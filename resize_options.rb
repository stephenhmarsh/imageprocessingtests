#!/usr/bin/env ruby

# rewrite of old shell scripts as ruby script
# modeled after https://gist.github.com/netzpirat/336871
# uses minimagick

#TODO: test with other formats / use file validation(?)

# How it works:
# Give the script:
  # * A folder of images to process
  # * (Optional) : An output folder (otherwise it creates one automatically based on timestamp and settings)
  # * TODO: Optional : A file of export options hashes to loop through
# The script processes the images based on hash(es) of settings and puts them in either A) a new folder specific to those settings or B) the folder specified
# There's a report about how long it took to do each folder and average time per image.

require 'find'
require 'mini_magick'
include MiniMagick

if ARGV.length < 1 && ARGV.length > 3
  puts "Usage: ruby resize_options.rb /path/to/inputdirectory [/path/to/outputdirectory] [/export_options.json]"
  exit 0
end

# Input folder
@input_path = ARGV[0] 

# Output folder
def set_output_path(set_name="")
  if ARGV[1]
    @output_path = ARGV[1]
    else
    @output_path = ("./output-#{Time.now.to_i}" + (set_name.length > 0 ? "-#{set_name}" : ""))
    `mkdir #{(@output_path)}`
    return @output_path
  end
end

# Options We're Running
if ARGV[2]
  # TODO : open the specified json file and use that
  # @options_set = parsed JSON
else
  # Unless given a JSON file, it will run these options by default
  @export_settings = {
    :web_from_previous => [
      { :label => 'full', :resize => '1985', :quality => 70},
      { :label => 'large', :resize => '1229', :quality => 70, :from_version => 'full'},
      { :label => 'med', :resize =>'977', :sharpen => '0x0.6', :quality => 70, :from_version => 'large'}, 
      { :label => 'grid', :resize =>'473', :sharpen => '0x0.6', :quality => 60, :from_version => 'med'},
      { :label => 'thumb', :resize =>'95', :sharpen => '0x0.6', :quality => 60, :from_version => 'grid'}
    ],
   :web_from_source => [
      { :label => 'full', :resize => '1985', :quality => 70},
      { :label => 'large', :resize => '1229', :quality => 70},
      { :label => 'med', :resize =>'977', :sharpen => '0x0.6', :quality => 70},
      { :label => 'grid', :resize =>'473', :sharpen => '0x0.6', :quality => 60},
      { :label => 'thumb', :resize =>'95', :sharpen => '0x0.6', :quality => 60}
    ]
  }
end


# Individual Image Processing
def process_image_for_web(params, file)
  filebase = File.basename(file,".jpg")

  if params[:from_version]
    processed = MiniMagick::Image.open("#{@output_path}/#{filebase}_#{params[:from_version]}.jpg")
  else
    processed = MiniMagick::Image.open(file)
  end

  start = Time.now

  puts "#{file}"
  puts "#{processed}"

  processed.combine_options do |c|
    c.resize "#{params[:resize]}"
    c.quality "#{params[:quality]}"
    c.strip
    c.adaptive_sharpen("#{params[:sharpen]}") if params[:sharpen]
  end

  # not baking settings info into filename right now
  # settings_info = "size-#{params[:label]}_quality-#{params[:quality]}_" + (params[:sharpen] ? "sharpen-#{params[:sharpen]}" : "no-sharpen") + (params[:from_version] ? "from-#{params[:from_version]}" : "") 

  puts "Writing #{@output_path}/#{filebase}_#{params[:label]}.jpg"
  processed.write "#{@output_path}/#{filebase}_#{params[:label]}.jpg"

  stop = Time.now
  time_total = stop - start
  puts "Processed image in #{time_total} seconds"
  @batch_time += time_total
end

# Process the images
@export_settings.each do |set_name, set_of_options|   # For every set of options...
  
  # export into a named, timestamped folder, or whatever was specified
  set_output_path(set_name)

  # Reports and Timers
  @batch_time = 0
  @processed_files = 0
  @skipped_files_list = 0
  @skipped_files = []
                                                     
  Find.find(ARGV[0]) do |f|
    if ['.jpg'].include?(File.extname(f))  # TODO: this should be tested with other formats like ani-gifs  
      set_of_options.each do |params|                 # for every file, process it with every option
        process_image_for_web(params, f)
      end
      @processed_files += 1
    else
      puts "Skip #{f}"
      @skipped_files_list += 1
      @skipped_files << f
    end 
  end # end files loop

  # Generate the performance report
  @total_time = Time.at(@batch_time).utc.strftime("%H hours %M minutes %S seconds")

  @export_settings_report = "
  Name: #{set_name} \n 
  Settings: \n #{set_of_options} \n \n
  Processed #{@processed_files} images in #{@total_time} \n
  Average: #{(@batch_time / @processed_files)} seconds per image \n 
  Skipped #{@skipped_files_list} files : #{@skipped_files}"

  puts @export_settings_report

  File.open("#{@output_path}/export_settings_report.txt", "w+") do |file|
    file.write(@export_settings_report)
  end # end file write

end
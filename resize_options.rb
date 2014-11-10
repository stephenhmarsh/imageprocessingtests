#!/usr/bin/env ruby

# rewrite of old shell scripts as ruby script
# modeled after https://gist.github.com/netzpirat/336871
# uses minimagick

# How it works:

# Each export option goes in a hash - example: "{label: 'big', resize: 2000}
# Groups of options can be put in an array and labeled, for example: 
#  "{ web_exports : [{some}, {options}], 
#     offline_exports : [{some}, {more}, {options}] 
#     expirement_1 : [{some}, {different}, {options}]" }
# The script will create folders based on the name of the options and the time.  Example: "/output-1415644186-web_exports" and "/output-1415644186-expirement_1"
  # Optional: Give the script a path to write to instead. All images will be outputted there.  Example: "/image-dump/1415644186-web_exports"

# You can give the script a JSON file of settings to run, but you will need to set output path to something (or 'none' to skip)
#   Example: ruby resize_options.rb ./originals ./image_output ./example.json
#        Or: ruby resize_options.rb ./originals none ./example.json

require 'find'
require 'json'
require 'mini_magick'

if ARGV.length < 1 && ARGV.length > 3
  puts "Usage: ruby resize_options.rb /path/to/inputdirectory [/path/to/outputdirectory] [/export_options.json]"
  exit 0
end

# Input folder
@input_path = ARGV[0] 

# Output folder
def set_output_path(set_name="")
  @output_path = ( (ARGV[1] && ARGV[1].downcase != 'none' ? "#{ARGV[1]}/" : "./output-") + "#{Time.now.to_i}" + (set_name.length > 0 ? "-#{set_name}" : ""))
  `mkdir #{@output_path}`
  return @output_path
end

# Options We're Running
if ARGV[2]
  @export_settings = JSON.parse(File.read("#{ARGV[2]}"), {symbolize_names: true})
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
def process_image_for_web(params, file, extension)
  start = Time.now
  filebase = File.basename(file, "#{extension}")

  if params[:from_version]
    processed = MiniMagick::Image.open("#{@output_path}/#{filebase}_#{params[:from_version]}#{extension}")
  else
    processed = MiniMagick::Image.open(file)
  end

  puts "#{file}"
  puts "#{processed}"

  processed.combine_options do |c|
    c.coalesce if extension == ".gif"
    c.resize "#{params[:resize]}"
    c.quality "#{params[:quality]}"
    c.strip
    c.adaptive_sharpen("#{params[:sharpen]}") if params[:sharpen]
  end  

  puts "Writing #{@output_path}/#{filebase}_#{params[:label]}#{extension}"
  processed.write "#{@output_path}/#{filebase}_#{params[:label]}#{extension}"

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
    if ['.jpg', '.gif'].include?(File.extname(f))  # TODO: this should be tested with other formats like ani-gifs  
      set_of_options.each do |params|                 # for every file, process it with every option
        process_image_for_web(params, f, File.extname(f))
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
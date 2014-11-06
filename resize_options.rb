#!/usr/bin/env ruby

# rewrite of old shell scripts as ruby script
# modeled after https://gist.github.com/netzpirat/336871
# uses minimagick


#TODO: get adaptive sharpen working - done
#TODO: make output dir if doesn't exist
#TODO: output "rest" formats with full outputted image as input (match app logic)
#TODO: test with other formats / use file validation(?)
#TODO: make it easy to loop/set & test & compare multiple quality options
#TODO: add perofmance/timing data


require 'find'
require 'mini_magick'
include MiniMagick

if ARGV.length < 1 &&  ARGV.length > 2
  puts "Usage: ruby resize_options.rb /path/to/inputdirectory [/path/to/outputdirectory]"
  exit 0
end

@input_path  = ARGV[0] 

if ARGV[1]
  @output_path = ARGV[1]
  else
  @output_path = "./output-#{Time.now.to_i}"
  `mkdir #{@output_path}`
end

# Timers 
@batch_time = 0


# each test, RMagick options for: { 'label' 'resize', 'crop', 'active-sharpen', 'quality' }
web_options = [
  { :label => 'full', :resize => '1985', :quality => 70},
  { :label => 'large', :resize => '1229', :quality => 70},
  { :label => 'med', :resize =>'977', :sharpen => '0x0.6', :quality => 70},
  { :label => 'grid', :resize =>'473', :sharpen => '0x0.6', :quality => 60},
  { :label => 'thumb', :resize =>'95', :sharpen => '0x0.6', :quality => 60}
]

def process_for_web(params, file)
  filebase = File.basename(file,".jpg")
  processed = MiniMagick::Image.open(file)

  start = Time.now

  puts "#{file}"
  puts "#{processed}"

  processed.combine_options do |c|
    c.resize "#{params[:resize]}"
    c.quality "#{params[:quality]}"
    c.strip
    c.adaptive_sharpen("#{params[:sharpen]}") if params[:sharpen]
  end

  puts "Writing #{@output_path}/#{filebase}_#{params[:label]}.jpg"
  processed.write "#{@output_path}/#{filebase}_#{params[:label]}.jpg"

  stop = Time.now
  time_total = stop - start
  puts "Processed image in #{time_total} seconds"
  @batch_time += time_total
end


Find.find(ARGV[0]) do |f|
  if ['.jpg'].include?(File.extname(f)) # TODO: this should be tested with other formats like ani-gifs
    web_options.each do |params| # for every file, process it with every option
      process_for_web(params, f)
    end
  else
    puts "Skip #{f}"
  end
  puts "Finished all images in #{Time.at(@batch_time).utc.strftime("%H hours %M minutes %S seconds")}"
end


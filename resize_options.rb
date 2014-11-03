#!/usr/bin/env ruby

# rewrite of old shell scripts as ruby script
# modeled after https://gist.github.com/netzpirat/336871
# uses minimagick


#TODO: get adaptive sharpen working
#TODO: make output dir if doesn't exist
#TODO: output "rest" formats with full outputted image as input (match app logic)
#TODO: test with other formats / use file validation(?)
#TODO: make it easy to loop/set & test & compare multiple quality options
#TODO: add perofmance/timing data


require 'find'
require 'mini_magick'
include MiniMagick

if ARGV.length != 2
  puts "Usage: ruby resize_options.rb /path/to/inputdirectory /path/to/outputdirectory"
  exit 0
end

# each test, RMagick options for: { 'label' 'resize', 'crop', 'active-sharpen', 'quality' }
first = [
  { :label => 'full', :resize => '1985', :quality => 70},
  { :label => 'large', :resize => '1229', :quality => 70}
]

rest = [
  { :label => 'med', :resize =>'977', :sharpen => '0x0.6', :quality => 70},
  { :label => 'grid', :resize =>'473', :sharpen => '0x0.6', :quality => 60},
  { :label => 'thumb', :resize =>'95', :sharpen => '0x0.6', :quality => 60}
]


Find.find(ARGV[0]) do |f|
  if ['.jpg'].include?(File.extname(f)) # TODO: this should be tested with other formats like ani-gifs
    first.each do |params|
      filebase = File.basename(f,".jpg")
      processed = MiniMagick::Image.open(f)

      puts "#{f}"
      puts "#{processed}"

      processed.resize "#{params[:resize]}"
      processed.quality "#{params[:quality]}"
      processed.strip
      #busted processed.adaptive-sharpen "#{params[:sharpen]}"

      puts "Writing #{ARGV[1]}/#{filebase}_#{params[:label]}.jpg"
      processed.write "#{ARGV[1]}/#{filebase}_#{params[:label]}.jpg"

    end
  else
    puts "Skip #{f}"

  end

end

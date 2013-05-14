#!/usr/bin/env ruby
#
# mztriz@gmail.com
# csv-to-json.rb
#
# mztriz$ ruby csv-to-json.rb
#
# [*] Automated CSV to JSON conversion with attributes for Panic Status Board                   
# [*] Author: Ava Gailliot                   
#                                            
# ######################################################################## 100.0%
# https://www.dropbox.com/s/sdfsdf/file1.csv.json
# ######################################################################## 100.0%
# https://dl.dropbox.com/s/5555555/file2.csv.json                      
#             
# Creative Commons Attribution-ShareAlike License: http://creativecommons.org/licenses/by-sa/3.0/

# Req Gems
require 'rubygems'
require 'json'
require 'open-uri'
require 'csv'


def read(url)
 file_name = url.to_s[/(\w*-*)\w*.csv$/]
 title = Array.new(0)
 data_seq = Array.new(0)
 hash = Hash.new(0)
 # Pull in the CSV file from the web and iterate through each line
 CSV.new(open(url),:headers => true, :header_converters => :symbol, :converters => :all).each do |line|
   # Grab the graph title -- this could be optimized but w/e
   title = line.headers[0]
   data_seq << line.headers[1..-1]
   # Generate hash from CSV data
   hash[line.fields[0]] = Hash[line.headers[1..-1].zip(line.fields[1..-1])]
 end
  
  # Try-Catch for title string manipulation 
 begin
  # Make the title pretty by getting rid of the underscores and capitalizing each word
  title = title.to_s.gsub!(/_/, ' ').split(" ").map(&:capitalize).join(" ")
 rescue
  title = title.to_s
 end
 
 data_seq = data_seq.first # Only need the first array
 csv_to_json(hash, title, data_seq, file_name)
end

def csv_to_json(data, title, datasequences, file_name)
  # Graph Config
  colors = %w[yellow green red purple blue mediumGray pink aqua orange lightGray]
  graph = Hash.new
  graph[:title] = title
  # Set the type of graph to be shown
  graph[:type] = 'bar'
  graph[:datasequences] = Array.new(0)
  index = 0
  datasequences.each do |seq_title|
   sequence = Hash.new(0)
   sequence[:title] = seq_title
   sequence_data = Array.new(0)
   data.each do |key, value|
   val = value[seq_title]
   sequence_data << { :title => key.to_s, :value => val }
  end
  sequence[:datapoints] = sequence_data
  sequence[:color] = colors[index]
  index +=1 
  graph[:datasequences] << sequence
 end
 # Write the file to disk
 File.open("#{Dir.pwd}/#{file_name}.json", "w") do |f|
  wrapper = Hash.new
  wrapper[:graph] = graph
  f.write wrapper.to_json
  end
  upload_to_dropbox(file_name) #Comment out this line below for Windows compatability
end

def upload_to_dropbox(file_name)
 # Shell out and do a fancy bash dropbox upload
 system "bash #{Dir.pwd}/dropbox_uploader.sh upload #{file_name}.json > /dev/null"
 system "bash #{Dir.pwd}/dropbox_uploader.sh share #{file_name}.json > /dev/null"
end

# Add the weblinks to your CSV files here
read("https://www.example.com/file1.csv")
read("https://dl.dropbox.com/s/5555555/file2.csv")

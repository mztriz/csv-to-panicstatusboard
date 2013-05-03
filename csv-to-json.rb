#!/usr/bin/env ruby
# Takes in a CSV file and converts to JSON with custom attributes for Panic Status Board
# Put script in a cronjob to have it rewrite the file to Dropbox every N times
# Linux only ATM

# Req Gems
require 'rubygems'
require 'date'
require 'json'
require 'open-uri'
require 'csv'
require 'date'

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
 # Make the title pretty by getting rid of the underscores and capitalizing each word
 title = title.to_s.gsub!(/_/, ' ').split(" ").map(&:capitalize).join(" ")
 data_seq = data_seq.first
 csv_to_json(hash, title, data_seq, file_name)
end

def csv_to_json(data, title, datasequences, file_name)
  # Graph Config
  colors = ['red', 'green', 'blue', 'purple', 'orange', 'gray']
  graph = Hash.new
  graph[:title] = title
  # Set the type of graph to be shown
  graph[:type] = 'bar'
  index = 0
  graph[:datasequences] = Array.new(0)
  datasequences.each do |seq_title|
   sequence = Hash.new(0)
   sequence[:title] = seq_title
   sequence_data = Array.new(0)
   data.each do |key, value|
   val = value[seq_title]
   sequence_data << { :title => key, :value => val }
  end
  sequence[:datapoints] = sequence_data
  sequence[:color] = colors[index]
  index +=1 
  graph[:datasequences] << sequence
 end
 # Write the file to disk
 File.open("#{file_name}.json", "w") do |f|
  wrapper = Hash.new
  wrapper[:graph] = graph
  f.write wrapper.to_json
  end
  upload_to_dropbox(file_name)
end

def upload_to_dropbox(file_name)
 # Shell out and do a fancy bash dropbox upload
 system "bash dropbox_uploader.sh upload #{file_name}.json > /dev/null"
 system "bash dropbox_uploader.sh share #{file_name}.json > /dev/null"
end

read("https://www.example.com/file1.csv")
read("https://www.example.com/file2.csv")

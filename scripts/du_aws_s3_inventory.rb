#!/bin/env ruby

require 'csv'
require 'du_aws_s3_inventory_gem'
require 'optparse'

#===
# Process command-line option 
#===
option = {}
OptionParser.new do |opt|
  opt.on('-i', '--inventry CSV_FILE', 'S3 invetntry CSV file'){|v| option[:i] = v}
  opt.on('-d', '--max-depth N', 'max depth'){|v| option[:d] = v}
  opt.on('-h', '--human-readable'){}
  opt.on('-a', '--all') {}
  opt.on('--help', 'show this help'){puts opt; exit}
  opt.parse!(ARGV)
end

#p option

#===
# Main
#===
csvf = option[:i]
target_path = (ARGV[0] || nil)
max_depth = (option[:d] || 9999).to_i
data = CSV.read(csvf)

path2size = {}
children = {}

data.each do |d|
  path = d[1]
  fsize = d[2].to_i
  path2size[path] = fsize
  
  if /\/$/.match(path)
    type = "d"
    a = path.split(/\//)
    parent = a[0..-2].join('/') + "/"
    edge = a[-1] + "/"
    unless children.has_key?(parent)
      children[parent] = []
    end
    children[parent] << {:type => type, :name => edge, :size => nil, :path => path}
  else
    type = "f"
    a = path.split(%r{/})
    parent = a[0..-2].join('/') + '/'
    edge = a[-1]
    unless children.has_key?(parent)
      children[parent] = []
    end
    children[parent] << {:type => type, :name => edge, :size => fsize, :path => path}
  end
  
end
require 'pp'

dirs_rsorted = children.keys.sort.reverse

dirs_rsorted.each do |d|
#  p d
#  p children[d].map{|a| a[:path]}
  total_size = children[d].map{|a| path2size[a[:path]]}.inject{|i, j| j+=i}
  path2size[d] = total_size
  
end

#max_depth = 3
path2size.each do |path, size|
  depth = path.count("/")
  if !target_path || /^#{target_path}/.match(path)
    if depth <= max_depth 
      if /\/$/.match(path)
        puts "#{DuAwsS3InventoryGem.human_readable_byte(size)[:display]}\t#{path}"
    end
    end
  end
end

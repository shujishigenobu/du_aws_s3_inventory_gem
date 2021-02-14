#!/bin/env ruby

require 'csv'
require 'du_aws_s3_inventory_gem'

csvf = ARGV[0]
target_path = (ARGV[1] || nil)
max_depth = (ARGV[2] || 9999).to_i
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

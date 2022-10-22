#!/usr/bin/env ruby
# coding: utf-8
# mongoloadファイルを生成

# TODO 引数化
user_name = "pub"
password = "pub"
db_name = "pubtator"
collection_name = "bc2pubtator"
load_file_dir_name = "load_files"
output_dir = "data/mongodb_data/#{load_file_dir_name}"
load_file = "data/mongodb_data/load.sh"
container_dir = "data/mongodb_data/#{load_file_dir_name}"

out = File.open(load_file, "w")
Dir.glob("#{output_dir}/*.json").sort_by {|fn| File.mtime(fn) }.each do |f|
  file_name = File.basename(f)
  out.puts "echo 'load start #{file_name}'"
  out.puts "mongoimport --jsonArray --db #{db_name} --collection #{collection_name} --host=localhost:27017 --file '#{container_dir}/#{file_name}'"
end
out.flush
out.close

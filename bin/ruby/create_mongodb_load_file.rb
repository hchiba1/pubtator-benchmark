# mongoloadファイルを生成

# TODO 引数化
user_name = "pub"
password = "pub"
db_name = "pubtator"
collection_name = "bc2pubtator"
load_file_dir_name = "load_files"
output_dir = File.expand_path("../../data/mongodb_data/#{load_file_dir_name}/", __FILE__)
load_file = File.expand_path("../../data/mongodb_data/load.sh", __FILE__)
container_dir = "/data/db/#{load_file_dir_name}"

out = File.open(load_file, "w")
Dir.glob("#{output_dir}/*.json").sort_by {|fn| File.birthtime(fn) }.each do |f|
  file_name = File.basename(f)
  command = "mongoimport -u #{user_name} -p #{password} --jsonArray --db #{db_name} --collection #{collection_name} --host=localhost:27017 --file '#{container_dir}/#{file_name}'"
  out.puts "echo 'load start #{file_name}'"
  out.puts command
end
out.flush
out.close
#!/usr/bin/env ruby
# coding: utf-8
require 'json'
require 'fileutils'

# JSONファイルから mongodbロード用のJSONファイルに変換
# type別の配列データを持つ構造に変換
# 配列は{id: xxxx}とハッシュの列挙
#
# 変換前
# [
#  {
#    "pmid": "3958000",
#    "type": "Species",
#    "id": "9606",
#    "label": "patients",
#    "source": "SR4GN"
#  },
#  {
#    "pmid": "3958000",
#    "type": "Disease",
#    "id": "MESH:D012544",
#    "label": "Scheuermann's kyphosis",
#    "source": "TaggerOne"
#  },
#  {
#    "pmid": "3958000",
#    "type": "Disease",
#    "id": "MESH:D007738",
#    "label": "kyphosis",
#    "source": "TaggerOne"
#  },...
#
# 変換後
# [
#   {
#     "pmid": "3958000",
#     "Species": [
#       {
#         "id": "9606"
#       }
#     ],
#     "Disease": [
#       {
#         "id": "MESH:D012544"
#       },
#       {
#         "id": "MESH:D007738"
#       },
#       {
#         "id": "MESH:D011183"
#       }
#     ]
#   }, ...
#
input_dir = ARGV[0] || exit
output_dir = ARGV[1] || exit
FileUtils.mkdir_p(output_dir) unless File.exist?(output_dir)

Dir.glob("#{input_dir}/*.json").sort_by{|fn| File.mtime(fn) }.each do |f|
  output_file = "#{output_dir}/#{File.basename(f)}"
  next if File.exist?(output_file)
  data_list = JSON.parse(File.read(f))
  pubmed_hash = data_list.group_by{|row| row["pmid"]} # PubMedID毎にグループ化
  pm_list = [] #PumMedID単位のリストにする
  pubmed_hash.each do |pmid, list|
    pminfo = { pmid: pmid}
    list.each do |row|
      pminfo[row["type"]] = [] if pminfo[row["type"]].nil?
      pminfo[row["type"]].push({id: row["id"]})
    end
    pminfo.each do |key, value|
      unless key.to_s == "pmid"
        value.uniq! #重複IDを削除(一つのPubMedに何度も9606が付いているようなケース)
      end
    end
    pm_list.push(pminfo)
  end
  File.open(output_file, "w") do |out|
    out.puts JSON.pretty_generate(pm_list)
  end
  puts "mongoimport --jsonArray --db pubtator --collection bc2pubtator --host=localhost:27017 --file #{output_file}"
end

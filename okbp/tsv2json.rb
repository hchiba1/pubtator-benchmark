#!/usr/bin/env ruby
# coding: utf-8
require 'json'
require 'fileutils'

# 約100万件毎にsplitしてjsonに出力する。PubMedIDが同じものは同じファイル内に収める
input_file = "bioconcepts2pubtatorcentral.tsv"
output_dir = "tsv2json"
FileUtils.mkdir_p(output_dir) unless File.exist?(output_dir)

File.open(input_file, "r") do |f|
  document_list = []
  file_idx = 1
  current_pmid = ""
  f.each_line do |line|
    columns = line.chomp.strip.split("\t")
    pmid = columns[1]
    hash = {
      pmid: pmid,
      type: columns[2],
      id: columns[3],
      label: columns[4],
      source: columns[5]
    }
    if document_list.size > 1000000 && current_pmid != pmid
      File.open("#{output_dir}/#{format("%04d", file_idx)}.json", "w") do |f|
        f.puts JSON.pretty_generate(document_list)
      end
      document_list = []
      file_idx += 1
    end
    current_pmid = pmid
    document_list.push(hash)
  end
  File.open("#{output_dir}/#{format("%04d", file_idx)}.json", "w") do |f|
    f.puts JSON.pretty_generate(document_list)
  end
end

#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
def extract_lyric filename
  open(filename) do |f|
    while line = f.gets
      break if line.include? 'lyric:'
    end
    f.read.gsub('　', ' ')
  end
end

def analysis text
  return text
end


require './libs/nlp.rb'

filenames = ARGV

tf_list = []
filenames.each do |filename|
  lyric = extract_lyric filename
  result = analysis lyric

  morphemes = NLP.parse(result)
  nouns = NLP.extract_noun(morphemes)
  tf = NLP.tf(morphemes.map{|m|m[:surface]})

  tf_list << tf
end

tf = NLP.merge_tf_list tf_list

tf.sort_by{|t, f| f}.each do |t, f|
  next if t.length <= 1

  puts "#{t}, #{f}"
end

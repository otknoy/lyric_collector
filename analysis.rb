#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

def extract_lyric text
  text.split("lyric:\n").last
end


filenames = ARGV

lyrics = filenames.map do |filename|
  text = open(filename).read.gsub('　', ' ')
  extract_lyric(text)
end

require './libs/nlp.rb'
tf_list = []
lyrics.each do |lyric|
  morphemes = NLP.parse(lyric)
  # morphemes = NLP.join_nouns(morphemes)
  nouns = NLP.extract_noun(morphemes)

  basic_forms = nouns.map{|m|m[:basic_form]}.select{|m|m!='*'}
  tf = NLP.tf(basic_forms)

  tf_list << tf
end

df = NLP.df tf_list
tfidf_list = NLP.tfidf tf_list, df

tfidf_list.each_with_index do |tfidf, i|
  printf("document %03d: %s\n", i, filenames[i])
  tfidf.sort_by{|t,f|f}.each do |term, tfidf|
    puts "#{term}: #{tfidf}"
  end
  puts
end


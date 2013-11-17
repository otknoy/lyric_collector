#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require './libs/nlp.rb'


def extract_lyric text
  text.split("lyric:\n").last
end

require 'matrix'
def to_document_vector tf, df
  dv = {}
  df.each do |k, v|
    if tf.has_key? k
      dv[k] = tf[k]
    else
      dv[k] = 0.0
    end
  end
  Vector[*dv.values]
end
  

def cos_sim dv1, dv2
  dv1.inner_product(dv2)
end


filenames = ARGV

lyrics = filenames.map do |filename|
  text = open(filename).read.gsub('　', ' ')
  extract_lyric(text)
end

# tfidf
tf_list = []
lyrics.each do |lyric|
  morphemes = NLP.parse(NLP.normalize(lyric))
  nouns = NLP.extract_noun(morphemes)
  basic_forms = nouns.map{|m|m[:basic_form]}.select{|m|m!='*'}
  tf_list << NLP.tf(basic_forms)
end

df = NLP.df tf_list
tfidf_list = NLP.tfidf tf_list, df


# tfidf, tf, df
morphemes = NLP.parse(lyrics.join)
nouns = NLP.extract_noun(morphemes)
basic_forms = nouns.map{|m|m[:basic_form]}.select{|m|m!='*'}
tf = NLP.tf(basic_forms)

# tf.sort_by{|k,v|v}.each do |term, tf|
#   puts "#{term}: #{tf}, #{df[term]}"
# end

tfidf_list.each_with_index do |tfidf, i|
  puts filenames[i]
  puts 'term, tf, tfidf, document_tf, df'
  tfidf.sort_by{|t,f|f}.each do |term, tfidf|
    puts "#{term}, #{tf_list[i][term]}, #{tfidf}, #{tf[term]}, #{df[term]}"
  end
  puts
end


tfidf_list.combination(2) do |tfidf1, tfidf2|
  v1 = to_document_vector(tfidf1, df)
  v2 = to_document_vector(tfidf2, df)
  
  puts v1.inner_product(v1)
end

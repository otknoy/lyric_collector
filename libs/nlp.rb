#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'MeCab'

class NLP
  def self.parse text
    m = MeCab::Tagger.new('-Ochasen')
    node = m.parseToNode(text)

    morphemes = []
    while node
      surface = node.surface
      features = node.feature.split(',')

      basic_form = features[6]

      morphemes.push({:surface    => surface,
                       :basic_form => basic_form,
                       :posid      => node.posid,
                       :features => features})

      node = node.next
    end
    morphemes
  end

  def self.join_nouns morphemes
    noun_id_list = (36..67)
    
    joined = []
    nouns = []
    morphemes.each do |m|
      if noun_id_list.include?(m[:posid])
        nouns << m
        next
      end

      if not nouns.empty?
        joined_noun = {
          :surface    => nouns.map{|m|m[:surface]}.join,
          :basic_form => nouns.map{|m|m[:basic_form]}.join,
          :posid      => nouns.first[:posid],
          :features   => nouns.first[:features]}
        nouns = []
          
        joined << joined_noun
      end
      joined << m
    end
    joined
  end
  
  def self.extract_noun morphemes
    noun_id_list = (36..67)

    morphemes.select do |m|
      noun_id_list.include?(m[:posid])
    end
  end

  def self.tf terms
    tf = {}
    terms.each do |t|
      tf[t] = 0 unless tf.has_key? t
      tf[t] += 1
    end
    tf
  end

  def self.df tf_list
    df = {}
    tf_list.each do |tf|
      tf.keys.each do |t|
        df[t] = 0 unless df.has_key? t
        df[t] += 1
      end
    end
    df
  end

  def self.tfidf tf_list, df
    n = tf_list.length
    tfidf_list = []
    tf_list.each do |tf|
      tfidf = {}
      tf.keys.each do |term|
        tfidf[term] = tf[term] * Math.log(n/df[term])
      end
      tfidf_list.push(tfidf)
    end
    tfidf_list
  end
end


if __FILE__ == $0
  text = '山下くんは山下さんと東京特許許可局に行った。'
  
  morphemes = NLP.parse(text)
  puts "morphemes:"  
  puts morphemes.map{|m|m[:surface]}.join(' ')

  puts "join nouns"
  puts NLP.join_nouns(morphemes).map{|m|m[:surface]}.join(' ')

  nouns = NLP.extract_noun(morphemes)
  puts "nouns:"
  puts nouns.map{|n|n[:surface]}.join(' ')

  tf = NLP.tf(morphemes.map{|m|m[:surface]})
  puts "tf:"
  puts tf
end

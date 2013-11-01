#!/usr/bin/ruby
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
                       :feature => node.feature})

      node = node.next
    end
    morphemes
  end

  def self.extract_noun morphemes
    nounid_list = [38, *(41..47)] 

    morphemes.select do |m|
      nounid_list.include?(m[:posid])
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

  def self.merge_tf_list tf_list
    merged_tf = {}
    tf_list.each do |tf|
      tf.each do |t, f|
        merged_tf[t] = 0 unless merged_tf.has_key? t
        merged_tf[t] += f
      end
    end
    merged_tf
  end
end


if __FILE__ == $0
  text = '山下くんは山下さんと山下に行った。'
  
  morphemes = NLP.parse(text)
  puts "morphemes:"  
  puts morphemes

  # nouns = NLP.extract_noun(morphemes)
  # puts "nouns:"
  # puts nouns

  # tf = NLP.tf(morphemes.map{|m|m[:surface]})
  # puts "tf:"
  # puts tf
end

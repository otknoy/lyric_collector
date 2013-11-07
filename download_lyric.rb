#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require './libs/JLyric.rb'

out_dir = './output'
# query = 'さくら'
query = 'さだまさし'
puts "query: #{query}"

uri_list = JLyric.get_search_results_by_artist query
puts "#{uri_list.length} uris"

dir = "#{out_dir}/#{query}"
FileUtils::mkdir_p dir

uri_list.each do |uri|
  info = JLyric.get_song_info uri

  title = info[:title]
  singer, writer, composer = info[:status]
  lyric = info[:lyric]
  
  filename = dir + "/#{title}_#{singer}.txt"; puts filename
  open(filename, 'w') do |f|
    f.write "title:\n#{title}\n\n"
    f.write "singe:\n#{singer}\n\n"
    f.write "writer:\n#{writer}\n\n"
    f.write "composer:\n#{composer}\n\n"
    f.write "lyric:\n#{lyric}}\n"
  end
end



# output for lda
# lyrics = info_list.map{|i|i[:lyric]}
# require './nlp'
# open(out_dir + '/test.dat', 'w') do |f|
#   lyrics.each do |l|
#     morphemes = NLP.parse(l)
#     nouns = NLP.extract_noun(morphemes)
#     f.write(nouns.map{|n|n[:surface]}.join(' ') + "\n")
#   end
# end

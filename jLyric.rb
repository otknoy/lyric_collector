#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'open-uri'
require 'uri'
require 'nokogiri'

class JLyric
  def self.get_search_results title
    results = []
    i = 1
    loop do
      r = search(i, title, 2, '', 2, '', 2)
      break if r.empty?
      results.concat(r)
      i += 1
    end
    results
  end

  def self.search p, kt, ct, ka, ca, kl, cl
    uri = 'http://search.j-lyric.net/index.php' +
      "?p=#{p}&kt=#{kt}&ct=#{ct}&ka=#{ka}&ca=#{ca}&kl=#{kl}&cl=#{cl}"
    doc = Nokogiri::HTML(open(URI.escape(uri)))

    lyricList = doc.css('#lyricList')
    results = lyricList.css('div.body').map do |e|
      info = {}
      info[:title] = e.css('div.title').inner_text
      info[:uri] = e.css('div.title/a').first[:href]
      info[:status] = e.css('div.status').inner_text
      info
    end
  end

  def self.get_song_info uri
    doc = Nokogiri::HTML(open(uri))
    lyricBlock = doc.css('#lyricBlock')
    info = {}
    info[:title] = lyricBlock.css('div.caption').inner_text
    info[:status] = lyricBlock.xpath('//div/table//tr/td').inner_text
    info[:lyric] = lyricBlock.css('#lyricBody').inner_text.strip.gsub(/\r?\n/, "\n")
    info
  end
end

if __FILE__ == $0
  # get lyric
  # uri = 'http://j-lyric.net/artist/a002907/l00731d.html'
  # info = JLyric::get_song_info uri
  # puts info[:artist]
  # puts info[:lyric]

  # get uri list by title
  results = JLyric::get_search_results 'さくら'
  results.each do |r|
    uri = r[:uri]
    info = JLyric::get_song_info uri

    puts 'title:'
    puts info[:title]
    puts 'status:'
    puts info[:status]
    puts 'lyric:'
    puts info[:lyric]    
    puts
  end

  # require '../nlp/nlp.rb'
  # morphems = NLP.parse(lyrics.map{|l|l['歌詞'].join}.join)
  # nouns = NLP.extract_noun(morphems)
  # word_dist = NLP.tf(nouns.map{|n|n[:surface]}).sort_by{|k, v| v}
  # word_dist.each do |t, f|
  #   printf("%3d: %s\n", f, t)
  # end
end

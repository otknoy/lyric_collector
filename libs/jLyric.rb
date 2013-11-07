#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'open-uri'
require 'uri'
require 'nokogiri'

class JLyric
  def self.get_search_results_by_title title
    self.search(title, 2, '', 2, '', 2)
  end

  def self.get_search_results_by_artist artist
    self.search('', 2, artist, 1, '', 2)
  end

  def self.search kt, ct, ka, ca, kl, cl
    results = []
    p = 1
    loop do 
      uri = 'http://search.j-lyric.net/index.php' +
        "?p=#{p}&kt=#{kt}&ct=#{ct}&ka=#{ka}&ca=#{ca}&kl=#{kl}&cl=#{cl}"
      doc = Nokogiri::HTML(open(URI.escape(uri)))
      lyricList = doc.css('#lyricList')
      uri_list = lyricList.css('div.body').map do |e|
        uri = e.css('div.title/a').first[:href]
      end

      break if uri_list.empty?
      results.concat(uri_list)
      p += 1
    end
    results.flatten
  end

  def self.get_song_info uri
    doc = Nokogiri::HTML(open(uri))
    lyricBlock = doc.css('#lyricBlock')
    info = {}
    info[:title] = lyricBlock.css('div.caption').inner_text.gsub(/[ 　\/]/, '')
    info[:status] = lyricBlock.xpath('//div/table//tr/td').map do |td|
      td.inner_text.split('：')[1].gsub(/[ 　\/]/, '')
    end
    info[:lyric] = lyricBlock.css('#lyricBody').inner_text.strip.gsub(/\r?\n/, "\n").gsub('　', ' ')
    info
  end
end


if __FILE__ == $0
  # get lyric
  uri = 'http://j-lyric.net/artist/a002907/l00731d.html'
  info = JLyric.get_song_info uri
  puts info[:title]
  puts info[:status].first
  puts info[:lyric]
  
  # get uri list by title
  title = '天体'
  uri_list = JLyric.get_search_results_by_title title
  puts uri_list
end

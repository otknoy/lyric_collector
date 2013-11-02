#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'sparql/client'

def fetch_abstract artist
  query = <<EOS
SELECT ?o
WHERE {
  <http://ja.dbpedia.org/resource/#{artist}> dbpedia-owl:abstract ?o.
}
EOS

  client = SPARQL::Client.new('http://ja.dbpedia.org/sparql')
  result = client.query(query)
  if result.first
    result.first[:o].to_s
  else
    ''
  end
end


def extract_artist filename
  open(filename) do |f|
    while line = f.gets
      break if line.include? 'status:'
    end
    f.gets.gsub(/[　 ]/, '_').chop
  end
end


if __FILE__ == $0
  filenames = ARGV

  artists = filenames.map do |filename|
    extract_artist filename
  end

  artists.each do |artist|
    abstract = fetch_abstract artist
    if abstract.include? '男性'
      print 'm: '
    elsif abstract.include? '女性'
      print 'f: '
    else
      print 'n: '
    end
    puts artist
  end
  

end

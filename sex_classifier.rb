#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'sparql/client'

def fetch_artist_list
  query = <<EOS
SELECT ?artist ?label ?abstract
WHERE {
  ?artist a dbpedia-owl:MusicalArtist;
   rdfs:label ?label;
   dbpedia-owl:abstract ?abstract.
}
EOS

  client = SPARQL::Client.new('http://ja.dbpedia.org/sparql')
  result = {}
  client.query(query).map do |solution|
    artist = solution[:label].to_s
    abstract = solution[:abstract].to_s
    result[artist] = abstract
  end
  result
end

def estimate_sex_from_abstract abstract
  if abstract.include? '男性'
    'm'
  elsif abstract.include? '女性'
    'f'
  else
    'n'
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

  artists = fetch_artist_list

  names = filenames.map do |filename|
    n = extract_artist filename
    
    print filename.split('/')[-1] + ', ' + n + ', '
    artists.each do |artist, abstract|
      if artist.include?(n) or n.include?(artist)
        print estimate_sex_from_abstract(abstract)
      end
    end
    puts
  end
    
end

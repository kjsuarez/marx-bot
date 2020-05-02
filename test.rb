require 'nokogiri'
require 'open-uri'
doc = Nokogiri::HTML(open('https://www.reddit.com/r/AnarchoWave/'))
doc.css('img')[2].attributes["src"].value
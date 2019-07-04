require 'sinatra'
require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open('https://coinmarketcap.com/currencies/bitcoin/historical-data/?start=20180703&end=20190703'))
tds = doc.css('td')

date = "Jul 01, 2019"
result = ""

tds.length.times do |i|
  if tds[i].to_s.include? date
    result = tds[i + 4].to_s.split('">')[1].split('</td>')[0]
  end
end

get '/' do
  "#{date}: #{result}"
end

require 'sinatra'
require 'nokogiri'
require 'open-uri'

def getHistory
  doc = Nokogiri::HTML(open('https://coinmarketcap.com/currencies/bitcoin/historical-data/?start=20180703&end=20190703'))
  tds = doc.css('td')
  time = Time.new

  weekAgo = (time - (7*24*60*60)).strftime("%b %d, %Y")
  yearAgo = (time - (365*24*60*60)).strftime("%b %d, %Y")

  week = getPrice(weekAgo, tds)
  year = getPrice(yearAgo, tds)

  return week, year
end

def getPrice(date, tds)
  tds.length.times do |i|
    if tds[i].to_s.include? date
      return tds[i + 4].to_s.split('">')[1].split('</td>')[0]
    end
  end
  return 'not found'
end

def getCurrent
  doc = Nokogiri::HTML(open('https://coinmarketcap.com/currencies/bitcoin/historical-data/?start=20180703&end=20190703'))
  spans = doc.css('span')
  current = 'not found'
  day = 'not found'

  spans.length.times do |i|
    if current == 'not found' && (spans[i].to_s.include? "data-currency-value")
      current = spans[i].to_s.split('value>')[1].split('</')[0]
    end
    if day == 'not found' && (spans[i].to_s.include? "data-format-percentage")
      day = spans[i].to_s.split('value')[1].split('>')[1].split('</')[0]
    end
  end

  return current, day
end

def render(current, day, week, year)
  get '/' do
    @current = current
    @day = day
    @week = week
    @year = year
    erb :index
  end
end



time = Time.new
puts "today: " + time.strftime("%b %d, %Y")

current, day = getCurrent()
week, year = getHistory()

week = sprintf('%.2f', (current.to_f - week.to_f) / week.to_f * 100)
week.to_f < 0 ? week = '-' + week.to_s :  week = '+' + week.to_s

year = sprintf('%.2f', (current.to_f - year.to_f) / year.to_f * 100)
year.to_f < 0 ? year = '-' + year.to_s :  year = '+' + year.to_s

current = '$' + current.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse

day.to_f < 0 ? day = '-' + day.to_s : day = '+' + day.to_s



render(current, day, week, year)

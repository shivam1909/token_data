
require 'open-uri'
require 'watir'
require 'nokogiri'
require 'httparty'
require "pry"

def empty?(string)
  string == "" || string.nil?
end

def value_or_empty_text(text)
  if empty? text
    ""
  else
    text
end
end

def empty_link(link)
  if link.exists?
    link.href
  else
    " "
  end
end

browser=Watir::Browser.new :chrome

browser.goto('https://www.tokendata.io/')
puts browser.title

sleep 10
document = Nokogiri::HTML(browser.html)
sleep 10
table=document.css('.dataTable')[1]
ico_data = []
while !browser.li(class: ['disabled','next']).a.exists? do
ico_trs = browser.tables(class: 'dataTable')[1].trs
 ico_trs.each do |tr|
  #tr.tds.each do |td|

  next if tr.text == ""

  puts tr.tds[1].text

  ico_map = {}


  ico_map[:website] = empty_link(tr.tds[0].a)
  ico_map[:name] = value_or_empty_text(tr.tds[1].text)
  ico_map[:ticker] = value_or_empty_text(tr.tds[2].text)
  ico_map[:status] = value_or_empty_text(tr.tds[3].text)
  #binding.pry
  ico_map[:raised] = value_or_empty_text(tr.tds[4].text)
  ico_map[:date]  = value_or_empty_text(tr.tds[5].text)
  ico_map[:sale_price] = value_or_empty_text(tr.tds[6].text)
  ico_map[:current_price] = value_or_empty_text(tr.tds[7].text)
  ico_map[:return] = value_or_empty_text(tr.tds[8].text)
  ico_map[:whitepaper] = empty_link(tr.tds[9].a)

   ico_data << ico_map

 end
browser.li(class: 'next').a.click
 sleep 2



end



ico_data.each do |row|
  CSV.open("token_data_raised.csv","a") do |csv|
    csv << row.values
  end
end

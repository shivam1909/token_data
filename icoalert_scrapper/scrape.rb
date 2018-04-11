require 'watir'
require 'watir-scroll'
require 'csv'
require 'pry'

def write_into_file(filename, array)
  CSV.open(filename,  "ab") do |csv|
    csv << array
  end
end

def read_file(filename)
  if File.exist?(filename)
    array = []
    CSV.foreach(filename) do |row|
      row.each do |cell|
        array << cell
      end
    end
    array
  end
end

def number_of_tiles(browser)
  browser.divs(class: ["ico-card"]).count
end

def collect_data(browser)
  browser.divs(class: ["ico-card"]).each do |ico_tile|
    hash = {}
    hash[:status] = ico_tile.divs(class: ["ico-card-body-banner-subheading", "upper"]).first.inner_html.gsub('<br>', ' ')
    if ico_tile.divs(class: ["ico-card-body-banner-heading", "upper"]).first.exists?
      hash[:status] = ico_tile.divs(class: ["ico-card-body-banner-heading", "upper"]).first.text + hash[:status]
    end
    hash[:name] = ico_tile.divs(class: ["ico-card-body-details-title", "upper"]).first.divs.first.inner_html
    hash[:website_link] = ico_tile.as(class: ['icoalert-btn', 'icoalert-outline']).first.href
    write_into_file("output.csv", hash.values)
  end
end

browser = Watir::Browser.new :chrome

browser.goto("https://www.icoalert.com/")
until number_of_tiles(browser) > 1500
  browser.scroll.to :bottom
  sleep 10
end
collect_data(browser)
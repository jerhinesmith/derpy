require 'open-uri'
require 'nokogiri'

class Culture
  ROOT_URL = "http://www.goodreads.com/author/quotes/4339.David_Foster_Wallace"

  def call
    random_culture
  end

  def self.call
    new().call
  end

  def random_culture
    # Get the main page
    root = Nokogiri::HTML(open(ROOT_URL))

    # Total pages
    total_pages = root.xpath("//a[contains(@href, 'page=')]").map(&:text).map(&:to_i).max

    # Only interested in the first half of pages
    max_page = total_pages / 2

    # Grab a random page
    doc = Nokogiri::HTML(open("#{ROOT_URL}?page=#{max_page + 1}"))

    # Grab a random quote
    doc.css('.quoteText').collect{|q| q.children.first.text}.map(&:strip).sample
  end
end

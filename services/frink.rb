require 'open-uri'
require 'json'

class Frink
  def self.call(text)
    url = search_url(text)
    data = (JSON.parse(open(url).read.to_s) || [])[1]
    return unless data

    "https://www.frinkiac.com/img/#{data['Episode']}/#{data['Timestamp']}/medium.jpg"
  end

  private

  def self.search_url(terms)
    "https://www.frinkiac.com/api/search?q=#{CGI.escape(terms)}"
  end
end

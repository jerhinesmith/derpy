require 'open-uri'
require 'faraday'
require 'json'

class GifCjh
  UPDATE_DICTIONARY_URI = 'http://txtpub.com/0x459rai8'
  DICTIONARY_URI = "#{UPDATE_DICTIONARY_URI}.txt"

  HELP = <<-EOF
/gif                returns a list of possible keys
/gif KEY            returns a gif if one is found
/gif add KEY URL    adds a new url for the given key
/gif help           returns this list
EOF

  def get(tag)
    dictionary[tag.to_s.to_sym].sample
  end

  def add(key, url)
    success = false

    return unless key && url
    return unless key.to_s.size > 0

    if url_exists?(url)
      lines << "#{key}: #{url}"
      body = {document: {body: lines.join("\n")}}.to_json

      res = Faraday.put(UPDATE_DICTIONARY_URI, body) do |req|
        req.headers['Content-Type'] = 'application/json'
      end

      success = res.success? || res.status == 302
    end

    success
  end

  def list
    dictionary.keys.sort.join(", ")
  end

  private

  def lines
    @lines ||= open(DICTIONARY_URI).readlines.map(&:strip).delete_if{|l| l.empty?}
  end

  def dictionary
    return @dictionary if defined?(@dictionary)

    @dictionary = Hash.new{|h, k| h[k] = []}

    lines.map{|l| l.split(':', 2)}.each do |k, v|
      @dictionary[k.downcase.to_sym] << v.strip
    end

    @dictionary
  end

  def url_exists?(url)
    begin
      res = Faraday.head(url)
      res.success?
    rescue
      false
    end
  end
end

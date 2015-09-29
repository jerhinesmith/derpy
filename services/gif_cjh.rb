require 'open-uri'
require 'faraday'
require 'json'
require_relative '../lib/redis_wrapper'

class GifCjh

  include RedisWrapper

  SCOPE = 'gifs'
  HELP = <<EOF

/gif                         returns a list of possible keys
/gif KEY                     returns a gif if one is found
/gif show KEY                show the url for the given key
/gif add KEY URL             adds a new url for the given key
/gif remove KEY URL          adds a new url for the given key
/gif help                    returns this list
EOF

  def get(tag)
    key = sanitize_key(tag)
    return unless key && key.to_s.size > 0

    redis do |r|
      r.srandmember(key.to_sym)
    end
  end

  def add(raw_key, url)
    key = sanitize_key(raw_key)

    return false unless key && url
    return false unless key.to_s.size > 0

    redis do |r|
      r.sadd(key, url)
    end
  end

  def remove(raw_key, url)
    key = sanitize_key(raw_key)

    return false unless key && url
    return false unless key.to_s.size > 0

    redis do |r|
      r.srem(key, url)
    end
  end

  def list(prefix = SCOPE, prefixed = true)
    key = prefix.nil? ? '*' : "#{prefix}/*"
    redis do |r|
      keys = r.keys(key).sort
      prefixed ? keys : keys.map{|k| k.gsub("#{prefix}/", '') }
    end
  end

  def gifs(prefix = SCOPE)
    data = {}
    key = prefix.nil? ? '*' : "#{prefix}/*"
    redis do |r|
      keys = r.keys(key).sort
      r.pipelined do
        keys.each do |key|
          data[key] = r.smembers(key)
        end
      end
    end

    data
  end

  private

  def sanitize_key(key)
    key = key.to_s.downcase.gsub(/\s/, '')
    return unless key.to_s.size > 0
    "#{SCOPE}/#{key}"
  end
end

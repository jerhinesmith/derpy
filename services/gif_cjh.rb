require 'open-uri'
require 'faraday'
require 'json'
require 'redis'

class GifCjh
  HELP = <<EOF
/gif                         returns a list of possible keys
/gif KEY                     returns a gif if one is found
/gif add KEY URL             adds a new url for the given key
/gif remove KEY URL          adds a new url for the given key
/gif help                    returns this list
EOF

  def get(tag)
    redis do |r|
      r.srandmember(tag.to_s.to_sym)
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

  def list
    @redis.keys("*").sort.join(", ")
  end


  private

  def redis
    @redis = Redis.new(url: ENV['REDISCLOUD_URL'])
    result = yield @redis
    @redis.quit
    result
  end

  def sanitize_key(key)
    key.to_s.downcase.gsub(/\s/, '')
  end
end

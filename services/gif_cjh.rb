require 'open-uri'
require 'faraday'
require 'json'
require_relative '../lib/redis_wrapper'

class GifCjh
  include RedisWrapper

  HELP = <<EOF

/gif                         returns a list of possible keys
/gif KEY                     returns a gif if one is found
/gif show KEY                show the url for the given key
/gif add KEY URL             adds a new url for the given key
/gif remove KEY URL          removes the url for the given key
/gif help                    returns this list
EOF

  attr_reader :key, :url

  def initialize(key, url = nil)
    @key = key.to_s
    @url = url.to_s
  end

  def get
    return unless has_key?
    store.rand(key)
  end

  def add
    return unless has_key? && has_url?
    store.add(key, url)
  end

  def remove
    return unless has_key? && has_url?
    store.remove(key, url)
  end

  def keys(scope = '*', full_path = false)
    store.keys(scope, full_path).sort
  end

  def gifs(prefix = SCOPE)
    keys = store.keys('*', true).sort

    data = {}
    redis do |r|
      r.pipelined do
        keys.each{|key| data[key] = r.smembers(key) }
      end
    end

    data
  end

  private

  def has_key?
    key && key.size > 0
  end

  def has_url?
    url && url.size > 0
  end

  def self.store
    @store ||= Keystore.new(:gifs)
  end

  def store
    self.class.store
  end
end

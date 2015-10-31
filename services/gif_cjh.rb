require 'open-uri'
require 'faraday'
require 'json'
require_relative '../lib/redis_wrapper'

class GifCjh
  include RedisWrapper
  attr_accessor :key, :url

  def initialize(key = nil, url = nil)
    @key = key.to_s
    @url = url.to_s
  end

  def self.find(*tags)
    results = []
    [*tags].each{|key| results += store.list(key) }
    [*tags].each{|key| results += store.list("tags/#{key}") }

    # Group keys by number of occurrences and pick the most frequent
    weights = results.group_by{|e| e }.values.group_by{|a| a.size }
    puts "Gif weights: #{weights.inspect}"
    (weights[weights.keys.max] || [[]]).sample.first
  end

  def get
    return unless has_key?
    store.rand(key)
  end

  def add
    return unless has_key? && has_url?
    tags = key.split(',')
    store.add(tags.shift, url)

    tags.each do |tag|
      self.class.tag(tag, url)
    end
  end

  def remove
    return unless has_key? && has_url?
    store.remove(key, url)
  end

  def keys(scope = '*', full_path = false)
    store.keys(scope, full_path).sort
  end

  def self.tag(key, url)
    key.split(',').each do |tag|
      next unless tag && tag.size > 0
      store.add("tags/#{tag}", url)
    end
  end

  def list
    return [] unless has_key?
    store.list(key)
  end

  def tags
    return [] unless has_key?
    gifs("tags/#{key}")
  end

  def gifs(scope = '*')
    keys = store.keys(scope, true).sort

    data = {}
    redis do |r|
      r.pipelined do
        keys.each{|key| data[key] = r.smembers(key) }
      end
    end

    data
  end

  def has_key?
    key && key.size > 0
  end

  def has_url?
    url && url.size > 0
  end

  private

  def self.store
    @store ||= Keystore.new(:gifs)
  end

  def store
    self.class.store
  end
end

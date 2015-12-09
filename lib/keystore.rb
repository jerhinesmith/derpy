require_relative '../lib/redis_wrapper'

class Keystore
  include RedisWrapper

  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def keys(scope = '*', full_path = false)
    results = []
    redis{|r| results = r.keys(scoped(scope)) }
    return results if full_path
    filter(results, scope)
  end

  def get(key)
    redis{|r| r.get(scoped(key)) }
  end

  def set(key, value)
    redis{|r| r.set(scoped(key), value) }
  end

  def add(key, value)
    redis{|r| r.sadd(scoped(key), value) }
  end

  def del(key)
    redis{|r| r.del(scoped(key)) }
  end

  def remove(key, value)
    redis{|r| r.srem(scoped(key), value) }
  end

  def list(key)
    redis{|r| r.smembers(scoped(key)) }
  end

  def rand(key)
    redis{|r| r.srandmember(scoped(key)) }
  end

  def hash_get(key)
    redis{|r| r.hgetall(scoped(key)) }
  end

  def hash_set(key, name, value)
    redis{|r| r.hset(scoped(key), name, value) }
  end

  def increment(key)
    value = get(key)
    value = (value.to_i || 0) + 1
    set(key, value)
    value
  end

  def decrement(key)
    value = get(key)
    value = (value.to_i || 0) - 1
    set(key, value)
    value
  end

  private

  def scoped(key)
    [scope, key].join('/')
  end

  def sanitized(key)
    key.to_s.downcase.gsub(/\s/, '')
  end

  def filter(keys, scope)
    elements = scope.split('/')[0..-2]
    keys.map{|key| key.gsub(/^.*#{elements.last}\//, '') }
  end
end

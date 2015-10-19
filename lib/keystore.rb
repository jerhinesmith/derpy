require_relative '../lib/redis_wrapper'

class Keystore
  include RedisWrapper

  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def keys
    redis{|r| r.keys }
  end

  def get(key)
    redis{|r| r.get(scoped(key)) }
  end

  def set(key, value)
    redis{|r| r.set(scoped(key), value) }
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
    value = (value || 0) - 1
    set(key, value)
    value
  end

  private

  def scoped(key)
    [scope, key].join('/')
  end
end

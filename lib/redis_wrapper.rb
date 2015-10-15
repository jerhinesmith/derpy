require 'redis'

module RedisWrapper

  private

  def redis
    @redis = Redis.new(url: ENV['REDISCLOUD_URL'])
    result = yield @redis
    @redis.quit
    result
  end
end

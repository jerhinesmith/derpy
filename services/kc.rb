require "twitter"

class Kc

  ACCOUNT_NAME = "kc_advice"
  NUMBER_OF_TWEETS = 200
  CONSUMER_KEY = "pqAHeAczxGlq1m0K7V4WRnOgj"
  CONSUMER_SECRET = ENV["TWITTER_CONSUMER_SECRET"]
  ACCESS_TOKEN = "23369679-mAKj448qj40u3in93Ldw6HkooiOKspxnUwRNsloA7"
  ACCESS_SECRET = ENV["TWITTER_ACCESS_SECRET"]

  attr_reader :tweets

  def initialize
    @tweets = _twitter_client.user_timeline(ACCOUNT_NAME, :count => NUMBER_OF_TWEETS)
  end

  def random_tweet
    @tweets.sample.text
  end

  def _twitter_client
    @twitter_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = CONSUMER_KEY
      config.consumer_secret     = CONSUMER_SECRET
      config.access_token        = ACCESS_TOKEN
      config.access_token_secret = ACCESS_SECRET
    end
  end
end

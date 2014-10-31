require 'twitter'

class Kc

  ACCOUNT_NAME = 'kc_advice'
  NUMBER_OF_TWEERS = 200

  def initialize
    @tweets = Twitter.user_timeline(ACCOUNT_NAME, NUMBER_OF_TWEETS)
  end

  def random_tweet
    tweets.sample['text']
  end

  private

    attr_accessor :tweets

end

require_relative '../lib/keystore'
require_relative '../lib/slack'
require_relative 'channel_observer'

class Scoreboard < ChannelObserver
  def call
    if match = incoming_message.text.match(/@(.*)(\+\+|\-\-)/)
      name, operation = match.captures
      total = adjust_score(name, operation)

      rank = self.class.rank(name)
      channel.post(OutgoingMessage.new({
        channel:  "##{incoming_message.channel_name}",
        username: 'scorecjh',
        icon_url: 'http://i.imgur.com/Tjk6mim.jpg',
        text: "@#{name}: #{ordinalize(rank)}"
      }))
    end
  end

  def self.rank(name)
    1 + (scores.index{|key, score| key == name } || scores.length)
  end

  def self.scores
    store = Keystore.new(:scoreboard)
    Slack::USERNAMES.reduce({}) do |memo, name|
      memo[name] = store.get(name) || 0
      memo
    end.sort{|(_,x),(_,y)| y.to_i <=> x.to_i }
  end

  private

  def adjust_score(name, operation)
    operation == '--' ? store.decrement(name) : store.increment(name)
  end

  def store
    @store ||= Keystore.new(:scoreboard)
  end

  def ordinalize(number)
    abs_number = number.to_i.abs

    ord = if (11..13).include?(abs_number % 100)
      "th"
    else
      case abs_number % 10
        when 1; "st"
        when 2; "nd"
        when 3; "rd"
        else    "th"
      end
    end

    "#{number}#{ord}"
  end
end

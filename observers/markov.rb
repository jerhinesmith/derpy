require_relative 'channel_observer'

class Markov < ChannelObserver
  TUPLE_LENGTH = 3

  def call
    input = incoming_message.text

    words = input.split(" ")

    return unless words.length > TUPLE_LENGTH

    words.unshift(*%w(__MARKOV_START_A__ __MARKOV_START_B__ __MARKOV_START_C__))
    words.push '__MARKOV_END__'

    (0...(words.length - TUPLE_LENGTH)).each do |i|
      Gram.add(*words[i..(i + TUPLE_LENGTH)])
    end
  end
end

require_relative 'channel_observer'

class Markov < ChannelObserver
  TUPLE_LENGTH = 3

  def call
    input = "#{incoming_message.text} __MARKOV_END__"

    words = input.split(" ")

    if words.length >= TUPLE_LENGTH
      (0...(words.length - TUPLE_LENGTH)).each do |i|
        Gram.add(*words[i..(i + TUPLE_LENGTH)])
      end
    end
  end
end

class PorkerCjh
  attr_reader :sword1, :sword2, :sword3

  def initialize
    @sword1, @sword2, @sword3 = "__MARKOV_START_A__", "__MARKOV_START_B__", "__MARKOV_START_C__"
  end

  def call
    new_phrase = []

    while true do
      gram = Gram.where(word1: @sword1, word2: @sword2, word3: @sword3).first
      next_word = gram.suffixes.sample

      break if next_word == "__MARKOV_END__"

      @sword1, @sword2, @sword3 = @sword2, @sword3, next_word

      new_phrase.append(next_word)
    end

    new_phrase.join(' ')
  end

  def self.call
    new().call
  end
end

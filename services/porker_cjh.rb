class PorkerCjh
  attr_reader :sword1, :sword2, :sword3

  def initialize
    @sword1, @sword2, @sword3 = "__MARKOV_START_A__", "__MARKOV_START_B__", "__MARKOV_START_C__"
  end

  def call
    new_phrase = []

    while true do
      next_word = Gram.random_suffix(@sword1, @sword2, @sword3)

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

class Gram < ActiveRecord::Base
  def self.add(word1, word2, word3, suffix)
    gram = self.where(word1: word1, word2: word2, word3: word3).first_or_initialize
    gram.suffixes << suffix
    gram.save
  end
end

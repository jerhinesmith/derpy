class Gram < ActiveRecord::Base
  def self.add(word1, word2, word3, suffix)
    if self.where(word1: word1, word2: word2, word3: word3).exists?
      Gram.connection.execute("UPDATE grams SET suffixes = array_append(suffixes, #{ActiveRecord::Base.connection.quote(suffix)}) WHERE word1 = #{ActiveRecord::Base.connection.quote(word1)} AND word2 = #{ActiveRecord::Base.connection.quote(word2)} AND word3 = #{ActiveRecord::Base.connection.quote(word3)};")
    else
      Gram.create(word1: word1, word2: word2, word3: word3, suffixes: [suffix])
    end
  end
end

require 'open-uri'

class GifCjh
  DICTIONARY_URI = 'http://txtpub.com/0x459rai8.txt'

  attr_accessor :tag

  def initialize(tag)
    @tag = tag.to_sym

    self
  end

  def self.call(tag)
    new(tag).call
  end

  def call
    dictionary[@tag].sample
  end

  private
  def dictionary
    return @dictionary if defined?(@dictionary)

    lines = open(DICTIONARY_URI).readlines.map(&:strip).delete_if{|l| l.empty?}

    @dictionary = Hash.new{|h, k| h[k] = []}

    lines.map{|l| l.split(':', 2)}.each do |k, v|
      @dictionary[k.downcase.to_sym] << v.strip
    end

    @dictionary
  end
end

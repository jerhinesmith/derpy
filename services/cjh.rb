require 'open-uri'
require 'nokogiri'
require 'cgi'

class Cjh
  attr_accessor :topic

  WEIGHTS = {
    pro:     0.1,
    haskell: 0.45,
    taylor:  0.05
  }

  def initialize(topic = nil)
    @topic = topic

    self
  end

  def self.call(topic)
    new(topic).call
  end

  def self.random_technology_topic
    url = "https://en.wikipedia.org/wiki/List_of_buzzwords"
    doc = Nokogiri::HTML(open(url))

    buzzwords = doc.at_css('#Science_and_technology').parent.next_sibling.next_sibling.css('li').collect{|n| n.content}

    # Remove citations
    buzzwords.map!{|b| b.gsub(/\[.+$/, '')}

    # Remove descriptors
    buzzwords.map!{|b| b.split(" - ")[0]}

    buzzwords.shuffle.first
  end

  def call
    if @topic.nil? || @topic.strip.length == 0
      @topic = self.class.random_technology_topic
    else
      @topic = topic.strip
    end

    form_opinion
  rescue
    "I hate everything."
  end

  def form_opinion
    srand()
    rand_value = rand()

    return ":heart: :taylor: :heart:" if rand_value < WEIGHTS[:taylor]
    return "Anyone who doesn't use #{@topic.downcase} is nubs." if rand_value < WEIGHTS[:pro]
    return "#{rand_value < WEIGHTS[:haskell] ? 'Learn :haskell:. ' : ''}#{@topic.capitalize} sucks. Never use #{@topic.downcase}."
  end
end
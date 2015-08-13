class ChannelObserver
  attr_reader :channel, :incoming_message

  def initialize(channel, incoming_message)
    @channel, @incoming_message = channel, incoming_message
  end

  def self.call(channel, incoming_message)
    new(channel, incoming_message).call
  end

  def call
    raise NotImplementedError, "#call must be implemented by subclasses"
  end
end

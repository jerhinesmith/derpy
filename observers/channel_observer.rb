class ChannelObserver
  attr_reader :channel, :incoming_message

  def initialize(channel, incoming_message)
    @channel, @incoming_message = channel, incoming_message
  end

  def self.call(channel, incoming_message)
    # Protect against responding to bots
    return true if (!respond_to_bots? && incoming_message.posted_by_bot?)

    new(channel, incoming_message).call
  end

  def call
    raise NotImplementedError, "#call must be implemented by subclasses"
  end

  def self.respond_to_bots?
    false
  end
end

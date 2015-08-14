class ChannelObserver
  attr_reader :channel, :incoming_message

  def initialize(channel, incoming_message)
    @channel, @incoming_message = channel, incoming_message
  end

  def self.call(channel, incoming_message)
    new(channel, incoming_message).call
  end

  def call
    # Protect against responding to bots
    return true if (!respond_to_bots? && incoming_message.posted_by_bot?)

    raise NotImplementedError, "#call must be implemented by subclasses"
  end

  def respond_to_bots?
    false
  end
end

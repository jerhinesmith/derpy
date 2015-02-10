class OutgoingMessage
  attr_accessor :channel, :username, :text, :icon_emoji, :icon_url, :attachments

  def initialize(attributes = {})
    self.attachments = []

    attributes.each do |k,v|
      send("#{k}=", v)
    end

    self
  end

  def to_json
    payload.to_json
  end

  private
  def payload
    @payload = { text: text }

    @payload.merge!(channel:    channel)    unless channel.nil?
    @payload.merge!(username:   username)   unless username.nil?
    @payload.merge!(icon_emoji: icon_emoji) unless icon_emoji.nil?
    @payload.merge!(icon_url:   icon_url)   unless icon_url.nil?

    @payload
  end
end

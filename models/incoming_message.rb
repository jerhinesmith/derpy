class IncomingMessage
  attr_accessor :token, :team_id, :team_domain, :service_id, :channel_id,
                :channel_name, :timestamp, :user_id, :user_name, :text,
                :bot_id, :bot_name, :trigger_word

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end

    self
  end

  def posted_by_bot?
    self.user_name == 'slackbot'
  end
end

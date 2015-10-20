class Presenter
  attr_accessor :channel, :response, :channel_name

  # The Presenter will send your content back to the slack channel.
  # Inherit from this class and set an attr_accessor for any data you'll
  # need in your response. Define a :foo_attachment and it will call that
  # attachment for each attribute that contains a value by that name.

  # Example: This will call EventPresenter's :message object, then attach
  # whatever is returned by `event_attachment`.
  #   presenter = EventPresenter.new(channel, params)
  #   presenter.event = Event.find(:halloween)
  #   presenter.present

  # If you just want to send a private response back to the caller, assign
  # your message to the :response attribute on the presenter and it's done.

  def initialize(channel, options = {})
    @channel = channel
    @channel_name = "##{options[:channel_name]}"
    @user_name = options[:user_name]
  end

  def present
    return response if response
    channel.post(content)
  end

  def message
    @message ||= OutgoingMessage.new({
      channel: channel_name,
      username: 'derp-bot',
      icon_url: 'http://i.imgur.com/w5yXDIe.jpg'
    })
  end

  def content
    # If there are values in any of these attributes, add their attachments
    %w(events result gif rsvp).each do |section|
      next unless respond_to?(section.to_sym)

      value = self.send(section.to_sym)
      if value
        puts "Adding #{section}: #{value}"
        message.attachments += [*send("#{section}_attachment".to_sym)]
      end
    end

    message
  end

  private

  def result_attachment
    MessageAttachment.new(text: result)
  end
end

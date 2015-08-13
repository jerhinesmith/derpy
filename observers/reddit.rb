class Reddit < ChannelObserver
  def call
    logginer.info incoming_message.inspect

    if incoming_message.text =~ /(\/r\/\w+)/i
      logginer.info $1

      message = OutgoingMessage.new(
        channel:  incoming_message.channel_name,
        username: 'redditcjh',
        icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
        text:     "<https://www.reddit.com#{$1}|#{$1}>"
      )

      channel.post(message)
    end
  end
end

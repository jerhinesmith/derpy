require_relative 'channel_observer'

class Reddit < ChannelObserver
  def call
    puts incoming_message.inspect

    if incoming_message.text =~ /(\/r\/\w+)/i
      puts $1

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

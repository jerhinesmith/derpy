require_relative 'channel_observer'

class Reddit < ChannelObserver
  def call
    if incoming_message.text =~ /(\/r\/\w+)/i
      message = OutgoingMessage.new(
        channel:  "##{incoming_message.channel_name}",
        username: 'redditcjh',
        icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
        text:     "<https://www.reddit.com#{$1}|#{$1}>"
      )

      begin
        puts message.to_json
      rescue
        puts "failed to put json"
      end

      channel.post(message)
    end
  end
end

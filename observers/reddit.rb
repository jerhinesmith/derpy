require_relative 'channel_observer'
require 'opengraph_parser'

class Reddit < ChannelObserver
  def call
    if incoming_message.text =~ /(^|\W)(\/r\/\w+)/i
      reddit_url = "https://www.reddit.com#{$2.strip}"
      open_graph = OpenGraph.new(reddit_url)

      message = OutgoingMessage.new(
        channel:  "##{incoming_message.channel_name}",
        username: 'reddit',
        icon_url: 'http://themodernape.com/wp-content/uploads/2014/09/20131209094736.png'
      )

      attachment = MessageAttachment.new(
        title:      open_graph.title,
        title_link: open_graph.url,
        text:       open_graph.description,
        thumb_url:  open_graph.images.first
      )

      message.attachments << attachment

      channel.post(message)
    end
  end
end

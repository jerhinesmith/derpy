require_relative 'channel_observer'

class Finance < ChannelObserver
  def call
    symbols = incoming_message.text.scan(/\$([A-Z]{1,4})/).flatten
    if symbols.any?
      symbol = symbols.shift
      message = OutgoingMessage.new(
        channel:  "##{incoming_message.channel_name}",
        username: 'greedcjh',
        icon_url: 'http://imgur.com/MeYf2Ee.jpg'
      )

      symbol_keys = symbols.map{|sym| "$#{sym}" }
      message.attachments << MessageAttachment.new(
        title:      "$#{symbol} vs #{symbol_keys.join(', ')}",
        title_link: "https://www.google.com/finance?q=#{symbol}",
        image_url:  "http://chart.finance.yahoo.com/z?s=#{symbol}&t=7d&q=l&l=on&z=s&p=m50,m200,v&c=#{symbols.join(',')}"
      )

      channel.post(message)
    end
  end
end

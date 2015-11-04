require_relative 'channel_observer'

class Finance < ChannelObserver
  def call
    match = incoming_message.match(/\$([A-Z]{1,4})/)
    if match
      symbol = match[1].to_s.upcase

      message = OutgoingMessage.new(
        channel:  "##{incoming_message.channel_name}",
        username: 'greedcjh',
        icon_url: 'http://imgur.com/MeYf2Ee.jpg'
      )

      message.attachments << MessageAttachment.new(
        title:      "$#{symbol}",
        title_link: "https://www.google.com/finance?q=#{symbol}",
        image_url:  "http://chart.finance.yahoo.com/z?s=#{symbol}&t=7d&q=l&l=on&z=s&p=m50,m200"
      )

      channel.post(message)
    end
  end
end

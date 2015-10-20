class GifPresenter < Presenter
  attr_accessor :gif

  def message
    @message ||= OutgoingMessage.new({
      channel: channel_name,
      username: 'gifcjh',
      icon_url: 'http://i.imgur.com/w5yXDIe.jpg'
    })
  end

  def gif_attachment
    MessageAttachment.new(
      fallback:  gif[:key],
      author_name: user_name,
      text: input,
      image_url: gif[:url]
    )
  end
end

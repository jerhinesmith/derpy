class MessageAttachment
  ATTRIBUTES = [
    :fallback, :color, :pretext, :author_name, :author_link, :author_icon,
    :title, :title_link, :text, :fields, :image_url, :thumb_url, :mrkdwn_in
  ]
  attr_accessor(*ATTRIBUTES)

  def initialize(attributes = {})
    self.fields = []

    attributes.each do |k,v|
      send("#{k}=", v)
    end

    self
  end

  def to_json(options = {})
    payload.to_json
  end

  private

  def payload
    @payload = { }

    ATTRIBUTES.each do |attribute|
      value = send(attribute.to_sym)
      @payload.merge!(attribute.to_sym => value) unless value.nil?
    end

    @payload
  end
end

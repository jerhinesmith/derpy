class MessageAttachment
  attr_accessor :fallback,
                :color,
                :pretext,
                :author_name,
                :author_link,
                :author_icon,
                :title,
                :title_link,
                :text,
                :fields,
                :image_url,
                :thumb_url

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

    @payload.merge!(fallback:     fallback)     unless fallback.nil?
    @payload.merge!(color:        color)        unless color.nil?
    @payload.merge!(pretext:      pretext)      unless pretext.nil?
    @payload.merge!(author_name:  author_name)  unless author_name.nil?
    @payload.merge!(author_link:  author_link)  unless author_link.nil?
    @payload.merge!(author_icon:  author_icon)  unless author_icon.nil?
    @payload.merge!(title:        title)        unless title.nil?
    @payload.merge!(title_link:   title_link)   unless title_link.nil?
    @payload.merge!(text:         text)         unless text.nil?
    @payload.merge!(fields:       fields)       unless fields.empty?
    @payload.merge!(image_url:    image_url)    unless image_url.nil?
    @payload.merge!(thumb_url:    thumb_url)    unless thumb_url.nil?

    @payload
  end
end

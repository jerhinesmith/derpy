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
end

class MessageAttachment
  attr_accessor :fallback, :pretext, :color, :fields

  def initialize(attributes = {})
    self.fields = []

    attributes.each do |k,v|
      send("#{k}=", v)
    end

    self
  end
end

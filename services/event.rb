require_relative '../lib/keystore'
require 'json'
require 'cgi'

class Event
  ATTRIBUTES = [:name, :tag, :body, :link, :location, :image_url, :date]

  attr_reader :id, :notes
  attr_accessor(*ATTRIBUTES)

  # Event.create('Chabot Camping 10/16')
  def initialize(options = {})
    @id = options['id']
    @notes = []

    ATTRIBUTES.each do |attribute|
      send "#{attribute}=", options.fetch(attribute.to_s, nil)
    end
  end

  def self.find(id_or_tag)
    find_by_tag(id_or_tag) || find_by_id(id_or_tag)
  end

  def self.find_by_id(id)
    data = store.get(id)
    return unless data
    json_to_event(data)
  end

  def self.find_by_tag(tag_name)
    id = store.get("tags/#{tag_name}")
    return unless id
    find_by_id(id)
  end

  def self.all
    events = []
    tags.each do |tag|
      events << find_by_tag(tag)
    end
    events
  end

  def self.tags
    store.keys('tags/*')
  end

  def self.tag(id, tag)
    event = find(id)
    return unless event
    event.tag = tag
    event.save

    tag!(tag, id)
    event
  end

  def rsvp!(name, response)
    rsvp.rsvp!(name, response)
  end

  def self.create(options = {})
    new(options).save
  end

  def update(attrs)
    attrs.select{|att| ATTRIBUTES.include?(att.to_sym) }.each_pair do |k, v|
      send("#{k}=", v)
    end
    save
  end

  def save
    if exists?
      puts "Update Event: #{id}:\n#{to_json}"
    else
      @id = Event.next_id
      self.class.tag!(tag, id) if tag

      puts "Create Event: #{id}:\n#{to_json}"
    end

    store.set(id, to_json)
    self
  end

  def self.parse(attrs)
    tag, name, date, body, location, image_url, link = attrs.split('|')
    create({
      'tag' => tag,
      'name' => name,
      'link' => link,
      'date' => date,
      'body' => body,
      'image_url' => image_url,
      'location' => location
    })
  end

  def attributes
    {
      id: id,
      name: name,
      tag: tag,
      body: body,
      location: location,
      image_url: image_url,
      date: date,
      notes: notes
    }
  end

  def to_json
    attributes.to_json
  end

  def exists?
    !store.get(id).nil?
  end

  def rsvp
    @rsvp ||= Rsvp.new(self)
  end

  private

  def self.json_to_event(data)
    Event.new(JSON.parse(data))
  rescue JSON::ParserError
    puts "Warning: Invalid event data"
  end

  def self.tag!(tag, id)
    key = "tags/#{ tag.downcase.strip.gsub(/[^\w]/, '-') }"
    store.set(key, id)
  end

  def self.next_id
    store.increment(:id)
  end

  def self.store
    @store ||= Keystore.new(:events)
  end

  def store
    self.class.store
  end
end

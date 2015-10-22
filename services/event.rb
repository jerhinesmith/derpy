require_relative '../lib/keystore'
require 'json'
require 'time'
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

    begin
      self.date = Time.parse(date) unless date.nil?
    rescue ArgumentError
      puts "Couldn't parse #{date} into a timestamp"
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
    id = store.get("tags/#{tag_name.to_s.gsub('#', '')}")
    return unless id
    find_by_id(id)
  end

  def self.all(options = {})
    events = []
    tags.each do |tag|
      event = find_by_tag(tag)

      if options[:upcoming]
        next if event.date.nil? || !event.date.is_a?(Time)
        next if event.date <= Time.now
      end

      if options[:completed]
        next if event.date.nil? || !event.date.is_a?(Time)
        next if event.date > Time.now
      end

      events << event
    end

    events.sort{|x,y| !x.date.is_a?(Time) || !y.date.is_a?(Time) ? 0 : x.date <=> y.date }
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

  def destroy
    store.del(id)
    store.del self.class.tag_redis_key(tag) if tag
    self
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

  def date_string(format = :human)
    case format
    when :human
      return '' if date.nil?
      !date.is_a?(Time) ? date : date.strftime("%A, %b %d at %I:%M%P")
    when :url
      return unless date.is_a?(Time)
      fmt = '%Y%m%dT%H%M%SZ'
      offset = 25200
      "#{(date + offset).strftime(fmt)}/#{(date + offset + 10800).strftime(fmt)}"
    end
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
    store.set(tag_redis_key(tag), id)
  end

  def self.tag_redis_key(tag)
    "tags/#{ tag.downcase.strip.gsub(/[^\w]/, '-') }"
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

require_relative '../lib/slack'

class Rsvp
  attr_reader :event_id

  def initialize(event)
    @event_id = event.id
  end

  def responses
    store.hash_get(key)
  end

  def responders
    responses.keys
  end

  def attending
    responses.select{|_, response| response == 'yes' }
  end

  def skipping
    responses.select{|_, response| response == 'no' }
  end

  def rsvp!(name, response)
    store.hash_set(key, name, parse_rsvp(response))
  end

  private

  def parse_rsvp(response)
    response = response.downcase
    return "yes" if %w(yes yeah yep).include?(response)
    return "no"  if %w(no nope).include?(response)

    "maybe"
  end

  def key
    "event_#{event_id}"
  end

  def store
    @store ||= Keystore.new(:rsvp)
  end
end

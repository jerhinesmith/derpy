require 'cgi'
require './derpy_controller'

class EventPresenter < Presenter
  attr_accessor :events, :rsvp

  def message
    @message ||= OutgoingMessage.new({
      channel: channel_name,
      username: 'eventcjh',
      icon_url: 'http://i.imgur.com/w5yXDIe.jpg'
    })
  end

  def event=(ev)
    self.events = (events || []) + [ev]
  end

  def events_attachment
    events.flatten.map{|e| event_to_attachment(e) }
  end

  def rsvp_attachment
    result = if rsvp[:response] == 'yes'
               ":white_check_mark: #{rsvp[:name]} is attending"
             elsif rsvp[:response] == 'no'
               ":x: #{rsvp[:name]} is not attending"
             else
               ":speech_balloon: #{rsvp[:name]} might go"
             end

    event = rsvp[:event]
    MessageAttachment.new({
      title:      "#{event.name} ##{event.tag}",
      text:       result,
      color:      '#7CD197',
      fallback:   "#{event.name} - #{result}"
    })
  end

  private

  def event_to_attachment(event)
    location_link = nil
    if event.location
      location_link = "<https://maps.google.com/maps?q=#{CGI.escape(event.location)}|#{event.location}>"
    end

    fields = [{
      title: 'Location',
      value: location_link,
      short: true
    },{
      title: 'Date',
      value: event.date,
      short: true
    }]

    attending = event.rsvp.attending
    fields.push({
      title: ':white_check_mark: Going',
      value: attending.keys.join(', ')
    }) if attending.any?

    skipping = event.rsvp.skipping
    fields.push({
      title: ":x: Can't Go",
      value: skipping.keys.join(', '),
      short: true
    }) if skipping.any?

    waiting = (Slack::USERNAMES - event.rsvp.responders)
    fields.push({
      title: ":speech_balloon: Haven't responded",
      value: waiting.join(', '),
      short: true
    }) if waiting.any?

    MessageAttachment.new({
      title:      "#{event.name} ##{event.tag}",
      title_link: event.link,
      text:       event.body,
      color:      '#7CD197',
      fallback:   "#{event.name} - ##{event.tag}",
      thumb_url:  event.image_url,
      mrkdwn_in:  ['fields'],
      fields:     fields
    })
  end
end

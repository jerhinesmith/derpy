require 'cgi'

class Presenter
  attr_accessor :text, :events, :result, :channel_name, :bot_name, :bot_icon, :rsvp

  def initialize(options = {})
    @channel_name = "##{options[:channel_name]}"
    @user_name = options[:user_name]

    bot_options = options[:bot] || {}
    @bot_name = bot_options[:name] || 'cjhbot'
    @bot_icon = bot_options[:icon_url] || 'http://i.imgur.com/w5yXDIe.jpg'
  end

  def content
    message = OutgoingMessage.new({
      text: text,
      channel: channel_name,
      username: bot_name,
      icon_url: bot_icon
    })

    # If there are values in any of these attributes, add their attachments
    %w(events result rsvp).each do |section|
      if value = self.send(section.to_sym)
        puts "Adding #{section}: #{value}"
        message.attachments += [*send("#{section}_attachment".to_sym)]
      end
    end

    message
  end

  # Convenience Methods
  def event=(ev)
    self.events = (events || []) + [ev]
  end

  def humanized_list(list)
    list.map!{|name| "@#{name}" }
    last = list.pop if list.length > 1

    result = list.join(', ')
    result += " and #{last}" if last
    result
  end

  private

  def events_attachment
    events.flatten.map{|e| event_to_attachment(e) }
  end

  def rsvp_attachment
    event = rsvp[:event]
    result = ""

    if rsvp[:response] == 'yes'
      result += ":white_check_mark: #{rsvp[:name]} is attending"
      people = event.rsvp.attending.keys.reject{|name| name == rsvp[:name] }
      if people.length > 0
        result += " along with #{humanized_list(people)}."
      else
        result += ". Alone."
      end
    elsif rsvp[:response] == 'no'
      result += ":x: #{rsvp[:name]} is pussing out"
      people = event.rsvp.skipping.keys.reject{|name| name == rsvp[:name] }
      if people.length > 0
        result += ", joining #{humanized_list(people)}."
      else
        result += ", because he's got so many better things to do."
      end
    else
      result += ":speech_balloon: #{rsvp[:name]} might go."
    end

    MessageAttachment.new({
      title:      "#{event.name} ##{event.tag}",
      text:       result,
      color:      '#7CD197',
      fallback:   "#{event.name} - #{result}"
    })
  end

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
      value: create_event_link(event),
      short: true
    }]

    attending = event.rsvp.attending
    fields.push({
      title: ':white_check_mark: Going',
      value: humanized_list(attending.keys)
    }) if attending.any?

    skipping = event.rsvp.skipping
    fields.push({
      title: ":x: Can't Go",
      value: humanized_list(skipping.keys),
      short: true
    }) if skipping.any?

    waiting = (Slack::USERNAMES - event.rsvp.responders)
    fields.push({
      title: ":speech_balloon: Haven't responded",
      value: humanized_list(waiting),
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

  def result_attachment
    MessageAttachment.new(text: result)
  end

  def create_event_link(event)
    params = {
      action: 'TEMPLATE',
      sf: true,
      output: 'xml',
      text: event.name || "New Event"
    }

    dates_param = event.date_string(:url)
    params.merge!(dates: dates_param) if dates_param
    params.merge!(details: event.body) if event.body
    params.merge!(location: event.location) if event.location

    param_string = params.map{|k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
    "<https://www.google.com/calendar/render?#{param_string}|#{event.date_string}>"
  end
end

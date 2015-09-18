require 'icalendar'
require 'open-uri'
require_relative "../models/outgoing_message"
require_relative "../models/message_attachment"
require_relative "raiders/game"

class Raiders
  SCHEDULE_URL = "http://www.raiders.com/cda-web/schedule-ics-module.ics?year=2015"
  LOGO_URL = "http://i.imgur.com/9UDbNnB.png"
  USERNAME = 'raidercjh'

  attr_reader :message

  def initialize(options={})
    @response = options[:args][:text]
    @channel_name = "##{options[:channel_name]}"
    @user_name = options[:user_name]
    @message = default_message
  end

  def summary
    @message.attachments << next_game_attachment
    @message.attachments << rsvp_list_attachment
  end

  def rsvp!
    next_game.rsvp!(@user_name, @response)
    @message.attachments << single_rsvp_attachment
  end

  private


  def default_message
    OutgoingMessage.new(
      channel: @channel_name,
      username: USERNAME,
      icon_url: LOGO_URL
    )
  end

  def single_rsvp_attachment
    MessageAttachment.new(text: "#{@user_name} rsvp'd #{@response}")
  end

  def next_game_attachment
    MessageAttachment.new(
      title:      "Next Game",
      text:       next_game.emoji_summary,
      fallback:   next_game.summary,
      fields:     [
        {
          title: 'Opponent',
          value: next_game.opponent
        },
        {
          title: 'Date',
          value: next_game.start_time,
          short: true
        },
        {
          title: 'Venue',
          value: next_game.location,
          short: true
        }
      ]
    )
  end

  def rsvp_list_attachment
    MessageAttachment.new(
      title: 'RSVPs',
      fields: next_game.rsvp_fields
    )
  end

  def next_game
    events.select{|e| e.dtstart >= DateTime.now}.first
  end

  def schedule
    @schedule ||= Icalendar.parse(open(SCHEDULE_URL).read).first
  end

  def events
    @events ||= schedule.events.sort_by{|e| e.dtstart}.collect do |e|
      Raiders::Game.new(e.dtstart, e.summary, e.location)
    end
  end
end

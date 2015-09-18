require 'icalendar'
require 'open-uri'
require 'redis'
require_relative 'lib/slack'

RaiderGame = Struct.new(:dtstart, :summary, :location_string) do
  def pst_start
    dtstart.new_offset('-0700')
  end

  def teams
    summary.split(' at ')
  end

  def home?
    teams.last == 'Oakland Raiders'
  end

  def opponent
    teams.delete_if{|t| t == 'Oakland Raiders'}.first
  end

  def location
    location_string.join(',')
  end

  def city
    location_string[1].strip
  end

  def venue
    location_string[0].strip
  end

  def state
    location_string[2].strip
  end

  def opponent_emoji
    ":#{opponent.split(/\W/).last.downcase}:"
  end

  def emoji_summary
    home? ? "#{opponent_emoji} @ :raiders:" : ":raiders: @ #{opponent_emoji}"
  end

  def rsvp(name, response)
    redis do |r|
      r.hset(redis_key, name, parse_rsvp(response))
    end
  end

  def rsvp_fields
    (format_rsvp_list + format_no_rsvp_list)
  end

  private

  def format_rsvp_list
    rsvp_list.map do |name, response|
      { value: "#{name}: #{response}" }
    end
  end

  def format_rsvp_no_list
    no_rsvp_list.map do |name|
      { value: "#{name}: please rsvp" }
    end
  end

  def no_rsvp_list
    Slack.usernames - rsvp_list.map(&:first)
  end

  def rsvp_list
    redis do |r|
      r.hgetall(redis_key)
    end
  end

  def parse_rsvp(response)
    response = response.downcase
    if positive_rsvp_responses.include?(response)
      "yes"
    elsif negative_rsvp_responses.include?(response)
      "no"
    else
      "maybe"
    end
  end

  def positive_rsvp_responses
    %w(yes yeah yep)
  end

  def negative_rsvp_responses
    %w(no nope)
  end

  def redis_key
    "raiders_rsvp_#{dtstart.to_date}"
  end

  def redis
    @redis = Redis.new(url: ENV['REDISCLOUD_URL'])
    result = yield @redis
    @redis.quit
    result
  end
end

class Raiders
  SCHEDULE_URL = "http://www.raiders.com/cda-web/schedule-ics-module.ics?year=2015"
  LOGO_URL = "http://i.imgur.com/9UDbNnB.png"

  def next_game
    events.select{|e| e.dtstart >= DateTime.now}.first
  end

  def schedule
    @schedule ||= Icalendar.parse(open(SCHEDULE_URL).read).first
  end

  def events
    @events ||= schedule.events.sort_by{|e| e.dtstart}.collect{|e| RaiderGame.new(e.dtstart, e.summary, e.location)}
  end
end

require 'icalendar'
require 'open-uri'

RaiderGame = Struct.new(:date, :summary, :location_string) do
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
end

class Raiders
  SCHEDULE_URL = "http://www.raiders.com/cda-web/schedule-ics-module.ics?year=2015"
  LOGO_URL = "https://upload.wikimedia.org/wikipedia/en/thumb/9/9d/Oakland_Raiders.svg/1024px-Oakland_Raiders.svg.png"

  def next
    events.select{|e| e.dtstart >= DateTime.now}.first
  end

  def schedule
    @schedule ||= Icalendar.parse(open(SCHEDULE_URL).read).first
  end

  def events
    @events ||= schedule.events.sort_by{|e| e.dtstart}.collect{|e| RaiderGame.new(e.dtstart.new_offset('-0700'), e.summary, e.location)}
  end
end

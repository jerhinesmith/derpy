require 'icalendar'
require 'open-uri'

class Raiders
  SCHEDULE_URL = "http://www.raiders.com/cda-web/schedule-ics-module.ics?year=2015"

  def next
    events.select{|e| e.dtstart >= DateTime.now}.first
  end

  def schedule
    @schedule ||= Icalendar.parse(open(SCHEDULE_URL).read).first
  end

  def events
    @events ||= @schedule.events.sort_by{|e| e.dtstart}
  end
end

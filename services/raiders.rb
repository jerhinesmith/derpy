require 'icalendar'
require 'open-uri'

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
    @events ||= schedule.events.sort_by{|e| e.dtstart}
  end
end

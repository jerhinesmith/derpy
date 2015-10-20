require_relative './derpy_controller'

class EventsController < DerpyController
  HELP = <<EOF
Event system, examples using #foo as the tag for our event.

/event foo                        Show all info about this event
/event rsvp foo yes|no|maybe      RSVP for this event
/event create bar                 Create an event with the "bar" tag
/event help                       Show this list
/event man                        Show extended help info for /event
===
## /event TAG
    Show all the info on an event

## /event rsvp TAG RESPONSE
    Mark your rsvp to this event (yes, no, maybe)

## /event list
    List all the tags for existing events

## /event create TAG [|NAME|DATE|BODY|LOCATION|IMAGE_URL|LINK]
    Create a new event delimited by the pipe "|". TAG is required
    ex: /event create foo|My Title
    ex: /event create umm|Weird Dungeon Sex Party|2015-11-13 23:00PST||Chez Vukicevich

## /event update TAG FIELD VALUE     Update a field for an event
    ex: /event update chabot name Chabot Glamping
    Fields:
      - name ( Chabot Camping )
      - date ( 2015-10-16 18:00PST )
      - body ( Let's camp like the Raiders win, barely and intermittently )
      - link ( http://www.ebparks.org/parks/anthony_chabot )
      - image_url ( http://i.imgur.com/AMmEwYN.jpg )
      - location ( Anthony Chabot Regional Park )

## /event man                       Returns this list
EOF

  def index
    event = Event.find(command)
    if event
      presenter.event = event
    else
      presenter.response = "No event found for: #{command}"
    end
  end

  def create
    if text == ""
      presenter.response = "You must provide a tag for your event."
      return
    end

    event = create_event!(text)
    if event.nil?
      presenter.response = "Tag is already taken:\n#{text}"
      return
    end

    presenter.event = event
  end

  def rsvp
    id, response = *text.split(' ')
    event = Event.find(id)
    if event.nil?
      presenter.response = "No event found for: #{id}"
      return
    end

    rsvp = event.rsvp!(params[:user_name], response)
    presenter.rsvp = rsvp.merge(event: event)
  end

  def tag
    Event.tag(*text.split(' '))
    presenter.response = "Tagged event"
  end

  def list
    events = Event.tags
    presenter.response = (events.empty? ? 'No Events to show' : events.join(", "))
  end

  def update
    _, id, attribute, value = *text.lstrip.match(/(\w*)\s(\w*)\s(.*)/)
    unless event = Event.find(id)
      presenter.response = "No event found for: #{id}"
      return
    end

    event.update(attribute => value)
    presenter.event = event
  end

  def help
    presenter.response = EventsController::HELP.split('===').first
  end

  def man
    presenter.response = EventsController::HELP.split('===').last
  end

  private

  def create_event!(text)
    id, _ = text.split('|')
    return if Event.find(id)

    Event.parse(text)
  end
end

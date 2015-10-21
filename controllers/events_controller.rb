class EventsController
  attr_reader :channel, :params, :command, :text, :username, :presenter

  ENDPOINTS = [:create, :tag, :list, :update, :rsvp, :help]

  HELP = <<EOF

/event TAG
  Show all the info on an event

/event create TAG [|NAME|DATE|BODY|LOCATION|IMAGE_URL|LINK]
  Create a new event delimited by the pipe "|". TAG is required
  ex: /event create foo|My Title
  ex: /event create umm|Weird Dungeon Sex Party|2015-11-13 23:00PST||Chez Vukicevich

/event list
  List all the tags for existing events

/event rsvp TAG RESPONSE
  - Mark your rsvp to this event (yes, no, maybe)

/event update TAG FIELD VALUE     Update a field for an event
  ex: /event update chabot name Chabot Glamping
  Fields:
    - name ( Chabot Camping )
    - date ( 2015-10-16 18:00PST )
    - body ( Let's camp like the Raiders win, barely and intermittently )
    - link ( http://www.ebparks.org/parks/anthony_chabot )
    - image_url ( http://i.imgur.com/AMmEwYN.jpg )
    - location ( Anthony Chabot Regional Park )

/event help                       Returns this list
EOF

  def initialize(channel, params)
    puts "  Params: #{params.inspect}"
    @channel = channel
    @params  = params
    @username = params[:user_name]
    args = params['text'].to_s.match(/([\w|-]*)(.*)/)
    @command = args[1].to_sym
    @text    = args[2].strip
    @presenter = Presenter.new(params.merge({
      bot: {
        name: 'eventcjh'
      }
    }))
  end

  def respond
    if ENDPOINTS.include?(command)
      send(command)
    else
      event = Event.find(command)
      if event
        presenter.event = event
      else
        raise StandardError, "No event found for: #{command}"
      end
    end

    channel.post(presenter.content)
  end

  def create
    if text == ""
      raise StandardError, "You must provide a tag for your event."
    end

    presenter.event = create_event!(text)
  end

  def rsvp
    id, response = *text.split(' ')
    event = Event.find(id)
    if event.nil?
      raise StandardError, "No event found for: #{id}"
    end

    rsvp = event.rsvp!(username, response)
    presenter.rsvp = rsvp.merge(event: event)
  end

  def tag
    Event.tag(*text.split(' '))
    raise StandardError, "Tagged event"
  end

  def list
    events = Event.tags
    raise StandardError, (events.empty? ? 'No Events to show' : events.join(", "))
  end

  def update
    _, id, attribute, value = *text.lstrip.match(/(\w*)\s(\w*)\s(.*)/)
    unless event = Event.find(id)
      raise StandardError, "No event found for: #{id}"
    end

    event.update(attribute => value)
    raise StandardError, "Updated event: #{attribute} to #{value}"
  end

  def help
    raise StandardError, EventsController::HELP
  end

  private

  def create_event!(text)
    id, _ = text.split('|')
    if Event.find(id)
      raise StandardError, "Tag is already taken:\n#{text}"
    else
      return Event.parse(text)
    end
  end
end

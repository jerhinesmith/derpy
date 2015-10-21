require 'sinatra'
require 'newrelic_rpm'
require 'faraday'
require 'json'

%w(controllers models services observers lib).each do |dir|
  Dir.glob(File.join(File.dirname(__FILE__), dir, '*.rb')).each do |file|
    require file
  end
end

slack_channel = ENV['SLACK_CHANNEL']
channel = Channel.new(slack_channel, ENV['SLACK_INCOMING_PATH'])

(ENV['OBSERVERS'] || "").split(',').each do |observer_klass|
  observer_klass.capitalize!

  channel.add_message_observer(Object.const_get(observer_klass)) if Object.const_defined?(observer_klass)
end

get '/status' do
  "ok"
end

# Register response handlers here
post '/message' do
  message = IncomingMessage.new(params)

  logger.info "Message! #{message.inspect}"

  channel.recieve(message)

  # return empty to make sinatra happy
  ""
end

get '/test' do
  logger.info "Alert! #{params[:message]}"

  message = OutgoingMessage.new(
    channel:    '#derpy-test',
    username:   'test',
    icon_emoji: ':light_rail:',
    text:       params[:message]
  )

  channel.post(message)
end

get '/cjh' do
  response = Cjh.call(params[:text])

  message = OutgoingMessage.new(
    channel: "##{params["channel_name"]}",
    username: 'trollcjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
    text:     response
  )

  channel.post(message)
end

get '/raiders' do
  args = ArgParser.new(params[:text]).to_hash
  presenter = Presenter.new(params.merge({
    bot: {
      name: Raiders::USERNAME,
      icon_url: Raiders::LOGO_URL
    }
  }))

  game = Raiders.new(params.merge(:args => args)).next_game
  event = Event.find(game.tag)
  if event.nil?
    event = Event.create({
      'tag' => game.tag,
      'name' => 'Next Raiders Game',
      'link' => game.link,
      'date' => game.start_time,
      'body' => game.emoji_summary,
      'image_url' => 'http://i.imgur.com/UCiZdsW.jpg',
      'location' => game.location
    })
  end

  presenter.event = event
  channel.post(presenter.content)
end

get '/gif' do
  command, key, url = params[:text].to_s.split(" ")
  gif_cjh = GifCjh.new(key || command, url)

  message = OutgoingMessage.new(
    channel: "##{params["channel_name"]}",
    username: 'gifcjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg'
  )

  case command.to_s.to_sym
  when :help
    return GifCjh::HELP
  when :add
    return gif_cjh.add    ? "Added #{key}: #{url}"   : "Unable to add key: url"
  when :remove
    return gif_cjh.remove ? "Removed #{key}: #{url}" : "Unable to remove key: url"
  when :"", :list
    return gif_cjh.keys.join(", ")
  when :show
    return gif_cjh.get || "Unable to get key: #{key}"
  else # got a key
    if image_url = gif_cjh.get
      message.attachments << MessageAttachment.new(
        fallback:  command,
        author_name: params[:user_name],
        text: command,
        image_url: image_url
      )

      channel.post(message)
    else
      return "No match for #{command}"
    end
  end

  return ''
end

get '/gifs' do
  @gifs = GifCjh.new.gifs
  erb :gifs
end

get '/event' do
  controller = EventsController.new(channel, params)

  begin
    controller.respond
  rescue StandardError => e
    return e.message
  end
end

get '/rsvp' do
  params['text'] = "rsvp #{params[:text]}"
  controller = EventsController.new(channel, params)

  begin
    controller.respond
  rescue StandardError => e
    return e.message
  end
end

get '/mitch' do
  message = OutgoingMessage.new(
    channel: "##{params["channel_name"]}",
    username: 'mitch',
    icon_url: 'http://i.imgur.com/bhDpHHS.jpg',
    text:      Mitch::ONE_LINERS.sample
  )

  channel.post(message)
end

get '/kc' do
  message = OutgoingMessage.new(
    channel: "##{params["channel_name"]}",
    username: 'kc',
    icon_url: 'https://pbs.twimg.com/profile_images/1783197378/five-dollars-wadded.png',
    text: Kc.speak
  )

  channel.post(message)
end

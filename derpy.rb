require 'sinatra'
require 'newrelic_rpm'
require 'faraday'
require 'json'

%w(controllers models presenters services observers lib).each do |dir|
  Dir.glob(File.join(File.dirname(__FILE__), dir, '*.rb')).each do |file|
    require file
  end
end

channel = Channel.new(ENV['SLACK_CHANNEL'], ENV['SLACK_INCOMING_PATH'])

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
  command = args[:command] ? args[:command].to_sym : :next
  raiders = Raiders.new(params.merge(:args => args))

  case command
  when :next
    raiders.summary
  when :rsvp
    raiders.rsvp!
  end

  channel.post(raiders.message)
end

get '/event' do
  presenter = EventPresenter.new(channel, params)
  EventsController.new(presenter, params).process
  presenter.present
end

get '/gif' do
  presenter = GifPresenter.new(channel, params)
  GifsController.new(presenter, params).process
  presenter.present
end

get '/gifs' do
  @gifs = GifCjh.new.gifs
  erb :gifs
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

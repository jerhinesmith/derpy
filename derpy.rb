require 'sinatra'
require 'newrelic_rpm'
require 'faraday'
require 'json'

Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')).each do |model|
  require model
end

Dir.glob(File.join(File.dirname(__FILE__), 'services', '*.rb')).each do |service|
  require service
end

Dir.glob(File.join(File.dirname(__FILE__), 'observers', '*.rb')).each do |observer|
  require observer
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
    channel: params["channel_name"],
    username: 'trollcjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
    text:     response
  )

  channel.post(message)
end

get '/raiders' do
  command = params[:text].to_s.strip
  command = :next if command.empty?

  raider_bot = Raiders.new
  message = OutgoingMessage.new(
    channel: params["channel_name"],
    username: 'raidercjh',
    icon_url: Raiders::LOGO_URL
  )

  case command.to_sym
  when :next
    next_game  = raider_bot.next
    start_time = next_game.pst_start

    attachment = MessageAttachment.new(
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
          value: start_time.strftime('%B %d, %Y @ %l:%M %P'),
          short: true
        },
        {
          title: 'Venue',
          value: next_game.location,
          short: true
        }
      ]
    )

    message.attachments << attachment
  end

  channel.post(message)
end

get '/gif' do
  result = nil
  gif_cjh = GifCjh.new
  input = params[:text]
  args = input.to_s.split(" ")
  command = args.shift.to_s.to_sym

  message = OutgoingMessage.new(
    channel: params["channel_name"],
    username: 'gifcjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg'
  )

  case command
    when :help
      result = GifCjh::HELP

    when :add
      key, url = args
      success = gif_cjh.add(key, url)
      result = success ? "Added #{key}: #{url}" : "Unable to add key: url"

    when :remove
      key, url = args
      success = gif_cjh.remove(key, url)
      result = success ? "Removed #{key}: #{url}" : "Unable to remove key: url"

    when :"", :list
      result = gif_cjh.list

    when :show
      key = args.first
      url = gif_cjh.get(key)
      result = url ? url : "Unable to get key: #{key}"

    else # got a key
      if image_url = gif_cjh.get(input)
        message.attachments << MessageAttachment.new(
          fallback:  input,
          author_name: params[:user_name],
          text: input,
          image_url: image_url
        )

        channel.post(message)
      else
        result = "No match for #{input}"
      end
  end

  return result
end

get '/gifs' do
  @gifs = GifCjh.new.gifs
  erb :gifs
end

get '/mitch' do
  message = OutgoingMessage.new(
    channel: params["channel_name"],
    username: 'mitch',
    icon_url: 'http://i.imgur.com/bhDpHHS.jpg',
    text:      Mitch::ONE_LINERS.sample
  )

  channel.post(message)
end

get '/kc' do
  message = OutgoingMessage.new(
    channel: params["channel_name"],
    username: 'kc',
    icon_url: 'https://pbs.twimg.com/profile_images/1783197378/five-dollars-wadded.png',
    text: Kc.speak
  )

  channel.post(message)
end

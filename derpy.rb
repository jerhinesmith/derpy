require 'sinatra'
require 'sinatra/activerecord'
require 'pg'
require 'faraday'
require 'json'
require 'newrelic_rpm'
require './config/environments'

%w(controllers models services observers lib).each do |dir|
  Dir.glob(File.join(File.dirname(__FILE__), dir, '*.rb')).each do |file|
    require file
  end
end

slack_channel = ENV['SLACK_CHANNEL']
channel = Channel.new(slack_channel, ENV['SLACK_INCOMING_PATH'])
gif_client = SlashGif.client

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
  controller = GifsController.new(channel, params)

  begin
    controller.respond
  rescue StandardError => e
    return e.message
  end
end

get '/gifs' do
  @gifs = GifCjh.new.gifs
  erb :gifs
end

get '/tags' do
  @tags = {}
  gifs = GifCjh.new.gifs
  gifs.select{|k,v| k.match(/tags\//)}.each_pair do |key, future|
    future.value.each do |url|
      @tags[url] = [*@tags[url], key].compact.uniq
    end
  end

  erb :tags
end

get '/scoreboard' do
  channel.post(OutgoingMessage.new({
    channel: "##{params["channel_name"]}",
    username: 'scorecjh',
    icon_url: 'http://i.imgur.com/Tjk6mim.jpg',
    text:     Scoreboard.scores.map{|k,v| "#{k}: #{v}" }.join("\n")
  }))
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

get '/porker' do
  message = OutgoingMessage.new(
    channel: "##{params["channel_name"]}",
    username: 'porkercjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
    text: PorkerCjh.call
  )

  channel.post(message)
end

get '/culture' do
  message = OutgoingMessage.new(
    channel: "##{params["channel_name"]}",
    username: 'culturecjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
    text: Culture.call
  )

  channel.post(message)
end

get '/frink' do
  image_url = Frink.call(params['text'])
  return "Could not find an image for #{params['text']}" unless image_url

  message = OutgoingMessage.new({
    channel: "##{params["channel_name"]}",
    username: 'frinkcjh',
    icon_url: 'http://i.imgur.com/EEmZJGi.png'
  })

  message.attachments << MessageAttachment.new({
    fallback:  params['text'],
    author_name: params['user_name'],
    image_url: image_url
  })

  channel.post(message)
end

get '/slash_gif' do
  content_type :json
  command, options = params['text'].to_s.split(/\s+/, 2)

  case command
  when nil
    # Show the tags
    tags = gif_client.tags(per: 500)

    OutgoingMessage.new(text: 'The following tags are available', attachments: [MessageAttachment.new(text: tags.collect{|t| t['name']}.join(', '))]).to_json
  when /add/i
    # Add a new url
    url, tags = options.split(/\s+/).partition{ |o| o =~ /^https?:\/\// }

    gif_client.create_gif(url.first, tag_list: tags.join(','))
  else
    # Random for tag
    puts "Get tag"
    gif = gif_client.random(tag: command)

    if url = gif.url
      OutgoingMessage.new(response_type: 'in_channel', attachments: [MessageAttachment.new(image_url: url)]).to_json
    else
      "No gifs found"
    end
  end
end

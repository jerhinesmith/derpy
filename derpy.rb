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

slack_channel = ENV['SLACK_CHANNEL']
channel = Channel.new(slack_channel, ENV['SLACK_INCOMING_PATH'])

get '/status' do
  "ok"
end

# Register response handlers here
post '/message' do
  message = IncomingMessage.new(params)

  logger.info "Message! #{message.inspect}"

  channel.recieve(message)
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

get '/r/:name' do
  url  = "https://www.reddit.com/r/#{params[:name]}"
  data = JSON.parse Faraday.get("#{url}/about/.json").body
  if data['error'].nil?
    message = OutgoingMessage.new(
      channel:  slack_channel,
      username: '/r/cjh',
      icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
      text: "#{data['display_name']}: #{url}"
    )

    channel.post(message)
  end
end

get '/cjh' do
  response = Cjh.call(params[:text])

  message = OutgoingMessage.new(
    channel:  slack_channel,
    username: 'trollcjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
    text:     response
  )

  channel.post(message)
end

get '/gif' do
  result = nil
  gif_cjh = GifCjh.new
  input = params[:text]
  args = input.to_s.split(" ")
  command = args.shift.to_s.to_sym

  message = OutgoingMessage.new(
    channel:  slack_channel,
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

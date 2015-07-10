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
      return GifCjh::HELP

    when :add
      key, url = args
      success = gif_cjh.add(key, url)
      return success ? "Added #{key}: #{url}" : "Unable to add key: url"

    when :remove
      key, url = args
      success = gif_cjh.remove(key, url)
      return success ? "Removed #{key}: #{url}" : "Unable to remove key: url"

    when :"", :list
      return gif_cjh.list

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
        return "No match for #{input}"
      end
  end
end

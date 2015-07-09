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

channel = Channel.new(ENV['SLACK_CHANNEL'], ENV['SLACK_INCOMING_PATH'])

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
    channel:  '#derp',
    username: 'trollcjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
    text:     response
  )

  channel.post(message)
end

get '/gif' do
  input = params[:text]

  message = OutgoingMessage.new(
    channel:  '#derpy-test',
    username: 'gifcjh',
    icon_url: 'http://i.imgur.com/w5yXDIe.jpg'
  )

  if image_url = GifCjh.call(input)
    message.attachments << MessageAttachment.new(image_url: image_url)
  else
    message.text = "No match for #{input}"
  end

  channel.post(message)

  channel.to_json
end

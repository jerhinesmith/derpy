require 'sinatra'
require 'newrelic_rpm'
require 'faraday'
require 'json'

Dir.glob(File.join(File.dirname(__FILE__), 'models', '*.rb')).each do |model|
  require model
end

channel = Channel.new(ENV['SLACK_CHANNEL'], ENV['SLACK_INCOMING_PATH'])

# config = {
#   'team'           => ENV['SLACK_TEAM'],
#   'channel'        => ENV['SLACK_CHANNEL'],
#   'name'           => ENV.fetch('SLACK_NAME', 'derpy'),
#   'incoming_token' => ENV['SLACK_TOKEN_INCOMING'],
#   'outgoing_token' => ENV['SLACK_TOKEN_OUTGOING'],
#   'incoming_path'  => ENV['SLACK_INCOMING_PATH']
# }

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

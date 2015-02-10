require 'sinatra'
require 'newrelic_rpm'
require 'faraday'
require 'json'

Dir.glob(File.join(File.dirname(__FILE__), 'services', '*.rb')).each do |service|
  require service
end

slack_connection = Faraday.new(url: 'https://hooks.slack.com') do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end

config = {
  'team'           => ENV['SLACK_TEAM'],
  'channel'        => ENV['SLACK_CHANNEL'],
  'name'           => ENV.fetch('SLACK_NAME', 'derpy'),
  'incoming_token' => ENV['SLACK_TOKEN_INCOMING'],
  'outgoing_token' => ENV['SLACK_TOKEN_OUTGOING'],
  'incoming_path'  => ENV['SLACK_INCOMING_PATH']
}

get '/status' do
  "ok"
end

# Register response handlers here
post '/message' do
  logger.info "Message Received"
  params.each do |k, v|
    logger.info "#{k}: #{v}"
  end
  logger.info "End Message"
end

get '/test' do
  message = params[:message]
  logger.info "Alert! #{params[:message]}"

  payload = {
    channel:    '#derpy-test',
    username:   'test',
    text:       message,
    icon_emoji: ':light_rail:'
  }

  slack_connection.post do |req|
    req.url config['incoming_path']
    req.headers['Content-Type'] = 'application/json'
    req.body = payload.to_json
  end
end

require 'slackbotsy'
require 'active_support'
require 'active_support/hash_with_indifferent_access'
require 'sinatra'
require 'newrelic_rpm'
require 'json'

Dir.glob(File.join(File.dirname(__FILE__), 'services', '*.rb')).each do |service|
  require service
end

config = {
  'team'           => ENV['SLACK_TEAM'],
  'channel'        => ENV['SLACK_CHANNEL'],
  'name'           => ENV.fetch('SLACK_NAME') { 'derpy' },
  'incoming_token' => ENV['SLACK_TOKEN_INCOMING'],
  'outgoing_token' => ENV['SLACK_TOKEN_OUTGOING']
}

bot = Slackbotsy::Bot.new(config) do

  hear /echo\s+(.+)/ do |mdata|
    "I heard #{user_name} say '#{mdata[1]}' in #{channel_name}"
  end

  hear /flip out/i do
    open('http://tableflipper.com/gif') do |f|
      "<#{f.read}>"
    end
  end

end

post '/' do
  bot.handle_item(ActiveSupport::HashWithIndifferentAccess.new(params.stringify_keys))
end

post '/cjh' do
  bot.say Cjh.call(params['text'])

  ""
end

get '/status' do
  "ok"
end

get '/config' do
  config.to_json
end

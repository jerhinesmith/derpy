require 'slackbotsy'
require 'sinatra'
require 'newrelic_rpm'
require 'json'

config = {
  'team'           => ENV['SLACK_TEAM'],
  'channel'        => ENV['SLACK_CHANNEL'],
  'name'           => ENV.fetch('SLACK_NAME') { 'derpy' },
  'incoming_token' => ENV['SLACK_TOKEN_INCOMING'],
  'outgoing_token' => ENV['SLACK_TOKEN_OUTGOING']
}

bot = Slackbotsy::Bot.new(config) do

  hear /echo\s+(.+)/ do |data, mdata|
    "I heard #{data['user_name']} say '#{mdata[1]}' in #{data['channel_name']}"
  end

  hear /flip out/i do
    open('http://tableflipper.com/gif') do |f|
      "<#{f.read}>"
    end
  end

end

post '/' do
  bot.handle_item(params)
end

get '/status' do
  "ok"
end

get '/config' do
  config.to_json
end

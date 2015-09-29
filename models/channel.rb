require 'faraday'
require 'json'

class Channel
  attr_accessor :name
  attr_reader   :message_observers, :incoming_path

  def initialize(name, path)
    self.name = name

    @incoming_path = path
    @message_observers = []
  end

  def add_message_observer(*observers)
    observers.each { |observer| @message_observers << observer }
  end

  def recieve(incoming_message)
    notify_message_observers(incoming_message)
  end

  def post(outgoing_message)
    connection.post do |req|
      req.url incoming_path
      req.headers['Content-Type'] = 'application/json'
      req.body = outgoing_message.to_json
    end
  end

  private
  def notify_message_observers(incoming_message)
    message_observers.each { |observer| observer.call(self, incoming_message) }
  end

  def connection
    @connection = Faraday.new(url: 'https://hooks.slack.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end
end

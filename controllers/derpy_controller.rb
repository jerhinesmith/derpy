class DerpyController
  attr_accessor :params, :command, :text, :presenter

  # Parent controller for nicethread
  # Inherit from this and the first space delimited word (@command)
  # will be the method that is run on your child controller.

  # If there is no matching method for @command, the :index method will be run

  # Available Attributes:
  #   - @params: The params sinatra received on the request
  #   - @command: The first space delimited word in the message
  #   - @text: The rest of the message after @command

  # Send data to slack by using the presenter.
  # Assign an attribute with the value you want to be used in the presenter. That
  # corresponding presenter will use that value when building the response.

  # If you want to send a private response back to the caller,
  # assign your message to :response

  def initialize(presenter, params)
    puts "  Params: #{params.inspect}"
    args = params['text'].to_s.match(/([\w|-]*)(.*)/)
    @presenter = presenter
    @params  = params
    @command = args[1].to_sym
    @text    = args[2].strip
  end

  def process
    endpoints.include?(command) ? send(command) : index
  end

  protected

  def endpoints
    self.methods - Object.instance_methods
  end
end

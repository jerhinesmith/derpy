require 'faraday'
require File.expand_path('../version', __FILE__)

module SlashGif
  # Defines constants and methods related to configuration
  module Configuration
    # An array of valid keys in the options hash when configuring a {Instagram::API}
    VALID_OPTIONS_KEYS = [
      :adapter,
      :connection_options,
      :endpoint,
      :format,
      :user_agent,
      :no_response_wrapper
    ].freeze

    # The adapter that will be used to connect if none is set
    #
    # @note The default faraday adapter is Net::HTTP.
    DEFAULT_ADAPTER = Faraday.default_adapter

    # By default, don't set any connection options
    DEFAULT_CONNECTION_OPTIONS = {}

    # The endpoint that will be used to connect if none is set
    #
    # @note There is no reason to use any other endpoint at this time
    DEFAULT_ENDPOINT = 'https://slash-gif.mjw.io/api/'.freeze

    # The response format appended to the path and sent in the 'Accept' header if none is set
    #
    # @note JSON is the only available format at this time
    DEFAULT_FORMAT = :json

    # By default, don't wrap responses with meta data (i.e. pagination)
    DEFAULT_NO_RESPONSE_WRAPPER = false

    # The user agent that will be sent to the API endpoint if none is set
    DEFAULT_USER_AGENT = "slash_gif/#{SlashGif::VERSION}" \
      " (#{RUBY_ENGINE}/#{RUBY_PLATFORM}" \
      " #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL})".freeze

    # An array of valid request/response formats
    #
    # @note Not all methods support the XML format.
    VALID_FORMATS = [
      :json].freeze

    # @private
    attr_accessor *VALID_OPTIONS_KEYS

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Create a hash of options and their values
    def options
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    # Reset all configuration options to defaults
    def reset
      self.adapter            = DEFAULT_ADAPTER
      self.connection_options = DEFAULT_CONNECTION_OPTIONS
      self.endpoint           = DEFAULT_ENDPOINT
      self.format             = DEFAULT_FORMAT
      self.user_agent         = DEFAULT_USER_AGENT
      self.no_response_wrapper= DEFAULT_NO_RESPONSE_WRAPPER
    end
  end
end
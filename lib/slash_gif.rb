require File.expand_path('../slash_gif/error', __FILE__)
require File.expand_path('../slash_gif/configuration', __FILE__)
require File.expand_path('../slash_gif/api', __FILE__)
require File.expand_path('../slash_gif/client', __FILE__)
require File.expand_path('../slash_gif/response', __FILE__)

module SlashGif
  extend Configuration

  # Alias for SlashGif::Client.new
  #
  # @return [SlashGif::Client]
  def self.client(options={})
    SlashGif::Client.new(options)
  end

  # Delegate to SlashGif::Client
  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)
    client.send(method, *args, &block)
  end

  # Delegate to SlashGif::Client
  def self.respond_to?(method, include_all=false)
    return client.respond_to?(method, include_all) || super
  end
end

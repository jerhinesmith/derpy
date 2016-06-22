require 'faraday_middleware'

module SlashGif
  # @private
  module Connection
    private

    def connection(raw=false)
      options = {
        headers: {'Accept' => "application/#{format}; charset=utf-8", 'User-Agent' => user_agent},
        url: endpoint,
      }.merge(connection_options)

      Faraday::Connection.new(options) do |connection|
        unless raw
          case format.to_s.downcase
          when 'json' then connection.use Faraday::Response::ParseJson
          end
        end
        connection.adapter(adapter)
      end
    end
  end
end

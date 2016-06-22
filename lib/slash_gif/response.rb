require 'hashie'

module SlashGif
  module Response
    def self.create(response_hash, response_headers = {})
      data = response_hash.data.dup rescue response_hash
      data.extend( self )
      data.instance_exec do
        %w{page total per-page total-pages}.each do |k|
          response_headers.public_send('[]', "x-#{k}").tap do |v|
            instance_variable_set("@#{k}".gsub('-', '_'), v) if v
          end
        end
        @headers = ::Hashie::Mash.new(response_headers)
      end
      data.is_a?(Hash) ? ::Hashie::Mash.new(data) : data
    end

    attr_reader :page
    attr_reader :total
    attr_reader :per_page
    attr_reader :total_pages
    attr_reader :headers
  end
end

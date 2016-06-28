module SlashGif
  class Client
    # Defines methods related to tags
    module Gifs
      # Returns extended information of a given SlashGif gif
      #
      # @overload gif(id)
      #   @param id [String] A SlashGif gif id
      #   @return [Hashie::Mash] The requested gif.
      #   @example Return extended information for the gif 'cafebabe'
      #     SlashGif.gif('cafebabe')
      # @format :json
      def gif(id)
        response = get("gifs/#{id}")
        response
      end

      # Returns extended information of a random SlashGif gif
      #
      # @overload random(options)
      #   @param tag [String] A SlashGif tag
      #   @return [Hashie::Mash] A random gif.
      #   @example Return a random gif with the tag 'there-it-is'
      #     SlashGif.random(tag: 'there-it-is')
      # @format :json
      def random(options = {})
        response = get("gifs/random", options)
        response
      end

      def create_gif(url, options = {})
        params    = Hash[options.merge(url: url).map{|k, v| ["gif[#{k}]", v]}]
        response  = post("gifs", params)
        response
      end
    end
  end
end

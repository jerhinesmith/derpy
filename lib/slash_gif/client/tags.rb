module SlashGif
  class Client
    # Defines methods related to tags
    module Tags
      # Returns extended information of a given SlashGif tag
      #
      # @overload tag(tag)
      #   @param tag [String] An SlashGif tag name
      #   @return [Hashie::Mash] The requested tag.
      #   @example Return extended information for the tag "cat"
      #     SlashGif.tag('cat')
      # @format :json
      def tag(tag, *args)
        response = get("tags/#{tag}")
        response
      end

      # Returns a list of tags
      #
      # @overload tags
      #   @return [Hashie::Mash]
      #   @example Return a list of tags
      #     SlashGif.tags
      # @format :json
      def tags(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        response = get("tags", options)
        response
      end
    end
  end
end

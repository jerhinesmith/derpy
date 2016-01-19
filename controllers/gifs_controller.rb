class GifsController
  attr_reader :channel, :params, :command, :text, :username, :presenter

  ENDPOINTS = [:add, :remove, :tag, :list, :show, :help]

  VIEW = 'https://nicethread.herokuapp.com/gifs'
  HELP = <<EOF

/gif                         returns a list of possible keys
/gif KEY                     returns a gif if one is found
/gif show KEY                show the url for the given key
/gif add KEY URL             adds a new url for the given key
/gif tag KEY URL             add a tag to a url
/gif remove KEY URL          removes the url for the given key
/gif help                    returns this list
EOF

  def initialize(channel, params)
    @channel = channel
    @params  = params
    @username = params[:user_name]

    args = params['text'].to_s.match(/([\w|-]*)(.*)/)
    @command = args[1].to_sym
    @text    = args[2].strip
    @presenter = Presenter.new(params.merge({
      bot: { name: 'gifcjh' }
    }))
    puts "GifsController##{command} Params: #{params.inspect}"
  end

  def respond
    if ENDPOINTS.include?(command)
      send(command)
    elsif command == :""
      raise StandardError, gif_tags_message
    else
      # Look up the gif
      tags = [command, *text.split(' ')].map(&:to_s)
      puts "Finding gif for: #{tags.inspect}"
      gif = GifCjh.find(*tags)

      GifCjh.track(username, *tags)

      if gif
        presenter.gif = gif
      else
        raise StandardError, "No match for #{tags.join(', ')}"
      end
    end

    channel.post(presenter.content)
  end

  def add
    key, url = text.split(' ')
    client = GifCjh.new(key, url)

    if client.add
      raise StandardError, "Added #{key}: #{url}"
    else
      raise StandardError, "Unable to add #{key}: #{url}"
    end
  end

  def remove
    key, url = text.split(' ')
    client = GifCjh.new(key, url)

    unless client.has_key?
      raise StandardError, "You have to specify the key and url"
    end

    unless client.has_url?
      if client.list.length == 1
        # If there's only one url, use it
        client.url = client.list.first
      else
        gifs = client.list.join("\n  ")
        raise StandardError, "You have to specify which #{key} url:\n#{gifs}"
      end
    end

    if client.remove
      raise StandardError, "Removed #{key}: #{client.url}"
    else
      raise StandardError, "Unable to remove #{key}: #{url}"
    end
  end

  def tag
    key, url = text.split(' ')
    tags = GifCjh.tag(key, url)
    raise StandardError, "Tagged #{url} with:\n  #{tags.join(', ')}"
  end

  def show
    key, url = text.split(' ')
    urls = GifCjh.new(key, url).list
    if urls.any?
      raise StandardError, "#{key}:\n#{urls.join("\n  ")}"
    else
      raise StandardError, "Unable to get key: #{key}"
    end
  end

  def list
    raise StandardError, gif_tags_message
  end

  def help
    raise StandardError, GifsController::HELP
  end

  private

  def gif_tags_message
    [GifCjh.new.keys.join(", "), VIEW].join("\n\n")
  end
end

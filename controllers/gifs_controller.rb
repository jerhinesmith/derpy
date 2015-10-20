require './derpy_controller'

class GifsController < DerpyController
  attr_reader :key, :url

  HELP = <<EOF

/gif                         returns a list of possible keys
/gif KEY                     returns a gif if one is found
/gif show KEY                show the url for the given key
/gif add KEY URL             adds a new url for the given key
/gif remove KEY URL          adds a new url for the given key
/gif help                    returns this list
EOF

  def initialize
    super
    @key, @url = *text.split(' ')
  end

  def index
    if image_url = gif_cjh.get(command)
      presenter.gif = { key: command, url: image_url }
    else
      presenter.response = "No match for #{command}"
    end
  end

  def add
    result = gif_cjh.add(key, url)
    presenter.response = (result ? "Added #{key}: #{url}" : "Unable to add key: url")
  end

  def remove
    result = gif_cjh.remove(key, url)
    presenter.response = (result ? "Removed #{key}: #{url}" : "Unable to remove key: url")
  end

  def show
    presenter.response = gif_cjh.get(key) || "Unable to get key: #{key}"
  end

  def help
    presenter.response = GifsController::HELP
  end

  private

  def gif_cjh
    @gif_cjh ||= GifCjh.new
  end
end

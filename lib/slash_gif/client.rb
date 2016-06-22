module SlashGif
  class Client < API
    Dir[File.expand_path('../client/*.rb', __FILE__)].each{|f| require f}

    include SlashGif::Client::Gifs
    include SlashGif::Client::Tags
  end
end

require_relative 'channel_observer'
require 'open-uri'
require 'json'

class Mitch < ChannelObserver
  ONE_LINERS      = JSON.parse(open("https://gist.githubusercontent.com/mkoga/7803bdf178a398884ba3/raw/04f2161a2365e5c330281783dd42b071a699bbf2/mitch.json").read)
  STOP_WORDS      = "a,able,about,across,after,all,almost,also,am,among,an,and,any,are,as,at,be,because,been,but,by,can,cannot,could,dear,did,do,does,either,else,ever,every,for,from,get,got,had,has,have,he,her,hers,him,his,how,however,i,if,in,into,is,it,its,just,least,let,like,likely,may,me,might,most,must,my,neither,no,nor,not,of,off,often,on,only,or,other,our,own,rather,said,say,says,she,should,since,so,some,than,that,the,their,them,then,there,these,they,this,tis,to,too,twas,us,wants,was,we,were,what,when,where,which,while,who,whom,why,will,with,would,yet,you,your".split(',')
  CHANCE_OF_MITCH = 0.25

  def call
    your_words = incoming_message.text.gsub(/[^\w\s]/, '').split(' ').delete_if{|w| STOP_WORDS.include?(w)}.sort.uniq

    ONE_LINERS.shuffle.each do |one_liner|
      mitch_words  = one_liner.gsub(/[^\w\s]/, '').split(' ').delete_if{|w| STOP_WORDS.include?(w)}.sort.uniq
      shared_words = (your_words & mitch_words)

      if shared_words.length >= 3
        say_something = (rand <= CHANCE_OF_MITCH)

        if say_something
          message = OutgoingMessage.new(
            channel:  "##{incoming_message.channel_name}",
            username: 'mitchcjh',
            icon_url: 'http://i.imgur.com/w5yXDIe.jpg',
            text:     one_liner
          )

          channel.post(message)
        end

        break
      end
    end
  end
end

require_relative '../../lib/slack'
require_relative '../../lib/redis_wrapper'

class Raiders
  class Game
    include RedisWrapper

    attr_reader :dtstart, :summary, :location_string

    def initialize(dtstart, summary, location_string)
      @dtstart = dtstart
      @summary = summary
      @location_string = location_string
    end

    def start_time
      pst_start.strftime('%B %d, %Y @ %l:%M %P')
    end

    def pst_start
      dtstart.new_offset('-0700')
    end

    def teams
      summary.split(' at ')
    end

    def home?
      teams.last == 'Oakland Raiders'
    end

    def opponent
      teams.delete_if{|t| t == 'Oakland Raiders'}.first
    end

    def location
      location_string.join(',')
    end

    def city
      location_string[1].strip
    end

    def venue
      location_string[0].strip
    end

    def state
      location_string[2].strip
    end

    def link
      'http://espn.go.com/nfl/team/schedule/_/name/oak'
    end

    def opponent_emoji
      ":#{opponent.split(/\W/).last.downcase}:"
    end

    def emoji_summary
      playing = ["#{opponent} #{opponent_emoji}", 'Oakland Raiders :raiders:']
      (home? ? playing : playing.reverse).join(' @ ')
    end

    def tag
      "raiders_#{dtstart.to_date}"
    end

    def rsvp!(name, response)
      redis do |r|
        r.hset(redis_key, name, parse_rsvp(response))
      end
    end

    def rsvp_fields
      (format_rsvp_list + format_no_rsvp_list)
    end

    private

    def format_rsvp_list
      rsvp_list.map do |name, response|
        { value: "#{name}: #{response}" }
      end
    end

    def format_no_rsvp_list
      no_rsvp_list.map do |name|
        { value: "#{name}: please rsvp" }
      end
    end

    def no_rsvp_list
      names = rsvp_list.map(&:first)
      Slack.mention_all_except(names)
    end

    def rsvp_list
      redis do |r|
        r.hgetall(redis_key)
      end
    end

    def parse_rsvp(response)
      response = response.downcase
      if positive_rsvp_responses.include?(response)
        "yes"
      elsif negative_rsvp_responses.include?(response)
        "no"
      else
        "maybe"
      end
    end

    def positive_rsvp_responses
      %w(yes yeah yep)
    end

    def negative_rsvp_responses
      %w(no nope)
    end

    def redis_key
      "raiders_rsvp_#{dtstart.to_date}"
    end
  end
end

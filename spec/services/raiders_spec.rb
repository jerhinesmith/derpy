require "rspec"
require "pry"
require_relative "../../services/raiders"

describe Raiders do

  context "#summary" do
    it "returns an OutgoingMessage with attachments" do
      params = {
        channel_name: "derpy",
        args: {},
      }
      raiders = Raiders.new(params)
      raiders.summary
      message = raiders.message

      expect(message.channel).to eq "#derpy"
      expect(message.username).to eq "raidercjh"
      expect(message.icon_url).to eq "http://i.imgur.com/9UDbNnB.png"

      attachments = message.attachments

      expect(attachments.length).to eq(2)

    end
  end

  context "#rsvp!" do
    let(:redis) { Redis.new }
    before(:each) { redis.flushdb }
    after(:each) { redis.flushdb }

    it "returns an OutgoingMessage with attachments" do
      params = {
        channel_name: "derpy",
        args: {
          text: "yes"
        },
      }
      raiders = Raiders.new(params)
      raiders.rsvp!
      message = raiders.message

      expect(message.channel).to eq "#derpy"
      expect(message.username).to eq "raidercjh"
      expect(message.icon_url).to eq "http://i.imgur.com/9UDbNnB.png"

      attachments = message.attachments
      expect(attachments.length).to eq(1)
    end

    it "stores the user's rsvp in redis" do
      params = {
        channel_name: "derpy",
        args: {
          text: "yes",
        },
        user_name: "john"
      }
      raiders = Raiders.new(params)
      next_game = raiders.send(:next_game)
      redis_key = next_game.send(:redis_key)

      expect { raiders.rsvp! }.to change {
        next_game.send(:rsvp_list).length
      }.from(0).to(1)

      expect(redis.hget(redis_key, "john")).to eq("yes")
    end
  end
end

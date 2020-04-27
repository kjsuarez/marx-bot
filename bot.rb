require 'discordrb'
require 'dotenv/load'

bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']

ADJECTIVE_PATH = File.join(File.dirname(__FILE__), "lib/adjective.json")
ADJECTIVE_DICT = JSON.parse(File.read(ADJECTIVE_PATH))

NOUN_PATH = File.join(File.dirname(__FILE__), "lib/noun.json")
NOUN_DICT = JSON.parse(File.read(NOUN_PATH))

SLOGAN_PATH = File.join(File.dirname(__FILE__), "lib/slogans.json")
SLOGAN_DICT = JSON.parse(File.read(SLOGAN_PATH))

bot.message(containing: '!kneel') do |event|
  has_specific = event.message.to_s.include?(">>")
  specific = event.message.to_s.split(">>").last
  puts "event: #{event.user.id.class}"

  event.server.members.each{ |member|
    begin
      current = member.nick
      if has_specific && event.user.id.to_s == ENV['KEVIN_ID']
        new_name = specific
      else
        new_name = "#{get_adjective} #{get_noun}"
      end

      member.set_nickname(new_name)
      if member.online?
        member.pm(
          "Know your place! You have been assigned #{new_name}. _All Glory to CHAOS_\n
          \"#{get_slogan}\""
        )
      end
    rescue Exception => e
      puts "big OOPS #{e}"
    end
  }
   event.respond("\"#{get_slogan}\"")
end

bot.message(containing: '!silence') do |event|
  if event.user.id.to_s == ENV['KEVIN_ID']
    event.server.members.each{ |member|
      begin
        if member.voice_channel
          puts "name: #{member.display_name}"
          member.server_mute
          if member.online?
            member.pm(
              "Silence.\n
              \"#{get_slogan}\""
            )
          end
        end
      rescue Exception => e
        puts "big OOPS #{e}"
      end
    }
    event.respond("\"#{get_slogan}\"")
  end
end

bot.message(containing: '!speak') do |event|
  if event.user.id.to_s == ENV['KEVIN_ID']
    event.server.members.each{ |member|
      begin
        if member.voice_channel
          puts "name: #{member.display_name}"
          member.server_unmute
          if member.online?
            member.pm(
              "You speak because I let you speak.\n
              \"#{get_slogan}\""
            )
          end
        end
      rescue Exception => e
        puts "big OOPS #{e}"
      end
    }
    event.respond("\"#{get_slogan}\"")
  end
end

def get_slogan()
  all_slogans = SLOGAN_DICT["slogans"]
  slogan_number = Random.new.rand(all_slogans.length)
  return all_slogans[slogan_number]
end

def get_adjective()
  adjectives = ADJECTIVE_DICT["adjs"]
  adj_choice = Random.new.rand(adjectives.length)
  return adjectives[adj_choice]
end

def get_noun()
  nouns = NOUN_DICT["nouns"]
  noun_choice = Random.new.rand(nouns.length)
  return nouns[noun_choice]
end

bot.run
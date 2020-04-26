require 'discordrb'
require 'dotenv/load'

bot = Discordrb::Bot.new token: ENV['BOT_TOKEN']

adjective_path = File.join(File.dirname(__FILE__), "lib/adjective.json")
adjective_dict = JSON.parse(File.read(adjective_path))

noun_path = File.join(File.dirname(__FILE__), "lib/noun.json")
noun_dict = JSON.parse(File.read(noun_path))

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
        nouns =  noun_dict["nouns"]
        adjectives = adjective_dict["adjs"]
        adj_choice = Random.new.rand(adjectives.length)
        noun_choice = Random.new.rand(nouns.length)

        new_name = "#{adjectives[adj_choice]} #{nouns[noun_choice]}"
      end

      member.set_nickname(new_name)
      if member.online?
        # member.pm("Know your place! You have been assigned #{new_name} as your new nickname! _All Glory to CHAOS_")
      end
    rescue Exception => e
      puts "big OOPS #{e}"
    end
  }
   event.respond("It is done.")
end

bot.message(containing: '!silence') do |event|
  if event.user.id.to_s == ENV['KEVIN_ID']
    event.server.members.each{ |member|
      begin
        if member.voice_channel
          puts "name: #{member.display_name}"
          member.server_mute
          if member.online?
            member.pm("Silence.")
          end
        end
      rescue Exception => e
        puts "big OOPS #{e}"
      end
    }
    event.respond("It is done.")
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
            member.pm("My power is beyond words.")
          end
        end  
      rescue Exception => e
        puts "big OOPS #{e}"
      end
    }
    event.respond("It is done.")
  end
end

bot.run
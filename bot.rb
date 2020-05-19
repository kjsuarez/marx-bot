require 'discordrb'
require 'dotenv/load'
require 'nokogiri'
require 'open-uri'

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
      if member.online? && false
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

bot.message(containing: '!normal') do |event|
  event.server.members.each{ |member|
    begin
      current = member.nick
      new_name = member.username
      member.set_nickname(new_name)
    rescue Exception => e
      puts "big OOPS #{e}"
    end
  }

  response_list = [
    "no fun.",
    "Boooooo",
    "BOOOOOO!",
    "GAY",
    "that's not very cash money of you.",
    "Nark.",
    get_lewd
  ]

   event.respond(response_list.sample)
end

bot.message(containing: '!silence') do |event|
  # if event.user.id.to_s == ENV['KEVIN_ID']
    event.server.members.each{ |member|
      begin
        if member.voice_channel
          puts "name: #{member.display_name}"
          member.server_mute
          if member.online? && false
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
  # end
end

bot.message(containing: '!speak') do |event|
  # if event.user.id.to_s == ENV['KEVIN_ID']
    event.server.members.each{ |member|
      begin
        if member.voice_channel
          puts "name: #{member.display_name}"
          member.server_unmute
          if member.online? && false
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
  # end
end

#TODO After prod bot is hosted, add function to assign role on joining.

bot.message(containing: '!lewd') do |event|
  begin
    if event.channel.name == "super-weenie-hut-juniors"
      event.respond("https://media.giphy.com/media/5ftsmLIqktHQA/giphy.gif")
      event.respond("no lewds in super-weenie-hut-juniors")
    else
      event.respond(get_lewd)
    end
    puts "event: #{event}"
  rescue Exception => e
    puts "big OOPS #{e}"
  end
end

bot.message(containing: '!biglewd') do |event|
  begin
    history = event.channel.history(limit = 100)
    lewd_history = history.select{|message| message.content.include?("!lewd")}
    puts "event: #{lewd_history.length}"
    lewd_history.each { |message|
      event.respond(get_lewd)
    }
    event.respond("fine.")
  rescue Exception => e
    puts "big OOPS #{e}"
  end
end

bot.message(containing: '!chaste') do |event|
  begin
    history = event.channel.history(limit = 100)
    lewd_history = history.select{|message| message.content.include?("rule34.xxx")}
    if lewd_history.length < 2
      lewd_history << history.find{|message| message.content.include?("!lewd")}
    end
    puts "event: #{lewd_history.length}"
    event.channel.delete_messages(lewd_history)
    event.respond("fine.")
  rescue Exception => e
    puts "big OOPS #{e}"
  end
end

bot.message(containing: '!truth') do |event|
  begin
    puts "event: #{event}"
    event.respond(get_reddit('https://www.reddit.com/r/AnarchoWave/'))
  rescue Exception => e
    puts "big OOPS #{e}"
  end
end

def get_reddit(url)
  retries = 0
  while retries < 15
    begin
      reddit_page = Nokogiri::HTML(open(url))
      reddit_images = reddit_page.css('img')
      preened_images = reddit_images.select{|img| img.attributes["src"].value.include?("https://preview.redd")}
      reddit_link = preened_images.sample.attributes["src"].value
      return reddit_link
    rescue OpenURI::HTTPError
      retries += 1
      puts "retrying #{url}"
    end

  end
end

bot.message(containing: '!cena') do |event|
  begin
    channel = event.user.voice_channel
    bot.voice_connect(channel)
    voice_bot = event.voice
    voice_bot.play_file('assets/cena_short.mp3')

    voice_bot.destroy
  rescue Exception => e
    puts "big OOPS #{e}"
  end
end

bot.message(containing: '!horn') do |event|
  begin
    channel = event.user.voice_channel
    bot.voice_connect(channel)
    voice_bot = event.voice
    voice_bot.play_file('assets/horn.mp3')

    voice_bot.destroy
  rescue Exception => e
    puts "big OOPS #{e}"
  end
end

def get_lewd()
  lewd_page = Nokogiri::HTML(open('https://rule34.xxx/index.php?page=post&s=random'))
  lewd_link = lewd_page.css('img')[2].attributes["src"].value
  return lewd_link
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
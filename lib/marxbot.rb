require 'discordrb'
# require 'dotenv/load' # Only for local use
require 'nokogiri'
require 'open-uri'
require_relative 'marxbot/tarot/fortune'
# require 'pry'


class MarxBot
  attr_reader :bot, :auto_stop, :stop_time
  def initialize(token:, auto_stop:false, stop_time:60*15)
    @token = token
    @auto_stop = auto_stop
    @stop_time = stop_time
    @bot = Discordrb::Bot.new token: @token
    @noun_path = File.join(File.dirname(__FILE__), "noun.json")
    @adjective_path = File.join(File.dirname(__FILE__), "adjective.json")
    @slogan_path = File.join(File.dirname(__FILE__), "slogans.json")
  end

  def stop_eventually()
    sleep(@stop_time)
    @bot.stop
    puts "$$$ The Bot should be stopped $$$"
  end

  def get_slogan()
    all_slogans = slogan_dict["slogans"]
    slogan_number = Random.new.rand(all_slogans.length)
    return all_slogans[slogan_number]
  end

  def get_adjective()
    adjectives = adjective_dict["adjs"]
    adj_choice = Random.new.rand(adjectives.length)
    return adjectives[adj_choice]
  end

  def get_noun()
    nouns = noun_dict["nouns"]
    noun_choice = Random.new.rand(nouns.length)
    return nouns[noun_choice]
  end

  def slogan_dict
    return JSON.parse(File.read(@slogan_path))
  end

  def noun_dict
    return JSON.parse(File.read(@noun_path))
  end

  def adjective_dict
    return JSON.parse(File.read(@adjective_path))
  end

  def get_lewd()
    lewd_page = Nokogiri::HTML(URI.open('https://rule34.xxx/index.php?page=post&s=random'))
    lewd_link = lewd_page.css('img')[2].attributes["src"].value
    return lewd_link
  end

  def run()
    @bot.message(content: 'ping') do |event|
      event.respond 'pong'
    end

    @bot.message(containing: '!sleep') do |event|
       event.respond("\"Good night Moon.\"")
       @bot.stop
    end

    @bot.message(containing: '!slogan') do |event|
      puts "event: #{event.user.id.class}"
        event.respond("\"#{get_slogan}\"")
    end

    @bot.message(containing: '!kneel') do |event|
      has_specific = event.message.to_s.include?(">>")
      specific = event.message.to_s.split(">>").last
      puts "event: #{event.user.id.class}"

      event.server.members.each{ |member|
        begin
          current = member.nick
          if has_specific
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

    @bot.message(containing: '!normal') do |event|
      event.server.members.each{ |member|
        begin
           puts member.nick
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

    @bot.message(containing: '!silence') do |event|
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

    @bot.message(containing: '!speak') do |event|
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

    @bot.message(containing: '!lewd') do |event|
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

    @bot.message(containing: '!biglewd') do |event|
      begin
        history = event.channel.history(limit = 100)
        lewd_history = history.select{|message| message.content.include?("!lewd")}
        puts "event: #{lewd_history.length}"
        20.times{ |n|
          sleep(5)
          event.respond(get_lewd)
        }
        event.respond("fine.")
      rescue Exception => e
        puts "big OOPS #{e}"
      end
    end

    @bot.message(containing: '!chaste') do |event|
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

    @bot.message(containing: '!fortune') do |event|
      begin
        fortune_teller = ::Tarot::Fortune.new()
        fortune = fortune_teller.tell_fortune()
        card_str = fortune[:cards].map{|card| "#{card.flipped ? "Reversed ":""} #{card.name}"}.join("\n")
        result_str = fortune[:result]
        event.respond("\`\`\`#{card_str}\`\`\`")
        event.respond(result_str)
      rescue Exception => e
        puts "big OOPS #{e}"
        event.respond(e)
      end
    end

    if @auto_stop
      threads = []
      threads << Thread.new { @bot.run }
      threads << Thread.new { self.stop_eventually() }
      threads.each(&:join)
    else
      @bot.run
    end
  end
end

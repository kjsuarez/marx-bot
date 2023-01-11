Gem::Specification.new do |s|
  s.name        = "marxbot"
  s.version     = "0.0.4"
  s.summary     = "A discord bot"
  s.description = "A simple set of toys for use in discord"
  s.authors     = ["Kevin Suarez"]
  s.email       = "kjsuarez94@gmail.com"
  s.add_runtime_dependency "nokogiri",
    ["= 1.10.9"]
  s.add_runtime_dependency "discordrb",
    ["= 3.4.0"]
  s.files       = [
    "lib/marxbot.rb",
    "lib/noun.json",
    "lib/adjective.json",
    "lib/slogans.json",
    "lib/marxbot/tarot/card.rb",
    "lib/marxbot/tarot/cards.json",
    "lib/marxbot/tarot/fortune.rb"
  ]
  s.homepage    =
    "https://rubygems.org/gems/marxbot"
  s.license       = "MIT"
end

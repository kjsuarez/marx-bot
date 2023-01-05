require "json"
require "pry"
CARDS_PATH = File.join(File.dirname(__FILE__), "cards.json")
CARDS_DICT = JSON.parse(File.read(CARDS_PATH))["cards"]
module Tarot
  class Card
    attr_reader :number, :name, :flipped, :nouns, :verbs, :adjectives
    def initialize(card_data, flipped)
      @number = card_data["id"]
      @flipped = flipped
      @card_data = card_data
      @name = @card_data["name"]
      @language = @card_data["orientation"].select{|ori| ori["flipped"] == @flipped}.first
      @nouns = @language["nouns"]
      @verbs = @language["verbs"]
      @adjectives = @language["adjectives"]
    end

    def noun
      @nouns.sample
    end

    def verb
      @verbs.sample
    end

    def adjective
      @adjectives.sample
    end

    def self.deck_json
      CARDS_DICT
    end

  end
end

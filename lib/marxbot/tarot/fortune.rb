require "json"
require "pry"
require_relative "card"
module Tarot
  class Fortune
    attr_reader :hand, :hand_size, :deck
    def initialize()
      @deck = Card.deck_json
      @hand_size = 6
      @hand = draw_hand()
    end

    def draw_hand()
      cards = []
      hand_size.times do |i|
        flipped = [true,false].sample
        card_data = deck.sample
        deck.reject!{|c| c == card_data}
        # binding.pry
        cards << Card.new(card_data, flipped)
      end

      return cards
    end

    def tell_fortune()
      puts hand.map{|card| "#{card.flipped} #{card.name}"}
      return {
        cards: hand,
        result: fortune_structures.sample
      }
    end

    def fortune_structures()
      lines = [
        "#{hand[0].adjective} #{hand[1].noun} #{maybe_word} #{hand[2].verb} #{link_word} #{hand[3].noun}"
      ]
    end

    def link_word
      ["for", "because of", "thanks to", "and so", "thus, the"].sample
    end

    def maybe_word
      ["will", "could", "shall", "ought to", "should"].sample
    end
  end
end

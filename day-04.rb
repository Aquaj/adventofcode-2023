require_relative 'common'

class Day4 < AdventDay
  EXPECTED_RESULTS = { 1 => 13, 2 => 30 }

  def first_part
    wins = cards.map do |card|
      (card[:winners] & card[:numbers]).count
    end
    wins.sum { |win_count| win_count.zero? ? 0 : 2**(win_count-1) }
  end

  class CardPile
    def initialize(cards)
      @cards = cards.dup
      @draws = {}
      @counts = @cards.map { |c| [c[:id], 0] }.to_h
    end

    attr_reader :cards, :counts

    def draw(card)
      @counts[card[:id]] += 1

      @draws[card] ||= begin
        count = (card[:winners] & card[:numbers]).count
        @cards.slice(card[:id], count) || []
      end

      @draws[card].each { |new_card| draw(new_card) }
    end
  end

  def second_part
    pile = CardPile.new(cards)
    pile.cards.each { |card| pile.draw(card) }
    pile.counts.values.sum
  end

  private

  alias cards input

  CARD_FORMAT = /^Card *(\d+): ((?: *\d+ ?)+) \| ((?: *\d+ ?)+)$/
  def convert_data(data)
    super.map do |card|
      id, winners, numbers = card.match(CARD_FORMAT).captures
      { id: id.to_i, winners: winners.split.map(&:to_i), numbers: numbers.split.map(&:to_i) }
    end
  end

  def debug_input
    path = "#{input_fetcher.debug_file_path}-#{part}"
    File.read(path)
  end
end

Day4.solve if __FILE__ == $0

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
      @original_cards = cards.dup
      @changes = {}
      @counts = {}
    end

    attr_reader :original_cards, :counts

    def draw(card)
      @counts = impact(compute_change(card), on: @counts)

      @counts
    end

    private

    def compute_change(card)
      @changes[card] ||= begin
        change = empty_changeset
        change[card] += 1

        count = (card[:winners] & card[:numbers]).count
        new_cards = original_cards.slice(card[:id], count) || []

        new_cards.reduce(change) do |changeset, new_card|
          impact(compute_change(new_card), on: changeset)
        end
      end
    end

    def empty_changeset
      original_cards.map { |c| [c, 0] }.to_h
    end

    def impact(change, on:)
      on.merge(change) { |_,existing,new| existing + new }
    end
  end

  def second_part
    pile = CardPile.new(cards)

    pile.original_cards.each { |card| pile.draw(card) }

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

require_relative 'common'

class Day4 < AdventDay
  EXPECTED_RESULTS = { 1 => 13 }

  def first_part
    wins = cards.map do |card|
      (card[:winners] & card[:numbers]).count
    end
    wins.sum { |win_count| win_count.zero? ? 0 : 2**(win_count-1) }
  end

  def second_part
  end

  private

  alias cards input

  CARD_FORMAT = /^Card *(\d+): ((?: *\d+ ?)+) \| ((?: *\d+ ?)+)$/
  def convert_data(data)
    super.map do |card|
      id, winners, numbers = card.match(CARD_FORMAT).captures
      { id:, winners: winners.split.map(&:to_i), numbers: numbers.split.map(&:to_i) }
    end
  end
end

Day4.solve if __FILE__ == $0

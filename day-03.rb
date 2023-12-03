require_relative 'common'

class Day3 < AdventDay
  EXPECTED_RESULTS = { 1 => 4361 }

  class Schematic < Grid
    SYMBOL = /\D/
    NUMBER = /\d/

    def neighbors_of(*coords, diagonals: true)
      # Do not connect through symbols
      return [] if self[*coords] =~ SYMBOL

      super.
        # Not allowing numbers to 'touch' when they're not in a *row* (reading LTR)
        reject { |(x,y)| y != coords.last && self[x,y] =~ NUMBER }
    end

    # Using BFS to establish connex components
    def components
      coords.each_with_object([]) do |seed, components|
        next if self[*seed].nil? || components.any? { _1.include? seed }
        components << bfs_traverse(seed)
      end
    end
  end

  def first_part
    parts = schematic.
      components.
      select { |group| group.find { |pos| schematic[*pos].match? Schematic::SYMBOL } } # Reject if no symbol in group

    numbers = parts.map do |positions|
      digits = positions.
        sort_by { |(x,_)| x }. # Sorting by y gives the digits in order ince numbers are read LTR
        map { |pos| schematic[*pos] }. # Converting to value in grid, ie digits
        reject { |digit| digit =~ Schematic::SYMBOL } # Remove symbol

      digits.join.to_i
    end

    numbers.sum
  end

  def second_part
  end

  private

  alias schematic input

  def convert_data(data)
    Schematic.new(super.map { |line| line.chars.map { |c| c == '.' ? nil : c }})
  end
end

Day3.solve if __FILE__ == $0

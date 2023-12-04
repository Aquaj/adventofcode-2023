require_relative 'common'

class Day3 < AdventDay
  EXPECTED_RESULTS = { 1 => 4361, 2 => 467835 }

  class Schematic < Grid
    NUMBER = /\d/
    SYMBOL = /\D/
    GEAR_SYMBOL = /\*/

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
    parts = schematic.components.
      reject { |group| group.none? { |pos| schematic[*pos] =~ Schematic::NUMBER } }.
      group_by { |group| group.find { |pos| schematic[*pos] =~ Schematic::SYMBOL } }.
      without(nil)

    # "A gear is any * symbol that is adjacent to exactly two part numbers."
    gears = parts.select { |part_type, parts| schematic[*part_type] =~ Schematic::GEAR_SYMBOL && parts.size == 2 }

    ratios = gears.map do |gear, parts|
      numbers = parts.map do |positions|
        digits = positions.
          sort_by { |(x,_)| x }. # Sorting by y gives the digits in order ince numbers are read LTR
          map { |pos| schematic[*pos] }. # Converting to value in grid, ie digits
          reject { |digit| digit =~ Schematic::SYMBOL } # Remove symbol

        digits.join.to_i
      end

      numbers.reduce(&:*)
    end

    ratios.sum
  end

  private

  alias schematic input

  def convert_data(data)
    Schematic.new(super.map { |line| line.chars.map { |c| c == '.' ? nil : c }})
  end
end

Day3.solve if __FILE__ == $0

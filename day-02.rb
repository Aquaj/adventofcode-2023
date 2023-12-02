require_relative 'common'

class Day2 < AdventDay
  EXPECTED_RESULTS = { 1 => 8, 2 => 2286 }

  REFERENCE_BAG = {
    red: 12,
    green: 13,
    blue: 14,
  }.freeze

  def first_part
    possible_games = games.select do |game|
      game[:pulls].all? do |pull|
        pull.all? do |color, count|
          count <= REFERENCE_BAG[color]
        end
      end
    end

    possible_games.sum { |g| g[:id] }
  end

  def second_part
    min_cube_sets = games.map do |game|
      REFERENCE_BAG.keys.map do |color|
        minimum_amount = game[:pulls].map { |pull| pull[color] || 0 }.max

        [color, minimum_amount]
      end.to_h
    end

    powers = min_cube_sets.map { |set| set.values.reduce(&:*) }

    powers.sum
  end

  private

  alias games input

  GAME_INFO_FORMAT = /^Game (?<id>\d+): (?<pulls>.*)$/
  def convert_data(data)
    super.map do |game_info|
      id, pulls = game_info.match(GAME_INFO_FORMAT).captures
      {
        id: id.to_i,
        pulls: pulls.split(';').map { |pull| extract_cubes_from(pull) }
      }
    end
  end

  CUBE_PULL_FORMAT = /(?<count>\d+) (?<color>\w+)/
  def extract_cubes_from(pull_info)
    pull_info.split(', ').map do |cube_pull|
      count, color = cube_pull.match(CUBE_PULL_FORMAT).captures
      [color.to_sym, count.to_i]
    end.to_h
  end
end

Day2.solve if __FILE__ == $0

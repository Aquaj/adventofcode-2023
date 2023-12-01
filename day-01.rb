require_relative 'common'

class Day1 < AdventDay
  EXPECTED_RESULTS = { 1 => 142, 2 => nil }

  def first_part
    calibration_values = input.map do |line|
      digits = line.gsub(/\D/, '').chars
      [digits.first, digits.last].join.to_i
    end

    calibration_values.sum
  end

  def second_part
  end

  private

  def convert_data(data)
    super
  end
end

Day1.solve if __FILE__ == $0

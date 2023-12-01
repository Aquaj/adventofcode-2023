require_relative 'common'

class Day1 < AdventDay
  EXPECTED_RESULTS = { 1 => 142, 2 => 281 }

  def first_part
    calibration_values = input.map do |line|
      digits = extract_digits(line)
      [digits.first, digits.last].join.to_i
    end

    calibration_values.sum
  end

  def second_part
  end

  private

  def extract_digits(line)
    line.gsub(/\D/, '').chars
  end

  def convert_data(data)
    super
  end

  def debug_input
    path = "#{input_fetcher.debug_file_path}-#{part}"
    File.read(path)
  end
end

Day1.solve if __FILE__ == $0

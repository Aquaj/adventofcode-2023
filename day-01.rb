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
    calibration_values = input.map do |line|
      digits = extract_digits(line, spelled_out: true)
      [digits.first, digits.last].join.to_i
    end

    calibration_values.sum
  end

  private

  DIGIT_WORDS = %w[one two three four five six seven eight nine].freeze

  def extract_digits(line, spelled_out: false)
    matches = [/\d/]
    matches += DIGIT_WORDS if spelled_out

    # By using a lookahead *with* a capture group, we can have a regexp that'll
    # get overlaps. e.g.: oneight => one, eight
    overlapping_scan_regex = /(?=(#{matches.join('|')}))/

    line.scan(overlapping_scan_regex).map do |(number_or_word)|
      if spelled_out && DIGIT_WORDS.include?(number_or_word)
        number_or_word => word
        DIGIT_WORDS.index(word) + 1 # + 1 to account for lack of `zero` in DIGIT_WORDS
      else
        number_or_word => number
        number.to_i
      end
    end
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

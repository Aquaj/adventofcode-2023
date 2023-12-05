require_relative 'common'

class Day5 < AdventDay
  EXPECTED_RESULTS = { 1 => 35 }

  class Converter
    def initialize(from_resource, to_resource)
      @from = from_resource.to_sym
      @to = to_resource.to_sym
      @conversions = {}
    end

    def add_conversion(source_start, dest_start, range)
      range = Range.new(source_start, source_start + range)
      @conversions[range] = (dest_start - source_start)
    end

    def can_convert?(type, to:)
      type == @from && (to.nil? || to == @to)
    end

    def convert(value)
      _, conversion_delta = @conversions.find { |range, _| range.cover? value }
      return value unless conversion_delta
      value + conversion_delta
    end
  end

  STEPS = %i[seed soil fertilizer water light temperature humidity location]
  def first_part
    almanac[:seeds].map do |seed|
      STEPS.each_cons(2).reduce(seed) do |value, (from, to)|
        converter = almanac[:converters].find { |conv| conv.can_convert?(from, to:)  }
        converter.convert(value)
      end
    end.min
  end

  def second_part
  end

  private

  alias almanac input

  def convert_data(data)
    sections = data.split("\n\n")
    seeds = sections.shift.scan(/\d+/).map(&:to_i)

    converters = sections.map do |section|
      lines = section.split("\n")
      from, to = lines.shift.match(/(\w+)-to-(\w+)/).captures
      converter = Converter.new(from, to)
      lines.each do |conversion|
        dest, source, range = conversion.split.map(&:to_i)
        converter.add_conversion(source, dest, range)
      end
      converter
    end

    { seeds: , converters: }
  end
end

Day5.solve if __FILE__ == $0

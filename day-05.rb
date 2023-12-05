require_relative 'common'

class Day5 < AdventDay
  EXPECTED_RESULTS = { 1 => 35, 2 => 46 }

  class Converter
    def initialize(from_resource, to_resource)
      @from = from_resource.to_sym
      @to = to_resource.to_sym
      @conversions = {}
    end

    def breakpoints
      @conversions.flat_map { |range, _| [range.begin, range.end] }.sort.uniq
    end

    def chain_with(oth)
      raise ArgumentError, "can't combine non-matching #{self.to} / #{oth.from}" unless oth.from == self.to

      combined = Converter.new(self.from, oth.to)
      inversion = self.inverse

      oth_breakpoints = oth.breakpoints.map { |b| inversion.convert(b) }
      breakpoints = [*self.breakpoints, *oth_breakpoints].sort.uniq

      breakpoints.each_cons(2) do |(start, finish)|
        total_delta = oth.convert(self.convert(start)) - start

        combined.add_conversion(start...finish, total_delta)
      end

      combined
    end

    def inverse
      inversion = Converter.new(to, from)

      @conversions.map do |range, delta|
        new_begin = range.begin + delta
        new_end = range.end + delta

        inversion.add_conversion new_begin...new_end, -delta
      end

      inversion
    end

    protected attr_reader :from, :to, :conversions

    def add_conversion(range, delta)
      @conversions[range] = delta
    end

    def can_convert?(type, to:)
      type == @from && (to.nil? || to == @to)
    end

    def convert(value, &default)
      default ||= proc { |v| v }
      _, delta = @conversions.find { |range, _| range.cover? value }
      return default.call(value) unless delta
      value + delta
    end
  end

  STEPS = %i[seed soil fertilizer water light temperature humidity location]
  def first_part
    seeds = almanac[:seed_info]
    seeds.map do |seed|
      STEPS.each_cons(2).reduce(seed) do |value, (from, to)|
        converter = almanac[:converters].find { |conv| conv.can_convert?(from, to:)  }
        converter.convert(value)
      end
    end.min
  end

  def second_part
    seed_ranges = almanac[:seed_info]
    seeds = seed_ranges.each_slice(2).map { |start, range| start...(start+range) }

    combined = almanac[:converters].reduce(&:chain_with)

    combined.breakpoints.reject do |breakpoint|
      seeds.none? { |seed_range| seed_range.cover? breakpoint }
    end.map do |seed|
      combined.convert(seed)
    end.min
  end

  private

  alias almanac input

  def convert_data(data)
    sections = data.split("\n\n")
    seed_info = sections.shift.scan(/\d+/).map(&:to_i)

    converters = sections.map do |section|
      lines = section.split("\n")
      from, to = lines.shift.match(/(\w+)-to-(\w+)/).captures
      converter = Converter.new(from, to)
      lines.each do |conversion|
        dest, source, range = conversion.split.map(&:to_i)
        range = source...(source + range)
        delta = (dest - source)

        converter.add_conversion(range, delta)
      end
      converter
    end

    { seed_info: , converters: }
  end
end

Day5.solve if __FILE__ == $0

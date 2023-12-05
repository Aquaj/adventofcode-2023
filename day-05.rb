require_relative 'common'
require 'z3'

class Day5 < AdventDay
  EXPECTED_RESULTS = { 1 => 35, 2 => 46 }

  class NaiveConverter
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

      combined = NaiveConverter.new(self.from, oth.to)
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
      inversion = NaiveConverter.new(to, from)

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

  class LinearConverter
    def initialize(from_resource, to_resource, input = Z3::Int("input-#{from_resource}>#{to_resource}"), formula = input)
      @from = from_resource.to_sym
      @to = to_resource.to_sym
      @input = input
      @formula = formula
    end

    def add_conversion(range, delta)
      @formula = Z3::IfThenElse((@input >= range.begin) & (@input < range.end), @input + delta, @formula)
    end

    def can_convert?(type, to:)
      type == @from && (to.nil? || to == @to)
    end

    def convert(val)
      solver = Z3::Solver.new
      solver.assert @input == val
      solver.model[@formula].to_i if solver.satisfiable?
    end

    def chain_with(oth)
      chain = ConversionChain.new
      chain.add(self).chain_with(oth)
    end

    attr_reader :from, :to, :formula, :input
  end

  class ConversionChain
    def initialize()
      @chain = []
    end

    def add(converter)
      to = @chain.last&.to
      raise ArgumentError, "can't combine non-matching #{to} / #{converter.from}" unless to.nil? || converter.from == to

      @chain << converter

      self
    end
    alias chain_with add

    def convert(val)
      solver = Z3::Optimize.new

      solver.assert @chain.first.input == val

      assert_conversions_on(solver)

      solver.model[@chain.last.formula].to_i if solver.satisfiable?
    end

    def find_minimum(allowed_answers:)
      solver = Z3::Optimize.new

      input = @chain.first.input

      output = Z3::Int('output')
      domain_restriction = allowed_answers.reduce(Z3.False) do |candidate_matcher, candidate|
        case candidate
        in Range
          candidate_matcher | (input >= candidate.begin) & (input < candidate.end)
        in Numeric
          candidate_matcher | (input == candidate)
        end
      end
      solver.assert domain_restriction.simplify

      assert_conversions_on(solver)

      solver.assert output == @chain.last.formula
      solver.minimize output
      solver.model[output].to_i if solver.satisfiable?
    end

    private

    def assert_conversions_on(solver)
      @chain.each_cons(2) do |c1, c2|
        solver.assert (c1.formula == c2.input).simplify
      end

      solver
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

    # combined.find_minimum(allowed_answers: seeds)

    # seeds.map.with_index do |seed_range, i|
    #   [seed_range.begin, seed_range.end].map do |seed|
    #     combined.convert(seed)
    #   end.min
    # end.min

    inversion = combined.inverse
    (1..).find do |location|
      seed = inversion.convert(location) { nil }
      seeds.any? { |range| range.cover? seed }
    end
  end

  private

  alias almanac input

  def convert_data(data)
    sections = data.split("\n\n")
    seed_info = sections.shift.scan(/\d+/).map(&:to_i)

    converters = sections.map do |section|
      lines = section.split("\n")
      from, to = lines.shift.match(/(\w+)-to-(\w+)/).captures
      converter = NaiveConverter.new(from, to)
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

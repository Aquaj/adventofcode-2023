require_relative 'common'

class Day6 < AdventDay
  EXPECTED_RESULTS = { 1 => 288 }

  # d(t) = (Tr-t)*t
  # d(t) > Dr
  # (Tr-t)*t > Dr
  # Tr*t - t^2 > Dr
  # t^2 - Tr*t < -Dr
  # t^2 - Tr*t - Dr < 0
  # ∆ = Tr^2 - 4Dr
  # t1 = (Tr - √(Tr^2 - 4Dr))/2
  # t2 = (Tr + √(Tr^2 - 4Dr))/2
  def first_part
    races_info.map do |race_duration, race_record|
      winning_times(race_duration, race_record).count
    end.reduce(&:*)
  end

  def second_part
  end

  private

  alias races_info input

  def winning_times(time, distance_to_beat)
    ∆ = time**2 - 4*distance_to_beat
    t1 = (time - Math.sqrt(∆))/2
    t2 = (time + Math.sqrt(∆))/2
    # t1 and t2 *tie* with distance_to_beat
    first_winning = (t1+1).floor
    last_winning = (t2-1).ceil

    (first_winning..last_winning)
  end

  def convert_data(data)
    super.map(&:split).map { |cols| cols.tap(&:shift).map(&:to_i) }.transpose
  end
end

Day6.solve if __FILE__ == $0

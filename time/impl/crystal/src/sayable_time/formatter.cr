module SayableTime
  class Formatter
    @short_clock : ShortClockConfig?

    def initialize(@locale : TimeLocale, @compactness : Symbol = :normal)
      ovr = case @compactness
            when :short   then @locale.short
            when :compact then @locale.compact
            else               nil
            end
      @short_clock = ovr.try(&.clock)
    end

    def format_time(input : String?) : String?
      return nil if input.nil? || input.empty?

      parsed = parse_time(input)
      return nil if parsed.nil?

      hour, minute = parsed

      if @compactness != :normal && @short_clock
        format_digital(hour, minute)
      else
        format_natural(hour, minute)
      end
    end

    private def parse_time(input_str : String) : Tuple(Int32, Int32)?
      return nil if input_str.empty?

      t = input_str
      t = t.split('T')[1] if t.includes?('T')
      t = t.split('+')[0] if t.includes?('+')
      t = t.split('Z')[0] if t.includes?('Z')

      parts = t.split(':')
      return nil if parts.size < 2

      hour = parts[0].to_i? || return nil
      minute = parts[1].split('.')[0].to_i? || return nil
      return nil if hour < 0 || hour > 23 || minute < 0 || minute > 59

      {hour, minute}
    end

    private def round_to_5(minute : Int32) : Int32
      ((minute + 2) // 5) * 5
    end

    private def format_natural(hour : Int32, minute : Int32) : String
      clock = @locale.clock
      rounded = round_to_5(minute)
      h = hour

      if rounded == 60
        rounded = 0
        h = (h + 1) % 24
      end

      if rounded == 0
        return clock.midnight if h == 0
        return clock.noon if h == 12
      end

      h12 = h % 12
      next_h12 = (h + 1) % 12
      h_name = clock.hours[h12]
      next_h_name = clock.hours[next_h12]
      pattern = clock.patterns[rounded]? || clock.patterns[0]? || "{h}"
      pattern.gsub("{h}", h_name).gsub("{next_h}", next_h_name)
    end

    private def format_digital(hour : Int32, minute : Int32) : String
      sc = @short_clock.not_nil!
      fmt = sc.format

      if sc.use24h
        return fmt.gsub("{h}", hour.to_s).gsub("{mm}", minute.to_s.rjust(2, '0'))
      end

      h12 = hour % 12
      h12 = 12 if h12 == 0
      am_pm = sc.am_pm || ["AM", "PM"]
      ampm_str = hour < 12 ? am_pm[0] : am_pm[1]

      fmt.gsub("{h}", h12.to_s)
         .gsub("{mm}", minute.to_s.rjust(2, '0'))
         .gsub("{ampm}", ampm_str)
    end
  end
end

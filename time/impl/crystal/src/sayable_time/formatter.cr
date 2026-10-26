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

    # A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
    # suffix, which is ignored), alone or after the T of an ISO datetime.
    CLOCK_PATTERN = /\A([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z/
    DATE_PATTERN  = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/

    private def parse_time(input_str : String) : Tuple(Int32, Int32)?
      clock = input_str
      if t = input_str.index('T')
        return nil unless real_date?(input_str[0, t])
        clock = input_str[(t + 1)..]
      end
      m = CLOCK_PATTERN.match(clock) || return nil
      hour, minute = m[1].to_i, m[2].to_i
      second = m[3]?.try(&.to_i) || 0
      return nil if hour > 23 || minute > 59 || second > 59

      {hour, minute}
    end

    private def real_date?(s : String) : Bool
      m = DATE_PATTERN.match(s) || return false
      year, month, day = m[1].to_i, m[2].to_i, m[3].to_i
      1 <= month <= 12 && 1 <= day <= days_in_month(year, month)
    end

    private def days_in_month(year : Int32, month : Int32) : Int32
      case month
      when 4, 6, 9, 11 then 30
      when 2           then (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28
      else                  31
      end
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

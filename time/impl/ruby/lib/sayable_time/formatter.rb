# frozen_string_literal: true

module SayableTime
  # Locale-aware clock time formatter.
  #
  # Example:
  #   st = SayableTime::Formatter.new(SayableTime::Locales::EN)
  #   st.format_time("14:15")   # => "a quarter past two"
  #   st.format_time("09:30")   # => "half past nine"
  #
  #   st_short = SayableTime::Formatter.new(SayableTime::Locales::EN, :short)
  #   st_short.format_time("14:15")   # => "2:15 PM"
  class Formatter
    VERSION = SayableTime::VERSION

    # @param locale [TimeLocale] locale definition
    # @param compactness [Symbol] :normal, :short, or :compact
    def initialize(locale, compactness = :normal)
      @locale = locale
      @compactness = compactness
      ovr = case compactness
            when :short then locale.short
            when :compact then locale.compact
            end
      @short_clock = ovr&.clock
    end

    # Format a time as natural language clock reading.
    #
    # @param input [String, nil] time as "HH:MM" or ISO datetime string
    # @return [String, nil] formatted time or nil on invalid input
    def format_time(input)
      return nil if input.nil? || (input.is_a?(String) && input.empty?)

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
    CLOCK_TIME = /\A(?:([0-9]{4})-([0-9]{2})-([0-9]{2})T)?([0-9]{1,2}):([0-9]{2})
                  (?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z/x

    private

    def parse_time(input_str)
      return nil if input_str.nil?

      match = CLOCK_TIME.match(input_str.to_s)
      return nil if match.nil?

      year, month, day, hour, minute, second = match.captures.map { |part| part&.to_i }
      return nil if year && !real_date?(year, month, day)
      return nil if hour > 23 || minute > 59 || (second || 0) > 59

      [hour, minute]
    end

    def real_date?(year, month, day)
      month.between?(1, 12) && day.between?(1, days_in_month(year, month))
    end

    def days_in_month(year, month)
      return 30 if [4, 6, 9, 11].include?(month)
      return 31 unless month == 2

      leap = (year % 4).zero? && (!(year % 100).zero? || (year % 400).zero?)
      leap ? 29 : 28
    end

    def round_to_five(minute)
      ((minute + 2) / 5) * 5
    end

    def format_natural(hour, minute)
      clock = @locale.clock
      rounded = round_to_five(minute)
      h = hour

      if rounded == 60
        rounded = 0
        h = (h + 1) % 24
      end

      if rounded.zero?
        return clock.midnight if h.zero?
        return clock.noon if h == 12
      end

      h12 = h % 12
      next_hour_index = (h + 1) % 12
      h_name = clock.hours[h12]
      next_h_name = clock.hours[next_hour_index]
      pattern = clock.patterns.fetch(rounded, clock.patterns.fetch(0, '{h}'))
      pattern.gsub('{h}', h_name).gsub('{next_h}', next_h_name)
    end

    def format_digital(hour, minute)
      sc = @short_clock
      fmt = sc.format

      return fmt.gsub('{h}', hour.to_s).gsub('{mm}', minute.to_s.rjust(2, '0')) if sc.use24h

      h12 = hour % 12
      h12 = 12 if h12.zero?
      am_pm = sc.am_pm || %w[AM PM]
      ampm_str = hour < 12 ? am_pm[0] : am_pm[1]

      fmt.gsub('{h}', h12.to_s)
         .gsub('{mm}', minute.to_s.rjust(2, '0'))
         .gsub('{ampm}', ampm_str)
    end
  end
end

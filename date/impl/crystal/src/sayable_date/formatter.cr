module SayableDate
  class Formatter
    @months : Array(String)
    @months_in_date : Array(String)?
    @weekdays : Array(String)
    @day_format : String
    @day_format_exceptions : Hash(String, String)
    @date_pattern : String
    @date_pattern_with_year : String
    @today : String
    @tomorrow : String
    @yesterday : String

    def initialize(@locale : DateLocale, @compactness : Symbol = :normal)
      ovr = case @compactness
            when :short   then @locale.short
            when :compact then @locale.compact
            else               nil
            end

      @months = ovr.try(&.months) || @locale.months
      @months_in_date = ovr.try(&.months_in_date) || @locale.months_in_date
      @weekdays = ovr.try(&.weekdays) || @locale.weekdays
      @day_format = ovr.try(&.day_format) || @locale.day_format

      # When day_format is overridden but day_format_exceptions is not,
      # clear exceptions (the override replaces the format entirely).
      @day_format_exceptions = if ovr && !ovr.day_format.nil? && ovr.day_format_exceptions.nil?
                                 {} of String => String
                               else
                                 ovr.try(&.day_format_exceptions) || @locale.day_format_exceptions
                               end

      @date_pattern = ovr.try(&.date_pattern) || @locale.date_pattern
      @date_pattern_with_year = ovr.try(&.date_pattern_with_year) || @locale.date_pattern_with_year
      @today = ovr.try(&.today) || @locale.today
      @tomorrow = ovr.try(&.tomorrow) || @locale.tomorrow
      @yesterday = ovr.try(&.yesterday) || @locale.yesterday
    end

    def format_date(date : String?) : String?
      parsed = parse_date(date)
      return nil if parsed.nil?
      y, m, d = parsed
      format_absolute(y, m, d, false)
    end

    def format_date_with_year(date : String?) : String?
      parsed = parse_date(date)
      return nil if parsed.nil?
      y, m, d = parsed
      format_absolute(y, m, d, true)
    end

    def format_relative(date : String?, as_of : String?) : String?
      return nil if date.nil? || date.empty? || as_of.nil? || as_of.empty?

      parsed_date = parse_date(date)
      parsed_as_of = parse_date(as_of)
      return nil if parsed_date.nil? || parsed_as_of.nil?

      dy, dm, dd = parsed_date
      ay, am, ad = parsed_as_of

      date_jdn = to_jdn(dy, dm, dd)
      asof_jdn = to_jdn(ay, am, ad)
      diff = date_jdn - asof_jdn

      # Today
      return @today if diff == 0

      # Tomorrow
      return @tomorrow if diff == 1

      # Yesterday
      return @yesterday if diff == -1

      is_compact = @compactness == :compact

      # Day after tomorrow
      if diff == 2 && @locale.day_after_tomorrow && !is_compact
        return @locale.day_after_tomorrow.not_nil!
      end

      # Day before yesterday
      if diff == -2 && @locale.day_before_yesterday && !is_compact
        return @locale.day_before_yesterday.not_nil!
      end

      # Compact mode: skip weekday references
      if is_compact
        include_year = dy != ay
        return format_absolute(dy, dm, dd, include_year)
      end

      # This weekday (+2 to +6)
      if diff >= 2 && diff <= 6 && @locale.this_weekday
        dow = weekday(dy, dm, dd)
        weekday_name = @weekdays[dow]
        return @locale.this_weekday.not_nil!.sub("{weekday}", weekday_name)
      end

      # Last weekday (-6 to -2)
      if diff >= -6 && diff <= -2 && @locale.last_weekday
        dow = weekday(dy, dm, dd)
        weekday_name = @weekdays[dow]
        return @locale.last_weekday.not_nil!.sub("{weekday}", weekday_name)
      end

      # Next weekday (+7 to +13)
      if diff >= 7 && diff <= 13 && @locale.next_weekday
        dow = weekday(dy, dm, dd)
        weekday_name = @weekdays[dow]
        return @locale.next_weekday.not_nil!.sub("{weekday}", weekday_name)
      end

      # Calendar fallback
      include_year = dy != ay
      format_absolute(dy, dm, dd, include_year)
    end

    # YYYY-MM-DD, optionally followed by T and a time; only the date part
    # is read, and it must name a real calendar day.
    DATE_PATTERN = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T|\z)/

    private def parse_date(s : String?) : Tuple(Int32, Int32, Int32)?
      return nil if s.nil?
      m = DATE_PATTERN.match(s) || return nil
      year, month, day = m[1].to_i, m[2].to_i, m[3].to_i
      return nil unless 1 <= month <= 12 && 1 <= day <= days_in_month(year, month)
      {year, month, day}
    end

    private def days_in_month(year : Int32, month : Int32) : Int32
      case month
      when 4, 6, 9, 11 then 30
      when 2           then (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28
      else                  31
      end
    end

    private def to_jdn(year : Int32, month : Int32, day : Int32) : Int32
      a = (14 - month) // 12
      y = year + 4800 - a
      m = month + 12 * a - 3
      day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045
    end

    private def weekday(year : Int32, month : Int32, day : Int32) : Int32
      jdn = to_jdn(year, month, day)
      (jdn + 1) % 7
    end

    private def format_absolute(year : Int32, month : Int32, day : Int32, include_year : Bool) : String
      day_str = day.to_s
      fmt = @day_format_exceptions[day_str]? || @day_format
      formatted_day = fmt.sub("{n}", day_str)

      # Pick month name (genitive form if available)
      month_names = @months_in_date || @months
      month_name = month_names[month - 1]

      pattern = include_year ? @date_pattern_with_year : @date_pattern
      result = pattern.sub("{month}", month_name)
      result = result.sub("{day}", formatted_day)
      result = result.sub("{d}", day.to_s)
      result = result.sub("{m}", month.to_s)
      if include_year
        result = result.sub("{year}", year.to_s)
        yy = year % 100
        yy_str = yy.to_s.rjust(2, '0')
        result = result.sub("{yy}", yy_str)
      end
      result
    end
  end
end

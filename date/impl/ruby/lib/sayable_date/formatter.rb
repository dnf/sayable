# frozen_string_literal: true

module SayableDate
  # Locale-aware date formatter.
  #
  # Supports three compactness levels: :normal, :short, :compact.
  class Formatter
    def initialize(locale, compactness: :normal)
      @locale = locale
      @compactness = compactness

      ovr = case compactness
            when :short then locale.short
            when :compact then locale.compact
            end

      @months              = pick(ovr, :months, locale.months)
      @months_in_date      = pick(ovr, :months_in_date, locale.months_in_date)
      @weekdays            = pick(ovr, :weekdays, locale.weekdays)
      @day_format          = pick(ovr, :day_format, locale.day_format)

      # When day_format is overridden but day_format_exceptions is not,
      # clear exceptions (the override replaces the format entirely).
      @day_format_exceptions = if ovr && !ovr.day_format.nil? && ovr.day_format_exceptions.nil?
                                 {}
                               else
                                 pick(ovr, :day_format_exceptions, locale.day_format_exceptions)
                               end

      @date_pattern          = pick(ovr, :date_pattern, locale.date_pattern)
      @date_pattern_with_year = pick(ovr, :date_pattern_with_year, locale.date_pattern_with_year)
      @today               = pick(ovr, :today, locale.today)
      @tomorrow            = pick(ovr, :tomorrow, locale.tomorrow)
      @yesterday           = pick(ovr, :yesterday, locale.yesterday)
      freeze
    end

    # Format a calendar date in locale-appropriate form (no year).
    # Returns nil if the input is nil, empty, or unparseable.
    def format_date(date)
      parsed = parse_date(date)
      return nil if parsed.nil?

      format_absolute(parsed[0], parsed[1], parsed[2], false)
    end

    # Format a calendar date with year in locale-appropriate form.
    # Returns nil if the input is nil, empty, or unparseable.
    def format_date_with_year(date)
      parsed = parse_date(date)
      return nil if parsed.nil?

      format_absolute(parsed[0], parsed[1], parsed[2], true)
    end

    # Format a date relative to as_of, picking the most natural reference.
    # Falls back to absolute date for distant dates.
    # Returns nil if either input is nil, empty, or unparseable.
    def format_relative(date, as_of)
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
      return @today if diff.zero?

      # Tomorrow
      return @tomorrow if diff == 1

      # Yesterday
      return @yesterday if diff == -1

      loc = @locale
      is_compact = @compactness == :compact

      # Day after tomorrow (optional, skipped in compact mode)
      return loc.day_after_tomorrow if diff == 2 && loc.day_after_tomorrow && !is_compact

      # Day before yesterday (optional, skipped in compact mode)
      return loc.day_before_yesterday if diff == -2 && loc.day_before_yesterday && !is_compact

      # Compact mode: skip weekday references, go straight to calendar date
      if is_compact
        include_year = dy != ay
        return format_absolute(dy, dm, dd, include_year)
      end

      # This weekday (+2 to +6)
      if diff >= 2 && diff <= 6 && loc.this_weekday
        dow = weekday(dy, dm, dd)
        weekday_name = @weekdays[dow]
        return loc.this_weekday.sub('{weekday}', weekday_name)
      end

      # Last weekday (-6 to -2)
      if diff >= -6 && diff <= -2 && loc.last_weekday
        dow = weekday(dy, dm, dd)
        weekday_name = @weekdays[dow]
        return loc.last_weekday.sub('{weekday}', weekday_name)
      end

      # Next weekday (+7 to +13)
      if diff >= 7 && diff <= 13 && loc.next_weekday
        dow = weekday(dy, dm, dd)
        weekday_name = @weekdays[dow]
        return loc.next_weekday.sub('{weekday}', weekday_name)
      end

      # Calendar fallback
      include_year = dy != ay
      format_absolute(dy, dm, dd, include_year)
    end

    private

    def pick(ovr, field, default)
      return default if ovr.nil?

      val = ovr.send(field)
      val.nil? ? default : val
    end

    # YYYY-MM-DD, optionally followed by T and a time (which is not read).
    ISO_DATE = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T|\z)/

    def parse_date(s)
      return nil if s.nil?

      match = ISO_DATE.match(s)
      return nil if match.nil?

      year, month, day = match.captures.map(&:to_i)
      return nil unless month.between?(1, 12) && day.between?(1, days_in_month(year, month))

      [year, month, day]
    end

    def days_in_month(year, month)
      return 30 if [4, 6, 9, 11].include?(month)
      return 31 unless month == 2

      leap = (year % 4).zero? && (!(year % 100).zero? || (year % 400).zero?)
      leap ? 29 : 28
    end

    def to_jdn(year, month, day)
      a = (14 - month) / 12
      y = year + 4800 - a
      m = month + 12 * a - 3
      day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
    end

    def weekday(year, month, day)
      jdn = to_jdn(year, month, day)
      (jdn + 1) % 7
    end

    def format_absolute(year, month, day, include_year)
      day_str = day.to_s

      fmt = @day_format_exceptions[day_str] || @day_format
      formatted_day = fmt.sub('{n}', day_str)

      # Pick month name (genitive form if available)
      month_names = @months_in_date || @months
      month_name = month_names[month - 1]

      pattern = include_year ? @date_pattern_with_year : @date_pattern
      result = pattern.sub('{month}', month_name)
      result = result.sub('{day}', formatted_day)
      result = result.sub('{d}', day.to_s)
      result = result.sub('{m}', month.to_s)
      if include_year
        result = result.sub('{year}', year.to_s)
        yy = year % 100
        yy_str = yy.to_s.rjust(2, '0')
        result = result.sub('{yy}', yy_str)
      end

      result
    end
  end
end

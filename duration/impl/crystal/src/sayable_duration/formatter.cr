module SayableDuration
  # 500 years, the same ceiling as sayable-age
  MAX_DURATION_MONTHS = 6000

  class Formatter
    @second : UnitForms
    @minute : UnitForms
    @hour : UnitForms
    @day : UnitForms
    @week : UnitForms
    @month : UnitForms
    @year : UnitForms
    @half : String
    @delimiter : String
    @just_now : String
    @ago : String
    @in_future : String

    def initialize(@locale : DurationLocale, compactness : Symbol = :normal)
      ovr = case compactness
            when :short   then @locale.short
            when :compact then @locale.compact
            else               nil
            end

      @second = (ovr.try(&.units).try(&.["second"]?)) || @locale.units["second"]
      @minute = (ovr.try(&.units).try(&.["minute"]?)) || @locale.units["minute"]
      @hour = (ovr.try(&.units).try(&.["hour"]?)) || @locale.units["hour"]
      @day = (ovr.try(&.units).try(&.["day"]?)) || @locale.units["day"]
      @week = (ovr.try(&.units).try(&.["week"]?)) || @locale.units["week"]
      @month = (ovr.try(&.units).try(&.["month"]?)) || @locale.units["month"]
      @year = (ovr.try(&.units).try(&.["year"]?)) || @locale.units["year"]
      @half = ovr.try(&.half) || @locale.half
      @delimiter = ovr.try(&.delimiter) || @locale.delimiter
      @just_now = @locale.just_now
      @ago = ovr.try(&.ago) || @locale.ago
      @in_future = ovr.try(&.in_future) || @locale.in_future
    end

    def format_duration(start_or_seconds : Int?, end_str : String? = nil) : String?
      return nil if start_or_seconds.nil?
      total_seconds = start_or_seconds.to_i64
      return nil if total_seconds < 0
      format_duration_seconds(total_seconds)
    end

    def format_duration(start_str : String?, end_str : String?) : String?
      return nil if start_str.nil? || end_str.nil?
      s = parse_iso_to_seconds(start_str)
      e = parse_iso_to_seconds(end_str)
      return nil if s.nil? || e.nil?
      total_seconds = (e - s).abs
      format_duration_seconds(total_seconds)
    end

    def format_since(start : String?, as_of : String?) : String?
      return nil if start.nil? || start.empty? || as_of.nil? || as_of.empty?
      s = parse_iso_to_seconds(start)
      a = parse_iso_to_seconds(as_of)
      return nil if s.nil? || a.nil?
      diff = a - s
      return nil if diff < 0
      return @just_now if diff == 0
      dur = format_duration_seconds(diff) || return nil
      @ago.sub("{0}", dur)
    end

    def format_until(target : String?, as_of : String?) : String?
      return nil if target.nil? || target.empty? || as_of.nil? || as_of.empty?
      t = parse_iso_to_seconds(target)
      a = parse_iso_to_seconds(as_of)
      return nil if t.nil? || a.nil?
      diff = t - a
      return nil if diff < 0
      return @just_now if diff == 0
      dur = format_duration_seconds(diff) || return nil
      @in_future.sub("{0}", dur)
    end

    private def format_duration_seconds(total : Int64) : String?
      return nil if approximate_months(total // 86400) > MAX_DURATION_MONTHS

      # 0 seconds
      return @just_now if total == 0

      # 1-59 seconds
      return SayableDuration.resolve_unit(total.to_i, @second, @locale) if total < 60

      total_minutes = (total // 60).to_i
      remainder_seconds = (total % 60).to_i

      # 1-4 minutes: minutes + seconds
      if total_minutes < 5
        result = SayableDuration.resolve_unit(total_minutes, @minute, @locale)
        if remainder_seconds > 0
          result += @delimiter + SayableDuration.resolve_unit(remainder_seconds, @second, @locale)
        end
        return result
      end

      # 5-59 minutes
      return SayableDuration.resolve_unit(total_minutes, @minute, @locale) if total_minutes < 60

      total_hours = (total // 3600).to_i
      remainder_minutes = ((total % 3600) // 60).to_i

      # 1-5 hours: hours + minutes (with half marker)
      if total_hours <= 5
        if remainder_minutes == 30
          return SayableDuration.resolve_unit(total_hours, @hour, @locale, @half)
        end
        result = SayableDuration.resolve_unit(total_hours, @hour, @locale)
        if remainder_minutes > 0
          result += @delimiter + SayableDuration.resolve_unit(remainder_minutes, @minute, @locale)
        end
        return result
      end

      # 6-23 hours
      return SayableDuration.resolve_unit(total_hours, @hour, @locale) if total_hours < 24

      total_days = (total // 86400).to_i
      remainder_hours = ((total % 86400) // 3600).to_i

      # 1-2 days: days + hours (with half marker)
      if total_days <= 2
        if remainder_hours == 12
          return SayableDuration.resolve_unit(total_days, @day, @locale, @half)
        end
        result = SayableDuration.resolve_unit(total_days, @day, @locale)
        if remainder_hours > 0
          result += @delimiter + SayableDuration.resolve_unit(remainder_hours, @hour, @locale)
        end
        return result
      end

      # 3-6 days
      return SayableDuration.resolve_unit(total_days, @day, @locale) if total_days < 7

      total_weeks = total_days // 7
      remainder_days = total_days % 7

      # 1-4 weeks: weeks + days (up to 29 days)
      if total_days < 30
        result = SayableDuration.resolve_unit(total_weeks, @week, @locale)
        if remainder_days > 0
          result += @delimiter + SayableDuration.resolve_unit(remainder_days, @day, @locale)
        end
        return result
      end

      total_months = approximate_months(total_days).to_i

      # 1-11 months
      if total_months < 12
        total_months = 1 if total_months == 0
        return SayableDuration.resolve_unit(total_months, @month, @locale)
      end

      # 12+ months: years + months
      total_years = total_months // 12
      remainder_months = total_months % 12
      result = SayableDuration.resolve_unit(total_years, @year, @locale)
      if remainder_months > 0
        result += @delimiter + SayableDuration.resolve_unit(remainder_months, @month, @locale)
      end
      result
    end

    # Months of 30.44 days (the average month), rounded.
    private def approximate_months(days : Int) : Int64
      (days / 30.44).round.to_i64
    end

    # YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
    TIMESTAMP_PATTERN = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z/

    private def parse_iso_to_seconds(iso_str : String) : Int64?
      m = TIMESTAMP_PATTERN.match(iso_str) || return nil
      year, month, day, hour, minute = m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i, m[5].to_i
      second = m[6]?.try(&.to_i) || 0
      return nil unless 1 <= month <= 12 && 1 <= day <= days_in_month(year, month)
      return nil if hour > 23 || minute > 59 || second > 59

      days_since_epoch(year, month, day).to_i64 * 86400 + hour * 3600 + minute * 60 + second
    end

    private def days_since_epoch(year : Int32, month : Int32, day : Int32) : Int32
      days = 0
      if year >= 2000
        (2000...year).each { |y| days += leap_year?(y) ? 366 : 365 }
      else
        (year...2000).each { |y| days -= leap_year?(y) ? 366 : 365 }
      end
      (1...month).each { |m| days += days_in_month(year, m) }
      days + day - 1
    end

    private def leap_year?(year : Int32) : Bool
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
    end

    private def days_in_month(year : Int32, month : Int32) : Int32
      case month
      when 1, 3, 5, 7, 8, 10, 12 then 31
      when 4, 6, 9, 11           then 30
      when 2                     then leap_year?(year) ? 29 : 28
      else                            31
      end
    end
  end
end

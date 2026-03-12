module SayableDuration
  class Formatter
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

    def format_duration(start_or_seconds : Int32?, end_str : String? = nil) : String?
      return nil if start_or_seconds.nil?
      total_seconds = start_or_seconds
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
      dur = format_duration_seconds(diff)
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
      dur = format_duration_seconds(diff)
      @in_future.sub("{0}", dur)
    end

    private def format_duration_seconds(total : Int32) : String
      # 0 seconds
      return @just_now if total == 0

      # 1-59 seconds
      return SayableDuration.resolve_unit(total, @second, @locale) if total < 60

      total_minutes = total // 60
      remainder_seconds = total % 60

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

      total_hours = total // 3600
      remainder_minutes = (total % 3600) // 60

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

      total_days = total // 86400
      remainder_hours = (total % 86400) // 3600

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

      # Approximate months (30.44 days average)
      total_months = (total_days / 30.44).round.to_i

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

    private def parse_iso_to_seconds(iso_str : String) : Int32?
      return nil if iso_str.empty?

      parts = iso_str.split('T')
      return nil if parts.size != 2

      date_part = parts[0]
      time_part = parts[1]

      dp = date_part.split('-')
      return nil if dp.size != 3
      year = dp[0].to_i? || return nil
      month = dp[1].to_i? || return nil
      day = dp[2].to_i? || return nil

      time_str = time_part
      time_str = time_str.split('+')[0] if time_str.includes?('+')
      time_str = time_str.split('Z')[0] if time_str.includes?('Z')

      tp = time_str.split(':')
      hour = tp[0].to_i? || return nil
      minute = tp.size > 1 ? (tp[1].to_i? || return nil) : 0
      second = tp.size > 2 ? (tp[2].split('.')[0].to_i? || return nil) : 0

      days = days_since_epoch(year, month, day)
      (days * 86400) + (hour * 3600) + (minute * 60) + second
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
      when 4, 6, 9, 11            then 30
      when 2                       then leap_year?(year) ? 29 : 28
      else                              31
      end
    end
  end
end

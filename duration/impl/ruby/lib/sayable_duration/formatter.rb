# frozen_string_literal: true

module SayableDuration
  MAX_DURATION_MONTHS = 6000 # 500 years, the same ceiling as sayable-age

  class Formatter
    # YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
    TIMESTAMP = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})
                 (?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z/x

    def initialize(locale, compactness: :normal)
      @locale = locale

      ovr = case compactness
            when :short then locale.short
            when :compact then locale.compact
            end

      @second    = (ovr&.units && ovr.units['second'])  || locale.units['second']
      @minute    = (ovr&.units && ovr.units['minute'])  || locale.units['minute']
      @hour      = (ovr&.units && ovr.units['hour'])    || locale.units['hour']
      @day       = (ovr&.units && ovr.units['day'])     || locale.units['day']
      @week      = (ovr&.units && ovr.units['week'])    || locale.units['week']
      @month     = (ovr&.units && ovr.units['month'])   || locale.units['month']
      @year      = (ovr&.units && ovr.units['year'])    || locale.units['year']
      @half      = ovr && !ovr.half.nil?      ? ovr.half      : locale.half
      @delimiter = ovr && !ovr.delimiter.nil? ? ovr.delimiter : locale.delimiter
      @just_now  = locale.just_now
      @ago       = ovr && !ovr.ago.nil?       ? ovr.ago       : locale.ago
      @in_future = ovr && !ovr.in_future.nil? ? ovr.in_future : locale.in_future
      freeze
    end

    # Format a duration in human-friendly terms.
    #
    # @param start_or_seconds [Integer, String, nil] seconds or ISO datetime start
    # @param end_str [String, nil] ISO datetime end (required if start_or_seconds is a string)
    # @return [String, nil] formatted duration or nil
    def format_duration(start_or_seconds, end_str = nil)
      if start_or_seconds.nil?
        return nil
      end

      if start_or_seconds.is_a?(Integer)
        total_seconds = start_or_seconds
      elsif start_or_seconds.is_a?(String)
        return nil if end_str.nil?

        s = parse_iso_to_seconds(start_or_seconds)
        e = parse_iso_to_seconds(end_str)
        return nil if s.nil? || e.nil?

        total_seconds = (e - s).abs
      else
        return nil
      end

      return nil if total_seconds.negative?

      format_duration_seconds(total_seconds)
    end

    # Format elapsed time as 'X ago'.
    #
    # @param start [String, nil] ISO datetime of the past event
    # @param as_of [String, nil] ISO datetime of the reference point
    # @return [String, nil] relative time string or nil
    def format_since(start, as_of)
      return nil if start.nil? || start.empty? || as_of.nil? || as_of.empty?

      s = parse_iso_to_seconds(start)
      a = parse_iso_to_seconds(as_of)
      return nil if s.nil? || a.nil?

      diff = a - s
      return nil if diff.negative?
      return @just_now if diff.zero?

      dur = format_duration_seconds(diff)
      dur && @ago.sub('{0}', dur)
    end

    # Format time until a future event as 'in X'.
    #
    # @param target [String, nil] ISO datetime of the future event
    # @param as_of [String, nil] ISO datetime of the reference point
    # @return [String, nil] relative time string or nil
    def format_until(target, as_of)
      return nil if target.nil? || target.empty? || as_of.nil? || as_of.empty?

      t = parse_iso_to_seconds(target)
      a = parse_iso_to_seconds(as_of)
      return nil if t.nil? || a.nil?

      diff = t - a
      return nil if diff.negative?
      return @just_now if diff.zero?

      dur = format_duration_seconds(diff)
      dur && @in_future.sub('{0}', dur)
    end

    private

    def format_duration_seconds(total)
      # 0 seconds
      return @just_now if total.zero?

      # 1-59 seconds
      return SayableDuration.resolve_unit(total, @second, @locale) if total < 60

      total_minutes = total / 60
      remainder_seconds = total % 60

      # 1-4 minutes: minutes + seconds
      if total_minutes < 5
        result = SayableDuration.resolve_unit(total_minutes, @minute, @locale)
        if remainder_seconds.positive?
          result += @delimiter + SayableDuration.resolve_unit(remainder_seconds, @second, @locale)
        end
        return result
      end

      # 5-59 minutes
      return SayableDuration.resolve_unit(total_minutes, @minute, @locale) if total_minutes < 60

      total_hours = total / 3600
      remainder_minutes = (total % 3600) / 60

      # 1-5 hours: hours + minutes (with half marker)
      if total_hours <= 5
        if remainder_minutes == 30
          return SayableDuration.resolve_unit(total_hours, @hour, @locale, @half)
        end

        result = SayableDuration.resolve_unit(total_hours, @hour, @locale)
        if remainder_minutes.positive?
          result += @delimiter + SayableDuration.resolve_unit(remainder_minutes, @minute, @locale)
        end
        return result
      end

      # 6-23 hours
      return SayableDuration.resolve_unit(total_hours, @hour, @locale) if total_hours < 24

      total_days = total / 86_400
      remainder_hours = (total % 86_400) / 3600

      # 1-2 days: days + hours (with half marker)
      if total_days <= 2
        if remainder_hours == 12
          return SayableDuration.resolve_unit(total_days, @day, @locale, @half)
        end

        result = SayableDuration.resolve_unit(total_days, @day, @locale)
        if remainder_hours.positive?
          result += @delimiter + SayableDuration.resolve_unit(remainder_hours, @hour, @locale)
        end
        return result
      end

      # 3-6 days
      return SayableDuration.resolve_unit(total_days, @day, @locale) if total_days < 7

      total_weeks = total_days / 7
      remainder_days = total_days % 7

      # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
      if total_days < 30
        result = SayableDuration.resolve_unit(total_weeks, @week, @locale)
        if remainder_days.positive?
          result += @delimiter + SayableDuration.resolve_unit(remainder_days, @day, @locale)
        end
        return result
      end

      # Approximate months (30.44 days average)
      total_months = (total_days / 30.44).round
      return nil if total_months > MAX_DURATION_MONTHS

      # 1-11 months
      if total_months < 12
        total_months = 1 if total_months.zero?
        return SayableDuration.resolve_unit(total_months, @month, @locale)
      end

      # 12+ months: years + months
      total_years = total_months / 12
      remainder_months = total_months % 12
      result = SayableDuration.resolve_unit(total_years, @year, @locale)
      if remainder_months.positive?
        result += @delimiter + SayableDuration.resolve_unit(remainder_months, @month, @locale)
      end
      result
    end

    def parse_iso_to_seconds(iso_str)
      match = TIMESTAMP.match(iso_str.to_s)
      return nil if match.nil?

      year, month, day, hour, minute, second = match.captures.map(&:to_i)
      return nil unless month.between?(1, 12) && day.between?(1, days_in_month(year, month))
      return nil if hour > 23 || minute > 59 || second > 59

      days = days_since_epoch(year, month, day)
      (days * 86_400) + (hour * 3600) + (minute * 60) + second
    end

    def days_since_epoch(year, month, day)
      days = 0
      if year >= 2000
        (2000...year).each { |y| days += leap_year?(y) ? 366 : 365 }
      else
        (year...2000).each { |y| days -= leap_year?(y) ? 366 : 365 }
      end
      (1...month).each { |m| days += days_in_month(year, m) }
      days + day - 1
    end

    def leap_year?(year)
      (year % 4).zero? && (year % 100 != 0) || (year % 400).zero?
    end

    def days_in_month(year, month)
      return 31 if [1, 3, 5, 7, 8, 10, 12].include?(month)
      return 30 if [4, 6, 9, 11].include?(month)

      leap_year?(year) ? 29 : 28
    end
  end
end

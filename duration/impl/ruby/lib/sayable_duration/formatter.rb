# frozen_string_literal: true

module SayableDuration
  MAX_DURATION_MONTHS = 6000 # 500 years, the same ceiling as sayable-age

  class Formatter
    def initialize(locale, compactness: :normal)
      @locale = locale

      ovr = case compactness
            when :short then locale.short
            when :compact then locale.compact
            end

      @second, @minute, @hour, @day, @week, @month, @year =
        %w[second minute hour day week month year].map { |name| unit_forms(ovr, name) }
      @half      = override_or(ovr, :half)
      @delimiter = override_or(ovr, :delimiter)
      @just_now  = locale.just_now
      @ago       = override_or(ovr, :ago)
      @in_future = override_or(ovr, :in_future)
      freeze
    end

    # Format a duration in human-friendly terms.
    #
    # @param start_or_seconds [Integer, String, nil] seconds or ISO datetime start
    # @param end_str [String, nil] ISO datetime end (required if start_or_seconds is a string)
    # @return [String, nil] formatted duration or nil
    def format_duration(start_or_seconds, end_str = nil)
      return nil if start_or_seconds.nil?

      if start_or_seconds.is_a?(Integer)
        total_seconds = start_or_seconds
      elsif start_or_seconds.is_a?(String)
        return nil if end_str.nil?

        s = Timestamp.to_seconds(start_or_seconds)
        e = Timestamp.to_seconds(end_str)
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

      s = Timestamp.to_seconds(start)
      a = Timestamp.to_seconds(as_of)
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

      t = Timestamp.to_seconds(target)
      a = Timestamp.to_seconds(as_of)
      return nil if t.nil? || a.nil?

      diff = t - a
      return nil if diff.negative?
      return @just_now if diff.zero?

      dur = format_duration_seconds(diff)
      dur && @in_future.sub('{0}', dur)
    end

    private

    def unit_forms(ovr, name)
      (ovr&.units && ovr.units[name]) || @locale.units[name]
    end

    def override_or(ovr, field)
      override = ovr&.public_send(field)
      override.nil? ? @locale.public_send(field) : override
    end

    def format_duration_seconds(total)
      return @just_now if total.zero?
      return SayableDuration.resolve_unit(total, @second, @locale) if total < 60

      total_minutes = total / 60
      return format_minutes(total_minutes, total % 60) if total_minutes < 60

      total_hours = total / 3600
      return format_hours(total_hours, (total % 3600) / 60) if total_hours < 24

      format_days_and_beyond(total / 86_400, (total % 86_400) / 3600)
    end

    # A major unit, plus the minor one when there is a remainder.
    def with_remainder(count, unit, remainder, remainder_unit)
      result = SayableDuration.resolve_unit(count, unit, @locale)
      return result unless remainder.positive?

      result + @delimiter + SayableDuration.resolve_unit(remainder, remainder_unit, @locale)
    end

    # 1-4 minutes: minutes + seconds. 5-59 minutes: minutes only.
    def format_minutes(total_minutes, remainder_seconds)
      return with_remainder(total_minutes, @minute, remainder_seconds, @second) if total_minutes < 5

      SayableDuration.resolve_unit(total_minutes, @minute, @locale)
    end

    # 1-5 hours: hours + minutes (with half marker). 6-23 hours: hours only.
    def format_hours(total_hours, remainder_minutes)
      return SayableDuration.resolve_unit(total_hours, @hour, @locale) if total_hours > 5
      return SayableDuration.resolve_unit(total_hours, @hour, @locale, @half) if remainder_minutes == 30

      with_remainder(total_hours, @hour, remainder_minutes, @minute)
    end

    def format_days_and_beyond(total_days, remainder_hours)
      # 1-2 days: days + hours (with half marker)
      if total_days <= 2
        return SayableDuration.resolve_unit(total_days, @day, @locale, @half) if remainder_hours == 12

        return with_remainder(total_days, @day, remainder_hours, @hour)
      end

      # 3-6 days
      return SayableDuration.resolve_unit(total_days, @day, @locale) if total_days < 7

      # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
      return with_remainder(total_days / 7, @week, total_days % 7, @day) if total_days < 30

      format_months_and_years((total_days / 30.44).round)
    end

    # Approximate months (30.44 days average)
    def format_months_and_years(total_months)
      return nil if total_months > MAX_DURATION_MONTHS

      return SayableDuration.resolve_unit([total_months, 1].max, @month, @locale) if total_months < 12

      with_remainder(total_months / 12, @year, total_months % 12, @month)
    end
  end
end

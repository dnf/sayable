# frozen_string_literal: true

require 'date'

module SayableAge
  MAX_AGE_MONTHS = 6000

  STRICT_DATE = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/

  def self.days_in_month(year, month)
    return 30 if [4, 6, 9, 11].include?(month)
    return 31 unless month == 2

    leap = (year % 4).zero? && (!(year % 100).zero? || (year % 400).zero?)
    leap ? 29 : 28
  end

  # Parse exactly YYYY-MM-DD naming a real calendar day into [y, m, d], else nil.
  def self.parse_date(str)
    match = STRICT_DATE.match(str)
    return nil if match.nil?

    year, month, day = match.captures.map(&:to_i)
    return nil unless month.between?(1, 12) && day.between?(1, days_in_month(year, month))

    [year, month, day]
  end

  # Proleptic Gregorian day number, so old dates follow the same calendar as recent ones.
  def self.julian_day(year, month, day)
    a = (14 - month) / 12
    y = year + 4800 - a
    m = month + (12 * a) - 3
    day + (((153 * m) + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32_045
  end

  class Formatter
    def initialize(locale, compactness: :normal)
      @locale = locale

      ovr = case compactness
            when :short then locale.short
            when :compact then locale.compact
            end

      @day       = (ovr&.units && ovr.units['day'])   || locale.units['day']
      @week      = (ovr&.units && ovr.units['week'])  || locale.units['week']
      @month     = (ovr&.units && ovr.units['month']) || locale.units['month']
      @year      = (ovr&.units && ovr.units['year'])  || locale.units['year']
      @half      = ovr && !ovr.half.nil?      ? ovr.half      : locale.half
      @delimiter = ovr && !ovr.delimiter.nil? ? ovr.delimiter : locale.delimiter
      @just_born = ovr && !ovr.just_born.nil? ? ovr.just_born : locale.just_born
      freeze
    end

    # Human-friendly age string.
    #
    # @param date_of_birth [String, nil] YYYY-MM-DD date string
    # @param as_of [String, nil] YYYY-MM-DD reference date (defaults to today)
    # @return [String, nil] formatted age or nil
    def format_age(date_of_birth, as_of = nil)
      age = parse_age(date_of_birth, as_of)
      return nil if age.nil?

      months, diff_days = age

      # Tier 1: 0 days
      return @just_born if diff_days.zero?

      # Tier 1b: 1-6 days
      return SayableAge.resolve_unit(diff_days, @day, @locale) if diff_days < 7

      # Tier 2: weeks + days until 3 calendar months
      if months < 3
        weeks = diff_days / 7
        days = diff_days % 7
        result = SayableAge.resolve_unit(weeks, @week, @locale)
        result += @delimiter + SayableAge.resolve_unit(days, @day, @locale) if days.positive?
        return result
      end

      # Tier 3: 3-23 months
      return SayableAge.resolve_unit(months, @month, @locale) if months < 24

      # Tier 4: 24-35 months -> years + months
      if months < 36
        years = months / 12
        rem = months % 12
        return SayableAge.resolve_unit(years, @year, @locale) if rem.zero?

        return SayableAge.resolve_unit(years, @year, @locale) +
               @delimiter +
               SayableAge.resolve_unit(rem, @month, @locale)
      end

      # Tier 5: 3-6 years -> years with half marker
      if months < 84
        years = months / 12
        rem = months % 12
        return SayableAge.resolve_unit(years, @year, @locale, @half) if rem >= 6

        return SayableAge.resolve_unit(years, @year, @locale)
      end

      # Tier 6: 7+ years
      years = months / 12
      SayableAge.resolve_unit(years, @year, @locale)
    end

    # Developmental stage label based on age.
    #
    # @param date_of_birth [String, nil] YYYY-MM-DD date string
    # @param as_of [String, nil] YYYY-MM-DD reference date (defaults to today)
    # @param gender [String, nil] 'm' or 'f' for gendered locales
    # @return [String, nil] stage label or nil
    def format_stage(date_of_birth, as_of = nil, gender: nil)
      age = parse_age(date_of_birth, as_of)
      return nil if age.nil?

      months = age[0]
      key = stage_key(months)
      SayableAge.resolve_stage(@locale.stages[key], gender)
    end

    private

    def parse_age(date_of_birth, as_of)
      return nil if date_of_birth.nil? || date_of_birth.empty?

      dob = SayableAge.parse_date(date_of_birth)
      ref = as_of && !as_of.empty? ? SayableAge.parse_date(as_of) : today_parts
      return nil if dob.nil? || ref.nil?

      dob_y, dob_m, dob_d = dob
      ref_y, ref_m, ref_d = ref
      diff_days = SayableAge.julian_day(ref_y, ref_m, ref_d) - SayableAge.julian_day(dob_y, dob_m, dob_d)
      return nil if diff_days.negative?

      # Calendar months: clamp birthday to last day of reference month so that
      # e.g. a child born Jan 31 turns 1 month old on Feb 28 (or 29 in a leap year).
      clamped_birthday = [dob_d, SayableAge.days_in_month(ref_y, ref_m)].min
      months = ((ref_y - dob_y) * 12) + (ref_m - dob_m)
      months -= 1 if ref_d < clamped_birthday
      return nil if months > MAX_AGE_MONTHS

      [months, diff_days]
    end

    def today_parts
      today = Date.today
      [today.year, today.month, today.day]
    end

    def stage_key(months)
      if months < 2 then :newborn
      elsif months < 12 then :infant
      elsif months < 36 then :toddler
      elsif months < 156 then :child
      elsif months < 216 then :teenager
      else :adult
      end
    end
  end
end

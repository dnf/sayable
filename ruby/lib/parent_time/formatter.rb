# frozen_string_literal: true

require 'date'

module ParentTime
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
      return ParentTime.resolve_unit(diff_days, @day, @locale) if diff_days < 7

      # Tier 2: weeks + days until 3 calendar months
      if months < 3
        weeks = diff_days / 7
        days = diff_days % 7
        result = ParentTime.resolve_unit(weeks, @week, @locale)
        result += @delimiter + ParentTime.resolve_unit(days, @day, @locale) if days.positive?
        return result
      end

      # Tier 3: 3-23 months
      return ParentTime.resolve_unit(months, @month, @locale) if months < 24

      # Tier 4: 24-35 months -> years + months
      if months < 36
        years = months / 12
        rem = months % 12
        return ParentTime.resolve_unit(years, @year, @locale) if rem.zero?

        return ParentTime.resolve_unit(years, @year, @locale) +
               @delimiter +
               ParentTime.resolve_unit(rem, @month, @locale)
      end

      # Tier 5: 3-6 years -> years with half marker
      if months < 84
        years = months / 12
        rem = months % 12
        return ParentTime.resolve_unit(years, @year, @locale, @half) if rem >= 6

        return ParentTime.resolve_unit(years, @year, @locale)
      end

      # Tier 6: 7+ years
      years = months / 12
      ParentTime.resolve_unit(years, @year, @locale)
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
      ParentTime.resolve_stage(@locale.stages[key], gender)
    end

    private

    def parse_age(date_of_birth, as_of)
      return nil if date_of_birth.nil? || date_of_birth.empty?

      dob_y, dob_m, dob_d = date_of_birth.split('-').map(&:to_i)

      if as_of && !as_of.empty?
        ref_y, ref_m, ref_d = as_of.split('-').map(&:to_i)
      else
        today = Date.today
        ref_y = today.year
        ref_m = today.month
        ref_d = today.day
      end

      dob_date = Date.new(dob_y, dob_m, dob_d)
      ref_date = Date.new(ref_y, ref_m, ref_d)
      diff_days = (ref_date - dob_date).to_i
      return nil if diff_days.negative?

      # Calendar months: clamp birthday to last day of reference month so that
      # e.g. a child born Jan 31 turns 1 month old on Feb 28 (or 29 in a leap year).
      last_day = Date.new(ref_y, ref_m, -1).day
      clamped_birthday = [dob_d, last_day].min
      months = ((ref_y - dob_y) * 12) + (ref_m - dob_m)
      months -= 1 if ref_d < clamped_birthday

      [months, diff_days]
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

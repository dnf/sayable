module SayableAge
  MAX_AGE_MONTHS = 6000

  class Formatter
    @day : UnitForms
    @week : UnitForms
    @month : UnitForms
    @year : UnitForms
    @half : String
    @delimiter : String
    @just_born : String

    def initialize(@locale : AgeLocale, compactness : Symbol = :normal)
      ovr = case compactness
            when :short   then @locale.short
            when :compact then @locale.compact
            else               nil
            end

      @day = (ovr.try(&.units).try(&.["day"]?)) || @locale.units["day"]
      @week = (ovr.try(&.units).try(&.["week"]?)) || @locale.units["week"]
      @month = (ovr.try(&.units).try(&.["month"]?)) || @locale.units["month"]
      @year = (ovr.try(&.units).try(&.["year"]?)) || @locale.units["year"]
      @half = ovr.try(&.half) || @locale.half
      @delimiter = ovr.try(&.delimiter) || @locale.delimiter
      @just_born = ovr.try(&.just_born) || @locale.just_born
    end

    def format_age(date_of_birth : String?, as_of : String? = nil) : String?
      age = parse_age(date_of_birth, as_of)
      return nil if age.nil?

      months, diff_days = age

      # Tier 1: 0 days
      return @just_born if diff_days == 0

      # Tier 1b: 1-6 days
      return SayableAge.resolve_unit(diff_days, @day, @locale) if diff_days < 7

      # Tier 2: weeks + days until 3 calendar months
      if months < 3
        weeks = diff_days // 7
        days = diff_days % 7
        result = SayableAge.resolve_unit(weeks, @week, @locale)
        result += @delimiter + SayableAge.resolve_unit(days, @day, @locale) if days > 0
        return result
      end

      # Tier 3: 3-23 months
      return SayableAge.resolve_unit(months, @month, @locale) if months < 24

      # Tier 4: 24-35 months -> years + months
      if months < 36
        years = months // 12
        rem = months % 12
        return SayableAge.resolve_unit(years, @year, @locale) if rem == 0
        return SayableAge.resolve_unit(years, @year, @locale) +
               @delimiter +
               SayableAge.resolve_unit(rem, @month, @locale)
      end

      # Tier 5: 3-6 years -> years with half marker
      if months < 84
        years = months // 12
        rem = months % 12
        return SayableAge.resolve_unit(years, @year, @locale, @half) if rem >= 6
        return SayableAge.resolve_unit(years, @year, @locale)
      end

      # Tier 6: 7+ years
      years = months // 12
      SayableAge.resolve_unit(years, @year, @locale)
    end

    def format_stage(date_of_birth : String?, as_of : String? = nil, gender : String? = nil) : String?
      age = parse_age(date_of_birth, as_of)
      return nil if age.nil?

      months = age[0]
      key = stage_key(months)
      @locale.stages[key].resolve(gender)
    end

    private def parse_age(date_of_birth : String?, as_of : String?) : Tuple(Int32, Int32)?
      return nil if date_of_birth.nil? || date_of_birth.empty?

      dob_parts = date_of_birth.split('-')
      return nil if dob_parts.size != 3

      dob_y = dob_parts[0].to_i? || return nil
      dob_m = dob_parts[1].to_i? || return nil
      dob_d = dob_parts[2].to_i? || return nil

      if as_of && !as_of.empty?
        ref_parts = as_of.split('-')
        return nil if ref_parts.size != 3
        ref_y = ref_parts[0].to_i? || return nil
        ref_m = ref_parts[1].to_i? || return nil
        ref_d = ref_parts[2].to_i? || return nil
      else
        now = Time.local
        ref_y = now.year
        ref_m = now.month
        ref_d = now.day
      end

      dob_jdn = to_jdn(dob_y, dob_m, dob_d)
      ref_jdn = to_jdn(ref_y, ref_m, ref_d)
      diff_days = ref_jdn - dob_jdn
      return nil if diff_days < 0

      # Calendar months
      last_day = days_in_month(ref_y, ref_m)
      clamped_birthday = {dob_d, last_day}.min
      months = ((ref_y - dob_y) * 12) + (ref_m - dob_m)
      months -= 1 if ref_d < clamped_birthday
      return nil if months > MAX_AGE_MONTHS

      {months, diff_days}
    end

    private def stage_key(months : Int32) : String
      if months < 2
        "newborn"
      elsif months < 12
        "infant"
      elsif months < 36
        "toddler"
      elsif months < 156
        "child"
      elsif months < 216
        "teenager"
      else
        "adult"
      end
    end

    private def to_jdn(year : Int32, month : Int32, day : Int32) : Int32
      a = (14 - month) // 12
      y = year + 4800 - a
      m = month + 12 * a - 3
      day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045
    end

    private def days_in_month(year : Int32, month : Int32) : Int32
      case month
      when 1, 3, 5, 7, 8, 10, 12 then 31
      when 4, 6, 9, 11            then 30
      when 2
        (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28
      else
        31
      end
    end
  end
end

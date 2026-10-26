# frozen_string_literal: true

module SayableDate
  # Strict calendar parsing and day arithmetic.
  module Calendar
    # YYYY-MM-DD, optionally followed by T and a time (which is not read).
    ISO_DATE = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T|\z)/

    def self.parse_date(str)
      return nil if str.nil?

      match = ISO_DATE.match(str)
      return nil if match.nil?

      year, month, day = match.captures.map(&:to_i)
      return nil unless month.between?(1, 12) && day.between?(1, days_in_month(year, month))

      [year, month, day]
    end

    def self.days_in_month(year, month)
      return 30 if [4, 6, 9, 11].include?(month)
      return 31 unless month == 2

      leap = (year % 4).zero? && (!(year % 100).zero? || (year % 400).zero?)
      leap ? 29 : 28
    end

    def self.to_jdn(year, month, day)
      a = (14 - month) / 12
      y = year + 4800 - a
      m = month + (12 * a) - 3
      day + (((153 * m) + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32_045
    end

    def self.weekday(year, month, day)
      jdn = to_jdn(year, month, day)
      (jdn + 1) % 7
    end
  end
end

# frozen_string_literal: true

module SayableDuration
  # Strict ISO timestamp parsing into seconds since 2000-01-01T00:00.
  module Timestamp
    # YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
    TIMESTAMP = /\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})
                 (?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z/x

    def self.to_seconds(iso_str)
      match = TIMESTAMP.match(iso_str.to_s)
      return nil if match.nil?

      year, month, day, hour, minute, second = match.captures.map(&:to_i)
      return nil unless month.between?(1, 12) && day.between?(1, days_in_month(year, month))
      return nil if hour > 23 || minute > 59 || second > 59

      days = days_since_epoch(year, month, day)
      (days * 86_400) + (hour * 3600) + (minute * 60) + second
    end

    def self.days_since_epoch(year, month, day)
      days = 0
      if year >= 2000
        (2000...year).each { |y| days += leap_year?(y) ? 366 : 365 }
      else
        (year...2000).each { |y| days -= leap_year?(y) ? 366 : 365 }
      end
      (1...month).each { |m| days += days_in_month(year, m) }
      days + day - 1
    end

    def self.leap_year?(year)
      ((year % 4).zero? && (year % 100 != 0)) || (year % 400).zero?
    end

    def self.days_in_month(year, month)
      return 31 if [1, 3, 5, 7, 8, 10, 12].include?(month)
      return 30 if [4, 6, 9, 11].include?(month)

      leap_year?(year) ? 29 : 28
    end
  end
end

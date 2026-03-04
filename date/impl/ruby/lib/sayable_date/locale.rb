# frozen_string_literal: true

module SayableDate
  # Frozen struct for compactness overrides.
  # Fields are nil when not overridden.
  CompactnessOverride = Struct.new(
    :months, :months_in_date, :weekdays,
    :day_format, :day_format_exceptions,
    :date_pattern, :date_pattern_with_year,
    :today, :tomorrow, :yesterday,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:months] ||= nil
      kwargs[:months_in_date] ||= nil
      kwargs[:weekdays] ||= nil
      kwargs[:day_format] ||= nil
      kwargs[:day_format_exceptions] ||= nil
      kwargs[:date_pattern] ||= nil
      kwargs[:date_pattern_with_year] ||= nil
      kwargs[:today] ||= nil
      kwargs[:tomorrow] ||= nil
      kwargs[:yesterday] ||= nil
      super
      freeze
    end
  end

  # Frozen struct for locale definitions.
  DateLocale = Struct.new(
    :code, :months, :weekdays,
    :day_format, :day_format_exceptions,
    :date_pattern, :date_pattern_with_year,
    :today, :tomorrow, :yesterday,
    :day_after_tomorrow, :day_before_yesterday,
    :this_weekday, :next_weekday, :last_weekday,
    :months_in_date,
    :short, :compact,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:day_format_exceptions] ||= {}
      kwargs[:day_after_tomorrow] ||= nil
      kwargs[:day_before_yesterday] ||= nil
      kwargs[:this_weekday] ||= nil
      kwargs[:next_weekday] ||= nil
      kwargs[:last_weekday] ||= nil
      kwargs[:months_in_date] ||= nil
      kwargs[:short] ||= nil
      kwargs[:compact] ||= nil
      super
      freeze
    end
  end
end

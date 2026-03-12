module SayableDate
  # Compactness override for short/compact modes.
  struct CompactnessOverride
    getter months : Array(String)?
    getter months_in_date : Array(String)?
    getter weekdays : Array(String)?
    getter day_format : String?
    getter day_format_exceptions : Hash(String, String)?
    getter date_pattern : String?
    getter date_pattern_with_year : String?
    getter today : String?
    getter tomorrow : String?
    getter yesterday : String?

    def initialize(*, @months = nil, @months_in_date = nil, @weekdays = nil,
                   @day_format = nil, @day_format_exceptions = nil,
                   @date_pattern = nil, @date_pattern_with_year = nil,
                   @today = nil, @tomorrow = nil, @yesterday = nil)
    end
  end

  # Locale definition for date formatting.
  struct DateLocale
    getter code : String
    getter months : Array(String)
    getter weekdays : Array(String)
    getter day_format : String
    getter day_format_exceptions : Hash(String, String)
    getter date_pattern : String
    getter date_pattern_with_year : String
    getter today : String
    getter tomorrow : String
    getter yesterday : String
    getter day_after_tomorrow : String?
    getter day_before_yesterday : String?
    getter this_weekday : String?
    getter next_weekday : String?
    getter last_weekday : String?
    getter months_in_date : Array(String)?
    getter short : CompactnessOverride?
    getter compact : CompactnessOverride?

    def initialize(*, @code, @months, @weekdays, @day_format,
                   @day_format_exceptions = {} of String => String,
                   @date_pattern, @date_pattern_with_year,
                   @today, @tomorrow, @yesterday,
                   @day_after_tomorrow = nil, @day_before_yesterday = nil,
                   @this_weekday = nil, @next_weekday = nil, @last_weekday = nil,
                   @months_in_date = nil, @short = nil, @compact = nil)
    end
  end
end

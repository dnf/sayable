module SayableTime
  # Clock reading configuration for natural language time.
  struct ClockConfig
    getter hours : Array(String)
    getter midnight : String
    getter noon : String
    getter patterns : Hash(Int32, String)

    def initialize(*, @hours, @midnight, @noon, @patterns)
    end
  end

  # Digital clock display configuration for short/compact modes.
  struct ShortClockConfig
    getter use24h : Bool
    getter format : String
    getter am_pm : Array(String)?

    def initialize(*, @use24h, @format, @am_pm = nil)
    end
  end

  # Compactness override for short/compact modes.
  struct CompactnessOverride
    getter clock : ShortClockConfig?

    def initialize(*, @clock = nil)
    end
  end

  # Locale definition for clock time formatting.
  struct TimeLocale
    getter code : String
    getter clock : ClockConfig
    getter short : CompactnessOverride?
    getter compact : CompactnessOverride?

    def initialize(*, @code, @clock, @short = nil, @compact = nil)
    end
  end
end

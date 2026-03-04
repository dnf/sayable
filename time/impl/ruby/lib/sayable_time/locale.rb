# frozen_string_literal: true

module SayableTime
  # Clock reading configuration for natural language time.
  ClockConfig = Struct.new(
    :hours, :midnight, :noon, :patterns,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      super
      freeze
    end
  end

  # Digital clock display configuration for short/compact modes.
  ShortClockConfig = Struct.new(
    :use24h, :format, :am_pm,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:am_pm] ||= nil
      super
      freeze
    end
  end

  # Optional overrides for short/compact display modes.
  CompactnessOverride = Struct.new(
    :clock,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:clock] ||= nil
      super
      freeze
    end
  end

  # Locale definition for clock time formatting.
  TimeLocale = Struct.new(
    :code, :clock, :short, :compact,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:short] ||= nil
      kwargs[:compact] ||= nil
      super
      freeze
    end
  end
end

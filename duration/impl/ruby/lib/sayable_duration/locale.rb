# frozen_string_literal: true

module SayableDuration
  # Frozen struct for locale definitions.
  DurationLocale = Struct.new(
    :code, :plural, :units, :half, :delimiter, :just_now, :ago, :in_future,
    :short, :compact, :format_number, :format_unit,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:short] ||= nil
      kwargs[:compact] ||= nil
      kwargs[:format_number] ||= nil
      kwargs[:format_unit] ||= nil
      super
      freeze
    end
  end

  # Frozen struct for compactness overrides.
  # Fields are nil when not overridden. Empty string "" is a valid override (not "unset").
  CompactnessOverride = Struct.new(
    :units, :half, :delimiter, :ago, :in_future,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:units] ||= nil
      kwargs[:half] ||= nil
      kwargs[:delimiter] ||= nil
      kwargs[:ago] ||= nil
      kwargs[:in_future] ||= nil
      super
      freeze
    end
  end

  # Resolve a unit count to its display string using locale rules.
  #
  # The `half` template supports two placeholders:
  # - `{n}` modifies the formatted number before unit substitution
  # - `{0}` wraps the fully resolved expression after unit substitution
  #
  # When a half marker is applied, the plural category is forced to
  # "other" (e.g. "1½ hours" not "1½ hour").
  def self.resolve_unit(count, unit_forms, locale, half = '')
    base_n = if locale.format_number
               locale.format_number.call(count)
             else
               count.to_s
             end

    n = if !half.empty? && half.include?('{n}')
          half.sub('{n}', base_n)
        else
          base_n
        end

    template = if unit_forms.is_a?(String)
                 unit_forms
               else
                 # Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
                 cat = half.empty? ? locale.plural.call(count) : :other
                 unit_forms[cat] || unit_forms[:other]
               end

    result = template.sub('{n}', n)

    result = locale.format_unit.call(count, result) if locale.format_unit

    result = half.sub('{0}', result) if !half.empty? && half.include?('{0}')

    result
  end
end

# frozen_string_literal: true

require 'date'

module SayableAge
  # Frozen struct for locale definitions.
  AgeLocale = Struct.new(
    :code, :plural, :units, :half, :delimiter, :just_born, :stages,
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
    :units, :half, :delimiter, :just_born,
    keyword_init: true
  ) do
    def initialize(**kwargs)
      kwargs[:units] ||= nil
      kwargs[:half] ||= nil
      kwargs[:delimiter] ||= nil
      kwargs[:just_born] ||= nil
      super
      freeze
    end
  end

  # Resolve a stage label, which may be a plain String or a Hash { m: "...", f: "..." }.
  def self.resolve_stage(label, gender = nil)
    return label if label.is_a?(String)

    gender == 'f' ? label[:f] : label[:m]
  end

  # Resolve a unit count to its display string using locale rules.
  #
  # The `half` template supports two placeholders:
  # - `{n}` modifies the formatted number before unit substitution
  # - `{0}` wraps the fully resolved expression after unit substitution
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
                 cat = locale.plural.call(count)
                 unit_forms[cat] || unit_forms[:other]
               end

    result = template.sub('{n}', n)

    result = locale.format_unit.call(count, result) if locale.format_unit

    result = half.sub('{0}', result) if !half.empty? && half.include?('{0}')

    result
  end
end

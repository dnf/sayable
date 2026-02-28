# frozen_string_literal: true

module ParentTime
  module Locales
    TR = AgeLocale.new(
      code: 'tr',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: "{n} g\u00FCn", other: "{n} g\u00FCn" },
        'week' => { one: '{n} hafta', other: '{n} hafta' },
        'month' => { one: '{n} ay', other: '{n} ay' },
        'year' => { one: "{n} ya\u015F", other: "{n} ya\u015F" }
      },
      half: "{n} bu\u00E7uk",
      delimiter: ', ',
      just_born: "Yeni do\u011Fan",
      stages: {
        newborn: "Yeni do\u011Fan",
        infant: 'Bebek',
        toddler: "K\u00FC\u00E7\u00FCk \u00E7ocuk",
        child: "\u00C7ocuk",
        teenager: 'Ergen',
        adult: "Yeti\u015Fkin"
      }
    )
  end
end

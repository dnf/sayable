# frozen_string_literal: true

module ParentTime
  module Locales
    SV = AgeLocale.new(
      code: 'sv',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} dag', other: '{n} dagar' },
        'week' => { one: '{n} vecka', other: '{n} veckor' },
        'month' => { one: '{n} månad', other: '{n} månader' },
        'year' => { one: '{n} år', other: '{n} år' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Nyfödd',
      stages: {
        newborn: 'Nyfödd',
        infant: 'Spädbarn',
        toddler: 'Litet barn',
        child: 'Barn',
        teenager: 'Tonåring',
        adult: 'Vuxen'
      }
    )
  end
end

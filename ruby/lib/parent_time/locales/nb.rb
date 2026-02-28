# frozen_string_literal: true

module ParentTime
  module Locales
    NB = AgeLocale.new(
      code: 'nb',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} dag', other: '{n} dager' },
        'week' => { one: '{n} uke', other: '{n} uker' },
        'month' => { one: '{n} måned', other: '{n} måneder' },
        'year' => { one: '{n} år', other: '{n} år' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Nyfødt',
      stages: {
        newborn: 'Nyfødt',
        infant: 'Spedbarn',
        toddler: 'Småbarn',
        child: 'Barn',
        teenager: 'Tenåring',
        adult: 'Voksen'
      }
    )
  end
end

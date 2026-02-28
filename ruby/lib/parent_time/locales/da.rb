# frozen_string_literal: true

module ParentTime
  module Locales
    DA = AgeLocale.new(
      code: 'da',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} dag', other: '{n} dage' },
        'week' => { one: '{n} uge', other: '{n} uger' },
        'month' => { one: '{n} måned', other: '{n} måneder' },
        'year' => { one: '{n} år', other: '{n} år' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Nyfødt',
      stages: {
        newborn: 'Nyfødt',
        infant: 'Spædbarn',
        toddler: 'Småbarn',
        child: 'Barn',
        teenager: 'Teenager',
        adult: 'Voksen'
      }
    )
  end
end

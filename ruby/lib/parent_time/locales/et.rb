# frozen_string_literal: true

module ParentTime
  module Locales
    ET = AgeLocale.new(
      code: 'et',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} päev', other: '{n} päeva' },
        'week' => { one: '{n} nädal', other: '{n} nädalat' },
        'month' => { one: '{n} kuu', other: '{n} kuud' },
        'year' => { one: '{n} aasta', other: '{n} aastat' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Vastsündinu',
      stages: {
        newborn: 'Vastsündinu',
        infant: 'Imik',
        toddler: 'Väikelaps',
        child: 'Laps',
        teenager: 'Teismeline',
        adult: 'Täiskasvanu'
      }
    )
  end
end

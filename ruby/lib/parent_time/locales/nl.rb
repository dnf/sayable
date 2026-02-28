# frozen_string_literal: true

module ParentTime
  module Locales
    NL = AgeLocale.new(
      code: 'nl',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} dag', other: '{n} dagen' },
        'week' => { one: '{n} week', other: '{n} weken' },
        'month' => { one: '{n} maand', other: '{n} maanden' },
        'year' => { one: '{n} jaar', other: '{n} jaar' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Pasgeboren',
      stages: {
        newborn: 'Pasgeborene',
        infant: 'Baby',
        toddler: 'Peuter',
        child: 'Kind',
        teenager: 'Tiener',
        adult: 'Volwassene'
      }
    )
  end
end

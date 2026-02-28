# frozen_string_literal: true

module ParentTime
  module Locales
    DE = AgeLocale.new(
      code: 'de',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} Tag', other: '{n} Tage' },
        'week' => { one: '{n} Woche', other: '{n} Wochen' },
        'month' => { one: '{n} Monat', other: '{n} Monate' },
        'year' => { one: '{n} Jahr', other: '{n} Jahre' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Neugeboren',
      stages: {
        newborn: 'Neugeborenes',
        infant: "S\u00E4ugling",
        toddler: 'Kleinkind',
        child: 'Kind',
        teenager: 'Teenager',
        adult: 'Erwachsener'
      }
    )
  end
end

# frozen_string_literal: true

module ParentTime
  module Locales
    ES = AgeLocale.new(
      code: 'es',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: "{n} d\u00EDa", other: "{n} d\u00EDas" },
        'week' => { one: '{n} semana', other: '{n} semanas' },
        'month' => { one: '{n} mes', other: '{n} meses' },
        'year' => { one: "{n} a\u00F1o", other: "{n} a\u00F1os" }
      },
      half: '{n} y medio',
      delimiter: ', ',
      just_born: "Reci\u00E9n nacido",
      stages: {
        newborn: "Reci\u00E9n nacido",
        infant: "Beb\u00E9",
        toddler: "Ni\u00F1o peque\u00F1o",
        child: "Ni\u00F1o",
        teenager: 'Adolescente',
        adult: 'Adulto'
      }
    )
  end
end

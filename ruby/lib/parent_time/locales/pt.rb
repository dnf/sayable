# frozen_string_literal: true

module ParentTime
  module Locales
    PT = AgeLocale.new(
      code: 'pt',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: '{n} dia', other: '{n} dias' },
        'week' => { one: '{n} semana', other: '{n} semanas' },
        'month' => { one: "{n} m\u00EAs", other: '{n} meses' },
        'year' => { one: '{n} ano', other: '{n} anos' }
      },
      half: '{0} e meio',
      delimiter: ', ',
      just_born: "Rec\u00E9m-nascido",
      stages: {
        newborn: "Rec\u00E9m-nascido",
        infant: "Beb\u00EA",
        toddler: "Crian\u00E7a pequena",
        child: "Crian\u00E7a",
        teenager: 'Adolescente',
        adult: 'Adulto'
      }
    )
  end
end

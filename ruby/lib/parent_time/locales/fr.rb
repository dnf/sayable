# frozen_string_literal: true

module ParentTime
  module Locales
    FR = AgeLocale.new(
      code: 'fr',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: '{n} jour', other: '{n} jours' },
        'week' => { one: '{n} semaine', other: '{n} semaines' },
        'month' => '{n} mois',
        'year' => { one: '{n} an', other: '{n} ans' }
      },
      half: '{0} et demi',
      delimiter: ', ',
      just_born: "Nouveau-n\u00E9",
      stages: {
        newborn: { m: 'Nouveau-né', f: 'Nouveau-née' },
        infant: 'Nourrisson',
        toddler: 'Tout-petit',
        child: 'Enfant',
        teenager: { m: 'Adolescent', f: 'Adolescente' },
        adult: 'Adulte'
      }
    )
  end
end

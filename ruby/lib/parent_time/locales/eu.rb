# frozen_string_literal: true

module ParentTime
  module Locales
    EU = AgeLocale.new(
      code: 'eu',
      plural: ->(_n) { :other },
      units: {
        'day' => '{n} egun',
        'week' => '{n} aste',
        'month' => '{n} hilabete',
        'year' => '{n} urte'
      },
      half: '{0} eta erdi',
      delimiter: ', ',
      just_born: 'Jaioberria',
      stages: {
        newborn: 'Jaioberria',
        infant: 'Haurra',
        toddler: 'Haur txikia',
        child: 'Umea',
        teenager: 'Nerabea',
        adult: 'Heldua'
      }
    )
  end
end

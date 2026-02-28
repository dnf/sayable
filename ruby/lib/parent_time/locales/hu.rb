# frozen_string_literal: true

module ParentTime
  module Locales
    HU = AgeLocale.new(
      code: 'hu',
      plural: ->(_n) { :other },
      units: {
        'day' => '{n} nap',
        'week' => '{n} hét',
        'month' => '{n} hónap',
        'year' => '{n} év'
      },
      half: '{n} és fél',
      delimiter: ', ',
      just_born: 'Újszülött',
      stages: {
        newborn: 'Újszülött',
        infant: 'Csecsemő',
        toddler: 'Kisgyermek',
        child: 'Gyermek',
        teenager: 'Tinédzser',
        adult: 'Felnőtt'
      }
    )
  end
end

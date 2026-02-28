# frozen_string_literal: true

module ParentTime
  module Locales
    GA = AgeLocale.new(
      code: 'ga',
      plural: ->(_n) { :other },
      units: {
        'day' => '{n} lá',
        'week' => '{n} seachtain',
        'month' => '{n} mí',
        'year' => '{n} bliain'
      },
      half: '{0} go leith',
      delimiter: ', ',
      just_born: 'Nuabheirthe',
      stages: {
        newborn: 'Nuabheirthe',
        infant: 'Naíonán',
        toddler: 'Lapadán',
        child: 'Páiste',
        teenager: 'Déagóir',
        adult: 'Duine fásta'
      }
    )
  end
end

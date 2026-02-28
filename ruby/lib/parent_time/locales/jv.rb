# frozen_string_literal: true

module ParentTime
  module Locales
    JV = AgeLocale.new(
      code: 'jv',
      plural: ->(_n) { :other },
      units: {
        'day' => '{n} dina',
        'week' => '{n} minggu',
        'month' => '{n} wulan',
        'year' => '{n} taun'
      },
      half: '{0} setengah',
      delimiter: ', ',
      just_born: 'Bayi anyar',
      stages: {
        newborn: 'Bayi anyar',
        infant: 'Bayi',
        toddler: 'Balita',
        child: 'Bocah',
        teenager: 'Remaja',
        adult: 'Diwasa'
      }
    )
  end
end

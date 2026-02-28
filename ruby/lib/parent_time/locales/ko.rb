# frozen_string_literal: true

module ParentTime
  module Locales
    KO = AgeLocale.new(
      code: 'ko',
      plural: ->(_n) { :other },
      units: {
        'day' => "{n}\uC77C",
        'week' => "{n}\uC8FC",
        'month' => "{n}\uAC1C\uC6D4",
        'year' => "{n}\uC0B4"
      },
      half: "{0} \uBC18",
      delimiter: ' ',
      just_born: "\uC2E0\uC0DD\uC544",
      stages: {
        newborn: "\uC2E0\uC0DD\uC544",
        infant: "\uC601\uC544",
        toddler: "\uC720\uC544",
        child: "\uC544\uB3D9",
        teenager: "\uCCAD\uC18C\uB144",
        adult: "\uC131\uC778"
      }
    )
  end
end

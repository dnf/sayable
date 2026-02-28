# frozen_string_literal: true

module ParentTime
  module Locales
    JA = AgeLocale.new(
      code: 'ja',
      plural: ->(_n) { :other },
      units: {
        'day' => "{n}\u65E5",
        'week' => "{n}\u9031",
        'month' => "{n}\u30F6\u6708",
        'year' => "{n}\u6B73"
      },
      half: "{0}\u534A",
      delimiter: '',
      just_born: "\u65B0\u751F\u5150",
      stages: {
        newborn: "\u65B0\u751F\u5150",
        infant: "\u4E73\u5150",
        toddler: "\u5E7C\u5150",
        child: "\u5150\u7AE5",
        teenager: "\u9752\u5C11\u5E74",
        adult: "\u6210\u4EBA"
      }
    )
  end
end

# frozen_string_literal: true

module ParentTime
  module Locales
    ZH = AgeLocale.new(
      code: 'zh',
      plural: ->(_n) { :other },
      units: {
        'day' => "{n}\u5929",
        'week' => "{n}\u5468",
        'month' => "{n}\u4E2A\u6708",
        'year' => "{n}\u5C81"
      },
      half: "{0}\u534A",
      delimiter: '',
      just_born: "\u65B0\u751F\u513F",
      stages: {
        newborn: "\u65B0\u751F\u513F",
        infant: "\u5A74\u513F",
        toddler: "\u5E7C\u513F",
        child: "\u513F\u7AE5",
        teenager: "\u9752\u5C11\u5E74",
        adult: "\u6210\u4EBA"
      }
    )
  end
end

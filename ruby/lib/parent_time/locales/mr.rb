# frozen_string_literal: true

module ParentTime
  module Locales
    MR = AgeLocale.new(
      code: 'mr',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: "{n} \u0926\u093F\u0935\u0938", other: "{n} \u0926\u093F\u0935\u0938" },
        'week' => { one: "{n} \u0906\u0920\u0935\u0921\u093E", other: "{n} \u0906\u0920\u0935\u0921\u0947" },
        'month' => { one: "{n} \u092E\u0939\u093F\u0928\u093E", other: "{n} \u092E\u0939\u093F\u0928\u0947" },
        'year' => { one: "{n} \u0935\u0930\u094D\u0937", other: "{n} \u0935\u0930\u094D\u0937\u0947" }
      },
      half: "\u0938\u093E\u0921\u0947 {n}",
      delimiter: ', ',
      just_born: "\u0928\u0935\u091C\u093E\u0924",
      stages: {
        newborn: "\u0928\u0935\u091C\u093E\u0924",
        infant: "\u0905\u0930\u094D\u092D\u0915",
        toddler: "\u092C\u093E\u0933",
        child: "\u092E\u0942\u0932",
        teenager: "\u0915\u093F\u0936\u094B\u0930",
        adult: "\u092A\u094D\u0930\u094C\u0922"
      }
    )
  end
end

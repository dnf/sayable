# frozen_string_literal: true

module ParentTime
  module Locales
    HI = AgeLocale.new(
      code: 'hi',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: "{n} \u0926\u093F\u0928", other: "{n} \u0926\u093F\u0928" },
        'week' => { one: "{n} \u0938\u092A\u094D\u0924\u093E\u0939", other: "{n} \u0938\u092A\u094D\u0924\u093E\u0939" },
        'month' => { one: "{n} \u092E\u0939\u0940\u0928\u093E", other: "{n} \u092E\u0939\u0940\u0928\u0947" },
        'year' => { one: "{n} \u0938\u093E\u0932", other: "{n} \u0938\u093E\u0932" }
      },
      half: "\u0938\u093E\u0922\u093C\u0947 {n}",
      delimiter: ', ',
      just_born: "\u0928\u0935\u091C\u093E\u0924",
      stages: {
        newborn: "\u0928\u0935\u091C\u093E\u0924",
        infant: "\u0936\u093F\u0936\u0941",
        toddler: { m: 'छोटा बच्चा', f: 'छोटी बच्ची' },
        child: { m: 'बच्चा', f: 'बच्ची' },
        teenager: { m: 'किशोर', f: 'किशोरी' },
        adult: "\u0935\u092F\u0938\u094D\u0915"
      }
    )
  end
end

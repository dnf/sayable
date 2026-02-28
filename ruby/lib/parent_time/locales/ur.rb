# frozen_string_literal: true

module ParentTime
  module Locales
    UR = AgeLocale.new(
      code: 'ur',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: "{n} \u062F\u0646", other: "{n} \u062F\u0646" },
        'week' => { one: "{n} \u06C1\u0641\u062A\u06C1", other: "{n} \u06C1\u0641\u062A\u06D2" },
        'month' => { one: "{n} \u0645\u06C1\u06CC\u0646\u06C1", other: "{n} \u0645\u06C1\u06CC\u0646\u06D2" },
        'year' => { one: "{n} \u0633\u0627\u0644", other: "{n} \u0633\u0627\u0644" }
      },
      half: "\u0633\u0627\u0691\u06BE\u06D2 {n}",
      delimiter: "\u060C ",
      just_born: "\u0646\u0648\u0645\u0648\u0644\u0648\u062F",
      stages: {
        newborn: "\u0646\u0648\u0645\u0648\u0644\u0648\u062F",
        infant: "\u0634\u06CC\u0631\u062E\u0648\u0627\u0631",
        toddler: "\u0686\u06BE\u0648\u0679\u0627 \u0628\u0686\u06C1",
        child: "\u0628\u0686\u06C1",
        teenager: "\u0646\u0648\u062C\u0648\u0627\u0646",
        adult: "\u0628\u0627\u0644\u063A"
      }
    )
  end
end

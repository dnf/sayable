# frozen_string_literal: true

module ParentTime
  module Locales
    PA = AgeLocale.new(
      code: 'pa',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: "{n} \u0A26\u0A3F\u0A28", other: "{n} \u0A26\u0A3F\u0A28" },
        'week' => { one: "{n} \u0A39\u0A2B\u0A3C\u0A24\u0A3E", other: "{n} \u0A39\u0A2B\u0A3C\u0A24\u0A47" },
        'month' => { one: "{n} \u0A2E\u0A39\u0A40\u0A28\u0A3E", other: "{n} \u0A2E\u0A39\u0A40\u0A28\u0A47" },
        'year' => { one: "{n} \u0A38\u0A3E\u0A32", other: "{n} \u0A38\u0A3E\u0A32" }
      },
      half: "\u0A38\u0A3E\u0A22\u0A47 {n}",
      delimiter: ', ',
      just_born: "\u0A28\u0A35\u0A1C\u0A70\u0A2E\u0A3F\u0A06",
      stages: {
        newborn: "\u0A28\u0A35\u0A1C\u0A70\u0A2E\u0A3F\u0A06",
        infant: "\u0A36\u0A3F\u0A36\u0A42",
        toddler: "\u0A1B\u0A4B\u0A1F\u0A3E \u0A2C\u0A71\u0A1A\u0A3E",
        child: "\u0A2C\u0A71\u0A1A\u0A3E",
        teenager: "\u0A15\u0A3F\u0A36\u0A4B\u0A30",
        adult: "\u0A2C\u0A3E\u0A32\u0A17"
      }
    )
  end
end

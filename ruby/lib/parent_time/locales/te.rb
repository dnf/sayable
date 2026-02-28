# frozen_string_literal: true

module ParentTime
  module Locales
    TE = AgeLocale.new(
      code: 'te',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: "{n} \u0C30\u0C4B\u0C1C\u0C41", other: "{n} \u0C30\u0C4B\u0C1C\u0C41\u0C32\u0C41" },
        'week' => { one: "{n} \u0C35\u0C3E\u0C30\u0C02", other: "{n} \u0C35\u0C3E\u0C30\u0C3E\u0C32\u0C41" },
        'month' => { one: "{n} \u0C28\u0C46\u0C32", other: "{n} \u0C28\u0C46\u0C32\u0C32\u0C41" },
        'year' => { one: "{n} \u0C38\u0C02\u0C35\u0C24\u0C4D\u0C38\u0C30\u0C02", other: "{n} \u0C38\u0C02\u0C35\u0C24\u0C4D\u0C38\u0C30\u0C3E\u0C32\u0C41" }
      },
      half: "{0}\u0C28\u0C4D\u0C28\u0C30",
      delimiter: ', ',
      just_born: "\u0C28\u0C35\u0C1C\u0C3E\u0C24 \u0C36\u0C3F\u0C36\u0C41\u0C35\u0C41",
      stages: {
        newborn: "\u0C28\u0C35\u0C1C\u0C3E\u0C24 \u0C36\u0C3F\u0C36\u0C41\u0C35\u0C41",
        infant: "\u0C36\u0C3F\u0C36\u0C41\u0C35\u0C41",
        toddler: "\u0C1A\u0C3F\u0C28\u0C4D\u0C28 \u0C2A\u0C3F\u0C32\u0C4D\u0C32\u0C35\u0C3E\u0C21\u0C41",
        child: "\u0C2A\u0C3F\u0C32\u0C4D\u0C32\u0C35\u0C3E\u0C21\u0C41",
        teenager: "\u0C15\u0C4C\u0C2E\u0C3E\u0C30\u0C26\u0C36",
        adult: "\u0C35\u0C2F\u0C4B\u0C1C\u0C28\u0C41\u0C21\u0C41"
      }
    )
  end
end

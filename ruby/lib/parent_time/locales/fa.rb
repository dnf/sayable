# frozen_string_literal: true

module ParentTime
  module Locales
    FA = AgeLocale.new(
      code: 'fa',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: "{n} \u0631\u0648\u0632", other: "{n} \u0631\u0648\u0632" },
        'week' => { one: "{n} \u0647\u0641\u062A\u0647", other: "{n} \u0647\u0641\u062A\u0647" },
        'month' => { one: "{n} \u0645\u0627\u0647", other: "{n} \u0645\u0627\u0647" },
        'year' => { one: "{n} \u0633\u0627\u0644", other: "{n} \u0633\u0627\u0644" }
      },
      half: "{0} \u0648 \u0646\u06CC\u0645",
      delimiter: " \u0648 ",
      just_born: "\u0646\u0648\u0632\u0627\u062F",
      stages: {
        newborn: "\u0646\u0648\u0632\u0627\u062F",
        infant: "\u0634\u06CC\u0631\u062E\u0648\u0627\u0631",
        toddler: "\u0646\u0648\u067E\u0627",
        child: "\u06A9\u0648\u062F\u06A9",
        teenager: "\u0646\u0648\u062C\u0648\u0627\u0646",
        adult: "\u0628\u0632\u0631\u06AF\u0633\u0627\u0644"
      }
    )
  end
end

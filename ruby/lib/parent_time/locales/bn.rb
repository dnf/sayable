# frozen_string_literal: true

module ParentTime
  module Locales
    BN = AgeLocale.new(
      code: 'bn',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: "{n} \u09A6\u09BF\u09A8", other: "{n} \u09A6\u09BF\u09A8" },
        'week' => { one: "{n} \u09B8\u09AA\u09CD\u09A4\u09BE\u09B9", other: "{n} \u09B8\u09AA\u09CD\u09A4\u09BE\u09B9" },
        'month' => { one: "{n} \u09AE\u09BE\u09B8", other: "{n} \u09AE\u09BE\u09B8" },
        'year' => { one: "{n} \u09AC\u099B\u09B0", other: "{n} \u09AC\u099B\u09B0" }
      },
      half: "\u09B8\u09BE\u09DC\u09C7 {n}",
      delimiter: ', ',
      just_born: "\u09A8\u09AC\u099C\u09BE\u09A4\u0995",
      stages: {
        newborn: "\u09A8\u09AC\u099C\u09BE\u09A4\u0995",
        infant: "\u09B6\u09BF\u09B6\u09C1",
        toddler: "\u099B\u09CB\u099F \u09B6\u09BF\u09B6\u09C1",
        child: "\u09B6\u09BF\u09B6\u09C1",
        teenager: { m: 'কিশোর', f: 'কিশোরী' },
        adult: "\u09AA\u09CD\u09B0\u09BE\u09AA\u09CD\u09A4\u09AC\u09AF\u09BC\u09B8\u09CD\u0995"
      }
    )
  end
end

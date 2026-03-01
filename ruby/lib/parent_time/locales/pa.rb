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
        newborn: { m: 'ਨਵਜੰਮਿਆ', f: 'ਨਵਜੰਮੀ' },
        infant: 'ਸ਼ਿਸ਼ੂ',
        toddler: { m: 'ਛੋਟਾ ਬੱਚਾ', f: 'ਛੋਟੀ ਬੱਚੀ' },
        child: { m: 'ਬੱਚਾ', f: 'ਬੱਚੀ' },
        teenager: { m: 'ਕਿਸ਼ੋਰ', f: 'ਕਿਸ਼ੋਰੀ' },
        adult: "\u0A2C\u0A3E\u0A32\u0A17"
      }
    )
  end
end

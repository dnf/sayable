# frozen_string_literal: true

module ParentTime
  module Locales
    GU = AgeLocale.new(
      code: 'gu',
      plural: ->(n) { [0, 1].include?(n) ? :one : :other },
      units: {
        'day' => { one: "{n} \u0AA6\u0ABF\u0AB5\u0AB8", other: "{n} \u0AA6\u0ABF\u0AB5\u0AB8" },
        'week' => { one: "{n} \u0A85\u0AA0\u0AB5\u0ABE\u0AA1\u0ABF\u0AAF\u0AC1\u0A82", other: "{n} \u0A85\u0AA0\u0AB5\u0ABE\u0AA1\u0ABF\u0AAF\u0ABE" },
        'month' => { one: "{n} \u0AAE\u0AB9\u0ABF\u0AA8\u0ACB", other: "{n} \u0AAE\u0AB9\u0ABF\u0AA8\u0ABE" },
        'year' => { one: "{n} \u0AB5\u0AB0\u0ACD\u0AB7", other: "{n} \u0AB5\u0AB0\u0ACD\u0AB7" }
      },
      half: "\u0AB8\u0ABE\u0AA1\u0AC7 {n}",
      delimiter: ', ',
      just_born: "\u0AA8\u0AB5\u0A9C\u0ABE\u0AA4",
      stages: {
        newborn: "\u0AA8\u0AB5\u0A9C\u0ABE\u0AA4",
        infant: "\u0AB6\u0ABF\u0AB6\u0AC1",
        toddler: "\u0AA8\u0ABE\u0AA8\u0AC1\u0A82 \u0AAC\u0ABE\u0AB3\u0A95",
        child: "\u0AAC\u0ABE\u0AB3\u0A95",
        teenager: "\u0A95\u0ABF\u0AB6\u0ACB\u0AB0",
        adult: "\u0AAA\u0AC1\u0A96\u0ACD\u0AA4"
      }
    )
  end
end

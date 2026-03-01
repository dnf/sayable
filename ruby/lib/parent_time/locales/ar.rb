# frozen_string_literal: true

module ParentTime
  module Locales
    AR = AgeLocale.new(
      code: 'ar',
      plural: lambda { |n|
        case n
        when 0 then :zero
        when 1 then :one
        when 2 then :two
        else
          mod100 = n % 100
          if mod100.between?(3, 10) then :few
          elsif mod100.between?(11, 99) then :many
          else :other
          end
        end
      },
      units: {
        'day' => { zero: "{n} \u064A\u0648\u0645", one: "\u064A\u0648\u0645", two: "\u064A\u0648\u0645\u0627\u0646", few: "{n} \u0623\u064A\u0627\u0645", many: "{n} \u064A\u0648\u0645\u064B\u0627", other: "{n} \u064A\u0648\u0645" },
        'week' => { zero: "{n} \u0623\u0633\u0628\u0648\u0639", one: "\u0623\u0633\u0628\u0648\u0639", two: "\u0623\u0633\u0628\u0648\u0639\u0627\u0646", few: "{n} \u0623\u0633\u0627\u0628\u064A\u0639", many: "{n} \u0623\u0633\u0628\u0648\u0639\u064B\u0627", other: "{n} \u0623\u0633\u0628\u0648\u0639" },
        'month' => { zero: "{n} \u0634\u0647\u0631", one: "\u0634\u0647\u0631", two: "\u0634\u0647\u0631\u0627\u0646", few: "{n} \u0623\u0634\u0647\u0631", many: "{n} \u0634\u0647\u0631\u064B\u0627", other: "{n} \u0634\u0647\u0631" },
        'year' => { zero: "{n} \u0633\u0646\u0629", one: "\u0633\u0646\u0629", two: "\u0633\u0646\u062A\u0627\u0646", few: "{n} \u0633\u0646\u0648\u0627\u062A", many: "{n} \u0633\u0646\u0629", other: "{n} \u0633\u0646\u0629" }
      },
      half: "{0} \u0648\u0646\u0635\u0641",
      delimiter: " \u0648",
      just_born: "\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629",
      stages: {
        newborn: { m: 'حديث الولادة', f: 'حديثة الولادة' },
        infant: { m: 'رضيع', f: 'رضيعة' },
        toddler: { m: 'طفل صغير', f: 'طفلة صغيرة' },
        child: { m: 'طفل', f: 'طفلة' },
        teenager: { m: 'مراهق', f: 'مراهقة' },
        adult: { m: 'بالغ', f: 'بالغة' }
      }
    )
  end
end

# frozen_string_literal: true

module ParentTime
  module Locales
    LV = AgeLocale.new(
      code: 'lv',
      plural: lambda { |n|
        if n.zero? then :zero
        elsif n % 10 == 1 && n % 100 != 11 then :one
        else :other
        end
      },
      units: {
        'day' => { zero: '{n} dienu', one: '{n} diena', other: '{n} dienas' },
        'week' => { zero: '{n} nedēļu', one: '{n} nedēļa', other: '{n} nedēļas' },
        'month' => { zero: '{n} mēnešu', one: '{n} mēnesis', other: '{n} mēneši' },
        'year' => { zero: '{n} gadu', one: '{n} gads', other: '{n} gadi' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Jaundzimušais',
      stages: {
        newborn: 'Jaundzimušais',
        infant: 'Zīdainis',
        toddler: 'Mazulis',
        child: 'Bērns',
        teenager: 'Pusaudzis',
        adult: 'Pieaugušais'
      }
    )
  end
end

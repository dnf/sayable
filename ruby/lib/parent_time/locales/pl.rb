# frozen_string_literal: true

module ParentTime
  module Locales
    PL = AgeLocale.new(
      code: 'pl',
      plural: lambda { |n|
        if n == 1 then :one
        elsif (n % 10).between?(2, 4) && !(n % 100).between?(12, 14) then :few
        else :many
        end
      },
      units: {
        'day' => { one: '{n} dzień', few: '{n} dni', many: '{n} dni', other: '{n} dni' },
        'week' => { one: '{n} tydzień', few: '{n} tygodnie', many: '{n} tygodni', other: '{n} tygodni' },
        'month' => { one: '{n} miesiąc', few: '{n} miesiące', many: '{n} miesięcy', other: '{n} miesięcy' },
        'year' => { one: '{n} rok', few: '{n} lata', many: '{n} lat', other: '{n} lat' }
      },
      half: '{n} i pół',
      delimiter: ', ',
      just_born: 'Noworodek',
      stages: {
        newborn: 'Noworodek',
        infant: 'Niemowlę',
        toddler: 'Maluch',
        child: 'Dziecko',
        teenager: 'Nastolatek',
        adult: 'Dorosły'
      }
    )
  end
end

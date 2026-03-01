# frozen_string_literal: true

module ParentTime
  module Locales
    CS = AgeLocale.new(
      code: 'cs',
      plural: lambda { |n|
        if n == 1 then :one
        elsif n.between?(2, 4) then :few
        else :other
        end
      },
      units: {
        'day' => { one: '{n} den', few: '{n} dny', other: '{n} dní' },
        'week' => { one: '{n} týden', few: '{n} týdny', other: '{n} týdnů' },
        'month' => { one: '{n} měsíc', few: '{n} měsíce', other: '{n} měsíců' },
        'year' => { one: '{n} rok', few: '{n} roky', other: '{n} let' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Novorozenec',
      stages: {
        newborn: 'Novorozenec',
        infant: 'Kojenec',
        toddler: 'Batole',
        child: 'Dítě',
        teenager: 'Teenager',
        adult: { m: 'Dospělý', f: 'Dospělá' }
      }
    )
  end
end

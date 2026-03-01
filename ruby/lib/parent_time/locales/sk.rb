# frozen_string_literal: true

module ParentTime
  module Locales
    SK = AgeLocale.new(
      code: 'sk',
      plural: lambda { |n|
        if n == 1 then :one
        elsif n.between?(2, 4) then :few
        else :other
        end
      },
      units: {
        'day' => { one: '{n} deň', few: '{n} dni', other: '{n} dní' },
        'week' => { one: '{n} týždeň', few: '{n} týždne', other: '{n} týždňov' },
        'month' => { one: '{n} mesiac', few: '{n} mesiace', other: '{n} mesiacov' },
        'year' => { one: '{n} rok', few: '{n} roky', other: '{n} rokov' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Novorodenec',
      stages: {
        newborn: 'Novorodenec',
        infant: 'Dojča',
        toddler: 'Batoľa',
        child: 'Dieťa',
        teenager: 'Tínedžer',
        adult: { m: 'Dospelý', f: 'Dospelá' }
      }
    )
  end
end

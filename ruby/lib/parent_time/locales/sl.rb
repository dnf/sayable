# frozen_string_literal: true

module ParentTime
  module Locales
    SL = AgeLocale.new(
      code: 'sl',
      plural: lambda { |n|
        mod100 = n % 100
        if mod100 == 1 then :one
        elsif mod100 == 2 then :two
        elsif [3, 4].include?(mod100) then :few
        else :other
        end
      },
      units: {
        'day' => { one: '{n} dan', two: '{n} dneva', few: '{n} dni', other: '{n} dni' },
        'week' => { one: '{n} teden', two: '{n} tedna', few: '{n} tedne', other: '{n} tednov' },
        'month' => { one: '{n} mesec', two: '{n} meseca', few: '{n} mesece', other: '{n} mesecev' },
        'year' => { one: '{n} leto', two: '{n} leti', few: '{n} leta', other: '{n} let' }
      },
      half: '{0} in pol',
      delimiter: ', ',
      just_born: 'Novorojenček',
      stages: {
        newborn: 'Novorojenček',
        infant: 'Dojenček',
        toddler: 'Malček',
        child: 'Otrok',
        teenager: 'Najstnik',
        adult: 'Odrasel'
      }
    )
  end
end

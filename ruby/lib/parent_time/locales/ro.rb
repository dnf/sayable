# frozen_string_literal: true

module ParentTime
  module Locales
    RO = AgeLocale.new(
      code: 'ro',
      plural: lambda { |n|
        if n == 1 then :one
        elsif n.zero? || (n % 100.between?(1, 19)) then :few
        else :other
        end
      },
      units: {
        'day' => { one: '{n} zi', few: '{n} zile', other: '{n} de zile' },
        'week' => { one: '{n} săptămână', few: '{n} săptămâni', other: '{n} de săptămâni' },
        'month' => { one: '{n} lună', few: '{n} luni', other: '{n} de luni' },
        'year' => { one: '{n} an', few: '{n} ani', other: '{n} de ani' }
      },
      half: '{0} și jumătate',
      delimiter: ', ',
      just_born: 'Nou-născut',
      stages: {
        newborn: { m: 'Nou-născut', f: 'Nou-născută' },
        infant: 'Sugar',
        toddler: 'Copil mic',
        child: 'Copil',
        teenager: { m: 'Adolescent', f: 'Adolescentă' },
        adult: { m: 'Adult', f: 'Adultă' }
      }
    )
  end
end

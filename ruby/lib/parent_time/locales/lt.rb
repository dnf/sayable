# frozen_string_literal: true

module ParentTime
  module Locales
    LT = AgeLocale.new(
      code: 'lt',
      plural: lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10.between?(2, 9) && (mod100 < 12 || mod100 > 19) then :few
        else :other
        end
      },
      units: {
        'day' => { one: '{n} diena', few: '{n} dienos', other: '{n} dienų' },
        'week' => { one: '{n} savaitė', few: '{n} savaitės', other: '{n} savaičių' },
        'month' => { one: '{n} mėnuo', few: '{n} mėnesiai', other: '{n} mėnesių' },
        'year' => { one: '{n} metai', few: '{n} metai', other: '{n} metų' }
      },
      half: "{n}\u00BD",
      delimiter: ', ',
      just_born: 'Naujagimis',
      stages: {
        newborn: { m: 'Naujagimis', f: 'Naujagimė' },
        infant: { m: 'Kūdikis', f: 'Kūdikė' },
        toddler: { m: 'Mažylis', f: 'Mažylė' },
        child: 'Vaikas',
        teenager: { m: 'Paauglys', f: 'Paauglė' },
        adult: { m: 'Suaugęs', f: 'Suaugusi' }
      }
    )
  end
end

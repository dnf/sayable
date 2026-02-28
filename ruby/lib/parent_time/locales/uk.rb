# frozen_string_literal: true

module ParentTime
  module Locales
    UK = AgeLocale.new(
      code: 'uk',
      plural: lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10.between?(2, 4) && (mod100 < 12 || mod100 > 14) then :few
        else :many
        end
      },
      units: {
        'day' => { one: '{n} день', few: '{n} дні', many: '{n} днів', other: '{n} днів' },
        'week' => { one: '{n} тиждень', few: '{n} тижні', many: '{n} тижнів', other: '{n} тижнів' },
        'month' => { one: '{n} місяць', few: '{n} місяці', many: '{n} місяців', other: '{n} місяців' },
        'year' => { one: '{n} рік', few: '{n} роки', many: '{n} років', other: '{n} років' }
      },
      half: '{n} з половиною',
      delimiter: ', ',
      just_born: 'Новонароджений',
      stages: {
        newborn: 'Новонароджений',
        infant: 'Немовля',
        toddler: 'Малюк',
        child: 'Дитина',
        teenager: 'Підліток',
        adult: 'Дорослий'
      }
    )
  end
end

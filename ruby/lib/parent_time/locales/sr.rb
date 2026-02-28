# frozen_string_literal: true

module ParentTime
  module Locales
    SR = AgeLocale.new(
      code: 'sr',
      plural: lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10.between?(2, 4) && (mod100 < 12 || mod100 > 14) then :few
        else :many
        end
      },
      units: {
        'day' => { one: '{n} дан', few: '{n} дана', many: '{n} дана', other: '{n} дана' },
        'week' => { one: '{n} недеља', few: '{n} недеље', many: '{n} недеља', other: '{n} недеља' },
        'month' => { one: '{n} месец', few: '{n} месеца', many: '{n} месеци', other: '{n} месеци' },
        'year' => { one: '{n} година', few: '{n} године', many: '{n} година', other: '{n} година' }
      },
      half: '{0} и по',
      delimiter: ', ',
      just_born: 'Новорођенче',
      stages: {
        newborn: 'Новорођенче',
        infant: 'Одојче',
        toddler: 'Мало дете',
        child: 'Дете',
        teenager: 'Тинејџер',
        adult: 'Одрасла особа'
      }
    )
  end
end

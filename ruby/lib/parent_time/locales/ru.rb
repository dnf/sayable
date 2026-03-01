# frozen_string_literal: true

module ParentTime
  module Locales
    RU = AgeLocale.new(
      code: 'ru',
      plural: lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10.between?(2, 4) && (mod100 < 12 || mod100 > 14) then :few
        else :many
        end
      },
      units: {
        'day' => { one: "{n} \u0434\u0435\u043D\u044C", few: "{n} \u0434\u043D\u044F", many: "{n} \u0434\u043D\u0435\u0439", other: "{n} \u0434\u043D\u0435\u0439" },
        'week' => { one: "{n} \u043D\u0435\u0434\u0435\u043B\u044F", few: "{n} \u043D\u0435\u0434\u0435\u043B\u0438", many: "{n} \u043D\u0435\u0434\u0435\u043B\u044C", other: "{n} \u043D\u0435\u0434\u0435\u043B\u044C" },
        'month' => { one: "{n} \u043C\u0435\u0441\u044F\u0446", few: "{n} \u043C\u0435\u0441\u044F\u0446\u0430", many: "{n} \u043C\u0435\u0441\u044F\u0446\u0435\u0432", other: "{n} \u043C\u0435\u0441\u044F\u0446\u0435\u0432" },
        'year' => { one: "{n} \u0433\u043E\u0434", few: "{n} \u0433\u043E\u0434\u0430", many: "{n} \u043B\u0435\u0442", other: "{n} \u043B\u0435\u0442" }
      },
      half: "{n} \u0441 \u043F\u043E\u043B\u043E\u0432\u0438\u043D\u043E\u0439",
      delimiter: ', ',
      just_born: "\u041D\u043E\u0432\u043E\u0440\u043E\u0436\u0434\u0451\u043D\u043D\u044B\u0439",
      stages: {
        newborn: { m: 'Новорождённый', f: 'Новорождённая' },
        infant: 'Младенец',
        toddler: { m: 'Малыш', f: 'Малышка' },
        child: 'Ребёнок',
        teenager: 'Подросток',
        adult: { m: 'Взрослый', f: 'Взрослая' }
      }
    )
  end
end

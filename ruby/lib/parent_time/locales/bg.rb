# frozen_string_literal: true

module ParentTime
  module Locales
    BG = AgeLocale.new(
      code: 'bg',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} ден', other: '{n} дни' },
        'week' => { one: '{n} седмица', other: '{n} седмици' },
        'month' => { one: '{n} месец', other: '{n} месеца' },
        'year' => { one: '{n} година', other: '{n} години' }
      },
      half: '{0} и половина',
      delimiter: ', ',
      just_born: 'Новородено',
      stages: {
        newborn: 'Новородено',
        infant: 'Бебе',
        toddler: 'Малко дете',
        child: 'Дете',
        teenager: 'Тийнейджър',
        adult: { m: 'Възрастен', f: 'Възрастна' }
      }
    )
  end
end

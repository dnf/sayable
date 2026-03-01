# frozen_string_literal: true

module ParentTime
  module Locales
    CA = AgeLocale.new(
      code: 'ca',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} dia', other: '{n} dies' },
        'week' => { one: '{n} setmana', other: '{n} setmanes' },
        'month' => { one: '{n} mes', other: '{n} mesos' },
        'year' => { one: '{n} any', other: '{n} anys' }
      },
      half: '{n} i mig',
      delimiter: ', ',
      just_born: 'Nounat',
      stages: {
        newborn: { m: 'Nounat', f: 'Nounada' },
        infant: 'Nadó',
        toddler: 'Infant',
        child: 'Criatura',
        teenager: 'Adolescent',
        adult: { m: 'Adult', f: 'Adulta' }
      }
    )
  end
end

# frozen_string_literal: true

module ParentTime
  module Locales
    EL = AgeLocale.new(
      code: 'el',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} μέρα', other: '{n} μέρες' },
        'week' => { one: '{n} εβδομάδα', other: '{n} εβδομάδες' },
        'month' => { one: '{n} μήνας', other: '{n} μήνες' },
        'year' => { one: '{n} χρόνος', other: '{n} χρόνια' }
      },
      half: '{0} και μισό',
      delimiter: ', ',
      just_born: 'Νεογέννητο',
      stages: {
        newborn: 'Νεογέννητο',
        infant: 'Βρέφος',
        toddler: 'Νήπιο',
        child: 'Παιδί',
        teenager: { m: 'Έφηβος', f: 'Έφηβη' },
        adult: { m: 'Ενήλικας', f: 'Ενήλικη' }
      }
    )
  end
end

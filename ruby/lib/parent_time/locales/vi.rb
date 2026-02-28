# frozen_string_literal: true

module ParentTime
  module Locales
    VI = AgeLocale.new(
      code: 'vi',
      plural: ->(_n) { :other },
      units: {
        'day' => "{n} ng\u00E0y",
        'week' => "{n} tu\u1EA7n",
        'month' => "{n} th\u00E1ng",
        'year' => "{n} tu\u1ED5i"
      },
      half: "{0} r\u01B0\u1EE1i",
      delimiter: ', ',
      just_born: "S\u01A1 sinh",
      stages: {
        newborn: "S\u01A1 sinh",
        infant: "Tr\u1EBB s\u01A1 sinh",
        toddler: "Tr\u1EBB m\u1EDBi bi\u1EBFt \u0111i",
        child: "Tr\u1EBB em",
        teenager: "Thi\u1EBFu ni\u00EAn",
        adult: "Ng\u01B0\u1EDDi l\u1EDBn"
      }
    )
  end
end

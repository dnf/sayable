# frozen_string_literal: true

module ParentTime
  module Locales
    TH = AgeLocale.new(
      code: 'th',
      plural: ->(_n) { :other },
      units: {
        'day' => "{n} \u0E27\u0E31\u0E19",
        'week' => "{n} \u0E2A\u0E31\u0E1B\u0E14\u0E32\u0E2B\u0E4C",
        'month' => "{n} \u0E40\u0E14\u0E37\u0E2D\u0E19",
        'year' => "{n} \u0E1B\u0E35"
      },
      half: "{0}\u0E04\u0E23\u0E36\u0E48\u0E07",
      delimiter: ' ',
      just_born: "\u0E41\u0E23\u0E01\u0E40\u0E01\u0E34\u0E14",
      stages: {
        newborn: "\u0E41\u0E23\u0E01\u0E40\u0E01\u0E34\u0E14",
        infant: "\u0E17\u0E32\u0E23\u0E01",
        toddler: "\u0E40\u0E14\u0E47\u0E01\u0E27\u0E31\u0E22\u0E40\u0E15\u0E32\u0E30\u0E41\u0E15\u0E30",
        child: "\u0E40\u0E14\u0E47\u0E01",
        teenager: "\u0E27\u0E31\u0E22\u0E23\u0E38\u0E48\u0E19",
        adult: "\u0E1C\u0E39\u0E49\u0E43\u0E2B\u0E0D\u0E48"
      }
    )
  end
end

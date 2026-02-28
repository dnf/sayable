# frozen_string_literal: true

module ParentTime
  module Locales
    TA = AgeLocale.new(
      code: 'ta',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: "{n} \u0BA8\u0BBE\u0BB3\u0BCD", other: "{n} \u0BA8\u0BBE\u0B9F\u0BCD\u0B95\u0BB3\u0BCD" },
        'week' => { one: "{n} \u0BB5\u0BBE\u0BB0\u0BAE\u0BCD", other: "{n} \u0BB5\u0BBE\u0BB0\u0B99\u0BCD\u0B95\u0BB3\u0BCD" },
        'month' => { one: "{n} \u0BAE\u0BBE\u0BA4\u0BAE\u0BCD", other: "{n} \u0BAE\u0BBE\u0BA4\u0B99\u0BCD\u0B95\u0BB3\u0BCD" },
        'year' => { one: "{n} \u0BB5\u0BAF\u0BA4\u0BC1", other: "{n} \u0BB5\u0BAF\u0BA4\u0BC1" }
      },
      half: "{0}\u0BB0\u0BC8",
      delimiter: ', ',
      just_born: "\u0BAA\u0BBF\u0BB1\u0BA8\u0BCD\u0BA4 \u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
      stages: {
        newborn: "\u0BAA\u0BBF\u0BB1\u0BA8\u0BCD\u0BA4 \u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
        infant: "\u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
        toddler: "\u0B9A\u0BBF\u0BB1\u0BC1 \u0B95\u0BC1\u0BB4\u0BA8\u0BCD\u0BA4\u0BC8",
        child: "\u0B9A\u0BBF\u0BB1\u0BC1\u0BB5\u0BB0\u0BCD",
        teenager: "\u0B87\u0BB3\u0BAE\u0BCD\u0BAA\u0BB0\u0BC1\u0BB5\u0BAE\u0BCD",
        adult: "\u0BAA\u0BC6\u0BB0\u0BBF\u0BAF\u0BB5\u0BB0\u0BCD"
      }
    )
  end
end

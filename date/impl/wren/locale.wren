// Type definitions for sayable-date locale data.
// A locale class exposes static getters for all fields.
// See date/locales/src/*.json for the canonical schema.
//
// Required static fields:
//   code         : String
//   months       : List of 12 month names
//   weekdays     : List of 7 weekday names (Sunday=0)
//   dayFormat    : String with {n} placeholder
//   dayFormatExceptions : Map of day-number string to format, or empty map
//   datePattern  : String with {month}, {day} placeholders
//   datePatternWithYear : String with {month}, {day}, {year}, {yy} placeholders
//   today        : String
//   tomorrow     : String
//   yesterday    : String
//   dayAfterTomorrow    : String or null
//   dayBeforeYesterday  : String or null
//   thisWeekday  : String with {weekday} placeholder, or null
//   nextWeekday  : String with {weekday} placeholder, or null
//   lastWeekday  : String with {weekday} placeholder, or null
//   monthsInDate : List of 12 genitive month names, or null
//
// Optional compactness overrides:
//   short   : Map with optional keys: months, weekdays, dayFormat, dayFormatExceptions,
//             datePattern, datePatternWithYear
//   compact : Map with optional keys: datePattern, datePatternWithYear

package sayabledate

import groovy.transform.Immutable

/**
 * Holds optional overrides for short/compact display modes.
 * Null fields mean "use the base locale value."
 */
@Immutable
class CompactnessOverride {
    List<String> months
    List<String> monthsInDate
    List<String> weekdays
    String dayFormat
    Map<String, String> dayFormatExceptions
    String datePattern
    String datePatternWithYear
    String today
    String tomorrow
    String yesterday
}

package sayabledate

/**
 * Defines all locale-specific data for date formatting.
 */
class DateLocale {
    final String code
    final List<String> months
    final List<String> weekdays
    final String dayFormat
    final Map<String, String> dayFormatExceptions
    final String datePattern
    final String datePatternWithYear
    final String today
    final String tomorrow
    final String yesterday
    final String dayAfterTomorrow
    final String dayBeforeYesterday
    final String thisWeekday
    final String nextWeekday
    final String lastWeekday
    final List<String> monthsInDate
    final CompactnessOverride shortOverride
    final CompactnessOverride compactOverride

    DateLocale(
        String code,
        List<String> months,
        List<String> weekdays,
        String dayFormat,
        Map<String, String> dayFormatExceptions,
        String datePattern,
        String datePatternWithYear,
        String today,
        String tomorrow,
        String yesterday,
        String dayAfterTomorrow,
        String dayBeforeYesterday,
        String thisWeekday,
        String nextWeekday,
        String lastWeekday,
        List<String> monthsInDate,
        CompactnessOverride shortOverride,
        CompactnessOverride compactOverride
    ) {
        this.code = code
        this.months = months
        this.weekdays = weekdays
        this.dayFormat = dayFormat
        this.dayFormatExceptions = dayFormatExceptions != null ? dayFormatExceptions : [:]
        this.datePattern = datePattern ?: '{day} {month}'
        this.datePatternWithYear = datePatternWithYear ?: '{day} {month} {year}'
        this.today = today ?: 'today'
        this.tomorrow = tomorrow ?: 'tomorrow'
        this.yesterday = yesterday ?: 'yesterday'
        this.dayAfterTomorrow = dayAfterTomorrow
        this.dayBeforeYesterday = dayBeforeYesterday
        this.thisWeekday = thisWeekday
        this.nextWeekday = nextWeekday
        this.lastWeekday = lastWeekday
        this.monthsInDate = monthsInDate
        this.shortOverride = shortOverride
        this.compactOverride = compactOverride
    }
}

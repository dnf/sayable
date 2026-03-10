/// Controls the verbosity of formatted output.
enum Compactness { normal, short, compact }

/// Optional overrides for short/compact display modes.
/// Null fields mean "use the base locale value."
class CompactnessOverride {
  final List<String>? months;
  final List<String>? monthsInDate;
  final List<String>? weekdays;
  final String? dayFormat;
  final Map<String, String>? dayFormatExceptions;
  final String? datePattern;
  final String? datePatternWithYear;
  final String? today;
  final String? tomorrow;
  final String? yesterday;

  const CompactnessOverride({
    this.months,
    this.monthsInDate,
    this.weekdays,
    this.dayFormat,
    this.dayFormatExceptions,
    this.datePattern,
    this.datePatternWithYear,
    this.today,
    this.tomorrow,
    this.yesterday,
  });
}

/// Locale definition for date formatting.
class DateLocale {
  final String code;
  final List<String> months;
  final List<String> weekdays;
  final String dayFormat;
  final Map<String, String> dayFormatExceptions;
  final String datePattern;
  final String datePatternWithYear;
  final String today;
  final String tomorrow;
  final String yesterday;
  final String? dayAfterTomorrow;
  final String? dayBeforeYesterday;
  final String? thisWeekday;
  final String? nextWeekday;
  final String? lastWeekday;
  final List<String>? monthsInDate;
  final CompactnessOverride? short;
  final CompactnessOverride? compact;

  const DateLocale({
    required this.code,
    required this.months,
    required this.weekdays,
    required this.dayFormat,
    this.dayFormatExceptions = const {},
    this.datePattern = '{day} {month}',
    this.datePatternWithYear = '{day} {month} {year}',
    this.today = 'today',
    this.tomorrow = 'tomorrow',
    this.yesterday = 'yesterday',
    this.dayAfterTomorrow,
    this.dayBeforeYesterday,
    this.thisWeekday,
    this.nextWeekday,
    this.lastWeekday,
    this.monthsInDate,
    this.short,
    this.compact,
  });
}

import 'types.dart';
import 'locales/locales.dart';

const String version = '0.5.0';

bool _isAsciiDigits(String s) =>
    s.codeUnits.every((c) => c >= 0x30 && c <= 0x39);

/// Parses YYYY-MM-DD, optionally followed by T and a time, naming a real
/// calendar day; returns null otherwise.
(int, int, int)? _parseDate(String s) {
  final isDateAlone = s.length == 10;
  final isDateTime = s.length > 10 && s[10] == 'T';
  if (!isDateAlone && !isDateTime) return null;
  if (s[4] != '-' || s[7] != '-') return null;
  final yearPart = s.substring(0, 4);
  final monthPart = s.substring(5, 7);
  final dayPart = s.substring(8, 10);
  if (!_isAsciiDigits(yearPart + monthPart + dayPart)) return null;
  final year = int.parse(yearPart);
  final month = int.parse(monthPart);
  final day = int.parse(dayPart);
  if (month < 1 || month > 12 || day < 1 || day > _daysInMonth(year, month)) {
    return null;
  }
  return (year, month, day);
}

bool _isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

int _daysInMonth(int year, int month) {
  const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2 && _isLeapYear(year)) return 29;
  return days[month];
}

int _toJdn(int year, int month, int day) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
}

int _weekday(int year, int month, int day) {
  final jdn = _toJdn(year, month, day);
  return (jdn + 1) % 7; // 0=Sun, 6=Sat
}

T _pick<T>(T? override, T base) => override ?? base;

class SayableDate {
  final DateLocale _locale;
  final Compactness _compactness;
  final List<String> _months;
  final List<String>? _monthsInDate;
  final List<String> _weekdays;
  final String _dayFormat;
  final Map<String, String> _dayFormatExceptions;
  final String _datePattern;
  final String _datePatternWithYear;
  final String _today;
  final String _tomorrow;
  final String _yesterday;

  SayableDate(DateLocale locale, [Compactness compactness = Compactness.normal])
      : _locale = locale,
        _compactness = compactness,
        _months = _resolveMonths(locale, compactness),
        _monthsInDate = _resolveMonthsInDate(locale, compactness),
        _weekdays = _resolveWeekdays(locale, compactness),
        _dayFormat = _resolveDayFormat(locale, compactness),
        _dayFormatExceptions = _resolveDayFormatExceptions(locale, compactness),
        _datePattern = _resolveDatePattern(locale, compactness),
        _datePatternWithYear = _resolveDatePatternWithYear(locale, compactness),
        _today = _resolveToday(locale, compactness),
        _tomorrow = _resolveTomorrow(locale, compactness),
        _yesterday = _resolveYesterday(locale, compactness);

  static List<String> _resolveMonths(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.months, l.months);
  }

  static List<String>? _resolveMonthsInDate(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.monthsInDate, l.monthsInDate);
  }

  static List<String> _resolveWeekdays(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.weekdays, l.weekdays);
  }

  static String _resolveDayFormat(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.dayFormat, l.dayFormat);
  }

  static Map<String, String> _resolveDayFormatExceptions(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    if (ovr != null && ovr.dayFormat != null && ovr.dayFormatExceptions == null) {
      return {};
    }
    return _pick(ovr?.dayFormatExceptions, l.dayFormatExceptions);
  }

  static String _resolveDatePattern(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.datePattern, l.datePattern);
  }

  static String _resolveDatePatternWithYear(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.datePatternWithYear, l.datePatternWithYear);
  }

  static String _resolveToday(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.today, l.today);
  }

  static String _resolveTomorrow(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.tomorrow, l.tomorrow);
  }

  static String _resolveYesterday(DateLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.yesterday, l.yesterday);
  }

  String? formatDate(String? date) {
    if (date == null || date.isEmpty) return null;
    final parsed = _parseDate(date);
    if (parsed == null) return null;
    final (year, month, day) = parsed;
    return _formatAbsolute(year, month, day, includeYear: false);
  }

  String? formatDateWithYear(String? date) {
    if (date == null || date.isEmpty) return null;
    final parsed = _parseDate(date);
    if (parsed == null) return null;
    final (year, month, day) = parsed;
    return _formatAbsolute(year, month, day, includeYear: true);
  }

  String? formatRelative(String? date, {required String? asOf}) {
    if (date == null || date.isEmpty || asOf == null || asOf.isEmpty) return null;
    final parsedDate = _parseDate(date);
    final parsedAsOf = _parseDate(asOf);
    if (parsedDate == null || parsedAsOf == null) return null;

    final (dy, dm, dd) = parsedDate;
    final (ay, am, ad) = parsedAsOf;
    final diff = _toJdn(dy, dm, dd) - _toJdn(ay, am, ad);

    if (diff == 0) return _today;
    if (diff == 1) return _tomorrow;
    if (diff == -1) return _yesterday;

    final loc = _locale;
    final isCompact = _compactness == Compactness.compact;

    if (diff == 2 && loc.dayAfterTomorrow != null && !isCompact) {
      return loc.dayAfterTomorrow!;
    }
    if (diff == -2 && loc.dayBeforeYesterday != null && !isCompact) {
      return loc.dayBeforeYesterday!;
    }

    if (isCompact) {
      return _formatAbsolute(dy, dm, dd, includeYear: dy != ay);
    }

    if (diff >= 2 && diff <= 6 && loc.thisWeekday != null) {
      final dow = _weekday(dy, dm, dd);
      return loc.thisWeekday!.replaceAll('{weekday}', _weekdays[dow]);
    }
    if (diff <= -2 && diff >= -6 && loc.lastWeekday != null) {
      final dow = _weekday(dy, dm, dd);
      return loc.lastWeekday!.replaceAll('{weekday}', _weekdays[dow]);
    }
    if (diff >= 7 && diff <= 13 && loc.nextWeekday != null) {
      final dow = _weekday(dy, dm, dd);
      return loc.nextWeekday!.replaceAll('{weekday}', _weekdays[dow]);
    }

    return _formatAbsolute(dy, dm, dd, includeYear: dy != ay);
  }

  String _formatAbsolute(int year, int month, int day, {required bool includeYear}) {
    final dayStr = day.toString();
    final fmt = _dayFormatExceptions[dayStr] ?? _dayFormat;
    final formattedDay = fmt.replaceAll('{n}', dayStr);

    final monthNames = _monthsInDate ?? _months;
    final monthName = monthNames[month - 1];

    final pattern = includeYear ? _datePatternWithYear : _datePattern;
    var result = pattern
        .replaceAll('{month}', monthName)
        .replaceAll('{day}', formattedDay)
        .replaceAll('{d}', day.toString())
        .replaceAll('{m}', month.toString());
    if (includeYear) {
      result = result
          .replaceAll('{year}', year.toString())
          .replaceAll('{yy}', (year % 100).toString().padLeft(2, '0'));
    }
    return result;
  }
}

SayableDate? _default;
SayableDate _getDefault() => _default ??= SayableDate(getLocale('en')!);

String? formatDate(String? date) => _getDefault().formatDate(date);

String? formatRelative(String? date, {required String? asOf}) =>
    _getDefault().formatRelative(date, asOf: asOf);

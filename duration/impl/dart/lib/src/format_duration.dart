import 'types.dart';
import 'locales/locales.dart';

const String version = '0.5.0';

bool _isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

int _daysInMonth(int year, int month) {
  const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2 && _isLeapYear(year)) return 29;
  return days[month];
}

int _daysSinceEpoch(int year, int month, int day) {
  var d = 0;
  if (year >= 2000) {
    for (var y = 2000; y < year; y++) {
      d += _isLeapYear(y) ? 366 : 365;
    }
  } else {
    for (var y = year; y < 2000; y++) {
      d -= _isLeapYear(y) ? 366 : 365;
    }
  }
  for (var m = 1; m < month; m++) {
    d += _daysInMonth(year, m);
  }
  d += day - 1;
  return d;
}

int? _parseIsoToSeconds(String isoStr) {
  if (isoStr.isEmpty) return null;
  final tIdx = isoStr.indexOf('T');
  if (tIdx < 0) return null;
  final datePart = isoStr.substring(0, tIdx);
  var timePart = isoStr.substring(tIdx + 1);

  final dp = datePart.split('-');
  if (dp.length != 3) return null;
  final year = int.tryParse(dp[0]);
  final month = int.tryParse(dp[1]);
  final day = int.tryParse(dp[2]);
  if (year == null || month == null || day == null) return null;

  if (timePart.contains('+')) timePart = timePart.split('+')[0];
  if (timePart.contains('Z')) timePart = timePart.split('Z')[0];
  final tp = timePart.split(':');
  final hour = int.tryParse(tp[0]);
  final minute = tp.length > 1 ? int.tryParse(tp[1]) : 0;
  final secondStr = tp.length > 2 ? tp[2].split('.')[0] : '0';
  final second = int.tryParse(secondStr);
  if (hour == null || minute == null || second == null) return null;

  final days = _daysSinceEpoch(year, month, day);
  return days * 86400 + hour * 3600 + minute * 60 + second;
}

T _pick<T>(T? override, T base) => override ?? base;

class SayableDuration {
  final DurationLocale _locale;
  final Map<String, UnitForms> _units;
  final String _half;
  final String _delimiter;
  final String _justNow;
  final String _ago;
  final String _inFuture;

  SayableDuration(DurationLocale locale,
      [Compactness compactness = Compactness.normal])
      : _locale = locale,
        _units = _resolveUnits(locale, compactness),
        _half = _resolveHalf(locale, compactness),
        _delimiter = _resolveDelimiter(locale, compactness),
        _justNow = locale.justNow,
        _ago = _resolveAgo(locale, compactness),
        _inFuture = _resolveInFuture(locale, compactness);

  static Map<String, UnitForms> _resolveUnits(DurationLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    final ovrUnits = ovr?.units;
    return {
      for (final k in ['second', 'minute', 'hour', 'day', 'week', 'month', 'year'])
        k: (ovrUnits != null && ovrUnits.containsKey(k)) ? ovrUnits[k]! : l.units[k]!,
    };
  }

  static String _resolveHalf(DurationLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.half, l.half);
  }

  static String _resolveDelimiter(DurationLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.delimiter, l.delimiter);
  }

  static String _resolveAgo(DurationLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.ago, l.ago);
  }

  static String _resolveInFuture(DurationLocale l, Compactness c) {
    final ovr = c == Compactness.short ? l.short : c == Compactness.compact ? l.compact : null;
    return _pick(ovr?.inFuture, l.inFuture);
  }

  String? formatDuration(Object? startOrSeconds, [String? end]) {
    if (startOrSeconds == null) return null;

    int totalSeconds;
    if (startOrSeconds is int) {
      totalSeconds = startOrSeconds;
    } else if (startOrSeconds is String) {
      if (end == null) return null;
      final s = _parseIsoToSeconds(startOrSeconds);
      final e = _parseIsoToSeconds(end);
      if (s == null || e == null) return null;
      totalSeconds = (e - s).abs();
    } else {
      return null;
    }

    if (totalSeconds < 0) return null;
    return _formatDurationSeconds(totalSeconds);
  }

  String _formatDurationSeconds(int total) {
    if (total == 0) return _justNow;

    // 1-59 seconds
    if (total < 60) {
      return resolveUnit(total, _units['second']!, _locale);
    }

    final totalMinutes = total ~/ 60;
    final remainderSeconds = total % 60;

    // 1-4 minutes: minutes + seconds
    if (totalMinutes < 5) {
      var result = resolveUnit(totalMinutes, _units['minute']!, _locale);
      if (remainderSeconds > 0) {
        result += _delimiter + resolveUnit(remainderSeconds, _units['second']!, _locale);
      }
      return result;
    }

    // 5-59 minutes
    if (totalMinutes < 60) {
      return resolveUnit(totalMinutes, _units['minute']!, _locale);
    }

    final totalHours = total ~/ 3600;
    final remainderMinutes = (total % 3600) ~/ 60;

    // 1-5 hours: hours + minutes (with half marker)
    if (totalHours <= 5) {
      if (remainderMinutes == 30) {
        return resolveUnit(totalHours, _units['hour']!, _locale, _half);
      }
      var result = resolveUnit(totalHours, _units['hour']!, _locale);
      if (remainderMinutes > 0) {
        result += _delimiter + resolveUnit(remainderMinutes, _units['minute']!, _locale);
      }
      return result;
    }

    // 6-23 hours
    if (totalHours < 24) {
      return resolveUnit(totalHours, _units['hour']!, _locale);
    }

    final totalDays = total ~/ 86400;
    final remainderHours = (total % 86400) ~/ 3600;

    // 1-2 days: days + hours (with half marker)
    if (totalDays <= 2) {
      if (remainderHours == 12) {
        return resolveUnit(totalDays, _units['day']!, _locale, _half);
      }
      var result = resolveUnit(totalDays, _units['day']!, _locale);
      if (remainderHours > 0) {
        result += _delimiter + resolveUnit(remainderHours, _units['hour']!, _locale);
      }
      return result;
    }

    // 3-6 days
    if (totalDays < 7) {
      return resolveUnit(totalDays, _units['day']!, _locale);
    }

    final totalWeeks = totalDays ~/ 7;
    final remainderDays = totalDays % 7;

    // Weeks + days (up to 29 days)
    if (totalDays < 30) {
      var result = resolveUnit(totalWeeks, _units['week']!, _locale);
      if (remainderDays > 0) {
        result += _delimiter + resolveUnit(remainderDays, _units['day']!, _locale);
      }
      return result;
    }

    // Approximate months
    var totalMonths = (totalDays / 30.44).round();

    // 1-11 months
    if (totalMonths < 12) {
      if (totalMonths == 0) totalMonths = 1;
      return resolveUnit(totalMonths, _units['month']!, _locale);
    }

    // Years + months
    final totalYears = totalMonths ~/ 12;
    final remainderMonths = totalMonths % 12;
    var result = resolveUnit(totalYears, _units['year']!, _locale);
    if (remainderMonths > 0) {
      result += _delimiter + resolveUnit(remainderMonths, _units['month']!, _locale);
    }
    return result;
  }

  String? formatSince(String? start, String? asOf) {
    if (start == null || start.isEmpty || asOf == null || asOf.isEmpty) return null;
    final s = _parseIsoToSeconds(start);
    final a = _parseIsoToSeconds(asOf);
    if (s == null || a == null) return null;
    final diff = a - s;
    if (diff < 0) return null;
    if (diff == 0) return _justNow;
    final dur = _formatDurationSeconds(diff);
    return _ago.replaceFirst('{0}', dur);
  }

  String? formatUntil(String? target, String? asOf) {
    if (target == null || target.isEmpty || asOf == null || asOf.isEmpty) return null;
    final t = _parseIsoToSeconds(target);
    final a = _parseIsoToSeconds(asOf);
    if (t == null || a == null) return null;
    final diff = t - a;
    if (diff < 0) return null;
    if (diff == 0) return _justNow;
    final dur = _formatDurationSeconds(diff);
    return _inFuture.replaceFirst('{0}', dur);
  }
}

SayableDuration? _default;
SayableDuration _getDefault() => _default ??= SayableDuration(getLocale('en')!);

String? formatDuration(Object? startOrSeconds, [String? end]) =>
    _getDefault().formatDuration(startOrSeconds, end);

String? formatSince(String? start, String? asOf) =>
    _getDefault().formatSince(start, asOf);

String? formatUntil(String? target, String? asOf) =>
    _getDefault().formatUntil(target, asOf);

import 'types.dart';
import 'locales/locales.dart';

const String version = '0.5.0';

/// A clock time: H:MM or HH:MM, optional :SS and fraction, optional zone
/// suffix (validated but ignored).
final _clockPattern = RegExp(
    r'^([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?$');
final _datePattern = RegExp(r'^([0-9]{4})-([0-9]{2})-([0-9]{2})$');

bool _isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

int _daysInMonth(int year, int month) {
  if (month == 2) return _isLeapYear(year) ? 29 : 28;
  return const [4, 6, 9, 11].contains(month) ? 30 : 31;
}

bool _isRealDate(String datePart) {
  final m = _datePattern.firstMatch(datePart);
  if (m == null) return false;
  final year = int.parse(m[1]!);
  final month = int.parse(m[2]!);
  final day = int.parse(m[3]!);
  return month >= 1 && month <= 12 && day >= 1 && day <= _daysInMonth(year, month);
}

/// Parses a clock time, alone or after the T of an ISO datetime whose date
/// is real, to (hour, minute); returns null otherwise.
(int, int)? _parseTime(String input) {
  if (input.isEmpty) return null;
  var clock = input;
  final t = input.indexOf('T');
  if (t >= 0) {
    if (!_isRealDate(input.substring(0, t))) return null;
    clock = input.substring(t + 1);
  }
  final m = _clockPattern.firstMatch(clock);
  if (m == null) return null;
  final hour = int.parse(m[1]!);
  final minute = int.parse(m[2]!);
  final second = m[3] == null ? 0 : int.parse(m[3]!);
  if (hour > 23 || minute > 59 || second > 59) return null;
  return (hour, minute);
}

int _roundTo5(int minute) => ((minute + 2) ~/ 5) * 5;

class SayableTime {
  final TimeLocale _locale;
  final Compactness _compactness;
  final ShortClockConfig? _shortClock;

  SayableTime(TimeLocale locale, [Compactness compactness = Compactness.normal])
      : _locale = locale,
        _compactness = compactness,
        _shortClock = compactness == Compactness.short
            ? locale.short?.clock
            : compactness == Compactness.compact
                ? locale.compact?.clock
                : null;

  String? formatTime(String? input) {
    if (input == null || input.isEmpty) return null;
    final parsed = _parseTime(input);
    if (parsed == null) return null;
    final (hour, minute) = parsed;

    if (_compactness != Compactness.normal && _shortClock != null) {
      return _formatDigital(hour, minute);
    }
    return _formatNatural(hour, minute);
  }

  String _formatNatural(int hour, int minute) {
    final clock = _locale.clock;
    var rounded = _roundTo5(minute);
    var h = hour;
    if (rounded == 60) {
      rounded = 0;
      h = (h + 1) % 24;
    }
    if (rounded == 0) {
      if (h == 0) return clock.midnight;
      if (h == 12) return clock.noon;
    }
    final h12 = h % 12;
    final nextH12 = (h + 1) % 12;
    final hName = clock.hours[h12];
    final nextHName = clock.hours[nextH12];
    final pattern = clock.patterns[rounded] ?? clock.patterns[0] ?? '{h}';
    return pattern.replaceAll('{h}', hName).replaceAll('{next_h}', nextHName);
  }

  String _formatDigital(int hour, int minute) {
    final sc = _shortClock!;
    final fmt = sc.format;
    if (sc.use24h) {
      return fmt
          .replaceAll('{h}', hour.toString())
          .replaceAll('{mm}', minute.toString().padLeft(2, '0'));
    }
    var h12 = hour % 12;
    if (h12 == 0) h12 = 12;
    final amPm = sc.amPm ?? ['AM', 'PM'];
    final ampmStr = hour < 12 ? amPm[0] : amPm[1];
    return fmt
        .replaceAll('{h}', h12.toString())
        .replaceAll('{mm}', minute.toString().padLeft(2, '0'))
        .replaceAll('{ampm}', ampmStr);
  }
}

SayableTime? _default;
SayableTime _getDefault() => _default ??= SayableTime(getLocale('en')!);

String? formatTime(String? input) => _getDefault().formatTime(input);

import 'types.dart';
import 'locales/locales.dart';

const String version = '0.5.0';

(int, int)? _parseTime(String input) {
  if (input.isEmpty) return null;
  var t = input;
  if (t.contains('T')) t = t.split('T')[1];
  if (t.contains('+')) t = t.split('+')[0];
  if (t.contains('Z')) t = t.split('Z')[0];
  final parts = t.split(':');
  if (parts.length < 2) return null;
  final dotParts = parts[1].split('.');
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(dotParts[0]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
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

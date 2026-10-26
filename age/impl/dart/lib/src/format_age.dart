import 'types.dart';
import 'locales/locales.dart';

const String version = '0.5.0';

const _maxAgeMonths = 6000;

class _AgeComponents {
  final int months;
  final int diffDays;
  const _AgeComponents(this.months, this.diffDays);
}

/// Testable clock — override for testing default asOf behavior.
DateTime Function() clock = () => DateTime.now();

_AgeComponents? _parseAge(String dateOfBirth, [String? asOf]) {
  if (dateOfBirth.isEmpty) return null;

  final dob = _parseDateParts(dateOfBirth);
  if (dob == null) return null;

  int refY, refM, refD;
  if (asOf != null && asOf.isNotEmpty) {
    final ref = _parseDateParts(asOf);
    if (ref == null) return null;
    refY = ref.$1;
    refM = ref.$2;
    refD = ref.$3;
  } else {
    final now = clock();
    refY = now.year;
    refM = now.month;
    refD = now.day;
  }

  final dobTime = DateTime.utc(dob.$1, dob.$2, dob.$3);
  final refTime = DateTime.utc(refY, refM, refD);
  final diffDays = refTime.difference(dobTime).inDays;
  if (diffDays < 0) return null;

  // Calendar months with birthday clamping
  final lastDay = _daysInMonth(refY, refM);
  var clampedBirthday = dob.$3;
  if (clampedBirthday > lastDay) clampedBirthday = lastDay;

  var months = (refY - dob.$1) * 12 + (refM - dob.$2);
  if (refD < clampedBirthday) months--;
  if (months > _maxAgeMonths) return null;

  return _AgeComponents(months, diffDays);
}

bool _isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

int _daysInMonth(int year, int month) {
  if (month == 2) return _isLeapYear(year) ? 29 : 28;
  return const [4, 6, 9, 11].contains(month) ? 30 : 31;
}

bool _isAsciiDigits(String s) =>
    s.codeUnits.every((c) => c >= 0x30 && c <= 0x39);

/// Parses exactly YYYY-MM-DD naming a real calendar day, else null.
(int, int, int)? _parseDateParts(String s) {
  if (s.length != 10 || s[4] != '-' || s[7] != '-') return null;
  final yearPart = s.substring(0, 4);
  final monthPart = s.substring(5, 7);
  final dayPart = s.substring(8, 10);
  if (!_isAsciiDigits(yearPart + monthPart + dayPart)) return null;
  final y = int.parse(yearPart);
  final m = int.parse(monthPart);
  final d = int.parse(dayPart);
  if (m < 1 || m > 12 || d < 1 || d > _daysInMonth(y, m)) return null;
  return (y, m, d);
}

String _stageKey(int months) {
  if (months < 2) return 'newborn';
  if (months < 12) return 'infant';
  if (months < 36) return 'toddler';
  if (months < 156) return 'child';
  if (months < 216) return 'teenager';
  return 'adult';
}

String _resolveUnit(int count, UnitForms uf, AgeLocale loc, String half) {
  final baseN =
      loc.formatNumber != null ? loc.formatNumber!(count) : count.toString();

  // Apply {n}-style half marker to the number
  var n = baseN;
  if (half.isNotEmpty && half.contains('{n}')) {
    n = half.replaceFirst('{n}', baseN);
  }

  // Select template
  String template;
  if (uf.simple != null && uf.simple!.isNotEmpty) {
    template = uf.simple!;
  } else {
    final cat = loc.plural(count);
    template = uf.forms![cat] ?? uf.forms![PluralCategory.other]!;
  }

  var result = template.replaceFirst('{n}', n);

  if (loc.formatUnit != null) {
    result = loc.formatUnit!(count, result);
  }

  // Apply {0}-style half marker (wraps the whole expression)
  if (half.isNotEmpty && half.contains('{0}')) {
    result = half.replaceFirst('{0}', result);
  }

  return result;
}

/// Locale-aware age formatter.
class SayableAge {
  final AgeLocale _locale;
  final UnitForms _day;
  final UnitForms _week;
  final UnitForms _month;
  final UnitForms _year;
  final String _half;
  final String _delimiter;
  final String _justBorn;

  /// Creates a new SayableAge instance with the given locale and optional compactness.
  factory SayableAge(AgeLocale locale,
      [Compactness compactness = Compactness.normal]) {
    var day = locale.day;
    var week = locale.week;
    var month = locale.month;
    var year = locale.year;
    var half = locale.half;
    var delimiter = locale.delimiter;
    var justBorn = locale.justBorn;

    CompactnessOverride? ovr;
    switch (compactness) {
      case Compactness.short:
        ovr = locale.short;
      case Compactness.compact:
        ovr = locale.compact;
      case Compactness.normal:
        break;
    }

    if (ovr != null) {
      if (ovr.day != null) day = ovr.day!;
      if (ovr.week != null) week = ovr.week!;
      if (ovr.month != null) month = ovr.month!;
      if (ovr.year != null) year = ovr.year!;
      if (ovr.half != null) half = ovr.half!;
      if (ovr.delimiter != null) delimiter = ovr.delimiter!;
      if (ovr.justBorn != null) justBorn = ovr.justBorn!;
    }

    return SayableAge._(locale, day, week, month, year, half, delimiter,
        justBorn);
  }

  const SayableAge._(this._locale, this._day, this._week, this._month,
      this._year, this._half, this._delimiter, this._justBorn);

  /// Formats a human-friendly age string.
  /// Returns null if dateOfBirth is empty or in the future.
  String? formatAge(String dateOfBirth, [String? asOf]) {
    final age = _parseAge(dateOfBirth, asOf);
    if (age == null) return null;

    final months = age.months;
    final diffDays = age.diffDays;

    // Tier 1: 0 days
    if (diffDays == 0) return _justBorn;

    // Tier 1b: 1-6 days
    if (diffDays < 7) {
      return _resolveUnit(diffDays, _day, _locale, '');
    }

    // Tier 2: weeks + days until 3 calendar months
    if (months < 3) {
      final weeks = diffDays ~/ 7;
      final days = diffDays % 7;
      var result = _resolveUnit(weeks, _week, _locale, '');
      if (days > 0) {
        result += _delimiter + _resolveUnit(days, _day, _locale, '');
      }
      return result;
    }

    // Tier 3: 3-23 months
    if (months < 24) {
      return _resolveUnit(months, _month, _locale, '');
    }

    // Tier 4: 24-35 months -> years + months
    if (months < 36) {
      final years = months ~/ 12;
      final rem = months % 12;
      if (rem == 0) {
        return _resolveUnit(years, _year, _locale, '');
      }
      return _resolveUnit(years, _year, _locale, '') +
          _delimiter +
          _resolveUnit(rem, _month, _locale, '');
    }

    // Tier 5: 3-6 years -> years with half marker
    if (months < 84) {
      final years = months ~/ 12;
      final rem = months % 12;
      if (rem >= 6) {
        return _resolveUnit(years, _year, _locale, _half);
      }
      return _resolveUnit(years, _year, _locale, '');
    }

    // Tier 6: 7+ years
    final years = months ~/ 12;
    return _resolveUnit(years, _year, _locale, '');
  }

  /// Returns the developmental stage label based on age.
  /// Returns null if dateOfBirth is empty or in the future.
  String? formatStage(String dateOfBirth, [String? asOf, String? gender]) {
    final age = _parseAge(dateOfBirth, asOf);
    if (age == null) return null;

    final key = _stageKey(age.months);
    final StageLabel sl;
    switch (key) {
      case 'newborn':
        sl = _locale.newborn;
      case 'infant':
        sl = _locale.infant;
      case 'toddler':
        sl = _locale.toddler;
      case 'child':
        sl = _locale.child;
      case 'teenager':
        sl = _locale.teenager;
      default:
        sl = _locale.adult;
    }
    return resolveStage(sl, gender ?? '');
  }
}

/// Default English SayableAge instance (lazy-initialized).
SayableAge? _defaultPt;
SayableAge get _getDefaultPt => _defaultPt ??= SayableAge(getLocale('en')!);

/// Formats an age using the default English locale (normal compactness).
String? formatAge(String dateOfBirth, [String? asOf]) {
  return _getDefaultPt.formatAge(dateOfBirth, asOf);
}

/// Returns the developmental stage using the default English locale.
String? formatStage(String dateOfBirth, [String? asOf, String? gender]) {
  return _getDefaultPt.formatStage(dateOfBirth, asOf, gender);
}

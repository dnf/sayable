/// CLDR-inspired plural categories.
enum PluralCategory { zero, one, two, few, many, other }

/// Controls the verbosity of formatted output.
enum Compactness { normal, short, compact }

/// Holds a unit's display template(s).
class UnitForms {
  final String? simple;
  final Map<PluralCategory, String>? forms;

  const UnitForms._({this.simple, this.forms});
}

/// Creates a UnitForms with a single template for all counts.
UnitForms simpleUnit(String s) => UnitForms._(simple: s);

/// Creates a UnitForms with per-category templates.
UnitForms pluralUnit(Map<PluralCategory, String> forms) =>
    UnitForms._(forms: forms);

/// Optional overrides for short/compact display modes.
class CompactnessOverride {
  final Map<String, UnitForms>? units;
  final String? half;
  final String? delimiter;
  final String? ago;
  final String? inFuture;

  const CompactnessOverride({
    this.units,
    this.half,
    this.delimiter,
    this.ago,
    this.inFuture,
  });
}

/// Locale definition for duration formatting.
class DurationLocale {
  final String code;
  final PluralCategory Function(int n) plural;
  final Map<String, UnitForms> units;
  final String half;
  final String delimiter;
  final String justNow;
  final String ago;
  final String inFuture;
  final CompactnessOverride? short;
  final CompactnessOverride? compact;
  final String Function(int n)? formatNumber;
  final String Function(int count, String label)? formatUnit;

  const DurationLocale({
    required this.code,
    required this.plural,
    required this.units,
    required this.half,
    required this.delimiter,
    required this.justNow,
    required this.ago,
    required this.inFuture,
    this.short,
    this.compact,
    this.formatNumber,
    this.formatUnit,
  });
}

/// Resolve a unit count to its display string using locale rules.
String resolveUnit(
  int count,
  UnitForms unitForms,
  DurationLocale locale, [
  String half = '',
]) {
  final baseN = locale.formatNumber != null
      ? locale.formatNumber!(count)
      : count.toString();
  var n = (half.isNotEmpty && half.contains('{n}'))
      ? half.replaceFirst('{n}', baseN)
      : baseN;

  String template;
  if (unitForms.simple != null && unitForms.simple!.isNotEmpty) {
    template = unitForms.simple!;
  } else {
    final category =
        half.isNotEmpty ? PluralCategory.other : locale.plural(count);
    template =
        unitForms.forms![category] ?? unitForms.forms![PluralCategory.other]!;
  }

  var result = template.replaceFirst('{n}', n);
  if (locale.formatUnit != null) {
    result = locale.formatUnit!(count, result);
  }
  if (half.isNotEmpty && half.contains('{0}')) {
    result = half.replaceFirst('{0}', result);
  }
  return result;
}

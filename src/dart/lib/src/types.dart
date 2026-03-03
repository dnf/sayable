/// CLDR-inspired plural categories.
enum PluralCategory { zero, one, two, few, many, other }

/// Controls the verbosity of formatted output.
enum Compactness { normal, short, compact }

/// Holds a unit's display template(s).
///
/// Use [SimpleUnit] for languages with no plural forms,
/// [PluralUnit] for plural-aware forms.
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

/// Holds optional overrides for short/compact display modes.
/// Null fields mean "use the base locale value."
class CompactnessOverride {
  final UnitForms? day;
  final UnitForms? week;
  final UnitForms? month;
  final UnitForms? year;
  final String? half;
  final String? delimiter;
  final String? justBorn;

  const CompactnessOverride({
    this.day,
    this.week,
    this.month,
    this.year,
    this.half,
    this.delimiter,
    this.justBorn,
  });
}

/// Represents a stage label that may be gender-neutral or gendered.
class StageLabel {
  final String? label;
  final String? m;
  final String? f;

  const StageLabel._({this.label, this.m, this.f});
}

/// Creates a gender-neutral StageLabel.
StageLabel stageNeutral(String s) => StageLabel._(label: s);

/// Creates a gendered StageLabel with masculine and feminine forms.
StageLabel stageGendered(String m, String f) => StageLabel._(m: m, f: f);

/// Returns the appropriate string for the given gender.
String resolveStage(StageLabel sl, String gender) {
  if (sl.m == null || sl.m!.isEmpty) return sl.label!;
  if (gender == 'f') return sl.f!;
  return sl.m!;
}

/// Defines all locale-specific data for age formatting.
class AgeLocale {
  final String code;
  final PluralCategory Function(int n) plural;
  final UnitForms day;
  final UnitForms week;
  final UnitForms month;
  final UnitForms year;
  final String half;
  final String delimiter;
  final String justBorn;
  final StageLabel newborn;
  final StageLabel infant;
  final StageLabel toddler;
  final StageLabel child;
  final StageLabel teenager;
  final StageLabel adult;
  final CompactnessOverride? short;
  final CompactnessOverride? compact;
  final String Function(int n)? formatNumber;
  final String Function(int count, String label)? formatUnit;

  const AgeLocale({
    required this.code,
    required this.plural,
    required this.day,
    required this.week,
    required this.month,
    required this.year,
    required this.half,
    required this.delimiter,
    required this.justBorn,
    required this.newborn,
    required this.infant,
    required this.toddler,
    required this.child,
    required this.teenager,
    required this.adult,
    this.short,
    this.compact,
    this.formatNumber,
    this.formatUnit,
  });
}

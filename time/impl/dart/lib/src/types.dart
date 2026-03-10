/// Controls the verbosity of formatted output.
enum Compactness { normal, short, compact }

/// Natural language clock reading configuration.
class ClockConfig {
  final List<String> hours;
  final String midnight;
  final String noon;
  final Map<int, String> patterns;

  const ClockConfig({
    required this.hours,
    required this.midnight,
    required this.noon,
    required this.patterns,
  });
}

/// Digital clock display configuration for short/compact modes.
class ShortClockConfig {
  final bool use24h;
  final String format;
  final List<String>? amPm;

  const ShortClockConfig({
    required this.use24h,
    required this.format,
    this.amPm,
  });
}

/// Optional overrides for short/compact display modes.
class CompactnessOverride {
  final ShortClockConfig? clock;

  const CompactnessOverride({this.clock});
}

/// Locale definition for clock time formatting.
class TimeLocale {
  final String code;
  final ClockConfig clock;
  final CompactnessOverride? short;
  final CompactnessOverride? compact;

  const TimeLocale({
    required this.code,
    required this.clock,
    this.short,
    this.compact,
  });
}

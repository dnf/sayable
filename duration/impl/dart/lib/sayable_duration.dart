/// Human-friendly duration and relative time formatting.
library sayable_duration;

export 'src/types.dart';
export 'src/format_duration.dart'
    show SayableDuration, formatDuration, formatSince, formatUntil, version;
export 'src/locales/locales.dart' show getLocale;

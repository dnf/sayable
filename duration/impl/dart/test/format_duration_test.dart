import 'package:test/test.dart';
import 'package:sayable_duration/src/types.dart';
import 'package:sayable_duration/src/format_duration.dart';
import 'package:sayable_duration/src/locales/locales.dart';

// All tests use explicit inputs for determinism.

void main() {
  // ================================================================
  // Null / edge cases
  // ================================================================
  group('Null / edge cases', () {
    test('null input', () {
      expect(formatDuration(null), isNull); // 1.1
    });
    test('negative seconds', () {
      expect(formatDuration(-1), isNull); // 1.2
    });
    test('format_since null start', () {
      expect(formatSince(null, '2025-01-15T10:00:00'), isNull); // 1.3
    });
    test('format_until null target', () {
      expect(formatUntil(null, '2025-01-15T10:00:00'), isNull); // 1.4
    });
    test('format_since asOf before start', () {
      expect(formatSince('2025-01-15T10:00:00', '2025-01-15T09:00:00'), isNull); // 1.5
    });
    test('format_until target in past', () {
      expect(formatUntil('2025-01-15T09:00:00', '2025-01-15T10:00:00'), isNull); // 1.6
    });
  });

  // ================================================================
  // Duration — seconds tier (0-59s)
  // ================================================================
  group('Duration — seconds tier', () {
    test('0 seconds', () {
      expect(formatDuration(0), 'just now'); // 2.1
    });
    test('1 second', () {
      expect(formatDuration(1), '1 second'); // 2.2
    });
    test('45 seconds', () {
      expect(formatDuration(45), '45 seconds'); // 2.3
    });
    test('59 seconds', () {
      expect(formatDuration(59), '59 seconds'); // 2.4
    });
  });

  // ================================================================
  // Duration — minutes + seconds tier (1-4 min)
  // ================================================================
  group('Duration — minutes + seconds tier', () {
    test('1 minute', () {
      expect(formatDuration(60), '1 minute'); // 3.1
    });
    test('1 minute, 30 seconds', () {
      expect(formatDuration(90), '1 minute, 30 seconds'); // 3.2
    });
    test('4 minutes', () {
      expect(formatDuration(240), '4 minutes'); // 3.3
    });
    test('4 minutes, 30 seconds', () {
      expect(formatDuration(270), '4 minutes, 30 seconds'); // 3.4
    });
  });

  // ================================================================
  // Duration — minutes tier (5-59 min)
  // ================================================================
  group('Duration — minutes tier', () {
    test('5 minutes', () {
      expect(formatDuration(300), '5 minutes'); // 4.1
    });
    test('25 minutes', () {
      expect(formatDuration(1500), '25 minutes'); // 4.2
    });
    test('59 minutes', () {
      expect(formatDuration(3540), '59 minutes'); // 4.3
    });
  });

  // ================================================================
  // Duration — hours + minutes tier (1-5 hr)
  // ================================================================
  group('Duration — hours + minutes tier', () {
    test('1 hour', () {
      expect(formatDuration(3600), '1 hour'); // 5.1
    });
    test('1½ hours (half marker)', () {
      expect(formatDuration(5400), '1½ hours'); // 5.2
    });
    test('2 hours, 15 minutes', () {
      expect(formatDuration(8100), '2 hours, 15 minutes'); // 5.3
    });
    test('5 hours', () {
      expect(formatDuration(18000), '5 hours'); // 5.4
    });
  });

  // ================================================================
  // Duration — hours tier (6-23 hr)
  // ================================================================
  group('Duration — hours tier', () {
    test('8 hours', () {
      expect(formatDuration(28800), '8 hours'); // 6.1
    });
    test('23 hours', () {
      expect(formatDuration(82800), '23 hours'); // 6.2
    });
  });

  // ================================================================
  // Duration — days tier
  // ================================================================
  group('Duration — days tier', () {
    test('1 day', () {
      expect(formatDuration(86400), '1 day'); // 7.1
    });
    test('1 day, 3 hours', () {
      expect(formatDuration(97200), '1 day, 3 hours'); // 7.2
    });
    test('1½ days (half marker)', () {
      expect(formatDuration(129600), '1½ days'); // 7.3
    });
    test('5 days', () {
      expect(formatDuration(432000), '5 days'); // 7.4
    });
    test('2 days', () {
      expect(formatDuration(172800), '2 days'); // 7.5
    });
  });

  // ================================================================
  // Duration — weeks tier
  // ================================================================
  group('Duration — weeks tier', () {
    test('1 week', () {
      expect(formatDuration(604800), '1 week'); // 8.1
    });
    test('2 weeks, 1 day', () {
      expect(formatDuration(1296000), '2 weeks, 1 day'); // 8.2
    });
    test('4 weeks', () {
      expect(formatDuration(2419200), '4 weeks'); // 8.3
    });
  });

  // ================================================================
  // Duration — months and years tier
  // ================================================================
  group('Duration — months and years tier', () {
    test('1 month', () {
      expect(formatDuration(2678400), '1 month'); // 9.1
    });
    test('3 months', () {
      expect(formatDuration(7884000), '3 months'); // 9.2
    });
    test('1 year', () {
      expect(formatDuration(31536000), '1 year'); // 9.3
    });
    test('1 year, 3 months', () {
      expect(formatDuration(39420000), '1 year, 3 months'); // 9.4
    });
  });

  // ================================================================
  // Duration from ISO timestamps
  // ================================================================
  group('Duration from ISO timestamps', () {
    test('1½ hours', () {
      expect(formatDuration('2025-01-15T10:00:00', '2025-01-15T11:30:00'), '1½ hours'); // 10.1
    });
    test('45 minutes', () {
      expect(formatDuration('2025-01-15T10:00:00', '2025-01-15T10:45:00'), '45 minutes'); // 10.2
    });
  });

  // ================================================================
  // Relative time — since
  // ================================================================
  group('Relative time — since', () {
    test('just now', () {
      expect(formatSince('2025-01-15T10:00:00', '2025-01-15T10:00:00'), 'just now'); // 11.1
    });
    test('30 seconds ago', () {
      expect(formatSince('2025-01-15T10:00:00', '2025-01-15T10:00:30'), '30 seconds ago'); // 11.2
    });
    test('45 minutes ago', () {
      expect(formatSince('2025-01-15T10:00:00', '2025-01-15T10:45:00'), '45 minutes ago'); // 11.3
    });
    test('3 hours ago', () {
      expect(formatSince('2025-01-15T10:00:00', '2025-01-15T13:00:00'), '3 hours ago'); // 11.4
    });
  });

  // ================================================================
  // Relative time — until
  // ================================================================
  group('Relative time — until', () {
    test('just now', () {
      expect(formatUntil('2025-01-15T10:00:00', '2025-01-15T10:00:00'), 'just now'); // 12.1
    });
    test('in 20 minutes', () {
      expect(formatUntil('2025-01-15T10:20:00', '2025-01-15T10:00:00'), 'in 20 minutes'); // 12.2
    });
    test('in 3 hours', () {
      expect(formatUntil('2025-01-15T13:00:00', '2025-01-15T10:00:00'), 'in 3 hours'); // 12.3
    });
  });

  // ================================================================
  // Locale — German
  // ================================================================
  group('Locale — German', () {
    final sd = SayableDuration(getLocale('de')!);
    test('1 Stunde', () {
      expect(sd.formatDuration(3600), '1 Stunde'); // 13.1
    });
    test('vor 5 Minuten', () {
      expect(sd.formatSince('2025-01-15T10:00:00', '2025-01-15T10:05:00'), 'vor 5 Minuten'); // 13.2
    });
  });

  // ================================================================
  // Locale — French
  // ================================================================
  group('Locale — French', () {
    final sd = SayableDuration(getLocale('fr')!);
    test('2 heures', () {
      expect(sd.formatDuration(7200), '2 heures'); // 14.1
    });
  });

  // ================================================================
  // Locale — Japanese
  // ================================================================
  group('Locale — Japanese', () {
    final sd = SayableDuration(getLocale('ja')!);
    test('2分', () {
      expect(sd.formatDuration(120), '2分'); // 15.1
    });
    test('1時間前', () {
      expect(sd.formatSince('2025-01-15T10:00:00', '2025-01-15T11:00:00'), '1時間前'); // 15.2
    });
  });

  // ================================================================
  // Short compactness — duration
  // ================================================================
  group('Short compactness', () {
    final sd = SayableDuration(getLocale('en')!, Compactness.short);
    test('1h', () {
      expect(sd.formatDuration(3600), '1h'); // 16.1
    });
    test('1m, 30s', () {
      expect(sd.formatDuration(90), '1m, 30s'); // 16.2
    });
  });

  // ================================================================
  // Compact compactness — duration
  // ================================================================
  group('Compact compactness', () {
    final sd = SayableDuration(getLocale('en')!, Compactness.compact);
    test('1h', () {
      expect(sd.formatDuration(3600), '1h'); // 17.1
    });
    test('1m30s', () {
      expect(sd.formatDuration(90), '1m30s'); // 17.2
    });
  });
}

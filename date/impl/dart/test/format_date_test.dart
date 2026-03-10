import 'package:test/test.dart';
import 'package:sayable_date/src/types.dart';
import 'package:sayable_date/src/format_date.dart';
import 'package:sayable_date/src/locales/locales.dart';

// All tests use explicit inputs for determinism.

void main() {
  // ================================================================
  // Null / edge cases
  // ================================================================
  group('Null / edge cases', () {
    test('null date', () {
      expect(formatDate(null), isNull); // 1.1
    });
    test('empty string', () {
      expect(formatDate(''), isNull); // 1.2
    });
    test('invalid string', () {
      expect(formatDate('invalid'), isNull); // 1.3
    });
    test('relative with null asOf', () {
      expect(formatRelative('2025-03-15', asOf: null), isNull); // 1.4
    });
    test('relative with null date', () {
      expect(formatRelative(null, asOf: '2025-03-15'), isNull); // 1.5
    });
  });

  // ================================================================
  // format_date — normal compactness (English)
  // ================================================================
  group('format_date — normal (English)', () {
    test('March 15th', () {
      expect(formatDate('2025-03-15'), 'March 15th'); // 2.1
    });
    test('January 1st', () {
      expect(formatDate('2025-01-01'), 'January 1st'); // 2.2
    });
    test('May 22nd', () {
      expect(formatDate('2025-05-22'), 'May 22nd'); // 2.3
    });
    test('July 3rd', () {
      expect(formatDate('2025-07-03'), 'July 3rd'); // 2.4
    });
    test('December 31st', () {
      expect(formatDate('2025-12-31'), 'December 31st'); // 2.5
    });
    test('June 11th', () {
      expect(formatDate('2025-06-11'), 'June 11th'); // 2.6
    });
    test('ISO datetime input', () {
      expect(formatDate('2025-03-15T14:30:00'), 'March 15th'); // 2.7
    });
  });

  // ================================================================
  // format_date — short compactness (English)
  // ================================================================
  group('format_date — short (English)', () {
    final sd = SayableDate(getLocale('en')!, Compactness.short);
    test('Mar 15', () {
      expect(sd.formatDate('2025-03-15'), 'Mar 15'); // 3.1
    });
    test('Jan 1', () {
      expect(sd.formatDate('2025-01-01'), 'Jan 1'); // 3.2
    });
    test('Dec 25', () {
      expect(sd.formatDate('2025-12-25'), 'Dec 25'); // 3.3
    });
  });

  // ================================================================
  // format_date — compact (English)
  // ================================================================
  group('format_date — compact (English)', () {
    final sd = SayableDate(getLocale('en')!, Compactness.compact);
    test('3/15', () {
      expect(sd.formatDate('2025-03-15'), '3/15'); // 4.1
    });
    test('1/1', () {
      expect(sd.formatDate('2025-01-01'), '1/1'); // 4.2
    });
  });

  // ================================================================
  // format_relative — proximity tiers (English)
  // ================================================================
  group('format_relative — proximity tiers (English)', () {
    test('today', () {
      expect(formatRelative('2025-03-15', asOf: '2025-03-15'), 'today'); // 5.1
    });
    test('tomorrow', () {
      expect(formatRelative('2025-03-16', asOf: '2025-03-15'), 'tomorrow'); // 5.2
    });
    test('yesterday', () {
      expect(formatRelative('2025-03-14', asOf: '2025-03-15'), 'yesterday'); // 5.3
    });
    test('day after tomorrow', () {
      expect(formatRelative('2025-03-17', asOf: '2025-03-15'), 'the day after tomorrow'); // 5.4
    });
    test('day before yesterday', () {
      expect(formatRelative('2025-03-13', asOf: '2025-03-15'), 'the day before yesterday'); // 5.5
    });
    test('this Wednesday (+4)', () {
      expect(formatRelative('2025-03-19', asOf: '2025-03-15'), 'this Wednesday'); // 5.6
    });
    test('this Thursday (+5)', () {
      expect(formatRelative('2025-03-20', asOf: '2025-03-15'), 'this Thursday'); // 5.7
    });
    test('last Tuesday (-4)', () {
      expect(formatRelative('2025-03-11', asOf: '2025-03-15'), 'last Tuesday'); // 5.8
    });
    test('next Saturday (+7)', () {
      expect(formatRelative('2025-03-22', asOf: '2025-03-15'), 'next Saturday'); // 5.9
    });
    test('next Thursday (+12)', () {
      expect(formatRelative('2025-03-27', asOf: '2025-03-15'), 'next Thursday'); // 5.10
    });
    test('calendar fallback same year (-14)', () {
      expect(formatRelative('2025-03-01', asOf: '2025-03-15'), 'March 1st'); // 5.11
    });
    test('calendar fallback same year (+26)', () {
      expect(formatRelative('2025-04-10', asOf: '2025-03-15'), 'April 10th'); // 5.12
    });
    test('different year future', () {
      expect(formatRelative('2026-01-05', asOf: '2025-03-15'), 'January 5th, 2026'); // 5.13
    });
    test('different year past', () {
      expect(formatRelative('2024-12-25', asOf: '2025-03-15'), 'December 25th, 2024'); // 5.14
    });
  });

  // ================================================================
  // format_relative — compact skips weekday tiers
  // ================================================================
  group('format_relative — compact', () {
    final sd = SayableDate(getLocale('en')!, Compactness.compact);
    test('today', () {
      expect(sd.formatRelative('2025-03-15', asOf: '2025-03-15'), 'today'); // 6.1
    });
    test('tomorrow', () {
      expect(sd.formatRelative('2025-03-16', asOf: '2025-03-15'), 'tomorrow'); // 6.2
    });
    test('compact goes to numeric', () {
      expect(sd.formatRelative('2025-03-19', asOf: '2025-03-15'), '3/19'); // 6.3
    });
    test('compact with year', () {
      expect(sd.formatRelative('2026-01-05', asOf: '2025-03-15'), '1/5/26'); // 6.4
    });
  });

  // ================================================================
  // Locale — German
  // ================================================================
  group('Locale — German', () {
    final sd = SayableDate(getLocale('de')!);
    test('ordinal dot', () {
      expect(sd.formatDate('2025-03-15'), '15. März'); // 7.1
    });
    test('morgen', () {
      expect(sd.formatRelative('2025-03-16', asOf: '2025-03-15'), 'morgen'); // 7.2
    });
    test('übermorgen', () {
      expect(sd.formatRelative('2025-03-17', asOf: '2025-03-15'), 'übermorgen'); // 7.3
    });
    test('diesen Mittwoch', () {
      expect(sd.formatRelative('2025-03-19', asOf: '2025-03-15'), 'diesen Mittwoch'); // 7.4
    });
  });

  // ================================================================
  // Locale — French
  // ================================================================
  group('Locale — French', () {
    final sd = SayableDate(getLocale('fr')!);
    test('1er mars', () {
      expect(sd.formatDate('2025-03-01'), '1er mars'); // 8.1
    });
    test('15 mars', () {
      expect(sd.formatDate('2025-03-15'), '15 mars'); // 8.2
    });
    test('demain', () {
      expect(sd.formatRelative('2025-03-16', asOf: '2025-03-15'), 'demain'); // 8.3
    });
  });

  // ================================================================
  // Locale — Japanese
  // ================================================================
  group('Locale — Japanese', () {
    final sd = SayableDate(getLocale('ja')!);
    test('3月15日', () {
      expect(sd.formatDate('2025-03-15'), '3月15日'); // 9.1
    });
    test('明日', () {
      expect(sd.formatRelative('2025-03-16', asOf: '2025-03-15'), '明日'); // 9.2
    });
    test('今度の水曜日', () {
      expect(sd.formatRelative('2025-03-19', asOf: '2025-03-15'), '今度の水曜日'); // 9.3
    });
  });

  // ================================================================
  // Locale — Russian (genitive months)
  // ================================================================
  group('Locale — Russian', () {
    final sd = SayableDate(getLocale('ru')!);
    test('genitive month form', () {
      expect(sd.formatDate('2025-03-15'), '15 марта'); // 10.1
    });
    test('завтра', () {
      expect(sd.formatRelative('2025-03-16', asOf: '2025-03-15'), 'завтра'); // 10.2
    });
  });

  // ================================================================
  // Locale — Arabic
  // ================================================================
  group('Locale — Arabic', () {
    final sd = SayableDate(getLocale('ar')!);
    test('15 مارس', () {
      expect(sd.formatDate('2025-03-15'), '15 مارس'); // 11.1
    });
    test('غداً', () {
      expect(sd.formatRelative('2025-03-16', asOf: '2025-03-15'), 'غداً'); // 11.2
    });
  });

  // ================================================================
  // Locale — Spanish
  // ================================================================
  group('Locale — Spanish', () {
    final sd = SayableDate(getLocale('es')!);
    test('15 de marzo', () {
      expect(sd.formatDate('2025-03-15'), '15 de marzo'); // 12.1
    });
    test('pasado mañana', () {
      expect(sd.formatRelative('2025-03-17', asOf: '2025-03-15'), 'pasado mañana'); // 12.2
    });
  });
}

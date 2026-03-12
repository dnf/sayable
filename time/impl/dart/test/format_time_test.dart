import 'package:test/test.dart';
import 'package:sayable_time/src/types.dart';
import 'package:sayable_time/src/format_time.dart';
import 'package:sayable_time/src/locales/locales.dart';

// All tests use explicit inputs for determinism.

void main() {
  // ================================================================
  // Null / edge cases
  // ================================================================
  group('Null / edge cases', () {
    test('null input', () {
      expect(formatTime(null), isNull); // 1.1
    });
    test('empty string', () {
      expect(formatTime(''), isNull); // 1.2
    });
    test('invalid string', () {
      expect(formatTime('invalid'), isNull); // 1.3
    });
    test('out of range', () {
      expect(formatTime('25:00'), isNull); // 1.4
    });
  });

  // ================================================================
  // Clock time (normal compactness)
  // ================================================================
  group('Clock time — normal', () {
    test('midnight', () {
      expect(formatTime('00:00'), 'midnight'); // 2.1
    });
    test('noon', () {
      expect(formatTime('12:00'), 'noon'); // 2.2
    });
    test('o\'clock', () {
      expect(formatTime('15:00'), 'three o\'clock'); // 2.3
    });
    test('quarter past', () {
      expect(formatTime('14:15'), 'a quarter past two'); // 2.4
    });
    test('half past', () {
      expect(formatTime('09:30'), 'half past nine'); // 2.5
    });
    test('quarter to', () {
      expect(formatTime('10:45'), 'a quarter to eleven'); // 2.6
    });
    test('five past', () {
      expect(formatTime('08:05'), 'five past eight'); // 2.7
    });
    test('five to', () {
      expect(formatTime('16:55'), 'five to five'); // 2.8
    });
    test('rounds to midnight', () {
      expect(formatTime('23:58'), 'midnight'); // 2.9
    });
    test('22 rounds to 20', () {
      expect(formatTime('07:22'), 'twenty past seven'); // 2.10
    });
    test('ISO datetime input', () {
      expect(formatTime('2025-01-15T14:15:00'), 'a quarter past two'); // 2.11
    });
  });

  // ================================================================
  // Clock time (short compactness)
  // ================================================================
  group('Clock time — short', () {
    final st = SayableTime(getLocale('en')!, Compactness.short);
    test('PM', () {
      expect(st.formatTime('14:15'), '2:15 PM'); // 3.1
    });
    test('AM', () {
      expect(st.formatTime('09:30'), '9:30 AM'); // 3.2
    });
    test('midnight as 12 AM', () {
      expect(st.formatTime('00:00'), '12:00 AM'); // 3.3
    });
    test('noon as 12 PM', () {
      expect(st.formatTime('12:00'), '12:00 PM'); // 3.4
    });
  });

  // ================================================================
  // Clock time (compact)
  // ================================================================
  group('Clock time — compact', () {
    final st = SayableTime(getLocale('en')!, Compactness.compact);
    test('PM compact', () {
      expect(st.formatTime('14:15'), '2:15p'); // 4.1
    });
    test('AM compact', () {
      expect(st.formatTime('09:30'), '9:30a'); // 4.2
    });
  });

  // ================================================================
  // Locale — German
  // ================================================================
  group('Locale — German', () {
    final st = SayableTime(getLocale('de')!);
    test('half-to pattern', () {
      expect(st.formatTime('15:30'), 'halb vier'); // 5.1
    });
  });

  // ================================================================
  // Locale — French
  // ================================================================
  group('Locale — French', () {
    final st = SayableTime(getLocale('fr')!);
    test('quarter past', () {
      expect(st.formatTime('15:15'), 'trois heures et quart'); // 6.1
    });
  });

  // ================================================================
  // Locale — Japanese
  // ================================================================
  group('Locale — Japanese', () {
    final st = SayableTime(getLocale('ja')!);
    test('half past', () {
      expect(st.formatTime('15:30'), '三時半'); // 7.1
    });
  });

  // ================================================================
  // Locale — Finnish (dot separator, short)
  // ================================================================
  group('Locale — Finnish (dot separator, short)', () {
    final st = SayableTime(getLocale('fi')!, Compactness.short);
    test('dot separator', () {
      expect(st.formatTime('14:15'), '14.15'); // 8.1
    });
    test('midnight dot', () {
      expect(st.formatTime('00:00'), '0.00'); // 8.2
    });
  });
}

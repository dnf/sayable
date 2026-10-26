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
    test('one oclock', () {
      expect(st.formatTime('13:00'), 'une heure'); // 6.2
    });
    test('half past one', () {
      expect(st.formatTime('13:30'), 'une heure et demie'); // 6.3
    });
    test('quarter to three', () {
      expect(st.formatTime('14:45'), 'trois heures moins le quart'); // 6.4
    });
    test('ten to three', () {
      expect(st.formatTime('14:50'), 'trois heures moins dix'); // 6.5
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

  // ================================================================
  // Minutes in short and compact modes
  // ================================================================
  group('Minutes in short and compact modes', () {
    test('short keeps the exact minute', () {
      final st = SayableTime(getLocale('en')!, Compactness.short);
      expect(st.formatTime('18:01'), '6:01 PM'); // 9.1
    });
    test('compact keeps the exact minute', () {
      final st = SayableTime(getLocale('en')!, Compactness.compact);
      expect(st.formatTime('19:05'), '7:05p'); // 9.2
    });
  });

  // ================================================================
  // Input validation
  // ================================================================
  group('Input validation', () {
    test('one-digit hour', () {
      expect(formatTime('9:30'), 'half past nine'); // 10.1
    });
    test('two-digit hour', () {
      expect(formatTime('09:30'), 'half past nine'); // 10.2
    });
    test('leading whitespace', () {
      expect(formatTime(' 9:30'), isNull); // 10.3
    });
    test('trailing whitespace', () {
      expect(formatTime('9:30 '), isNull); // 10.4
    });
    test('minutes need two digits', () {
      expect(formatTime('9:5'), isNull); // 10.5
    });
    test('hour out of range', () {
      expect(formatTime('24:00'), isNull); // 10.6
    });
    test('seconds are allowed and ignored', () {
      expect(formatTime('14:15:30'), 'a quarter past two'); // 10.7
    });
    test('ISO datetime with zone suffix (ignored)', () {
      expect(formatTime('2025-01-15T14:15:00Z'), 'a quarter past two'); // 10.8
    });
    test('ISO datetime with an impossible date', () {
      expect(formatTime('2025-02-30T14:15:00'), isNull); // 10.9
    });
  });
}

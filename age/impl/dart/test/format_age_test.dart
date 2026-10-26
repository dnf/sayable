import 'package:test/test.dart';
import 'package:sayable_age/src/types.dart';
import 'package:sayable_age/src/format_age.dart';
import 'package:sayable_age/src/locales/locales.dart';

// All tests use explicit (dob, asOf) pairs for determinism.

void main() {
  // ================================================================
  // formatAge — null/edge cases
  // ================================================================
  group('formatAge — null/edge cases', () {
    test('empty string', () {
      expect(formatAge('', '2025-06-15'), isNull); // 1.1, 1.3
    });
    test('future dob', () {
      expect(formatAge('2025-07-01', '2025-06-15'), isNull); // 1.4
    });
    test('exactly 500 years', () {
      expect(formatAge('1525-06-15', '2025-06-15'), '500 years'); // 1.5
    });
    test('501 years exceeds max', () {
      expect(formatAge('1524-06-15', '2025-06-15'), isNull); // 1.6
    });
    test('1000 years exceeds max', () {
      expect(formatAge('1025-06-15', '2025-06-15'), isNull); // 1.7
    });
  });

  // ================================================================
  // formatAge — days tier (0–6)
  // ================================================================
  group('formatAge — days tier', () {
    test('born today', () {
      expect(formatAge('2025-06-15', '2025-06-15'), 'Newborn'); // 2.1
    });
    test('1 day ago (singular)', () {
      expect(formatAge('2025-06-14', '2025-06-15'), '1 day'); // 2.2
    });
    test('3 days ago', () {
      expect(formatAge('2025-06-12', '2025-06-15'), '3 days'); // 2.3
    });
    test('6 days ago', () {
      expect(formatAge('2025-06-09', '2025-06-15'), '6 days'); // 2.4
    });
    test('7 days → 1 week', () {
      expect(formatAge('2025-06-08', '2025-06-15'), '1 week'); // 2.5
    });
  });

  // ================================================================
  // formatAge — weeks+days tier (7 days to <3 months)
  // ================================================================
  group('formatAge — weeks+days tier', () {
    test('7 days', () {
      expect(formatAge('2025-06-08', '2025-06-15'), '1 week'); // 3.1
    });
    test('8 days', () {
      expect(formatAge('2025-06-07', '2025-06-15'), '1 week, 1 day'); // 3.2
    });
    test('9 days', () {
      expect(formatAge('2025-06-06', '2025-06-15'), '1 week, 2 days'); // 3.3
    });
    test('13 days', () {
      expect(formatAge('2025-06-02', '2025-06-15'), '1 week, 6 days'); // 3.4
    });
    test('14 days', () {
      expect(formatAge('2025-06-01', '2025-06-15'), '2 weeks'); // 3.5
    });
    test('15 days', () {
      expect(formatAge('2025-05-31', '2025-06-15'), '2 weeks, 1 day'); // 3.6
    });
    test('20 days', () {
      expect(formatAge('2025-05-26', '2025-06-15'), '2 weeks, 6 days'); // 3.7
    });
    test('21 days', () {
      expect(formatAge('2025-05-25', '2025-06-15'), '3 weeks'); // 3.8
    });
    test('at 1 cal month still weeks+days', () {
      expect(formatAge('2025-05-15', '2025-06-15'), '4 weeks, 3 days'); // 3.9
    });
    test('at 2 cal months still weeks+days', () {
      expect(formatAge('2025-04-15', '2025-06-15'), '8 weeks, 5 days'); // 3.10
    });
    test('one day before 3mo still weeks', () {
      expect(formatAge('2025-03-15', '2025-06-14'), '13 weeks'); // 3.11
    });
    test('on 3mo birthday switches', () {
      expect(formatAge('2025-03-15', '2025-06-15'), '3 months'); // 3.12
    });
  });

  // ================================================================
  // formatAge — month boundaries: standard months
  // ================================================================
  group('formatAge — month boundaries standard', () {
    test('Jan1 → Apr1 = 3mo', () {
      expect(formatAge('2025-01-01', '2025-04-01'), '3 months'); // 4.1
    });
    test('Jan1 → Mar31 still weeks', () {
      expect(formatAge('2025-01-01', '2025-03-31'), contains('weeks')); // 4.2
    });
    test('Jun15 → Sep15 = 3mo', () {
      expect(formatAge('2025-06-15', '2025-09-15'), '3 months'); // 4.3
    });
    test('Jun15 → Sep14 still weeks', () {
      expect(formatAge('2025-06-15', '2025-09-14'), contains('weeks')); // 4.4
    });
    test('Jun15 → Dec15 = 6mo', () {
      expect(formatAge('2025-06-15', '2025-12-15'), '6 months'); // 4.5
    });
  });

  // ================================================================
  // formatAge — month boundaries: February non-leap
  // ================================================================
  group('formatAge — month boundaries Feb non-leap', () {
    test('Jan31 → Feb28 non-leap', () {
      expect(formatAge('2025-01-31', '2025-02-28'), '4 weeks'); // 5.1
    });
    test('Jan31 → Apr30 = 3mo (clamp)', () {
      expect(formatAge('2025-01-31', '2025-04-30'), '3 months'); // 5.2
    });
    test('Jan31 → Apr29 still weeks', () {
      expect(formatAge('2025-01-31', '2025-04-29'), contains('weeks')); // 5.3
    });
    test('Feb1 → May1 = 3mo', () {
      expect(formatAge('2025-02-01', '2025-05-01'), '3 months'); // 5.4
    });
    test('Feb1 → Apr30 still weeks', () {
      expect(formatAge('2025-02-01', '2025-04-30'), contains('weeks')); // 5.5
    });
  });

  // ================================================================
  // formatAge — month boundaries: February leap year
  // ================================================================
  group('formatAge — month boundaries Feb leap', () {
    test('Jan31 → Feb29 leap', () {
      expect(formatAge('2024-01-31', '2024-02-29'), '4 weeks, 1 day'); // 6.1
    });
    test('Jan31 → Feb28 leap', () {
      expect(formatAge('2024-01-31', '2024-02-28'), '4 weeks'); // 6.2
    });
    test('Jan31 → Apr30 leap = 3mo', () {
      expect(formatAge('2024-01-31', '2024-04-30'), '3 months'); // 6.3
    });
    test('Jan30 → Feb29 leap still weeks', () {
      expect(formatAge('2024-01-30', '2024-02-29'), contains('weeks')); // 6.4
    });
    test('Jan30 → Feb28 leap still weeks', () {
      expect(formatAge('2024-01-30', '2024-02-28'), contains('weeks')); // 6.5
    });
  });

  // ================================================================
  // formatAge — month boundaries: 30-day months
  // ================================================================
  group('formatAge — month boundaries 30-day', () {
    test('Mar31 → Jun30 = 3mo (clamped)', () {
      expect(formatAge('2025-03-31', '2025-06-30'), '3 months'); // 7.1
    });
    test('Mar31 → Jun29 still weeks', () {
      expect(formatAge('2025-03-31', '2025-06-29'), contains('weeks')); // 7.2
    });
    test('Aug31 → Nov30 = 3mo', () {
      expect(formatAge('2025-08-31', '2025-11-30'), '3 months'); // 7.3
    });
    test('Aug31 → Nov29 still weeks', () {
      expect(formatAge('2025-08-31', '2025-11-29'), contains('weeks')); // 7.4
    });
  });

  // ================================================================
  // formatAge — leap year baby (born Feb 29)
  // ================================================================
  group('formatAge — leap year baby', () {
    test('Feb29 → May29 = 3mo', () {
      expect(formatAge('2024-02-29', '2024-05-29'), '3 months'); // 8.1
    });
    test('Feb29 → May28 still weeks', () {
      expect(formatAge('2024-02-29', '2024-05-28'), contains('weeks')); // 8.2
    });
    test('Feb29 2024 → Feb28 2025 = 12mo', () {
      expect(formatAge('2024-02-29', '2025-02-28'), '12 months'); // 8.3
    });
    test('Feb29 2024 → Mar1 2025 = 12mo', () {
      expect(formatAge('2024-02-29', '2025-03-01'), '12 months'); // 8.4
    });
  });

  // ================================================================
  // formatAge — months tier (3–23)
  // ================================================================
  group('formatAge — months tier', () {
    test('3 months at transition', () {
      expect(formatAge('2025-01-15', '2025-04-15'), '3 months'); // 9.1
    });
    test('6 months', () {
      expect(formatAge('2025-01-15', '2025-07-15'), '6 months'); // 9.2
    });
    test('12 months (not 1 year)', () {
      expect(formatAge('2024-06-15', '2025-06-15'), '12 months'); // 9.3
    });
    test('23 months at upper', () {
      expect(formatAge('2024-01-15', '2025-12-15'), '23 months'); // 9.4
    });
    test('one day before boundary', () {
      expect(formatAge('2025-01-15', '2025-07-14'), '5 months'); // 9.5
    });
    test('crossing year boundary', () {
      expect(formatAge('2024-11-10', '2025-04-10'), '5 months'); // 9.6
    });
  });

  // ================================================================
  // formatAge — years+months tier (24–35 months)
  // ================================================================
  group('formatAge — years+months tier', () {
    test('2 years at 24mo', () {
      expect(formatAge('2023-06-15', '2025-06-15'), '2 years'); // 10.1
    });
    test('2 years 1 month', () {
      expect(formatAge('2023-06-15', '2025-07-15'), '2 years, 1 month'); // 10.2
    });
    test('2 years 6 months', () {
      expect(formatAge('2023-06-15', '2025-12-15'), '2 years, 6 months'); // 10.3
    });
    test('2 years 11 months', () {
      expect(formatAge('2023-06-15', '2026-05-15'), '2 years, 11 months'); // 10.4
    });
    test('one day before 24mo', () {
      expect(formatAge('2023-06-15', '2025-06-14'), '23 months'); // 10.5
    });
  });

  // ================================================================
  // formatAge — half-year tier (3–6 years)
  // ================================================================
  group('formatAge — half-year tier', () {
    test('3 years exactly', () {
      expect(formatAge('2022-06-15', '2025-06-15'), '3 years'); // 11.1
    });
    test('3 years 5 months', () {
      expect(formatAge('2022-06-15', '2025-11-15'), '3 years'); // 11.2
    });
    test('3½ years at 3y6m', () {
      expect(formatAge('2022-06-15', '2025-12-15'), '3\u00BD years'); // 11.3
    });
    test('3½ years at 3y11m', () {
      expect(formatAge('2022-06-15', '2026-05-15'), '3\u00BD years'); // 11.4
    });
    test('4 years exactly', () {
      expect(formatAge('2021-06-15', '2025-06-15'), '4 years'); // 11.5
    });
    test('4½ years', () {
      expect(formatAge('2021-06-15', '2025-12-15'), '4\u00BD years'); // 11.6
    });
    test('5 years', () {
      expect(formatAge('2020-06-15', '2025-06-15'), '5 years'); // 11.7
    });
    test('5½ years at 5y8m', () {
      expect(formatAge('2020-06-15', '2026-02-15'), '5\u00BD years'); // 11.8
    });
    test('6 years', () {
      expect(formatAge('2019-06-15', '2025-06-15'), '6 years'); // 11.9
    });
    test('6½ years', () {
      expect(formatAge('2019-06-15', '2025-12-15'), '6\u00BD years'); // 11.10
    });
    test('6½ years at 6y11m', () {
      expect(formatAge('2019-06-15', '2026-05-15'), '6\u00BD years'); // 11.11
    });
    test('one day before 3rd bday', () {
      expect(formatAge('2022-06-15', '2025-06-14'), '2 years, 11 months'); // 11.12
    });
  });

  // ================================================================
  // formatAge — integer tier (7+ years)
  // ================================================================
  group('formatAge — integer tier', () {
    test('7 years exactly', () {
      expect(formatAge('2018-06-15', '2025-06-15'), '7 years'); // 12.1
    });
    test('7 years 6 months (no ½)', () {
      expect(formatAge('2018-03-20', '2025-06-15'), '7 years'); // 12.2
    });
    test('45 years', () {
      expect(formatAge('1980-01-01', '2025-06-15'), '45 years'); // 12.3
    });
  });

  // ================================================================
  // formatAge — cross-year transitions with Feb
  // ================================================================
  group('formatAge — cross-year Feb', () {
    test('Dec31 → Mar31 = 3mo', () {
      expect(formatAge('2024-12-31', '2025-03-31'), '3 months'); // 13.1
    });
    test('Dec31 → Mar30 still weeks', () {
      expect(formatAge('2024-12-31', '2025-03-30'), contains('weeks')); // 13.2
    });
    test('Nov30 → Feb28 = 3mo', () {
      expect(formatAge('2024-11-30', '2025-02-28'), '3 months'); // 13.3
    });
    test('Nov30 → Feb27 still weeks', () {
      expect(formatAge('2024-11-30', '2025-02-27'), contains('weeks')); // 13.4
    });
  });

  // ================================================================
  // formatAge — born-on-31st progression
  // ================================================================
  group('formatAge — born-on-31st', () {
    test('Jan31 → Apr30 = 3mo', () {
      expect(formatAge('2025-01-31', '2025-04-30'), '3 months'); // 14.1
    });
    test('Jan31 → May31 = 4mo', () {
      expect(formatAge('2025-01-31', '2025-05-31'), '4 months'); // 14.2
    });
    test('Jan31 → Jun30 = 5mo (clamped)', () {
      expect(formatAge('2025-01-31', '2025-06-30'), '5 months'); // 14.3
    });
    test('Jan31 → Jul1 = 5mo', () {
      expect(formatAge('2025-01-31', '2025-07-01'), '5 months'); // 14.4
    });
    test('Jan31 → Jul31 = 6mo', () {
      expect(formatAge('2025-01-31', '2025-07-31'), '6 months'); // 14.5
    });
  });

  // ================================================================
  // formatAge — default asOf (uses current date)
  // ================================================================
  group('formatAge — default asOf', () {
    test('uses clock', () {
      final origClock = clock;
      clock = () => DateTime.utc(2025, 6, 15);
      try {
        expect(formatAge('2020-01-01'), '5 years'); // 15.1
        expect(formatAge('2025-06-10'), '5 days'); // 15.2
      } finally {
        clock = origClock;
      }
    });
  });

  // ================================================================
  // formatStage — null/edge cases
  // ================================================================
  group('formatStage — null/edge cases', () {
    test('empty string', () {
      expect(formatStage('', '2025-06-15'), isNull); // 16.1, 16.3
    });
    test('future dob', () {
      expect(formatStage('2025-07-01', '2025-06-15'), isNull); // 16.4
    });
    test('stage 500 years', () {
      expect(formatStage('1525-06-15', '2025-06-15'), 'Adult'); // 16.5
    });
    test('stage 501 years exceeds max', () {
      expect(formatStage('1524-06-15', '2025-06-15'), isNull); // 16.6
    });
  });

  // ================================================================
  // formatStage — stages
  // ================================================================
  group('formatStage — Newborn', () {
    test('born today', () {
      expect(formatStage('2025-06-15', '2025-06-15'), 'Newborn'); // 17.1
    });
    test('1 day old', () {
      expect(formatStage('2025-06-14', '2025-06-15'), 'Newborn'); // 17.2
    });
    test('3 weeks old', () {
      expect(formatStage('2025-05-25', '2025-06-15'), 'Newborn'); // 17.3
    });
    test('1 month old', () {
      expect(formatStage('2025-05-15', '2025-06-15'), 'Newborn'); // 17.4
    });
    test('1 month 29 days', () {
      expect(formatStage('2025-04-16', '2025-06-15'), 'Newborn'); // 17.5
    });
    test('exactly 2 months → Infant', () {
      expect(formatStage('2025-04-15', '2025-06-15'), 'Infant'); // 17.6
    });
  });

  group('formatStage — Infant', () {
    test('2 months', () {
      expect(formatStage('2025-04-15', '2025-06-15'), 'Infant'); // 18.1
    });
    test('6 months', () {
      expect(formatStage('2024-12-15', '2025-06-15'), 'Infant'); // 18.2
    });
    test('11 months', () {
      expect(formatStage('2024-07-15', '2025-06-15'), 'Infant'); // 18.3
    });
    test('exactly 12mo → Toddler', () {
      expect(formatStage('2024-06-15', '2025-06-15'), 'Toddler'); // 18.4
    });
  });

  group('formatStage — Toddler', () {
    test('12 months', () {
      expect(formatStage('2024-06-15', '2025-06-15'), 'Toddler'); // 19.1
    });
    test('18 months', () {
      expect(formatStage('2024-01-15', '2025-07-15'), 'Toddler'); // 19.2
    });
    test('24 months', () {
      expect(formatStage('2023-06-15', '2025-06-15'), 'Toddler'); // 19.3
    });
    test('35 months', () {
      expect(formatStage('2023-06-15', '2026-05-15'), 'Toddler'); // 19.4
    });
    test('exactly 36mo → Child', () {
      expect(formatStage('2022-06-15', '2025-06-15'), 'Child'); // 19.5
    });
  });

  group('formatStage — Child', () {
    test('3 years', () {
      expect(formatStage('2022-06-15', '2025-06-15'), 'Child'); // 20.1
    });
    test('4 years', () {
      expect(formatStage('2021-06-15', '2025-06-15'), 'Child'); // 20.2
    });
    test('6 years', () {
      expect(formatStage('2019-06-15', '2025-06-15'), 'Child'); // 20.3
    });
    test('9 years', () {
      expect(formatStage('2016-06-15', '2025-06-15'), 'Child'); // 20.4
    });
    test('12y 11mo', () {
      expect(formatStage('2013-06-15', '2026-05-15'), 'Child'); // 20.5
    });
    test('exactly 13y → Teenager', () {
      expect(formatStage('2012-06-15', '2025-06-15'), 'Teenager'); // 20.6
    });
  });

  group('formatStage — Teenager', () {
    test('13 years', () {
      expect(formatStage('2012-06-15', '2025-06-15'), 'Teenager'); // 21.1
    });
    test('15 years', () {
      expect(formatStage('2010-06-15', '2025-06-15'), 'Teenager'); // 21.2
    });
    test('17y 11mo', () {
      expect(formatStage('2008-06-15', '2026-05-15'), 'Teenager'); // 21.3
    });
    test('exactly 18y → Adult', () {
      expect(formatStage('2007-06-15', '2025-06-15'), 'Adult'); // 21.4
    });
  });

  group('formatStage — Adult', () {
    test('18 years', () {
      expect(formatStage('2007-06-15', '2025-06-15'), 'Adult'); // 22.1
    });
    test('25 years', () {
      expect(formatStage('2000-06-15', '2025-06-15'), 'Adult'); // 22.2
    });
    test('45 years', () {
      expect(formatStage('1980-01-01', '2025-06-15'), 'Adult'); // 22.3
    });
  });

  // ================================================================
  // formatStage — default asOf (uses current date)
  // ================================================================
  group('formatStage — default asOf', () {
    test('uses clock', () {
      final origClock = clock;
      clock = () => DateTime.utc(2025, 6, 15);
      try {
        expect(formatStage('2025-06-15'), 'Newborn'); // 23.1
        expect(formatStage('2020-01-01'), 'Child'); // 23.2
        expect(formatStage('1980-01-01'), 'Adult'); // 23.3
      } finally {
        clock = origClock;
      }
    });
  });

  // ================================================================
  // SayableAge class with English locale
  // ================================================================
  group('SayableAge — English', () {
    final pt = SayableAge(getLocale('en')!);

    test('Newborn', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'Newborn'); // 24.1
    });
    test('3 days', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3 days'); // 24.2
    });
    test('1 week 1 day', () {
      expect(pt.formatAge('2025-06-07', '2025-06-15'), '1 week, 1 day'); // 24.3
    });
    test('6 months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6 months'); // 24.4
    });
    test('2y 1mo', () {
      expect(pt.formatAge('2023-06-15', '2025-07-15'), '2 years, 1 month'); // 24.5
    });
    test('3½ years', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3\u00BD years'); // 24.6
    });
    test('7 years', () {
      expect(pt.formatAge('2018-06-15', '2025-06-15'), '7 years'); // 24.7
    });
    test('stage Newborn', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15'), 'Newborn'); // 24.8
    });
    test('stage Infant', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15'), 'Infant'); // 24.9
    });
    test('stage Toddler', () {
      expect(pt.formatStage('2024-06-15', '2025-06-15'), 'Toddler'); // 24.10
    });
    test('stage Child', () {
      expect(pt.formatStage('2022-06-15', '2025-06-15'), 'Child'); // 24.11
    });
    test('stage Teenager', () {
      expect(pt.formatStage('2012-06-15', '2025-06-15'), 'Teenager'); // 24.12
    });
    test('stage Adult', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15'), 'Adult'); // 24.13
    });
    test('null age', () {
      expect(pt.formatAge(''), isNull); // 24.14
    });
    test('null stage', () {
      expect(pt.formatStage(''), isNull); // 24.15
    });
  });

  // ================================================================
  // SayableAge with Spanish locale (inline)
  // ================================================================
  group('SayableAge — Spanish', () {
    final es = AgeLocale(
      code: 'es',
      plural: (int n) => n == 1 ? PluralCategory.one : PluralCategory.other,
      day: pluralUnit({PluralCategory.one: '{n} día', PluralCategory.other: '{n} días'}),
      week: pluralUnit({PluralCategory.one: '{n} semana', PluralCategory.other: '{n} semanas'}),
      month: pluralUnit({PluralCategory.one: '{n} mes', PluralCategory.other: '{n} meses'}),
      year: pluralUnit({PluralCategory.one: '{n} año', PluralCategory.other: '{n} años'}),
      half: '{0} y medio',
      delimiter: ', ',
      justBorn: 'Recién nacido',
      newborn: stageGendered('Recién nacido', 'Recién nacida'),
      infant: stageNeutral('Bebé'),
      toddler: stageGendered('Niño pequeño', 'Niña pequeña'),
      child: stageGendered('Niño', 'Niña'),
      teenager: stageNeutral('Adolescente'),
      adult: stageGendered('Adulto', 'Adulta'),
    );

    final pt = SayableAge(es);

    test('justBorn', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'Recién nacido'); // 25.1
    });
    test('singular day', () {
      expect(pt.formatAge('2025-06-14', '2025-06-15'), '1 día'); // 25.2
    });
    test('plural days', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3 días'); // 25.3
    });
    test('singular week', () {
      expect(pt.formatAge('2025-06-08', '2025-06-15'), '1 semana'); // 25.4
    });
    test('weeks+days', () {
      expect(pt.formatAge('2025-06-07', '2025-06-15'), '1 semana, 1 día'); // 25.5
    });
    test('plural weeks+days', () {
      expect(pt.formatAge('2025-05-26', '2025-06-15'), '2 semanas, 6 días'); // 25.6
    });
    test('months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6 meses'); // 25.7
    });
    test('singular month compound', () {
      expect(pt.formatAge('2023-06-15', '2025-07-15'), '2 años, 1 mes'); // 25.8
    });
    test('years+months', () {
      expect(pt.formatAge('2023-06-15', '2025-12-15'), '2 años, 6 meses'); // 25.9
    });
    test('half marker', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3 años y medio'); // 25.10
    });
    test('integer years', () {
      expect(pt.formatAge('2022-06-15', '2025-06-15'), '3 años'); // 25.11
    });
    test('7+ years', () {
      expect(pt.formatAge('2018-06-15', '2025-06-15'), '7 años'); // 25.12
    });
    test('stage newborn', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15'), 'Recién nacido'); // 25.13
    });
    test('stage infant', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15'), 'Bebé'); // 25.14
    });
    test('stage toddler', () {
      expect(pt.formatStage('2024-06-15', '2025-06-15'), 'Niño pequeño'); // 25.15
    });
    test('stage child', () {
      expect(pt.formatStage('2022-06-15', '2025-06-15'), 'Niño'); // 25.16
    });
    test('stage teenager', () {
      expect(pt.formatStage('2012-06-15', '2025-06-15'), 'Adolescente'); // 25.17
    });
    test('stage adult', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15'), 'Adulto'); // 25.18
    });
    test('null', () {
      expect(pt.formatAge(''), isNull); // 25.19
    });
    test('null stage', () {
      expect(pt.formatStage(''), isNull); // 25.20
    });
  });

  // ================================================================
  // Compactness: short
  // ================================================================
  group('Compactness — short', () {
    final pt = SayableAge(getLocale('en')!, Compactness.short);

    test('days', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3 d'); // 26.1
    });
    test('weeks', () {
      expect(pt.formatAge('2025-06-08', '2025-06-15'), '1 wk'); // 26.2
    });
    test('weeks+days', () {
      expect(pt.formatAge('2025-06-07', '2025-06-15'), '1 wk, 1 d'); // 26.3
    });
    test('months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6 mo'); // 26.4
    });
    test('years+months', () {
      expect(pt.formatAge('2023-06-15', '2025-07-15'), '2 yr, 1 mo'); // 26.5
    });
    test('half years', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3\u00BD yr'); // 26.6
    });
    test('integer years', () {
      expect(pt.formatAge('2018-06-15', '2025-06-15'), '7 yr'); // 26.7
    });
    test('justBorn unchanged', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'Newborn'); // 26.8
    });
    test('stages unchanged', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15'), 'Infant'); // 26.9
    });
  });

  // ================================================================
  // Compactness: compact
  // ================================================================
  group('Compactness — compact', () {
    final pt = SayableAge(getLocale('en')!, Compactness.compact);

    test('days', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3d'); // 27.1
    });
    test('weeks', () {
      expect(pt.formatAge('2025-06-08', '2025-06-15'), '1w'); // 27.2
    });
    test('weeks+days no delimiter', () {
      expect(pt.formatAge('2025-06-07', '2025-06-15'), '1w1d'); // 27.3
    });
    test('months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6m'); // 27.4
    });
    test('years+months no delimiter', () {
      expect(pt.formatAge('2023-06-15', '2025-07-15'), '2y1m'); // 27.5
    });
    test('half years', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3\u00BDy'); // 27.6
    });
    test('integer years', () {
      expect(pt.formatAge('2018-06-15', '2025-06-15'), '7y'); // 27.7
    });
    test('justBorn unchanged', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'Newborn'); // 27.8
    });
  });

  // ================================================================
  // formatStage — gender support
  // ================================================================
  group('formatStage — gender neutral locale', () {
    final pt = SayableAge(getLocale('en')!);

    test('en no gender', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15'), 'Newborn');
    });
    test('en masculine', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'm'), 'Newborn');
    });
    test('en feminine', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'f'), 'Newborn');
    });
    test('en adult no gender', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15'), 'Adult');
    });
    test('en adult m', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'm'), 'Adult');
    });
    test('en adult f', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'f'), 'Adult');
    });
  });

  group('formatStage — gendered locale (Spanish)', () {
    final pt = SayableAge(getLocale('es')!);

    // Default returns masculine for gendered labels
    test('es newborn default', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15'), 'Recién nacido');
    });
    test('es toddler default', () {
      expect(pt.formatStage('2024-06-15', '2025-06-15'), 'Niño pequeño');
    });
    test('es child default', () {
      expect(pt.formatStage('2022-06-15', '2025-06-15'), 'Niño');
    });
    test('es adult default', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15'), 'Adulto');
    });
    // Masculine
    test('es newborn m', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'm'), 'Recién nacido');
    });
    test('es toddler m', () {
      expect(pt.formatStage('2024-06-15', '2025-06-15', 'm'), 'Niño pequeño');
    });
    test('es child m', () {
      expect(pt.formatStage('2022-06-15', '2025-06-15', 'm'), 'Niño');
    });
    test('es adult m', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'm'), 'Adulto');
    });
    // Feminine
    test('es newborn f', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'f'), 'Recién nacida');
    });
    test('es toddler f', () {
      expect(pt.formatStage('2024-06-15', '2025-06-15', 'f'), 'Niña pequeña');
    });
    test('es child f', () {
      expect(pt.formatStage('2022-06-15', '2025-06-15', 'f'), 'Niña');
    });
    test('es adult f', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'f'), 'Adulta');
    });
    // Gender-neutral labels ignore gender
    test('es infant neutral', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15'), 'Bebé');
    });
    test('es infant m', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15', 'm'), 'Bebé');
    });
    test('es infant f', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15', 'f'), 'Bebé');
    });
    test('es teenager neutral', () {
      expect(pt.formatStage('2012-06-15', '2025-06-15'), 'Adolescente');
    });
    test('es teenager m', () {
      expect(pt.formatStage('2012-06-15', '2025-06-15', 'm'), 'Adolescente');
    });
    test('es teenager f', () {
      expect(pt.formatStage('2012-06-15', '2025-06-15', 'f'), 'Adolescente');
    });
  });

  group('formatStage — gendered locale (Arabic)', () {
    final pt = SayableAge(getLocale('ar')!);

    test('ar newborn m', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'm'), 'حديث الولادة');
    });
    test('ar newborn f', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'f'), 'حديثة الولادة');
    });
    test('ar infant m', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15', 'm'), 'رضيع');
    });
    test('ar infant f', () {
      expect(pt.formatStage('2025-01-15', '2025-06-15', 'f'), 'رضيعة');
    });
    test('ar toddler m', () {
      expect(pt.formatStage('2024-06-15', '2025-06-15', 'm'), 'طفل صغير');
    });
    test('ar toddler f', () {
      expect(pt.formatStage('2024-06-15', '2025-06-15', 'f'), 'طفلة صغيرة');
    });
    test('ar child m', () {
      expect(pt.formatStage('2022-06-15', '2025-06-15', 'm'), 'طفل');
    });
    test('ar child f', () {
      expect(pt.formatStage('2022-06-15', '2025-06-15', 'f'), 'طفلة');
    });
    test('ar teenager m', () {
      expect(pt.formatStage('2012-06-15', '2025-06-15', 'm'), 'مراهق');
    });
    test('ar teenager f', () {
      expect(pt.formatStage('2012-06-15', '2025-06-15', 'f'), 'مراهقة');
    });
    test('ar adult m', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'm'), 'بالغ');
    });
    test('ar adult f', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'f'), 'بالغة');
    });
  });

  group('formatStage — gender edge cases', () {
    final pt = SayableAge(getLocale('es')!);

    test('empty dob', () {
      expect(pt.formatStage(''), isNull);
    });
    test('empty dob with gender', () {
      expect(pt.formatStage('', '', 'f'), isNull);
    });
    test('future dob with gender', () {
      expect(pt.formatStage('2025-07-01', '2025-06-15', 'f'), isNull);
    });
  });

  group('formatStage — package-level gender', () {
    test('pkg FormatStage no gender', () {
      expect(formatStage('2007-06-15', '2025-06-15'), 'Adult');
    });
    test('pkg FormatStage m', () {
      expect(formatStage('2007-06-15', '2025-06-15', 'm'), 'Adult');
    });
    test('pkg FormatStage f', () {
      expect(formatStage('2007-06-15', '2025-06-15', 'f'), 'Adult');
    });
  });

  group('resolveStage — direct', () {
    test('neutral no gender', () {
      expect(resolveStage(stageNeutral('Newborn'), ''), 'Newborn');
    });
    test('neutral m', () {
      expect(resolveStage(stageNeutral('Newborn'), 'm'), 'Newborn');
    });
    test('neutral f', () {
      expect(resolveStage(stageNeutral('Newborn'), 'f'), 'Newborn');
    });
    test('gendered no gender', () {
      expect(resolveStage(stageGendered('Adulto', 'Adulta'), ''), 'Adulto');
    });
    test('gendered m', () {
      expect(resolveStage(stageGendered('Adulto', 'Adulta'), 'm'), 'Adulto');
    });
    test('gendered f', () {
      expect(resolveStage(stageGendered('Adulto', 'Adulta'), 'f'), 'Adulta');
    });
  });

  // ================================================================
  // Section 29: Locale-specific edge cases
  // ================================================================
  group('Locale — Hebrew', () {
    final pt = SayableAge(getLocale('he')!);

    test('he justBorn', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'רק נולד'); // 29.1
    });
    test('he 1 day one', () {
      expect(pt.formatAge('2025-06-14', '2025-06-15'), 'יום'); // 29.2
    });
    test('he 3 days other', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3 ימים'); // 29.3
    });
    test('he 2 weeks dual', () {
      expect(pt.formatAge('2025-06-01', '2025-06-15'), 'שבועיים'); // 29.4
    });
    test('he 3 weeks other', () {
      expect(pt.formatAge('2025-05-25', '2025-06-15'), '3 שבועות'); // 29.5
    });
    test('he 6 months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6 חודשים'); // 29.6
    });
    test('he 3 months', () {
      expect(pt.formatAge('2025-03-15', '2025-06-15'), '3 חודשים'); // 29.7
    });
    test('he 2y dual 1m one', () {
      expect(pt.formatAge('2023-06-15', '2025-07-15'), 'שנתיים, חודש'); // 29.8
    });
    test('he 3.5y half', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3 שנים וחצי'); // 29.9
    });
    test('he 7y other', () {
      expect(pt.formatAge('2018-06-15', '2025-06-15'), '7 שנים'); // 29.10
    });
    test('he stage m newborn', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'm'), 'רק נולד'); // 29.11
    });
    test('he stage f newborn', () {
      expect(pt.formatStage('2025-06-15', '2025-06-15', 'f'), 'רק נולדה'); // 29.12
    });
    test('he stage m adult', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'm'), 'מבוגר'); // 29.13
    });
    test('he stage f adult', () {
      expect(pt.formatStage('2007-06-15', '2025-06-15', 'f'), 'מבוגרת'); // 29.14
    });
  });

  group('Locale — Macedonian', () {
    final pt = SayableAge(getLocale('mk')!);

    test('mk justBorn', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'Новороденче'); // 29.15
    });
    test('mk 1 day one', () {
      expect(pt.formatAge('2025-06-14', '2025-06-15'), '1 ден'); // 29.16
    });
    test('mk 3 days other', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3 дена'); // 29.17
    });
    test('mk 6 months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6 месеци'); // 29.18
    });
    test('mk 2y1m one month', () {
      expect(pt.formatAge('2023-06-15', '2025-07-15'), '2 години, 1 месец'); // 29.19
    });
    test('mk 3.5y half', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3 години и пол'); // 29.20
    });
    test('mk 7y', () {
      expect(pt.formatAge('2018-06-15', '2025-06-15'), '7 години'); // 29.21
    });
  });

  group('Locale — Swahili', () {
    final pt = SayableAge(getLocale('sw')!);

    test('sw justBorn', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'Mzaliwa mpya'); // 29.22
    });
    test('sw 1 day', () {
      expect(pt.formatAge('2025-06-14', '2025-06-15'), 'siku 1'); // 29.23
    });
    test('sw 3 days', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), 'siku 3'); // 29.24
    });
    test('sw 6 months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), 'miezi 6'); // 29.25
    });
    test('sw 2y 1m', () {
      expect(pt.formatAge('2023-06-15', '2025-07-15'), 'miaka 2, mwezi 1'); // 29.26
    });
    test('sw 3.5y half', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), 'miaka 3 na nusu'); // 29.27
    });
  });

  group('Locale — Indonesian', () {
    final pt = SayableAge(getLocale('id')!);

    test('id justBorn', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'Baru lahir'); // 29.28
    });
    test('id 1 day', () {
      expect(pt.formatAge('2025-06-14', '2025-06-15'), '1 hari'); // 29.29
    });
    test('id 3 days', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3 hari'); // 29.30
    });
    test('id 6 months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6 bulan'); // 29.31
    });
    test('id 3.5y half', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3 setengah tahun'); // 29.32
    });
    test('id 7y', () {
      expect(pt.formatAge('2018-06-15', '2025-06-15'), '7 tahun'); // 29.33
    });
  });

  group('Locale — Amharic', () {
    final pt = SayableAge(getLocale('am')!);

    test('am justBorn', () {
      expect(pt.formatAge('2025-06-15', '2025-06-15'), 'አዲስ የተወለደ'); // 29.34
    });
    test('am 1 day', () {
      expect(pt.formatAge('2025-06-14', '2025-06-15'), '1 ቀን'); // 29.35
    });
    test('am 3 days', () {
      expect(pt.formatAge('2025-06-12', '2025-06-15'), '3 ቀናት'); // 29.36
    });
    test('am 1w1d ethiopic', () {
      expect(pt.formatAge('2025-06-07', '2025-06-15'), '1 ሳምንት፣ 1 ቀን'); // 29.37
    });
    test('am 6 months', () {
      expect(pt.formatAge('2025-01-15', '2025-07-15'), '6 ወራት'); // 29.38
    });
    test('am 3.5y half', () {
      expect(pt.formatAge('2022-06-15', '2025-12-15'), '3 ዓመታት ተኩል'); // 29.39
    });
  });

  // ================================================================
  // Section 30: Locale lookup by code string
  // ================================================================
  group('Locale lookup', () {
    test('known locale en', () {
      final loc = getLocale('en'); // 30.1
      expect(loc, isNotNull);
      expect(loc!.code, 'en');
    });
    test('known locale fr', () {
      final loc = getLocale('fr'); // 30.2
      expect(loc, isNotNull);
      expect(loc!.code, 'fr');
    });
    test('unknown code', () {
      expect(getLocale('xx'), isNull); // 30.3
    });
    test('empty string', () {
      expect(getLocale(''), isNull); // 30.4
    });
    test('case-sensitive', () {
      expect(getLocale('EN'), isNull); // 30.5
    });
  });

  // ================================================================
  // Section 31: Weeks and days across month ends
  // ================================================================
  group('Weeks and days across month ends', () {
    test('88 days across a 28-day February', () {
      expect(formatAge('2016-12-31', '2017-03-29'), '12 weeks, 4 days'); // 31.1
    });
    test('90 days across a year end into a leap year', () {
      expect(formatAge('1991-11-27', '1992-02-25'), '12 weeks, 6 days'); // 31.2
    });
    test('33 days across a year end', () {
      expect(formatAge('2020-11-30', '2021-01-02'), '4 weeks, 5 days'); // 31.3
    });
    test('compact form of 31.1', () {
      final pt = SayableAge(getLocale('en')!, Compactness.compact);
      expect(pt.formatAge('2016-12-31', '2017-03-29'), '12w4d'); // 31.4
    });
  });

  // ================================================================
  // Section 32: Half years take their plural form from whole years
  // ================================================================
  group('Half years take their plural form from whole years', () {
    test('Polish 3 is few', () {
      final pt = SayableAge(getLocale('pl')!);
      expect(pt.formatAge('2021-06-15', '2025-01-15'), '3 i pół lata'); // 32.1
    });
    test('Polish 5 is many (short)', () {
      final pt = SayableAge(getLocale('pl')!, Compactness.short);
      expect(pt.formatAge('2020-06-15', '2025-12-15'), '5 i pół lat'); // 32.2
    });
    test('Tachelhit 6 is few', () {
      final pt = SayableAge(getLocale('shi')!);
      expect(pt.formatAge('2005-06-08', '2012-06-07'), '6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ'); // 32.3
    });
  });

  // ================================================================
  // Section 33: Input validation
  // ================================================================
  group('Input validation', () {
    test('February 30 does not exist', () {
      expect(formatAge('2025-02-30', '2032-06-25'), isNull); // 33.1
    });
    test('month 13', () {
      expect(formatAge('2025-13-01', '2027-01-31'), isNull); // 33.2
    });
    test('February 29 in a non-leap year', () {
      expect(formatAge('2023-02-29', '2025-03-01'), isNull); // 33.3
    });
    test('day 00', () {
      expect(formatAge('2025-06-00', '2027-02-25'), isNull); // 33.4
    });
    test('unpadded month and day', () {
      expect(formatAge('2025-6-1', '2027-02-25'), isNull); // 33.5
    });
    test('surrounding whitespace', () {
      expect(formatAge(' 2025-06-01', '2027-02-25'), isNull); // 33.6
    });
    test('a datetime is not a date', () {
      expect(formatAge('2025-06-15T10:00:00', '2027-02-25'), isNull); // 33.7
    });
    test('invalid asOf', () {
      expect(formatAge('2020-01-01', '2025-04-31'), isNull); // 33.8
    });
    test('formatStage validates too', () {
      expect(formatStage('2025-02-30', '2027-09-05'), isNull); // 33.9
    });
    test('February 29 in a leap year is valid', () {
      expect(formatAge('2024-02-29', '2026-03-01'), '2 years'); // 33.10
    });
  });
}

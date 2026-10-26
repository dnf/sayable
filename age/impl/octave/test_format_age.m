% Tests for sayable-age — mirrors the canonical test specification.
% All test IDs reference config/tests.json.
%
% Run: octave --no-gui --path . test_format_age.m

addpath('locales');

global test_passed test_failed test_errors;
test_passed = 0;
test_failed = 0;
test_errors = {};

function check(name, actual, expected)
  global test_passed test_failed test_errors;
  if (isempty(expected))
    if (isempty(actual))
      test_passed++;
    else
      test_failed++;
      test_errors{end + 1} = sprintf('FAIL: %s — expected [], got "%s"', name, actual);
    endif
  else
    if (ischar(actual) && strcmp(actual, expected))
      test_passed++;
    else
      test_failed++;
      if (isempty(actual))
        test_errors{end + 1} = sprintf('FAIL: %s — expected "%s", got []', name, expected);
      else
        test_errors{end + 1} = sprintf('FAIL: %s — expected "%s", got "%s"', name, expected, actual);
      endif
    endif
  endif
endfunction

function check_contains(name, actual, substr)
  global test_passed test_failed test_errors;
  if (isempty(actual))
    test_failed++;
    test_errors{end + 1} = sprintf('FAIL: %s — expected string containing "%s", got []', name, substr);
  elseif (isempty(strfind(actual, substr)))
    test_failed++;
    test_errors{end + 1} = sprintf('FAIL: %s — expected "%s" to contain "%s"', name, actual, substr);
  else
    test_passed++;
  endif
endfunction

en = locale_en();
sa = sayable_age_new(en);

% ================================================================
% 1. Null / edge cases
% ================================================================
printf('Section 1: Null / edge cases\n');

% 1.1
check('1.1 null input', format_age('', '2025-06-15'), []);

% 1.3
check('1.3 empty string', format_age('', '2025-06-15'), []);

% 1.4
check('1.4 future dob', format_age('2025-07-01', '2025-06-15'), []);

% 1.5
check('1.5 500 years', format_age('1525-06-15', '2025-06-15'), '500 years');

% 1.6
check('1.6 501 years', format_age('1524-06-15', '2025-06-15'), []);

% 1.7
check('1.7 1000 years', format_age('1025-06-15', '2025-06-15'), []);

% ================================================================
% 2. Days tier (0-6 days)
% ================================================================
printf('Section 2: Days tier\n');

% 2.1
check('2.1 born today', format_age('2025-06-15', '2025-06-15'), 'Newborn');

% 2.2
check('2.2 1 day', format_age('2025-06-14', '2025-06-15'), '1 day');

% 2.3
check('2.3 3 days', format_age('2025-06-12', '2025-06-15'), '3 days');

% 2.4
check('2.4 6 days', format_age('2025-06-09', '2025-06-15'), '6 days');

% 2.5
check('2.5 7 days transitions to weeks', format_age('2025-06-08', '2025-06-15'), '1 week');

% ================================================================
% 3. Weeks+days tier (7 days to <3 calendar months)
% ================================================================
printf('Section 3: Weeks+days tier\n');

% 3.1
check('3.1 exactly 7 days', format_age('2025-06-08', '2025-06-15'), '1 week');

% 3.2
check('3.2 8 days', format_age('2025-06-07', '2025-06-15'), '1 week, 1 day');

% 3.3
check('3.3 9 days', format_age('2025-06-06', '2025-06-15'), '1 week, 2 days');

% 3.4
check('3.4 13 days', format_age('2025-06-02', '2025-06-15'), '1 week, 6 days');

% 3.5
check('3.5 14 days', format_age('2025-06-01', '2025-06-15'), '2 weeks');

% 3.6
check('3.6 15 days', format_age('2025-05-31', '2025-06-15'), '2 weeks, 1 day');

% 3.7
check('3.7 20 days', format_age('2025-05-26', '2025-06-15'), '2 weeks, 6 days');

% 3.8
check('3.8 21 days', format_age('2025-05-25', '2025-06-15'), '3 weeks');

% 3.9
check('3.9 1 month still weeks', format_age('2025-05-15', '2025-06-15'), '4 weeks, 3 days');

% 3.10
check('3.10 2 months still weeks', format_age('2025-04-15', '2025-06-15'), '8 weeks, 5 days');

% 3.11
check('3.11 day before 3-month birthday', format_age('2025-03-15', '2025-06-14'), '13 weeks');

% 3.12
check('3.12 on 3-month birthday', format_age('2025-03-15', '2025-06-15'), '3 months');

% ================================================================
% 4. Month boundaries — standard months
% ================================================================
printf('Section 4: Month boundaries — standard\n');

% 4.1
check('4.1 Jan1 to Apr1', format_age('2025-01-01', '2025-04-01'), '3 months');

% 4.2
check_contains('4.2 Jan1 to Mar31 still weeks', format_age('2025-01-01', '2025-03-31'), 'week');

% 4.3
check('4.3 Jun15 to Sep15', format_age('2025-06-15', '2025-09-15'), '3 months');

% 4.4
check_contains('4.4 Jun15 to Sep14 still weeks', format_age('2025-06-15', '2025-09-14'), 'week');

% 4.5
check('4.5 Jun15 to Dec15', format_age('2025-06-15', '2025-12-15'), '6 months');

% ================================================================
% 5. Month boundaries — February non-leap year
% ================================================================
printf('Section 5: Month boundaries — Feb non-leap\n');

% 5.1
check('5.1 Jan31 to Feb28 non-leap', format_age('2025-01-31', '2025-02-28'), '4 weeks');

% 5.2
check('5.2 Jan31 to Apr30', format_age('2025-01-31', '2025-04-30'), '3 months');

% 5.3
check_contains('5.3 Jan31 to Apr29 still weeks', format_age('2025-01-31', '2025-04-29'), 'week');

% 5.4
check('5.4 Feb1 to May1', format_age('2025-02-01', '2025-05-01'), '3 months');

% 5.5
check_contains('5.5 Feb1 to Apr30 still weeks', format_age('2025-02-01', '2025-04-30'), 'week');

% ================================================================
% 6. Month boundaries — February leap year
% ================================================================
printf('Section 6: Month boundaries — Feb leap\n');

% 6.1
check('6.1 Jan31 to Feb29 leap', format_age('2024-01-31', '2024-02-29'), '4 weeks, 1 day');

% 6.2
check('6.2 Jan31 to Feb28 leap', format_age('2024-01-31', '2024-02-28'), '4 weeks');

% 6.3
check('6.3 Jan31 to Apr30 leap', format_age('2024-01-31', '2024-04-30'), '3 months');

% 6.4
check_contains('6.4 Jan30 to Feb29 leap still weeks', format_age('2024-01-30', '2024-02-29'), 'week');

% 6.5
check_contains('6.5 Jan30 to Feb28 leap still weeks', format_age('2024-01-30', '2024-02-28'), 'week');

% ================================================================
% 7. Month boundaries — 30-day months
% ================================================================
printf('Section 7: Month boundaries — 30-day months\n');

% 7.1
check('7.1 Mar31 to Jun30', format_age('2025-03-31', '2025-06-30'), '3 months');

% 7.2
check_contains('7.2 Mar31 to Jun29 still weeks', format_age('2025-03-31', '2025-06-29'), 'week');

% 7.3
check('7.3 Aug31 to Nov30', format_age('2025-08-31', '2025-11-30'), '3 months');

% 7.4
check_contains('7.4 Aug31 to Nov29 still weeks', format_age('2025-08-31', '2025-11-29'), 'week');

% ================================================================
% 8. Month boundaries — leap year baby (born Feb 29)
% ================================================================
printf('Section 8: Month boundaries — leap year baby\n');

% 8.1
check('8.1 Feb29 to May29', format_age('2024-02-29', '2024-05-29'), '3 months');

% 8.2
check_contains('8.2 Feb29 to May28 still weeks', format_age('2024-02-29', '2024-05-28'), 'week');

% 8.3
check('8.3 Feb29 to Feb28 non-leap', format_age('2024-02-29', '2025-02-28'), '12 months');

% 8.4
check('8.4 Feb29 to Mar1 next year', format_age('2024-02-29', '2025-03-01'), '12 months');

% ================================================================
% 9. Months tier (3-23 months)
% ================================================================
printf('Section 9: Months tier\n');

% 9.1
check('9.1 3 months', format_age('2025-01-15', '2025-04-15'), '3 months');

% 9.2
check('9.2 6 months', format_age('2025-01-15', '2025-07-15'), '6 months');

% 9.3
check('9.3 12 months not 1 year', format_age('2024-06-15', '2025-06-15'), '12 months');

% 9.4
check('9.4 23 months', format_age('2024-01-15', '2025-12-15'), '23 months');

% 9.5
check('9.5 one day before month boundary', format_age('2025-01-15', '2025-07-14'), '5 months');

% 9.6
check('9.6 crossing year boundary', format_age('2024-11-10', '2025-04-10'), '5 months');

% ================================================================
% 10. Years+months tier (24-35 months)
% ================================================================
printf('Section 10: Years+months tier\n');

% 10.1
check('10.1 2 years at 24 months', format_age('2023-06-15', '2025-06-15'), '2 years');

% 10.2
check('10.2 2 years 1 month', format_age('2023-06-15', '2025-07-15'), '2 years, 1 month');

% 10.3
check('10.3 2 years 6 months', format_age('2023-06-15', '2025-12-15'), '2 years, 6 months');

% 10.4
check('10.4 2 years 11 months', format_age('2023-06-15', '2026-05-15'), '2 years, 11 months');

% 10.5
check('10.5 day before 24 months', format_age('2023-06-15', '2025-06-14'), '23 months');

% ================================================================
% 11. Half-year tier (3-6 years)
% ================================================================
printf('Section 11: Half-year tier\n');

half = native2unicode([0xc2 0xbd], 'UTF-8');

% 11.1
check('11.1 3 years exact', format_age('2022-06-15', '2025-06-15'), '3 years');

% 11.2
check('11.2 3 years 5 months', format_age('2022-06-15', '2025-11-15'), '3 years');

% 11.3
check('11.3 3 and half years', format_age('2022-06-15', '2025-12-15'), ['3' half ' years']);

% 11.4
check('11.4 3 years 11 months', format_age('2022-06-15', '2026-05-15'), ['3' half ' years']);

% 11.5
check('11.5 4 years exact', format_age('2021-06-15', '2025-06-15'), '4 years');

% 11.6
check('11.6 4 and half years', format_age('2021-06-15', '2025-12-15'), ['4' half ' years']);

% 11.7
check('11.7 5 years exact', format_age('2020-06-15', '2025-06-15'), '5 years');

% 11.8
check('11.8 5 and half years', format_age('2020-06-15', '2026-02-15'), ['5' half ' years']);

% 11.9
check('11.9 6 years exact', format_age('2019-06-15', '2025-06-15'), '6 years');

% 11.10
check('11.10 6 and half years', format_age('2019-06-15', '2025-12-15'), ['6' half ' years']);

% 11.11
check('11.11 6 years 11 months', format_age('2019-06-15', '2026-05-15'), ['6' half ' years']);

% 11.12
check('11.12 day before 3rd birthday', format_age('2022-06-15', '2025-06-14'), '2 years, 11 months');

% ================================================================
% 12. Integer tier (7+ years)
% ================================================================
printf('Section 12: Integer tier\n');

% 12.1
check('12.1 7 years', format_age('2018-06-15', '2025-06-15'), '7 years');

% 12.2
check('12.2 7.5 years no half', format_age('2018-03-20', '2025-06-15'), '7 years');

% 12.3
check('12.3 45 years', format_age('1980-01-01', '2025-06-15'), '45 years');

% ================================================================
% 13. Cross-year transitions with February
% ================================================================
printf('Section 13: Cross-year transitions with Feb\n');

% 13.1
check('13.1 Dec31 to Mar31', format_age('2024-12-31', '2025-03-31'), '3 months');

% 13.2
check_contains('13.2 Dec31 to Mar30 still weeks', format_age('2024-12-31', '2025-03-30'), 'week');

% 13.3
check('13.3 Nov30 to Feb28', format_age('2024-11-30', '2025-02-28'), '3 months');

% 13.4
check_contains('13.4 Nov30 to Feb27 still weeks', format_age('2024-11-30', '2025-02-27'), 'week');

% ================================================================
% 14. Born-on-31st progression
% ================================================================
printf('Section 14: Born-on-31st progression\n');

% 14.1
check('14.1 Jan31 to Apr30', format_age('2025-01-31', '2025-04-30'), '3 months');

% 14.2
check('14.2 Jan31 to May31', format_age('2025-01-31', '2025-05-31'), '4 months');

% 14.3
check('14.3 Jan31 to Jun30', format_age('2025-01-31', '2025-06-30'), '5 months');

% 14.4
check('14.4 Jan31 to Jul1', format_age('2025-01-31', '2025-07-01'), '5 months');

% 14.5
check('14.5 Jan31 to Jul31', format_age('2025-01-31', '2025-07-31'), '6 months');

% ================================================================
% 15. Default asOf (current date)
% ================================================================
printf('Section 15: Default asOf\n');

% There is no way to inject "today", so these dates are derived from the real
% current date (local time, like the library) to keep the canonical outputs.
v = clock();
today_iso = sprintf('%04d-%02d-%02d', v(1), v(2), v(3));
five_years_ago = sprintf('%04d-%02d-%02d', v(1) - 5, v(2), min(v(3), 28));
forty_five_years_ago = sprintf('%04d-%02d-%02d', v(1) - 45, v(2), min(v(3), 28));
five_days_ago = datestr(datenum(v(1), v(2), v(3)) - 5, 'yyyy-mm-dd');

% 15.1
check('15.1 default as_of 5 years', format_age(five_years_ago), '5 years');
% 15.2
check('15.2 default as_of 5 days', format_age(five_days_ago), '5 days');

% ================================================================
% 16. formatStage null/edge cases
% ================================================================
printf('Section 16: formatStage null/edge cases\n');

% 16.1
check('16.1 null', format_stage('', '2025-06-15'), []);

% 16.3
check('16.3 empty string', format_stage('', '2025-06-15'), []);

% 16.4
check('16.4 future dob', format_stage('2025-07-01', '2025-06-15'), []);

% 16.5
check('16.5 500 years', format_stage('1525-06-15', '2025-06-15'), 'Adult');

% 16.6
check('16.6 501 years', format_stage('1524-06-15', '2025-06-15'), []);

% ================================================================
% 17. formatStage — Newborn (0-1 months)
% ================================================================
printf('Section 17: formatStage — Newborn\n');

% 17.1
check('17.1 born today', format_stage('2025-06-15', '2025-06-15'), 'Newborn');

% 17.2
check('17.2 1 day', format_stage('2025-06-14', '2025-06-15'), 'Newborn');

% 17.3
check('17.3 3 weeks', format_stage('2025-05-25', '2025-06-15'), 'Newborn');

% 17.4
check('17.4 1 month', format_stage('2025-05-15', '2025-06-15'), 'Newborn');

% 17.5
check('17.5 1 month 29 days', format_stage('2025-04-16', '2025-06-15'), 'Newborn');

% 17.6
check('17.6 exactly 2 months', format_stage('2025-04-15', '2025-06-15'), 'Infant');

% ================================================================
% 18. formatStage — Infant (2-11 months)
% ================================================================
printf('Section 18: formatStage — Infant\n');

% 18.1
check('18.1 2 months', format_stage('2025-04-15', '2025-06-15'), 'Infant');

% 18.2
check('18.2 6 months', format_stage('2024-12-15', '2025-06-15'), 'Infant');

% 18.3
check('18.3 11 months', format_stage('2024-07-15', '2025-06-15'), 'Infant');

% 18.4
check('18.4 12 months becomes toddler', format_stage('2024-06-15', '2025-06-15'), 'Toddler');

% ================================================================
% 19. formatStage — Toddler (12-35 months)
% ================================================================
printf('Section 19: formatStage — Toddler\n');

% 19.1
check('19.1 12 months', format_stage('2024-06-15', '2025-06-15'), 'Toddler');

% 19.2
check('19.2 18 months', format_stage('2024-01-15', '2025-07-15'), 'Toddler');

% 19.3
check('19.3 24 months', format_stage('2023-06-15', '2025-06-15'), 'Toddler');

% 19.4
check('19.4 35 months', format_stage('2023-06-15', '2026-05-15'), 'Toddler');

% 19.5
check('19.5 36 months becomes child', format_stage('2022-06-15', '2025-06-15'), 'Child');

% ================================================================
% 20. formatStage — Child (36-155 months)
% ================================================================
printf('Section 20: formatStage — Child\n');

% 20.1
check('20.1 3 years', format_stage('2022-06-15', '2025-06-15'), 'Child');

% 20.2
check('20.2 4 years', format_stage('2021-06-15', '2025-06-15'), 'Child');

% 20.3
check('20.3 6 years', format_stage('2019-06-15', '2025-06-15'), 'Child');

% 20.4
check('20.4 9 years', format_stage('2016-06-15', '2025-06-15'), 'Child');

% 20.5
check('20.5 12 years 11 months', format_stage('2013-06-15', '2026-05-15'), 'Child');

% 20.6
check('20.6 13 years becomes teenager', format_stage('2012-06-15', '2025-06-15'), 'Teenager');

% ================================================================
% 21. formatStage — Teenager (156-215 months)
% ================================================================
printf('Section 21: formatStage — Teenager\n');

% 21.1
check('21.1 13 years', format_stage('2012-06-15', '2025-06-15'), 'Teenager');

% 21.2
check('21.2 15 years', format_stage('2010-06-15', '2025-06-15'), 'Teenager');

% 21.3
check('21.3 17 years 11 months', format_stage('2008-06-15', '2026-05-15'), 'Teenager');

% 21.4
check('21.4 18 years becomes adult', format_stage('2007-06-15', '2025-06-15'), 'Adult');

% ================================================================
% 22. formatStage — Adult (216+ months)
% ================================================================
printf('Section 22: formatStage — Adult\n');

% 22.1
check('22.1 18 years', format_stage('2007-06-15', '2025-06-15'), 'Adult');

% 22.2
check('22.2 25 years', format_stage('2000-06-15', '2025-06-15'), 'Adult');

% 22.3
check('22.3 45 years', format_stage('1980-01-01', '2025-06-15'), 'Adult');

% ================================================================
% 23. formatStage — default asOf
% ================================================================
printf('Section 23: formatStage — default asOf\n');

% Dates derived from the real current date, see section 15.
% 23.1
check('23.1 newborn', format_stage(today_iso), 'Newborn');
% 23.2
check('23.2 child', format_stage(five_years_ago), 'Child');
% 23.3
check('23.3 adult', format_stage(forty_five_years_ago), 'Adult');

% ================================================================
% 24. SayableAge class — English locale delegation
% ================================================================
printf('Section 24: SayableAge English locale\n');

% 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
check('24.1 newborn', sa.format_age('2025-06-15', '2025-06-15'), 'Newborn');
check('24.2 3 days', sa.format_age('2025-06-12', '2025-06-15'), '3 days');
check('24.3 1w 1d', sa.format_age('2025-06-07', '2025-06-15'), '1 week, 1 day');
check('24.4 6 months', sa.format_age('2025-01-15', '2025-07-15'), '6 months');
check('24.5 2y 1m', sa.format_age('2023-06-15', '2025-07-15'), '2 years, 1 month');
check('24.6 3.5 years', sa.format_age('2022-06-15', '2025-12-15'), ['3' half ' years']);
check('24.7 7 years', sa.format_age('2018-06-15', '2025-06-15'), '7 years');

% 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
check('24.8 stage newborn', sa.format_stage('2025-06-15', '2025-06-15', ''), 'Newborn');
check('24.9 stage infant', sa.format_stage('2025-01-15', '2025-06-15', ''), 'Infant');
check('24.10 stage toddler', sa.format_stage('2024-06-15', '2025-06-15', ''), 'Toddler');
check('24.11 stage child', sa.format_stage('2022-06-15', '2025-06-15', ''), 'Child');
check('24.12 stage teenager', sa.format_stage('2012-06-15', '2025-06-15', ''), 'Teenager');
check('24.13 stage adult', sa.format_stage('2007-06-15', '2025-06-15', ''), 'Adult');

% 24.14, 24.15
check('24.14 null format_age', sa.format_age('', '2025-06-15'), []);
check('24.15 null format_stage', sa.format_stage('', '2025-06-15', ''), []);

% ================================================================
% 25. i18n — Spanish locale
% ================================================================
printf('Section 25: i18n — Spanish locale\n');

es = locale_es();
sa_es = sayable_age_new(es);

% 25.1
check('25.1 just born', sa_es.format_age('2025-06-15', '2025-06-15'), 'Recién nacido');

% 25.2
check('25.2 singular day', sa_es.format_age('2025-06-14', '2025-06-15'), '1 día');

% 25.3
check('25.3 plural days', sa_es.format_age('2025-06-12', '2025-06-15'), '3 días');

% 25.4
check('25.4 singular week', sa_es.format_age('2025-06-08', '2025-06-15'), '1 semana');

% 25.5
check('25.5 compound weeks days', sa_es.format_age('2025-06-07', '2025-06-15'), '1 semana, 1 día');

% 25.6
check('25.6 plural weeks days', sa_es.format_age('2025-05-26', '2025-06-15'), '2 semanas, 6 días');

% 25.7
check('25.7 months', sa_es.format_age('2025-01-15', '2025-07-15'), '6 meses');

% 25.8
check('25.8 singular month', sa_es.format_age('2023-06-15', '2025-07-15'), '2 años, 1 mes');

% 25.9
check('25.9 years months', sa_es.format_age('2023-06-15', '2025-12-15'), '2 años, 6 meses');

% 25.10
check('25.10 half marker', sa_es.format_age('2022-06-15', '2025-12-15'), '3 años y medio');

% 25.11
check('25.11 integer years', sa_es.format_age('2022-06-15', '2025-06-15'), '3 años');

% 25.12
check('25.12 7+ years', sa_es.format_age('2018-06-15', '2025-06-15'), '7 años');

% 25.13, 25.14, 25.15, 25.16, 25.17, 25.18
check('25.13 stage newborn', sa_es.format_stage('2025-06-15', '2025-06-15', ''), 'Recién nacido');
check('25.14 stage infant', sa_es.format_stage('2025-01-15', '2025-06-15', ''), 'Bebé');
check('25.15 stage toddler', sa_es.format_stage('2024-06-15', '2025-06-15', ''), 'Niño pequeño');
check('25.16 stage child', sa_es.format_stage('2022-06-15', '2025-06-15', ''), 'Niño');
check('25.17 stage teenager', sa_es.format_stage('2012-06-15', '2025-06-15', ''), 'Adolescente');
check('25.18 stage adult', sa_es.format_stage('2007-06-15', '2025-06-15', ''), 'Adulto');

% 25.19, 25.20
check('25.19 null', sa_es.format_age('', '2025-06-15'), []);
check('25.20 null stage', sa_es.format_stage('', '2025-06-15', ''), []);

% ================================================================
% 26. Compactness — short
% ================================================================
printf('Section 26: Compactness — short\n');

sa_short = sayable_age_new(en, 'short');

% 26.1
check('26.1 days', sa_short.format_age('2025-06-12', '2025-06-15'), '3 d');

% 26.2
check('26.2 weeks', sa_short.format_age('2025-06-08', '2025-06-15'), '1 wk');

% 26.3
check('26.3 weeks days', sa_short.format_age('2025-06-07', '2025-06-15'), '1 wk, 1 d');

% 26.4
check('26.4 months', sa_short.format_age('2025-01-15', '2025-07-15'), '6 mo');

% 26.5
check('26.5 years months', sa_short.format_age('2023-06-15', '2025-07-15'), '2 yr, 1 mo');

% 26.6
check('26.6 half years', sa_short.format_age('2022-06-15', '2025-12-15'), ['3' half ' yr']);

% 26.7
check('26.7 integer years', sa_short.format_age('2018-06-15', '2025-06-15'), '7 yr');

% 26.8
check('26.8 just born unchanged', sa_short.format_age('2025-06-15', '2025-06-15'), 'Newborn');

% 26.9
check('26.9 stages unchanged', sa_short.format_stage('2025-01-15', '2025-06-15', ''), 'Infant');

% ================================================================
% 27. Compactness — compact
% ================================================================
printf('Section 27: Compactness — compact\n');

sa_compact = sayable_age_new(en, 'compact');

% 27.1
check('27.1 days', sa_compact.format_age('2025-06-12', '2025-06-15'), '3d');

% 27.2
check('27.2 weeks', sa_compact.format_age('2025-06-08', '2025-06-15'), '1w');

% 27.3
check('27.3 weeks days no delimiter', sa_compact.format_age('2025-06-07', '2025-06-15'), '1w1d');

% 27.4
check('27.4 months', sa_compact.format_age('2025-01-15', '2025-07-15'), '6m');

% 27.5
check('27.5 years months', sa_compact.format_age('2023-06-15', '2025-07-15'), '2y1m');

% 27.6
check('27.6 half years', sa_compact.format_age('2022-06-15', '2025-12-15'), ['3' half 'y']);

% 27.7
check('27.7 integer years', sa_compact.format_age('2018-06-15', '2025-06-15'), '7y');

% 27.8
check('27.8 just born', sa_compact.format_age('2025-06-15', '2025-06-15'), 'Newborn');

% ================================================================
% 29. Locale-specific edge cases — plural rules
% ================================================================
printf('Section 29: Locale-specific edge cases\n');

% 29.1-29.14 — Hebrew
he = locale_he();
sa_he = sayable_age_new(he);

check('29.1 he just born', sa_he.format_age('2025-06-15', '2025-06-15'), 'רק נולד');
check('29.2 he one day', sa_he.format_age('2025-06-14', '2025-06-15'), 'יום');
check('29.3 he three days', sa_he.format_age('2025-06-12', '2025-06-15'), '3 ימים');
check('29.4 he two weeks dual', sa_he.format_age('2025-06-01', '2025-06-15'), 'שבועיים');
check('29.5 he three weeks', sa_he.format_age('2025-05-25', '2025-06-15'), '3 שבועות');
check('29.6 he six months', sa_he.format_age('2025-01-15', '2025-07-15'), '6 חודשים');
check('29.7 he three months', sa_he.format_age('2025-03-15', '2025-06-15'), '3 חודשים');
check('29.8 he 2y 1m', sa_he.format_age('2023-06-15', '2025-07-15'), 'שנתיים, חודש');
check('29.9 he half years', sa_he.format_age('2022-06-15', '2025-12-15'), '3 שנים וחצי');
check('29.10 he seven years', sa_he.format_age('2018-06-15', '2025-06-15'), '7 שנים');
check('29.11 he stage m newborn', sa_he.format_stage('2025-06-15', '2025-06-15', 'm'), 'רק נולד');
check('29.12 he stage f newborn', sa_he.format_stage('2025-06-15', '2025-06-15', 'f'), 'רק נולדה');
check('29.13 he stage m adult', sa_he.format_stage('2007-06-15', '2025-06-15', 'm'), 'מבוגר');
check('29.14 he stage f adult', sa_he.format_stage('2007-06-15', '2025-06-15', 'f'), 'מבוגרת');

% 29.15-29.21 — Macedonian
mk = locale_mk();
sa_mk = sayable_age_new(mk);

check('29.15 mk just born', sa_mk.format_age('2025-06-15', '2025-06-15'), 'Новороденче');
check('29.16 mk one day', sa_mk.format_age('2025-06-14', '2025-06-15'), '1 ден');
check('29.17 mk three days', sa_mk.format_age('2025-06-12', '2025-06-15'), '3 дена');
check('29.18 mk six months', sa_mk.format_age('2025-01-15', '2025-07-15'), '6 месеци');
check('29.19 mk 2y 1m', sa_mk.format_age('2023-06-15', '2025-07-15'), '2 години, 1 месец');
check('29.20 mk half years', sa_mk.format_age('2022-06-15', '2025-12-15'), '3 години и пол');
check('29.21 mk seven years', sa_mk.format_age('2018-06-15', '2025-06-15'), '7 години');

% 29.22-29.27 — Swahili
sw = locale_sw();
sa_sw = sayable_age_new(sw);

check('29.22 sw just born', sa_sw.format_age('2025-06-15', '2025-06-15'), 'Mzaliwa mpya');
check('29.23 sw one day', sa_sw.format_age('2025-06-14', '2025-06-15'), 'siku 1');
check('29.24 sw three days', sa_sw.format_age('2025-06-12', '2025-06-15'), 'siku 3');
check('29.25 sw six months', sa_sw.format_age('2025-01-15', '2025-07-15'), 'miezi 6');
check('29.26 sw 2y 1m', sa_sw.format_age('2023-06-15', '2025-07-15'), 'miaka 2, mwezi 1');
check('29.27 sw half years', sa_sw.format_age('2022-06-15', '2025-12-15'), 'miaka 3 na nusu');

% 29.28-29.33 — Indonesian
id_loc = locale_id();
sa_id = sayable_age_new(id_loc);

check('29.28 id just born', sa_id.format_age('2025-06-15', '2025-06-15'), 'Baru lahir');
check('29.29 id one day', sa_id.format_age('2025-06-14', '2025-06-15'), '1 hari');
check('29.30 id three days', sa_id.format_age('2025-06-12', '2025-06-15'), '3 hari');
check('29.31 id six months', sa_id.format_age('2025-01-15', '2025-07-15'), '6 bulan');
check('29.32 id half years', sa_id.format_age('2022-06-15', '2025-12-15'), '3 setengah tahun');
check('29.33 id seven years', sa_id.format_age('2018-06-15', '2025-06-15'), '7 tahun');

% 29.34-29.39 — Amharic
am = locale_am();
sa_am = sayable_age_new(am);

check('29.34 am just born', sa_am.format_age('2025-06-15', '2025-06-15'), 'አዲስ የተወለደ');
check('29.35 am one day', sa_am.format_age('2025-06-14', '2025-06-15'), '1 ቀን');
check('29.36 am three days', sa_am.format_age('2025-06-12', '2025-06-15'), '3 ቀናት');
check('29.37 am 1w 1d', sa_am.format_age('2025-06-07', '2025-06-15'), '1 ሳምንት፣ 1 ቀን');
check('29.38 am six months', sa_am.format_age('2025-01-15', '2025-07-15'), '6 ወራት');
check('29.39 am half years', sa_am.format_age('2022-06-15', '2025-12-15'), '3 ዓመታት ተኩል');

% ================================================================
% 30. Locale lookup by code string
% ================================================================
printf('Section 30: Locale lookup\n');

% 30.1
loc = get_locale('en');
if (!isempty(loc) && isfield(loc, 'code') && strcmp(loc.code, 'en'))
  test_passed++;
else
  test_failed++;
  test_errors{end + 1} = 'FAIL: 30.1 known locale en';
endif

% 30.2
loc = get_locale('fr');
if (!isempty(loc) && isfield(loc, 'code') && strcmp(loc.code, 'fr'))
  test_passed++;
else
  test_failed++;
  test_errors{end + 1} = 'FAIL: 30.2 known locale fr';
endif

% 30.3
loc = get_locale('xx');
if (isempty(loc))
  test_passed++;
else
  test_failed++;
  test_errors{end + 1} = 'FAIL: 30.3 unknown code should be []';
endif

% 30.4
loc = get_locale('');
if (isempty(loc))
  test_passed++;
else
  test_failed++;
  test_errors{end + 1} = 'FAIL: 30.4 empty string should be []';
endif

% 30.5
loc = get_locale('EN');
if (isempty(loc))
  test_passed++;
else
  test_failed++;
  test_errors{end + 1} = 'FAIL: 30.5 case sensitive should be []';
endif

% ================================================================
% 31. Weeks and days across month ends
% ================================================================
printf('Section 31: Weeks and days across month ends\n');

% 31.1
check('31.1 across a 28-day February', format_age('2016-12-31', '2017-03-29'), '12 weeks, 4 days');

% 31.2
check('31.2 across a year end into a leap year', format_age('1991-11-27', '1992-02-25'), '12 weeks, 6 days');

% 31.3
check('31.3 across a year end', format_age('2020-11-30', '2021-01-02'), '4 weeks, 5 days');

% 31.4
check('31.4 compact', format_age('2016-12-31', '2017-03-29', en, 'compact'), '12w4d');

% ================================================================
% 32. Half years take their plural form from whole years
% ================================================================
printf('Section 32: Half-year plurals\n');

% 32.1
check('32.1 pl 3 is few', format_age('2021-06-15', '2025-01-15', locale_pl()), '3 i pół lata');

% 32.2
check('32.2 pl short 5 is many', format_age('2020-06-15', '2025-12-15', locale_pl(), 'short'), '5 i pół lat');

% 32.3
check('32.3 shi 6 is few', format_age('2005-06-08', '2012-06-07', locale_shi()), '6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ');

% ================================================================
% 33. Input validation
% ================================================================
printf('Section 33: Input validation\n');

% 33.1
check('33.1 February 30', format_age('2025-02-30', '2032-06-25'), []);

% 33.2
check('33.2 month 13', format_age('2025-13-01', '2027-01-31'), []);

% 33.3
check('33.3 February 29 in a non-leap year', format_age('2023-02-29', '2025-03-01'), []);

% 33.4
check('33.4 day 00', format_age('2025-06-00', '2027-02-25'), []);

% 33.5
check('33.5 unpadded', format_age('2025-6-1', '2027-02-25'), []);

% 33.6
check('33.6 surrounding whitespace', format_age(' 2025-06-01', '2027-02-25'), []);

% 33.7
check('33.7 datetime', format_age('2025-06-15T10:00:00', '2027-02-25'), []);

% 33.8
check('33.8 invalid asOf', format_age('2020-01-01', '2025-04-31'), []);

% 33.9
check('33.9 formatStage validates', format_stage('2025-02-30', '2027-09-05'), []);

% 33.10
check('33.10 February 29 in a leap year', format_age('2024-02-29', '2026-03-01'), '2 years');

% ================================================================
% Summary
% ================================================================
printf('\n');
printf('========================================\n');
printf('Results: %d passed, %d failed\n', test_passed, test_failed);
printf('========================================\n');

for i = 1:length(test_errors)
  printf('%s\n', test_errors{i});
endfor

if (test_failed > 0)
  exit(1);
endif

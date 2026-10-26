% Tests for sayable-date — mirrors the canonical test specification.
% All test IDs reference config/tests.json.
%
% Run: octave --no-gui --path . test_format_date.m

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

en = locale_en();
sd = sayable_date_new(en);

% ================================================================
% 1. Null / edge cases
% ================================================================
printf('Section 1: Null / edge cases\n');

% 1.1
check('1.1 null', sd.format_date([]), []);

% 1.2
check('1.2 empty string', sd.format_date(''), []);

% 1.3
check('1.3 invalid', sd.format_date('invalid'), []);

% 1.4
check('1.4 relative null asOf', sd.format_relative('2025-03-15', []), []);

% 1.5
check('1.5 relative null date', sd.format_relative([], '2025-03-15'), []);

% ================================================================
% 2. format_date — normal compactness (English)
% ================================================================
printf('Section 2: format_date — normal\n');

% 2.1
check('2.1 March 15th', sd.format_date('2025-03-15'), 'March 15th');

% 2.2
check('2.2 January 1st', sd.format_date('2025-01-01'), 'January 1st');

% 2.3
check('2.3 May 22nd', sd.format_date('2025-05-22'), 'May 22nd');

% 2.4
check('2.4 July 3rd', sd.format_date('2025-07-03'), 'July 3rd');

% 2.5
check('2.5 December 31st', sd.format_date('2025-12-31'), 'December 31st');

% 2.6
check('2.6 June 11th', sd.format_date('2025-06-11'), 'June 11th');

% 2.7
check('2.7 ISO datetime input', sd.format_date('2025-03-15T14:30:00'), 'March 15th');

% ================================================================
% 3. format_date — short compactness (English)
% ================================================================
printf('Section 3: format_date — short\n');

sd_short = sayable_date_new(en, 'short');

% 3.1
check('3.1 short Mar 15', sd_short.format_date('2025-03-15'), 'Mar 15');

% 3.2
check('3.2 short Jan 1', sd_short.format_date('2025-01-01'), 'Jan 1');

% 3.3
check('3.3 short Dec 25', sd_short.format_date('2025-12-25'), 'Dec 25');

% ================================================================
% 4. format_date — compact (English)
% ================================================================
printf('Section 4: format_date — compact\n');

sd_compact = sayable_date_new(en, 'compact');

% 4.1
check('4.1 compact 3/15', sd_compact.format_date('2025-03-15'), '3/15');

% 4.2
check('4.2 compact 1/1', sd_compact.format_date('2025-01-01'), '1/1');

% ================================================================
% 5. format_relative — proximity tiers (English)
% ================================================================
printf('Section 5: format_relative — proximity\n');

% 5.1
check('5.1 today', sd.format_relative('2025-03-15', '2025-03-15'), 'today');

% 5.2
check('5.2 tomorrow', sd.format_relative('2025-03-16', '2025-03-15'), 'tomorrow');

% 5.3
check('5.3 yesterday', sd.format_relative('2025-03-14', '2025-03-15'), 'yesterday');

% 5.4
check('5.4 day after tomorrow', sd.format_relative('2025-03-17', '2025-03-15'), 'the day after tomorrow');

% 5.5
check('5.5 day before yesterday', sd.format_relative('2025-03-13', '2025-03-15'), 'the day before yesterday');

% 5.6
check('5.6 this Wednesday', sd.format_relative('2025-03-19', '2025-03-15'), 'this Wednesday');

% 5.7
check('5.7 this Thursday', sd.format_relative('2025-03-20', '2025-03-15'), 'this Thursday');

% 5.8
check('5.8 last Tuesday', sd.format_relative('2025-03-11', '2025-03-15'), 'last Tuesday');

% 5.9
check('5.9 next Saturday', sd.format_relative('2025-03-22', '2025-03-15'), 'next Saturday');

% 5.10
check('5.10 next Thursday', sd.format_relative('2025-03-27', '2025-03-15'), 'next Thursday');

% 5.11
check('5.11 calendar fallback same year', sd.format_relative('2025-03-01', '2025-03-15'), 'March 1st');

% 5.12
check('5.12 calendar fallback same year', sd.format_relative('2025-04-10', '2025-03-15'), 'April 10th');

% 5.13
check('5.13 different year', sd.format_relative('2026-01-05', '2025-03-15'), 'January 5th, 2026');

% 5.14
check('5.14 past year', sd.format_relative('2024-12-25', '2025-03-15'), 'December 25th, 2024');

% ================================================================
% 6. format_relative — compact skips weekday tiers
% ================================================================
printf('Section 6: format_relative — compact\n');

% 6.1
check('6.1 compact today', sd_compact.format_relative('2025-03-15', '2025-03-15'), 'today');

% 6.2
check('6.2 compact tomorrow', sd_compact.format_relative('2025-03-16', '2025-03-15'), 'tomorrow');

% 6.3
check('6.3 compact numeric', sd_compact.format_relative('2025-03-19', '2025-03-15'), '3/19');

% 6.4
check('6.4 compact different year', sd_compact.format_relative('2026-01-05', '2025-03-15'), '1/5/26');

% ================================================================
% 7. Locale — German
% ================================================================
printf('Section 7: Locale — German\n');

de = locale_de();
sd_de = sayable_date_new(de);

% 7.1
check('7.1 de format_date', sd_de.format_date('2025-03-15'), '15. März');

% 7.2
check('7.2 de tomorrow', sd_de.format_relative('2025-03-16', '2025-03-15'), 'morgen');

% 7.3
check('7.3 de day after tomorrow', sd_de.format_relative('2025-03-17', '2025-03-15'), 'übermorgen');

% 7.4
check('7.4 de this Wednesday', sd_de.format_relative('2025-03-19', '2025-03-15'), 'diesen Mittwoch');

% ================================================================
% 8. Locale — French
% ================================================================
printf('Section 8: Locale — French\n');

fr = locale_fr();
sd_fr = sayable_date_new(fr);

% 8.1
check('8.1 fr 1er mars', sd_fr.format_date('2025-03-01'), '1er mars');

% 8.2
check('8.2 fr 15 mars', sd_fr.format_date('2025-03-15'), '15 mars');

% 8.3
check('8.3 fr demain', sd_fr.format_relative('2025-03-16', '2025-03-15'), 'demain');

% ================================================================
% 9. Locale — Japanese
% ================================================================
printf('Section 9: Locale — Japanese\n');

ja = locale_ja();
sd_ja = sayable_date_new(ja);

% 9.1
check('9.1 ja date', sd_ja.format_date('2025-03-15'), '3月15日');

% 9.2
check('9.2 ja tomorrow', sd_ja.format_relative('2025-03-16', '2025-03-15'), '明日');

% 9.3
check('9.3 ja this Wednesday', sd_ja.format_relative('2025-03-19', '2025-03-15'), '今度の水曜日');

% ================================================================
% 10. Locale — Russian (genitive months)
% ================================================================
printf('Section 10: Locale — Russian\n');

ru = locale_ru();
sd_ru = sayable_date_new(ru);

% 10.1
check('10.1 ru genitive month', sd_ru.format_date('2025-03-15'), '15 марта');

% 10.2
check('10.2 ru tomorrow', sd_ru.format_relative('2025-03-16', '2025-03-15'), 'завтра');

% ================================================================
% 11. Locale — Arabic
% ================================================================
printf('Section 11: Locale — Arabic\n');

ar = locale_ar();
sd_ar = sayable_date_new(ar);

% 11.1
check('11.1 ar date', sd_ar.format_date('2025-03-15'), '15 مارس');

% 11.2
check('11.2 ar tomorrow', sd_ar.format_relative('2025-03-16', '2025-03-15'), 'غداً');

% ================================================================
% 12. Locale — Spanish
% ================================================================
printf('Section 12: Locale — Spanish\n');

es = locale_es();
sd_es = sayable_date_new(es);

% 12.1
check('12.1 es date', sd_es.format_date('2025-03-15'), '15 de marzo');

% 12.2
check('12.2 es day after tomorrow', sd_es.format_relative('2025-03-17', '2025-03-15'), 'pasado mañana');

% ================================================================
% 13. format_date_with_year
% ================================================================
printf('Section 13: format_date_with_year\n');

% 13.1
check('13.1 en with year', sd.format_date_with_year('2018-02-04'), 'February 4th, 2018');

% 13.2
check('13.2 en short with year', sayable_date_new(en, 'short').format_date_with_year('2025-03-15'), 'Mar 15, 2025');

% 13.3
check('13.3 en compact with year', sayable_date_new(en, 'compact').format_date_with_year('1997-01-21'), '1/21/97');

% 13.4
check('13.4 tg compact keeps two-digit year zero', sayable_date_new(locale_tg(), 'compact').format_date_with_year('2007-05-20'), '20/5/07');

% 13.5
check('13.5 fi short with year', sayable_date_new(locale_fi(), 'short').format_date_with_year('1996-06-21'), '21. kesäkuuta 1996');

% ================================================================
% 14. Short month names (locales that keep the full genitive)
% ================================================================
printf('Section 14: Short month names\n');

% 14.1
check('14.1 sk short', sayable_date_new(locale_sk(), 'short').format_date('2031-02-15'), '15. februára');

% 14.2
check('14.2 cs short', sayable_date_new(locale_cs(), 'short').format_date('2025-12-10'), '10. prosince');

% 14.3
check('14.3 uk short', sayable_date_new(locale_uk(), 'short').format_date('2025-11-05'), '5 листопада');

% 14.4
check('14.4 fi short relative', sayable_date_new(locale_fi(), 'short').format_relative('1998-08-08', '1998-08-15'), '8. elokuuta');

% ================================================================
% 15. format_relative — short phrases
% ================================================================
printf('Section 15: format_relative short phrases\n');

% 15.1
check('15.1 kw short day after tomorrow', sayable_date_new(locale_kw(), 'short').format_relative('2035-12-04', '2035-12-02'), 'an Mth ma');

% 15.2
check('15.2 mam short day before yesterday', sayable_date_new(locale_mam(), 'short').format_relative('2000-01-23', '2000-01-25'), 'Dom nchi''j');

% 15.3
check('15.3 kek short day after tomorrow', sayable_date_new(locale_kek(), 'short').format_relative('2014-10-24', '2014-10-22'), 'a''in Vie');

% ================================================================
% 16. Input validation
% ================================================================
printf('Section 16: Input validation\n');

% 16.1
check('16.1 February 30', sd.format_date('2025-02-30'), []);

% 16.2
check('16.2 month 13', sd.format_date('2025-13-01'), []);

% 16.3
check('16.3 unpadded', sd.format_date('2025-6-1'), []);

% 16.4
check('16.4 surrounding whitespace', sd.format_date(' 2025-06-01'), []);

% 16.5
check('16.5 ISO datetime', sd.format_date('2025-06-01T10:00:00'), 'June 1st');

% 16.6
check('16.6 February 29 in a non-leap year', sd.format_date_with_year('2023-02-29'), []);

% 16.7
check('16.7 invalid asOf', sd.format_relative('2025-03-16', '2025-04-31'), []);

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

% Tests for sayable-duration — mirrors the canonical test specification.
% All test IDs reference config/tests.json.
%
% Run: octave --no-gui --path . test_format_duration.m

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
sd = sayable_duration_new(en);

half = native2unicode([0xc2 0xbd], 'UTF-8');

% ================================================================
% 1. Null / edge cases
% ================================================================
printf('Section 1: Null / edge cases\n');

% 1.1
check('1.1 null seconds', sd.format_duration([], ''), []);

% 1.2
check('1.2 negative seconds', sd.format_duration(-1, ''), []);

% 1.3
check('1.3 null start', sd.format_since([], '2025-01-15T10:00:00'), []);

% 1.4
check('1.4 null target', sd.format_until([], '2025-01-15T10:00:00'), []);

% 1.5
check('1.5 asOf before start', sd.format_since('2025-01-15T10:00:00', '2025-01-15T09:00:00'), []);

% 1.6
check('1.6 target in past', sd.format_until('2025-01-15T09:00:00', '2025-01-15T10:00:00'), []);

% ================================================================
% 2. Duration — seconds tier (0-59s)
% ================================================================
printf('Section 2: Seconds tier\n');

% 2.1
check('2.1 0 seconds', sd.format_duration(0, ''), 'just now');

% 2.2
check('2.2 1 second', sd.format_duration(1, ''), '1 second');

% 2.3
check('2.3 45 seconds', sd.format_duration(45, ''), '45 seconds');

% 2.4
check('2.4 59 seconds', sd.format_duration(59, ''), '59 seconds');

% ================================================================
% 3. Duration — minutes + seconds tier (1-4 min)
% ================================================================
printf('Section 3: Minutes + seconds tier\n');

% 3.1
check('3.1 60 seconds', sd.format_duration(60, ''), '1 minute');

% 3.2
check('3.2 90 seconds', sd.format_duration(90, ''), '1 minute, 30 seconds');

% 3.3
check('3.3 240 seconds', sd.format_duration(240, ''), '4 minutes');

% 3.4
check('3.4 270 seconds', sd.format_duration(270, ''), '4 minutes, 30 seconds');

% ================================================================
% 4. Duration — minutes tier (5-59 min)
% ================================================================
printf('Section 4: Minutes tier\n');

% 4.1
check('4.1 5 min', sd.format_duration(300, ''), '5 minutes');

% 4.2
check('4.2 25 min', sd.format_duration(1500, ''), '25 minutes');

% 4.3
check('4.3 59 min', sd.format_duration(3540, ''), '59 minutes');

% ================================================================
% 5. Duration — hours + minutes tier (1-5 hr)
% ================================================================
printf('Section 5: Hours + minutes tier\n');

% 5.1
check('5.1 1 hour', sd.format_duration(3600, ''), '1 hour');

% 5.2
check('5.2 1.5 hours', sd.format_duration(5400, ''), ['1' half ' hours']);

% 5.3
check('5.3 2h 15m', sd.format_duration(8100, ''), '2 hours, 15 minutes');

% 5.4
check('5.4 5 hours', sd.format_duration(18000, ''), '5 hours');

% ================================================================
% 6. Duration — hours tier (6-23 hr)
% ================================================================
printf('Section 6: Hours tier\n');

% 6.1
check('6.1 8 hours', sd.format_duration(28800, ''), '8 hours');

% 6.2
check('6.2 23 hours', sd.format_duration(82800, ''), '23 hours');

% ================================================================
% 7. Duration — days tier
% ================================================================
printf('Section 7: Days tier\n');

% 7.1
check('7.1 1 day', sd.format_duration(86400, ''), '1 day');

% 7.2
check('7.2 1 day 3 hours', sd.format_duration(97200, ''), '1 day, 3 hours');

% 7.3
check('7.3 1.5 days', sd.format_duration(129600, ''), ['1' half ' days']);

% 7.4
check('7.4 5 days', sd.format_duration(432000, ''), '5 days');

% 7.5
check('7.5 2 days', sd.format_duration(172800, ''), '2 days');

% ================================================================
% 8. Duration — weeks tier
% ================================================================
printf('Section 8: Weeks tier\n');

% 8.1
check('8.1 1 week', sd.format_duration(604800, ''), '1 week');

% 8.2
check('8.2 2 weeks 1 day', sd.format_duration(1296000, ''), '2 weeks, 1 day');

% 8.3
check('8.3 4 weeks', sd.format_duration(2419200, ''), '4 weeks');

% ================================================================
% 9. Duration — months and years tier
% ================================================================
printf('Section 9: Months and years tier\n');

% 9.1
check('9.1 1 month', sd.format_duration(2678400, ''), '1 month');

% 9.2
check('9.2 3 months', sd.format_duration(7884000, ''), '3 months');

% 9.3
check('9.3 1 year', sd.format_duration(31536000, ''), '1 year');

% 9.4
check('9.4 1 year 3 months', sd.format_duration(39420000, ''), '1 year, 3 months');

% ================================================================
% 10. Duration from ISO timestamps
% ================================================================
printf('Section 10: ISO timestamps\n');

% 10.1
check('10.1 ISO 1.5 hours', sd.format_duration('2025-01-15T10:00:00', '2025-01-15T11:30:00'), ['1' half ' hours']);

% 10.2
check('10.2 ISO 45 min', sd.format_duration('2025-01-15T10:00:00', '2025-01-15T10:45:00'), '45 minutes');

% ================================================================
% 11. Relative time — since
% ================================================================
printf('Section 11: format_since\n');

% 11.1
check('11.1 just now', sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:00:00'), 'just now');

% 11.2
check('11.2 30 sec ago', sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:00:30'), '30 seconds ago');

% 11.3
check('11.3 45 min ago', sd.format_since('2025-01-15T10:00:00', '2025-01-15T10:45:00'), '45 minutes ago');

% 11.4
check('11.4 3 hours ago', sd.format_since('2025-01-15T10:00:00', '2025-01-15T13:00:00'), '3 hours ago');

% ================================================================
% 12. Relative time — until
% ================================================================
printf('Section 12: format_until\n');

% 12.1
check('12.1 just now', sd.format_until('2025-01-15T10:00:00', '2025-01-15T10:00:00'), 'just now');

% 12.2
check('12.2 in 20 min', sd.format_until('2025-01-15T10:20:00', '2025-01-15T10:00:00'), 'in 20 minutes');

% 12.3
check('12.3 in 3 hours', sd.format_until('2025-01-15T13:00:00', '2025-01-15T10:00:00'), 'in 3 hours');

% ================================================================
% 13. Locale — German
% ================================================================
printf('Section 13: Locale — German\n');

de = locale_de();
sd_de = sayable_duration_new(de);

% 13.1
check('13.1 de 1 Stunde', sd_de.format_duration(3600, ''), '1 Stunde');

% 13.2
check('13.2 de vor 5 Minuten', sd_de.format_since('2025-01-15T10:00:00', '2025-01-15T10:05:00'), 'vor 5 Minuten');

% ================================================================
% 14. Locale — French
% ================================================================
printf('Section 14: Locale — French\n');

fr = locale_fr();
sd_fr = sayable_duration_new(fr);

% 14.1
check('14.1 fr 2 heures', sd_fr.format_duration(7200, ''), '2 heures');

% ================================================================
% 15. Locale — Japanese
% ================================================================
printf('Section 15: Locale — Japanese\n');

ja = locale_ja();
sd_ja = sayable_duration_new(ja);

% 15.1
check('15.1 ja 2 min', sd_ja.format_duration(120, ''), '2分');

% 15.2
check('15.2 ja 1 hour ago', sd_ja.format_since('2025-01-15T10:00:00', '2025-01-15T11:00:00'), '1時間前');

% ================================================================
% 16. Short compactness
% ================================================================
printf('Section 16: Short compactness\n');

sd_short = sayable_duration_new(en, 'short');

% 16.1
check('16.1 short 1h', sd_short.format_duration(3600, ''), '1h');

% 16.2
check('16.2 short 1m 30s', sd_short.format_duration(90, ''), '1m, 30s');

% ================================================================
% 17. Compact compactness
% ================================================================
printf('Section 17: Compact compactness\n');

sd_compact = sayable_duration_new(en, 'compact');

% 17.1
check('17.1 compact 1h', sd_compact.format_duration(3600, ''), '1h');

% 17.2
check('17.2 compact 1m30s', sd_compact.format_duration(90, ''), '1m30s');

% ================================================================
% 18. Short compactness — relative time
% ================================================================
printf('Section 18: Short compactness — relative time\n');

% 18.1
check('18.1 men short since keeps days and hours', sayable_duration_new(locale_men(), 'short').format_since('2025-01-20T01:32:11', '2025-01-22T15:39:16'), 'lɔhɔnga 2, awa 14 taa gbɔyɔ');

% ================================================================
% 19. Range (500-year ceiling)
% ================================================================
printf('Section 19: Range (500-year ceiling)\n');

% 19.1
check('19.1 500 Julian years', sd.format_duration(15778800000, ''), '500 years');

% 19.2
check('19.2 over 6000 months', sd.format_duration(15800000000, ''), []);

% 19.3
check('19.3 well beyond the ceiling', sd.format_duration(99999999999, ''), []);

% 19.4
check('19.4 525 years ago', sd.format_since('1500-01-01T00:00:00', '2025-01-01T00:00:00'), []);

% 19.5
check('19.5 575 years from now', sd.format_until('2600-01-01T00:00:00', '2025-01-01T00:00:00'), []);

% ================================================================
% 20. Timestamp validation
% ================================================================
printf('Section 20: Timestamp validation\n');

% 20.1
check('20.1 seconds are optional', sd.format_duration('2025-01-15T10:00', '2025-01-15T11:30:00'), '1½ hours');

% 20.2
check('20.2 minutes are required', sd.format_duration('2025-01-15T10', '2025-01-15T11:30:00'), []);

% 20.3
check('20.3 unpadded date', sd.format_duration('2025-1-5T10:00:00', '2025-01-15T11:30:00'), []);

% 20.4
check('20.4 impossible date', sd.format_duration('2025-02-30T10:00:00', '2025-03-15T11:30:00'), []);

% 20.5
check('20.5 hour out of range', sd.format_since('2025-01-15T10:00:00', '2025-01-15T25:00:00'), []);

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

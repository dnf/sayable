% Tests for sayable-time — mirrors the canonical test specification.
% All test IDs reference config/tests.json.
%
% Run: octave --no-gui --path . test_format_time.m

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
st = sayable_time_new(en);

% ================================================================
% 1. Null / edge cases
% ================================================================
printf('Section 1: Null / edge cases\n');

% 1.1
check('1.1 null', st.format_time([]), []);

% 1.2
check('1.2 empty string', st.format_time(''), []);

% 1.3
check('1.3 invalid', st.format_time('invalid'), []);

% 1.4
check('1.4 out of range', st.format_time('25:00'), []);

% ================================================================
% 2. Clock time — normal compactness
% ================================================================
printf('Section 2: Clock time — normal\n');

% 2.1
check('2.1 midnight', st.format_time('00:00'), 'midnight');

% 2.2
check('2.2 noon', st.format_time('12:00'), 'noon');

% 2.3
check('2.3 three o''clock', st.format_time('15:00'), 'three o''clock');

% 2.4
check('2.4 quarter past two', st.format_time('14:15'), 'a quarter past two');

% 2.5
check('2.5 half past nine', st.format_time('09:30'), 'half past nine');

% 2.6
check('2.6 quarter to eleven', st.format_time('10:45'), 'a quarter to eleven');

% 2.7
check('2.7 five past eight', st.format_time('08:05'), 'five past eight');

% 2.8
check('2.8 five to five', st.format_time('16:55'), 'five to five');

% 2.9
check('2.9 23:58 rounds to midnight', st.format_time('23:58'), 'midnight');

% 2.10
check('2.10 22 rounds to 20', st.format_time('07:22'), 'twenty past seven');

% 2.11
check('2.11 ISO datetime', st.format_time('2025-01-15T14:15:00'), 'a quarter past two');

% ================================================================
% 3. Clock time — short compactness
% ================================================================
printf('Section 3: Clock time — short\n');

st_short = sayable_time_new(en, 'short');

% 3.1
check('3.1 short 2:15 PM', st_short.format_time('14:15'), '2:15 PM');

% 3.2
check('3.2 short 9:30 AM', st_short.format_time('09:30'), '9:30 AM');

% 3.3
check('3.3 short 12:00 AM', st_short.format_time('00:00'), '12:00 AM');

% 3.4
check('3.4 short 12:00 PM', st_short.format_time('12:00'), '12:00 PM');

% ================================================================
% 4. Clock time — compact
% ================================================================
printf('Section 4: Clock time — compact\n');

st_compact = sayable_time_new(en, 'compact');

% 4.1
check('4.1 compact 2:15p', st_compact.format_time('14:15'), '2:15p');

% 4.2
check('4.2 compact 9:30a', st_compact.format_time('09:30'), '9:30a');

% ================================================================
% 5. Locale — German
% ================================================================
printf('Section 5: Locale — German\n');

de = locale_de();
st_de = sayable_time_new(de);

% 5.1
check('5.1 de halb vier', st_de.format_time('15:30'), 'halb vier');

% ================================================================
% 6. Locale — French
% ================================================================
printf('Section 6: Locale — French\n');

fr = locale_fr();
st_fr = sayable_time_new(fr);

% 6.1
check('6.1 fr trois heures et quart', st_fr.format_time('15:15'), 'trois heures et quart');

% ================================================================
% 7. Locale — Japanese
% ================================================================
printf('Section 7: Locale — Japanese\n');

ja = locale_ja();
st_ja = sayable_time_new(ja);

% 7.1
check('7.1 ja 三時半', st_ja.format_time('15:30'), '三時半');

% ================================================================
% 8. Locale — Finnish (dot separator, short)
% ================================================================
printf('Section 8: Locale — Finnish\n');

fi = locale_fi();
st_fi = sayable_time_new(fi, 'short');

% 8.1
check('8.1 fi dot separator', st_fi.format_time('14:15'), '14.15');

% 8.2
check('8.2 fi midnight 24h dot', st_fi.format_time('00:00'), '0.00');

% ================================================================
% 9. Minutes in short and compact modes
% ================================================================
printf('Section 9: Minutes in short and compact modes\n');

% 9.1
check('9.1 short keeps the exact minute', st_short.format_time('18:01'), '6:01 PM');

% 9.2
check('9.2 compact keeps the exact minute', st_compact.format_time('19:05'), '7:05p');

% ================================================================
% 10. Input validation
% ================================================================
printf('Section 10: Input validation\n');

% 10.1
check('10.1 one-digit hour', st.format_time('9:30'), 'half past nine');

% 10.2
check('10.2 two-digit hour', st.format_time('09:30'), 'half past nine');

% 10.3
check('10.3 leading whitespace', st.format_time(' 9:30'), []);

% 10.4
check('10.4 trailing whitespace', st.format_time('9:30 '), []);

% 10.5
check('10.5 one-digit minutes', st.format_time('9:5'), []);

% 10.6
check('10.6 hour out of range', st.format_time('24:00'), []);

% 10.7
check('10.7 seconds ignored', st.format_time('14:15:30'), 'a quarter past two');

% 10.8
check('10.8 ISO datetime with zone', st.format_time('2025-01-15T14:15:00Z'), 'a quarter past two');

% 10.9
check('10.9 ISO datetime with an impossible date', st.format_time('2025-02-30T14:15:00'), []);

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

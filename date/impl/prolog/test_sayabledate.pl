%% test_sayabledate.pl — Test file for sayabledate.
%% Generated from date/config/tests.json.

:- use_module(sayabledate).

:- discontiguous test_case/1.

% Section 1: Null / edge cases
% 1.1: null input
test_case(test_1_1) :-
    \+ format_date('en', _, normal, _).

% 1.2: empty string
test_case(test_1_2) :-
    \+ format_date('en', '', normal, _).

% 1.3: invalid
test_case(test_1_3) :-
    \+ format_date('en', invalid, normal, _).

% 1.4: relative with null asOf
test_case(test_1_4) :-
    \+ format_relative('en', '2025-03-15', '', normal, _).

% 1.5: relative with null date
test_case(test_1_5) :-
    \+ format_relative('en', '', '2025-03-15', normal, _).

% Section 2: format_date — normal compactness (English)
% 2.1: March 15th
test_case(test_2_1) :-
    format_date('en', '2025-03-15', Result),
    Result == 'March 15th'.

% 2.2: January 1st
test_case(test_2_2) :-
    format_date('en', '2025-01-01', Result),
    Result == 'January 1st'.

% 2.3: May 22nd
test_case(test_2_3) :-
    format_date('en', '2025-05-22', Result),
    Result == 'May 22nd'.

% 2.4: July 3rd
test_case(test_2_4) :-
    format_date('en', '2025-07-03', Result),
    Result == 'July 3rd'.

% 2.5: December 31st
test_case(test_2_5) :-
    format_date('en', '2025-12-31', Result),
    Result == 'December 31st'.

% 2.6: June 11th (no exception for 11)
test_case(test_2_6) :-
    format_date('en', '2025-06-11', Result),
    Result == 'June 11th'.

% 2.7: ISO datetime input
test_case(test_2_7) :-
    format_date('en', '2025-03-15T14:30:00', Result),
    Result == 'March 15th'.

% Section 3: format_date — short compactness (English)
% 3.1: short Mar 15
test_case(test_3_1) :-
    format_date('en', '2025-03-15', short, Result),
    Result == 'Mar 15'.

% 3.2: short Jan 1
test_case(test_3_2) :-
    format_date('en', '2025-01-01', short, Result),
    Result == 'Jan 1'.

% 3.3: short Dec 25
test_case(test_3_3) :-
    format_date('en', '2025-12-25', short, Result),
    Result == 'Dec 25'.

% Section 4: format_date — compact (English)
% 4.1: compact 3/15
test_case(test_4_1) :-
    format_date('en', '2025-03-15', compact, Result),
    Result == '3/15'.

% 4.2: compact 1/1
test_case(test_4_2) :-
    format_date('en', '2025-01-01', compact, Result),
    Result == '1/1'.

% Section 5: format_relative — proximity tiers (English)
% 5.1: today
test_case(test_5_1) :-
    format_relative('en', '2025-03-15', '2025-03-15', Result),
    Result == today.

% 5.2: tomorrow
test_case(test_5_2) :-
    format_relative('en', '2025-03-16', '2025-03-15', Result),
    Result == tomorrow.

% 5.3: yesterday
test_case(test_5_3) :-
    format_relative('en', '2025-03-14', '2025-03-15', Result),
    Result == yesterday.

% 5.4: day after tomorrow
test_case(test_5_4) :-
    format_relative('en', '2025-03-17', '2025-03-15', Result),
    Result == 'the day after tomorrow'.

% 5.5: day before yesterday
test_case(test_5_5) :-
    format_relative('en', '2025-03-13', '2025-03-15', Result),
    Result == 'the day before yesterday'.

% 5.6: this Wednesday (+4)
test_case(test_5_6) :-
    format_relative('en', '2025-03-19', '2025-03-15', Result),
    Result == 'this Wednesday'.

% 5.7: this Thursday (+5)
test_case(test_5_7) :-
    format_relative('en', '2025-03-20', '2025-03-15', Result),
    Result == 'this Thursday'.

% 5.8: last Tuesday (-4)
test_case(test_5_8) :-
    format_relative('en', '2025-03-11', '2025-03-15', Result),
    Result == 'last Tuesday'.

% 5.9: next Saturday (+7)
test_case(test_5_9) :-
    format_relative('en', '2025-03-22', '2025-03-15', Result),
    Result == 'next Saturday'.

% 5.10: next Thursday (+12)
test_case(test_5_10) :-
    format_relative('en', '2025-03-27', '2025-03-15', Result),
    Result == 'next Thursday'.

% 5.11: calendar fallback same year
test_case(test_5_11) :-
    format_relative('en', '2025-03-01', '2025-03-15', Result),
    Result == 'March 1st'.

% 5.12: calendar fallback same year
test_case(test_5_12) :-
    format_relative('en', '2025-04-10', '2025-03-15', Result),
    Result == 'April 10th'.

% 5.13: different year includes year
test_case(test_5_13) :-
    format_relative('en', '2026-01-05', '2025-03-15', Result),
    Result == 'January 5th, 2026'.

% 5.14: past year includes year
test_case(test_5_14) :-
    format_relative('en', '2024-12-25', '2025-03-15', Result),
    Result == 'December 25th, 2024'.

% Section 6: format_relative — compact skips weekday tiers
% 6.1: compact today
test_case(test_6_1) :-
    format_relative('en', '2025-03-15', '2025-03-15', compact, Result),
    Result == today.

% 6.2: compact tomorrow
test_case(test_6_2) :-
    format_relative('en', '2025-03-16', '2025-03-15', compact, Result),
    Result == tomorrow.

% 6.3: compact skips weekday
test_case(test_6_3) :-
    format_relative('en', '2025-03-19', '2025-03-15', compact, Result),
    Result == '3/19'.

% 6.4: compact different year
test_case(test_6_4) :-
    format_relative('en', '2026-01-05', '2025-03-15', compact, Result),
    Result == '1/5/26'.

% Section 7: Locale — German
% 7.1: German date
test_case(test_7_1) :-
    format_date('de', '2025-03-15', Result),
    Result == '15. März'.

% 7.2: German tomorrow
test_case(test_7_2) :-
    format_relative('de', '2025-03-16', '2025-03-15', Result),
    Result == morgen.

% 7.3: German übermorgen
test_case(test_7_3) :-
    format_relative('de', '2025-03-17', '2025-03-15', Result),
    Result == 'übermorgen'.

% 7.4: German this weekday
test_case(test_7_4) :-
    format_relative('de', '2025-03-19', '2025-03-15', Result),
    Result == 'diesen Mittwoch'.

% Section 8: Locale — French
% 8.1: French 1er mars
test_case(test_8_1) :-
    format_date('fr', '2025-03-01', Result),
    Result == '1er mars'.

% 8.2: French 15 mars
test_case(test_8_2) :-
    format_date('fr', '2025-03-15', Result),
    Result == '15 mars'.

% 8.3: French tomorrow
test_case(test_8_3) :-
    format_relative('fr', '2025-03-16', '2025-03-15', Result),
    Result == demain.

% Section 9: Locale — Japanese
% 9.1: Japanese date
test_case(test_9_1) :-
    format_date('ja', '2025-03-15', Result),
    Result == '3月15日'.

% 9.2: Japanese tomorrow
test_case(test_9_2) :-
    format_relative('ja', '2025-03-16', '2025-03-15', Result),
    Result == '明日'.

% 9.3: Japanese this weekday
test_case(test_9_3) :-
    format_relative('ja', '2025-03-19', '2025-03-15', Result),
    Result == '今度の水曜日'.

% Section 10: Locale — Russian (genitive months)
% 10.1: Russian genitive month
test_case(test_10_1) :-
    format_date('ru', '2025-03-15', Result),
    Result == '15 марта'.

% 10.2: Russian tomorrow
test_case(test_10_2) :-
    format_relative('ru', '2025-03-16', '2025-03-15', Result),
    Result == 'завтра'.

% Section 11: Locale — Arabic
% 11.1: Arabic date
test_case(test_11_1) :-
    format_date('ar', '2025-03-15', Result),
    Result == '15 مارس'.

% 11.2: Arabic tomorrow
test_case(test_11_2) :-
    format_relative('ar', '2025-03-16', '2025-03-15', Result),
    Result == 'غداً'.

% Section 12: Locale — Spanish
% 12.1: Spanish date
test_case(test_12_1) :-
    format_date('es', '2025-03-15', Result),
    Result == '15 de marzo'.

% 12.2: Spanish day after tomorrow
test_case(test_12_2) :-
    format_relative('es', '2025-03-17', '2025-03-15', Result),
    Result == 'pasado mañana'.

% Test runner
run_tests :-
    findall(Name, test_case_name(Name), Tests),
    length(Tests, Total),
    run_all(Tests, 0, 0, Passed, Failed),
    format('~n~w/~w tests passed, ~w failed.~n', [Passed, Total, Failed]),
    (Failed > 0 -> halt(1) ; true).

test_case_name(test_1_1).
test_case_name(test_1_2).
test_case_name(test_1_3).
test_case_name(test_1_4).
test_case_name(test_1_5).
test_case_name(test_2_1).
test_case_name(test_2_2).
test_case_name(test_2_3).
test_case_name(test_2_4).
test_case_name(test_2_5).
test_case_name(test_2_6).
test_case_name(test_2_7).
test_case_name(test_3_1).
test_case_name(test_3_2).
test_case_name(test_3_3).
test_case_name(test_4_1).
test_case_name(test_4_2).
test_case_name(test_5_1).
test_case_name(test_5_2).
test_case_name(test_5_3).
test_case_name(test_5_4).
test_case_name(test_5_5).
test_case_name(test_5_6).
test_case_name(test_5_7).
test_case_name(test_5_8).
test_case_name(test_5_9).
test_case_name(test_5_10).
test_case_name(test_5_11).
test_case_name(test_5_12).
test_case_name(test_5_13).
test_case_name(test_5_14).
test_case_name(test_6_1).
test_case_name(test_6_2).
test_case_name(test_6_3).
test_case_name(test_6_4).
test_case_name(test_7_1).
test_case_name(test_7_2).
test_case_name(test_7_3).
test_case_name(test_7_4).
test_case_name(test_8_1).
test_case_name(test_8_2).
test_case_name(test_8_3).
test_case_name(test_9_1).
test_case_name(test_9_2).
test_case_name(test_9_3).
test_case_name(test_10_1).
test_case_name(test_10_2).
test_case_name(test_11_1).
test_case_name(test_11_2).
test_case_name(test_12_1).
test_case_name(test_12_2).

run_all([], Passed, Failed, Passed, Failed).
run_all([Name|Rest], PassedIn, FailedIn, PassedOut, FailedOut) :-
    (catch(test_case(Name), Error, (format('  FAIL ~w: ~w~n', [Name, Error]), fail))
     -> P1 is PassedIn + 1, F1 is FailedIn
     ;  format('  FAIL ~w~n', [Name]), P1 is PassedIn, F1 is FailedIn + 1
    ),
    run_all(Rest, P1, F1, PassedOut, FailedOut).

%% test_sayabletime.pl — Test file for sayabletime.
%% Generated from time/config/tests.json.

:- use_module(sayabletime).

:- discontiguous test_case/1.

% Section 1: Null / edge cases
% 1.1:
test_case(test_1_1) :-
    \+ format_time('en', _, normal, _).

% 1.2:
test_case(test_1_2) :-
    \+ format_time('en', '', normal, _).

% 1.3:
test_case(test_1_3) :-
    \+ format_time('en', 'invalid', normal, _).

% 1.4:
test_case(test_1_4) :-
    \+ format_time('en', '25:00', normal, _).

% Section 2: Clock time (normal compactness)
% 2.1:
test_case(test_2_1) :-
    format_time('en', '00:00', normal, Result),
    Result == 'midnight'.

% 2.2:
test_case(test_2_2) :-
    format_time('en', '12:00', normal, Result),
    Result == 'noon'.

% 2.3:
test_case(test_2_3) :-
    format_time('en', '15:00', normal, Result),
    Result == 'three o\'clock'.

% 2.4:
test_case(test_2_4) :-
    format_time('en', '14:15', normal, Result),
    Result == 'a quarter past two'.

% 2.5:
test_case(test_2_5) :-
    format_time('en', '09:30', normal, Result),
    Result == 'half past nine'.

% 2.6:
test_case(test_2_6) :-
    format_time('en', '10:45', normal, Result),
    Result == 'a quarter to eleven'.

% 2.7:
test_case(test_2_7) :-
    format_time('en', '08:05', normal, Result),
    Result == 'five past eight'.

% 2.8:
test_case(test_2_8) :-
    format_time('en', '16:55', normal, Result),
    Result == 'five to five'.

% 2.9: rounds to 0:00 of next day
test_case(test_2_9) :-
    format_time('en', '23:58', normal, Result),
    Result == 'midnight'.

% 2.10: 22 rounds to 20
test_case(test_2_10) :-
    format_time('en', '07:22', normal, Result),
    Result == 'twenty past seven'.

% 2.11: ISO datetime input
test_case(test_2_11) :-
    format_time('en', '2025-01-15T14:15:00', normal, Result),
    Result == 'a quarter past two'.

% Section 3: Clock time (short compactness)
% 3.1:
test_case(test_3_1) :-
    format_time('en', '14:15', short, Result),
    Result == '2:15 PM'.

% 3.2:
test_case(test_3_2) :-
    format_time('en', '09:30', short, Result),
    Result == '9:30 AM'.

% 3.3:
test_case(test_3_3) :-
    format_time('en', '00:00', short, Result),
    Result == '12:00 AM'.

% 3.4:
test_case(test_3_4) :-
    format_time('en', '12:00', short, Result),
    Result == '12:00 PM'.

% Section 4: Clock time (compact)
% 4.1:
test_case(test_4_1) :-
    format_time('en', '14:15', compact, Result),
    Result == '2:15p'.

% 4.2:
test_case(test_4_2) :-
    format_time('en', '09:30', compact, Result),
    Result == '9:30a'.

% Section 5: Locale — German
% 5.1: German half-to pattern
test_case(test_5_1) :-
    format_time('de', '15:30', normal, Result),
    Result == 'halb vier'.

% Section 6: Locale — French
% 6.1:
test_case(test_6_1) :-
    format_time('fr', '15:15', normal, Result),
    Result == 'trois heures et quart'.

% 6.2:
test_case(test_6_2) :-
    format_time('fr', '13:00', normal, Result),
    Result == 'une heure'.

% 6.3:
test_case(test_6_3) :-
    format_time('fr', '13:30', normal, Result),
    Result == 'une heure et demie'.

% 6.4:
test_case(test_6_4) :-
    format_time('fr', '14:45', normal, Result),
    Result == 'trois heures moins le quart'.

% 6.5:
test_case(test_6_5) :-
    format_time('fr', '14:50', normal, Result),
    Result == 'trois heures moins dix'.

% Section 7: Locale — Japanese
% 7.1:
test_case(test_7_1) :-
    format_time('ja', '15:30', normal, Result),
    Result == '三時半'.

% Section 8: Locale — Finnish (dot separator, short)
% 8.1: dot separator per CLDR Finnish time format
test_case(test_8_1) :-
    format_time('fi', '14:15', short, Result),
    Result == '14.15'.

% 8.2: midnight in 24h dot format
test_case(test_8_2) :-
    format_time('fi', '00:00', short, Result),
    Result == '0.00'.

% Section 9: Minutes in short and compact modes
% 9.1: digital modes keep the exact minute
test_case(test_9_1) :-
    format_time('en', '18:01', short, Result),
    Result == '6:01 PM'.

% 9.2: digital modes keep the exact minute
test_case(test_9_2) :-
    format_time('en', '19:05', compact, Result),
    Result == '7:05p'.

% Section 10: Input validation
% 10.1: one-digit hour
test_case(test_10_1) :-
    format_time('en', '9:30', normal, Result),
    Result == 'half past nine'.

% 10.2: two-digit hour
test_case(test_10_2) :-
    format_time('en', '09:30', normal, Result),
    Result == 'half past nine'.

% 10.3: leading whitespace
test_case(test_10_3) :-
    \+ format_time('en', ' 9:30', normal, _).

% 10.4: trailing whitespace
test_case(test_10_4) :-
    \+ format_time('en', '9:30 ', normal, _).

% 10.5: minutes need two digits
test_case(test_10_5) :-
    \+ format_time('en', '9:5', normal, _).

% 10.6: hour out of range
test_case(test_10_6) :-
    \+ format_time('en', '24:00', normal, _).

% 10.7: seconds are allowed and ignored
test_case(test_10_7) :-
    format_time('en', '14:15:30', normal, Result),
    Result == 'a quarter past two'.

% 10.8: ISO datetime with zone suffix (ignored)
test_case(test_10_8) :-
    format_time('en', '2025-01-15T14:15:00Z', normal, Result),
    Result == 'a quarter past two'.

% 10.9: ISO datetime with an impossible date
test_case(test_10_9) :-
    \+ format_time('en', '2025-02-30T14:15:00', normal, _).

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
test_case_name(test_2_1).
test_case_name(test_2_2).
test_case_name(test_2_3).
test_case_name(test_2_4).
test_case_name(test_2_5).
test_case_name(test_2_6).
test_case_name(test_2_7).
test_case_name(test_2_8).
test_case_name(test_2_9).
test_case_name(test_2_10).
test_case_name(test_2_11).
test_case_name(test_3_1).
test_case_name(test_3_2).
test_case_name(test_3_3).
test_case_name(test_3_4).
test_case_name(test_4_1).
test_case_name(test_4_2).
test_case_name(test_5_1).
test_case_name(test_6_1).
test_case_name(test_6_2).
test_case_name(test_6_3).
test_case_name(test_6_4).
test_case_name(test_6_5).
test_case_name(test_7_1).
test_case_name(test_8_1).
test_case_name(test_8_2).
test_case_name(test_9_1).
test_case_name(test_9_2).
test_case_name(test_10_1).
test_case_name(test_10_2).
test_case_name(test_10_3).
test_case_name(test_10_4).
test_case_name(test_10_5).
test_case_name(test_10_6).
test_case_name(test_10_7).
test_case_name(test_10_8).
test_case_name(test_10_9).

run_all([], Passed, Failed, Passed, Failed).
run_all([Name|Rest], PassedIn, FailedIn, PassedOut, FailedOut) :-
    (catch(test_case(Name), Error, (format('  FAIL ~w: ~w~n', [Name, Error]), fail))
     -> P1 is PassedIn + 1, F1 is FailedIn
     ;  format('  FAIL ~w~n', [Name]), P1 is PassedIn, F1 is FailedIn + 1
    ),
    run_all(Rest, P1, F1, PassedOut, FailedOut).

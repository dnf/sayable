%% test_sayableduration.pl — Test file for sayableduration.
%% Generated from duration/config/tests.json.

:- use_module(sayableduration).

:- discontiguous test_case/1.

% Section 1: Null / edge cases
% 1.1: null seconds
test_case(test_1_1) :-
    \+ format_duration('en', _, normal, _).

% 1.2: negative seconds
test_case(test_1_2) :-
    \+ format_duration('en', -1, normal, _).

% 1.3: null start for since
test_case(test_1_3) :-
    \+ format_since('en', '', '2025-01-15T10:00:00', normal, _).

% 1.4: null target for until
test_case(test_1_4) :-
    \+ format_until('en', '', '2025-01-15T10:00:00', normal, _).

% 1.5: asOf before start
test_case(test_1_5) :-
    \+ format_since('en', '2025-01-15T10:00:00', '2025-01-15T09:00:00', normal, _).

% 1.6: target in the past
test_case(test_1_6) :-
    \+ format_until('en', '2025-01-15T09:00:00', '2025-01-15T10:00:00', normal, _).

% Section 2: Duration — seconds tier (0-59s)
% 2.1: 0 seconds
test_case(test_2_1) :-
    format_duration('en', 0, Result),
    Result == 'just now'.

% 2.2: 1 second
test_case(test_2_2) :-
    format_duration('en', 1, Result),
    Result == '1 second'.

% 2.3: 45 seconds
test_case(test_2_3) :-
    format_duration('en', 45, Result),
    Result == '45 seconds'.

% 2.4: 59 seconds
test_case(test_2_4) :-
    format_duration('en', 59, Result),
    Result == '59 seconds'.

% Section 3: Duration — minutes + seconds tier (1-4 min)
% 3.1: 1 minute
test_case(test_3_1) :-
    format_duration('en', 60, Result),
    Result == '1 minute'.

% 3.2: 1 minute, 30 seconds
test_case(test_3_2) :-
    format_duration('en', 90, Result),
    Result == '1 minute, 30 seconds'.

% 3.3: 4 minutes
test_case(test_3_3) :-
    format_duration('en', 240, Result),
    Result == '4 minutes'.

% 3.4: 4 minutes, 30 seconds
test_case(test_3_4) :-
    format_duration('en', 270, Result),
    Result == '4 minutes, 30 seconds'.

% Section 4: Duration — minutes tier (5-59 min)
% 4.1: 5 minutes
test_case(test_4_1) :-
    format_duration('en', 300, Result),
    Result == '5 minutes'.

% 4.2: 25 minutes
test_case(test_4_2) :-
    format_duration('en', 1500, Result),
    Result == '25 minutes'.

% 4.3: 59 minutes
test_case(test_4_3) :-
    format_duration('en', 3540, Result),
    Result == '59 minutes'.

% Section 5: Duration — hours + minutes tier (1-5 hr)
% 5.1: 1 hour
test_case(test_5_1) :-
    format_duration('en', 3600, Result),
    Result == '1 hour'.

% 5.2: 1½ hours (half marker)
test_case(test_5_2) :-
    format_duration('en', 5400, Result),
    Result == '1½ hours'.

% 5.3: 2 hours, 15 minutes
test_case(test_5_3) :-
    format_duration('en', 8100, Result),
    Result == '2 hours, 15 minutes'.

% 5.4: 5 hours
test_case(test_5_4) :-
    format_duration('en', 18000, Result),
    Result == '5 hours'.

% Section 6: Duration — hours tier (6-23 hr)
% 6.1: 8 hours
test_case(test_6_1) :-
    format_duration('en', 28800, Result),
    Result == '8 hours'.

% 6.2: 23 hours
test_case(test_6_2) :-
    format_duration('en', 82800, Result),
    Result == '23 hours'.

% Section 7: Duration — days tier
% 7.1: 1 day
test_case(test_7_1) :-
    format_duration('en', 86400, Result),
    Result == '1 day'.

% 7.2: 1 day, 3 hours
test_case(test_7_2) :-
    format_duration('en', 97200, Result),
    Result == '1 day, 3 hours'.

% 7.3: 1½ days (half marker)
test_case(test_7_3) :-
    format_duration('en', 129600, Result),
    Result == '1½ days'.

% 7.4: 5 days
test_case(test_7_4) :-
    format_duration('en', 432000, Result),
    Result == '5 days'.

% 7.5: 2 days
test_case(test_7_5) :-
    format_duration('en', 172800, Result),
    Result == '2 days'.

% Section 8: Duration — weeks tier
% 8.1: 1 week
test_case(test_8_1) :-
    format_duration('en', 604800, Result),
    Result == '1 week'.

% 8.2: 2 weeks, 1 day
test_case(test_8_2) :-
    format_duration('en', 1296000, Result),
    Result == '2 weeks, 1 day'.

% 8.3: 4 weeks
test_case(test_8_3) :-
    format_duration('en', 2419200, Result),
    Result == '4 weeks'.

% Section 9: Duration — months and years tier
% 9.1: 1 month (~31 days)
test_case(test_9_1) :-
    format_duration('en', 2678400, Result),
    Result == '1 month'.

% 9.2: 3 months (~91 days)
test_case(test_9_2) :-
    format_duration('en', 7884000, Result),
    Result == '3 months'.

% 9.3: 1 year (365 days)
test_case(test_9_3) :-
    format_duration('en', 31536000, Result),
    Result == '1 year'.

% 9.4: 1 year, 3 months (~456 days)
test_case(test_9_4) :-
    format_duration('en', 39420000, Result),
    Result == '1 year, 3 months'.

% Section 10: Duration from ISO timestamps
% 10.1: 1½ hours
test_case(test_10_1) :-
    format_duration_ts('en', '2025-01-15T10:00:00', '2025-01-15T11:30:00', Result),
    Result == '1½ hours'.

% 10.2: 45 minutes
test_case(test_10_2) :-
    format_duration_ts('en', '2025-01-15T10:00:00', '2025-01-15T10:45:00', Result),
    Result == '45 minutes'.

% Section 11: Relative time — since
% 11.1: just now
test_case(test_11_1) :-
    format_since('en', '2025-01-15T10:00:00', '2025-01-15T10:00:00', Result),
    Result == 'just now'.

% 11.2: 30 seconds ago
test_case(test_11_2) :-
    format_since('en', '2025-01-15T10:00:00', '2025-01-15T10:00:30', Result),
    Result == '30 seconds ago'.

% 11.3: 45 minutes ago
test_case(test_11_3) :-
    format_since('en', '2025-01-15T10:00:00', '2025-01-15T10:45:00', Result),
    Result == '45 minutes ago'.

% 11.4: 3 hours ago
test_case(test_11_4) :-
    format_since('en', '2025-01-15T10:00:00', '2025-01-15T13:00:00', Result),
    Result == '3 hours ago'.

% Section 12: Relative time — until
% 12.1: just now
test_case(test_12_1) :-
    format_until('en', '2025-01-15T10:00:00', '2025-01-15T10:00:00', Result),
    Result == 'just now'.

% 12.2: in 20 minutes
test_case(test_12_2) :-
    format_until('en', '2025-01-15T10:20:00', '2025-01-15T10:00:00', Result),
    Result == 'in 20 minutes'.

% 12.3: in 3 hours
test_case(test_12_3) :-
    format_until('en', '2025-01-15T13:00:00', '2025-01-15T10:00:00', Result),
    Result == 'in 3 hours'.

% Section 13: Locale — German
% 13.1: 1 Stunde
test_case(test_13_1) :-
    format_duration('de', 3600, Result),
    Result == '1 Stunde'.

% 13.2: vor 5 Minuten
test_case(test_13_2) :-
    format_since('de', '2025-01-15T10:00:00', '2025-01-15T10:05:00', Result),
    Result == 'vor 5 Minuten'.

% Section 14: Locale — French
% 14.1: 2 heures
test_case(test_14_1) :-
    format_duration('fr', 7200, Result),
    Result == '2 heures'.

% Section 15: Locale — Japanese
% 15.1: 2分
test_case(test_15_1) :-
    format_duration('ja', 120, Result),
    Result == '2分'.

% 15.2: 1時間前
test_case(test_15_2) :-
    format_since('ja', '2025-01-15T10:00:00', '2025-01-15T11:00:00', Result),
    Result == '1時間前'.

% Section 16: Short compactness — duration
% 16.1: short 1h
test_case(test_16_1) :-
    format_duration('en', 3600, short, Result),
    Result == '1h'.

% 16.2: short 1m, 30s
test_case(test_16_2) :-
    format_duration('en', 90, short, Result),
    Result == '1m, 30s'.

% Section 17: Compact compactness — duration
% 17.1: compact 1h
test_case(test_17_1) :-
    format_duration('en', 3600, compact, Result),
    Result == '1h'.

% 17.2: compact 1m30s
test_case(test_17_2) :-
    format_duration('en', 90, compact, Result),
    Result == '1m30s'.

% Section 18: Short compactness — relative time
% 18.1: days and hours both kept
test_case(test_18_1) :-
    format_since('men', '2025-01-20T01:32:11', '2025-01-22T15:39:16', normal, Result),
    Result == 'lɔhɔnga 2, awa 14 taa gbɔyɔ'.

% Section 19: Range (500-year ceiling)
% 19.1: 500 Julian years: 6000 months, the ceiling
test_case(test_19_1) :-
    format_duration('en', 15778800000, normal, Result),
    Result == '500 years'.

% 19.2: over 6000 months
test_case(test_19_2) :-
    \+ format_duration('en', 15800000000, normal, _).

% 19.3: well beyond the ceiling (and 32-bit range)
test_case(test_19_3) :-
    \+ format_duration('en', 99999999999, normal, _).

% 19.4: 525 years ago
test_case(test_19_4) :-
    \+ format_since('en', '1500-01-01T00:00:00', '2025-01-01T00:00:00', normal, _).

% 19.5: 575 years from now
test_case(test_19_5) :-
    \+ format_until('en', '2600-01-01T00:00:00', '2025-01-01T00:00:00', normal, _).

% Section 20: Timestamp validation
% 20.1: seconds are optional
test_case(test_20_1) :-
    format_duration_ts('en', '2025-01-15T10:00', '2025-01-15T11:30:00', normal, Result),
    Result == '1½ hours'.

% 20.2: minutes are required
test_case(test_20_2) :-
    \+ format_duration_ts('en', '2025-01-15T10', '2025-01-15T11:30:00', normal, _).

% 20.3: unpadded date
test_case(test_20_3) :-
    \+ format_duration_ts('en', '2025-1-5T10:00:00', '2025-01-15T11:30:00', normal, _).

% 20.4: impossible date
test_case(test_20_4) :-
    \+ format_duration_ts('en', '2025-02-30T10:00:00', '2025-03-15T11:30:00', normal, _).

% 20.5: hour out of range
test_case(test_20_5) :-
    \+ format_since('en', '2025-01-15T10:00:00', '2025-01-15T25:00:00', normal, _).

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
test_case_name(test_1_6).
test_case_name(test_2_1).
test_case_name(test_2_2).
test_case_name(test_2_3).
test_case_name(test_2_4).
test_case_name(test_3_1).
test_case_name(test_3_2).
test_case_name(test_3_3).
test_case_name(test_3_4).
test_case_name(test_4_1).
test_case_name(test_4_2).
test_case_name(test_4_3).
test_case_name(test_5_1).
test_case_name(test_5_2).
test_case_name(test_5_3).
test_case_name(test_5_4).
test_case_name(test_6_1).
test_case_name(test_6_2).
test_case_name(test_7_1).
test_case_name(test_7_2).
test_case_name(test_7_3).
test_case_name(test_7_4).
test_case_name(test_7_5).
test_case_name(test_8_1).
test_case_name(test_8_2).
test_case_name(test_8_3).
test_case_name(test_9_1).
test_case_name(test_9_2).
test_case_name(test_9_3).
test_case_name(test_9_4).
test_case_name(test_10_1).
test_case_name(test_10_2).
test_case_name(test_11_1).
test_case_name(test_11_2).
test_case_name(test_11_3).
test_case_name(test_11_4).
test_case_name(test_12_1).
test_case_name(test_12_2).
test_case_name(test_12_3).
test_case_name(test_13_1).
test_case_name(test_13_2).
test_case_name(test_14_1).
test_case_name(test_15_1).
test_case_name(test_15_2).
test_case_name(test_16_1).
test_case_name(test_16_2).
test_case_name(test_17_1).
test_case_name(test_17_2).
test_case_name(test_18_1).
test_case_name(test_19_1).
test_case_name(test_19_2).
test_case_name(test_19_3).
test_case_name(test_19_4).
test_case_name(test_19_5).
test_case_name(test_20_1).
test_case_name(test_20_2).
test_case_name(test_20_3).
test_case_name(test_20_4).
test_case_name(test_20_5).

run_all([], Passed, Failed, Passed, Failed).
run_all([Name|Rest], PassedIn, FailedIn, PassedOut, FailedOut) :-
    (catch(test_case(Name), Error, (format('  FAIL ~w: ~w~n', [Name, Error]), fail))
     -> P1 is PassedIn + 1, F1 is FailedIn
     ;  format('  FAIL ~w~n', [Name]), P1 is PassedIn, F1 is FailedIn + 1
    ),
    run_all(Rest, P1, F1, PassedOut, FailedOut).

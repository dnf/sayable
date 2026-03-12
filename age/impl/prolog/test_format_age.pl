%% test_format_age.pl — Test file for sayableage.
%% Generated from age/config/tests.json.

:- use_module(sayableage).

:- discontiguous test_case/1.

% Section 1: Null / edge cases
% 1.1: 
test_case(test_1_1) :-
    \+ format_age('en', '', '', normal, _).

% 1.2: where applicable
test_case(test_1_2) :-
    \+ format_age('en', undefined, '', normal, _).

% 1.3: empty string
test_case(test_1_3) :-
    \+ format_age('en', '', '', normal, _).

% 1.4: future DOB
test_case(test_1_4) :-
    \+ format_age('en', '2025-07-01', '2025-06-15', normal, _).

% 1.5: exactly 500 years
test_case(test_1_5) :-
    format_age('en', '1525-06-15', '2025-06-15', normal, Result),
    Result == '500 years'.

% 1.6: 501 years
test_case(test_1_6) :-
    \+ format_age('en', '1524-06-15', '2025-06-15', normal, _).

% 1.7: 1000 years
test_case(test_1_7) :-
    \+ format_age('en', '1025-06-15', '2025-06-15', normal, _).

% Section 2: Days tier (0–6 days)
% 2.1: Born today, 0 days
test_case(test_2_1) :-
    format_age('en', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'Newborn'.

% 2.2: Singular
test_case(test_2_2) :-
    format_age('en', '2025-06-14', '2025-06-15', normal, Result),
    Result == '1 day'.

% 2.3: Plural
test_case(test_2_3) :-
    format_age('en', '2025-06-12', '2025-06-15', normal, Result),
    Result == '3 days'.

% 2.4: Maximum days before weeks
test_case(test_2_4) :-
    format_age('en', '2025-06-09', '2025-06-15', normal, Result),
    Result == '6 days'.

% 2.5: 7 days = transition to weeks
test_case(test_2_5) :-
    format_age('en', '2025-06-08', '2025-06-15', normal, Result),
    Result == '1 week'.

% Section 3: Weeks+days tier (7 days to <3 calendar months)
% 3.1: Exactly 7 days
test_case(test_3_1) :-
    format_age('en', '2025-06-08', '2025-06-15', normal, Result),
    Result == '1 week'.

% 3.2: Singular day remainder
test_case(test_3_2) :-
    format_age('en', '2025-06-07', '2025-06-15', normal, Result),
    Result == '1 week, 1 day'.

% 3.3: Plural day remainder
test_case(test_3_3) :-
    format_age('en', '2025-06-06', '2025-06-15', normal, Result),
    Result == '1 week, 2 days'.

% 3.4: Max days in week
test_case(test_3_4) :-
    format_age('en', '2025-06-02', '2025-06-15', normal, Result),
    Result == '1 week, 6 days'.

% 3.5: Exactly 14 days
test_case(test_3_5) :-
    format_age('en', '2025-06-01', '2025-06-15', normal, Result),
    Result == '2 weeks'.

% 3.6: 15 days
test_case(test_3_6) :-
    format_age('en', '2025-05-31', '2025-06-15', normal, Result),
    Result == '2 weeks, 1 day'.

% 3.7: 20 days
test_case(test_3_7) :-
    format_age('en', '2025-05-26', '2025-06-15', normal, Result),
    Result == '2 weeks, 6 days'.

% 3.8: 21 days
test_case(test_3_8) :-
    format_age('en', '2025-05-25', '2025-06-15', normal, Result),
    Result == '3 weeks'.

% 3.9: 1 calendar month, still weeks
test_case(test_3_9) :-
    format_age('en', '2025-05-15', '2025-06-15', normal, Result),
    Result == '4 weeks, 3 days'.

% 3.10: 2 calendar months, still weeks
test_case(test_3_10) :-
    format_age('en', '2025-04-15', '2025-06-15', normal, Result),
    Result == '8 weeks, 5 days'.

% 3.11: Day before 3-month birthday
test_case(test_3_11) :-
    format_age('en', '2025-03-15', '2025-06-14', normal, Result),
    Result == '13 weeks'.

% 3.12: Exactly 3 months = transition
test_case(test_3_12) :-
    format_age('en', '2025-03-15', '2025-06-15', normal, Result),
    Result == '3 months'.

% Section 4: Month boundaries — standard months
% 4.1: Standard 3-month boundary
test_case(test_4_1) :-
    format_age('en', '2025-01-01', '2025-04-01', normal, Result),
    Result == '3 months'.

% 4.2: Not yet 3 months
test_case(test_4_2) :-
    format_age('en', '2025-01-01', '2025-03-31', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% 4.3: Mid-month boundary
test_case(test_4_3) :-
    format_age('en', '2025-06-15', '2025-09-15', normal, Result),
    Result == '3 months'.

% 4.4: Day before 3-month mark
test_case(test_4_4) :-
    format_age('en', '2025-06-15', '2025-09-14', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% 4.5: 6 months
test_case(test_4_5) :-
    format_age('en', '2025-06-15', '2025-12-15', normal, Result),
    Result == '6 months'.

% Section 5: Month boundaries — February non-leap year
% 5.1: 1 cal month (clamped to Feb 28)
test_case(test_5_1) :-
    format_age('en', '2025-01-31', '2025-02-28', normal, Result),
    Result == '4 weeks'.

% 5.2: Apr has no 31st, clamp to 30
test_case(test_5_2) :-
    format_age('en', '2025-01-31', '2025-04-30', normal, Result),
    Result == '3 months'.

% 5.3: Day before 3-month mark
test_case(test_5_3) :-
    format_age('en', '2025-01-31', '2025-04-29', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% 5.4: Standard 3-month from Feb
test_case(test_5_4) :-
    format_age('en', '2025-02-01', '2025-05-01', normal, Result),
    Result == '3 months'.

% 5.5: Day before 3 months from Feb
test_case(test_5_5) :-
    format_age('en', '2025-02-01', '2025-04-30', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% Section 6: Month boundaries — February leap year
% 6.1: Leap year, Feb 29 exists
test_case(test_6_1) :-
    format_age('en', '2024-01-31', '2024-02-29', normal, Result),
    Result == '4 weeks, 1 day'.

% 6.2: 28 days
test_case(test_6_2) :-
    format_age('en', '2024-01-31', '2024-02-28', normal, Result),
    Result == '4 weeks'.

% 6.3: 3 months with Apr clamp
test_case(test_6_3) :-
    format_age('en', '2024-01-31', '2024-04-30', normal, Result),
    Result == '3 months'.

% 6.4: 1 month (clamped to 29)
test_case(test_6_4) :-
    format_age('en', '2024-01-30', '2024-02-29', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% 6.5: Not yet 1 month
test_case(test_6_5) :-
    format_age('en', '2024-01-30', '2024-02-28', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% Section 7: Month boundaries — 30-day months
% 7.1: Jun 30 is 3mo (clamped from 31)
test_case(test_7_1) :-
    format_age('en', '2025-03-31', '2025-06-30', normal, Result),
    Result == '3 months'.

% 7.2: Day before 3-month mark
test_case(test_7_2) :-
    format_age('en', '2025-03-31', '2025-06-29', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% 7.3: Nov 30 is 3mo (clamped from 31)
test_case(test_7_3) :-
    format_age('en', '2025-08-31', '2025-11-30', normal, Result),
    Result == '3 months'.

% 7.4: Day before 3-month mark
test_case(test_7_4) :-
    format_age('en', '2025-08-31', '2025-11-29', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% Section 8: Month boundaries — leap year baby (born Feb 29)
% 8.1: 3 months from Feb 29
test_case(test_8_1) :-
    format_age('en', '2024-02-29', '2024-05-29', normal, Result),
    Result == '3 months'.

% 8.2: Day before 3 months
test_case(test_8_2) :-
    format_age('en', '2024-02-29', '2024-05-28', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% 8.3: Non-leap: birthday clamps to 28
test_case(test_8_3) :-
    format_age('en', '2024-02-29', '2025-02-28', normal, Result),
    Result == '12 months'.

% 8.4: Day after clamped birthday
test_case(test_8_4) :-
    format_age('en', '2024-02-29', '2025-03-01', normal, Result),
    Result == '12 months'.

% Section 9: Months tier (3–23 months)
% 9.1: Transition point
test_case(test_9_1) :-
    format_age('en', '2025-01-15', '2025-04-15', normal, Result),
    Result == '3 months'.

% 9.2: 
test_case(test_9_2) :-
    format_age('en', '2025-01-15', '2025-07-15', normal, Result),
    Result == '6 months'.

% 9.3: Not "1 year"
test_case(test_9_3) :-
    format_age('en', '2024-06-15', '2025-06-15', normal, Result),
    Result == '12 months'.

% 9.4: Upper boundary
test_case(test_9_4) :-
    format_age('en', '2024-01-15', '2025-12-15', normal, Result),
    Result == '23 months'.

% 9.5: Day before boundary
test_case(test_9_5) :-
    format_age('en', '2025-01-15', '2025-07-14', normal, Result),
    Result == '5 months'.

% 9.6: Cross-year boundary
test_case(test_9_6) :-
    format_age('en', '2024-11-10', '2025-04-10', normal, Result),
    Result == '5 months'.

% Section 10: Years+months tier (24–35 months)
% 10.1: Exactly 24 months
test_case(test_10_1) :-
    format_age('en', '2023-06-15', '2025-06-15', normal, Result),
    Result == '2 years'.

% 10.2: Singular month
test_case(test_10_2) :-
    format_age('en', '2023-06-15', '2025-07-15', normal, Result),
    Result == '2 years, 1 month'.

% 10.3: 
test_case(test_10_3) :-
    format_age('en', '2023-06-15', '2025-12-15', normal, Result),
    Result == '2 years, 6 months'.

% 10.4: Upper boundary
test_case(test_10_4) :-
    format_age('en', '2023-06-15', '2026-05-15', normal, Result),
    Result == '2 years, 11 months'.

% 10.5: Day before 24 months
test_case(test_10_5) :-
    format_age('en', '2023-06-15', '2025-06-14', normal, Result),
    Result == '23 months'.

% Section 11: Half-year tier (3–6 years)
% 11.1: Exactly 3 years
test_case(test_11_1) :-
    format_age('en', '2022-06-15', '2025-06-15', normal, Result),
    Result == '3 years'.

% 11.2: 3y5m (under half)
test_case(test_11_2) :-
    format_age('en', '2022-06-15', '2025-11-15', normal, Result),
    Result == '3 years'.

% 11.3: 3y6m
test_case(test_11_3) :-
    format_age('en', '2022-06-15', '2025-12-15', normal, Result),
    Result == '3½ years'.

% 11.4: 3y11m
test_case(test_11_4) :-
    format_age('en', '2022-06-15', '2026-05-15', normal, Result),
    Result == '3½ years'.

% 11.5: Exactly 4 years
test_case(test_11_5) :-
    format_age('en', '2021-06-15', '2025-06-15', normal, Result),
    Result == '4 years'.

% 11.6: 4y6m
test_case(test_11_6) :-
    format_age('en', '2021-06-15', '2025-12-15', normal, Result),
    Result == '4½ years'.

% 11.7: Exactly 5 years
test_case(test_11_7) :-
    format_age('en', '2020-06-15', '2025-06-15', normal, Result),
    Result == '5 years'.

% 11.8: 5y8m
test_case(test_11_8) :-
    format_age('en', '2020-06-15', '2026-02-15', normal, Result),
    Result == '5½ years'.

% 11.9: Exactly 6 years
test_case(test_11_9) :-
    format_age('en', '2019-06-15', '2025-06-15', normal, Result),
    Result == '6 years'.

% 11.10: 6y6m
test_case(test_11_10) :-
    format_age('en', '2019-06-15', '2025-12-15', normal, Result),
    Result == '6½ years'.

% 11.11: 6y11m (last month before 7)
test_case(test_11_11) :-
    format_age('en', '2019-06-15', '2026-05-15', normal, Result),
    Result == '6½ years'.

% 11.12: Day before 3rd birthday
test_case(test_11_12) :-
    format_age('en', '2022-06-15', '2025-06-14', normal, Result),
    Result == '2 years, 11 months'.

% Section 12: Integer tier (7+ years)
% 12.1: Exactly 7 years
test_case(test_12_1) :-
    format_age('en', '2018-06-15', '2025-06-15', normal, Result),
    Result == '7 years'.

% 12.2: 7y3m — no ½ at 7+
test_case(test_12_2) :-
    format_age('en', '2018-03-20', '2025-06-15', normal, Result),
    Result == '7 years'.

% 12.3: Adult
test_case(test_12_3) :-
    format_age('en', '1980-01-01', '2025-06-15', normal, Result),
    Result == '45 years'.

% Section 13: Cross-year transitions with February
% 13.1: Dec→Jan→Feb(28)→Mar
test_case(test_13_1) :-
    format_age('en', '2024-12-31', '2025-03-31', normal, Result),
    Result == '3 months'.

% 13.2: Day before 3mo from Dec 31
test_case(test_13_2) :-
    format_age('en', '2024-12-31', '2025-03-30', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% 13.3: Nov→Dec→Jan→Feb(28 clamp)
test_case(test_13_3) :-
    format_age('en', '2024-11-30', '2025-02-28', normal, Result),
    Result == '3 months'.

% 13.4: Day before 3mo from Nov 30
test_case(test_13_4) :-
    format_age('en', '2024-11-30', '2025-02-27', normal, Result),
    atom_string(Result, Str),
    sub_string(Str, _, _, _, "week").

% Section 14: Born-on-31st progression
% 14.1: Apr clamp
test_case(test_14_1) :-
    format_age('en', '2025-01-31', '2025-04-30', normal, Result),
    Result == '3 months'.

% 14.2: May has 31
test_case(test_14_2) :-
    format_age('en', '2025-01-31', '2025-05-31', normal, Result),
    Result == '4 months'.

% 14.3: Jun clamp
test_case(test_14_3) :-
    format_age('en', '2025-01-31', '2025-06-30', normal, Result),
    Result == '5 months'.

% 14.4: Before Jul 31
test_case(test_14_4) :-
    format_age('en', '2025-01-31', '2025-07-01', normal, Result),
    Result == '5 months'.

% 14.5: Jul has 31
test_case(test_14_5) :-
    format_age('en', '2025-01-31', '2025-07-31', normal, Result),
    Result == '6 months'.

% Section 15: Default asOf (current date)
% 15.1: Skipped (requires system date mocking)
% 15.2: Skipped (requires system date mocking)
% Section 16: formatStage — null / edge cases
% 16.1: 
test_case(test_16_1) :-
    \+ format_stage('en', '', '', none, _).

% 16.2: where applicable
test_case(test_16_2) :-
    \+ format_age('en', undefined, '', normal, _).

% 16.3: 
test_case(test_16_3) :-
    \+ format_stage('en', '', '', none, _).

% 16.4: 
test_case(test_16_4) :-
    \+ format_stage('en', '2025-07-01', '2025-06-15', none, _).

% 16.5: exactly 500 years
test_case(test_16_5) :-
    format_stage('en', '1525-06-15', '2025-06-15', none, Result),
    Result == 'Adult'.

% 16.6: 501 years
test_case(test_16_6) :-
    \+ format_stage('en', '1524-06-15', '2025-06-15', none, _).

% Section 17: formatStage — Newborn (0–1 months, <2 calendar months)
% 17.1: Born today
test_case(test_17_1) :-
    format_stage('en', '2025-06-15', '2025-06-15', none, Result),
    Result == 'Newborn'.

% 17.2: 1 day
test_case(test_17_2) :-
    format_stage('en', '2025-06-14', '2025-06-15', none, Result),
    Result == 'Newborn'.

% 17.3: 3 weeks
test_case(test_17_3) :-
    format_stage('en', '2025-05-25', '2025-06-15', none, Result),
    Result == 'Newborn'.

% 17.4: 1 month
test_case(test_17_4) :-
    format_stage('en', '2025-05-15', '2025-06-15', none, Result),
    Result == 'Newborn'.

% 17.5: 1 month 29 days
test_case(test_17_5) :-
    format_stage('en', '2025-04-16', '2025-06-15', none, Result),
    Result == 'Newborn'.

% 17.6: Exactly 2 months = transition
test_case(test_17_6) :-
    format_stage('en', '2025-04-15', '2025-06-15', none, Result),
    Result == 'Infant'.

% Section 18: formatStage — Infant (2–11 months)
% 18.1: 2 months
test_case(test_18_1) :-
    format_stage('en', '2025-04-15', '2025-06-15', none, Result),
    Result == 'Infant'.

% 18.2: 6 months
test_case(test_18_2) :-
    format_stage('en', '2024-12-15', '2025-06-15', none, Result),
    Result == 'Infant'.

% 18.3: 11 months
test_case(test_18_3) :-
    format_stage('en', '2024-07-15', '2025-06-15', none, Result),
    Result == 'Infant'.

% 18.4: 12 months = transition
test_case(test_18_4) :-
    format_stage('en', '2024-06-15', '2025-06-15', none, Result),
    Result == 'Toddler'.

% Section 19: formatStage — Toddler (12–35 months)
% 19.1: 12 months
test_case(test_19_1) :-
    format_stage('en', '2024-06-15', '2025-06-15', none, Result),
    Result == 'Toddler'.

% 19.2: 18 months
test_case(test_19_2) :-
    format_stage('en', '2024-01-15', '2025-07-15', none, Result),
    Result == 'Toddler'.

% 19.3: 24 months
test_case(test_19_3) :-
    format_stage('en', '2023-06-15', '2025-06-15', none, Result),
    Result == 'Toddler'.

% 19.4: 35 months
test_case(test_19_4) :-
    format_stage('en', '2023-06-15', '2026-05-15', none, Result),
    Result == 'Toddler'.

% 19.5: 36 months = transition
test_case(test_19_5) :-
    format_stage('en', '2022-06-15', '2025-06-15', none, Result),
    Result == 'Child'.

% Section 20: formatStage — Child (36–155 months, 3–12 years)
% 20.1: 3 years
test_case(test_20_1) :-
    format_stage('en', '2022-06-15', '2025-06-15', none, Result),
    Result == 'Child'.

% 20.2: 4 years
test_case(test_20_2) :-
    format_stage('en', '2021-06-15', '2025-06-15', none, Result),
    Result == 'Child'.

% 20.3: 6 years
test_case(test_20_3) :-
    format_stage('en', '2019-06-15', '2025-06-15', none, Result),
    Result == 'Child'.

% 20.4: 9 years
test_case(test_20_4) :-
    format_stage('en', '2016-06-15', '2025-06-15', none, Result),
    Result == 'Child'.

% 20.5: 12y11m
test_case(test_20_5) :-
    format_stage('en', '2013-06-15', '2026-05-15', none, Result),
    Result == 'Child'.

% 20.6: 13 years = transition
test_case(test_20_6) :-
    format_stage('en', '2012-06-15', '2025-06-15', none, Result),
    Result == 'Teenager'.

% Section 21: formatStage — Teenager (156–215 months, 13–17 years)
% 21.1: 13 years
test_case(test_21_1) :-
    format_stage('en', '2012-06-15', '2025-06-15', none, Result),
    Result == 'Teenager'.

% 21.2: 15 years
test_case(test_21_2) :-
    format_stage('en', '2010-06-15', '2025-06-15', none, Result),
    Result == 'Teenager'.

% 21.3: 17y11m
test_case(test_21_3) :-
    format_stage('en', '2008-06-15', '2026-05-15', none, Result),
    Result == 'Teenager'.

% 21.4: 18 years = transition
test_case(test_21_4) :-
    format_stage('en', '2007-06-15', '2025-06-15', none, Result),
    Result == 'Adult'.

% Section 22: formatStage — Adult (216+ months, 18+ years)
% 22.1: 18 years
test_case(test_22_1) :-
    format_stage('en', '2007-06-15', '2025-06-15', none, Result),
    Result == 'Adult'.

% 22.2: 25 years
test_case(test_22_2) :-
    format_stage('en', '2000-06-15', '2025-06-15', none, Result),
    Result == 'Adult'.

% 22.3: 45 years
test_case(test_22_3) :-
    format_stage('en', '1980-01-01', '2025-06-15', none, Result),
    Result == 'Adult'.

% Section 23: formatStage — default asOf
% 23.1: Skipped (requires system date mocking)
% 23.2: Skipped (requires system date mocking)
% 23.3: Skipped (requires system date mocking)
% Section 24: SayableAge class — English locale delegation
% 24.1: 
test_case(test_24_1) :-
    format_age('en', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'Newborn'.

% 24.2: 
test_case(test_24_2) :-
    format_age('en', '2025-06-12', '2025-06-15', normal, Result),
    Result == '3 days'.

% 24.3: 
test_case(test_24_3) :-
    format_age('en', '2025-06-07', '2025-06-15', normal, Result),
    Result == '1 week, 1 day'.

% 24.4: 
test_case(test_24_4) :-
    format_age('en', '2025-01-15', '2025-07-15', normal, Result),
    Result == '6 months'.

% 24.5: 
test_case(test_24_5) :-
    format_age('en', '2023-06-15', '2025-07-15', normal, Result),
    Result == '2 years, 1 month'.

% 24.6: 
test_case(test_24_6) :-
    format_age('en', '2022-06-15', '2025-12-15', normal, Result),
    Result == '3½ years'.

% 24.7: 
test_case(test_24_7) :-
    format_age('en', '2018-06-15', '2025-06-15', normal, Result),
    Result == '7 years'.

% 24.8: 
test_case(test_24_8) :-
    format_stage('en', '2025-06-15', '2025-06-15', none, Result),
    Result == 'Newborn'.

% 24.9: 
test_case(test_24_9) :-
    format_stage('en', '2025-01-15', '2025-06-15', none, Result),
    Result == 'Infant'.

% 24.10: 
test_case(test_24_10) :-
    format_stage('en', '2024-06-15', '2025-06-15', none, Result),
    Result == 'Toddler'.

% 24.11: 
test_case(test_24_11) :-
    format_stage('en', '2022-06-15', '2025-06-15', none, Result),
    Result == 'Child'.

% 24.12: 
test_case(test_24_12) :-
    format_stage('en', '2012-06-15', '2025-06-15', none, Result),
    Result == 'Teenager'.

% 24.13: 
test_case(test_24_13) :-
    format_stage('en', '2007-06-15', '2025-06-15', none, Result),
    Result == 'Adult'.

% 24.14: 
test_case(test_24_14) :-
    \+ format_age('en', '', '2025-06-15', normal, _).

% 24.15: 
test_case(test_24_15) :-
    \+ format_stage('en', '', '2025-06-15', none, _).

% Section 25: i18n — locale with all plural features
% 25.1: justBorn
test_case(test_25_1) :-
    format_age('es', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'Recién nacido'.

% 25.2: Singular day
test_case(test_25_2) :-
    format_age('es', '2025-06-14', '2025-06-15', normal, Result),
    Result == '1 día'.

% 25.3: Plural days
test_case(test_25_3) :-
    format_age('es', '2025-06-12', '2025-06-15', normal, Result),
    Result == '3 días'.

% 25.4: Singular week
test_case(test_25_4) :-
    format_age('es', '2025-06-08', '2025-06-15', normal, Result),
    Result == '1 semana'.

% 25.5: Compound
test_case(test_25_5) :-
    format_age('es', '2025-06-07', '2025-06-15', normal, Result),
    Result == '1 semana, 1 día'.

% 25.6: Plural compound
test_case(test_25_6) :-
    format_age('es', '2025-05-26', '2025-06-15', normal, Result),
    Result == '2 semanas, 6 días'.

% 25.7: Months
test_case(test_25_7) :-
    format_age('es', '2025-01-15', '2025-07-15', normal, Result),
    Result == '6 meses'.

% 25.8: Singular month
test_case(test_25_8) :-
    format_age('es', '2023-06-15', '2025-07-15', normal, Result),
    Result == '2 años, 1 mes'.

% 25.9: Years+months
test_case(test_25_9) :-
    format_age('es', '2023-06-15', '2025-12-15', normal, Result),
    Result == '2 años, 6 meses'.

% 25.10: Half marker
test_case(test_25_10) :-
    format_age('es', '2022-06-15', '2025-12-15', normal, Result),
    Result == '3 y medio años'.

% 25.11: No half
test_case(test_25_11) :-
    format_age('es', '2022-06-15', '2025-06-15', normal, Result),
    Result == '3 años'.

% 25.12: 7+ years
test_case(test_25_12) :-
    format_age('es', '2018-06-15', '2025-06-15', normal, Result),
    Result == '7 años'.

% 25.13: Stage label
test_case(test_25_13) :-
    format_stage('es', '2025-06-15', '2025-06-15', none, Result),
    Result == 'Recién nacido'.

% 25.14: 
test_case(test_25_14) :-
    format_stage('es', '2025-01-15', '2025-06-15', none, Result),
    Result == 'Bebé'.

% 25.15: 
test_case(test_25_15) :-
    format_stage('es', '2024-06-15', '2025-06-15', none, Result),
    Result == 'Niño pequeño'.

% 25.16: 
test_case(test_25_16) :-
    format_stage('es', '2022-06-15', '2025-06-15', none, Result),
    Result == 'Niño'.

% 25.17: 
test_case(test_25_17) :-
    format_stage('es', '2012-06-15', '2025-06-15', none, Result),
    Result == 'Adolescente'.

% 25.18: 
test_case(test_25_18) :-
    format_stage('es', '2007-06-15', '2025-06-15', none, Result),
    Result == 'Adulto'.

% 25.19: Null handling
test_case(test_25_19) :-
    \+ format_age('es', '', '2025-06-15', normal, _).

% 25.20: Null handling
test_case(test_25_20) :-
    \+ format_stage('es', '', '2025-06-15', none, _).

% Section 26: Compactness — short
% 26.1: Short days
test_case(test_26_1) :-
    format_age('en', '2025-06-12', '2025-06-15', short, Result),
    Result == '3 d'.

% 26.2: Short week
test_case(test_26_2) :-
    format_age('en', '2025-06-08', '2025-06-15', short, Result),
    Result == '1 wk'.

% 26.3: Short compound
test_case(test_26_3) :-
    format_age('en', '2025-06-07', '2025-06-15', short, Result),
    Result == '1 wk, 1 d'.

% 26.4: Short months
test_case(test_26_4) :-
    format_age('en', '2025-01-15', '2025-07-15', short, Result),
    Result == '6 mo'.

% 26.5: Short years+months
test_case(test_26_5) :-
    format_age('en', '2023-06-15', '2025-07-15', short, Result),
    Result == '2 yr, 1 mo'.

% 26.6: Short half
test_case(test_26_6) :-
    format_age('en', '2022-06-15', '2025-12-15', short, Result),
    Result == '3½ yr'.

% 26.7: Short years
test_case(test_26_7) :-
    format_age('en', '2018-06-15', '2025-06-15', short, Result),
    Result == '7 yr'.

% 26.8: justBorn unchanged
test_case(test_26_8) :-
    format_age('en', '2025-06-15', '2025-06-15', short, Result),
    Result == 'Newborn'.

% 26.9: Stages unchanged
test_case(test_26_9) :-
    format_stage('en', '2025-01-15', '2025-06-15', none, Result),
    Result == 'Infant'.

% Section 27: Compactness — compact
% 27.1: Compact days
test_case(test_27_1) :-
    format_age('en', '2025-06-12', '2025-06-15', compact, Result),
    Result == '3d'.

% 27.2: Compact week
test_case(test_27_2) :-
    format_age('en', '2025-06-08', '2025-06-15', compact, Result),
    Result == '1w'.

% 27.3: No delimiter
test_case(test_27_3) :-
    format_age('en', '2025-06-07', '2025-06-15', compact, Result),
    Result == '1w1d'.

% 27.4: Compact months
test_case(test_27_4) :-
    format_age('en', '2025-01-15', '2025-07-15', compact, Result),
    Result == '6m'.

% 27.5: No delimiter
test_case(test_27_5) :-
    format_age('en', '2023-06-15', '2025-07-15', compact, Result),
    Result == '2y1m'.

% 27.6: Compact half
test_case(test_27_6) :-
    format_age('en', '2022-06-15', '2025-12-15', compact, Result),
    Result == '3½y'.

% 27.7: Compact years
test_case(test_27_7) :-
    format_age('en', '2018-06-15', '2025-06-15', compact, Result),
    Result == '7y'.

% 27.8: justBorn unchanged
test_case(test_27_8) :-
    format_age('en', '2025-06-15', '2025-06-15', compact, Result),
    Result == 'Newborn'.

% Section 29: Locale-specific edge cases — plural rules
% 29.1: justBorn
test_case(test_29_1) :-
    format_age('he', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'רק נולד'.

% 29.2: 1 day — one form
test_case(test_29_2) :-
    format_age('he', '2025-06-14', '2025-06-15', normal, Result),
    Result == 'יום 1'.

% 29.3: 3 days — other form
test_case(test_29_3) :-
    format_age('he', '2025-06-12', '2025-06-15', normal, Result),
    Result == '3 ימים'.

% 29.4: 2 weeks — dual form
test_case(test_29_4) :-
    format_age('he', '2025-06-01', '2025-06-15', normal, Result),
    Result == 'שבועיים'.

% 29.5: 3 weeks — other form
test_case(test_29_5) :-
    format_age('he', '2025-05-25', '2025-06-15', normal, Result),
    Result == '3 שבועות'.

% 29.6: 6 months — other
test_case(test_29_6) :-
    format_age('he', '2025-01-15', '2025-07-15', normal, Result),
    Result == '6 חודשים'.

% 29.7: 3 months — other
test_case(test_29_7) :-
    format_age('he', '2025-03-15', '2025-06-15', normal, Result),
    Result == '3 חודשים'.

% 29.8: 2y dual + 1m one
test_case(test_29_8) :-
    format_age('he', '2023-06-15', '2025-07-15', normal, Result),
    Result == 'שנתיים, חודש 1'.

% 29.9: 3½ years — half marker
test_case(test_29_9) :-
    format_age('he', '2022-06-15', '2025-12-15', normal, Result),
    Result == '3 שנים וחצי'.

% 29.10: 7+ years — other
test_case(test_29_10) :-
    format_age('he', '2018-06-15', '2025-06-15', normal, Result),
    Result == '7 שנים'.

% 29.11: masculine newborn
test_case(test_29_11) :-
    format_stage('he', '2025-06-15', '2025-06-15', m, Result),
    Result == 'רק נולד'.

% 29.12: feminine newborn
test_case(test_29_12) :-
    format_stage('he', '2025-06-15', '2025-06-15', f, Result),
    Result == 'רק נולדה'.

% 29.13: masculine adult
test_case(test_29_13) :-
    format_stage('he', '2007-06-15', '2025-06-15', m, Result),
    Result == 'מבוגר'.

% 29.14: feminine adult
test_case(test_29_14) :-
    format_stage('he', '2007-06-15', '2025-06-15', f, Result),
    Result == 'מבוגרת'.

% 29.15: justBorn
test_case(test_29_15) :-
    format_age('mk', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'Новороденче'.

% 29.16: 1 day — one
test_case(test_29_16) :-
    format_age('mk', '2025-06-14', '2025-06-15', normal, Result),
    Result == '1 ден'.

% 29.17: 3 days — other
test_case(test_29_17) :-
    format_age('mk', '2025-06-12', '2025-06-15', normal, Result),
    Result == '3 дена'.

% 29.18: 6 months — other
test_case(test_29_18) :-
    format_age('mk', '2025-01-15', '2025-07-15', normal, Result),
    Result == '6 месеци'.

% 29.19: 2y1m — one for month
test_case(test_29_19) :-
    format_age('mk', '2023-06-15', '2025-07-15', normal, Result),
    Result == '2 години, 1 месец'.

% 29.20: 3½ years — half marker
test_case(test_29_20) :-
    format_age('mk', '2022-06-15', '2025-12-15', normal, Result),
    Result == '3 години и пол'.

% 29.21: 7+ years — other
test_case(test_29_21) :-
    format_age('mk', '2018-06-15', '2025-06-15', normal, Result),
    Result == '7 години'.

% 29.22: justBorn
test_case(test_29_22) :-
    format_age('sw', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'Mzaliwa mpya'.

% 29.23: 1 day — one
test_case(test_29_23) :-
    format_age('sw', '2025-06-14', '2025-06-15', normal, Result),
    Result == 'siku 1'.

% 29.24: 3 days — other (same word)
test_case(test_29_24) :-
    format_age('sw', '2025-06-12', '2025-06-15', normal, Result),
    Result == 'siku 3'.

% 29.25: 6 months — other (noun class)
test_case(test_29_25) :-
    format_age('sw', '2025-01-15', '2025-07-15', normal, Result),
    Result == 'miezi 6'.

% 29.26: 2y other + 1m one
test_case(test_29_26) :-
    format_age('sw', '2023-06-15', '2025-07-15', normal, Result),
    Result == 'miaka 2, mwezi 1'.

% 29.27: 3½ years — half marker
test_case(test_29_27) :-
    format_age('sw', '2022-06-15', '2025-12-15', normal, Result),
    Result == 'miaka 3 na nusu'.

% 29.28: justBorn
test_case(test_29_28) :-
    format_age('id', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'Baru lahir'.

% 29.29: 1 day
test_case(test_29_29) :-
    format_age('id', '2025-06-14', '2025-06-15', normal, Result),
    Result == '1 hari'.

% 29.30: 3 days (same unit)
test_case(test_29_30) :-
    format_age('id', '2025-06-12', '2025-06-15', normal, Result),
    Result == '3 hari'.

% 29.31: 6 months
test_case(test_29_31) :-
    format_age('id', '2025-01-15', '2025-07-15', normal, Result),
    Result == '6 bulan'.

% 29.32: 3½ years — half marker
test_case(test_29_32) :-
    format_age('id', '2022-06-15', '2025-12-15', normal, Result),
    Result == '3 tahun setengah'.

% 29.33: 7+ years
test_case(test_29_33) :-
    format_age('id', '2018-06-15', '2025-06-15', normal, Result),
    Result == '7 tahun'.

% 29.34: justBorn
test_case(test_29_34) :-
    format_age('am', '2025-06-15', '2025-06-15', normal, Result),
    Result == 'አዲስ የተወለደ'.

% 29.35: 1 day — one form
test_case(test_29_35) :-
    format_age('am', '2025-06-14', '2025-06-15', normal, Result),
    Result == '1 ቀን'.

% 29.36: 3 days — other form
test_case(test_29_36) :-
    format_age('am', '2025-06-12', '2025-06-15', normal, Result),
    Result == '3 ቀናት'.

% 29.37: 1w1d with Ethiopic delimiter
test_case(test_29_37) :-
    format_age('am', '2025-06-07', '2025-06-15', normal, Result),
    Result == '1 ሳምንት፣ 1 ቀን'.

% 29.38: 6 months — other form
test_case(test_29_38) :-
    format_age('am', '2025-01-15', '2025-07-15', normal, Result),
    Result == '6 ወራት'.

% 29.39: 3½ years — half marker
test_case(test_29_39) :-
    format_age('am', '2022-06-15', '2025-12-15', normal, Result),
    Result == '3 ዓመታት ተኩል'.

% Section 30: Locale lookup by code string
% 30.1: Known locale
test_case(test_30_1) :-
    get_locale('en').

% 30.2: Another known locale
test_case(test_30_2) :-
    get_locale('fr').

% 30.3: Unknown code
test_case(test_30_3) :-
    \+ get_locale('xx').

% 30.4: Empty string
test_case(test_30_4) :-
    \+ get_locale('').

% 30.5: Case-sensitive
test_case(test_30_5) :-
    \+ get_locale('EN').

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
test_case_name(test_1_7).
test_case_name(test_2_1).
test_case_name(test_2_2).
test_case_name(test_2_3).
test_case_name(test_2_4).
test_case_name(test_2_5).
test_case_name(test_3_1).
test_case_name(test_3_2).
test_case_name(test_3_3).
test_case_name(test_3_4).
test_case_name(test_3_5).
test_case_name(test_3_6).
test_case_name(test_3_7).
test_case_name(test_3_8).
test_case_name(test_3_9).
test_case_name(test_3_10).
test_case_name(test_3_11).
test_case_name(test_3_12).
test_case_name(test_4_1).
test_case_name(test_4_2).
test_case_name(test_4_3).
test_case_name(test_4_4).
test_case_name(test_4_5).
test_case_name(test_5_1).
test_case_name(test_5_2).
test_case_name(test_5_3).
test_case_name(test_5_4).
test_case_name(test_5_5).
test_case_name(test_6_1).
test_case_name(test_6_2).
test_case_name(test_6_3).
test_case_name(test_6_4).
test_case_name(test_6_5).
test_case_name(test_7_1).
test_case_name(test_7_2).
test_case_name(test_7_3).
test_case_name(test_7_4).
test_case_name(test_8_1).
test_case_name(test_8_2).
test_case_name(test_8_3).
test_case_name(test_8_4).
test_case_name(test_9_1).
test_case_name(test_9_2).
test_case_name(test_9_3).
test_case_name(test_9_4).
test_case_name(test_9_5).
test_case_name(test_9_6).
test_case_name(test_10_1).
test_case_name(test_10_2).
test_case_name(test_10_3).
test_case_name(test_10_4).
test_case_name(test_10_5).
test_case_name(test_11_1).
test_case_name(test_11_2).
test_case_name(test_11_3).
test_case_name(test_11_4).
test_case_name(test_11_5).
test_case_name(test_11_6).
test_case_name(test_11_7).
test_case_name(test_11_8).
test_case_name(test_11_9).
test_case_name(test_11_10).
test_case_name(test_11_11).
test_case_name(test_11_12).
test_case_name(test_12_1).
test_case_name(test_12_2).
test_case_name(test_12_3).
test_case_name(test_13_1).
test_case_name(test_13_2).
test_case_name(test_13_3).
test_case_name(test_13_4).
test_case_name(test_14_1).
test_case_name(test_14_2).
test_case_name(test_14_3).
test_case_name(test_14_4).
test_case_name(test_14_5).
test_case_name(test_16_1).
test_case_name(test_16_2).
test_case_name(test_16_3).
test_case_name(test_16_4).
test_case_name(test_16_5).
test_case_name(test_16_6).
test_case_name(test_17_1).
test_case_name(test_17_2).
test_case_name(test_17_3).
test_case_name(test_17_4).
test_case_name(test_17_5).
test_case_name(test_17_6).
test_case_name(test_18_1).
test_case_name(test_18_2).
test_case_name(test_18_3).
test_case_name(test_18_4).
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
test_case_name(test_20_6).
test_case_name(test_21_1).
test_case_name(test_21_2).
test_case_name(test_21_3).
test_case_name(test_21_4).
test_case_name(test_22_1).
test_case_name(test_22_2).
test_case_name(test_22_3).
test_case_name(test_24_1).
test_case_name(test_24_2).
test_case_name(test_24_3).
test_case_name(test_24_4).
test_case_name(test_24_5).
test_case_name(test_24_6).
test_case_name(test_24_7).
test_case_name(test_24_8).
test_case_name(test_24_9).
test_case_name(test_24_10).
test_case_name(test_24_11).
test_case_name(test_24_12).
test_case_name(test_24_13).
test_case_name(test_24_14).
test_case_name(test_24_15).
test_case_name(test_25_1).
test_case_name(test_25_2).
test_case_name(test_25_3).
test_case_name(test_25_4).
test_case_name(test_25_5).
test_case_name(test_25_6).
test_case_name(test_25_7).
test_case_name(test_25_8).
test_case_name(test_25_9).
test_case_name(test_25_10).
test_case_name(test_25_11).
test_case_name(test_25_12).
test_case_name(test_25_13).
test_case_name(test_25_14).
test_case_name(test_25_15).
test_case_name(test_25_16).
test_case_name(test_25_17).
test_case_name(test_25_18).
test_case_name(test_25_19).
test_case_name(test_25_20).
test_case_name(test_26_1).
test_case_name(test_26_2).
test_case_name(test_26_3).
test_case_name(test_26_4).
test_case_name(test_26_5).
test_case_name(test_26_6).
test_case_name(test_26_7).
test_case_name(test_26_8).
test_case_name(test_26_9).
test_case_name(test_27_1).
test_case_name(test_27_2).
test_case_name(test_27_3).
test_case_name(test_27_4).
test_case_name(test_27_5).
test_case_name(test_27_6).
test_case_name(test_27_7).
test_case_name(test_27_8).
test_case_name(test_29_1).
test_case_name(test_29_2).
test_case_name(test_29_3).
test_case_name(test_29_4).
test_case_name(test_29_5).
test_case_name(test_29_6).
test_case_name(test_29_7).
test_case_name(test_29_8).
test_case_name(test_29_9).
test_case_name(test_29_10).
test_case_name(test_29_11).
test_case_name(test_29_12).
test_case_name(test_29_13).
test_case_name(test_29_14).
test_case_name(test_29_15).
test_case_name(test_29_16).
test_case_name(test_29_17).
test_case_name(test_29_18).
test_case_name(test_29_19).
test_case_name(test_29_20).
test_case_name(test_29_21).
test_case_name(test_29_22).
test_case_name(test_29_23).
test_case_name(test_29_24).
test_case_name(test_29_25).
test_case_name(test_29_26).
test_case_name(test_29_27).
test_case_name(test_29_28).
test_case_name(test_29_29).
test_case_name(test_29_30).
test_case_name(test_29_31).
test_case_name(test_29_32).
test_case_name(test_29_33).
test_case_name(test_29_34).
test_case_name(test_29_35).
test_case_name(test_29_36).
test_case_name(test_29_37).
test_case_name(test_29_38).
test_case_name(test_29_39).
test_case_name(test_30_1).
test_case_name(test_30_2).
test_case_name(test_30_3).
test_case_name(test_30_4).
test_case_name(test_30_5).

run_all([], Passed, Failed, Passed, Failed).
run_all([Name|Rest], PassedIn, FailedIn, PassedOut, FailedOut) :-
    (catch(test_case(Name), Error, (format('  FAIL ~w: ~w~n', [Name, Error]), fail))
     -> P1 is PassedIn + 1, F1 is FailedIn
     ;  format('  FAIL ~w~n', [Name]), P1 is PassedIn, F1 is FailedIn + 1
    ),
    run_all(Rest, P1, F1, PassedOut, FailedOut).

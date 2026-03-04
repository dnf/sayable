open Parent_time

let en = En.locale

let age dob as_of = Formatter.format_age_pure en Types.Normal dob as_of
let age_s loc dob as_of = Formatter.format_age_pure loc Types.Normal dob as_of
let age_short dob as_of = Formatter.format_age_pure en Types.Short dob as_of
let age_compact dob as_of = Formatter.format_age_pure en Types.Compact dob as_of
let stage dob as_of = Formatter.format_stage_pure en dob as_of None
let stage_g loc dob as_of gender = Formatter.format_stage_pure loc dob as_of gender

let check_some expected result =
  Alcotest.(check (option string)) "same" (Some expected) result

let check_none result =
  Alcotest.(check (option string)) "same" None result

let contains_weeks result =
  match result with
  | None -> Alcotest.fail "expected weeks pattern, got None"
  | Some s ->
    if not (Formatter.string_contains ~needle:"week" s) then
      Alcotest.failf "expected 'week' in %S" s

(* 1. Null / edge cases *)
let test_1_1 () = check_none (age "" "2025-06-15")        (* 1.1 null dateOfBirth *)
let test_1_3 () = check_none (age "" "2025-06-15")        (* 1.3 empty string *)
let test_1_4 () = check_none (age "2025-07-01" "2025-06-15") (* 1.4 future DOB *)
let test_1_5 () = check_some "500 years" (age "1525-06-15" "2025-06-15") (* 1.5 exactly 500 years *)
let test_1_6 () = check_none (age "1524-06-15" "2025-06-15") (* 1.6 501 years *)
let test_1_7 () = check_none (age "1025-06-15" "2025-06-15") (* 1.7 1000 years *)

(* 2. Days tier (0-6 days) *)
let test_2_1 () = check_some "Newborn" (age "2025-06-15" "2025-06-15") (* 2.1 born today *)
let test_2_2 () = check_some "1 day" (age "2025-06-14" "2025-06-15")   (* 2.2 1 day *)
let test_2_3 () = check_some "3 days" (age "2025-06-12" "2025-06-15")  (* 2.3 3 days *)
let test_2_4 () = check_some "6 days" (age "2025-06-09" "2025-06-15")  (* 2.4 6 days *)
let test_2_5 () = check_some "1 week" (age "2025-06-08" "2025-06-15")  (* 2.5 7 days = 1 week *)

(* 3. Weeks+days tier *)
let test_3_1 () = check_some "1 week" (age "2025-06-08" "2025-06-15")             (* 3.1 exactly 7 days *)
let test_3_2 () = check_some "1 week, 1 day" (age "2025-06-07" "2025-06-15")      (* 3.2 1 week, 1 day *)
let test_3_3 () = check_some "1 week, 2 days" (age "2025-06-06" "2025-06-15")     (* 3.3 1 week, 2 days *)
let test_3_4 () = check_some "1 week, 6 days" (age "2025-06-02" "2025-06-15")     (* 3.4 1 week, 6 days *)
let test_3_5 () = check_some "2 weeks" (age "2025-06-01" "2025-06-15")            (* 3.5 2 weeks *)
let test_3_6 () = check_some "2 weeks, 1 day" (age "2025-05-31" "2025-06-15")     (* 3.6 2 weeks, 1 day *)
let test_3_7 () = check_some "2 weeks, 6 days" (age "2025-05-26" "2025-06-15")    (* 3.7 2 weeks, 6 days *)
let test_3_8 () = check_some "3 weeks" (age "2025-05-25" "2025-06-15")            (* 3.8 3 weeks *)
let test_3_9 () = check_some "4 weeks, 3 days" (age "2025-05-15" "2025-06-15")    (* 3.9 4 weeks, 3 days *)
let test_3_10 () = check_some "8 weeks, 5 days" (age "2025-04-15" "2025-06-15")   (* 3.10 8 weeks, 5 days *)
let test_3_11 () = check_some "13 weeks" (age "2025-03-15" "2025-06-14")           (* 3.11 13 weeks *)
let test_3_12 () = check_some "3 months" (age "2025-03-15" "2025-06-15")           (* 3.12 3 months transition *)

(* 4. Month boundaries - standard months *)
let test_4_1 () = check_some "3 months" (age "2025-01-01" "2025-04-01")   (* 4.1 Jan1->Apr1 *)
let test_4_2 () = contains_weeks (age "2025-01-01" "2025-03-31")          (* 4.2 Jan1->Mar31 *)
let test_4_3 () = check_some "3 months" (age "2025-06-15" "2025-09-15")   (* 4.3 Jun15->Sep15 *)
let test_4_4 () = contains_weeks (age "2025-06-15" "2025-09-14")          (* 4.4 Jun15->Sep14 *)
let test_4_5 () = check_some "6 months" (age "2025-06-15" "2025-12-15")   (* 4.5 Jun15->Dec15 *)

(* 5. Month boundaries - Feb non-leap *)
let test_5_1 () = check_some "4 weeks" (age "2025-01-31" "2025-02-28")         (* 5.1 Jan31->Feb28 *)
let test_5_2 () = check_some "3 months" (age "2025-01-31" "2025-04-30")        (* 5.2 Jan31->Apr30 *)
let test_5_3 () = contains_weeks (age "2025-01-31" "2025-04-29")               (* 5.3 Jan31->Apr29 *)
let test_5_4 () = check_some "3 months" (age "2025-02-01" "2025-05-01")        (* 5.4 Feb1->May1 *)
let test_5_5 () = contains_weeks (age "2025-02-01" "2025-04-30")               (* 5.5 Feb1->Apr30 *)

(* 6. Month boundaries - Feb leap year *)
let test_6_1 () = check_some "4 weeks, 1 day" (age "2024-01-31" "2024-02-29") (* 6.1 Jan31->Feb29 leap *)
let test_6_2 () = check_some "4 weeks" (age "2024-01-31" "2024-02-28")         (* 6.2 Jan31->Feb28 leap *)
let test_6_3 () = check_some "3 months" (age "2024-01-31" "2024-04-30")        (* 6.3 Jan31->Apr30 *)
let test_6_4 () = contains_weeks (age "2024-01-30" "2024-02-29")               (* 6.4 Jan30->Feb29 *)
let test_6_5 () = contains_weeks (age "2024-01-30" "2024-02-28")               (* 6.5 Jan30->Feb28 *)

(* 7. Month boundaries - 30-day months *)
let test_7_1 () = check_some "3 months" (age "2025-03-31" "2025-06-30") (* 7.1 Mar31->Jun30 *)
let test_7_2 () = contains_weeks (age "2025-03-31" "2025-06-29")        (* 7.2 Mar31->Jun29 *)
let test_7_3 () = check_some "3 months" (age "2025-08-31" "2025-11-30") (* 7.3 Aug31->Nov30 *)
let test_7_4 () = contains_weeks (age "2025-08-31" "2025-11-29")        (* 7.4 Aug31->Nov29 *)

(* 8. Leap year baby *)
let test_8_1 () = check_some "3 months" (age "2024-02-29" "2024-05-29")   (* 8.1 Feb29->May29 *)
let test_8_2 () = contains_weeks (age "2024-02-29" "2024-05-28")          (* 8.2 Feb29->May28 *)
let test_8_3 () = check_some "12 months" (age "2024-02-29" "2025-02-28")  (* 8.3 Feb29->Feb28 next year *)
let test_8_4 () = check_some "12 months" (age "2024-02-29" "2025-03-01")  (* 8.4 Feb29->Mar1 next year *)

(* 9. Months tier (3-23 months) *)
let test_9_1 () = check_some "3 months" (age "2025-01-15" "2025-04-15")  (* 9.1 3 months *)
let test_9_2 () = check_some "6 months" (age "2025-01-15" "2025-07-15")  (* 9.2 6 months *)
let test_9_3 () = check_some "12 months" (age "2024-06-15" "2025-06-15") (* 9.3 12 months *)
let test_9_4 () = check_some "23 months" (age "2024-01-15" "2025-12-15") (* 9.4 23 months *)
let test_9_5 () = check_some "5 months" (age "2025-01-15" "2025-07-14")  (* 9.5 5 months *)
let test_9_6 () = check_some "5 months" (age "2024-11-10" "2025-04-10")  (* 9.6 5 months cross-year *)

(* 10. Years+months tier (24-35 months) *)
let test_10_1 () = check_some "2 years" (age "2023-06-15" "2025-06-15")                 (* 10.1 2 years *)
let test_10_2 () = check_some "2 years, 1 month" (age "2023-06-15" "2025-07-15")        (* 10.2 2y1m *)
let test_10_3 () = check_some "2 years, 6 months" (age "2023-06-15" "2025-12-15")       (* 10.3 2y6m *)
let test_10_4 () = check_some "2 years, 11 months" (age "2023-06-15" "2026-05-15")      (* 10.4 2y11m *)
let test_10_5 () = check_some "23 months" (age "2023-06-15" "2025-06-14")               (* 10.5 day before 24m *)

(* 11. Half-year tier (3-6 years) *)
let test_11_1 () = check_some "3 years" (age "2022-06-15" "2025-06-15")     (* 11.1 3 years *)
let test_11_2 () = check_some "3 years" (age "2022-06-15" "2025-11-15")     (* 11.2 3y5m *)
let test_11_3 () = {|3½ years|} |> fun e -> check_some e (age "2022-06-15" "2025-12-15") (* 11.3 3y6m *)
let test_11_4 () = {|3½ years|} |> fun e -> check_some e (age "2022-06-15" "2026-05-15") (* 11.4 3y11m *)
let test_11_5 () = check_some "4 years" (age "2021-06-15" "2025-06-15")     (* 11.5 4 years *)
let test_11_6 () = {|4½ years|} |> fun e -> check_some e (age "2021-06-15" "2025-12-15") (* 11.6 4y6m *)
let test_11_7 () = check_some "5 years" (age "2020-06-15" "2025-06-15")     (* 11.7 5 years *)
let test_11_8 () = {|5½ years|} |> fun e -> check_some e (age "2020-06-15" "2026-02-15") (* 11.8 5y8m *)
let test_11_9 () = check_some "6 years" (age "2019-06-15" "2025-06-15")     (* 11.9 6 years *)
let test_11_10 () = {|6½ years|} |> fun e -> check_some e (age "2019-06-15" "2025-12-15") (* 11.10 6y6m *)
let test_11_11 () = {|6½ years|} |> fun e -> check_some e (age "2019-06-15" "2026-05-15") (* 11.11 6y11m *)
let test_11_12 () = check_some "2 years, 11 months" (age "2022-06-15" "2025-06-14") (* 11.12 day before 3rd birthday *)

(* 12. Integer tier (7+ years) *)
let test_12_1 () = check_some "7 years" (age "2018-06-15" "2025-06-15")  (* 12.1 7 years *)
let test_12_2 () = check_some "7 years" (age "2018-03-20" "2025-06-15")  (* 12.2 7y3m *)
let test_12_3 () = check_some "45 years" (age "1980-01-01" "2025-06-15") (* 12.3 45 years *)

(* 13. Cross-year transitions with February *)
let test_13_1 () = check_some "3 months" (age "2024-12-31" "2025-03-31")  (* 13.1 Dec31->Mar31 *)
let test_13_2 () = contains_weeks (age "2024-12-31" "2025-03-30")         (* 13.2 Dec31->Mar30 *)
let test_13_3 () = check_some "3 months" (age "2024-11-30" "2025-02-28")  (* 13.3 Nov30->Feb28 *)
let test_13_4 () = contains_weeks (age "2024-11-30" "2025-02-27")         (* 13.4 Nov30->Feb27 *)

(* 14. Born-on-31st progression *)
let test_14_1 () = check_some "3 months" (age "2025-01-31" "2025-04-30")  (* 14.1 Jan31->Apr30 *)
let test_14_2 () = check_some "4 months" (age "2025-01-31" "2025-05-31")  (* 14.2 Jan31->May31 *)
let test_14_3 () = check_some "5 months" (age "2025-01-31" "2025-06-30")  (* 14.3 Jan31->Jun30 *)
let test_14_4 () = check_some "5 months" (age "2025-01-31" "2025-07-01")  (* 14.4 Jan31->Jul1 *)
let test_14_5 () = check_some "6 months" (age "2025-01-31" "2025-07-31")  (* 14.5 Jan31->Jul31 *)

(* 16. formatStage - null / edge cases *)
let test_16_1 () = check_none (stage "" "2025-06-15")                  (* 16.1/16.3 empty string *)
let test_16_4 () = check_none (stage "2025-07-01" "2025-06-15")       (* 16.4 future DOB *)
let test_16_5 () = check_some "Adult" (stage "1525-06-15" "2025-06-15") (* 16.5 exactly 500 years *)
let test_16_6 () = check_none (stage "1524-06-15" "2025-06-15")       (* 16.6 501 years *)

(* 17. formatStage - Newborn (0-1 months) *)
let test_17_1 () = check_some "Newborn" (stage "2025-06-15" "2025-06-15") (* 17.1 born today *)
let test_17_2 () = check_some "Newborn" (stage "2025-06-14" "2025-06-15") (* 17.2 1 day *)
let test_17_3 () = check_some "Newborn" (stage "2025-05-25" "2025-06-15") (* 17.3 3 weeks *)
let test_17_4 () = check_some "Newborn" (stage "2025-05-15" "2025-06-15") (* 17.4 1 month *)
let test_17_5 () = check_some "Newborn" (stage "2025-04-16" "2025-06-15") (* 17.5 1 month 29 days *)
let test_17_6 () = check_some "Infant" (stage "2025-04-15" "2025-06-15") (* 17.6 2 months = Infant *)

(* 18. formatStage - Infant (2-11 months) *)
let test_18_1 () = check_some "Infant" (stage "2025-04-15" "2025-06-15") (* 18.1 2 months *)
let test_18_2 () = check_some "Infant" (stage "2024-12-15" "2025-06-15") (* 18.2 6 months *)
let test_18_3 () = check_some "Infant" (stage "2024-07-15" "2025-06-15") (* 18.3 11 months *)
let test_18_4 () = check_some "Toddler" (stage "2024-06-15" "2025-06-15") (* 18.4 12 months = Toddler *)

(* 19. formatStage - Toddler (12-35 months) *)
let test_19_1 () = check_some "Toddler" (stage "2024-06-15" "2025-06-15") (* 19.1 12 months *)
let test_19_2 () = check_some "Toddler" (stage "2024-01-15" "2025-07-15") (* 19.2 18 months *)
let test_19_3 () = check_some "Toddler" (stage "2023-06-15" "2025-06-15") (* 19.3 24 months *)
let test_19_4 () = check_some "Toddler" (stage "2023-06-15" "2026-05-15") (* 19.4 35 months *)
let test_19_5 () = check_some "Child" (stage "2022-06-15" "2025-06-15")   (* 19.5 36 months = Child *)

(* 20. formatStage - Child (36-155 months) *)
let test_20_1 () = check_some "Child" (stage "2022-06-15" "2025-06-15")    (* 20.1 3 years *)
let test_20_2 () = check_some "Child" (stage "2021-06-15" "2025-06-15")    (* 20.2 4 years *)
let test_20_3 () = check_some "Child" (stage "2019-06-15" "2025-06-15")    (* 20.3 6 years *)
let test_20_4 () = check_some "Child" (stage "2016-06-15" "2025-06-15")    (* 20.4 9 years *)
let test_20_5 () = check_some "Child" (stage "2013-06-15" "2026-05-15")    (* 20.5 12y11m *)
let test_20_6 () = check_some "Teenager" (stage "2012-06-15" "2025-06-15") (* 20.6 13 years = Teenager *)

(* 21. formatStage - Teenager (156-215 months) *)
let test_21_1 () = check_some "Teenager" (stage "2012-06-15" "2025-06-15") (* 21.1 13 years *)
let test_21_2 () = check_some "Teenager" (stage "2010-06-15" "2025-06-15") (* 21.2 15 years *)
let test_21_3 () = check_some "Teenager" (stage "2008-06-15" "2026-05-15") (* 21.3 17y11m *)
let test_21_4 () = check_some "Adult" (stage "2007-06-15" "2025-06-15")    (* 21.4 18 years = Adult *)

(* 22. formatStage - Adult (216+ months) *)
let test_22_1 () = check_some "Adult" (stage "2007-06-15" "2025-06-15")    (* 22.1 18 years *)
let test_22_2 () = check_some "Adult" (stage "2000-06-15" "2025-06-15")    (* 22.2 25 years *)
let test_22_3 () = check_some "Adult" (stage "1980-01-01" "2025-06-15")    (* 22.3 45 years *)

(* 24. Class delegation (English locale) *)
let test_24_1 () = check_some "Newborn" (age "2025-06-15" "2025-06-15")           (* 24.1 Newborn *)
let test_24_2 () = check_some "3 days" (age "2025-06-12" "2025-06-15")            (* 24.2 3 days *)
let test_24_3 () = check_some "1 week, 1 day" (age "2025-06-07" "2025-06-15")     (* 24.3 1w1d *)
let test_24_4 () = check_some "6 months" (age "2025-01-15" "2025-07-15")           (* 24.4 6 months *)
let test_24_5 () = check_some "2 years, 1 month" (age "2023-06-15" "2025-07-15")   (* 24.5 2y1m *)
let test_24_6 () = {|3½ years|} |> fun e -> check_some e (age "2022-06-15" "2025-12-15") (* 24.6 3½ years *)
let test_24_7 () = check_some "7 years" (age "2018-06-15" "2025-06-15")            (* 24.7 7 years *)
let test_24_8 () = check_some "Newborn" (stage "2025-06-15" "2025-06-15")          (* 24.8 stage Newborn *)
let test_24_9 () = check_some "Infant" (stage "2025-01-15" "2025-06-15")           (* 24.9 stage Infant *)
let test_24_10 () = check_some "Toddler" (stage "2024-06-15" "2025-06-15")        (* 24.10 stage Toddler *)
let test_24_11 () = check_some "Child" (stage "2022-06-15" "2025-06-15")           (* 24.11 stage Child *)
let test_24_12 () = check_some "Teenager" (stage "2012-06-15" "2025-06-15")        (* 24.12 stage Teenager *)
let test_24_13 () = check_some "Adult" (stage "2007-06-15" "2025-06-15")           (* 24.13 stage Adult *)
let test_24_14 () = check_none (age "" "2025-06-15")                               (* 24.14 null formatAge *)
let test_24_15 () = check_none (stage "" "2025-06-15")                             (* 24.15 null formatStage *)

(* 25. i18n - Spanish locale *)
let test_25_1 () = check_some "Reci\xc3\xa9n nacido" (age_s Es.locale "2025-06-15" "2025-06-15")
let test_25_2 () = check_some "1 d\xc3\xada" (age_s Es.locale "2025-06-14" "2025-06-15")
let test_25_3 () = check_some "3 d\xc3\xadas" (age_s Es.locale "2025-06-12" "2025-06-15")
let test_25_4 () = check_some "1 semana" (age_s Es.locale "2025-06-08" "2025-06-15")
let test_25_5 () = check_some "1 semana, 1 d\xc3\xada" (age_s Es.locale "2025-06-07" "2025-06-15")
let test_25_6 () = check_some "2 semanas, 6 d\xc3\xadas" (age_s Es.locale "2025-05-26" "2025-06-15")
let test_25_7 () = check_some "6 meses" (age_s Es.locale "2025-01-15" "2025-07-15")
let test_25_8 () = check_some "2 a\xc3\xb1os, 1 mes" (age_s Es.locale "2023-06-15" "2025-07-15")
let test_25_9 () = check_some "2 a\xc3\xb1os, 6 meses" (age_s Es.locale "2023-06-15" "2025-12-15")
let test_25_10 () = check_some "3 y medio a\xc3\xb1os" (age_s Es.locale "2022-06-15" "2025-12-15")
let test_25_11 () = check_some "3 a\xc3\xb1os" (age_s Es.locale "2022-06-15" "2025-06-15")
let test_25_12 () = check_some "7 a\xc3\xb1os" (age_s Es.locale "2018-06-15" "2025-06-15")
let test_25_13 () = check_some "Reci\xc3\xa9n nacido" (Formatter.format_stage_pure Es.locale "2025-06-15" "2025-06-15" None)
let test_25_14 () = check_some "Beb\xc3\xa9" (Formatter.format_stage_pure Es.locale "2025-01-15" "2025-06-15" None)
let test_25_15 () = check_some "Ni\xc3\xb1o peque\xc3\xb1o" (Formatter.format_stage_pure Es.locale "2024-06-15" "2025-06-15" None)
let test_25_16 () = check_some "Ni\xc3\xb1o" (Formatter.format_stage_pure Es.locale "2022-06-15" "2025-06-15" None)
let test_25_17 () = check_some "Adolescente" (Formatter.format_stage_pure Es.locale "2012-06-15" "2025-06-15" None)
let test_25_18 () = check_some "Adulto" (Formatter.format_stage_pure Es.locale "2007-06-15" "2025-06-15" None)
let test_25_19 () = check_none (age_s Es.locale "" "2025-06-15")
let test_25_20 () = check_none (Formatter.format_stage_pure Es.locale "" "2025-06-15" None)

(* 26. Compactness - short *)
let test_26_1 () = check_some "3 d" (age_short "2025-06-12" "2025-06-15")         (* 26.1 short days *)
let test_26_2 () = check_some "1 wk" (age_short "2025-06-08" "2025-06-15")        (* 26.2 short week *)
let test_26_3 () = check_some "1 wk, 1 d" (age_short "2025-06-07" "2025-06-15")   (* 26.3 short compound *)
let test_26_4 () = check_some "6 mo" (age_short "2025-01-15" "2025-07-15")        (* 26.4 short months *)
let test_26_5 () = check_some "2 yr, 1 mo" (age_short "2023-06-15" "2025-07-15")  (* 26.5 short years+months *)
let test_26_6 () = {|3½ yr|} |> fun e -> check_some e (age_short "2022-06-15" "2025-12-15") (* 26.6 short half *)
let test_26_7 () = check_some "7 yr" (age_short "2018-06-15" "2025-06-15")        (* 26.7 short years *)
let test_26_8 () = check_some "Newborn" (age_short "2025-06-15" "2025-06-15")     (* 26.8 justBorn unchanged *)
let test_26_9 () = check_some "Infant" (Formatter.format_stage_pure en "2025-01-15" "2025-06-15" None) (* 26.9 stages unchanged *)

(* 27. Compactness - compact *)
let test_27_1 () = check_some "3d" (age_compact "2025-06-12" "2025-06-15")         (* 27.1 compact days *)
let test_27_2 () = check_some "1w" (age_compact "2025-06-08" "2025-06-15")         (* 27.2 compact week *)
let test_27_3 () = check_some "1w1d" (age_compact "2025-06-07" "2025-06-15")       (* 27.3 no delimiter *)
let test_27_4 () = check_some "6m" (age_compact "2025-01-15" "2025-07-15")         (* 27.4 compact months *)
let test_27_5 () = check_some "2y1m" (age_compact "2023-06-15" "2025-07-15")       (* 27.5 no delimiter *)
let test_27_6 () = {|3½y|} |> fun e -> check_some e (age_compact "2022-06-15" "2025-12-15") (* 27.6 compact half *)
let test_27_7 () = check_some "7y" (age_compact "2018-06-15" "2025-06-15")         (* 27.7 compact years *)
let test_27_8 () = check_some "Newborn" (age_compact "2025-06-15" "2025-06-15")    (* 27.8 justBorn unchanged *)

(* 29.1 Hebrew dual forms *)
let he = He.locale
let test_29_1 () = check_some "\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93" (age_s he "2025-06-15" "2025-06-15")
let test_29_2 () = check_some "\xd7\x99\xd7\x95\xd7\x9d 1" (age_s he "2025-06-14" "2025-06-15")
let test_29_3 () = check_some "3 \xd7\x99\xd7\x9e\xd7\x99\xd7\x9d" (age_s he "2025-06-12" "2025-06-15")
let test_29_4 () = check_some "\xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x99\xd7\x99\xd7\x9d" (age_s he "2025-06-01" "2025-06-15")
let test_29_5 () = check_some "3 \xd7\xa9\xd7\x91\xd7\x95\xd7\xa2\xd7\x95\xd7\xaa" (age_s he "2025-05-25" "2025-06-15")
let test_29_6 () = check_some "6 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d" (age_s he "2025-01-15" "2025-07-15")
let test_29_7 () = check_some "3 \xd7\x97\xd7\x95\xd7\x93\xd7\xa9\xd7\x99\xd7\x9d" (age_s he "2025-03-15" "2025-06-15")
let test_29_8 () = check_some "\xd7\xa9\xd7\xa0\xd7\xaa\xd7\x99\xd7\x99\xd7\x9d, \xd7\x97\xd7\x95\xd7\x93\xd7\xa9 1" (age_s he "2023-06-15" "2025-07-15")
let test_29_9 () = check_some "3 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d \xd7\x95\xd7\x97\xd7\xa6\xd7\x99" (age_s he "2022-06-15" "2025-12-15")
let test_29_10 () = check_some "7 \xd7\xa9\xd7\xa0\xd7\x99\xd7\x9d" (age_s he "2018-06-15" "2025-06-15")
let test_29_11 () = check_some "\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93" (stage_g he "2025-06-15" "2025-06-15" (Some Types.M))
let test_29_12 () = check_some "\xd7\xa8\xd7\xa7 \xd7\xa0\xd7\x95\xd7\x9c\xd7\x93\xd7\x94" (stage_g he "2025-06-15" "2025-06-15" (Some Types.F))
let test_29_13 () = check_some "\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8" (stage_g he "2007-06-15" "2025-06-15" (Some Types.M))
let test_29_14 () = check_some "\xd7\x9e\xd7\x91\xd7\x95\xd7\x92\xd7\xa8\xd7\xaa" (stage_g he "2007-06-15" "2025-06-15" (Some Types.F))

(* 29.2 Macedonian mod10/mod100 *)
let mk = Mk.locale
let test_29_15 () = check_some "\xd0\x9d\xd0\xbe\xd0\xb2\xd0\xbe\xd1\x80\xd0\xbe\xd0\xb4\xd0\xb5\xd0\xbd\xd1\x87\xd0\xb5" (age_s mk "2025-06-15" "2025-06-15")
let test_29_16 () = check_some "1 \xd0\xb4\xd0\xb5\xd0\xbd" (age_s mk "2025-06-14" "2025-06-15")
let test_29_17 () = check_some "3 \xd0\xb4\xd0\xb5\xd0\xbd\xd0\xb0" (age_s mk "2025-06-12" "2025-06-15")
let test_29_18 () = check_some "6 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86\xd0\xb8" (age_s mk "2025-01-15" "2025-07-15")
let test_29_19 () = check_some "2 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8, 1 \xd0\xbc\xd0\xb5\xd1\x81\xd0\xb5\xd1\x86" (age_s mk "2023-06-15" "2025-07-15")
let test_29_20 () = check_some "3 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8 \xd0\xb8 \xd0\xbf\xd0\xbe\xd0\xbb" (age_s mk "2022-06-15" "2025-12-15")
let test_29_21 () = check_some "7 \xd0\xb3\xd0\xbe\xd0\xb4\xd0\xb8\xd0\xbd\xd0\xb8" (age_s mk "2018-06-15" "2025-06-15")

(* 29.3 Swahili *)
let sw = Sw.locale
let test_29_22 () = check_some "Mzaliwa mpya" (age_s sw "2025-06-15" "2025-06-15")
let test_29_23 () = check_some "siku 1" (age_s sw "2025-06-14" "2025-06-15")
let test_29_24 () = check_some "siku 3" (age_s sw "2025-06-12" "2025-06-15")
let test_29_25 () = check_some "miezi 6" (age_s sw "2025-01-15" "2025-07-15")
let test_29_26 () = check_some "miaka 2, mwezi 1" (age_s sw "2023-06-15" "2025-07-15")
let test_29_27 () = check_some "miaka 3 na nusu" (age_s sw "2022-06-15" "2025-12-15")

(* 29.4 Indonesian *)
let id' = Id.locale
let test_29_28 () = check_some "Baru lahir" (age_s id' "2025-06-15" "2025-06-15")
let test_29_29 () = check_some "1 hari" (age_s id' "2025-06-14" "2025-06-15")
let test_29_30 () = check_some "3 hari" (age_s id' "2025-06-12" "2025-06-15")
let test_29_31 () = check_some "6 bulan" (age_s id' "2025-01-15" "2025-07-15")
let test_29_32 () = check_some "3 tahun setengah" (age_s id' "2022-06-15" "2025-12-15")
let test_29_33 () = check_some "7 tahun" (age_s id' "2018-06-15" "2025-06-15")

(* 29.5 Amharic *)
let am = Am.locale
let test_29_34 () = check_some "\xe1\x8a\xa0\xe1\x8b\xb2\xe1\x88\xb5 \xe1\x8b\xa8\xe1\x89\xb0\xe1\x8b\x88\xe1\x88\x88\xe1\x8b\xb0" (age_s am "2025-06-15" "2025-06-15")
let test_29_35 () = check_some "1 \xe1\x89\x80\xe1\x8a\x95" (age_s am "2025-06-14" "2025-06-15")
let test_29_36 () = check_some "3 \xe1\x89\x80\xe1\x8a\x93\xe1\x89\xb5" (age_s am "2025-06-12" "2025-06-15")
let test_29_37 () = check_some "1 \xe1\x88\xb3\xe1\x88\x9d\xe1\x8a\x95\xe1\x89\xb5\xe1\x8d\xa3 1 \xe1\x89\x80\xe1\x8a\x95" (age_s am "2025-06-07" "2025-06-15")
let test_29_38 () = check_some "6 \xe1\x8b\x88\xe1\x88\xab\xe1\x89\xb5" (age_s am "2025-01-15" "2025-07-15")
let test_29_39 () = check_some "3 \xe1\x8b\x93\xe1\x88\x98\xe1\x89\xb3\xe1\x89\xb5 \xe1\x89\xb0\xe1\x8a\xa9\xe1\x88\x8d" (age_s am "2022-06-15" "2025-12-15")

(* 30. Locale lookup *)
let test_30_1 () = check_some "en" (Option.map (fun (l : Types.locale) -> l.code) (Locales.get_locale "en"))
let test_30_2 () = check_some "fr" (Option.map (fun (l : Types.locale) -> l.code) (Locales.get_locale "fr"))
let test_30_3 () = Alcotest.(check bool) "unknown" true (Option.is_none (Locales.get_locale "xx"))
let test_30_4 () = Alcotest.(check bool) "empty" true (Option.is_none (Locales.get_locale ""))
let test_30_5 () = Alcotest.(check bool) "case-sensitive" true (Option.is_none (Locales.get_locale "EN"))

let () =
  Alcotest.run "sayable-age"
    [ ( "1. Null / edge cases"
      , [ Alcotest.test_case "1.1 null dateOfBirth" `Quick test_1_1
        ; Alcotest.test_case "1.3 empty string" `Quick test_1_3
        ; Alcotest.test_case "1.4 future DOB" `Quick test_1_4
        ; Alcotest.test_case "1.5 exactly 500 years" `Quick test_1_5
        ; Alcotest.test_case "1.6 501 years" `Quick test_1_6
        ; Alcotest.test_case "1.7 1000 years" `Quick test_1_7
        ] )
    ; ( "2. Days tier"
      , [ Alcotest.test_case "2.1 born today" `Quick test_2_1
        ; Alcotest.test_case "2.2 1 day" `Quick test_2_2
        ; Alcotest.test_case "2.3 3 days" `Quick test_2_3
        ; Alcotest.test_case "2.4 6 days" `Quick test_2_4
        ; Alcotest.test_case "2.5 7 days = 1 week" `Quick test_2_5
        ] )
    ; ( "3. Weeks+days tier"
      , [ Alcotest.test_case "3.1 exactly 7 days" `Quick test_3_1
        ; Alcotest.test_case "3.2 1 week, 1 day" `Quick test_3_2
        ; Alcotest.test_case "3.3 1 week, 2 days" `Quick test_3_3
        ; Alcotest.test_case "3.4 1 week, 6 days" `Quick test_3_4
        ; Alcotest.test_case "3.5 2 weeks" `Quick test_3_5
        ; Alcotest.test_case "3.6 2 weeks, 1 day" `Quick test_3_6
        ; Alcotest.test_case "3.7 2 weeks, 6 days" `Quick test_3_7
        ; Alcotest.test_case "3.8 3 weeks" `Quick test_3_8
        ; Alcotest.test_case "3.9 4 weeks, 3 days" `Quick test_3_9
        ; Alcotest.test_case "3.10 8 weeks, 5 days" `Quick test_3_10
        ; Alcotest.test_case "3.11 13 weeks" `Quick test_3_11
        ; Alcotest.test_case "3.12 3 months transition" `Quick test_3_12
        ] )
    ; ( "4. Month boundaries - standard"
      , [ Alcotest.test_case "4.1 Jan1->Apr1 = 3 months" `Quick test_4_1
        ; Alcotest.test_case "4.2 Jan1->Mar31 still weeks" `Quick test_4_2
        ; Alcotest.test_case "4.3 Jun15->Sep15 = 3 months" `Quick test_4_3
        ; Alcotest.test_case "4.4 Jun15->Sep14 still weeks" `Quick test_4_4
        ; Alcotest.test_case "4.5 Jun15->Dec15 = 6 months" `Quick test_4_5
        ] )
    ; ( "5. Month boundaries - Feb non-leap"
      , [ Alcotest.test_case "5.1 Jan31->Feb28" `Quick test_5_1
        ; Alcotest.test_case "5.2 Jan31->Apr30 = 3 months" `Quick test_5_2
        ; Alcotest.test_case "5.3 Jan31->Apr29 still weeks" `Quick test_5_3
        ; Alcotest.test_case "5.4 Feb1->May1 = 3 months" `Quick test_5_4
        ; Alcotest.test_case "5.5 Feb1->Apr30 still weeks" `Quick test_5_5
        ] )
    ; ( "6. Month boundaries - Feb leap"
      , [ Alcotest.test_case "6.1 Jan31->Feb29 leap" `Quick test_6_1
        ; Alcotest.test_case "6.2 Jan31->Feb28 leap" `Quick test_6_2
        ; Alcotest.test_case "6.3 Jan31->Apr30 = 3 months" `Quick test_6_3
        ; Alcotest.test_case "6.4 Jan30->Feb29 weeks" `Quick test_6_4
        ; Alcotest.test_case "6.5 Jan30->Feb28 weeks" `Quick test_6_5
        ] )
    ; ( "7. Month boundaries - 30-day months"
      , [ Alcotest.test_case "7.1 Mar31->Jun30 = 3 months" `Quick test_7_1
        ; Alcotest.test_case "7.2 Mar31->Jun29 still weeks" `Quick test_7_2
        ; Alcotest.test_case "7.3 Aug31->Nov30 = 3 months" `Quick test_7_3
        ; Alcotest.test_case "7.4 Aug31->Nov29 still weeks" `Quick test_7_4
        ] )
    ; ( "8. Leap year baby"
      , [ Alcotest.test_case "8.1 Feb29->May29 = 3 months" `Quick test_8_1
        ; Alcotest.test_case "8.2 Feb29->May28 still weeks" `Quick test_8_2
        ; Alcotest.test_case "8.3 Feb29->Feb28 next year = 12 months" `Quick test_8_3
        ; Alcotest.test_case "8.4 Feb29->Mar1 next year = 12 months" `Quick test_8_4
        ] )
    ; ( "9. Months tier"
      , [ Alcotest.test_case "9.1 3 months" `Quick test_9_1
        ; Alcotest.test_case "9.2 6 months" `Quick test_9_2
        ; Alcotest.test_case "9.3 12 months" `Quick test_9_3
        ; Alcotest.test_case "9.4 23 months" `Quick test_9_4
        ; Alcotest.test_case "9.5 5 months" `Quick test_9_5
        ; Alcotest.test_case "9.6 5 months cross-year" `Quick test_9_6
        ] )
    ; ( "10. Years+months tier"
      , [ Alcotest.test_case "10.1 2 years" `Quick test_10_1
        ; Alcotest.test_case "10.2 2y1m" `Quick test_10_2
        ; Alcotest.test_case "10.3 2y6m" `Quick test_10_3
        ; Alcotest.test_case "10.4 2y11m" `Quick test_10_4
        ; Alcotest.test_case "10.5 day before 24m" `Quick test_10_5
        ] )
    ; ( "11. Half-year tier"
      , [ Alcotest.test_case "11.1 3 years" `Quick test_11_1
        ; Alcotest.test_case "11.2 3y5m" `Quick test_11_2
        ; Alcotest.test_case "11.3 3y6m" `Quick test_11_3
        ; Alcotest.test_case "11.4 3y11m" `Quick test_11_4
        ; Alcotest.test_case "11.5 4 years" `Quick test_11_5
        ; Alcotest.test_case "11.6 4y6m" `Quick test_11_6
        ; Alcotest.test_case "11.7 5 years" `Quick test_11_7
        ; Alcotest.test_case "11.8 5y8m" `Quick test_11_8
        ; Alcotest.test_case "11.9 6 years" `Quick test_11_9
        ; Alcotest.test_case "11.10 6y6m" `Quick test_11_10
        ; Alcotest.test_case "11.11 6y11m" `Quick test_11_11
        ; Alcotest.test_case "11.12 day before 3rd birthday" `Quick test_11_12
        ] )
    ; ( "12. Integer tier"
      , [ Alcotest.test_case "12.1 7 years" `Quick test_12_1
        ; Alcotest.test_case "12.2 7y3m" `Quick test_12_2
        ; Alcotest.test_case "12.3 45 years" `Quick test_12_3
        ] )
    ; ( "13. Cross-year transitions"
      , [ Alcotest.test_case "13.1 Dec31->Mar31 = 3 months" `Quick test_13_1
        ; Alcotest.test_case "13.2 Dec31->Mar30 still weeks" `Quick test_13_2
        ; Alcotest.test_case "13.3 Nov30->Feb28 = 3 months" `Quick test_13_3
        ; Alcotest.test_case "13.4 Nov30->Feb27 still weeks" `Quick test_13_4
        ] )
    ; ( "14. Born-on-31st progression"
      , [ Alcotest.test_case "14.1 Jan31->Apr30 = 3 months" `Quick test_14_1
        ; Alcotest.test_case "14.2 Jan31->May31 = 4 months" `Quick test_14_2
        ; Alcotest.test_case "14.3 Jan31->Jun30 = 5 months" `Quick test_14_3
        ; Alcotest.test_case "14.4 Jan31->Jul1 = 5 months" `Quick test_14_4
        ; Alcotest.test_case "14.5 Jan31->Jul31 = 6 months" `Quick test_14_5
        ] )
    ; ( "16. formatStage null/edge"
      , [ Alcotest.test_case "16.1/16.3 empty string" `Quick test_16_1
        ; Alcotest.test_case "16.4 future DOB" `Quick test_16_4
        ; Alcotest.test_case "16.5 exactly 500 years" `Quick test_16_5
        ; Alcotest.test_case "16.6 501 years" `Quick test_16_6
        ] )
    ; ( "17. formatStage - Newborn"
      , [ Alcotest.test_case "17.1 born today" `Quick test_17_1
        ; Alcotest.test_case "17.2 1 day" `Quick test_17_2
        ; Alcotest.test_case "17.3 3 weeks" `Quick test_17_3
        ; Alcotest.test_case "17.4 1 month" `Quick test_17_4
        ; Alcotest.test_case "17.5 1 month 29 days" `Quick test_17_5
        ; Alcotest.test_case "17.6 2 months = Infant" `Quick test_17_6
        ] )
    ; ( "18. formatStage - Infant"
      , [ Alcotest.test_case "18.1 2 months" `Quick test_18_1
        ; Alcotest.test_case "18.2 6 months" `Quick test_18_2
        ; Alcotest.test_case "18.3 11 months" `Quick test_18_3
        ; Alcotest.test_case "18.4 12 months = Toddler" `Quick test_18_4
        ] )
    ; ( "19. formatStage - Toddler"
      , [ Alcotest.test_case "19.1 12 months" `Quick test_19_1
        ; Alcotest.test_case "19.2 18 months" `Quick test_19_2
        ; Alcotest.test_case "19.3 24 months" `Quick test_19_3
        ; Alcotest.test_case "19.4 35 months" `Quick test_19_4
        ; Alcotest.test_case "19.5 36 months = Child" `Quick test_19_5
        ] )
    ; ( "20. formatStage - Child"
      , [ Alcotest.test_case "20.1 3 years" `Quick test_20_1
        ; Alcotest.test_case "20.2 4 years" `Quick test_20_2
        ; Alcotest.test_case "20.3 6 years" `Quick test_20_3
        ; Alcotest.test_case "20.4 9 years" `Quick test_20_4
        ; Alcotest.test_case "20.5 12y11m" `Quick test_20_5
        ; Alcotest.test_case "20.6 13 years = Teenager" `Quick test_20_6
        ] )
    ; ( "21. formatStage - Teenager"
      , [ Alcotest.test_case "21.1 13 years" `Quick test_21_1
        ; Alcotest.test_case "21.2 15 years" `Quick test_21_2
        ; Alcotest.test_case "21.3 17y11m" `Quick test_21_3
        ; Alcotest.test_case "21.4 18 years = Adult" `Quick test_21_4
        ] )
    ; ( "22. formatStage - Adult"
      , [ Alcotest.test_case "22.1 18 years" `Quick test_22_1
        ; Alcotest.test_case "22.2 25 years" `Quick test_22_2
        ; Alcotest.test_case "22.3 45 years" `Quick test_22_3
        ] )
    ; ( "24. English locale delegation"
      , [ Alcotest.test_case "24.1 Newborn" `Quick test_24_1
        ; Alcotest.test_case "24.2 3 days" `Quick test_24_2
        ; Alcotest.test_case "24.3 1w1d" `Quick test_24_3
        ; Alcotest.test_case "24.4 6 months" `Quick test_24_4
        ; Alcotest.test_case "24.5 2y1m" `Quick test_24_5
        ; Alcotest.test_case "24.6 3.5 years" `Quick test_24_6
        ; Alcotest.test_case "24.7 7 years" `Quick test_24_7
        ; Alcotest.test_case "24.8 stage Newborn" `Quick test_24_8
        ; Alcotest.test_case "24.9 stage Infant" `Quick test_24_9
        ; Alcotest.test_case "24.10 stage Toddler" `Quick test_24_10
        ; Alcotest.test_case "24.11 stage Child" `Quick test_24_11
        ; Alcotest.test_case "24.12 stage Teenager" `Quick test_24_12
        ; Alcotest.test_case "24.13 stage Adult" `Quick test_24_13
        ; Alcotest.test_case "24.14 null formatAge" `Quick test_24_14
        ; Alcotest.test_case "24.15 null formatStage" `Quick test_24_15
        ] )
    ; ( "25. i18n - Spanish"
      , [ Alcotest.test_case "25.1 justBorn" `Quick test_25_1
        ; Alcotest.test_case "25.2 singular day" `Quick test_25_2
        ; Alcotest.test_case "25.3 plural days" `Quick test_25_3
        ; Alcotest.test_case "25.4 singular week" `Quick test_25_4
        ; Alcotest.test_case "25.5 compound" `Quick test_25_5
        ; Alcotest.test_case "25.6 plural compound" `Quick test_25_6
        ; Alcotest.test_case "25.7 months" `Quick test_25_7
        ; Alcotest.test_case "25.8 singular month" `Quick test_25_8
        ; Alcotest.test_case "25.9 years+months" `Quick test_25_9
        ; Alcotest.test_case "25.10 half marker" `Quick test_25_10
        ; Alcotest.test_case "25.11 no half" `Quick test_25_11
        ; Alcotest.test_case "25.12 7+ years" `Quick test_25_12
        ; Alcotest.test_case "25.13 stage Newborn" `Quick test_25_13
        ; Alcotest.test_case "25.14 stage Infant" `Quick test_25_14
        ; Alcotest.test_case "25.15 stage Toddler" `Quick test_25_15
        ; Alcotest.test_case "25.16 stage Child" `Quick test_25_16
        ; Alcotest.test_case "25.17 stage Teenager" `Quick test_25_17
        ; Alcotest.test_case "25.18 stage Adult" `Quick test_25_18
        ; Alcotest.test_case "25.19 null age" `Quick test_25_19
        ; Alcotest.test_case "25.20 null stage" `Quick test_25_20
        ] )
    ; ( "26. Compactness - short"
      , [ Alcotest.test_case "26.1 short days" `Quick test_26_1
        ; Alcotest.test_case "26.2 short week" `Quick test_26_2
        ; Alcotest.test_case "26.3 short compound" `Quick test_26_3
        ; Alcotest.test_case "26.4 short months" `Quick test_26_4
        ; Alcotest.test_case "26.5 short years+months" `Quick test_26_5
        ; Alcotest.test_case "26.6 short half" `Quick test_26_6
        ; Alcotest.test_case "26.7 short years" `Quick test_26_7
        ; Alcotest.test_case "26.8 justBorn unchanged" `Quick test_26_8
        ; Alcotest.test_case "26.9 stages unchanged" `Quick test_26_9
        ] )
    ; ( "27. Compactness - compact"
      , [ Alcotest.test_case "27.1 compact days" `Quick test_27_1
        ; Alcotest.test_case "27.2 compact week" `Quick test_27_2
        ; Alcotest.test_case "27.3 no delimiter" `Quick test_27_3
        ; Alcotest.test_case "27.4 compact months" `Quick test_27_4
        ; Alcotest.test_case "27.5 no delimiter" `Quick test_27_5
        ; Alcotest.test_case "27.6 compact half" `Quick test_27_6
        ; Alcotest.test_case "27.7 compact years" `Quick test_27_7
        ; Alcotest.test_case "27.8 justBorn unchanged" `Quick test_27_8
        ] )
    ; ( "29.1 Hebrew dual forms"
      , [ Alcotest.test_case "29.1 justBorn" `Quick test_29_1
        ; Alcotest.test_case "29.2 1 day" `Quick test_29_2
        ; Alcotest.test_case "29.3 3 days" `Quick test_29_3
        ; Alcotest.test_case "29.4 2 weeks dual" `Quick test_29_4
        ; Alcotest.test_case "29.5 3 weeks" `Quick test_29_5
        ; Alcotest.test_case "29.6 6 months" `Quick test_29_6
        ; Alcotest.test_case "29.7 3 months" `Quick test_29_7
        ; Alcotest.test_case "29.8 2y dual + 1m" `Quick test_29_8
        ; Alcotest.test_case "29.9 3.5 years" `Quick test_29_9
        ; Alcotest.test_case "29.10 7 years" `Quick test_29_10
        ; Alcotest.test_case "29.11 masculine newborn" `Quick test_29_11
        ; Alcotest.test_case "29.12 feminine newborn" `Quick test_29_12
        ; Alcotest.test_case "29.13 masculine adult" `Quick test_29_13
        ; Alcotest.test_case "29.14 feminine adult" `Quick test_29_14
        ] )
    ; ( "29.2 Macedonian"
      , [ Alcotest.test_case "29.15 justBorn" `Quick test_29_15
        ; Alcotest.test_case "29.16 1 day" `Quick test_29_16
        ; Alcotest.test_case "29.17 3 days" `Quick test_29_17
        ; Alcotest.test_case "29.18 6 months" `Quick test_29_18
        ; Alcotest.test_case "29.19 2y1m" `Quick test_29_19
        ; Alcotest.test_case "29.20 3.5 years" `Quick test_29_20
        ; Alcotest.test_case "29.21 7 years" `Quick test_29_21
        ] )
    ; ( "29.3 Swahili"
      , [ Alcotest.test_case "29.22 justBorn" `Quick test_29_22
        ; Alcotest.test_case "29.23 1 day" `Quick test_29_23
        ; Alcotest.test_case "29.24 3 days" `Quick test_29_24
        ; Alcotest.test_case "29.25 6 months" `Quick test_29_25
        ; Alcotest.test_case "29.26 2y+1m" `Quick test_29_26
        ; Alcotest.test_case "29.27 3.5 years" `Quick test_29_27
        ] )
    ; ( "29.4 Indonesian"
      , [ Alcotest.test_case "29.28 justBorn" `Quick test_29_28
        ; Alcotest.test_case "29.29 1 day" `Quick test_29_29
        ; Alcotest.test_case "29.30 3 days" `Quick test_29_30
        ; Alcotest.test_case "29.31 6 months" `Quick test_29_31
        ; Alcotest.test_case "29.32 3.5 years" `Quick test_29_32
        ; Alcotest.test_case "29.33 7 years" `Quick test_29_33
        ] )
    ; ( "29.5 Amharic"
      , [ Alcotest.test_case "29.34 justBorn" `Quick test_29_34
        ; Alcotest.test_case "29.35 1 day" `Quick test_29_35
        ; Alcotest.test_case "29.36 3 days" `Quick test_29_36
        ; Alcotest.test_case "29.37 1w1d ethiopic delimiter" `Quick test_29_37
        ; Alcotest.test_case "29.38 6 months" `Quick test_29_38
        ; Alcotest.test_case "29.39 3.5 years" `Quick test_29_39
        ] )
    ; ( "30. Locale lookup"
      , [ Alcotest.test_case "30.1 known locale en" `Quick test_30_1
        ; Alcotest.test_case "30.2 known locale fr" `Quick test_30_2
        ; Alcotest.test_case "30.3 unknown code" `Quick test_30_3
        ; Alcotest.test_case "30.4 empty string" `Quick test_30_4
        ; Alcotest.test_case "30.5 case-sensitive" `Quick test_30_5
        ] )
    ]

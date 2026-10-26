open Sayable_date

let en = En.locale
let de = De.locale
let fr = Fr.locale
let ja = Ja.locale
let ru = Ru.locale
let ar = Ar.locale
let es = Es.locale

let fdate loc date = Formatter.format_date loc Types.Normal date
let fdate_s loc comp date = Formatter.format_date loc comp date
let frel loc date as_of = Formatter.format_relative loc Types.Normal date as_of
let frel_c loc comp date as_of = Formatter.format_relative loc comp date as_of

let check_some expected result =
  Alcotest.(check (option string)) "same" (Some expected) result

let check_none result =
  Alcotest.(check (option string)) "same" None result

(* 1. Null / edge cases *)
let test_1_1 () = check_none (fdate en "")                          (* 1.1 null date *)
let test_1_2 () = check_none (fdate en "")                          (* 1.2 empty string *)
let test_1_3 () = check_none (fdate en "invalid")                   (* 1.3 invalid *)
let test_1_4 () = check_none (frel en "2025-03-15" "")              (* 1.4 null asOf *)
let test_1_5 () = check_none (frel en "" "2025-03-15")              (* 1.5 null date *)

(* 2. format_date — normal compactness (English) *)
let test_2_1 () = check_some "March 15th" (fdate en "2025-03-15")          (* 2.1 *)
let test_2_2 () = check_some "January 1st" (fdate en "2025-01-01")         (* 2.2 *)
let test_2_3 () = check_some "May 22nd" (fdate en "2025-05-22")            (* 2.3 *)
let test_2_4 () = check_some "July 3rd" (fdate en "2025-07-03")            (* 2.4 *)
let test_2_5 () = check_some "December 31st" (fdate en "2025-12-31")       (* 2.5 *)
let test_2_6 () = check_some "June 11th" (fdate en "2025-06-11")           (* 2.6 *)
let test_2_7 () = check_some "March 15th" (fdate en "2025-03-15T14:30:00") (* 2.7 ISO datetime *)

(* 3. format_date — short compactness (English) *)
let test_3_1 () = check_some "Mar 15" (fdate_s en Types.Short "2025-03-15")  (* 3.1 *)
let test_3_2 () = check_some "Jan 1" (fdate_s en Types.Short "2025-01-01")   (* 3.2 *)
let test_3_3 () = check_some "Dec 25" (fdate_s en Types.Short "2025-12-25")  (* 3.3 *)

(* 4. format_date — compact (English) *)
let test_4_1 () = check_some "3/15" (fdate_s en Types.Compact "2025-03-15")  (* 4.1 *)
let test_4_2 () = check_some "1/1" (fdate_s en Types.Compact "2025-01-01")   (* 4.2 *)

(* 5. format_relative — proximity tiers (English) *)
let test_5_1 () = check_some "today" (frel en "2025-03-15" "2025-03-15")                           (* 5.1 *)
let test_5_2 () = check_some "tomorrow" (frel en "2025-03-16" "2025-03-15")                        (* 5.2 *)
let test_5_3 () = check_some "yesterday" (frel en "2025-03-14" "2025-03-15")                       (* 5.3 *)
let test_5_4 () = check_some "the day after tomorrow" (frel en "2025-03-17" "2025-03-15")          (* 5.4 *)
let test_5_5 () = check_some "the day before yesterday" (frel en "2025-03-13" "2025-03-15")        (* 5.5 *)
let test_5_6 () = check_some "this Wednesday" (frel en "2025-03-19" "2025-03-15")                  (* 5.6 *)
let test_5_7 () = check_some "this Thursday" (frel en "2025-03-20" "2025-03-15")                   (* 5.7 *)
let test_5_8 () = check_some "last Tuesday" (frel en "2025-03-11" "2025-03-15")                    (* 5.8 *)
let test_5_9 () = check_some "next Saturday" (frel en "2025-03-22" "2025-03-15")                   (* 5.9 *)
let test_5_10 () = check_some "next Thursday" (frel en "2025-03-27" "2025-03-15")                  (* 5.10 *)
let test_5_11 () = check_some "March 1st" (frel en "2025-03-01" "2025-03-15")                      (* 5.11 *)
let test_5_12 () = check_some "April 10th" (frel en "2025-04-10" "2025-03-15")                     (* 5.12 *)
let test_5_13 () = check_some "January 5th, 2026" (frel en "2026-01-05" "2025-03-15")              (* 5.13 *)
let test_5_14 () = check_some "December 25th, 2024" (frel en "2024-12-25" "2025-03-15")            (* 5.14 *)

(* 6. format_relative — compact skips weekday tiers *)
let test_6_1 () = check_some "today" (frel_c en Types.Compact "2025-03-15" "2025-03-15")           (* 6.1 *)
let test_6_2 () = check_some "tomorrow" (frel_c en Types.Compact "2025-03-16" "2025-03-15")        (* 6.2 *)
let test_6_3 () = check_some "3/19" (frel_c en Types.Compact "2025-03-19" "2025-03-15")            (* 6.3 *)
let test_6_4 () = check_some "1/5/26" (frel_c en Types.Compact "2026-01-05" "2025-03-15")          (* 6.4 *)

(* 7. Locale — German *)
let test_7_1 () = check_some "15. M\xc3\xa4rz" (fdate de "2025-03-15")                              (* 7.1 *)
let test_7_2 () = check_some "morgen" (frel de "2025-03-16" "2025-03-15")                            (* 7.2 *)
let test_7_3 () = check_some "\xc3\xbcbermorgen" (frel de "2025-03-17" "2025-03-15")                 (* 7.3 *)
let test_7_4 () = check_some "diesen Mittwoch" (frel de "2025-03-19" "2025-03-15")                   (* 7.4 *)

(* 8. Locale — French *)
let test_8_1 () = check_some "1er mars" (fdate fr "2025-03-01")                                      (* 8.1 *)
let test_8_2 () = check_some "15 mars" (fdate fr "2025-03-15")                                       (* 8.2 *)
let test_8_3 () = check_some "demain" (frel fr "2025-03-16" "2025-03-15")                            (* 8.3 *)

(* 9. Locale — Japanese *)
let test_9_1 () = check_some "3\xe6\x9c\x8815\xe6\x97\xa5" (fdate ja "2025-03-15")                  (* 9.1 *)
let test_9_2 () = check_some "\xe6\x98\x8e\xe6\x97\xa5" (frel ja "2025-03-16" "2025-03-15")         (* 9.2 *)
let test_9_3 () = check_some "\xe4\xbb\x8a\xe5\xba\xa6\xe3\x81\xae\xe6\xb0\xb4\xe6\x9b\x9c\xe6\x97\xa5" (frel ja "2025-03-19" "2025-03-15") (* 9.3 *)

(* 10. Locale — Russian (genitive months) *)
let test_10_1 () = check_some "15 \xd0\xbc\xd0\xb0\xd1\x80\xd1\x82\xd0\xb0" (fdate ru "2025-03-15") (* 10.1 *)
let test_10_2 () = check_some "\xd0\xb7\xd0\xb0\xd0\xb2\xd1\x82\xd1\x80\xd0\xb0" (frel ru "2025-03-16" "2025-03-15") (* 10.2 *)

(* 11. Locale — Arabic *)
let test_11_1 () = check_some "15 \xd9\x85\xd8\xa7\xd8\xb1\xd8\xb3" (fdate ar "2025-03-15")        (* 11.1 *)
let test_11_2 () = check_some "\xd8\xba\xd8\xaf\xd8\xa7\xd9\x8b" (frel ar "2025-03-16" "2025-03-15") (* 11.2 *)

(* 12. Locale — Spanish *)
let test_12_1 () = check_some "15 de marzo" (fdate es "2025-03-15")                                  (* 12.1 *)
let test_12_2 () = check_some "pasado ma\xc3\xb1ana" (frel es "2025-03-17" "2025-03-15")             (* 12.2 *)

(* Formats with the locale for a code (None for an unknown code). *)
let with_locale code f = Option.bind (Locales.get_locale code) f

let expect_canonical expected actual =
  Alcotest.(check (option string)) "canonical" expected actual

(* 13. format_date_with_year *)
let test_13_1 () = expect_canonical (Some "February 4th, 2018") (with_locale "en" (fun l -> Formatter.format_date_with_year l Types.Normal "2018-02-04"))  (* 13.1 *)
let test_13_2 () = expect_canonical (Some "Mar 15, 2025") (with_locale "en" (fun l -> Formatter.format_date_with_year l Types.Short "2025-03-15"))  (* 13.2 *)
let test_13_3 () = expect_canonical (Some "1/21/97") (with_locale "en" (fun l -> Formatter.format_date_with_year l Types.Compact "1997-01-21"))  (* 13.3 *)
let test_13_4 () = expect_canonical (Some "20/5/07") (with_locale "tg" (fun l -> Formatter.format_date_with_year l Types.Compact "2007-05-20"))  (* 13.4 *)
let test_13_5 () = expect_canonical (Some "21. kesäkuuta 1996") (with_locale "fi" (fun l -> Formatter.format_date_with_year l Types.Short "1996-06-21"))  (* 13.5 *)
(* 14. Short month names (locales that keep the full genitive) *)
let test_14_1 () = expect_canonical (Some "15. februára") (with_locale "sk" (fun l -> Formatter.format_date l Types.Short "2031-02-15"))  (* 14.1 *)
let test_14_2 () = expect_canonical (Some "10. prosince") (with_locale "cs" (fun l -> Formatter.format_date l Types.Short "2025-12-10"))  (* 14.2 *)
let test_14_3 () = expect_canonical (Some "5 листопада") (with_locale "uk" (fun l -> Formatter.format_date l Types.Short "2025-11-05"))  (* 14.3 *)
let test_14_4 () = expect_canonical (Some "8. elokuuta") (with_locale "fi" (fun l -> Formatter.format_relative l Types.Short "1998-08-08" "1998-08-15"))  (* 14.4 *)
(* 15. format_relative — short phrases *)
let test_15_1 () = expect_canonical (Some "an Mth ma") (with_locale "kw" (fun l -> Formatter.format_relative l Types.Short "2035-12-04" "2035-12-02"))  (* 15.1 *)
let test_15_2 () = expect_canonical (Some "Dom nchi'j") (with_locale "mam" (fun l -> Formatter.format_relative l Types.Short "2000-01-23" "2000-01-25"))  (* 15.2 *)
let test_15_3 () = expect_canonical (Some "a'in Vie") (with_locale "kek" (fun l -> Formatter.format_relative l Types.Short "2014-10-24" "2014-10-22"))  (* 15.3 *)
(* 16. Input validation *)
let test_16_1 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_date l Types.Normal "2025-02-30"))  (* 16.1 *)
let test_16_2 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_date l Types.Normal "2025-13-01"))  (* 16.2 *)
let test_16_3 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_date l Types.Normal "2025-6-1"))  (* 16.3 *)
let test_16_4 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_date l Types.Normal " 2025-06-01"))  (* 16.4 *)
let test_16_5 () = expect_canonical (Some "June 1st") (with_locale "en" (fun l -> Formatter.format_date l Types.Normal "2025-06-01T10:00:00"))  (* 16.5 *)
let test_16_6 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_date_with_year l Types.Normal "2023-02-29"))  (* 16.6 *)
let test_16_7 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_relative l Types.Normal "2025-03-16" "2025-04-31"))  (* 16.7 *)

let () =
  Alcotest.run "sayable-date"
    [ ( "1. Null / edge cases"
      , [ Alcotest.test_case "1.1 null date" `Quick test_1_1
        ; Alcotest.test_case "1.2 empty string" `Quick test_1_2
        ; Alcotest.test_case "1.3 invalid" `Quick test_1_3
        ; Alcotest.test_case "1.4 null asOf" `Quick test_1_4
        ; Alcotest.test_case "1.5 null date for relative" `Quick test_1_5
        ] )
    ; ( "2. format_date normal (English)"
      , [ Alcotest.test_case "2.1 March 15th" `Quick test_2_1
        ; Alcotest.test_case "2.2 January 1st" `Quick test_2_2
        ; Alcotest.test_case "2.3 May 22nd" `Quick test_2_3
        ; Alcotest.test_case "2.4 July 3rd" `Quick test_2_4
        ; Alcotest.test_case "2.5 December 31st" `Quick test_2_5
        ; Alcotest.test_case "2.6 June 11th" `Quick test_2_6
        ; Alcotest.test_case "2.7 ISO datetime" `Quick test_2_7
        ] )
    ; ( "3. format_date short (English)"
      , [ Alcotest.test_case "3.1 Mar 15" `Quick test_3_1
        ; Alcotest.test_case "3.2 Jan 1" `Quick test_3_2
        ; Alcotest.test_case "3.3 Dec 25" `Quick test_3_3
        ] )
    ; ( "4. format_date compact (English)"
      , [ Alcotest.test_case "4.1 3/15" `Quick test_4_1
        ; Alcotest.test_case "4.2 1/1" `Quick test_4_2
        ] )
    ; ( "5. format_relative proximity tiers"
      , [ Alcotest.test_case "5.1 today" `Quick test_5_1
        ; Alcotest.test_case "5.2 tomorrow" `Quick test_5_2
        ; Alcotest.test_case "5.3 yesterday" `Quick test_5_3
        ; Alcotest.test_case "5.4 day after tomorrow" `Quick test_5_4
        ; Alcotest.test_case "5.5 day before yesterday" `Quick test_5_5
        ; Alcotest.test_case "5.6 this Wednesday" `Quick test_5_6
        ; Alcotest.test_case "5.7 this Thursday" `Quick test_5_7
        ; Alcotest.test_case "5.8 last Tuesday" `Quick test_5_8
        ; Alcotest.test_case "5.9 next Saturday" `Quick test_5_9
        ; Alcotest.test_case "5.10 next Thursday" `Quick test_5_10
        ; Alcotest.test_case "5.11 calendar fallback same year" `Quick test_5_11
        ; Alcotest.test_case "5.12 calendar fallback same year" `Quick test_5_12
        ; Alcotest.test_case "5.13 different year" `Quick test_5_13
        ; Alcotest.test_case "5.14 past year" `Quick test_5_14
        ] )
    ; ( "6. format_relative compact"
      , [ Alcotest.test_case "6.1 today" `Quick test_6_1
        ; Alcotest.test_case "6.2 tomorrow" `Quick test_6_2
        ; Alcotest.test_case "6.3 compact numeric" `Quick test_6_3
        ; Alcotest.test_case "6.4 compact different year" `Quick test_6_4
        ] )
    ; ( "7. Locale German"
      , [ Alcotest.test_case "7.1 format_date" `Quick test_7_1
        ; Alcotest.test_case "7.2 morgen" `Quick test_7_2
        ; Alcotest.test_case "7.3 uebermorgen" `Quick test_7_3
        ; Alcotest.test_case "7.4 diesen Mittwoch" `Quick test_7_4
        ] )
    ; ( "8. Locale French"
      , [ Alcotest.test_case "8.1 1er mars" `Quick test_8_1
        ; Alcotest.test_case "8.2 15 mars" `Quick test_8_2
        ; Alcotest.test_case "8.3 demain" `Quick test_8_3
        ] )
    ; ( "9. Locale Japanese"
      , [ Alcotest.test_case "9.1 format_date" `Quick test_9_1
        ; Alcotest.test_case "9.2 ashita" `Quick test_9_2
        ; Alcotest.test_case "9.3 this Wednesday" `Quick test_9_3
        ] )
    ; ( "10. Locale Russian"
      , [ Alcotest.test_case "10.1 genitive month" `Quick test_10_1
        ; Alcotest.test_case "10.2 zavtra" `Quick test_10_2
        ] )
    ; ( "11. Locale Arabic"
      , [ Alcotest.test_case "11.1 format_date" `Quick test_11_1
        ; Alcotest.test_case "11.2 ghadan" `Quick test_11_2
        ] )
    ; ( "12. Locale Spanish"
      , [ Alcotest.test_case "12.1 format_date" `Quick test_12_1
        ; Alcotest.test_case "12.2 pasado manana" `Quick test_12_2
        ] )
    ; ( "13. format_date_with_year"
      , [ Alcotest.test_case "13.1 format_date_with_year en normal" `Quick test_13_1
        ; Alcotest.test_case "13.2 format_date_with_year en short" `Quick test_13_2
        ; Alcotest.test_case "13.3 format_date_with_year en compact" `Quick test_13_3
        ; Alcotest.test_case "13.4 two-digit year keeps its leading zero" `Quick test_13_4
        ; Alcotest.test_case "13.5 format_date_with_year fi short" `Quick test_13_5
        ] )
    ; ( "14. Short month names (locales that keep the full genitive)"
      , [ Alcotest.test_case "14.1 format_date sk short" `Quick test_14_1
        ; Alcotest.test_case "14.2 format_date cs short" `Quick test_14_2
        ; Alcotest.test_case "14.3 format_date uk short" `Quick test_14_3
        ; Alcotest.test_case "14.4 format_relative fi short" `Quick test_14_4
        ] )
    ; ( "15. format_relative — short phrases"
      , [ Alcotest.test_case "15.1 day after tomorrow" `Quick test_15_1
        ; Alcotest.test_case "15.2 day before yesterday" `Quick test_15_2
        ; Alcotest.test_case "15.3 day after tomorrow" `Quick test_15_3
        ] )
    ; ( "16. Input validation"
      , [ Alcotest.test_case "16.1 February 30 doesn't exist" `Quick test_16_1
        ; Alcotest.test_case "16.2 Month 13" `Quick test_16_2
        ; Alcotest.test_case "16.3 Unpadded month and day" `Quick test_16_3
        ; Alcotest.test_case "16.4 Surrounding whitespace" `Quick test_16_4
        ; Alcotest.test_case "16.5 An ISO datetime: only the date part is used" `Quick test_16_5
        ; Alcotest.test_case "16.6 February 29 in a non-leap year" `Quick test_16_6
        ; Alcotest.test_case "16.7 Invalid asOf" `Quick test_16_7
        ] )
    ]

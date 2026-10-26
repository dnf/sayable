open Sayable_duration

let en = En.locale
let de = De.locale
let fr = Fr.locale
let ja = Ja.locale

let dur loc secs = Formatter.format_duration loc Types.Normal (`Seconds secs) None
let dur_iso loc start_iso end_iso = Formatter.format_duration loc Types.Normal (`Iso start_iso) (Some end_iso)
let dur_s loc comp secs = Formatter.format_duration loc comp (`Seconds secs) None
let since loc start as_of = Formatter.format_since loc Types.Normal start as_of
let until loc target as_of = Formatter.format_until loc Types.Normal target as_of

let check_some expected result =
  Alcotest.(check (option string)) "same" (Some expected) result

let check_none result =
  Alcotest.(check (option string)) "same" None result

(* 1. Null / edge cases *)
let test_1_1 () = check_none (Formatter.format_duration en Types.Normal `Null None)                            (* 1.1 null seconds *)
let test_1_2 () = check_none (dur en (-1))                                                                      (* 1.2 negative seconds *)
let test_1_3 () = check_none (since en "" "2025-01-15T10:00:00")                                                (* 1.3 null start *)
let test_1_4 () = check_none (until en "" "2025-01-15T10:00:00")                                                (* 1.4 null target *)
let test_1_5 () = check_none (since en "2025-01-15T10:00:00" "2025-01-15T09:00:00")                             (* 1.5 asOf before start *)
let test_1_6 () = check_none (until en "2025-01-15T09:00:00" "2025-01-15T10:00:00")                             (* 1.6 target in past *)

(* 2. Duration — seconds tier (0-59s) *)
let test_2_1 () = check_some "just now" (dur en 0)              (* 2.1 *)
let test_2_2 () = check_some "1 second" (dur en 1)              (* 2.2 *)
let test_2_3 () = check_some "45 seconds" (dur en 45)           (* 2.3 *)
let test_2_4 () = check_some "59 seconds" (dur en 59)           (* 2.4 *)

(* 3. Duration — minutes + seconds tier (1-4 min) *)
let test_3_1 () = check_some "1 minute" (dur en 60)                      (* 3.1 *)
let test_3_2 () = check_some "1 minute, 30 seconds" (dur en 90)          (* 3.2 *)
let test_3_3 () = check_some "4 minutes" (dur en 240)                    (* 3.3 *)
let test_3_4 () = check_some "4 minutes, 30 seconds" (dur en 270)        (* 3.4 *)

(* 4. Duration — minutes tier (5-59 min) *)
let test_4_1 () = check_some "5 minutes" (dur en 300)                    (* 4.1 *)
let test_4_2 () = check_some "25 minutes" (dur en 1500)                  (* 4.2 *)
let test_4_3 () = check_some "59 minutes" (dur en 3540)                  (* 4.3 *)

(* 5. Duration — hours + minutes tier (1-5 hr) *)
let test_5_1 () = check_some "1 hour" (dur en 3600)                      (* 5.1 *)
let test_5_2 () = {|1½ hours|} |> fun e -> check_some e (dur en 5400)    (* 5.2 half marker *)
let test_5_3 () = check_some "2 hours, 15 minutes" (dur en 8100)         (* 5.3 *)
let test_5_4 () = check_some "5 hours" (dur en 18000)                    (* 5.4 *)

(* 6. Duration — hours tier (6-23 hr) *)
let test_6_1 () = check_some "8 hours" (dur en 28800)                    (* 6.1 *)
let test_6_2 () = check_some "23 hours" (dur en 82800)                   (* 6.2 *)

(* 7. Duration — days tier *)
let test_7_1 () = check_some "1 day" (dur en 86400)                      (* 7.1 *)
let test_7_2 () = check_some "1 day, 3 hours" (dur en 97200)             (* 7.2 *)
let test_7_3 () = {|1½ days|} |> fun e -> check_some e (dur en 129600)   (* 7.3 half marker *)
let test_7_4 () = check_some "5 days" (dur en 432000)                    (* 7.4 *)
let test_7_5 () = check_some "2 days" (dur en 172800)                    (* 7.5 *)

(* 8. Duration — weeks tier *)
let test_8_1 () = check_some "1 week" (dur en 604800)                    (* 8.1 *)
let test_8_2 () = check_some "2 weeks, 1 day" (dur en 1296000)           (* 8.2 *)
let test_8_3 () = check_some "4 weeks" (dur en 2419200)                  (* 8.3 *)

(* 9. Duration — months and years tier *)
let test_9_1 () = check_some "1 month" (dur en 2678400)                  (* 9.1 ~31 days *)
let test_9_2 () = check_some "3 months" (dur en 7884000)                 (* 9.2 ~91 days *)
let test_9_3 () = check_some "1 year" (dur en 31536000)                  (* 9.3 365 days *)
let test_9_4 () = check_some "1 year, 3 months" (dur en 39420000)        (* 9.4 ~456 days *)

(* 10. Duration from ISO timestamps *)
let test_10_1 () = {|1½ hours|} |> fun e ->
  check_some e (dur_iso en "2025-01-15T10:00:00" "2025-01-15T11:30:00")  (* 10.1 *)
let test_10_2 () = check_some "45 minutes"
  (dur_iso en "2025-01-15T10:00:00" "2025-01-15T10:45:00")               (* 10.2 *)

(* 11. Relative time — since *)
let test_11_1 () = check_some "just now"
  (since en "2025-01-15T10:00:00" "2025-01-15T10:00:00")                 (* 11.1 *)
let test_11_2 () = check_some "30 seconds ago"
  (since en "2025-01-15T10:00:00" "2025-01-15T10:00:30")                 (* 11.2 *)
let test_11_3 () = check_some "45 minutes ago"
  (since en "2025-01-15T10:00:00" "2025-01-15T10:45:00")                 (* 11.3 *)
let test_11_4 () = check_some "3 hours ago"
  (since en "2025-01-15T10:00:00" "2025-01-15T13:00:00")                 (* 11.4 *)

(* 12. Relative time — until *)
let test_12_1 () = check_some "just now"
  (until en "2025-01-15T10:00:00" "2025-01-15T10:00:00")                 (* 12.1 *)
let test_12_2 () = check_some "in 20 minutes"
  (until en "2025-01-15T10:20:00" "2025-01-15T10:00:00")                 (* 12.2 *)
let test_12_3 () = check_some "in 3 hours"
  (until en "2025-01-15T13:00:00" "2025-01-15T10:00:00")                 (* 12.3 *)

(* 13. Locale — German *)
let test_13_1 () = check_some "1 Stunde" (Formatter.format_duration de Types.Normal (`Seconds 3600) None)                       (* 13.1 *)
let test_13_2 () = check_some "vor 5 Minuten"
  (Formatter.format_since de Types.Normal "2025-01-15T10:00:00" "2025-01-15T10:05:00")                                          (* 13.2 *)

(* 14. Locale — French *)
let test_14_1 () = check_some "2 heures" (Formatter.format_duration fr Types.Normal (`Seconds 7200) None)                       (* 14.1 *)

(* 15. Locale — Japanese *)
let test_15_1 () = check_some "2\xe5\x88\x86" (Formatter.format_duration ja Types.Normal (`Seconds 120) None)                   (* 15.1 *)
let test_15_2 () = check_some "1\xe6\x99\x82\xe9\x96\x93\xe5\x89\x8d"
  (Formatter.format_since ja Types.Normal "2025-01-15T10:00:00" "2025-01-15T11:00:00")                                          (* 15.2 *)

(* 16. Short compactness — duration *)
let test_16_1 () = check_some "1h" (dur_s en Types.Short 3600)           (* 16.1 *)
let test_16_2 () = check_some "1m, 30s" (dur_s en Types.Short 90)        (* 16.2 *)

(* 17. Compact compactness — duration *)
let test_17_1 () = check_some "1h" (dur_s en Types.Compact 3600)         (* 17.1 *)
let test_17_2 () = check_some "1m30s" (dur_s en Types.Compact 90)        (* 17.2 *)

(* Formats with the locale for a code (None for an unknown code). *)
let with_locale code f = Option.bind (Locales.get_locale code) f

let expect_canonical expected actual =
  Alcotest.(check (option string)) "canonical" expected actual

(* 18. Short compactness — relative time *)
let test_18_1 () = expect_canonical (Some "lɔhɔnga 2, awa 14 taa gbɔyɔ") (with_locale "men" (fun l -> Formatter.format_since l Types.Normal "2025-01-20T01:32:11" "2025-01-22T15:39:16"))  (* 18.1 *)
(* 19. Range (500-year ceiling) *)
let test_19_1 () = expect_canonical (Some "500 years") (with_locale "en" (fun l -> Formatter.format_duration l Types.Normal (`Seconds 15778800000) None))  (* 19.1 *)
let test_19_2 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_duration l Types.Normal (`Seconds 15800000000) None))  (* 19.2 *)
let test_19_3 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_duration l Types.Normal (`Seconds 99999999999) None))  (* 19.3 *)
let test_19_4 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_since l Types.Normal "1500-01-01T00:00:00" "2025-01-01T00:00:00"))  (* 19.4 *)
let test_19_5 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_until l Types.Normal "2600-01-01T00:00:00" "2025-01-01T00:00:00"))  (* 19.5 *)
(* 20. Timestamp validation *)
let test_20_1 () = expect_canonical (Some "1½ hours") (with_locale "en" (fun l -> Formatter.format_duration l Types.Normal (`Iso "2025-01-15T10:00") (Some "2025-01-15T11:30:00")))  (* 20.1 *)
let test_20_2 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_duration l Types.Normal (`Iso "2025-01-15T10") (Some "2025-01-15T11:30:00")))  (* 20.2 *)
let test_20_3 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_duration l Types.Normal (`Iso "2025-1-5T10:00:00") (Some "2025-01-15T11:30:00")))  (* 20.3 *)
let test_20_4 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_duration l Types.Normal (`Iso "2025-02-30T10:00:00") (Some "2025-03-15T11:30:00")))  (* 20.4 *)
let test_20_5 () = expect_canonical None (with_locale "en" (fun l -> Formatter.format_since l Types.Normal "2025-01-15T10:00:00" "2025-01-15T25:00:00"))  (* 20.5 *)

let () =
  Alcotest.run "sayable-duration"
    [ ( "1. Null / edge cases"
      , [ Alcotest.test_case "1.1 null seconds" `Quick test_1_1
        ; Alcotest.test_case "1.2 negative seconds" `Quick test_1_2
        ; Alcotest.test_case "1.3 null start" `Quick test_1_3
        ; Alcotest.test_case "1.4 null target" `Quick test_1_4
        ; Alcotest.test_case "1.5 asOf before start" `Quick test_1_5
        ; Alcotest.test_case "1.6 target in past" `Quick test_1_6
        ] )
    ; ( "2. Seconds tier"
      , [ Alcotest.test_case "2.1 0 seconds" `Quick test_2_1
        ; Alcotest.test_case "2.2 1 second" `Quick test_2_2
        ; Alcotest.test_case "2.3 45 seconds" `Quick test_2_3
        ; Alcotest.test_case "2.4 59 seconds" `Quick test_2_4
        ] )
    ; ( "3. Minutes + seconds tier"
      , [ Alcotest.test_case "3.1 1 minute" `Quick test_3_1
        ; Alcotest.test_case "3.2 1m 30s" `Quick test_3_2
        ; Alcotest.test_case "3.3 4 minutes" `Quick test_3_3
        ; Alcotest.test_case "3.4 4m 30s" `Quick test_3_4
        ] )
    ; ( "4. Minutes tier"
      , [ Alcotest.test_case "4.1 5 minutes" `Quick test_4_1
        ; Alcotest.test_case "4.2 25 minutes" `Quick test_4_2
        ; Alcotest.test_case "4.3 59 minutes" `Quick test_4_3
        ] )
    ; ( "5. Hours + minutes tier"
      , [ Alcotest.test_case "5.1 1 hour" `Quick test_5_1
        ; Alcotest.test_case "5.2 1.5 hours" `Quick test_5_2
        ; Alcotest.test_case "5.3 2h 15m" `Quick test_5_3
        ; Alcotest.test_case "5.4 5 hours" `Quick test_5_4
        ] )
    ; ( "6. Hours tier"
      , [ Alcotest.test_case "6.1 8 hours" `Quick test_6_1
        ; Alcotest.test_case "6.2 23 hours" `Quick test_6_2
        ] )
    ; ( "7. Days tier"
      , [ Alcotest.test_case "7.1 1 day" `Quick test_7_1
        ; Alcotest.test_case "7.2 1d 3h" `Quick test_7_2
        ; Alcotest.test_case "7.3 1.5 days" `Quick test_7_3
        ; Alcotest.test_case "7.4 5 days" `Quick test_7_4
        ; Alcotest.test_case "7.5 2 days" `Quick test_7_5
        ] )
    ; ( "8. Weeks tier"
      , [ Alcotest.test_case "8.1 1 week" `Quick test_8_1
        ; Alcotest.test_case "8.2 2w 1d" `Quick test_8_2
        ; Alcotest.test_case "8.3 4 weeks" `Quick test_8_3
        ] )
    ; ( "9. Months and years tier"
      , [ Alcotest.test_case "9.1 1 month" `Quick test_9_1
        ; Alcotest.test_case "9.2 3 months" `Quick test_9_2
        ; Alcotest.test_case "9.3 1 year" `Quick test_9_3
        ; Alcotest.test_case "9.4 1y 3m" `Quick test_9_4
        ] )
    ; ( "10. ISO timestamps"
      , [ Alcotest.test_case "10.1 1.5 hours" `Quick test_10_1
        ; Alcotest.test_case "10.2 45 minutes" `Quick test_10_2
        ] )
    ; ( "11. format_since"
      , [ Alcotest.test_case "11.1 just now" `Quick test_11_1
        ; Alcotest.test_case "11.2 30 seconds ago" `Quick test_11_2
        ; Alcotest.test_case "11.3 45 minutes ago" `Quick test_11_3
        ; Alcotest.test_case "11.4 3 hours ago" `Quick test_11_4
        ] )
    ; ( "12. format_until"
      , [ Alcotest.test_case "12.1 just now" `Quick test_12_1
        ; Alcotest.test_case "12.2 in 20 minutes" `Quick test_12_2
        ; Alcotest.test_case "12.3 in 3 hours" `Quick test_12_3
        ] )
    ; ( "13. Locale German"
      , [ Alcotest.test_case "13.1 1 Stunde" `Quick test_13_1
        ; Alcotest.test_case "13.2 vor 5 Minuten" `Quick test_13_2
        ] )
    ; ( "14. Locale French"
      , [ Alcotest.test_case "14.1 2 heures" `Quick test_14_1
        ] )
    ; ( "15. Locale Japanese"
      , [ Alcotest.test_case "15.1 2 fun" `Quick test_15_1
        ; Alcotest.test_case "15.2 1 jikan mae" `Quick test_15_2
        ] )
    ; ( "16. Short compactness"
      , [ Alcotest.test_case "16.1 1h" `Quick test_16_1
        ; Alcotest.test_case "16.2 1m 30s" `Quick test_16_2
        ] )
    ; ( "17. Compact compactness"
      , [ Alcotest.test_case "17.1 1h" `Quick test_17_1
        ; Alcotest.test_case "17.2 1m30s" `Quick test_17_2
        ] )
    ; ( "18. Short compactness — relative time"
      , [ Alcotest.test_case "18.1 days and hours both kept" `Quick test_18_1
        ] )
    ; ( "19. Range (500-year ceiling)"
      , [ Alcotest.test_case "19.1 500 Julian years: 6000 months, the ceiling" `Quick test_19_1
        ; Alcotest.test_case "19.2 over 6000 months" `Quick test_19_2
        ; Alcotest.test_case "19.3 well beyond the ceiling (and 32-bit range)" `Quick test_19_3
        ; Alcotest.test_case "19.4 525 years ago" `Quick test_19_4
        ; Alcotest.test_case "19.5 575 years from now" `Quick test_19_5
        ] )
    ; ( "20. Timestamp validation"
      , [ Alcotest.test_case "20.1 seconds are optional" `Quick test_20_1
        ; Alcotest.test_case "20.2 minutes are required" `Quick test_20_2
        ; Alcotest.test_case "20.3 unpadded date" `Quick test_20_3
        ; Alcotest.test_case "20.4 impossible date" `Quick test_20_4
        ; Alcotest.test_case "20.5 hour out of range" `Quick test_20_5
        ] )
    ]

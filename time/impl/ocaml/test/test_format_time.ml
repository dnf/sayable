open Sayable_time

let en = En.locale
let de = De.locale
let fr = Fr.locale
let ja = Ja.locale

let ftime loc input = Formatter.format_time loc Types.Normal input
let ftime_s loc comp input = Formatter.format_time loc comp input

let check_some expected result =
  Alcotest.(check (option string)) "same" (Some expected) result

let check_none result =
  Alcotest.(check (option string)) "same" None result

(* 1. Null / edge cases *)
let test_1_1 () = check_none (ftime en "")           (* 1.1 null time *)
let test_1_2 () = check_none (ftime en "")           (* 1.2 empty string *)
let test_1_3 () = check_none (ftime en "invalid")    (* 1.3 invalid *)
let test_1_4 () = check_none (ftime en "25:00")      (* 1.4 out of range *)

(* 2. Clock time (normal compactness) *)
let test_2_1 () = check_some "midnight" (ftime en "00:00")                          (* 2.1 *)
let test_2_2 () = check_some "noon" (ftime en "12:00")                               (* 2.2 *)
let test_2_3 () = check_some "three o'clock" (ftime en "15:00")                      (* 2.3 *)
let test_2_4 () = check_some "a quarter past two" (ftime en "14:15")                 (* 2.4 *)
let test_2_5 () = check_some "half past nine" (ftime en "09:30")                     (* 2.5 *)
let test_2_6 () = check_some "a quarter to eleven" (ftime en "10:45")                (* 2.6 *)
let test_2_7 () = check_some "five past eight" (ftime en "08:05")                    (* 2.7 *)
let test_2_8 () = check_some "five to five" (ftime en "16:55")                       (* 2.8 *)
let test_2_9 () = check_some "midnight" (ftime en "23:58")                           (* 2.9 rounds to 0:00 *)
let test_2_10 () = check_some "twenty past seven" (ftime en "07:22")                 (* 2.10 22 rounds to 20 *)
let test_2_11 () = check_some "a quarter past two" (ftime en "2025-01-15T14:15:00")  (* 2.11 ISO datetime *)

(* 3. Clock time (short compactness) *)
let test_3_1 () = check_some "2:15 PM" (ftime_s en Types.Short "14:15")              (* 3.1 *)
let test_3_2 () = check_some "9:30 AM" (ftime_s en Types.Short "09:30")              (* 3.2 *)
let test_3_3 () = check_some "12:00 AM" (ftime_s en Types.Short "00:00")             (* 3.3 *)
let test_3_4 () = check_some "12:00 PM" (ftime_s en Types.Short "12:00")             (* 3.4 *)

(* 4. Clock time (compact) *)
let test_4_1 () = check_some "2:15p" (ftime_s en Types.Compact "14:15")              (* 4.1 *)
let test_4_2 () = check_some "9:30a" (ftime_s en Types.Compact "09:30")              (* 4.2 *)

(* 5. Locale — German *)
let test_5_1 () = check_some "halb vier" (ftime de "15:30")                          (* 5.1 *)

(* 6. Locale — French *)
let test_6_1 () = check_some "trois heures et quart" (ftime fr "15:15")              (* 6.1 *)

(* 7. Locale — Japanese *)
let test_7_1 () = check_some "\xe4\xb8\x89\xe6\x99\x82\xe5\x8d\x8a" (ftime ja "15:30") (* 7.1 *)

let () =
  Alcotest.run "sayable-time"
    [ ( "1. Null / edge cases"
      , [ Alcotest.test_case "1.1 null time" `Quick test_1_1
        ; Alcotest.test_case "1.2 empty string" `Quick test_1_2
        ; Alcotest.test_case "1.3 invalid" `Quick test_1_3
        ; Alcotest.test_case "1.4 out of range" `Quick test_1_4
        ] )
    ; ( "2. Clock time normal"
      , [ Alcotest.test_case "2.1 midnight" `Quick test_2_1
        ; Alcotest.test_case "2.2 noon" `Quick test_2_2
        ; Alcotest.test_case "2.3 three o'clock" `Quick test_2_3
        ; Alcotest.test_case "2.4 quarter past two" `Quick test_2_4
        ; Alcotest.test_case "2.5 half past nine" `Quick test_2_5
        ; Alcotest.test_case "2.6 quarter to eleven" `Quick test_2_6
        ; Alcotest.test_case "2.7 five past eight" `Quick test_2_7
        ; Alcotest.test_case "2.8 five to five" `Quick test_2_8
        ; Alcotest.test_case "2.9 rounds to midnight" `Quick test_2_9
        ; Alcotest.test_case "2.10 22 rounds to 20" `Quick test_2_10
        ; Alcotest.test_case "2.11 ISO datetime" `Quick test_2_11
        ] )
    ; ( "3. Clock time short"
      , [ Alcotest.test_case "3.1 2:15 PM" `Quick test_3_1
        ; Alcotest.test_case "3.2 9:30 AM" `Quick test_3_2
        ; Alcotest.test_case "3.3 12:00 AM" `Quick test_3_3
        ; Alcotest.test_case "3.4 12:00 PM" `Quick test_3_4
        ] )
    ; ( "4. Clock time compact"
      , [ Alcotest.test_case "4.1 2:15p" `Quick test_4_1
        ; Alcotest.test_case "4.2 9:30a" `Quick test_4_2
        ] )
    ; ( "5. Locale German"
      , [ Alcotest.test_case "5.1 halb vier" `Quick test_5_1
        ] )
    ; ( "6. Locale French"
      , [ Alcotest.test_case "6.1 trois heures et quart" `Quick test_6_1
        ] )
    ; ( "7. Locale Japanese"
      , [ Alcotest.test_case "7.1 san ji han" `Quick test_7_1
        ] )
    ]

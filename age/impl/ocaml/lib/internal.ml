let is_digit c = c >= '0' && c <= '9'

let is_leap_year y =
  (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0

let days_in_month y m =
  match m with
  | 1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
  | 4 | 6 | 9 | 11 -> 30
  | 2 -> if is_leap_year y then 29 else 28
  | _ -> 30

(* Exactly YYYY-MM-DD naming a real calendar day. *)
let parse_date s =
  if String.length s <> 10 then None
  else if s.[4] <> '-' || s.[7] <> '-' then None
  else
    let y_str = String.sub s 0 4 in
    let m_str = String.sub s 5 2 in
    let d_str = String.sub s 8 2 in
    let all_digits str =
      let ok = ref true in
      String.iter (fun c -> if not (is_digit c) then ok := false) str;
      !ok
    in
    if not (all_digits y_str && all_digits m_str && all_digits d_str) then None
    else
      let y = int_of_string y_str in
      let m = int_of_string m_str in
      let d = int_of_string d_str in
      if m < 1 || m > 12 || d < 1 || d > days_in_month y m then None
      else Some (y, m, d)

let to_jdn y m d =
  let a = (14 - m) / 12 in
  let yy = y + 4800 - a in
  let mm = m + 12 * a - 3 in
  d + (153 * mm + 2) / 5 + 365 * yy + yy / 4 - yy / 100 + yy / 400 - 32045

let days_between (y1, m1, d1) (y2, m2, d2) =
  to_jdn y2 m2 d2 - to_jdn y1 m1 d1

let compute_age dob as_of =
  match parse_date dob, parse_date as_of with
  | Some (dy, dm, dd), Some (ry, rm, rd) ->
    let diff_days = days_between (dy, dm, dd) (ry, rm, rd) in
    if diff_days < 0 then None
    else
      let last_day = days_in_month ry rm in
      let clamped_birthday = min dd last_day in
      let months0 = (ry - dy) * 12 + (rm - dm) in
      let months = if rd < clamped_birthday then months0 - 1 else months0 in
      if months > 6000 then None
      else Some (months, diff_days)
  | _ -> None

let today () =
  let t = Unix.gettimeofday () in
  let tm = Unix.gmtime t in
  (tm.Unix.tm_year + 1900, tm.Unix.tm_mon + 1, tm.Unix.tm_mday)

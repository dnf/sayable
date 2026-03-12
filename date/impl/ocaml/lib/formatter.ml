open Types

let version = "0.5.0"

let string_replace ~needle ~replacement haystack =
  let nlen = String.length needle in
  if nlen = 0 then haystack
  else
    let buf = Buffer.create (String.length haystack) in
    let hlen = String.length haystack in
    let i = ref 0 in
    while !i <= hlen - nlen do
      if String.sub haystack !i nlen = needle then begin
        Buffer.add_string buf replacement;
        i := !i + nlen
      end else begin
        Buffer.add_char buf haystack.[!i];
        i := !i + 1
      end
    done;
    while !i < hlen do
      Buffer.add_char buf haystack.[!i];
      i := !i + 1
    done;
    Buffer.contents buf

let string_contains ~needle haystack =
  let nlen = String.length needle in
  let hlen = String.length haystack in
  if nlen = 0 then true
  else if nlen > hlen then false
  else
    let found = ref false in
    let i = ref 0 in
    while !i <= hlen - nlen && not !found do
      if String.sub haystack !i nlen = needle then found := true
      else i := !i + 1
    done;
    !found

let is_digit c = c >= '0' && c <= '9'

let parse_date s =
  if String.length s = 0 then None
  else
    let date_part =
      if string_contains ~needle:"T" s then
        let idx = String.index s 'T' in
        String.sub s 0 idx
      else s
    in
    if String.length date_part < 10 then None
    else if date_part.[4] <> '-' || date_part.[7] <> '-' then None
    else
      let y_str = String.sub date_part 0 4 in
      let m_str = String.sub date_part 5 2 in
      let d_str = String.sub date_part 8 2 in
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
        if m < 1 || m > 12 || d < 1 || d > 31 then None
        else Some (y, m, d)

let to_jdn y m d =
  let a = (14 - m) / 12 in
  let yy = y + 4800 - a in
  let mm = m + 12 * a - 3 in
  d + (153 * mm + 2) / 5 + 365 * yy + yy / 4 - yy / 100 + yy / 400 - 32045

let weekday y m d =
  let jdn = to_jdn y m d in
  (jdn + 1) mod 7

let nth_list n lst =
  let rec aux i = function
    | [] -> ""
    | x :: rest -> if i = n then x else aux (i + 1) rest
  in
  aux 0 lst

let assoc_opt_str key lst =
  let rec aux = function
    | [] -> None
    | (k, v) :: rest -> if k = key then Some v else aux rest
  in
  aux lst

let pick_opt opt default =
  match opt with
  | Some v -> v
  | None -> default

let pick_opt_str opt default =
  match opt with
  | Some v -> v
  | None -> default

type resolved_locale =
  { r_months : string list
  ; r_months_in_date : string list option
  ; r_weekdays : string list
  ; r_day_format : string
  ; r_day_format_exceptions : (string * string) list
  ; r_date_pattern : string
  ; r_date_pattern_with_year : string
  ; r_today : string
  ; r_tomorrow : string
  ; r_yesterday : string
  }

let resolve_locale loc compactness =
  let m_ovr =
    match compactness with
    | Normal -> None
    | Short -> loc.short
    | Compact -> loc.compact
  in
  match m_ovr with
  | None ->
    { r_months = loc.months
    ; r_months_in_date = loc.months_in_date
    ; r_weekdays = loc.weekdays
    ; r_day_format = loc.day_format
    ; r_day_format_exceptions = loc.day_format_exceptions
    ; r_date_pattern = loc.date_pattern
    ; r_date_pattern_with_year = loc.date_pattern_with_year
    ; r_today = loc.today
    ; r_tomorrow = loc.tomorrow
    ; r_yesterday = loc.yesterday
    }
  | Some ovr ->
    let day_fmt = pick_opt_str ovr.ovr_day_format loc.day_format in
    let day_exc =
      match ovr.ovr_day_format, ovr.ovr_day_format_exceptions with
      | Some _, None -> []
      | _, Some exc -> exc
      | _, None -> loc.day_format_exceptions
    in
    { r_months = pick_opt ovr.ovr_months loc.months
    ; r_months_in_date =
        (match ovr.ovr_months_in_date with
         | Some _ as v -> v
         | None -> loc.months_in_date)
    ; r_weekdays = pick_opt ovr.ovr_weekdays loc.weekdays
    ; r_day_format = day_fmt
    ; r_day_format_exceptions = day_exc
    ; r_date_pattern = pick_opt_str ovr.ovr_date_pattern loc.date_pattern
    ; r_date_pattern_with_year = pick_opt_str ovr.ovr_date_pattern_with_year loc.date_pattern_with_year
    ; r_today = pick_opt_str ovr.ovr_today loc.today
    ; r_tomorrow = pick_opt_str ovr.ovr_tomorrow loc.tomorrow
    ; r_yesterday = pick_opt_str ovr.ovr_yesterday loc.yesterday
    }

let format_absolute rl year month day include_year =
  let day_str = string_of_int day in
  let fmt =
    match assoc_opt_str day_str rl.r_day_format_exceptions with
    | Some f -> f
    | None -> rl.r_day_format
  in
  let formatted_day = string_replace ~needle:"{n}" ~replacement:day_str fmt in
  let month_names =
    match rl.r_months_in_date with
    | Some mid -> mid
    | None -> rl.r_months
  in
  let month_name = nth_list (month - 1) month_names in
  let pattern =
    if include_year then rl.r_date_pattern_with_year
    else rl.r_date_pattern
  in
  let result = string_replace ~needle:"{month}" ~replacement:month_name pattern in
  let result = string_replace ~needle:"{day}" ~replacement:formatted_day result in
  let result = string_replace ~needle:"{d}" ~replacement:(string_of_int day) result in
  let result = string_replace ~needle:"{m}" ~replacement:(string_of_int month) result in
  if include_year then
    let result = string_replace ~needle:"{year}" ~replacement:(string_of_int year) result in
    let yy = Printf.sprintf "%02d" (year mod 100) in
    string_replace ~needle:"{yy}" ~replacement:yy result
  else result

let format_date loc compactness date =
  if date = "" then None
  else
    match parse_date date with
    | None -> None
    | Some (y, m, d) ->
      let rl = resolve_locale loc compactness in
      Some (format_absolute rl y m d false)

let format_date_with_year loc compactness date =
  if date = "" then None
  else
    match parse_date date with
    | None -> None
    | Some (y, m, d) ->
      let rl = resolve_locale loc compactness in
      Some (format_absolute rl y m d true)

let format_relative loc compactness date as_of =
  if date = "" || as_of = "" then None
  else
    match parse_date date, parse_date as_of with
    | Some (dy, dm, dd), Some (ay, am, ad) ->
      let date_jdn = to_jdn dy dm dd in
      let asof_jdn = to_jdn ay am ad in
      let diff = date_jdn - asof_jdn in
      let rl = resolve_locale loc compactness in
      if diff = 0 then Some rl.r_today
      else if diff = 1 then Some rl.r_tomorrow
      else if diff = -1 then Some rl.r_yesterday
      else begin
        let is_compact = compactness = Compact in
        if diff = 2 && loc.day_after_tomorrow <> None && not is_compact then
          loc.day_after_tomorrow
        else if diff = -2 && loc.day_before_yesterday <> None && not is_compact then
          loc.day_before_yesterday
        else if is_compact then
          let include_year = dy <> ay in
          Some (format_absolute rl dy dm dd include_year)
        else if diff >= 2 && diff <= 6 && loc.this_weekday <> None then
          let dow = weekday dy dm dd in
          let weekday_name = nth_list dow rl.r_weekdays in
          let pattern = match loc.this_weekday with Some p -> p | None -> "" in
          Some (string_replace ~needle:"{weekday}" ~replacement:weekday_name pattern)
        else if diff >= -6 && diff <= -2 && loc.last_weekday <> None then
          let dow = weekday dy dm dd in
          let weekday_name = nth_list dow rl.r_weekdays in
          let pattern = match loc.last_weekday with Some p -> p | None -> "" in
          Some (string_replace ~needle:"{weekday}" ~replacement:weekday_name pattern)
        else if diff >= 7 && diff <= 13 && loc.next_weekday <> None then
          let dow = weekday dy dm dd in
          let weekday_name = nth_list dow rl.r_weekdays in
          let pattern = match loc.next_weekday with Some p -> p | None -> "" in
          Some (string_replace ~needle:"{weekday}" ~replacement:weekday_name pattern)
        else
          let include_year = dy <> ay in
          Some (format_absolute rl dy dm dd include_year)
      end
    | _ -> None

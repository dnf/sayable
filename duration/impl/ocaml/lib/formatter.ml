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

let resolve_unit count uf loc half =
  let base_n = string_of_int count in
  let n =
    if half <> "" && string_contains ~needle:"{n}" half then
      string_replace ~needle:"{n}" ~replacement:base_n half
    else base_n
  in
  let template =
    match uf with
    | Simple s -> s
    | Pluralized forms ->
      let cat = if half <> "" then Other else loc.plural count in
      lookup_unit_form cat forms
  in
  let result = string_replace ~needle:"{n}" ~replacement:n template in
  if half <> "" && string_contains ~needle:"{0}" half then
    string_replace ~needle:"{0}" ~replacement:result half
  else result

let is_leap_year y =
  (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0

let days_in_month y m =
  match m with
  | 1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
  | 4 | 6 | 9 | 11 -> 30
  | 2 -> if is_leap_year y then 29 else 28
  | _ -> 30

let days_since_epoch year month day =
  let days = ref 0 in
  if year >= 2000 then
    for y = 2000 to year - 1 do
      days := !days + (if is_leap_year y then 366 else 365)
    done
  else
    for y = year to 1999 do
      days := !days - (if is_leap_year y then 366 else 365)
    done;
  for m = 1 to month - 1 do
    days := !days + days_in_month year m
  done;
  !days + day - 1

let strip_tz s =
  let s =
    if string_contains ~needle:"+" s then
      let idx = String.index s '+' in
      String.sub s 0 idx
    else s
  in
  if string_contains ~needle:"Z" s then
    let idx = String.index s 'Z' in
    String.sub s 0 idx
  else s

let parse_iso_to_seconds iso_str =
  if String.length iso_str = 0 then None
  else
    try
      let t_idx = String.index iso_str 'T' in
      let date_part = String.sub iso_str 0 t_idx in
      let time_part = String.sub iso_str (t_idx + 1) (String.length iso_str - t_idx - 1) in
      let dp = String.split_on_char '-' date_part in
      let year, month, day =
        match dp with
        | [y; m; d] -> (int_of_string y, int_of_string m, int_of_string d)
        | _ -> raise (Failure "bad date")
      in
      let time_str = strip_tz time_part in
      let tp = String.split_on_char ':' time_str in
      let hour = match tp with h :: _ -> int_of_string h | [] -> 0 in
      let minute = match tp with _ :: m :: _ -> int_of_string m | _ -> 0 in
      let second = match tp with _ :: _ :: s :: _ ->
        let s = if string_contains ~needle:"." s then
          let idx = String.index s '.' in String.sub s 0 idx
        else s in
        int_of_string s | _ -> 0 in
      let days = days_since_epoch year month day in
      Some (days * 86400 + hour * 3600 + minute * 60 + second)
    with _ -> None

let resolve_locale loc compactness =
  let m_ovr =
    match compactness with
    | Normal -> None
    | Short -> loc.short
    | Compact -> loc.compact
  in
  match m_ovr with
  | None ->
    ( loc.second, loc.minute, loc.hour, loc.day, loc.week, loc.month, loc.year
    , loc.half, loc.delimiter, loc.just_now, loc.ago, loc.in_future )
  | Some ovr ->
    let pick_uf opt default = match opt with Some v -> v | None -> default in
    let pick_s opt default = match opt with Some v -> v | None -> default in
    ( pick_uf ovr.ovr_second loc.second
    , pick_uf ovr.ovr_minute loc.minute
    , pick_uf ovr.ovr_hour loc.hour
    , pick_uf ovr.ovr_day loc.day
    , pick_uf ovr.ovr_week loc.week
    , pick_uf ovr.ovr_month loc.month
    , pick_uf ovr.ovr_year loc.year
    , pick_s ovr.ovr_half loc.half
    , pick_s ovr.ovr_delimiter loc.delimiter
    , loc.just_now
    , pick_s ovr.ovr_ago loc.ago
    , pick_s ovr.ovr_in_future loc.in_future
    )

let format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now total =
  if total = 0 then just_now
  else if total < 60 then
    resolve_unit total second' loc ""
  else
    let total_minutes = total / 60 in
    let remainder_seconds = total mod 60 in
    if total_minutes < 5 then
      let result = resolve_unit total_minutes minute' loc "" in
      if remainder_seconds > 0 then
        result ^ delim ^ resolve_unit remainder_seconds second' loc ""
      else result
    else if total_minutes < 60 then
      resolve_unit total_minutes minute' loc ""
    else
      let total_hours = total / 3600 in
      let remainder_minutes = (total mod 3600) / 60 in
      if total_hours <= 5 then begin
        if remainder_minutes = 30 then
          resolve_unit total_hours hour' loc half'
        else
          let result = resolve_unit total_hours hour' loc "" in
          if remainder_minutes > 0 then
            result ^ delim ^ resolve_unit remainder_minutes minute' loc ""
          else result
      end else if total_hours < 24 then
        resolve_unit total_hours hour' loc ""
      else
        let total_days = total / 86400 in
        let remainder_hours = (total mod 86400) / 3600 in
        if total_days <= 2 then begin
          if remainder_hours = 12 then
            resolve_unit total_days day' loc half'
          else
            let result = resolve_unit total_days day' loc "" in
            if remainder_hours > 0 then
              result ^ delim ^ resolve_unit remainder_hours hour' loc ""
            else result
        end else if total_days < 7 then
          resolve_unit total_days day' loc ""
        else
          let total_weeks = total_days / 7 in
          let remainder_days = total_days mod 7 in
          if total_days < 30 then begin
            let result = resolve_unit total_weeks week' loc "" in
            if remainder_days > 0 then
              result ^ delim ^ resolve_unit remainder_days day' loc ""
            else result
          end else
            let total_months = int_of_float (Float.round (float_of_int total_days /. 30.44)) in
            let total_months = if total_months = 0 then 1 else total_months in
            if total_months < 12 then
              resolve_unit total_months month' loc ""
            else
              let total_years = total_months / 12 in
              let remainder_months = total_months mod 12 in
              let result = resolve_unit total_years year' loc "" in
              if remainder_months > 0 then
                result ^ delim ^ resolve_unit remainder_months month' loc ""
              else result

let format_duration loc compactness start_or_seconds end_iso =
  match start_or_seconds with
  | `Null -> None
  | `Seconds total_seconds ->
    if total_seconds < 0 then None
    else
      let (second', minute', hour', day', week', month', year', half', delim, just_now, _ago, _in_future) =
        resolve_locale loc compactness
      in
      Some (format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now total_seconds)
  | `Iso start_iso ->
    match end_iso with
    | None -> None
    | Some end_s ->
      match parse_iso_to_seconds start_iso, parse_iso_to_seconds end_s with
      | Some s, Some e ->
        let total_seconds = abs (e - s) in
        let (second', minute', hour', day', week', month', year', half', delim, just_now, _ago, _in_future) =
          resolve_locale loc compactness
        in
        Some (format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now total_seconds)
      | _ -> None

let format_since loc compactness start as_of =
  if start = "" || as_of = "" then None
  else
    match parse_iso_to_seconds start, parse_iso_to_seconds as_of with
    | Some s, Some a ->
      let diff = a - s in
      if diff < 0 then None
      else if diff = 0 then
        let (_, _, _, _, _, _, _, _, _, just_now, _, _) = resolve_locale loc compactness in
        Some just_now
      else
        let (second', minute', hour', day', week', month', year', half', delim, just_now, ago, _) =
          resolve_locale loc compactness
        in
        let dur = format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now diff in
        Some (string_replace ~needle:"{0}" ~replacement:dur ago)
    | _ -> None

let format_until loc compactness target as_of =
  if target = "" || as_of = "" then None
  else
    match parse_iso_to_seconds target, parse_iso_to_seconds as_of with
    | Some t, Some a ->
      let diff = t - a in
      if diff < 0 then None
      else if diff = 0 then
        let (_, _, _, _, _, _, _, _, _, just_now, _, _) = resolve_locale loc compactness in
        Some just_now
      else
        let (second', minute', hour', day', week', month', year', half', delim, just_now, _, in_future) =
          resolve_locale loc compactness
        in
        let dur = format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now diff in
        Some (string_replace ~needle:"{0}" ~replacement:dur in_future)
    | _ -> None

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

let is_digit c = c >= '0' && c <= '9'

(* The value of the digits in s.[pos .. pos + len - 1], or None if any
   position is out of range or not a digit. *)
let digits_value s pos len =
  if pos < 0 || len <= 0 || pos + len > String.length s then None
  else begin
    let value = ref 0 in
    let ok = ref true in
    for i = pos to pos + len - 1 do
      if is_digit s.[i] then value := !value * 10 + (Char.code s.[i] - Char.code '0')
      else ok := false
    done;
    if !ok then Some !value else None
  end

(* Z or +HH:MM / -HH:MM (validated, never applied). *)
let is_zone_suffix s =
  s = "Z"
  || (String.length s = 6 && (s.[0] = '+' || s.[0] = '-')
      && digits_value s 1 2 <> None && s.[3] = ':' && digits_value s 4 2 <> None)

(* H:MM or HH:MM, then optional :SS with optional .fraction, then an
   optional zone suffix. *)
let parse_clock s =
  let len = String.length s in
  let hour_digits = if len > 1 && is_digit s.[0] && is_digit s.[1] then 2 else 1 in
  match digits_value s 0 hour_digits, digits_value s (hour_digits + 1) 2 with
  | Some hour, Some minute when s.[hour_digits] = ':' ->
    let pos = ref (hour_digits + 3) in
    let second = ref 0 in
    (if !pos < len && s.[!pos] = ':' then
       match digits_value s (!pos + 1) 2 with
       | Some sec ->
         second := sec;
         pos := !pos + 3;
         if !pos + 1 < len && s.[!pos] = '.' && is_digit s.[!pos + 1] then begin
           incr pos;
           while !pos < len && is_digit s.[!pos] do incr pos done
         end
       | None -> ());
    let zone = String.sub s !pos (len - !pos) in
    if (zone = "" || is_zone_suffix zone) && hour <= 23 && minute <= 59 && !second <= 59
    then Some (hour, minute, !second)
    else None
  | _ -> None

(* YYYY-MM-DDTHH:MM (one- or two-digit hour), then optional :SS with
   optional .fraction, then an optional zone suffix that is ignored. *)
let parse_iso_to_seconds iso_str =
  let len = String.length iso_str in
  if len < 11 || iso_str.[4] <> '-' || iso_str.[7] <> '-' || iso_str.[10] <> 'T' then None
  else
    match digits_value iso_str 0 4, digits_value iso_str 5 2, digits_value iso_str 8 2 with
    | Some year, Some month, Some day when month >= 1 && month <= 12 && day >= 1 && day <= days_in_month year month ->
      (match parse_clock (String.sub iso_str 11 (len - 11)) with
       | Some (hour, minute, second) ->
         Some (days_since_epoch year month day * 86400 + hour * 3600 + minute * 60 + second)
       | None -> None)
    | _ -> None

(* 500 years, the same ceiling as sayable-age *)
let max_duration_months = 6000

(* Months of 30.44 days (the average month), rounded. *)
let approximate_months days = int_of_float (Float.round (float_of_int days /. 30.44))

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

let format_tiers loc second' minute' hour' day' week' month' year' half' delim just_now total =
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
            let total_months = approximate_months total_days in
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

(* The formatted duration, or None beyond the 500-year ceiling. *)
let format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now total =
  if approximate_months (total / 86400) > max_duration_months then None
  else Some (format_tiers loc second' minute' hour' day' week' month' year' half' delim just_now total)

let format_duration loc compactness start_or_seconds end_iso =
  match start_or_seconds with
  | `Null -> None
  | `Seconds total_seconds ->
    if total_seconds < 0 then None
    else
      let (second', minute', hour', day', week', month', year', half', delim, just_now, _ago, _in_future) =
        resolve_locale loc compactness
      in
      format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now total_seconds
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
        format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now total_seconds
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
        format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now diff
        |> Option.map (fun dur -> string_replace ~needle:"{0}" ~replacement:dur ago)
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
        format_duration_seconds loc second' minute' hour' day' week' month' year' half' delim just_now diff
        |> Option.map (fun dur -> string_replace ~needle:"{0}" ~replacement:dur in_future)
    | _ -> None

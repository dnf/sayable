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

let nth_list n lst =
  let rec aux i = function
    | [] -> ""
    | x :: rest -> if i = n then x else aux (i + 1) rest
  in
  aux 0 lst

let assoc_opt_int key lst =
  let rec aux = function
    | [] -> None
    | (k, v) :: rest -> if k = key then Some v else aux rest
  in
  aux lst

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

let days_in_month y m =
  match m with
  | 4 | 6 | 9 | 11 -> 30
  | 2 -> if (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0 then 29 else 28
  | _ -> 31

(* YYYY-MM-DD naming a real calendar day. *)
let is_real_date s =
  String.length s = 10 && s.[4] = '-' && s.[7] = '-'
  && (match digits_value s 0 4, digits_value s 5 2, digits_value s 8 2 with
      | Some y, Some m, Some d -> m >= 1 && m <= 12 && d >= 1 && d <= days_in_month y m
      | _ -> false)

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
    then Some (hour, minute)
    else None
  | _ -> None

(* A clock time alone, or after the T of an ISO datetime whose date part
   is a real calendar day. *)
let parse_time input =
  match String.index_opt input 'T' with
  | None -> parse_clock input
  | Some idx ->
    if is_real_date (String.sub input 0 idx)
    then parse_clock (String.sub input (idx + 1) (String.length input - idx - 1))
    else None

let round_to_5 minute =
  ((minute + 2) / 5) * 5

let format_natural clock hour minute =
  let rounded = round_to_5 minute in
  let h = hour in
  let rounded, h =
    if rounded = 60 then (0, (h + 1) mod 24)
    else (rounded, h)
  in
  if rounded = 0 then begin
    if h = 0 then clock.midnight
    else if h = 12 then clock.noon
    else
      let h12 = h mod 12 in
      let h_name = nth_list h12 clock.hours in
      let pattern = match assoc_opt_int 0 clock.patterns with
        | Some p -> p
        | None -> "{h}"
      in
      string_replace ~needle:"{h}" ~replacement:h_name pattern
  end else begin
    let h12 = h mod 12 in
    let next_h12 = (h + 1) mod 12 in
    let h_name = nth_list h12 clock.hours in
    let next_h_name = nth_list next_h12 clock.hours in
    let pattern = match assoc_opt_int rounded clock.patterns with
      | Some p -> p
      | None -> (match assoc_opt_int 0 clock.patterns with
        | Some p -> p
        | None -> "{h}")
    in
    let result = string_replace ~needle:"{h}" ~replacement:h_name pattern in
    string_replace ~needle:"{next_h}" ~replacement:next_h_name result
  end

let format_digital sc hour minute =
  let fmt = sc.format in
  if sc.use_24h then
    let result = string_replace ~needle:"{h}" ~replacement:(string_of_int hour) fmt in
    string_replace ~needle:"{mm}" ~replacement:(Printf.sprintf "%02d" minute) result
  else
    let h12 = hour mod 12 in
    let h12 = if h12 = 0 then 12 else h12 in
    let am_pm = match sc.am_pm with
      | Some (a, p) -> (a, p)
      | None -> ("AM", "PM")
    in
    let ampm_str = if hour < 12 then fst am_pm else snd am_pm in
    let result = string_replace ~needle:"{h}" ~replacement:(string_of_int h12) fmt in
    let result = string_replace ~needle:"{mm}" ~replacement:(Printf.sprintf "%02d" minute) result in
    string_replace ~needle:"{ampm}" ~replacement:ampm_str result

let format_time loc compactness input =
  if input = "" then None
  else
    match parse_time input with
    | None -> None
    | Some (hour, minute) ->
      let ovr =
        match compactness with
        | Normal -> None
        | Short -> loc.short
        | Compact -> loc.compact
      in
      let short_clock =
        match ovr with
        | Some o -> o.clock
        | None -> None
      in
      if compactness <> Normal && short_clock <> None then
        let sc = match short_clock with Some c -> c | None -> assert false in
        Some (format_digital sc hour minute)
      else
        Some (format_natural loc.clock hour minute)

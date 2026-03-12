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

let strip_tz s =
  let s = if string_contains ~needle:"+" s then
    let idx = String.index s '+' in
    String.sub s 0 idx
  else s in
  if string_contains ~needle:"Z" s then
    let idx = String.index s 'Z' in
    String.sub s 0 idx
  else s

let parse_time input =
  if String.length input = 0 then None
  else
    let t =
      if string_contains ~needle:"T" input then
        let idx = String.index input 'T' in
        String.sub input (idx + 1) (String.length input - idx - 1)
      else input
    in
    let t = strip_tz t in
    let parts = String.split_on_char ':' t in
    match parts with
    | h_str :: m_str :: _ ->
      let m_str =
        if string_contains ~needle:"." m_str then
          let idx = String.index m_str '.' in
          String.sub m_str 0 idx
        else m_str
      in
      (try
         let hour = int_of_string h_str in
         let minute = int_of_string m_str in
         if hour < 0 || hour > 23 || minute < 0 || minute > 59 then None
         else Some (hour, minute)
       with Failure _ -> None)
    | _ -> None

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

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
    | Pluralized forms -> lookup_unit_form (loc.plural count) forms
  in
  let result = string_replace ~needle:"{n}" ~replacement:n template in
  if half <> "" && string_contains ~needle:"{0}" half then
    string_replace ~needle:"{0}" ~replacement:result half
  else result

let stage_key months =
  if months < 2 then "newborn"
  else if months < 12 then "infant"
  else if months < 36 then "toddler"
  else if months < 156 then "child"
  else if months < 216 then "teenager"
  else "adult"

let resolve_locale loc compactness =
  let m_ovr =
    match compactness with
    | Normal -> None
    | Short -> loc.short
    | Compact -> loc.compact
  in
  match m_ovr with
  | None ->
    (loc.day, loc.week, loc.month, loc.year, loc.half, loc.delimiter, loc.just_born)
  | Some ovr ->
    let pick opt default = match opt with Some v -> v | None -> default in
    ( pick ovr.ovr_day loc.day
    , pick ovr.ovr_week loc.week
    , pick ovr.ovr_month loc.month
    , pick ovr.ovr_year loc.year
    , pick ovr.ovr_half loc.half
    , pick ovr.ovr_delimiter loc.delimiter
    , pick ovr.ovr_just_born loc.just_born
    )

let format_tier loc day' week' month' year' half' delim just_born months diff_days =
  if diff_days = 0 then just_born
  else if diff_days < 7 then resolve_unit diff_days day' loc ""
  else if months < 3 then
    let weeks = diff_days / 7 in
    let days = diff_days mod 7 in
    let w_str = resolve_unit weeks week' loc "" in
    if days > 0 then w_str ^ delim ^ resolve_unit days day' loc ""
    else w_str
  else if months < 24 then resolve_unit months month' loc ""
  else if months < 36 then
    let years = months / 12 in
    let rem = months mod 12 in
    let y_str = resolve_unit years year' loc "" in
    if rem = 0 then y_str
    else y_str ^ delim ^ resolve_unit rem month' loc ""
  else if months < 84 then
    let years = months / 12 in
    let rem = months mod 12 in
    if rem >= 6 then resolve_unit years year' loc half'
    else resolve_unit years year' loc ""
  else
    let years = months / 12 in
    resolve_unit years year' loc ""

let format_age_pure loc compactness dob as_of =
  if dob = "" then None
  else
    match Internal.compute_age dob as_of with
    | None -> None
    | Some (months, diff_days) ->
      if months > 6000 then None
      else
        let (day', week', month', year', half', delim, just_born) =
          resolve_locale loc compactness
        in
        Some (format_tier loc day' week' month' year' half' delim just_born months diff_days)

let format_stage_pure loc dob as_of gender =
  if dob = "" then None
  else
    match Internal.compute_age dob as_of with
    | None -> None
    | Some (months, _) ->
      let stages' = loc.stages in
      let label =
        match stage_key months with
        | "newborn" -> stages'.newborn
        | "infant" -> stages'.infant
        | "toddler" -> stages'.toddler
        | "child" -> stages'.child
        | "teenager" -> stages'.teenager
        | "adult" -> stages'.adult
        | _ -> stages'.newborn
      in
      Some (resolve_stage_label label gender)

let show_date y m d =
  Printf.sprintf "%04d-%02d-%02d" y m d

let format_age loc compactness dob as_of =
  let as_of' =
    match as_of with
    | Some s when s <> "" -> s
    | _ ->
      let (y, m, d) = Internal.today () in
      show_date y m d
  in
  format_age_pure loc compactness dob as_of'

let format_stage loc dob as_of gender =
  let as_of' =
    match as_of with
    | Some s when s <> "" -> s
    | _ ->
      let (y, m, d) = Internal.today () in
      show_date y m d
  in
  format_stage_pure loc dob as_of' gender

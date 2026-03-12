type plural_category = Zero | One | Two | Few | Many | Other

type unit_forms = Simple of string | Pluralized of (plural_category * string) list

type compactness = Normal | Short | Compact

type compactness_override =
  { ovr_second : unit_forms option
  ; ovr_minute : unit_forms option
  ; ovr_hour : unit_forms option
  ; ovr_day : unit_forms option
  ; ovr_week : unit_forms option
  ; ovr_month : unit_forms option
  ; ovr_year : unit_forms option
  ; ovr_half : string option
  ; ovr_delimiter : string option
  ; ovr_ago : string option
  ; ovr_in_future : string option
  }

type duration_locale =
  { code : string
  ; plural : int -> plural_category
  ; second : unit_forms
  ; minute : unit_forms
  ; hour : unit_forms
  ; day : unit_forms
  ; week : unit_forms
  ; month : unit_forms
  ; year : unit_forms
  ; half : string
  ; delimiter : string
  ; just_now : string
  ; ago : string
  ; in_future : string
  ; short : compactness_override option
  ; compact : compactness_override option
  }

let lookup_unit_form cat forms =
  match List.assoc_opt cat forms with
  | Some s -> s
  | None ->
    (match List.assoc_opt Other forms with
     | Some s -> s
     | None -> "")

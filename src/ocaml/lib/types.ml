type plural_category = Zero | One | Two | Few | Many | Other

type unit_forms = Simple of string | Pluralized of (plural_category * string) list

type compactness = Normal | Short | Compact

type gender = M | F

type stage_label = Neutral of string | Gendered of string * string

type stages =
  { newborn : stage_label
  ; infant : stage_label
  ; toddler : stage_label
  ; child : stage_label
  ; teenager : stage_label
  ; adult : stage_label
  }

type compactness_override =
  { ovr_day : unit_forms option
  ; ovr_week : unit_forms option
  ; ovr_month : unit_forms option
  ; ovr_year : unit_forms option
  ; ovr_half : string option
  ; ovr_delimiter : string option
  ; ovr_just_born : string option
  }

type locale =
  { code : string
  ; plural : int -> plural_category
  ; day : unit_forms
  ; week : unit_forms
  ; month : unit_forms
  ; year : unit_forms
  ; half : string
  ; delimiter : string
  ; just_born : string
  ; stages : stages
  ; short : compactness_override option
  ; compact : compactness_override option
  }

let resolve_stage_label label gender =
  match label, gender with
  | Neutral s, _ -> s
  | Gendered (_, f), Some F -> f
  | Gendered (m, _), _ -> m

let lookup_unit_form cat forms =
  match List.assoc_opt cat forms with
  | Some s -> s
  | None ->
    (match List.assoc_opt Other forms with
     | Some s -> s
     | None -> "")

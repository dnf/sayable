let cli_version = "0.5.0"

let help_text =
  "Usage: sayable <command> [arguments] [options]\n\
   \n\
   Commands:\n\
  \  age <dob>              Format an age\n\
  \  stage <dob>            Get developmental stage\n\
  \  date <date>            Format a calendar date\n\
  \  relative <date>        Format a relative date\n\
  \  time <time>            Format a clock time\n\
  \  duration <value> [end] Format a duration\n\
  \  since <start>          Format elapsed time\n\
  \  until <target>         Format remaining time\n\
  \  locales                List available locale codes\n\
  \  version                Show version\n\
  \  help                   Show this help\n\
   \n\
   Options:\n\
  \  -l, --locale <code>    Locale code (default: en)\n\
  \  -d, --as-of <value>    Reference date/timestamp\n\
  \      --short            Short compactness\n\
  \      --compact          Compact compactness\n\
  \  -g, --gender <m|f>     Gender for stage labels\n\
  \      --with-year        Include year (date only)\n\
  \  -h, --help             Show this help\n\
  \  -v, --version          Show version"

let all_locales =
  [ "af"; "ak"; "am"; "ar"; "ay"; "az"; "bci"; "be"; "bem"; "bg"
  ; "bi"; "bm"; "bn"; "br"; "bs"; "ca"; "cak"; "ceb"; "cs"; "cy"
  ; "da"; "de"; "din"; "dje"; "dv"; "dyu"; "dz"; "ee"; "el"; "en"
  ; "es"; "et"; "eu"; "fa"; "fan"; "ff"; "fi"; "fil"; "fj"; "fon"
  ; "fr"; "ga"; "gd"; "gl"; "gn"; "gu"; "gv"; "ha"; "he"; "hi"
  ; "hmn"; "hr"; "ht"; "hu"; "hy"; "id"; "ig"; "is"; "it"; "ja"
  ; "jv"; "ka"; "kbp"; "kek"; "ki"; "kk"; "kl"; "km"; "kn"; "ko"
  ; "kpe"; "kri"; "ktu"; "ku"; "kw"; "ky"; "lb"; "lg"; "ln"; "lo"
  ; "lt"; "luo"; "lv"; "mam"; "men"; "mfe"; "mg"; "mi"; "mk"; "ml"
  ; "mn"; "mnk"; "mos"; "mr"; "ms"; "mt"; "my"; "nb"; "nd"; "ne"
  ; "ng"; "nl"; "nr"; "nso"; "nus"; "ny"; "om"; "or"; "pa"; "pis"
  ; "pl"; "pov"; "ps"; "pt"; "qu"; "quc"; "ro"; "ru"; "rw"; "sar"
  ; "sd"; "sg"; "shi"; "shn"; "si"; "sk"; "sl"; "sn"; "snk"; "so"
  ; "sq"; "sr"; "ss"; "st"; "su"; "suk"; "sv"; "sw"; "ta"; "te"
  ; "tem"; "tet"; "tg"; "th"; "ti"; "tig"; "tk"; "tn"; "tpi"; "tr"
  ; "ts"; "tum"; "tzm"; "uk"; "umb"; "ur"; "uz"; "ve"; "vi"; "vmw"
  ; "wo"; "xh"; "yao"; "yo"; "yue"; "zdj"; "zh"; "zu"
  ]

type options =
  { locale : string
  ; as_of : string option
  ; compactness : string
  ; gender : string option
  ; with_year : bool
  }

let default_options =
  { locale = "en"
  ; as_of = None
  ; compactness = "normal"
  ; gender = None
  ; with_year = false
  }

(* Raised instead of exiting so the REPL can answer usage errors and keep
   serving. *)
exception Usage_error

let usage_error msg =
  Printf.eprintf "error: %s\n" msg;
  Printf.eprintf "Run 'sayable help' for usage.\n";
  raise Usage_error

let nullify s =
  if s = "null" then None else Some s

(* One command's exit code and the line it prints to stdout, if any. *)
type outcome = { code : int; output : string option }

let print_result = function
  | None -> { code = 1; output = None }
  | Some s -> { code = 0; output = Some s }

let get_today () =
  let t = Unix.gmtime (Unix.time ()) in
  Printf.sprintf "%04d-%02d-%02d"
    (t.Unix.tm_year + 1900) (t.Unix.tm_mon + 1) t.Unix.tm_mday

let age_compactness s =
  match s with
  | "short" -> Sayable_age.Types.Short
  | "compact" -> Sayable_age.Types.Compact
  | _ -> Sayable_age.Types.Normal

let date_compactness s =
  match s with
  | "short" -> Sayable_date.Types.Short
  | "compact" -> Sayable_date.Types.Compact
  | _ -> Sayable_date.Types.Normal

let time_compactness s =
  match s with
  | "short" -> Sayable_time.Types.Short
  | "compact" -> Sayable_time.Types.Compact
  | _ -> Sayable_time.Types.Normal

let duration_compactness s =
  match s with
  | "short" -> Sayable_duration.Types.Short
  | "compact" -> Sayable_duration.Types.Compact
  | _ -> Sayable_duration.Types.Normal

let is_all_digits s =
  let len = String.length s in
  if len = 0 then false
  else
    let ok = ref true in
    for i = 0 to len - 1 do
      let c = s.[i] in
      if c < '0' || c > '9' then ok := false
    done;
    !ok

let is_integer_string s =
  if String.length s = 0 then false
  else if s.[0] = '-' then
    String.length s > 1 && is_all_digits (String.sub s 1 (String.length s - 1))
  else
    is_all_digits s

(* Digit strings beyond the native int are far past the 500-year ceiling,
   so they saturate instead of failing. *)
let parse_seconds s =
  match int_of_string_opt s with
  | Some n -> n
  | None -> if s.[0] = '-' then min_int else max_int

let parse_args argv =
  let len = Array.length argv in
  if len = 0 then (None, [], default_options)
  else
    let first = argv.(0) in
    if first = "-h" || first = "--help" || first = "help" then
      (Some "help", [], default_options)
    else if first = "-v" || first = "--version" || first = "version" then
      (Some "version", [], default_options)
    else begin
      let command = first in
      let positionals = ref [] in
      let opts = ref default_options in
      let i = ref 1 in
      let stop_opts = ref false in
      let early_command = ref None in
      while !i < len do
        let arg = argv.(!i) in
        if arg = "--" && not !stop_opts then begin
          stop_opts := true;
          incr i
        end else if not !stop_opts && String.length arg > 0 && arg.[0] = '-' then begin
          if arg = "-l" || arg = "--locale" then begin
            if !i + 1 >= len then usage_error (Printf.sprintf "'%s' requires a value" arg);
            incr i;
            opts := { !opts with locale = argv.(!i) }
          end else if arg = "-d" || arg = "--as-of" then begin
            if !i + 1 >= len then usage_error (Printf.sprintf "'%s' requires a value" arg);
            incr i;
            opts := { !opts with as_of = Some argv.(!i) }
          end else if arg = "-g" || arg = "--gender" then begin
            if !i + 1 >= len then usage_error (Printf.sprintf "'%s' requires a value" arg);
            incr i;
            opts := { !opts with gender = Some argv.(!i) }
          end else if arg = "--short" then
            opts := { !opts with compactness = "short" }
          else if arg = "--compact" then
            opts := { !opts with compactness = "compact" }
          else if arg = "--with-year" then
            opts := { !opts with with_year = true }
          else if arg = "-h" || arg = "--help" then begin
            early_command := Some "help";
            i := len
          end else if arg = "-v" || arg = "--version" then begin
            early_command := Some "version";
            i := len
          end else
            usage_error (Printf.sprintf "unknown option '%s'" arg);
          incr i
        end else begin
          positionals := arg :: !positionals;
          incr i
        end
      done;
      match !early_command with
      | Some early -> (Some early, [], default_options)
      | None -> (Some command, List.rev !positionals, !opts)
    end

let cmd_age positionals opts =
  if positionals = [] then usage_error "age requires a date-of-birth argument";
  let dob = nullify (List.hd positionals) in
  let locale_code = opts.locale in
  let locale = Sayable_age.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let as_of = match opts.as_of with
      | Some s -> nullify s
      | None -> Some (get_today ())
    in
    let dob_str = match dob with Some s -> s | None -> "" in
    let result = Sayable_age.Formatter.format_age loc
      (age_compactness opts.compactness) dob_str as_of in
    print_result result

let cmd_stage positionals opts =
  if positionals = [] then usage_error "stage requires a date-of-birth argument";
  let dob = nullify (List.hd positionals) in
  let locale_code = opts.locale in
  let locale = Sayable_age.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let as_of = match opts.as_of with
      | Some s -> nullify s
      | None -> Some (get_today ())
    in
    let dob_str = match dob with Some s -> s | None -> "" in
    let gender = match opts.gender with
      | Some "f" -> Some Sayable_age.Types.F
      | Some "m" -> Some Sayable_age.Types.M
      | _ -> None
    in
    let result = Sayable_age.Formatter.format_stage loc dob_str as_of gender in
    print_result result

let cmd_date positionals opts =
  if positionals = [] then usage_error "date requires a date argument";
  let date_val = nullify (List.hd positionals) in
  let locale_code = opts.locale in
  let locale = Sayable_date.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let date_str = match date_val with Some s -> s | None -> "" in
    let compact = date_compactness opts.compactness in
    let result =
      if opts.with_year then
        Sayable_date.Formatter.format_date_with_year loc compact date_str
      else
        Sayable_date.Formatter.format_date loc compact date_str
    in
    print_result result

let cmd_relative positionals opts =
  if positionals = [] then usage_error "relative requires a date argument";
  let date_val = nullify (List.hd positionals) in
  (match opts.as_of with
   | None -> usage_error "relative requires --as-of / -d option"
   | _ -> ());
  let as_of = match opts.as_of with
    | Some s -> (match nullify s with Some v -> v | None -> "")
    | None -> ""
  in
  let locale_code = opts.locale in
  let locale = Sayable_date.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let date_str = match date_val with Some s -> s | None -> "" in
    let compact = date_compactness opts.compactness in
    let result = Sayable_date.Formatter.format_relative loc compact date_str as_of in
    print_result result

let cmd_time positionals opts =
  if positionals = [] then usage_error "time requires a time argument";
  let time_val = nullify (List.hd positionals) in
  let locale_code = opts.locale in
  let locale = Sayable_time.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let time_str = match time_val with Some s -> s | None -> "" in
    let compact = time_compactness opts.compactness in
    let result = Sayable_time.Formatter.format_time loc compact time_str in
    print_result result

let cmd_duration positionals opts =
  if positionals = [] then usage_error "duration requires a value argument";
  let value = nullify (List.hd positionals) in
  let locale_code = opts.locale in
  let locale = Sayable_duration.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let compact = duration_compactness opts.compactness in
    let result = match value with
      | None ->
        Sayable_duration.Formatter.format_duration loc compact `Null None
      | Some s ->
        if is_integer_string s then
          Sayable_duration.Formatter.format_duration loc compact
            (`Seconds (parse_seconds s)) None
        else begin
          if List.length positionals < 2 then
            usage_error "duration with timestamps requires start and end arguments";
          let end_val = nullify (List.nth positionals 1) in
          Sayable_duration.Formatter.format_duration loc compact
            (`Iso s) end_val
        end
    in
    print_result result

let cmd_since positionals opts =
  if positionals = [] then usage_error "since requires a start timestamp argument";
  let start = nullify (List.hd positionals) in
  (match opts.as_of with
   | None -> usage_error "since requires --as-of / -d option"
   | _ -> ());
  let as_of = match opts.as_of with
    | Some s -> (match nullify s with Some v -> v | None -> "")
    | None -> ""
  in
  let locale_code = opts.locale in
  let locale = Sayable_duration.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let start_str = match start with Some s -> s | None -> "" in
    let compact = duration_compactness opts.compactness in
    let result = Sayable_duration.Formatter.format_since loc compact start_str as_of in
    print_result result

let cmd_until positionals opts =
  if positionals = [] then usage_error "until requires a target timestamp argument";
  let target = nullify (List.hd positionals) in
  (match opts.as_of with
   | None -> usage_error "until requires --as-of / -d option"
   | _ -> ());
  let as_of = match opts.as_of with
    | Some s -> (match nullify s with Some v -> v | None -> "")
    | None -> ""
  in
  let locale_code = opts.locale in
  let locale = Sayable_duration.Locales.get_locale locale_code in
  match locale with
  | None -> usage_error (Printf.sprintf "unknown locale '%s'" locale_code)
  | Some loc ->
    let target_str = match target with Some s -> s | None -> "" in
    let compact = duration_compactness opts.compactness in
    let result = Sayable_duration.Formatter.format_until loc compact target_str as_of in
    print_result result

let cmd_locales () =
  { code = 0; output = Some (String.concat "\n" all_locales) }

let run argv =
  let (command, positionals, opts) = parse_args argv in
  match command with
  | None -> { code = 2; output = Some help_text }
  | Some "help" -> { code = 0; output = Some help_text }
  | Some "version" ->
    { code = 0; output = Some (Printf.sprintf "sayable %s" cli_version) }
  | Some "locales" -> cmd_locales ()
  | Some "age" -> cmd_age positionals opts
  | Some "stage" -> cmd_stage positionals opts
  | Some "date" -> cmd_date positionals opts
  | Some "relative" -> cmd_relative positionals opts
  | Some "time" -> cmd_time positionals opts
  | Some "duration" -> cmd_duration positionals opts
  | Some "since" -> cmd_since positionals opts
  | Some "until" -> cmd_until positionals opts
  | Some cmd ->
    usage_error (Printf.sprintf "unknown command '%s'" cmd)

let run_or_usage_error argv =
  try run argv with Usage_error -> { code = 2; output = None }

let strip_carriage_return line =
  let len = String.length line in
  if len > 0 && line.[len - 1] = '\r' then String.sub line 0 (len - 1)
  else line

let response_line { code; output } =
  let text = Option.value output ~default:"" in
  Printf.sprintf "%d\t%s" code (String.concat "\t" (String.split_on_char '\n' text))

(* Answer one tab-separated request per stdin line (see cli/SPEC.md). *)
let repl () =
  let rec loop () =
    match In_channel.input_line stdin with
    | None -> ()
    | Some line ->
      let fields = String.split_on_char '\t' (strip_carriage_return line) in
      let outcome =
        try run_or_usage_error (Array.of_list fields)
        with exn ->
          (* A crash exits non-zero in one-shot mode; report it and keep serving. *)
          Printf.eprintf "error: %s\n%!" (Printexc.to_string exn);
          { code = 1; output = None }
      in
      print_string (response_line outcome);
      print_newline ();
      loop ()
  in
  loop ()

let () =
  let argv = Array.sub Sys.argv 1 (Array.length Sys.argv - 1) in
  if argv = [| "--repl" |] then repl ()
  else begin
    let { code; output } =
      try run_or_usage_error argv
      with exn ->
        (* A crash exits 1, as in the reference, not OCaml's default 2. *)
        Printf.eprintf "error: %s\n%!" (Printexc.to_string exn);
        { code = 1; output = None }
    in
    Option.iter print_endline output;
    exit code
  end

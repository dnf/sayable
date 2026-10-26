module SayableCli.Program

open System

let [<Literal>] private CliVersion = "0.5.0"

let private helpText =
    String.concat "\n" [
        "Usage: sayable <command> [arguments] [options]"
        ""
        "Commands:"
        "  age <dob>              Format an age"
        "  stage <dob>            Get developmental stage"
        "  date <date>            Format a calendar date"
        "  relative <date>        Format a relative date"
        "  time <time>            Format a clock time"
        "  duration <value> [end] Format a duration"
        "  since <start>          Format elapsed time"
        "  until <target>         Format remaining time"
        "  locales                List available locale codes"
        "  version                Show version"
        "  help                   Show this help"
        ""
        "Options:"
        "  -l, --locale <code>    Locale code (default: en)"
        "  -d, --as-of <value>    Reference date/timestamp"
        "      --short            Short compactness"
        "      --compact          Compact compactness"
        "  -g, --gender <m|f>     Gender for stage labels"
        "      --with-year        Include year (date only)"
        "  -h, --help             Show this help"
        "  -v, --version          Show version"
    ]

type private Options =
    { Locale: string
      AsOf: string option
      Compactness: string
      Gender: string option
      WithYear: bool }

let private defaultOptions =
    { Locale = "en"
      AsOf = None
      Compactness = "normal"
      Gender = None
      WithYear = false }

/// What one invocation prints to stdout (None: nothing) and the code it exits with.
type private Outcome = { ExitCode: int; Output: string option }

let private printing (output: string) = { ExitCode = 0; Output = Some output }

let private printError (msg: string) =
    eprintfn "error: %s" msg
    eprintfn "Run 'sayable help' for usage."
    { ExitCode = 2; Output = None }

let private nullify (s: string) : string option =
    if s = "null" then None else Some s

let private getToday () =
    DateTime.Today.ToString("yyyy-MM-dd")

let private isInteger (s: string) : bool =
    if String.IsNullOrEmpty(s) then
        false
    else
        let start = if s.[0] = '-' then 1 else 0
        if start >= s.Length then
            false
        else
            let mutable ok = true
            let mutable idx = start
            while ok && idx < s.Length do
                let c = s.[idx]
                if c < '0' || c > '9' then ok <- false
                else idx <- idx + 1
            ok

let private toAgeCompactness (s: string) : SayableAgeLib.Types.Compactness =
    match s with
    | "short" -> SayableAgeLib.Types.Compactness.Short
    | "compact" -> SayableAgeLib.Types.Compactness.Compact
    | _ -> SayableAgeLib.Types.Compactness.Normal

let private toDateCompactness (s: string) : SayableDateLib.Types.Compactness =
    match s with
    | "short" -> SayableDateLib.Types.Compactness.Short
    | "compact" -> SayableDateLib.Types.Compactness.Compact
    | _ -> SayableDateLib.Types.Compactness.Normal

let private toTimeCompactness (s: string) : SayableTimeLib.Types.Compactness =
    match s with
    | "short" -> SayableTimeLib.Types.Compactness.Short
    | "compact" -> SayableTimeLib.Types.Compactness.Compact
    | _ -> SayableTimeLib.Types.Compactness.Normal

let private toDurationCompactness (s: string) : SayableDurationLib.Types.Compactness =
    match s with
    | "short" -> SayableDurationLib.Types.Compactness.Short
    | "compact" -> SayableDurationLib.Types.Compactness.Compact
    | _ -> SayableDurationLib.Types.Compactness.Normal

let private printResult (result: string option) : Outcome =
    match result with
    | Some s -> printing s
    | None -> { ExitCode = 1; Output = None }

let private cmdAge (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "age requires a date-of-birth argument"
    | dobArg :: _ ->
        let dob = nullify dobArg
        match SayableAgeLib.Locales.get opts.Locale with
        | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
        | Some locale ->
            let asOf =
                match opts.AsOf with
                | Some v -> nullify v
                | None -> Some(getToday ())
            let formatter = SayableAgeLib.Formatter.SayableAgeFormatter(locale, toAgeCompactness opts.Compactness)
            printResult (formatter.FormatAge(dob, ?asOf = Some asOf))

let private cmdStage (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "stage requires a date-of-birth argument"
    | dobArg :: _ ->
        let dob = nullify dobArg
        match SayableAgeLib.Locales.get opts.Locale with
        | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
        | Some locale ->
            let asOf =
                match opts.AsOf with
                | Some v -> nullify v
                | None -> Some(getToday ())
            let gender = opts.Gender
            let formatter = SayableAgeLib.Formatter.SayableAgeFormatter(locale, toAgeCompactness opts.Compactness)
            printResult (formatter.FormatStage(dob, ?asOf = Some asOf, ?gender = Some gender))

let private cmdDate (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "date requires a date argument"
    | dateArg :: _ ->
        let dateVal = nullify dateArg
        match SayableDateLib.Locales.get opts.Locale with
        | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
        | Some locale ->
            let formatter = SayableDateLib.Formatter.SayableDateFormatter(locale, toDateCompactness opts.Compactness)
            let result =
                if opts.WithYear then formatter.FormatDateWithYear(dateVal)
                else formatter.FormatDate(dateVal)
            printResult result

let private cmdRelative (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "relative requires a date argument"
    | dateArg :: _ ->
        let dateVal = nullify dateArg
        match opts.AsOf with
        | None -> printError "relative requires --as-of / -d option"
        | Some asOfRaw ->
            let asOf = nullify asOfRaw
            match SayableDateLib.Locales.get opts.Locale with
            | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
            | Some locale ->
                let formatter = SayableDateLib.Formatter.SayableDateFormatter(locale, toDateCompactness opts.Compactness)
                printResult (formatter.FormatRelative(dateVal, asOf))

let private cmdTime (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "time requires a time argument"
    | timeArg :: _ ->
        let timeVal = nullify timeArg
        match SayableTimeLib.Locales.get opts.Locale with
        | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
        | Some locale ->
            let formatter = SayableTimeLib.Formatter.SayableTimeFormatter(locale, toTimeCompactness opts.Compactness)
            printResult (formatter.FormatTime(timeVal))

let private cmdDuration (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "duration requires a value argument"
    | valueArg :: rest ->
        let value = nullify valueArg
        match SayableDurationLib.Locales.get opts.Locale with
        | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
        | Some locale ->
            let formatter = SayableDurationLib.Formatter.SayableDurationFormatter(locale, toDurationCompactness opts.Compactness)
            match value with
            | None -> printResult None
            | Some v when isInteger v ->
                // A digit string too long for an int64 is far beyond the 500-year ceiling
                match Int64.TryParse(v, Globalization.NumberStyles.AllowLeadingSign, Globalization.CultureInfo.InvariantCulture) with
                | true, seconds -> printResult (formatter.FormatDurationSeconds(seconds))
                | false, _ -> printResult None
            | Some v ->
                match rest with
                | [] -> printError "duration with timestamps requires start and end arguments"
                | endArg :: _ -> printResult (formatter.FormatDurationIso(v, endArg))

let private cmdSince (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "since requires a start timestamp argument"
    | startArg :: _ ->
        let start = nullify startArg
        match opts.AsOf with
        | None -> printError "since requires --as-of / -d option"
        | Some asOfRaw ->
            let asOf = nullify asOfRaw
            match SayableDurationLib.Locales.get opts.Locale with
            | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
            | Some locale ->
                let formatter = SayableDurationLib.Formatter.SayableDurationFormatter(locale, toDurationCompactness opts.Compactness)
                printResult (formatter.FormatSince(start, asOf))

let private cmdUntil (positionals: string list) (opts: Options) : Outcome =
    match positionals with
    | [] -> printError "until requires a target timestamp argument"
    | targetArg :: _ ->
        let target = nullify targetArg
        match opts.AsOf with
        | None -> printError "until requires --as-of / -d option"
        | Some asOfRaw ->
            let asOf = nullify asOfRaw
            match SayableDurationLib.Locales.get opts.Locale with
            | None -> printError (sprintf "unknown locale '%s'" opts.Locale)
            | Some locale ->
                let formatter = SayableDurationLib.Formatter.SayableDurationFormatter(locale, toDurationCompactness opts.Compactness)
                printResult (formatter.FormatUntil(target, asOf))

let private cmdLocales () : Outcome =
    SayableAgeLib.Locales.All
    |> Map.toSeq
    |> Seq.map fst
    |> Seq.sort
    |> String.concat "\n"
    |> printing

type private ParseResult =
    | Parsed of command: string * positionals: string list * options: Options
    | ParseError of msg: string

let private parseArgs (argv: string[]) : ParseResult =
    if argv.Length = 0 then
        Parsed("help-no-args", [], defaultOptions)
    else
        match argv.[0] with
        | "-h" | "--help" | "help" -> Parsed("help", [], defaultOptions)
        | "-v" | "--version" | "version" -> Parsed("version", [], defaultOptions)
        | _ ->
            let command = argv.[0]
            let mutable positionals: string list = []
            let mutable opts = defaultOptions
            let mutable i = 1
            let mutable stopOpts = false
            let mutable error: string option = None
            let mutable redirectCommand: string option = None

            while i < argv.Length && error.IsNone && redirectCommand.IsNone do
                let arg = argv.[i]

                if arg = "--" && not stopOpts then
                    stopOpts <- true
                elif not stopOpts && arg.StartsWith("-") then
                    match arg with
                    | "-l" | "--locale" ->
                        if i + 1 >= argv.Length then
                            error <- Some(sprintf "'%s' requires a value" arg)
                        else
                            i <- i + 1
                            opts <- { opts with Locale = argv.[i] }
                    | "-d" | "--as-of" ->
                        if i + 1 >= argv.Length then
                            error <- Some(sprintf "'%s' requires a value" arg)
                        else
                            i <- i + 1
                            opts <- { opts with AsOf = Some argv.[i] }
                    | "-g" | "--gender" ->
                        if i + 1 >= argv.Length then
                            error <- Some(sprintf "'%s' requires a value" arg)
                        else
                            i <- i + 1
                            opts <- { opts with Gender = Some argv.[i] }
                    | "--short" ->
                        opts <- { opts with Compactness = "short" }
                    | "--compact" ->
                        opts <- { opts with Compactness = "compact" }
                    | "--with-year" ->
                        opts <- { opts with WithYear = true }
                    | "-h" | "--help" ->
                        redirectCommand <- Some "help"
                    | "-v" | "--version" ->
                        redirectCommand <- Some "version"
                    | _ ->
                        error <- Some(sprintf "unknown option '%s'" arg)
                else
                    positionals <- positionals @ [ arg ]

                i <- i + 1

            match error with
            | Some msg -> ParseError msg
            | None ->
                match redirectCommand with
                | Some cmd -> Parsed(cmd, [], defaultOptions)
                | None -> Parsed(command, positionals, opts)

let private run (argv: string[]) : Outcome =
    match parseArgs argv with
    | ParseError msg -> printError msg
    | Parsed(command, positionals, opts) ->
        match command with
        | "help-no-args" -> { ExitCode = 2; Output = Some helpText }
        | "help" -> printing helpText
        | "version" -> printing (sprintf "sayable %s" CliVersion)
        | "locales" -> cmdLocales ()
        | "age" -> cmdAge positionals opts
        | "stage" -> cmdStage positionals opts
        | "date" -> cmdDate positionals opts
        | "relative" -> cmdRelative positionals opts
        | "time" -> cmdTime positionals opts
        | "duration" -> cmdDuration positionals opts
        | "since" -> cmdSince positionals opts
        | "until" -> cmdUntil positionals opts
        | _ -> printError (sprintf "unknown command '%s'" command)

/// A crash must not end the REPL: the request answers 1 (cli/SPEC.md) and the error goes to stderr.
let private runCatchingCrashes (argv: string[]) : Outcome =
    try
        run argv
    with e ->
        eprintfn "%O" e
        { ExitCode = 1; Output = None }

/// Answers one tab-separated request per stdin line (see cli/SPEC.md, "REPL Mode").
let private repl () : int =
    let mutable line = Console.In.ReadLine()
    while not (isNull line) do
        let outcome = runCatchingCrashes (line.Split('\t'))
        let output = outcome.Output |> Option.map (fun o -> o.Replace('\n', '\t')) |> Option.defaultValue ""
        Console.Out.Write(sprintf "%d\t%s\n" outcome.ExitCode output)
        Console.Out.Flush()
        line <- Console.In.ReadLine()
    0

[<EntryPoint>]
let main (argv: string[]) : int =
    match argv with
    | [| "--repl" |] -> repl ()
    | _ ->
        let outcome = run argv
        outcome.Output |> Option.iter (printfn "%s")
        outcome.ExitCode

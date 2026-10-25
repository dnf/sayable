%% main.pl — Sayable CLI for SWI-Prolog.
%% Unified command-line interface to all four Sayable components.

:- use_module(library(lists)).

version('0.5.0').

%% Dynamic loading of component modules based on script location.
%% Resolve project root from the path of this file, then register search paths.
:- prolog_load_context(directory, Dir),
   file_directory_name(Dir, CliDir),
   file_directory_name(CliDir, ImplDir),
   file_directory_name(ImplDir, ProjectRoot),
   atomic_list_concat([ProjectRoot, '/age/impl/prolog'], AgePath),
   atomic_list_concat([ProjectRoot, '/date/impl/prolog'], DatePath),
   atomic_list_concat([ProjectRoot, '/duration/impl/prolog'], DurationPath),
   atomic_list_concat([ProjectRoot, '/time/impl/prolog'], TimePath),
   asserta(user:file_search_path(age_dir, AgePath)),
   asserta(user:file_search_path(date_dir, DatePath)),
   asserta(user:file_search_path(duration_dir, DurationPath)),
   asserta(user:file_search_path(time_dir, TimePath)).

%% Load each component independently so a missing one does not prevent others.
%% Import nothing — all calls use fully qualified module:predicate syntax.
:- catch(use_module(age_dir(sayableage), []), _, true).
:- catch(use_module(date_dir(sayabledate), []), _, true).
:- catch(use_module(duration_dir(sayableduration), []), _, true).
:- catch(use_module(time_dir(sayabletime), []), _, true).

%% main — Entry point.
main :-
    current_prolog_flag(argv, Argv),
    (   Argv == ['--repl']
    ->  repl
    ;   catch(dispatch(Argv), cli_exit(Code), halt(Code))
    ).

%% dispatch(+Argv) — run one command; it ends by calling cli_exit/1.
dispatch(Argv) :-
    parse_args(Argv, Command, Positionals, Options),
    (Command == none
     -> print_help, cli_exit(2)
     ;  true
    ),
    run_command(Command, Positionals, Options).

%% cli_exit(+Code) — end the current command with exit Code.
%% The caller of dispatch/1 decides whether that halts or answers a REPL request.
cli_exit(Code) :-
    throw(cli_exit(Code)).

%% exit_code_of(+Argv, -Code) — the exit code a one-shot run of Argv ends with.
%% A one-shot run whose goal fails exits 1.
exit_code_of(Argv, Code) :-
    catch((dispatch(Argv) -> Code = 0 ; Code = 1),
          cli_exit(Exit),
          Code = Exit).

%% run_isolated(+Argv, -Code, -Output) — run one command, capturing its stdout.
%% A crashed one-shot run exits 1, so a crash answers 1 and the REPL keeps serving.
run_isolated(Argv, Code, Output) :-
    catch(with_output_to(string(Output), exit_code_of(Argv, Code)),
          Error,
          ( print_message(error, Error), Code = 1, Output = "" )).

%% repl — answer one tab-separated request per stdin line (see cli/SPEC.md).
repl :-
    set_stream(user_input, encoding(utf8)),
    set_stream(user_output, encoding(utf8)),
    read_line_to_string(user_input, Line),
    repl(Line).

repl(end_of_file) :- !.
repl(Line) :-
    split_string(Line, "\t", "", Fields),
    maplist([Field, Arg]>>atom_string(Arg, Field), Fields, Argv),
    run_isolated(Argv, Code, Output),
    response_text(Output, Text),
    format("~d\t~w~n", [Code, Text]),
    flush_output,
    read_line_to_string(user_input, Next),
    repl(Next).

%% response_text(+Output, -Text) — Output without its trailing newline, inner newlines as tabs.
response_text(Output, Text) :-
    (string_concat(Body, "\n", Output) -> true ; Body = Output),
    split_string(Body, "\n", "", Lines),
    atomic_list_concat(Lines, '\t', Text).

%% parse_args(+Argv, -Command, -Positionals, -Options)
parse_args([], none, [], options(en, none, normal, none, false)).
parse_args(Argv, Command, Positionals, Options) :-
    Argv = [First|_],
    (member(First, ['-h', '--help', help])
     -> Command = help, Positionals = [], Options = options(en, none, normal, none, false)
     ;  member(First, ['-v', '--version', version])
     -> Command = version, Positionals = [], Options = options(en, none, normal, none, false)
     ;  Argv = [Cmd|Rest],
        atom_string(Command, Cmd),
        parse_options(Rest, Positionals, en, none, normal, none, false, Options)
    ).

%% parse_options(+Args, -Positionals, +Locale, +AsOf, +Compactness, +Gender, +WithYear, -Options)
parse_options([], [], Loc, AsOf, Comp, Gen, WY, options(Loc, AsOf, Comp, Gen, WY)).
parse_options(['--'|Rest], Rest, Loc, AsOf, Comp, Gen, WY, options(Loc, AsOf, Comp, Gen, WY)).
parse_options([Arg|Rest], Pos, _Loc, AsOf, Comp, Gen, WY, Opts) :-
    (Arg == '-l' ; Arg == '--locale'),
    !,
    (Rest = [Val|Rest2]
     -> parse_options(Rest2, Pos, Val, AsOf, Comp, Gen, WY, Opts)
     ;  format(user_error, "error: '~w' requires a value~n", [Arg]),
        format(user_error, "Run 'sayable help' for usage.~n", []),
        cli_exit(2)
    ).
parse_options([Arg|Rest], Pos, Loc, _AsOf, Comp, Gen, WY, Opts) :-
    (Arg == '-d' ; Arg == '--as-of'),
    !,
    (Rest = [Val|Rest2]
     -> parse_options(Rest2, Pos, Loc, Val, Comp, Gen, WY, Opts)
     ;  format(user_error, "error: '~w' requires a value~n", [Arg]),
        format(user_error, "Run 'sayable help' for usage.~n", []),
        cli_exit(2)
    ).
parse_options([Arg|Rest], Pos, Loc, AsOf, _Comp, _Gen, WY, Opts) :-
    (Arg == '-g' ; Arg == '--gender'),
    !,
    (Rest = [Val|Rest2]
     -> parse_options(Rest2, Pos, Loc, AsOf, normal, Val, WY, Opts)
     ;  format(user_error, "error: '~w' requires a value~n", [Arg]),
        format(user_error, "Run 'sayable help' for usage.~n", []),
        cli_exit(2)
    ).
parse_options(['--short'|Rest], Pos, Loc, AsOf, _Comp, Gen, WY, Opts) :-
    !, parse_options(Rest, Pos, Loc, AsOf, short, Gen, WY, Opts).
parse_options(['--compact'|Rest], Pos, Loc, AsOf, _Comp, Gen, WY, Opts) :-
    !, parse_options(Rest, Pos, Loc, AsOf, compact, Gen, WY, Opts).
parse_options(['--with-year'|Rest], Pos, Loc, AsOf, Comp, Gen, _WY, Opts) :-
    !, parse_options(Rest, Pos, Loc, AsOf, Comp, Gen, true, Opts).
parse_options([Arg|_Rest], _Pos, _Loc, _AsOf, _Comp, _Gen, _WY, _Opts) :-
    (Arg == '-h' ; Arg == '--help'),
    !, print_help, cli_exit(0).
parse_options([Arg|_Rest], _Pos, _Loc, _AsOf, _Comp, _Gen, _WY, _Opts) :-
    (Arg == '-v' ; Arg == '--version'),
    !, version(V), format("sayable ~w~n", [V]), cli_exit(0).
parse_options([Arg|_Rest], _Pos, _Loc, _AsOf, _Comp, _Gen, _WY, _Opts) :-
    atom_string(Arg, ArgStr),
    string_concat("-", _, ArgStr),
    !,
    format(user_error, "error: unknown option '~w'~n", [Arg]),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
parse_options([Arg|Rest], [Arg|Pos], Loc, AsOf, Comp, Gen, WY, Opts) :-
    parse_options(Rest, Pos, Loc, AsOf, Comp, Gen, WY, Opts).

%% nullify(+Value, -Result) — convert 'null' sentinel to failure.
nullify(null, _) :- !, fail.
nullify(Val, Val).

%% get_today(-Date) — get today's date as YYYY-MM-DD atom.
get_today(Date) :-
    get_time(Stamp),
    stamp_date_time(Stamp, date(Y, M, D, _, _, _, _, _, _), local),
    format(atom(Date), "~w-~|~`0t~w~2+-~|~`0t~w~2+", [Y, M, D]).

%% run_command(+Command, +Positionals, +Options)
run_command(help, _, _) :- print_help, cli_exit(0).
run_command(version, _, _) :- version(V), format("sayable ~w~n", [V]), cli_exit(0).
run_command(locales, _, _) :- cmd_locales, cli_exit(0).

run_command(age, Positionals, Options) :-
    !, cmd_age(Positionals, Options).
run_command(stage, Positionals, Options) :-
    !, cmd_stage(Positionals, Options).
run_command(date, Positionals, Options) :-
    !, cmd_date(Positionals, Options).
run_command(relative, Positionals, Options) :-
    !, cmd_relative(Positionals, Options).
run_command(time, Positionals, Options) :-
    !, cmd_time(Positionals, Options).
run_command(duration, Positionals, Options) :-
    !, cmd_duration(Positionals, Options).
run_command(since, Positionals, Options) :-
    !, cmd_since(Positionals, Options).
run_command(until, Positionals, Options) :-
    !, cmd_until(Positionals, Options).
run_command(Cmd, _, _) :-
    format(user_error, "error: unknown command '~w'~n", [Cmd]),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).

%% require_locale(+Module, +Locale) — end with a usage error (exit 2) unless
%% Module knows Locale.
require_locale(Module, Locale) :-
    (catch(Module:get_locale(Locale), _, fail)
     -> true
     ;  format(user_error, "error: unknown locale '~w'~n", [Locale]),
        format(user_error, "Run 'sayable help' for usage.~n", []),
        cli_exit(2)
    ).

%% cmd_age(+Positionals, +Options)
cmd_age([], _) :-
    format(user_error, "error: age requires a date-of-birth argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_age([DobRaw|_], options(Locale, AsOfRaw, Compactness, _, _)) :-
    require_locale(sayableage, Locale),
    (AsOfRaw == none -> get_today(AsOf) ; (nullify(AsOfRaw, AsOf) -> true ; cli_exit(1))),
    (nullify(DobRaw, Dob)
     -> (sayableage:format_age(Locale, Dob, AsOf, Compactness, Result)
         -> format("~w~n", [Result]), cli_exit(0)
         ;  cli_exit(1)
        )
     ;  cli_exit(1)
    ).

%% cmd_stage(+Positionals, +Options)
cmd_stage([], _) :-
    format(user_error, "error: stage requires a date-of-birth argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_stage([DobRaw|_], options(Locale, AsOfRaw, _Compactness, GenderRaw, _)) :-
    require_locale(sayableage, Locale),
    (AsOfRaw == none -> get_today(AsOf) ; (nullify(AsOfRaw, AsOf) -> true ; cli_exit(1))),
    (GenderRaw == none -> Gender = none ; Gender = GenderRaw),
    (nullify(DobRaw, Dob)
     -> (sayableage:format_stage(Locale, Dob, AsOf, Gender, Result)
         -> format("~w~n", [Result]), cli_exit(0)
         ;  cli_exit(1)
        )
     ;  cli_exit(1)
    ).

%% cmd_date(+Positionals, +Options)
cmd_date([], _) :-
    format(user_error, "error: date requires a date argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_date([DateRaw|_], options(Locale, _, Compactness, _, WithYear)) :-
    require_locale(sayabledate, Locale),
    (nullify(DateRaw, DateVal)
     -> (WithYear == true
         -> (sayabledate:format_date_with_year(Locale, DateVal, Compactness, Result)
             -> format("~w~n", [Result]), cli_exit(0)
             ;  cli_exit(1)
            )
         ;  (sayabledate:format_date(Locale, DateVal, Compactness, Result)
             -> format("~w~n", [Result]), cli_exit(0)
             ;  cli_exit(1)
            )
        )
     ;  cli_exit(1)
    ).

%% cmd_relative(+Positionals, +Options)
cmd_relative([], _) :-
    format(user_error, "error: relative requires a date argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_relative(_, options(_, none, _, _, _)) :-
    format(user_error, "error: relative requires --as-of / -d option~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_relative([DateRaw|_], options(Locale, AsOfRaw, Compactness, _, _)) :-
    require_locale(sayabledate, Locale),
    (nullify(DateRaw, DateVal)
     -> (nullify(AsOfRaw, AsOf)
         -> (sayabledate:format_relative(Locale, DateVal, AsOf, Compactness, Result)
             -> format("~w~n", [Result]), cli_exit(0)
             ;  cli_exit(1)
            )
         ;  cli_exit(1)
        )
     ;  cli_exit(1)
    ).

%% cmd_time(+Positionals, +Options)
cmd_time([], _) :-
    format(user_error, "error: time requires a time argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_time([TimeRaw|_], options(Locale, _, Compactness, _, _)) :-
    require_locale(sayabletime, Locale),
    (nullify(TimeRaw, TimeVal)
     -> (sayabletime:format_time(Locale, TimeVal, Compactness, Result)
         -> format("~w~n", [Result]), cli_exit(0)
         ;  cli_exit(1)
        )
     ;  cli_exit(1)
    ).

%% cmd_duration(+Positionals, +Options)
cmd_duration([], _) :-
    format(user_error, "error: duration requires a value argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_duration([ValueRaw|Rest], options(Locale, _, Compactness, _, _)) :-
    require_locale(sayableduration, Locale),
    (nullify(ValueRaw, Value)
     -> atom_string(Value, ValueStr),
        (is_integer_string(ValueStr)
         -> number_string(Secs, ValueStr),
            (sayableduration:format_duration(Locale, Secs, Compactness, Result)
             -> format("~w~n", [Result]), cli_exit(0)
             ;  cli_exit(1)
            )
         ;  (Rest = [EndRaw|_]
             -> (nullify(EndRaw, End)
                 -> (sayableduration:format_duration_ts(Locale, Value, End, Compactness, Result)
                     -> format("~w~n", [Result]), cli_exit(0)
                     ;  cli_exit(1)
                    )
                 ;  cli_exit(1)
                )
             ;  format(user_error, "error: duration with timestamps requires start and end arguments~n", []),
                format(user_error, "Run 'sayable help' for usage.~n", []),
                cli_exit(2)
            )
        )
     ;  cli_exit(1)
    ).

%% cmd_since(+Positionals, +Options)
cmd_since([], _) :-
    format(user_error, "error: since requires a start timestamp argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_since(_, options(_, none, _, _, _)) :-
    format(user_error, "error: since requires --as-of / -d option~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_since([StartRaw|_], options(Locale, AsOfRaw, Compactness, _, _)) :-
    require_locale(sayableduration, Locale),
    (nullify(StartRaw, Start)
     -> (nullify(AsOfRaw, AsOf)
         -> (sayableduration:format_since(Locale, Start, AsOf, Compactness, Result)
             -> format("~w~n", [Result]), cli_exit(0)
             ;  cli_exit(1)
            )
         ;  cli_exit(1)
        )
     ;  cli_exit(1)
    ).

%% cmd_until(+Positionals, +Options)
cmd_until([], _) :-
    format(user_error, "error: until requires a target timestamp argument~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_until(_, options(_, none, _, _, _)) :-
    format(user_error, "error: until requires --as-of / -d option~n", []),
    format(user_error, "Run 'sayable help' for usage.~n", []),
    cli_exit(2).
cmd_until([TargetRaw|_], options(Locale, AsOfRaw, Compactness, _, _)) :-
    require_locale(sayableduration, Locale),
    (nullify(TargetRaw, Target)
     -> (nullify(AsOfRaw, AsOf)
         -> (sayableduration:format_until(Locale, Target, AsOf, Compactness, Result)
             -> format("~w~n", [Result]), cli_exit(0)
             ;  cli_exit(1)
            )
         ;  cli_exit(1)
        )
     ;  cli_exit(1)
    ).

%% cmd_locales — list all locale codes.
%% Try each component in order; all share the same locale set.
cmd_locales :-
    (catch(findall(Code, sayableage:sa_locale(Code), Codes), _, fail)
     -> true
     ;  catch(findall(Code, sayabledate:sd_locale(Code), Codes), _, fail)
     -> true
     ;  catch(findall(Code, sayableduration:sd_locale(Code), Codes), _, fail)
     -> true
     ;  catch(findall(Code, sayabletime:st_locale(Code), Codes), _, fail)
     -> true
     ;  Codes = []
    ),
    sort(Codes, Sorted),
    print_codes(Sorted).

print_codes([]).
print_codes([C|Rest]) :-
    format("~w~n", [C]),
    print_codes(Rest).

%% is_integer_string(+Str) — true if string represents an integer (possibly negative).
is_integer_string(Str) :-
    string_codes(Str, Codes),
    (Codes = [0'- | Rest] -> true ; Rest = Codes),
    Rest \= [],
    forall(member(C, Rest), (C >= 0'0, C =< 0'9)).

%% print_help — print usage information.
print_help :-
    format("Usage: sayable <command> [arguments] [options]~n~n"),
    format("Commands:~n"),
    format("  age <dob>              Format an age~n"),
    format("  stage <dob>            Get developmental stage~n"),
    format("  date <date>            Format a calendar date~n"),
    format("  relative <date>        Format a relative date~n"),
    format("  time <time>            Format a clock time~n"),
    format("  duration <value> [end] Format a duration~n"),
    format("  since <start>          Format elapsed time~n"),
    format("  until <target>         Format remaining time~n"),
    format("  locales                List available locale codes~n"),
    format("  version                Show version~n"),
    format("  help                   Show this help~n~n"),
    format("Options:~n"),
    format("  -l, --locale <code>    Locale code (default: en)~n"),
    format("  -d, --as-of <value>    Reference date/timestamp~n"),
    format("      --short            Short compactness~n"),
    format("      --compact          Compact compactness~n"),
    format("  -g, --gender <m|f>     Gender for stage labels~n"),
    format("      --with-year        Include year (date only)~n"),
    format("  -h, --help             Show this help~n"),
    format("  -v, --version          Show version~n").

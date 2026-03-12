-module(sayable_cli).
-export([main/0, main/1]).

-define(VERSION, "0.5.0").

main() ->
    main(init:get_plain_arguments()).

main(Args) ->
    case parse_args(Args) of
        {help, _, _} ->
            print_help(),
            erlang:halt(0);
        {version, _, _} ->
            io:format("sayable ~s~n", [?VERSION]),
            erlang:halt(0);
        {locales, _, _} ->
            cmd_locales(),
            erlang:halt(0);
        {none, _, _} ->
            print_help(),
            erlang:halt(2);
        {Command, Positionals, Options} ->
            run_command(Command, Positionals, Options);
        {error, Msg} ->
            error_exit(Msg)
    end.

%% ── Argument parsing ──────────────────────────────────────────────

parse_args([]) ->
    {none, [], #{}};
parse_args([First | _] = Args) ->
    case First of
        "-h"        -> {help, [], #{}};
        "--help"    -> {help, [], #{}};
        "help"      -> {help, [], #{}};
        "-v"        -> {version, [], #{}};
        "--version" -> {version, [], #{}};
        "version"   -> {version, [], #{}};
        _ ->
            Command = First,
            parse_opts(tl(Args), Command, [], default_options(), false)
    end.

default_options() ->
    #{locale => "en", as_of => undefined, compactness => normal,
      gender => undefined, with_year => false}.

parse_opts([], Command, Pos, Opts, _StopOpts) ->
    {list_to_atom(Command), lists:reverse(Pos), Opts};
parse_opts(["--" | Rest], Command, Pos, Opts, false) ->
    parse_opts(Rest, Command, Pos, Opts, true);
parse_opts([Arg | Rest], Command, Pos, Opts, false) when hd(Arg) =:= $- ->
    case Arg of
        "-l" -> parse_opt_value(Rest, Command, Pos, Opts, locale);
        "--locale" -> parse_opt_value(Rest, Command, Pos, Opts, locale);
        "-d" -> parse_opt_value(Rest, Command, Pos, Opts, as_of);
        "--as-of" -> parse_opt_value(Rest, Command, Pos, Opts, as_of);
        "-g" -> parse_opt_value(Rest, Command, Pos, Opts, gender);
        "--gender" -> parse_opt_value(Rest, Command, Pos, Opts, gender);
        "--short" ->
            parse_opts(Rest, Command, Pos, Opts#{compactness => short}, false);
        "--compact" ->
            parse_opts(Rest, Command, Pos, Opts#{compactness => compact}, false);
        "--with-year" ->
            parse_opts(Rest, Command, Pos, Opts#{with_year => true}, false);
        "-h" -> {help, [], #{}};
        "--help" -> {help, [], #{}};
        "-v" -> {version, [], #{}};
        "--version" -> {version, [], #{}};
        _ ->
            {error, "unknown option '" ++ Arg ++ "'"}
    end;
parse_opts([Arg | Rest], Command, Pos, Opts, StopOpts) ->
    parse_opts(Rest, Command, [Arg | Pos], Opts, StopOpts).

parse_opt_value([], _Command, _Pos, _Opts, Key) ->
    Label = case Key of
        locale -> "--locale";
        as_of -> "--as-of";
        gender -> "--gender"
    end,
    {error, "'" ++ Label ++ "' requires a value"};
parse_opt_value([Val | Rest], Command, Pos, Opts, Key) ->
    parse_opts(Rest, Command, Pos, Opts#{Key => Val}, false).

%% ── Null handling ──────────────────────────────────────────────────

nullify("null") -> undefined;
nullify(Value) -> Value.

%% ── Today helper ──────────────────────────────────────────────────

get_today() ->
    {{Y, M, D}, _} = calendar:local_time(),
    lists:flatten(io_lib:format("~4..0B-~2..0B-~2..0B", [Y, M, D])).

%% ── Command dispatch ─────────────────────────────────────────────

run_command(age, Positionals, Options) -> cmd_age(Positionals, Options);
run_command(stage, Positionals, Options) -> cmd_stage(Positionals, Options);
run_command(date, Positionals, Options) -> cmd_date(Positionals, Options);
run_command(relative, Positionals, Options) -> cmd_relative(Positionals, Options);
run_command(time, Positionals, Options) -> cmd_time(Positionals, Options);
run_command(duration, Positionals, Options) -> cmd_duration(Positionals, Options);
run_command(since, Positionals, Options) -> cmd_since(Positionals, Options);
run_command('until', Positionals, Options) -> cmd_until(Positionals, Options);
run_command(Command, _Positionals, _Options) ->
    error_exit("unknown command '" ++ atom_to_list(Command) ++ "'").

%% ── Age command ───────────────────────────────────────────────────

cmd_age([], _Options) ->
    error_exit("age requires a date-of-birth argument");
cmd_age([RawDob | _], Options) ->
    Dob = nullify(RawDob),
    case Dob of
        undefined ->
            erlang:halt(1);
        _ ->
            #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness} = Options,
            case sayableage:get_locale(LocaleCode) of
                error ->
                    error_exit("unknown locale '" ++ LocaleCode ++ "'");
                {ok, Locale} ->
                    AsOf = case RawAsOf of
                        undefined -> get_today();
                        _ -> nullify(RawAsOf)
                    end,
                    case sayableage:format_age_pure(Locale, Compactness, Dob, AsOf) of
                        {ok, Result} ->
                            io:format("~ts~n", [Result]),
                            erlang:halt(0);
                        error ->
                            erlang:halt(1)
                    end
            end
    end.

%% ── Stage command ─────────────────────────────────────────────────

cmd_stage([], _Options) ->
    error_exit("stage requires a date-of-birth argument");
cmd_stage([RawDob | _], Options) ->
    Dob = nullify(RawDob),
    case Dob of
        undefined ->
            erlang:halt(1);
        _ ->
            #{locale := LocaleCode, as_of := RawAsOf, compactness := _Compactness,
              gender := RawGender} = Options,
            case sayableage:get_locale(LocaleCode) of
                error ->
                    error_exit("unknown locale '" ++ LocaleCode ++ "'");
                {ok, Locale} ->
                    AsOf = case RawAsOf of
                        undefined -> get_today();
                        _ -> nullify(RawAsOf)
                    end,
                    Gender = case RawGender of
                        "m" -> male;
                        "f" -> female;
                        _ -> undefined
                    end,
                    case sayableage:format_stage_pure(Locale, Dob, AsOf, Gender) of
                        {ok, Result} ->
                            io:format("~ts~n", [Result]),
                            erlang:halt(0);
                        error ->
                            erlang:halt(1)
                    end
            end
    end.

%% ── Date command ──────────────────────────────────────────────────

cmd_date([], _Options) ->
    error_exit("date requires a date argument");
cmd_date([RawDate | _], Options) ->
    DateVal = nullify(RawDate),
    #{locale := LocaleCode, compactness := Compactness, with_year := WithYear} = Options,
    case sayabledate:get_locale(LocaleCode) of
        error ->
            error_exit("unknown locale '" ++ LocaleCode ++ "'");
        {ok, Locale} ->
            Result = case WithYear of
                true -> sayabledate:format_date_with_year(Locale, Compactness, DateVal);
                false -> sayabledate:format_date(Locale, Compactness, DateVal)
            end,
            case Result of
                {ok, Output} ->
                    io:format("~ts~n", [Output]),
                    erlang:halt(0);
                error ->
                    erlang:halt(1)
            end
    end.

%% ── Relative command ──────────────────────────────────────────────

cmd_relative([], _Options) ->
    error_exit("relative requires a date argument");
cmd_relative([RawDate | _], Options) ->
    DateVal = nullify(RawDate),
    #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness} = Options,
    case RawAsOf of
        undefined ->
            error_exit("relative requires --as-of / -d option");
        _ ->
            AsOf = nullify(RawAsOf),
            case sayabledate:get_locale(LocaleCode) of
                error ->
                    error_exit("unknown locale '" ++ LocaleCode ++ "'");
                {ok, Locale} ->
                    case sayabledate:format_relative(Locale, Compactness, DateVal, AsOf) of
                        {ok, Result} ->
                            io:format("~ts~n", [Result]),
                            erlang:halt(0);
                        error ->
                            erlang:halt(1)
                    end
            end
    end.

%% ── Time command ──────────────────────────────────────────────────

cmd_time([], _Options) ->
    error_exit("time requires a time argument");
cmd_time([RawTime | _], Options) ->
    TimeVal = nullify(RawTime),
    #{locale := LocaleCode, compactness := Compactness} = Options,
    case sayabletime:get_locale(LocaleCode) of
        error ->
            error_exit("unknown locale '" ++ LocaleCode ++ "'");
        {ok, Locale} ->
            case sayabletime:format_time(Locale, Compactness, TimeVal) of
                {ok, Result} ->
                    io:format("~ts~n", [Result]),
                    erlang:halt(0);
                error ->
                    erlang:halt(1)
            end
    end.

%% ── Duration command ──────────────────────────────────────────────

cmd_duration([], _Options) ->
    error_exit("duration requires a value argument");
cmd_duration([RawValue | RestPos], Options) ->
    Value = nullify(RawValue),
    #{locale := LocaleCode, compactness := Compactness} = Options,
    case sayableduration:get_locale(LocaleCode) of
        error ->
            error_exit("unknown locale '" ++ LocaleCode ++ "'");
        {ok, Locale} ->
            Result = case Value of
                undefined ->
                    sayableduration:format_duration(Locale, Compactness, undefined, undefined);
                _ ->
                    case is_integer_string(Value) of
                        {true, N} ->
                            sayableduration:format_duration(Locale, Compactness, N, undefined);
                        false ->
                            %% Timestamp mode: need end argument
                            case RestPos of
                                [] ->
                                    error_exit("duration with timestamps requires start and end arguments");
                                [RawEnd | _] ->
                                    End = nullify(RawEnd),
                                    sayableduration:format_duration(Locale, Compactness, Value, End)
                            end
                    end
            end,
            case Result of
                {ok, Output} ->
                    io:format("~ts~n", [Output]),
                    erlang:halt(0);
                error ->
                    erlang:halt(1)
            end
    end.

%% ── Since command ─────────────────────────────────────────────────

cmd_since([], _Options) ->
    error_exit("since requires a start timestamp argument");
cmd_since([RawStart | _], Options) ->
    Start = nullify(RawStart),
    #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness} = Options,
    case RawAsOf of
        undefined ->
            error_exit("since requires --as-of / -d option");
        _ ->
            AsOf = nullify(RawAsOf),
            case sayableduration:get_locale(LocaleCode) of
                error ->
                    error_exit("unknown locale '" ++ LocaleCode ++ "'");
                {ok, Locale} ->
                    case sayableduration:format_since(Locale, Compactness, Start, AsOf) of
                        {ok, Result} ->
                            io:format("~ts~n", [Result]),
                            erlang:halt(0);
                        error ->
                            erlang:halt(1)
                    end
            end
    end.

%% ── Until command ─────────────────────────────────────────────────

cmd_until([], _Options) ->
    error_exit("until requires a target timestamp argument");
cmd_until([RawTarget | _], Options) ->
    Target = nullify(RawTarget),
    #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness} = Options,
    case RawAsOf of
        undefined ->
            error_exit("until requires --as-of / -d option");
        _ ->
            AsOf = nullify(RawAsOf),
            case sayableduration:get_locale(LocaleCode) of
                error ->
                    error_exit("unknown locale '" ++ LocaleCode ++ "'");
                {ok, Locale} ->
                    case sayableduration:format_until(Locale, Compactness, Target, AsOf) of
                        {ok, Result} ->
                            io:format("~ts~n", [Result]),
                            erlang:halt(0);
                        error ->
                            erlang:halt(1)
                    end
            end
    end.

%% ── Locales command ───────────────────────────────────────────────

cmd_locales() ->
    Codes = collect_locale_codes(),
    lists:foreach(fun(Code) -> io:format("~s~n", [Code]) end, Codes).

collect_locale_codes() ->
    %% All four components share the same locale codes.
    %% Enumerate by probing the age locales barrel module with all known codes.
    AllCodes = all_locale_codes(),
    lists:sort(AllCodes).

all_locale_codes() ->
    %% Complete list derived from the generated locales barrel modules.
    ["af","ak","am","ar","az","bci","be","bem","bg","bm","bn","br","bs",
     "ca","ceb","cs","cy","da","de","din","dje","dyu","ee","el","en","es",
     "et","eu","fa","fan","ff","fi","fil","fon","fr","ga","gd","gl","gn",
     "gu","gv","ha","he","hi","hr","ht","hu","hy","id","ig","is","it",
     "ja","jv","ka","kbp","kk","km","kn","ko","kpe","ktu","ku","kw","ky",
     "lg","ln","lo","lt","lv","men","mfe","mg","mi","mk","ml","mn","mnk",
     "mos","mr","ms","mt","my","nb","nd","ne","ng","nl","nso","nus","ny",
     "om","or","pa","pl","pov","ps","pt","qu","ro","ru","rw","sar","sd",
     "sg","shi","si","sk","sl","sn","snk","so","sq","sr","ss","st","su",
     "suk","sv","sw","ta","te","tem","tg","th","ti","tig","tk","tn","tr",
     "ts","tzm","uk","umb","ur","uz","vi","vmw","wo","xh","yo","yue",
     "zdj","zh","zu"].

%% ── Integer detection ─────────────────────────────────────────────

is_integer_string([]) -> false;
is_integer_string([$- | Rest]) ->
    case all_digits(Rest) andalso Rest =/= [] of
        true -> {true, list_to_integer([$- | Rest])};
        false -> false
    end;
is_integer_string(Str) ->
    case all_digits(Str) of
        true -> {true, list_to_integer(Str)};
        false -> false
    end.

all_digits([]) -> true;
all_digits([C | Rest]) when C >= $0, C =< $9 -> all_digits(Rest);
all_digits(_) -> false.

%% ── Error helpers ─────────────────────────────────────────────────

error_exit(Msg) ->
    io:format(standard_error, "error: ~s~n", [Msg]),
    io:format(standard_error, "Run 'sayable help' for usage.~n", []),
    erlang:halt(2).

%% ── Help text ─────────────────────────────────────────────────────

print_help() ->
    io:format(
"Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version~n", []).

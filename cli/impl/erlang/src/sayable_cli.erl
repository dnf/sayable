-module(sayable_cli).
-export([main/0, main/1]).

-define(VERSION, "0.5.0").

%% A command's exit code and the lines it prints to stdout.
-type result() :: {0..2, [unicode:chardata()]}.

main() ->
    main(init:get_plain_arguments()).

main(["--repl"]) ->
    repl(),
    erlang:halt(0);
main(Args) ->
    {Code, Lines} = run(Args),
    lists:foreach(fun(Line) -> io:format("~ts~n", [Line]) end, Lines),
    erlang:halt(Code).

-spec run([string()]) -> result().
run(Args) ->
    try dispatch(parse_args(Args))
    catch
        throw:{usage_error, Msg} ->
            print_usage_error(Msg),
            {2, []}
    end.

dispatch({help, _, _}) -> {0, [help_text()]};
dispatch({version, _, _}) -> {0, ["sayable " ?VERSION]};
dispatch({none, _, _}) -> {2, [help_text()]};
dispatch({error, Msg}) -> usage_error(Msg);
dispatch({"locales", _, _}) -> {0, collect_locale_codes()};
dispatch({Command, Positionals, Options}) -> run_command(Command, Positionals, Options).

%% ── REPL mode (see cli/SPEC.md) ───────────────────────────────────

repl() ->
    ok = io:setopts(standard_io, [binary, {encoding, unicode}]),
    repl_loop().

repl_loop() ->
    case io:get_line(standard_io, "") of
        eof ->
            ok;
        {error, Reason} ->
            io:format(standard_error, "error: cannot read request: ~p~n", [Reason]),
            erlang:halt(1);
        Line ->
            {Code, Lines} = run_isolated(request_args(Line)),
            io:put_chars(standard_io, [integer_to_list(Code), $\t, response_text(Lines), $\n]),
            repl_loop()
    end.

request_args(Line) ->
    Fields = binary:split(string:chomp(Line), <<"\t">>, [global]),
    [unicode:characters_to_list(Field) || Field <- Fields].

response_text(Lines) ->
    string:replace(lists:join("\n", Lines), "\n", "\t", all).

%% A crashed one-shot run exits 1, so a crashed request answers 1 and the REPL keeps serving.
run_isolated(Args) ->
    try run(Args)
    catch
        Class:Reason:Stack ->
            io:format(standard_error, "error: ~p~n", [{Class, Reason, Stack}]),
            {1, []}
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
    {Command, lists:reverse(Pos), Opts};
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

run_command("age", Positionals, Options) -> cmd_age(Positionals, Options);
run_command("stage", Positionals, Options) -> cmd_stage(Positionals, Options);
run_command("date", Positionals, Options) -> cmd_date(Positionals, Options);
run_command("relative", Positionals, Options) -> cmd_relative(Positionals, Options);
run_command("time", Positionals, Options) -> cmd_time(Positionals, Options);
run_command("duration", Positionals, Options) -> cmd_duration(Positionals, Options);
run_command("since", Positionals, Options) -> cmd_since(Positionals, Options);
run_command("until", Positionals, Options) -> cmd_until(Positionals, Options);
run_command(Command, _Positionals, _Options) ->
    usage_error("unknown command '" ++ Command ++ "'").

formatted({ok, Text}) -> {0, [Text]};
formatted(error) -> null_result().

null_result() -> {1, []}.

locale(Component, LocaleCode) ->
    case Component:get_locale(LocaleCode) of
        {ok, Locale} -> Locale;
        error -> usage_error("unknown locale '" ++ LocaleCode ++ "'")
    end.

as_of_or_today(undefined) -> get_today();
as_of_or_today(RawAsOf) -> nullify(RawAsOf).

required_as_of(Command, undefined) ->
    usage_error(Command ++ " requires --as-of / -d option");
required_as_of(_Command, RawAsOf) ->
    nullify(RawAsOf).

%% ── Age command ───────────────────────────────────────────────────

cmd_age([], _Options) ->
    usage_error("age requires a date-of-birth argument");
cmd_age(["null" | _], _Options) ->
    null_result();
cmd_age([Dob | _], #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness}) ->
    Locale = locale(sayableage, LocaleCode),
    formatted(sayableage:format_age_pure(Locale, Compactness, Dob, as_of_or_today(RawAsOf))).

%% ── Stage command ─────────────────────────────────────────────────

cmd_stage([], _Options) ->
    usage_error("stage requires a date-of-birth argument");
cmd_stage(["null" | _], _Options) ->
    null_result();
cmd_stage([Dob | _], #{locale := LocaleCode, as_of := RawAsOf, gender := RawGender}) ->
    Locale = locale(sayableage, LocaleCode),
    Gender = case RawGender of
        "m" -> male;
        "f" -> female;
        _ -> undefined
    end,
    formatted(sayableage:format_stage_pure(Locale, Dob, as_of_or_today(RawAsOf), Gender)).

%% ── Date command ──────────────────────────────────────────────────

cmd_date([], _Options) ->
    usage_error("date requires a date argument");
cmd_date([RawDate | _], #{locale := LocaleCode, compactness := Compactness, with_year := WithYear}) ->
    DateVal = nullify(RawDate),
    Locale = locale(sayabledate, LocaleCode),
    formatted(case WithYear of
        true -> sayabledate:format_date_with_year(Locale, Compactness, DateVal);
        false -> sayabledate:format_date(Locale, Compactness, DateVal)
    end).

%% ── Relative command ──────────────────────────────────────────────

cmd_relative([], _Options) ->
    usage_error("relative requires a date argument");
cmd_relative([RawDate | _], #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness}) ->
    AsOf = required_as_of("relative", RawAsOf),
    Locale = locale(sayabledate, LocaleCode),
    formatted(sayabledate:format_relative(Locale, Compactness, nullify(RawDate), AsOf)).

%% ── Time command ──────────────────────────────────────────────────

cmd_time([], _Options) ->
    usage_error("time requires a time argument");
cmd_time([RawTime | _], #{locale := LocaleCode, compactness := Compactness}) ->
    Locale = locale(sayabletime, LocaleCode),
    formatted(sayabletime:format_time(Locale, Compactness, nullify(RawTime))).

%% ── Duration command ──────────────────────────────────────────────

cmd_duration([], _Options) ->
    usage_error("duration requires a value argument");
cmd_duration([RawValue | RestPos], #{locale := LocaleCode, compactness := Compactness}) ->
    Locale = locale(sayableduration, LocaleCode),
    formatted(case nullify(RawValue) of
        undefined ->
            sayableduration:format_duration(Locale, Compactness, undefined, undefined);
        Value ->
            case {is_integer_string(Value), RestPos} of
                {{true, Seconds}, _} ->
                    sayableduration:format_duration(Locale, Compactness, Seconds, undefined);
                {false, []} ->
                    usage_error("duration with timestamps requires start and end arguments");
                {false, [RawEnd | _]} ->
                    sayableduration:format_duration(Locale, Compactness, Value, nullify(RawEnd))
            end
    end).

%% ── Since command ─────────────────────────────────────────────────

cmd_since([], _Options) ->
    usage_error("since requires a start timestamp argument");
cmd_since([RawStart | _], #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness}) ->
    AsOf = required_as_of("since", RawAsOf),
    Locale = locale(sayableduration, LocaleCode),
    formatted(sayableduration:format_since(Locale, Compactness, nullify(RawStart), AsOf)).

%% ── Until command ─────────────────────────────────────────────────

cmd_until([], _Options) ->
    usage_error("until requires a target timestamp argument");
cmd_until([RawTarget | _], #{locale := LocaleCode, as_of := RawAsOf, compactness := Compactness}) ->
    AsOf = required_as_of("until", RawAsOf),
    Locale = locale(sayableduration, LocaleCode),
    formatted(sayableduration:format_until(Locale, Compactness, nullify(RawTarget), AsOf)).

%% ── Locales command ───────────────────────────────────────────────

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

%% Unwinds to run/1, which reports the message and answers exit code 2.
usage_error(Msg) ->
    throw({usage_error, Msg}).

print_usage_error(Msg) ->
    io:format(standard_error, "error: ~ts~n", [Msg]),
    io:format(standard_error, "Run 'sayable help' for usage.~n", []).

%% ── Help text ─────────────────────────────────────────────────────

help_text() ->
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
  -v, --version          Show version".

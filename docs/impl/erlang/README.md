# Erlang Style Guide

A comprehensive reference for idiomatic Erlang coding style and best practices. Intended for code auditing Erlang implementations.

## Sources

This guide synthesizes conventions from the following authoritative references:

- [Erlang Programming Rules and Conventions](http://www.erlang.se/doc/programming_rules.shtml) (Ericsson)
- [Inaka Erlang Coding Guidelines](https://github.com/inaka/erlang_guidelines)
- [Erlang/OTP Documentation](https://www.erlang.org/docs)
- [Learn You Some Erlang for Great Good!](https://learnyousomeerlang.com/)
- [Adopting Erlang](https://adoptingerlang.org/)
- [Erlang Expressions Reference](https://www.erlang.org/doc/system/expressions.html)
- [Erlang Efficiency Guide](https://www.erlang.org/doc/system/listhandling.html)

---

## 1. Naming Conventions

### Modules

Module names are atoms. Use lowercase with underscores to separate words. Erlang has a flat module namespace, so simulate hierarchy with prefixes.

```erlang
-module(sayableage_formatter).
-module(sayableage_internal).
-module(sayableage_locales_en).
```

Registered processes should share their module name. If module `db_server` starts a process, register it as `db_server`.

### Functions

Function names are atoms. Use lowercase with underscores. The name must describe exactly what the function does.

```erlang
parse_date(S) -> ...
is_leap_year(Y) -> ...
format_age_pure(Locale, Compactness, DOB, AsOf) -> ...
```

Use conventional prefixes to signal return types:

| Prefix | Returns | Example |
|---|---|---|
| `is_` | `true \| false` | `is_leap_year(Y)` |
| `validate_` | `{ok, ...} \| {error, ...}` | `validate_permissions(User)` |
| `get_` | Value or crashes | `get_locale(Code)` |
| `find_` | `{ok, Value} \| error` | `find_user(Id)` |

### Variables

Variables use CamelCase (also called UpperCamelCase). Do not separate words with underscores.

```erlang
%% Good
DiffDays = days_between(Date1, Date2),
BaseN = integer_to_list(Count),
ClampedBirthday = min(DD, LastDay).

%% Bad
Diff_days = days_between(Date1, Date2),
base_n = integer_to_list(Count).          % This is an atom, not a variable
```

For unused variables, prefer `_DescriptiveName` over bare `_`. This documents intent and aids future maintenance.

```erlang
%% Good: documents what is being ignored
format_tier(_Locale, _Day, _Week, _Month, _Year, _Half, _Delim, JustBorn, _Months, DiffDays)
    when DiffDays =:= 0 ->
    JustBorn;

%% Acceptable for truly anonymous matches
lists:map(fun({_, V}) -> V end, Pairs).
```

### Atoms

Atoms are lowercase with underscores. Avoid quoted atoms unless wrapping external strings (like HTTP methods).

```erlang
%% Good
normal, short, compact,
one, two, few, many, other,
{ok, Value}, error.

%% Acceptable when wrapping external names
'GET', 'POST', 'Content-Type'.

%% Bad: unnecessary quoting
'myAtom', 'MY_ATOM'.
```

### Macros

Macros use `ALL_UPPER_CASE`. Restrict macro use to constants and standard predefined macros (`?MODULE`, `?MODULE_STRING`, `?LINE`).

```erlang
-define(MAX_AGE_MONTHS, 6000).
-define(VERSION, "0.5.0").
-define(IP_VERSION, 4).
```

### Records

Record names use lowercase with underscores, matching the module that owns them. Fields use `snake_case`.

```erlang
-record(locale, {
    code      :: string(),
    plural    :: fun((non_neg_integer()) -> plural_category()),
    day       :: unit_forms(),
    week      :: unit_forms(),
    month     :: unit_forms(),
    year      :: unit_forms(),
    half      :: string(),
    delimiter :: string(),
    just_born :: string()
}).
```

---

## 2. Code Formatting

### Indentation

Use **4 spaces** for indentation. Never use tabs. This is the most common convention in the Erlang community (some projects use 2 spaces; pick one and be consistent).

### Line Length

Keep lines to a maximum of **100 characters**. Erlang's qualified module calls, record access syntax, and prefixed module names are verbose enough that 80 columns leads to excessive line breaks that hurt readability. 100 characters is a practical limit for modern displays and editors.

When long strings are unavoidable, break them with explicit concatenation:

```erlang
Message = "Name: " ++ Name ++ ", Age: " ++ integer_to_list(Age)
    ++ ", Phone: " ++ Phone.
```

Note: unlike C, Erlang does **not** automatically concatenate adjacent string literals. You must use `++` or iolists to join strings.

### Function Clauses

Separate function clauses of the same function with a semicolon. Place each clause on its own line. Use a period only after the last clause.

```erlang
days_in_month(_, M) when M =:= 1; M =:= 3; M =:= 5; M =:= 7;
                         M =:= 8; M =:= 10; M =:= 12 -> 31;
days_in_month(_, M) when M =:= 4; M =:= 6; M =:= 9; M =:= 11 -> 30;
days_in_month(Y, 2) ->
    case is_leap_year(Y) of
        true -> 29;
        false -> 28
    end;
days_in_month(_, _) -> 30.
```

For short clauses that fit on one line, keeping the arrow and body on the same line is fine:

```erlang
ovr_or(nothing, Default) -> Default;
ovr_or({just, Val}, _Default) -> Val.
```

For longer bodies, put the body on the next line, indented:

```erlang
format_age_pure(Locale, Compactness, DOB, AsOf) ->
    case sayableage_internal:compute_age(DOB, AsOf) of
        {ok, {Months, DiffDays}} when Months =< ?MAX_AGE_MONTHS ->
            {ok, format_tier(...)};
        _ -> error
    end.
```

### Case Expressions

Align `case` arms consistently. The `end` keyword aligns with `case`:

```erlang
case Compactness of
    normal  -> nothing;
    short   -> Locale#locale.short;
    compact -> Locale#locale.compact
end.
```

### Guard Formatting

For multiple guards on one clause, place them after `when`. Use commas for AND (all must pass), semicolons for OR (any may pass):

```erlang
%% AND: both conditions must hold
foo(X, Y) when X > 0, Y > 0 -> positive;

%% OR: either condition suffices
bar(X) when X =:= 0; X =:= 1 -> small;

%% Multi-line guards
format_tier(_Locale, _Day, _Week, _Month, _Year, _Half, _Delim, JustBorn,
            _Months, DiffDays) when DiffDays =:= 0 ->
    JustBorn.
```

### Nesting Depth

Limit code to a maximum of **three levels** of nesting. Deeply nested `case`/`if`/`receive` is a code smell. Extract nested logic into helper functions:

```erlang
%% Bad: deeply nested
process(Data) ->
    case validate(Data) of
        {ok, Valid} ->
            case transform(Valid) of
                {ok, Result} ->
                    case store(Result) of
                        ok -> {ok, done};
                        {error, R} -> {error, R}
                    end;
                {error, R} -> {error, R}
            end;
        {error, R} -> {error, R}
    end.

%% Good: flat pipeline with helper functions
process(Data) ->
    case validate(Data) of
        {ok, Valid}   -> transform_and_store(Valid);
        {error, R}    -> {error, R}
    end.

transform_and_store(Valid) ->
    case transform(Valid) of
        {ok, Result}  -> store(Result);
        {error, R}    -> {error, R}
    end.
```

### Comments

Use the standard comment convention with percent signs:

```erlang
%%% Module-level comments (three percent signs)

%% Function-level comments (two percent signs)
%% Explain the purpose, arguments, and return values.

some_code(),  % Inline comments (one percent sign)
```

Comments should explain **why**, not **what**. If a comment explains what code does, extract it into a named function instead.

---

## 3. Pattern Matching

### Function Clauses Over Case

Prefer pattern matching in function clause heads over `case` expressions when dispatching on arguments. Multiple clauses are more readable and extend more naturally.

```erlang
%% Good: pattern matching in clause heads
resolve_stage_label({neutral, S}, _Gender) -> S;
resolve_stage_label({gendered, _M, F}, female) -> F;
resolve_stage_label({gendered, M, _F}, _) -> M.

%% Avoid: unnecessary case expression
resolve_stage_label(Label, Gender) ->
    case Label of
        {neutral, S} -> S;
        {gendered, _M, F} when Gender =:= female -> F;
        {gendered, M, _F} -> M
    end.
```

### Guards

Guards restrict which clause matches. Only a restricted set of BIFs and expressions are allowed in guards (they must be side-effect free).

**Type test BIFs allowed in guards:**

`is_atom/1`, `is_binary/1`, `is_bitstring/1`, `is_boolean/1`, `is_float/1`, `is_function/1`, `is_function/2`, `is_integer/1`, `is_list/1`, `is_map/1`, `is_number/1`, `is_pid/1`, `is_port/1`, `is_record/2`, `is_record/3`, `is_reference/1`, `is_tuple/1`

**Other BIFs allowed in guards:**

`abs/1`, `bit_size/1`, `byte_size/1`, `element/2`, `float/1`, `hd/1`, `is_map_key/2`, `length/1`, `map_get/2`, `map_size/1`, `max/2`, `min/2`, `node/0`, `node/1`, `round/1`, `self/0`, `size/1`, `tl/1`, `trunc/1`, `tuple_size/1`

**Operators allowed in guards:**

- Comparison: `==`, `/=`, `=<`, `<`, `>=`, `>`, `=:=`, `=/=`
- Arithmetic: `+`, `-`, `*`, `/`, `div`, `rem`, `band`, `bor`, `bxor`, `bsl`, `bsr`
- Boolean: `not`, `and`, `or`, `xor`, `andalso`, `orelse`

Guard expressions that fail (e.g., `length(X)` when `X` is not a list) cause that guard to fail, not crash. The next clause is tried.

```erlang
stage_label(Months, Stages) when Months < 2   -> Stages#stages.newborn;
stage_label(Months, Stages) when Months < 12  -> Stages#stages.infant;
stage_label(Months, Stages) when Months < 36  -> Stages#stages.toddler;
stage_label(Months, Stages) when Months < 156 -> Stages#stages.child;
stage_label(Months, Stages) when Months < 216 -> Stages#stages.teenager;
stage_label(_Months, Stages) -> Stages#stages.adult.
```

### Record Patterns

Use record syntax in patterns rather than raw tuple matching. Record syntax survives field additions without breaking existing code.

```erlang
%% Good: uses record syntax
Day = Locale#locale.day,
Stages = Locale#locale.stages.

%% Bad: raw tuple matching (fragile, breaks when fields change)
{locale, _Code, _Plural, Day, _Week, _Month, _Year, _Half, _Delim, _JustBorn, Stages, _, _} = Locale.
```

### `if` vs. `case`

The `if` expression evaluates guard expressions only, with no pattern matching. Use `case` when you need to match on values. Use `if` when you have pure guard conditions and nothing to pattern-match against:

```erlang
%% Good use of if: pure guard conditions
Months = if
    RD < ClampedBirthday -> Months0 - 1;
    true -> Months0
end.

%% Use case when matching is involved
case Days > 0 of
    true  -> WStr ++ Delim ++ resolve_unit(Days, Day, Locale, "");
    false -> WStr
end.
```

### Maybe Expressions (OTP 25+)

The `maybe` expression (stabilized in OTP 27) provides a clean way to chain operations that may fail, eliminating the deeply-nested `case` pattern:

```erlang
%% Clean: sequential operations with early exit on failure
maybe
    {ok, Valid} ?= validate(Data),
    {ok, Result} ?= transform(Valid),
    {ok, _} ?= store(Result),
    {ok, done}
end.
```

The `?=` operator matches the right-hand side against the pattern on the left. If the match fails, the non-matching value is returned immediately from the `maybe` block. This replaces manual helper-function extraction for linear pipelines of fallible operations.

Note: requires OTP 25+ and the feature must be enabled. In OTP 27 it is enabled by default.

---

## 4. Module Design

### Module Attributes

Place module attributes in this order at the top of each file:

```erlang
-module(sayableage_formatter).        % 1. Module declaration
-behaviour(gen_server).               % 2. Behaviour (if applicable)
-include("sayableage.hrl").           % 3. Includes
-export([format_age_pure/4]).         % 4. Exports
-export_type([...]).                  % 5. Type exports

-define(MAX_AGE_MONTHS, 6000).        % 6. Macros

-type my_type() :: ...                % 7. Type definitions

-spec format_age_pure(...) -> ...     % 8. Specs (above each function)
```

### Exports

Export as few functions as possible. A module's exported functions define its public API. Group exports logically:

```erlang
%% Public API
-export([format_age/4, format_age_pure/4, format_stage/4, format_stage_pure/4, get_locale/1]).

%% For OTP callbacks (if using a behaviour)
-export([init/1, handle_call/3, handle_cast/2, terminate/2]).

%% For testing only (use -ifdef(TEST))
-ifdef(TEST).
-export([internal_helper/1]).
-endif.
```

### Type Specifications

Write `-spec` declarations for **all exported functions**. Place the spec immediately above the function it describes:

```erlang
-spec format_age_pure(#locale{}, compactness(), string(), string()) -> {ok, string()} | error.
format_age_pure(_Locale, _Compactness, [], _AsOf) -> error;
format_age_pure(Locale, Compactness, DOB, AsOf) ->
    ...
```

Define custom types for domain concepts:

```erlang
-type plural_category() :: zero | one | two | few | many | other.
-type compactness() :: normal | short | compact.
-type gender() :: male | female.
-type unit_forms() :: {simple, string()} | {pluralized, [{plural_category(), string()}]}.
-type stage_label() :: {neutral, string()} | {gendered, string(), string()}.
```

Use `-callback` for behaviour specifications instead of the older `behaviour_info/1`:

```erlang
-callback init(Args :: term()) ->
    {ok, State :: term()} | {stop, Reason :: term()}.
```

### Header Files (.hrl)

Use header files for:
- Record definitions shared across modules
- Type definitions shared across modules
- Macro constants shared across modules

Do **not** put function definitions in header files. Always use include guards:

```erlang
-ifndef(SAYABLEAGE_HRL).
-define(SAYABLEAGE_HRL, true).

-type plural_category() :: zero | one | two | few | many | other.

-record(locale, {
    code      :: string(),
    plural    :: fun((non_neg_integer()) -> plural_category()),
    day       :: unit_forms(),
    ...
}).

-endif.
```

If a record is used by only one module, define it in that module, not in a header file.

### Module Size

Aim to keep modules under **600 lines** of source code. This is a guideline, not a hard rule. The real measure is cohesion: if every function in the module serves the same responsibility, a larger module is preferable to artificially splitting related logic across multiple modules. If a module grows large and has multiple distinct responsibilities, split it.

### Function Size

Keep functions under **15-20 lines**. Long functions indicate missing abstractions. Split into smaller, well-named helpers.

### Avoid `-import`

Do not use `-import`. It hides where a function is defined, making code harder to read and preventing cross-reference tools from working:

```erlang
%% Bad: where does keyfind come from?
-import(lists, [keyfind/3]).
keyfind(Cat, 1, Forms).

%% Good: explicit module reference
lists:keyfind(Cat, 1, Forms).
```

---

## 5. Data Structures

### When to Use What

| Structure | Use when... |
|---|---|
| Tuples | Fixed-size, positional data; tagged return values (`{ok, Val}`, `{error, Reason}`) |
| Lists | Ordered collections; variable length; processed head-to-tail |
| Records | Structured data with named fields known at compile time; process state |
| Maps | Dynamic key-value data; keys unknown at compile time; data crossing module boundaries |
| Binaries | Raw byte data; strings (prefer binaries over lists for large text) |
| Proplists | Simple configuration; option lists passed to functions |

### Strings: Lists vs. Binaries

Erlang has two string representations. Pick one convention per project for internal APIs and be consistent.

**List strings** (`"hello"` = `[104,101,108,108,111]`): The traditional Erlang representation. Easy to pattern match and manipulate with list operations. Each character consumes one word (8 bytes on 64-bit), so they are expensive for large text.

**Binary strings** (`<<"hello">>` = `<<104,101,108,108,111>>`): More memory-efficient for large text. Used by most modern libraries (Cowboy, jsx, etc.). Pattern matching uses bit syntax.

**Iolists** (nested lists of integers, binaries, and other iolists): Most I/O functions accept iolists, so you often do not need to convert between representations. Prefer building iolists over repeated string concatenation.

```erlang
%% Iolist: no conversion needed, efficient
IoList = [<<"Name: ">>, Name, <<", Age: ">>, integer_to_list(Age)].
file:write(Fd, IoList).
```

### Records

Records are the primary data structure for structured state. Always annotate record fields with types:

```erlang
-record(stages, {
    newborn  :: stage_label(),
    infant   :: stage_label(),
    toddler  :: stage_label(),
    child    :: stage_label(),
    teenager :: stage_label(),
    adult    :: stage_label()
}).
```

Access fields using record syntax, never by raw tuple position:

```erlang
%% Good
Name = Person#person.name.

%% Bad: fragile, position-dependent
{person, Name, _Age, _Phone, _Dict} = Person.
```

### Tagged Tuples

Always tag return values. Untagged values lead to ambiguity.

```erlang
%% Good: tagged
{ok, Value}
{error, not_found}
{value, X}

%% Bad: ambiguous bare values
Value     % Is false a valid value or an error?
not_found % Is this a return value or an error?
```

The standard return conventions are:

```erlang
{ok, Result}            % Success with data
ok                      % Success without data
error                   % Failure without detail
{error, Reason}         % Failure with reason
{ok, Result} | error    % Common pattern for lookups
```

### Maps

Maps are useful for dynamic data structures and for crossing module boundaries. Use the `=>` operator for creating maps and `:=` for updating (which ensures the key already exists):

```erlang
%% Create
Config = #{timeout => 5000, retries => 3}.

%% Update (key must exist)
Config2 = Config#{timeout := 10000}.

%% Pattern match
#{timeout := T, retries := R} = Config.
```

### Optional Values

The standard Erlang idiom for optional values is `undefined | Value`:

```erlang
-record(config, {
    timeout  :: pos_integer() | undefined,
    retries  :: non_neg_integer() | undefined
}).

%% Pattern match to extract
case Config#config.timeout of
    undefined -> DefaultTimeout;
    Val       -> Val
end.
```

This aligns with OTP conventions and the default value of uninitialized record fields.

**Project convention:** This codebase uses `nothing | {just, Value}` for optional values to distinguish "not set" from potentially valid falsy values. This departs from standard Erlang idiom but is consistent across the project:

```erlang
-type optional(T) :: nothing | {just, T}.

case Config#config.timeout of
    nothing     -> DefaultTimeout;
    {just, Val} -> Val
end.
```

### Lists vs. Iolists

When building strings for output, prefer iolists over string concatenation. Iolists are nested lists of integers and binaries that are flattened lazily by I/O functions:

```erlang
%% Efficient: no intermediate copies
IoList = ["Name: ", Name, ", Age: ", integer_to_list(Age)].
io:format("~s~n", [IoList]).

%% Inefficient: copies on every ++
String = "Name: " ++ Name ++ ", Age: " ++ integer_to_list(Age).
```

---

## 6. Error Handling

### Let It Crash

The core Erlang philosophy: **program the normal case and let abnormal cases crash**. Do not clutter normal-case code with defensive error handling. Instead, rely on supervisors to restart failed processes.

```erlang
%% Good: program the normal case
process_order(Order) ->
    Items = validate_items(Order#order.items),
    Total = calculate_total(Items),
    submit(Order#order.customer, Items, Total).

%% Bad: defensive programming obscuring the normal case
process_order(Order) ->
    case Order of
        undefined -> {error, no_order};
        _ ->
            case validate_items(Order#order.items) of
                {error, R} -> {error, R};
                {ok, Items} ->
                    case calculate_total(Items) of
                        {error, R} -> {error, R};
                        {ok, Total} ->
                            submit(...)
                    end
            end
    end.
```

### Error Tuples for Expected Failures

When a function has an expected failure mode (like a lookup that may not find its key), return tagged error tuples. Do not throw exceptions for expected conditions.

```erlang
-spec get_locale(string()) -> {ok, #locale{}} | error.
get_locale("en") -> {ok, en_locale()};
get_locale("fr") -> {ok, fr_locale()};
get_locale(_)    -> error.
```

### Try/Catch for Boundaries

Use `try/catch` only at system boundaries where you handle untrusted external input. Do not use it for normal control flow.

```erlang
%% Good: boundary validation
parse_config(RawInput) ->
    try
        Json = jsx:decode(RawInput),
        validate_schema(Json)
    catch
        error:badarg -> {error, invalid_json};
        throw:{schema_error, Reason} -> {error, Reason}
    end.
```

The three exception classes and when to use each:

| Class | Raised by | Use for |
|---|---|---|
| `error` | `erlang:error(Reason)` | Programming errors; unrecoverable situations |
| `exit` | `exit(Reason)` | Process termination signals |
| `throw` | `throw(Value)` | Non-local returns expected to be caught by caller |

### Don't Catch Everything

Catch specific exception types. Avoid `_:_` catch-all unless you are a top-level error boundary:

```erlang
%% Good: specific
catch
    error:badarg -> handle_bad_arg();
    throw:not_found -> handle_missing()

%% Bad: swallows everything
catch
    _:_ -> {error, unknown}
```

### Validate at the Boundary

Validate data when it enters the system (from external sources, user input, network). Internal functions should trust their callers and crash on bad input rather than re-validating everywhere.

---

## 7. OTP Patterns

### gen_server

The `gen_server` behaviour encapsulates stateful processes. Key conventions:

```erlang
-module(my_server).
-behaviour(gen_server).

%% Public API
-export([start_link/0, get_value/1, set_value/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-record(state, {
    values :: map()
}).

%% --- Public API ---

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

get_value(Key) ->
    gen_server:call(?MODULE, {get_value, Key}).

set_value(Key, Value) ->
    gen_server:cast(?MODULE, {set_value, Key, Value}).

%% --- Callbacks ---

init([]) ->
    {ok, #state{values = #{}}}.

handle_call({get_value, Key}, _From, State) ->
    Reply = maps:get(Key, State#state.values, undefined),
    {reply, Reply, State};
handle_call(_Request, _From, State) ->
    {reply, {error, unknown_request}, State}.

handle_cast({set_value, Key, Value}, State) ->
    NewValues = maps:put(Key, Value, State#state.values),
    {noreply, State#state{values = NewValues}};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    logger:debug("Unexpected message: ~p", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.
```

Key principles:

- **Always wrap message passing in API functions.** Callers should never send raw messages to a gen_server.
- **Name the state record** `state` or `#mod_state{}`.
- **Define `-type state() :: #state{}`** for Dialyzer.
- **Handle unknown messages** in `handle_call`, `handle_cast`, and `handle_info` to prevent mailbox accumulation. Log unexpected messages in `handle_info` at `debug` level to aid troubleshooting without creating noise in production.
- **Use `start_link`** (not `start`) when the process will be supervised.

### Supervisors

```erlang
-module(my_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        strategy  => one_for_one,
        intensity => 5,
        period    => 10
    },
    Children = [
        #{id       => my_worker,
          start    => {my_worker, start_link, []},
          restart  => permanent,
          shutdown => 5000,
          type     => worker}
    ],
    {ok, {SupFlags, Children}}.
```

Restart strategies:

| Strategy | Behavior |
|---|---|
| `one_for_one` | Restart only the failed child |
| `one_for_all` | Restart all children if one fails |
| `rest_for_one` | Restart the failed child and all children started after it |
| `simple_one_for_one` | Dynamic children with the same specification |

### Application

Every OTP application has an application resource file (`.app.src`) and an application callback module:

```erlang
%% src/my_app.app.src
{application, my_app, [
    {description, "My application"},
    {vsn, "1.0.0"},
    {modules, []},
    {registered, []},
    {applications, [kernel, stdlib]},
    {mod, {my_app, []}}
]}.
```

### Behaviours

When creating custom behaviours, use `-callback` attributes:

```erlang
-module(my_behaviour).

-callback init(Args :: term()) -> {ok, State :: term()}.
-callback handle(Request :: term(), State :: term()) ->
    {reply, Reply :: term(), NewState :: term()}.
```

---

## 8. Functional Patterns

### List Comprehensions

Prefer list comprehensions for simple mapping and filtering over manual recursion:

```erlang
%% List comprehension
Evens = [X || X <- List, X rem 2 =:= 0].
Doubled = [X * 2 || X <- List].
Pairs = [{X, Y} || X <- Xs, Y <- Ys, X =/= Y].

%% Map comprehension (OTP 26+)
Squares = #{X => X * X || X <- [1, 2, 3]}.
```

### Higher-Order Functions

Prefer `lists:map/2`, `lists:filter/2`, `lists:foldl/3`, `lists:foldr/3`, and `lists:foreach/2` over hand-written recursion for standard operations:

```erlang
%% Good: intent is clear
Names = lists:map(fun(#person{name = N}) -> N end, People),
Adults = lists:filter(fun(#person{age = A}) -> A >= 18 end, People),
Total = lists:foldl(fun(X, Acc) -> X + Acc end, 0, Amounts).

%% Less clear: hand-written recursion for the same
get_names([#person{name = N} | Rest]) -> [N | get_names(Rest)];
get_names([]) -> [].
```

### Tail Recursion

Tail recursion is **critical for server loops** (processes that run indefinitely). A non-tail-recursive server loop will consume memory until the system crashes.

```erlang
%% Correct: tail-recursive loop
loop(State) ->
    receive
        {msg, Data} ->
            NewState = handle(Data, State),
            loop(NewState);          % Tail call
        stop ->
            ok
    end.

%% WRONG: not tail-recursive (code after receive)
loop(State) ->
    receive
        {msg, Data} ->
            NewState = handle(Data, State),
            loop(NewState)
    end,
    cleanup().   % This prevents tail-call optimization
```

For list-processing functions, the performance difference between body recursion and tail recursion with `lists:reverse/1` is negligible in modern Erlang. Prioritize readability:

```erlang
%% Body-recursive: reads naturally
map_fn(_F, []) -> [];
map_fn(F, [H | T]) -> [F(H) | map_fn(F, T)].

%% Tail-recursive with accumulator: use for non-list-producing functions
sum(List) -> sum(List, 0).
sum([], Acc) -> Acc;
sum([H | T], Acc) -> sum(T, Acc + H).
```

### Building Lists Efficiently

Always prepend to lists (`[H | Acc]`) and reverse at the end. Never append with `++` in a loop:

```erlang
%% Good: prepend + reverse
collect(List) -> collect(List, []).
collect([], Acc) -> lists:reverse(Acc);
collect([H | T], Acc) -> collect(T, [transform(H) | Acc]).

%% Bad: O(n^2) from repeated appending
collect([]) -> [];
collect([H | T]) -> collect(T) ++ [transform(H)].
```

### Folds

Use `lists:foldl/3` when accumulating a result from left to right. Use `lists:foldr/3` when order matters and right-to-left processing is needed (foldr is not tail-recursive).

```erlang
%% Sum with foldl
Total = lists:foldl(fun(X, Acc) -> X + Acc end, 0, Numbers).

%% Build a map from a list
Index = lists:foldl(
    fun({K, V}, Acc) -> maps:put(K, V, Acc) end,
    #{},
    Pairs
).
```

---

## 9. Common Idioms

### Tagged Tuples

The foundation of Erlang APIs. Use atoms as the first element to identify the tuple's purpose:

```erlang
{ok, Value}
{error, Reason}
{reply, Reply, NewState}
{noreply, NewState}
{stop, Reason, State}
{signal, What, From, To}
```

### Guard Expressions

Use guards for lightweight conditional dispatch:

```erlang
classify(N) when N < 0  -> negative;
classify(0)             -> zero;
classify(N) when N > 0  -> positive.

abs_value(N) when N < 0 -> -N;
abs_value(N)            -> N.
```

Combine guards with semicolons (OR) and commas (AND):

```erlang
%% OR: either guard succeeds
is_small(X) when X =:= 0; X =:= 1 -> true;
is_small(_) -> false.

%% AND: both guards must succeed
in_range(X, Lo, Hi) when X >= Lo, X =< Hi -> true;
in_range(_, _, _) -> false.
```

### Binary Matching

Erlang's bit syntax enables declarative binary parsing:

```erlang
%% Parse a 4-byte header
parse_header(<<Version:8, Type:8, Length:16, Payload/binary>>) ->
    {Version, Type, Length, Payload}.

%% UTF-8 string matching
<<Char/utf8, Rest/binary>> = <<"hello"/utf8>>.

%% Variable-length fields
parse_message(<<Len:16, Body:Len/binary, Rest/binary>>) ->
    {Body, Rest}.
```

### Message Tagging

Always tag inter-process messages. Untagged messages create conflicts and make receive clauses fragile:

```erlang
%% Good: tagged messages
Server ! {request, self(), {get, Key}},
receive
    {response, {ok, Value}} -> Value;
    {response, {error, Reason}} -> handle_error(Reason)
end.

%% Bad: untagged
Server ! Key,
receive
    Value -> Value
end.
```

### Interface Functions

Encapsulate message passing in exported functions. Callers should never construct and send raw messages:

```erlang
%% Good: function API
-export([get/2]).

get(Server, Key) ->
    Server ! {get_request, self(), Key},
    receive
        {get_response, Result} -> Result
    after 5000 ->
        {error, timeout}
    end.

%% Bad: exposing message protocol
%% (Callers send raw messages and know the protocol)
```

### Keyfind for Tagged Lists

Use `lists:keyfind/3` to look up values in lists of tagged tuples:

```erlang
lookup_unit_form(Cat, Forms) ->
    case lists:keyfind(Cat, 1, Forms) of
        {Cat, S} -> S;
        false ->
            case lists:keyfind(other, 1, Forms) of
                {other, S} -> S;
                false -> ""
            end
    end.
```

---

## 10. Things to Avoid

### Process Dictionary

Avoid direct use of `put/2`, `get/1`, and `erase/1` in application code. The process dictionary makes functions impure: the same arguments produce different results depending on hidden state. It breaks referential transparency, makes testing difficult, and makes code unpredictable.

```erlang
%% Don't do this in application code
put(device, Handle),
tokenize(Input).  % Secretly reads from process dictionary

%% Instead: pass state explicitly
tokenize(Handle, Input).
```

Note: some OTP modules use the process dictionary internally (e.g., `rand` for seed state, `logger` for process metadata). This is acceptable -- the prohibition is on application-level code storing its own state in the process dictionary.

### Catch-All Clauses That Hide Bugs

A catch-all clause should log or crash, never silently succeed. Swallowing unknown patterns hides bugs:

```erlang
%% Bad: silently ignores new message types
handle_cast(Msg, State) ->
    {noreply, State}.

%% Good: logs unexpected messages
handle_cast(Msg, State) ->
    logger:warning("Unexpected cast: ~p", [Msg]),
    {noreply, State}.
```

For `handle_info`, where unexpected messages are more common in practice (late replies, monitor notifications), logging at `debug` level is appropriate to avoid noise in production logs.

### Deep Nesting

Never nest `case`/`if`/`receive` more than three levels deep. Extract into helper functions or use `maybe` expressions (OTP 25+):

```erlang
%% Bad: three levels of nesting
do_thing(X) ->
    case foo(X) of
        {ok, A} ->
            case bar(A) of
                {ok, B} ->
                    case baz(B) of  % Too deep
                        ...
```

### Catch and Throw for Control Flow

Do not use `throw/catch` for normal control flow. Reserve them for genuine error handling at boundaries. Use pattern matching and return values instead.

### Mutable State Tricks

Avoid using ETS tables or process dictionaries as mutable global state. Pass state explicitly through function arguments and return values.

### Dynamic Function Calls

Avoid `apply(Mod, Fun, Args)` and `Mod:Fun(Args)` with variable module/function names unless absolutely necessary. Dynamic calls prevent xref from tracking dependencies and make code harder to analyze statically.

### Copy-Paste Code

Extract duplicate logic into shared functions. If two functions have the same structure with different details, parameterize the shared structure.

### Boolean Parameters

Avoid boolean parameters that change function behavior. Use separate functions or descriptive atoms:

```erlang
%% Bad: what does 'true' mean?
process(Data, true).

%% Good: self-documenting
process_with_validation(Data).
process_without_validation(Data).

%% Also good: named atom
process(Data, validated).
process(Data, raw).
```

### Unnecessary `lists:flatten/1`

`lists:flatten/1` builds an entirely new list. Avoid it when:

- Sending data to ports (they accept deep lists natively)
- Calling BIFs that accept iolists (`list_to_binary/1`, `iolist_to_binary/1`)
- Lists are only one level deep (use `lists:append/1` instead)

---

## 11. Tooling

### Compiler Warnings

Always compile with warnings enabled and treat warnings as errors in CI. Key flags:

```erlang
%% In rebar.config
{erl_opts, [
    debug_info,
    warnings_as_errors,
    warn_unused_vars,
    warn_unused_import,
    warn_shadow_vars,
    warn_obsolete_guard
]}.
```

Zero warnings should be the standard. If you must suppress a warning, document why.

### Dialyzer

[Dialyzer](https://www.erlang.org/doc/apps/dialyzer/dialyzer_chapter) is a static analysis tool that finds type inconsistencies, unreachable code, and unnecessary tests. It uses "success typing," which gives it a very low false-positive rate -- when Dialyzer reports an issue, it is almost always a genuine problem.

**Setup:**

```bash
# Build the PLT (Persistent Lookup Table) -- do this once
dialyzer --build_plt --apps erts kernel stdlib

# Run analysis
dialyzer -r src/ --src

# Or via rebar3
rebar3 dialyzer
```

**Best practices:**

- Write `-spec` for all exported functions. Dialyzer uses them to find contract violations.
- Define custom `-type` declarations for domain concepts.
- Use `-opaque` types to hide internal representation from other modules.
- Export types with `-export_type([my_type/0]).`
- When Dialyzer complains about your spec, the spec is almost always wrong -- not Dialyzer. Start by re-examining the spec before assuming a tool bug.
- Annotate record fields with types.

### Elvis

[Elvis](https://github.com/inaka/elvis) is a style linter for Erlang. Configure it with an `elvis.config` file:

```erlang
[{elvis, [
    {config, [
        #{dirs => ["src"],
          filter => "*.erl",
          rules => [
              {elvis_style, line_length, #{limit => 100}},
              {elvis_style, no_tabs},
              {elvis_style, macro_names},
              {elvis_style, operator_spaces, #{rules => [{right, ","}, {right, "++"}, {left, "++"}]}},
              {elvis_style, nesting_level, #{level => 3}},
              {elvis_style, function_naming_convention, #{regex => "^[a-z]([a-z0-9]*_?)*$"}},
              {elvis_style, variable_naming_convention, #{regex => "^_?[A-Z][a-zA-Z0-9]*$"}}
          ]}
    ]}
]}].
```

### EUnit

[EUnit](https://www.erlang.org/doc/apps/eunit/chapter.html) is the standard unit testing framework. Key conventions:

```erlang
-module(my_module_test).
-include_lib("eunit/include/eunit.hrl").

%% Test generators: function names ending in _test_ return lists of tests
basic_test_() ->
    [?_assertEqual(expected, actual),
     ?_assertMatch({ok, _}, some_function()),
     ?_assertError(badarg, bad_function())].

%% Simple tests: function names ending in _test
smoke_test() ->
    ?assertEqual(42, compute()).
```

Best practices:

- **Each test should verify one behavior.** Multiple assertions are fine when they collectively verify a single logical behavior or share necessary setup.
- **Name tests descriptively.** Use `_test_()` generators with descriptive function names.
- **Use `?_assertEqual`** (with underscore prefix) inside test generators for lazy evaluation.
- **Use `?assertEqual`** (without underscore) inside simple `_test` functions.
- Helpers go at the top of the test module.

### Common Test

[Common Test](https://www.erlang.org/doc/apps/common_test/introduction.html) is for integration and system testing. It provides test suites, setup/teardown, configuration, and distributed testing. Use Common Test when:

- Tests need setup and teardown across groups
- Tests interact with external systems
- You need test sequencing or distributed testing

Use EUnit for unit tests and Common Test for integration tests.

### Xref

Xref (cross-reference) analyzes module dependencies and finds undefined function calls, unused exports, and deprecated functions:

```bash
rebar3 xref
```

### Rebar3

[Rebar3](https://rebar3.org/) is the standard build tool. Key commands:

```bash
rebar3 compile          # Compile
rebar3 eunit            # Run EUnit tests
rebar3 ct               # Run Common Test suites
rebar3 dialyzer         # Run Dialyzer
rebar3 xref             # Cross-reference analysis
rebar3 as test shell    # Interactive shell with test profile
```

---

## Quick Reference Checklist

For auditing an Erlang implementation, verify:

- [ ] Module names are lowercase with underscores
- [ ] Function names are lowercase with underscores; names describe behavior
- [ ] Variables use CamelCase, unused variables use `_CamelCase`
- [ ] Macros use `ALL_UPPER_CASE`, restricted to constants
- [ ] `-spec` on all exported functions
- [ ] Types defined with `-type` for domain concepts
- [ ] Record fields annotated with types
- [ ] Header files have include guards (`-ifndef`/`-define`/`-endif`)
- [ ] No `-import` directives; all calls are fully qualified
- [ ] Pattern matching in function clauses preferred over `case`
- [ ] `if` used only for pure guard conditions, `case` used when matching values
- [ ] Nesting depth at most three levels
- [ ] Functions under 20 lines
- [ ] No direct process dictionary usage (`put`/`get`/`erase`) in application code
- [ ] Tagged tuples for return values (`{ok, V}`, `{error, R}`)
- [ ] Tail-recursive server loops
- [ ] Lists built by prepending, reversed at end
- [ ] No `lists:flatten/1` where iolists or `lists:append/1` suffice
- [ ] Messages are tagged tuples, wrapped in interface functions
- [ ] Unknown messages in `handle_info` are logged, not silently dropped
- [ ] `warnings_as_errors` in compiler options
- [ ] Dialyzer runs clean
- [ ] Tests verify one behavior each, with descriptive names
- [ ] No dynamic `apply` calls without justification
- [ ] No boolean parameters; use descriptive atoms or separate functions
- [ ] Comments explain "why", not "what"

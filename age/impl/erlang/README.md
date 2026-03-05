# sayable-age — Erlang

Human-friendly age formatting — how parents actually talk about little ones.

```erlang
{ok, Age} = sayableage_formatter:format_age_pure(
    sayableage_locales:en(), normal, "2025-06-01", "2025-06-15"),
io:format("~s~n", [Age]).  % "2 weeks"
```

## Setup

Rebar3 project. Not published to Hex — use as a local dependency.

```bash
cd src/erlang
rebar3 compile
```

Requires OTP 26+. Zero external dependencies.

## Usage

```erlang
Locale = sayableage_locales:en(),

{ok, Age} = sayableage_formatter:format_age_pure(Locale, normal, "2025-01-15", "2025-07-15"),
io:format("~s~n", [Age]),  % "6 months"

{ok, Stage} = sayableage_formatter:format_stage_pure(Locale, "2025-01-15", "2025-06-15", undefined),
io:format("~s~n", [Stage]).  % "Infant"
```

## Internationalization

```erlang
Ja = sayableage_locales:ja(),
{ok, Age} = sayableage_formatter:format_age_pure(Ja, normal, "2025-01-01", "2025-07-15"),
io:format("~s~n", [Age]).  % "6ヶ月"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```erlang
-spec format_age_pure(#locale{}, compactness(), string(), string()) -> {ok, string()} | error.
-spec format_stage_pure(#locale{}, string(), string(), gender() | undefined) -> {ok, string()} | error.
```

**Parameters:**

- `Locale` — A locale record from `sayableage_locales`.
- `Compactness` — `normal`, `short`, or `compact`.
- `DOB` — `"YYYY-MM-DD"` string. Returns `error` for empty strings.
- `AsOf` — Reference date (`"YYYY-MM-DD"`).

**Returns:** `{ok, string()}` on success, `error` on invalid input or future dates.

## Development

```bash
rebar3 eunit    # Run tests
```

## License

[MIT](../../LICENSE.md)

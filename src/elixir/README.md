# parent-time — Elixir

A thoughtful time formatting library that reflects how we think about little ones.

```elixir
{:ok, age} = ParentTime.format_age(
  ParentTime.Locales.EN.locale(), :normal, "2025-06-01", "2025-06-15")
IO.puts(age)  # "2 weeks"
```

## Setup

Mix project. Not published to Hex — use as a local dependency.

```bash
cd src/elixir
mix compile
```

Requires Elixir 1.14+ / OTP 26+. Zero external dependencies.

## Usage

```elixir
locale = ParentTime.Locales.EN.locale()

{:ok, age} = ParentTime.format_age(locale, :normal, "2025-01-15", "2025-07-15")
IO.puts(age)  # "6 months"

{:ok, stage} = ParentTime.format_stage(locale, "2025-01-15", "2025-06-15", nil)
IO.puts(stage)  # "Infant"
```

## Internationalization

```elixir
{:ok, locale} = ParentTime.get_locale("ja")
{:ok, age} = ParentTime.format_age(locale, :normal, "2025-01-01", "2025-07-15")
IO.puts(age)  # "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```elixir
@spec ParentTime.format_age(map(), :normal | :short | :compact, String.t(), String.t()) ::
        {:ok, String.t()} | :error

@spec ParentTime.format_stage(map(), String.t(), String.t(), :male | :female | nil) ::
        {:ok, String.t()} | :error

@spec ParentTime.get_locale(String.t()) :: {:ok, map()} | :error
```

**Parameters:**

- `locale` — A locale map from `ParentTime.Locales`.
- `compactness` — `:normal`, `:short`, or `:compact`.
- `dob` — `"YYYY-MM-DD"` string. Returns `:error` for empty strings.
- `as_of` — Reference date (`"YYYY-MM-DD"`).

**Returns:** `{:ok, string}` on success, `:error` on invalid input or future dates.

## Development

```bash
mix test    # Run tests
```

## License

[MIT](../../LICENSE.md)

# sayable-age — Prolog

Human-friendly age formatting — how parents actually talk about little ones.

```prolog
:- use_module('sayableage').
?- format_age(en, '2025-06-01', '2025-06-15', Age).
Age = '2 weeks'.
```

## Installation

Copy the Prolog source files into your project. Requires SWI-Prolog 8.0+. Zero external dependencies.

## Usage

```prolog
:- use_module('sayableage').

% Human-readable age string
?- format_age(en, '2025-06-15', '2025-06-15', Age).
Age = 'Newborn'.

?- format_age(en, '2025-06-01', '2025-06-15', Age).
Age = '2 weeks'.

?- format_age(en, '2025-01-15', '2025-07-15', Age).
Age = '6 months'.

?- format_age(en, '2022-06-15', '2025-12-15', Age).
Age = '3½ years'.

% Developmental stage label
?- format_stage(en, '2025-06-15', '2025-06-15', '', Stage).
Stage = 'Newborn'.

?- format_stage(en, '2025-01-15', '2025-06-15', '', Stage).
Stage = 'Infant'.

% Fails for invalid/future dates or ages exceeding 500 years
?- format_age(en, '', '2025-06-15', Age).
false.
```

## Internationalization

```prolog
?- format_age(ja, '2025-01-01', '2025-07-15', Age).
Age = '6ヶ月'.
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```prolog
?- format_age(en, '2025-01-15', '2025-07-15', normal, Age).
Age = '6 months'.

?- format_age(en, '2025-01-15', '2025-07-15', short, Age).
Age = '6 mo'.

?- format_age(en, '2025-01-15', '2025-07-15', compact, Age).
Age = '6m'.
```

## API

```prolog
format_age(+Code, +Dob, +AsOf, -Result)
format_age(+Code, +Dob, +AsOf, +Compactness, -Result)
format_stage(+Code, +Dob, +AsOf, +Gender, -Result)
get_locale(+Code)
version(-Version)
```

**Parameters:**

- `Code` — Locale code atom (e.g., `en`, `es`, `ja`).
- `Dob` — `YYYY-MM-DD` atom.
- `AsOf` — Reference date as `YYYY-MM-DD` atom.
- `Gender` — `m` or `f` for gendered stage labels, empty string for default.
- `Compactness` — `normal`, `short`, or `compact`.

**Returns:** Unifies `Result` with the formatted string. Fails if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
swipl -g run_tests -t halt test_format_age.pl
```

## License

[MIT](../../LICENSE.md)

# sayable-age — Octave

Human-friendly age formatting — how parents actually talk about little ones.

```octave
format_age('2025-06-01', '2025-06-15')
% ans = 2 weeks
```

## Setup

Plain Octave/MATLAB functions. Not published to any package manager — use as a local dependency.

```bash
cd age/impl/octave
```

Requires GNU Octave >= 6.0. Zero external dependencies.

## Usage

```octave
format_age('2025-01-15', '2025-07-15')
% ans = 6 months

format_stage('2025-01-15', '2025-06-15')
% ans = Infant
```

## Internationalization

```octave
addpath('locales');
ja = locale_ja();
sa = sayable_age_new(ja);
sa.format_age('2025-01-01', '2025-07-15')
% ans = 6ヶ月
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### Module-level functions (English locale)

```octave
format_age(date_of_birth, as_of)           % -> string or []
format_stage(date_of_birth, as_of, gender)  % -> string or []
get_locale(code)                            % -> locale struct or []
```

### Constructor

```octave
sa = sayable_age_new(locale, compactness);
sa.format_age(date_of_birth, as_of)            % -> string or []
sa.format_stage(date_of_birth, as_of, gender)  % -> string or []
```

**Parameters:**

- `locale` — A locale struct (e.g., `locale_en()`).
- `compactness` — `'normal'`, `'short'`, or `'compact'` (default: `'normal'`).
- `date_of_birth` — `'YYYY-MM-DD'` string. Returns `[]` for empty strings.
- `as_of` — Reference date (`'YYYY-MM-DD'`). Defaults to today if omitted.
- `gender` — `'m'` or `'f'` for gendered locales (optional, defaults to masculine/neutral).

**Returns:** Formatted string, or `[]` on invalid input.

## Development

```bash
octave --no-gui --path . test_format_age.m    # Run tests
```

## License

[MIT](../../LICENSE.md)

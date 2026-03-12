# sayable-age -- Bash

Human-friendly age formatting -- how parents actually talk about little ones.

```bash
source sayableage.sh

sayableage_format_age "en" "2025-06-01" "2025-06-15"
# "2 weeks"
```

## Setup

Source the script directly. Not published to any registry -- use as a local dependency.

```bash
cd age/impl/bash
```

Requires Bash >= 4.0. Zero external dependencies.

## Usage

```bash
source sayableage.sh

# Format age with English locale
sayableage_format_age "en" "2025-01-15" "2025-07-15"
# "6 months"

# Format developmental stage
sayableage_format_stage "en" "2025-01-15" "2025-06-15"
# "Infant"
```

## Internationalization

```bash
source sayableage.sh

sayableage_format_age "ja" "2025-01-01" "2025-07-15"
# "6ヶ月"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### format_age

```bash
sayableage_format_age locale_code date_of_birth [as_of] [compactness]
```

### format_stage

```bash
sayableage_format_stage locale_code date_of_birth [as_of] [gender]
```

### get_locale

```bash
sayableage_get_locale code    # returns 0 if found, 1 if not
```

**Parameters:**

- `locale_code` -- Locale code string (e.g., `"en"`, `"es"`, `"ja"`).
- `date_of_birth` -- `"YYYY-MM-DD"` string. Returns empty string for empty/invalid input.
- `as_of` -- Reference date (`"YYYY-MM-DD"`). Defaults to today if omitted or empty.
- `compactness` -- `"normal"`, `"short"`, or `"compact"` (default: `"normal"`).
- `gender` -- `"m"` or `"f"` for gendered locales (optional, defaults to masculine/neutral).

**Returns:** Formatted string via stdout, or empty string on invalid input.

## Development

```bash
bash test_format_age.sh    # Run tests
```

## License

[MIT](../../LICENSE.md)

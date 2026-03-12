# sayable-age — D

Human-friendly age formatting — how parents actually talk about little ones.

```d
import sayableage.format_age;
import sayableage.locales;

auto age = formatAge(EN, "2025-06-01", "2025-06-15");
writeln(age.get);  // "2 weeks"
```

## Installation

Add the source files to your D project. Requires LDC or DMD. Zero external dependencies.

## Usage

```d
import sayableage.format_age;
import sayableage.locales;

// Human-readable age string
auto age = formatAge(EN, "2025-06-15", "2025-06-15");
writeln(age.get);  // "Newborn"

auto months = formatAge(EN, "2025-01-15", "2025-07-15");
writeln(months.get);  // "6 months"

auto half = formatAge(EN, "2022-06-15", "2025-12-15");
writeln(half.get);  // "3½ years"

// Developmental stage label
auto stage = formatStage(EN, "2025-06-15", "2025-06-15");
writeln(stage.get);  // "Newborn"

// Returns null for invalid/future dates or ages exceeding 500 years
auto result = formatAge(EN, "", "2025-06-15");
assert(result.isNull);
```

## Internationalization

```d
auto ja = getLocale("ja");
auto age = formatAge(*ja, "2025-01-01", "2025-07-15");
writeln(age.get);  // "6ヶ月"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```d
formatAge(EN, "2025-01-15", "2025-07-15");                    // "6 months"
formatAge(EN, "2025-01-15", "2025-07-15", Compactness.short_); // "6 mo"
formatAge(EN, "2025-01-15", "2025-07-15", Compactness.compact);// "6m"
```

## API

```d
Nullable!string formatAge(ref const AgeLocale locale, string dob, string asOf,
    Compactness compactness = Compactness.normal);

Nullable!string formatStage(ref const AgeLocale locale, string dob, string asOf,
    string gender = "");

const(AgeLocale)* getLocale(string code);
```

**Parameters:**

- `dob` — `YYYY-MM-DD` string.
- `asOf` — Reference date as `YYYY-MM-DD`.
- `gender` — `"m"` or `"f"` for gendered stage labels.

**Returns:** `Nullable!string` — check with `.isNull` before accessing `.get`.

## Development

```bash
ldc2 -unittest -main -I=source source/sayableage/*.d && ./source/sayableage/format_age
```

## License

[MIT](../../LICENSE.md)

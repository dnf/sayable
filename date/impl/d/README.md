# sayable-date — D

Human-friendly date formatting — how people reference dates in conversation.

```d
import sayabledate.format_date;
import sayabledate.locales;

auto sd = SayableDate(EN);
auto result = sd.formatDate("2025-03-15");
writeln(result.get);  // "March 15th"
```

## Installation

Add the source files to your D project. Requires LDC or DMD. Zero external dependencies.

## Usage

```d
import sayabledate.format_date;
import sayabledate.locales;

// Absolute date formatting
auto sd = SayableDate(EN);
sd.formatDate("2025-03-15").get;     // "March 15th"
sd.formatDate("2025-01-01").get;     // "January 1st"

// Date with year
sd.formatDateWithYear("2025-03-15").get;  // "March 15th, 2025"

// Relative date formatting
sd.formatRelative("2025-03-16", "2025-03-15").get;  // "tomorrow"
sd.formatRelative("2025-03-19", "2025-03-15").get;  // "this Wednesday"
sd.formatRelative("2025-03-22", "2025-03-15").get;  // "next Saturday"

// Returns null for invalid input
auto result = sd.formatDate("");
assert(result.isNull);
```

## Internationalization

```d
auto loc = getLocale("de");
auto sd = SayableDate(*loc);
sd.formatDate("2025-03-15").get;  // "15. März"
sd.formatRelative("2025-03-16", "2025-03-15").get;  // "morgen"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```d
SayableDate(EN).formatDate("2025-03-15").get;                       // "March 15th"
SayableDate(EN, Compactness.short_).formatDate("2025-03-15").get;   // "Mar 15"
SayableDate(EN, Compactness.compact).formatDate("2025-03-15").get;  // "3/15"
```

## API

```d
struct SayableDate {
    this(ref const DateLocale locale, Compactness compactness = Compactness.normal);

    Nullable!string formatDate(string date);
    Nullable!string formatDateWithYear(string date);
    Nullable!string formatRelative(string date, string asOf);
}

const(DateLocale)* getLocale(string code);
```

**Parameters:**

- `date` — `YYYY-MM-DD` or ISO 8601 datetime string.
- `asOf` — Reference date as `YYYY-MM-DD`.

**Returns:** `Nullable!string` — check with `.isNull` before accessing `.get`.

## Development

```bash
ldc2 -unittest -main -I=source source/sayabledate/*.d && ./source/sayabledate/format_date
```

## License

[MIT](../../LICENSE.md)

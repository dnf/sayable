# parent-time — Zig

A thoughtful time formatting library that reflects how we think about little ones.

```zig
const pt = @import("parenttime");

var buf: [256]u8 = undefined;
const age = pt.formatAge(&buf, &pt.locales.en, .normal, "2025-06-01", "2025-06-15");
// "2 weeks"

const stage = pt.formatStage(&pt.locales.en, "2025-01-15", "2025-06-15", "");
// "Infant"
```

## Installation

Add as a Zig dependency or copy `src/parenttime.zig` and `src/locales.zig` into your project.

Zero external dependencies.

## Usage

```zig
const pt = @import("parenttime");

// Buffer-based API — caller provides output buffer
var buf: [256]u8 = undefined;

const age = pt.formatAge(&buf, &pt.locales.en, .normal, "2025-06-15", "2025-06-15");
// "Newborn"

const age2 = pt.formatAge(&buf, &pt.locales.en, .normal, "2025-06-01", "2025-06-15");
// "2 weeks"

const age3 = pt.formatAge(&buf, &pt.locales.en, .normal, "2025-01-15", "2025-07-15");
// "6 months"

const age4 = pt.formatAge(&buf, &pt.locales.en, .normal, "2022-06-15", "2025-12-15");
// "3½ years"

const stage = pt.formatStage(&pt.locales.en, "2025-01-15", "2025-06-15", "");
// "Infant"

// Returns null for empty/future dates or ages exceeding 500 years
const nothing = pt.formatAge(&buf, &pt.locales.en, .normal, "", "2025-06-15");
// null
```

## Internationalization

```zig
const pt = @import("parenttime");

var buf: [256]u8 = undefined;
const age = pt.formatAge(&buf, &pt.locales.ja, .normal, "2025-01-01", "2025-07-15");
// "6ヶ月"

const stage = pt.formatStage(&pt.locales.ja, "2025-01-01", "2025-07-15", "");
// "乳児"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```zig
const normal  = pt.formatAge(&buf, &pt.locales.en, .normal, dob, asOf);     // "3 months"
const short_m = pt.formatAge(&buf, &pt.locales.en, .short_mode, dob, asOf); // "3 mo"
const compact = pt.formatAge(&buf, &pt.locales.en, .compact, dob, asOf);    // "3m"
```

## API

```zig
pub fn formatAge(
    buf: []u8,
    locale: *const Locale,
    compactness: Compactness,
    dob: []const u8,
    as_of: []const u8,
) ?[]const u8

pub fn formatStage(
    locale: *const Locale,
    dob: []const u8,
    as_of: []const u8,
    gender: ?[]const u8,
) ?[]const u8
```

**Parameters:**

- `buf` — Output buffer for `formatAge` (caller-provided, no allocation).
- `locale` — Pointer to a locale definition.
- `compactness` — `.normal`, `.short_mode`, or `.compact`.
- `dob` — `YYYY-MM-DD` date string.
- `as_of` — Reference date string.
- `gender` — Optional `"f"` for feminine stage labels.

**Returns:** `?[]const u8` — a slice of `buf` with the formatted string, or `null` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
zig build test    # Run tests
zig build         # Build
```

## License

[MIT](../../LICENSE.md)

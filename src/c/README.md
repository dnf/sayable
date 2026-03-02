# parent-time — C

A thoughtful time formatting library that reflects how we think about little ones.

```c
char buf[64];
pt_format_age(buf, sizeof(buf), pt_locale_get("en"), PT_NORMAL, "2025-06-01", "2025-06-15");
printf("%s\n", buf);  // "2 weeks"
```

## Building

CMake freestanding build — no external dependencies.

```bash
cd src/c
cmake -B build
cmake --build build
```

Requires a C11-compatible compiler.

## Usage

```c
#include "parenttime/parenttime.h"

const PtLocale *en = pt_locale_get("en");

char buf[64];
pt_format_age(buf, sizeof(buf), en, PT_NORMAL, "2025-01-15", "2025-07-15");
printf("%s\n", buf);  // "6 months"

const char *stage = pt_stage(en, "2025-01-15", "2025-06-15", NULL);
printf("%s\n", stage);  // "Infant"
```

## Internationalization

```c
const PtLocale *ja = pt_locale_get("ja");
pt_format_age(buf, sizeof(buf), ja, PT_NORMAL, "2025-01-01", "2025-07-15");
printf("%s\n", buf);  // "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```c
int pt_format_age(char *buf, size_t bufsz, const PtLocale *locale,
                  PtCompactness compactness, const char *dob, const char *as_of);

const char *pt_stage(const PtLocale *locale, const char *dob, const char *as_of,
                     const char *gender);

const PtLocale *pt_locale_get(const char *code);
```

**Parameters:**

- `dob` — `YYYY-MM-DD` string.
- `as_of` — Reference date (`YYYY-MM-DD`).
- `buf` / `bufsz` — Output buffer and its size.

**Returns:** `pt_format_age` writes to `buf` and returns 0 on success. `pt_stage` returns a string pointer, or `NULL` on error.

## Development

```bash
cmake -B build && cmake --build build
ctest --test-dir build --output-on-failure   # Run tests
```

## License

[MIT](../../LICENSE.md)

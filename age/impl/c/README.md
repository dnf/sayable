# sayable-age — C

Human-friendly age formatting — how parents actually talk about little ones.

```c
char buf[64];
sa_format_age(buf, sizeof(buf), sa_locale_get("en"), SA_NORMAL, "2025-06-01", "2025-06-15");
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
#include "sayableage/sayableage.h"

const SaLocale *en = sa_locale_get("en");

char buf[64];
sa_format_age(buf, sizeof(buf), en, SA_NORMAL, "2025-01-15", "2025-07-15");
printf("%s\n", buf);  // "6 months"

const char *stage = sa_stage(en, "2025-01-15", "2025-06-15", NULL);
printf("%s\n", stage);  // "Infant"
```

## Internationalization

```c
const SaLocale *ja = sa_locale_get("ja");
sa_format_age(buf, sizeof(buf), ja, SA_NORMAL, "2025-01-01", "2025-07-15");
printf("%s\n", buf);  // "6ヶ月"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```c
int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale,
                  SaCompactness compactness, const char *dob, const char *as_of);

const char *sa_stage(const SaLocale *locale, const char *dob, const char *as_of,
                     const char *gender);

const SaLocale *sa_locale_get(const char *code);
```

**Parameters:**

- `dob` — `YYYY-MM-DD` string.
- `as_of` — Reference date (`YYYY-MM-DD`).
- `buf` / `bufsz` — Output buffer and its size.

**Returns:** `sa_format_age` writes to `buf` and returns 0 on success. `sa_stage` returns a string pointer, or `NULL` on error.

## Development

```bash
cmake -B build && cmake --build build
ctest --test-dir build --output-on-failure   # Run tests
```

## License

[MIT](../../LICENSE.md)

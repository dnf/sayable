# sayable-age -- COBOL

Human-friendly age formatting — how parents actually talk about little ones.

```cobol
MOVE "en" TO WS-LOOKUP-CODE
PERFORM GET-LOCALE
MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
MOVE "2025-06-01" TO WS-FMT-DOB
MOVE "2025-06-15" TO WS-FMT-AS-OF
PERFORM FORMAT-AGE
*> WS-FORMAT-RESULT contains "2 weeks"
```

## Building

CMake build with GnuCOBOL (free-format source) -- no external dependencies.

```bash
cd src/cobol
cmake -B build
cmake --build build
```

Requires GnuCOBOL 3.x (`cobc`). Install via `brew install gnu-cobol` (macOS) or `apt install gnucobol` (Linux).

## Usage

```cobol
IDENTIFICATION DIVISION.
PROGRAM-ID. MY-PROGRAM.
DATA DIVISION.
WORKING-STORAGE SECTION.
COPY "src/Types.cbl".

PROCEDURE DIVISION.
    MOVE "en" TO WS-LOOKUP-CODE
    PERFORM GET-LOCALE

    MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
    MOVE "2025-01-15" TO WS-FMT-DOB
    MOVE "2025-07-15" TO WS-FMT-AS-OF
    PERFORM FORMAT-AGE
    DISPLAY FUNCTION TRIM(WS-FORMAT-RESULT TRAILING)
    *> "6 months"

    MOVE "2025-01-15" TO WS-FMT-DOB
    MOVE "2025-06-15" TO WS-FMT-AS-OF
    PERFORM FORMAT-STAGE
    DISPLAY FUNCTION TRIM(WS-STAGE-RESULT TRAILING)
    *> "Infant"

    STOP RUN.

COPY "src/SayableAge.cbl".
COPY "src/locales/Locales.cbl".
```

## Internationalization

```cobol
MOVE "ja" TO WS-LOOKUP-CODE
PERFORM GET-LOCALE
MOVE PT-NORMAL TO WS-FMT-COMPACTNESS
MOVE "2025-01-01" TO WS-FMT-DOB
MOVE "2025-07-15" TO WS-FMT-AS-OF
PERFORM FORMAT-AGE
*> WS-FORMAT-RESULT contains "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

### FORMAT-AGE

Formats a child's age as a human-readable string.

**Inputs:**

| Variable             | Type    | Description                                          |
| -------------------- | ------- | ---------------------------------------------------- |
| `WS-LOOKUP-CODE`     | `X(8)`  | Locale code (call `GET-LOCALE` first)                |
| `WS-FMT-COMPACTNESS` | `9`     | `PT-NORMAL` (0), `PT-SHORT` (1), or `PT-COMPACT` (2) |
| `WS-FMT-DOB`         | `X(10)` | Date of birth (`YYYY-MM-DD`)                         |
| `WS-FMT-AS-OF`       | `X(10)` | Reference date (`YYYY-MM-DD`)                        |

**Output:** `WS-FORMAT-RESULT` (`X(256)`) -- use `FUNCTION TRIM(... TRAILING)` to get the meaningful content.

### FORMAT-STAGE

Determines the child's life stage.

**Inputs:** Same as FORMAT-AGE, plus:

| Variable        | Type   | Description                                              |
| --------------- | ------ | -------------------------------------------------------- |
| `WS-FMT-GENDER` | `X(1)` | `"m"` or `"f"` for gendered labels, or space for neutral |

**Output:** `WS-STAGE-RESULT` (`X(256)`)

### GET-LOCALE

Loads locale data into the active locale fields.

**Input:** `WS-LOOKUP-CODE` (`X(8)`) -- the locale code (e.g., `"en"`, `"ja"`, `"es"`).

**Output:** `WS-LOOKUP-FOUND` (`9`) -- `1` if found, `0` if not.

## Architecture

This implementation makes several design decisions worth documenting for future reference.

### Free-format source

All COBOL source uses GnuCOBOL's `-free` flag, avoiding the traditional 80-column fixed-format restriction. This allows natural indentation and longer lines for locale data.

### Active locale pattern

COBOL lacks modules, dynamic allocation, and modern data structures. Instead of storing all 71 locales in parallel arrays (which would require complex indexing), the implementation uses a single "active locale" slot:

1. `GET-LOCALE` receives a locale code in `WS-LOOKUP-CODE`
2. An `EVALUATE` statement dispatches to the matching `INIT-LOCALE-XX` paragraph
3. That paragraph populates the `WS-ACT-*` (active) fields in WORKING-STORAGE
4. The formatter reads from these active fields

This is simple, avoids array indexing entirely, and maps naturally to COBOL's procedural style.

### Effective locale fields (compactness overrides)

When a locale defines `short` or `compact` overrides, the formatter needs to merge the override with the base locale. Rather than conditional reads throughout the formatting code, the `COPY-LOCALE-TO-EFFECTIVE` paragraph copies all `WS-ACT-*` unit/scalar fields into `WS-EFF-*` (effective) fields, then `APPLY-COMPACTNESS-OVERRIDE` selectively overwrites from the short/compact override. The formatter always reads from `WS-EFF-*`.

### COPY-based inclusion

COBOL's `COPY` statement (analogous to C's `#include`) textually includes source files. The test program structure is:

```
WORKING-STORAGE SECTION.
COPY "src/Types.cbl".          *> All field definitions

PROCEDURE DIVISION.
*> Test paragraphs...

COPY "src/SayableAge.cbl".     *> Formatter paragraphs
COPY "src/locales/Locales.cbl". *> Locale data paragraphs
```

All COPY paths are relative to the `src/cobol/` directory (the compilation working directory).

### Julian Day Number for date arithmetic

Days-between calculation uses the same Julian Day Number formula as the Fortran and C implementations. Each intermediate term (`y/4`, `y/100`, `y/400`, etc.) is computed into a separate temporary variable (`WS-JD-T1` through `WS-JD-T6`) before summing, because GnuCOBOL's single-expression `COMPUTE` can produce off-by-one results due to intermediate precision truncation.

### Template replacement

Unit forms use `{n}` as a placeholder for the numeric value (e.g., `"{n} months"`). The `REPLACE-FIRST` paragraph finds the marker using `INSPECT TALLYING FOR CHARACTERS BEFORE INITIAL`, then reconstructs the string with `STRING ... DELIMITED BY SIZE`. The half-year pattern `{0}` triggers a two-part substitution (`{0}` = count, `{1}` = half marker).

### Generated locale file

`src/cobol/src/locales/Locales.cbl` is generated by `codegen/targets/cobol/emitter.py` from the canonical JSON files. It contains:

- A `GET-LOCALE` dispatcher paragraph
- An `APPLY-PLURAL-RULE` dispatcher paragraph
- Deduplicated plural rule paragraphs (only rules actually used)
- One `INIT-LOCALE-XX` paragraph per locale (~6,900 lines total for 71 locales)

### UTF-8 and the C compiler warning suppression

GnuCOBOL compiles COBOL to C, then compiles the C with the system's C compiler. Locale strings contain raw UTF-8 characters (e.g., `"婴儿"`, `"ヶ月"`, `"أسبوع"`). GnuCOBOL emits these as raw byte sequences in C string literals, which triggers Clang's `-Winvalid-source-encoding` warning -- over 1,100 times across the 71 locales.

The strings are correct: they round-trip through compilation and produce valid UTF-8 output at runtime. There is no way to avoid this at the COBOL source level -- even COBOL hex literals (`X"E5A9B4E584BF"`) are converted back to raw UTF-8 bytes in the generated C.

The `CMakeLists.txt` suppresses this by appending `-Wno-invalid-source-encoding` to GnuCOBOL's `COB_CFLAGS`. It extracts the default `COB_CFLAGS` at configure time (which contain platform-specific include paths for `gmp.h` and `libcob`) and appends the suppression flag, so the build remains portable across macOS and Linux.

### String handling

COBOL uses fixed-length strings. All text fields are `PIC X(256)`. Output uses `FUNCTION TRIM(... TRAILING)` to strip trailing spaces while preserving leading content. The `NUM-TO-STR` paragraph converts integers to trimmed strings using an edited picture (`PIC Z(7)9`) and `FUNCTION TRIM(... LEADING)` to remove leading spaces.

## Development

```bash
cmake -B build && cmake --build build
ctest --test-dir build --output-on-failure   # Run tests
```

Or using the project task runner:

```bash
just test cobol    # or: just test cb
just build cobol   # or: just build cb
just clean cobol   # or: just clean cb
```

## License

[MIT](../../LICENSE.md)

# C Style Guide

A comprehensive reference for writing and auditing idiomatic C code. Synthesized from
the Linux kernel coding style, CERT C Coding Standard, MISRA C, NASA/JPL Power of Ten
rules, the GNU Coding Standards, and modern C best practices.

---

## Table of Contents

1. [Language Standard](#1-language-standard)
2. [Naming Conventions](#2-naming-conventions)
3. [Code Formatting](#3-code-formatting)
4. [Header File Design](#4-header-file-design)
5. [Memory Management](#5-memory-management)
6. [Error Handling](#6-error-handling)
7. [Type Safety](#7-type-safety)
8. [String Handling](#8-string-handling)
9. [Common Idioms and Patterns](#9-common-idioms-and-patterns)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)
12. [References](#12-references)

---

## 1. Language Standard

Target **C99** (`-std=c99`) as the baseline. C99 provides the features modern C code
needs while remaining broadly portable:

- `//` single-line comments
- Declarations anywhere in a block (not just at the top)
- `<stdbool.h>` for `bool`, `true`, `false`
- `<stdint.h>` for fixed-width integer types
- `<inttypes.h>` for portable format specifiers (`PRIu32`, `PRId64`, etc.)
- Designated initializers (`(struct foo){.x = 1, .y = 2}`)
- `inline` functions
- Variable-length arrays (use sparingly -- prefer fixed buffers)
- `snprintf` with guaranteed null-termination

If the target toolchain supports C11 (`-std=c11`), prefer it for `_Static_assert`,
`_Noreturn`, and `_Alignas`. Always specify the standard explicitly rather than
relying on compiler defaults.

```bash
# Minimum
cc -std=c99 -Wall -Wextra -pedantic -o prog prog.c

# Preferred when C11 is available
cc -std=c11 -Wall -Wextra -pedantic -o prog prog.c
```

---

## 2. Naming Conventions

### 2.1 General Principles

Names communicate intent. A reader should understand what a symbol represents without
needing a comment to explain it.

- Use **lowercase with underscores** (`snake_case`) for functions and variables.
- Use **UPPER_CASE** for macros and constants defined with `#define`.
- Use **PascalCase** for `typedef`'d type names (structs, enums, function pointer types).
- Use a **project prefix** on all public symbols to prevent namespace collisions.

### 2.2 Functions

```c
// Public API -- prefixed, descriptive
int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale, ...);
const char *sa_stage(const SaLocale *locale, ...);

// File-local helpers -- static, descriptive but concise
static int parse_date(const char *s, int *year, int *month, int *day);
static void write_string(Writer *w, const char *s);
```

Public functions use the library prefix (`sa_`). Static helper functions omit the
prefix since they are file-scoped.

### 2.3 Variables

```c
// Local variables: short, clear names
int year, month, day;
size_t len = strlen(input);
const char *pos = strstr(haystack, needle);

// Loop counters: single letters are fine for tight loops
for (int i = 0; i < count; i++) { ... }

// Booleans: name as predicates
bool overflow = false;
bool has_half = (locale->half[0] != '\0');
```

Avoid Hungarian notation. The type system enforces types; encoding them in names adds
noise without value.

### 2.4 Constants and Macros

```c
#define SA_MAX_AGE_MONTHS 6000
#define SA_BUFFER_SIZE    256

// Enum constants follow the project prefix + category convention
typedef enum {
    SA_ZERO,
    SA_ONE,
    SA_TWO,
    SA_FEW,
    SA_MANY,
    SA_OTHER
} SaPluralCategory;
```

Prefer `enum` over `#define` for related integer constants. Enum values are visible in
debuggers and participate in type checking.

### 2.5 Typedefs

Use typedefs judiciously:

```c
// Good: opaque types that hide implementation
typedef struct SaLocale SaLocale;

// Good: function pointer types (avoids unwieldy syntax)
typedef SaPluralCategory (*SaPluralFn)(int n);

// Good: clear semantic types
typedef enum { SA_NORMAL, SA_SHORT, SA_COMPACT } SaCompactness;

// Avoid: typedef'ing a struct with directly accessible members
//        where knowing it's a struct aids comprehension
typedef struct { int x; int y; } Point;  // Debatable -- acceptable for small, value-like types
```

The Linux kernel style guide advises against gratuitous typedefs. The key question is:
does the typedef aid comprehension, or does it hide information the reader needs?

### 2.6 Struct and Enum Tags

Give structs and enums a tag even when typedef'd, to allow forward declarations:

```c
// Forward-declarable
typedef struct SaLocale SaLocale;

// Later, the full definition
struct SaLocale {
    const char *code;
    SaPluralFn plural;
    SaUnitSet units;
    /* ... */
};
```

---

## 3. Code Formatting

### 3.1 Indentation

Use **4 spaces** per indentation level. Never mix tabs and spaces.

The Linux kernel uses 8-space tabs, but most non-kernel C projects have converged on
4 spaces as a pragmatic default. The critical rule is consistency within a project.

### 3.2 Brace Placement

Use **K&R style** (opening brace on the same line) for control structures. Place the
opening brace of a function definition on its own line:

```c
// Functions: opening brace on next line
int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale,
                  SaCompactness compactness, const char *dob, const char *as_of)
{
    if (!buf || bufsz == 0 || !locale || !dob) {
        return -1;
    }
    /* ... */
}

// Control structures: opening brace on same line
if (months < 3) {
    int weeks = diff_days / 7;
    int days = diff_days % 7;
} else if (months < 24) {
    /* ... */
} else {
    /* ... */
}

// Single-statement bodies: braces are optional for truly simple cases
if (!s)
    return false;

// But always use braces when any branch in an if/else chain is multi-line
if (condition) {
    do_something();
} else {
    do_other();
    do_more();
}

// do-while: closing brace joins the while
do {
    process();
} while (condition);

// switch: case labels align with the switch
switch (category) {
case SA_ZERO:
    return "zero";
case SA_ONE:
    return "one";
default:
    return "other";
}
```

### 3.3 Line Length

Keep lines to **100 characters** maximum. Break longer lines at logical points:

```c
// Break after the opening parenthesis, align parameters
int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale,
                  SaCompactness compactness, const char *dob,
                  const char *as_of);

// Break before operators
int result = long_variable_name
           + another_long_name
           * coefficient;
```

Never break string literals that users might search for (error messages, log strings).

### 3.4 Spacing

```c
// Space after keywords
if (condition)
for (int i = 0; i < n; i++)
while (running)
switch (value)
return result;

// No space after function-like keywords
sizeof(struct foo)
typeof(expression)
alignof(type)

// Spaces around binary operators
int result = a + b;
bool valid = (x > 0) && (y < max);
flags = flags | MASK;

// No space around unary operators
int *ptr = &value;
result = -offset;
if (!valid)

// No space inside parentheses
func(a, b, c);          // not func( a, b, c );
if (x > 0)              // not if ( x > 0 )

// Pointer declarations: asterisk with the variable name
char *name;              // not char* name; or char * name;
const char *src, *dst;

// Struct member access: no spaces
node->next
point.x
```

### 3.5 Blank Lines

Use blank lines to separate logical sections within a function. Separate function
definitions with exactly one blank line. Group related declarations together.

```c
static int compute_months(int dob_y, int dob_m, int ref_y, int ref_m, int ref_d,
                          int clamped_birthday)
{
    int months = (ref_y - dob_y) * 12 + (ref_m - dob_m);
    if (ref_d < clamped_birthday)
        months--;
    return months;
}

static int compute_diff_days(int dob_y, int dob_m, int dob_d,
                             int ref_y, int ref_m, int ref_d)
{
    return julian_day(ref_y, ref_m, ref_d) - julian_day(dob_y, dob_m, dob_d);
}
```

### 3.6 Function Length

Functions should fit on **one or two screens** (roughly 40-80 lines). If a function
exceeds this, it is doing too much. Extract helpers.

The NASA/JPL Power of Ten rules restrict functions to no more than 60 lines. The Linux
kernel guide suggests one or two screenfuls (24-48 lines at 80 columns). The exact
limit matters less than the principle: each function should do one thing and do it well.

---

## 4. Header File Design

### 4.1 Include Guards

Every header file must have an include guard. Use the `#ifndef` / `#define` / `#endif`
pattern with a unique macro name derived from the file path:

```c
#ifndef SAYABLEAGE_H
#define SAYABLEAGE_H

/* declarations */

#endif /* SAYABLEAGE_H */
```

The guard macro should be **UPPER_CASE**, derived from the project and file name, and
suffixed with `_H`. Include a trailing comment on `#endif` identifying which guard it
closes.

`#pragma once` is widely supported but not part of the C standard. Prefer traditional
include guards for maximum portability. Use `#pragma once` only when you can guarantee
the toolchain supports it.

### 4.2 What Goes in Headers (.h) vs. Source Files (.c)

**Headers expose the public interface:**

- Type definitions (`struct`, `enum`, `typedef`) that callers need
- Function prototypes (declarations)
- Macro definitions that form part of the API
- `extern` variable declarations (use sparingly)

**Source files contain the implementation:**

- Function bodies
- `static` functions (internal helpers)
- `static` global variables (file-scoped state)
- Private type definitions not needed by callers

```c
/* sayableage.h -- public API */
#ifndef SAYABLEAGE_H
#define SAYABLEAGE_H

#include <stddef.h>
#include <stdbool.h>

typedef struct SaLocale SaLocale;   /* opaque to callers */

int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale, ...);

#endif /* SAYABLEAGE_H */
```

```c
/* sayableage.c -- implementation */
#include "sayableage.h"

/* Full struct definition visible only inside this translation unit */
struct SaLocale {
    const char *code;
    /* ... */
};

static int parse_date(const char *s, int *y, int *m, int *d) {
    /* ... */
}

int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale, ...) {
    /* ... */
}
```

### 4.3 Include Order

Order `#include` directives in groups, separated by blank lines:

1. The corresponding header for this `.c` file (e.g., `#include "sayableage.h"`)
2. Other project headers
3. Third-party library headers
4. Standard library headers

```c
#include "sayableage/sayableage.h"
#include "sayableage/locales.h"

#include <stdio.h>
#include <string.h>
```

Placing the corresponding header first ensures it is self-contained (it does not
depend on includes that happen to precede it).

### 4.4 Forward Declarations

Prefer forward declarations over including an entire header when only a pointer to a
type is needed:

```c
/* Only need a pointer to SaLocale, not its full definition */
struct SaLocale;
const struct SaLocale *get_locale(const char *code);
```

This reduces compile times and avoids circular dependency issues.

### 4.5 Header Self-Containment

Every header must compile on its own. Include all headers that your header depends on.
Never require the caller to include prerequisite headers in a specific order:

```c
/* Good: sayableage.h includes what it needs */
#ifndef SAYABLEAGE_H
#define SAYABLEAGE_H

#include <stddef.h>    /* for size_t */
#include <stdbool.h>   /* for bool */

int sa_format_age(char *buf, size_t bufsz, ...);

#endif
```

---

## 5. Memory Management

### 5.1 Allocation and Deallocation Patterns

Every allocation must have a clear, deterministic deallocation path. The two
fundamental patterns are:

**Caller-allocated buffers** (preferred for small, bounded data):

```c
/* The caller owns the buffer. No heap allocation inside the library. */
char buf[256];
int rc = sa_format_age(buf, sizeof(buf), locale, SA_NORMAL, dob, as_of);
```

**Library-managed allocation** (when the library must own lifetime):

```c
Config *config_create(const char *path);  /* allocator */
void config_destroy(Config *cfg);          /* deallocator */
```

Always pair creation and destruction functions. Name them symmetrically:
`create`/`destroy`, `open`/`close`, `init`/`cleanup`, `alloc`/`free`.

### 5.2 Ownership Conventions

Document ownership in function signatures and comments:

- **Caller owns the memory** -- the function fills a caller-provided buffer.
- **Callee owns the memory** -- the function allocates and returns; caller must free.
- **Borrowed reference** -- the function returns a pointer to data it does not own;
  caller must not free.

```c
/*
 * Fills 'buf' with the formatted age string.
 * Returns 0 on success, -1 on error.
 * The caller owns 'buf' and is responsible for its lifetime.
 */
int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale, ...);

/*
 * Returns a pointer to a statically-allocated locale.
 * The caller must NOT free the returned pointer.
 */
const SaLocale *sa_locale_get(const char *code);
```

### 5.3 Allocation Sizing

Always use `sizeof(*ptr)` rather than `sizeof(Type)`. This is resilient to type
changes:

```c
/* Good: tracks the type automatically */
Node *node = malloc(sizeof(*node));
int *arr = calloc(count, sizeof(*arr));

/* Fragile: must be updated if the type changes */
Node *node = malloc(sizeof(Node));
```

### 5.4 Checking Allocation Results

Every call to `malloc`, `calloc`, or `realloc` must be checked for `NULL`:

```c
char *buf = malloc(size);
if (!buf) {
    return -1;  /* or propagate error appropriately */
}
```

For libraries, return an error code. For applications, handle gracefully or abort with
a clear message. The GNU Coding Standards recommend making allocation failure fatal in
non-interactive programs.

### 5.5 Avoiding Common Pitfalls

- Never use memory after freeing it (use-after-free).
- Never free memory more than once (double-free).
- Set pointers to `NULL` after freeing to catch stale access under sanitizers.
- Never return a pointer to a stack-local variable.
- Use `realloc` carefully -- it can return `NULL` while the original pointer remains
  valid. Always assign to a temporary:

```c
void *tmp = realloc(buf, new_size);
if (!tmp) {
    /* buf is still valid -- handle error */
    return -1;
}
buf = tmp;
```

### 5.6 Prefer Stack and Static Allocation

When the size is known at compile time or bounded by a small constant, prefer stack
allocation over heap allocation. This eliminates the possibility of memory leaks and
simplifies error handling:

```c
/* Good: stack-allocated, fixed bound */
char result_buf[128];

/* Good: static const data */
static const char *months[] = {"Jan", "Feb", "Mar", /* ... */};
```

The NASA/JPL Power of Ten rules go further: they recommend avoiding dynamic memory
allocation entirely in safety-critical code. While this is overly restrictive for
general-purpose software, the principle holds -- prefer static and stack allocation
when feasible.

---

## 6. Error Handling

### 6.1 Return Codes

Use integer return codes for functions that can fail. The convention is:

- **0** for success
- **Negative values** for errors (e.g., `-1` for general failure, or specific
  negative error codes)

```c
int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale,
                  SaCompactness compactness, const char *dob, const char *as_of)
{
    if (!buf || bufsz == 0 || !locale || !dob)
        return -1;
    /* ... */
    return 0;
}
```

For functions that return pointers, return `NULL` on failure:

```c
const SaLocale *sa_locale_get(const char *code)
{
    if (!code)
        return NULL;
    /* ... lookup ... */
    return NULL;  /* not found */
}
```

### 6.2 Validate Inputs Early

Check preconditions at the top of the function and return immediately on failure.
This keeps the happy path at the lowest indentation level:

```c
int process(const char *input, char *output, size_t output_size)
{
    if (!input || !output || output_size == 0)
        return -1;

    /* Happy path follows at base indentation */
    size_t len = strlen(input);
    /* ... */
    return 0;
}
```

### 6.3 The goto Cleanup Pattern

When a function acquires multiple resources, use `goto` for centralized cleanup. This
is idiomatic C and endorsed by the Linux kernel coding style:

```c
int do_work(const char *path)
{
    int result = -1;
    FILE *fp = NULL;
    char *buf = NULL;

    fp = fopen(path, "r");
    if (!fp)
        goto cleanup;

    buf = malloc(BUFSZ);
    if (!buf)
        goto cleanup;

    if (read_data(fp, buf, BUFSZ) < 0)
        goto cleanup;

    result = 0;

cleanup:
    free(buf);
    fclose_if_open(fp);
    return result;
}
```

Label names should describe the action (`cleanup`, `out_free_buffer`) rather than the
error (`err1`, `err2`).

### 6.4 errno

Use `errno` for communicating errors from system calls and standard library functions.
Always check `errno` immediately after the call that might set it, since subsequent
calls may overwrite it:

```c
FILE *fp = fopen(path, "r");
if (!fp) {
    int saved_errno = errno;
    fprintf(stderr, "Cannot open %s: %s\n", path, strerror(saved_errno));
    return -1;
}
```

Never rely on `errno` being zero after a successful call -- only check it when the
return value indicates failure.

### 6.5 Assertions

Use `assert()` for conditions that must be true if the program is correct (programmer
errors, invariant violations). Never use `assert()` for runtime errors like bad user
input or allocation failure, because assertions are disabled in release builds
(`-DNDEBUG`):

```c
#include <assert.h>

static void write_char(Writer *w, char c)
{
    assert(w != NULL);       /* programming error if NULL */
    assert(w->cap > 0);     /* invariant: capacity must be positive */
    /* ... */
}
```

The NASA/JPL Power of Ten rules recommend at least two assertions per function on
average. Use them liberally to document and enforce invariants.

---

## 7. Type Safety

### 7.1 const Correctness

Mark every pointer parameter `const` when the function does not modify the pointed-to
data. Mark every local variable `const` when it is assigned once and never mutated.
`const` communicates intent and enables compiler optimizations:

```c
/* Good: input strings are const, output buffer is not */
int sa_format_age(char *buf, size_t bufsz, const SaLocale *locale,
                  SaCompactness compactness, const char *dob, const char *as_of);

/* Good: return a const pointer to data the caller must not modify */
const char *sa_stage(const SaLocale *locale, const char *dob,
                     const char *as_of, const char *gender);
```

Read pointer declarations right-to-left to understand const placement:

```c
const char *p;        /* pointer to const char (can reassign p, cannot modify *p) */
char *const p;        /* const pointer to char (cannot reassign p, can modify *p) */
const char *const p;  /* const pointer to const char (neither reassignable nor modifiable) */
```

### 7.2 Fixed-Width Integers

Use fixed-width types from `<stdint.h>` when the exact width matters (binary
protocols, file formats, hardware registers). Use standard `int` and `size_t` for
general computation:

```c
#include <stdint.h>

/* When exact width matters */
uint8_t  flags;
int32_t  error_code;
uint64_t file_offset;

/* For general computation, plain types are fine */
int count;
size_t length;
```

When printing fixed-width types, use format macros from `<inttypes.h>`:

```c
#include <inttypes.h>

uint64_t value = 42;
printf("value = %" PRIu64 "\n", value);

size_t len = 100;
printf("len = %zu\n", len);
```

### 7.3 Avoiding Implicit Conversions

Enable `-Wconversion` to catch implicit narrowing conversions. Be explicit when
converting between types of different widths or signedness:

```c
/* Bad: implicit truncation */
uint8_t byte = some_int;

/* Good: explicit cast documents intent */
uint8_t byte = (uint8_t)(some_int & 0xFF);
```

Be especially careful with signed/unsigned comparisons:

```c
/* Bug: if length is unsigned, -1 wraps to a very large number */
if (length > -1)   /* always true for unsigned length */

/* Correct */
if (length > 0)
```

### 7.4 Bool Usage

Use `bool` from `<stdbool.h>` for true/false values. Do not use `int` as a boolean:

```c
#include <stdbool.h>

bool is_valid = (input != NULL);
bool overflow = false;

if (is_valid) {
    /* ... */
}
```

Avoid `bool` in structs where packing matters -- use `uint8_t` or bitfields instead.

### 7.5 Enum Type Safety

Prefer enums over `#define` for sets of related constants. Give each enum a typedef
for documentation and type-checking:

```c
typedef enum {
    SA_NORMAL,
    SA_SHORT,
    SA_COMPACT
} SaCompactness;

/* The compiler can warn about unhandled cases in switch statements */
switch (compactness) {
case SA_NORMAL:  /* ... */ break;
case SA_SHORT:   /* ... */ break;
case SA_COMPACT: /* ... */ break;
/* No default -- compiler warns if a new case is added but unhandled */
}
```

---

## 8. String Handling

### 8.1 Buffer Safety

Always pass buffer sizes alongside buffer pointers. Never rely on the caller to
provide a "large enough" buffer without knowing the size:

```c
/* Good: size is part of the contract */
int sa_format_age(char *buf, size_t bufsz, ...);

/* Bad: no way to prevent overflow */
int format_age(char *buf, ...);
```

### 8.2 snprintf Over sprintf

Always use `snprintf` instead of `sprintf`. `snprintf` guarantees null-termination
and prevents buffer overflows:

```c
/* Good: bounded, null-terminated */
char msg[128];
snprintf(msg, sizeof(msg), "%d %s", count, unit);

/* Dangerous: no bounds checking */
char msg[128];
sprintf(msg, "%d %s", count, unit);   /* DO NOT USE */
```

Check the return value of `snprintf` to detect truncation:

```c
int written = snprintf(buf, bufsz, "%s, %s", part1, part2);
if (written < 0 || (size_t)written >= bufsz) {
    /* output was truncated */
    return -1;
}
```

### 8.3 Null Termination

Every string-producing operation must guarantee null-termination. Be especially
careful with:

- `strncpy` -- does NOT null-terminate if the source is longer than `n`. Prefer
  `snprintf` or manual termination:

```c
/* strncpy pitfall: no null terminator if src >= n */
strncpy(dst, src, sizeof(dst));
dst[sizeof(dst) - 1] = '\0';  /* manual fix required */

/* Better: snprintf always null-terminates */
snprintf(dst, sizeof(dst), "%s", src);
```

- Hand-rolled string operations must always write `'\0'` at the end:

```c
static void wr_str(Writer *w, const char *s) {
    size_t len = strlen(s);
    if (w->pos + len < w->cap) {
        memcpy(w->buf + w->pos, s, len);
        w->pos += len;
        w->buf[w->pos] = '\0';   /* always null-terminate */
    } else {
        w->overflow = true;
    }
}
```

### 8.4 String Comparison

Use `strcmp` for equality checks, not pointer comparison:

```c
/* Correct: compares content */
if (strcmp(code, "en") == 0) { /* ... */ }

/* Wrong: compares addresses */
if (code == "en") { /* ... */ }
```

For bounded comparisons, use `strncmp`:

```c
if (strncmp(input, "prefix", 6) == 0) {
    /* input starts with "prefix" */
}
```

### 8.5 Banned String Functions

The following functions are unsafe and must not be used:

| Banned Function | Safe Replacement |
|-----------------|------------------|
| `gets`          | `fgets`          |
| `sprintf`       | `snprintf`       |
| `strcat`        | `strncat` or `snprintf` |
| `strcpy`        | `strncpy` + null termination, or `snprintf` |
| `strtok`        | `strtok_r` (reentrant) |
| `scanf` (unbounded `%s`) | `scanf` with width limit (`%255s`) or `fgets` + `sscanf` |

These functions are flagged by CERT C rules STR31-C and STR07-C, and by MISRA C.

---

## 9. Common Idioms and Patterns

### 9.1 Opaque Pointers

Hide implementation details behind an opaque pointer. The header declares the struct
name; the source file defines it:

```c
/* widget.h */
typedef struct Widget Widget;

Widget *widget_create(int width, int height);
void widget_destroy(Widget *w);
int widget_area(const Widget *w);
```

```c
/* widget.c */
#include "widget.h"
#include <stdlib.h>

struct Widget {
    int width;
    int height;
};

Widget *widget_create(int width, int height) {
    Widget *w = malloc(sizeof(*w));
    if (!w) return NULL;
    w->width = width;
    w->height = height;
    return w;
}

void widget_destroy(Widget *w) {
    free(w);
}

int widget_area(const Widget *w) {
    return w->width * w->height;
}
```

This gives the library control over the struct layout and allows changing it without
breaking callers.

### 9.2 Callback Patterns

Use function pointers for customizable behavior. Pair them with a `void *` context
for type-safe user data:

```c
typedef void (*EventHandler)(int event_type, void *context);

void register_handler(EventHandler handler, void *context);

/* Caller side */
static void on_click(int event_type, void *context) {
    Button *btn = context;
    btn->pressed = true;
}
register_handler(on_click, &my_button);
```

### 9.3 Compound Literals for Initialization

Use C99 compound literals to initialize structs inline:

```c
Writer w = (Writer){
    .buf = buffer,
    .cap = sizeof(buffer),
    .pos = 0,
    .overflow = false
};
```

Use designated initializers for clarity. Unmentioned fields are zero-initialized.

### 9.4 ARRAY_SIZE Macro

Calculate the number of elements in a stack-allocated array:

```c
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

int values[] = {10, 20, 30, 40, 50};
for (size_t i = 0; i < ARRAY_SIZE(values); i++) {
    process(values[i]);
}
```

Never use this on pointers -- it will silently produce the wrong result. Some
codebases use a type-safe variant that triggers a compile error on pointers.

### 9.5 Multi-Statement Macros

Wrap multi-statement macros in `do { ... } while (0)`:

```c
#define ASSERT_EQ(name, rc, buf, expected) do { \
    if ((rc) != 0) { \
        fprintf(stderr, "FAIL [%s]: got rc=%d\n", (name), (rc)); \
        tests_failed++; \
    } else if (strcmp((buf), (expected)) != 0) { \
        fprintf(stderr, "FAIL [%s]: got \"%s\", expected \"%s\"\n", \
                (name), (buf), (expected)); \
        tests_failed++; \
    } else { \
        tests_passed++; \
    } \
} while (0)
```

This ensures the macro behaves like a single statement and can be used safely in
`if`/`else` chains without braces.

### 9.6 Init/Cleanup Function Pairs

For resources that require setup and teardown, provide symmetric init/cleanup
functions:

```c
typedef struct {
    char *buf;
    size_t cap;
    size_t pos;
    bool overflow;
} Writer;

static void writer_init(Writer *w, char *buf, size_t cap) {
    w->buf = buf;
    w->cap = cap;
    w->pos = 0;
    w->overflow = false;
}

/* No writer_cleanup needed here since the buffer is caller-owned,
   but the pattern generalizes to cases where cleanup is required */
```

### 9.7 Centralized Exit with Resource Cleanup

For functions that acquire multiple resources, use a single return point with `goto`:

```c
int load_config(const char *path, Config *out)
{
    int rc = -1;
    FILE *fp = NULL;
    char *line = NULL;

    fp = fopen(path, "r");
    if (!fp)
        goto done;

    line = malloc(MAX_LINE);
    if (!line)
        goto done;

    /* ... parsing logic ... */

    rc = 0;

done:
    free(line);
    if (fp)
        fclose(fp);
    return rc;
}
```

---

## 10. Things to Avoid

### 10.1 Undefined Behavior

Undefined behavior (UB) means the compiler can do anything -- crash, silently corrupt
data, or appear to "work" today and break tomorrow. The CERT C standard catalogs
dozens of UB sources. Key ones to guard against:

- **Signed integer overflow**: `INT_MAX + 1` is UB. Check before arithmetic, or use
  unsigned types when wrapping is acceptable.
- **Null pointer dereference**: Always validate pointers before use.
- **Buffer overflows**: Always bound array access and string operations.
- **Use of uninitialized variables**: Initialize all variables at declaration.
- **Accessing freed memory**: Set pointers to NULL after free.
- **Strict aliasing violations**: Do not cast between incompatible pointer types.
  Use `memcpy` for type punning:

```c
/* Wrong: violates strict aliasing */
float f = 3.14f;
uint32_t bits = *(uint32_t *)&f;

/* Correct: use memcpy */
float f = 3.14f;
uint32_t bits;
memcpy(&bits, &f, sizeof(bits));
```

### 10.2 Variable-Length Arrays (VLAs)

VLAs can cause stack overflows since their size is not known at compile time. The Linux
kernel bans them entirely. If you use C99 VLAs, limit them to very small, bounded
sizes. Prefer fixed-size stack buffers or heap allocation:

```c
/* Risky: unbounded stack allocation */
void process(int n) {
    char buf[n];  /* stack overflow if n is large */
}

/* Safe: bounded stack allocation */
void process(int n) {
    if (n > MAX_BUF) return;
    char buf[MAX_BUF];
    /* ... */
}
```

### 10.3 Macros That Affect Control Flow

Never write macros that contain `return`, `break`, `continue`, or `goto`. These hide
control flow and make the code impossible to reason about:

```c
/* BAD: hidden return */
#define CHECK(x) if (!(x)) return -1

/* Better: visible control flow */
if (!validate(input))
    return -1;
```

### 10.4 Multiple Side Effects in Arguments

Macro arguments that are evaluated more than once can cause bugs when used with
expressions that have side effects:

```c
#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* Bug: i++ is evaluated twice */
int result = MAX(i++, j);  /* i is incremented twice if i > j */
```

Prefer inline functions for type-safe, single-evaluation alternatives:

```c
static inline int max_int(int a, int b) {
    return a > b ? a : b;
}
```

### 10.5 Recursion

Unbounded recursion can exhaust the stack. The NASA/JPL Power of Ten rules ban
recursion entirely in safety-critical code. For general-purpose code, ensure every
recursive function has:

- A provably reachable base case
- Arguments that progress toward the base case on every call
- A bounded maximum depth

Prefer iterative solutions when the logic is equally clear.

### 10.6 Global Mutable State

Minimize global and file-scope mutable variables. They create hidden coupling between
functions, make code harder to test, and prevent thread safety:

```c
/* Problematic: hidden mutable state */
static int error_count = 0;

void process(void) {
    /* ... */
    error_count++;  /* which caller does this affect? */
}

/* Better: explicit state passing */
void process(int *error_count) {
    /* ... */
    (*error_count)++;
}
```

### 10.7 Dangerous Functions to Avoid

Beyond the banned string functions (Section 8.5), avoid:

| Function | Problem | Alternative |
|----------|---------|-------------|
| `atoi`, `atol`, `atof` | No error detection | `strtol`, `strtod` with error checking |
| `gets` | Cannot limit input | `fgets` |
| `alloca` | No failure indication, stack overflow | `malloc` or fixed-size stack buffer |
| `setjmp`/`longjmp` | Bypasses cleanup code, error-prone | Structured error handling with return codes |

---

## 11. Tooling

### 11.1 Compiler Warnings

Enable comprehensive warnings and treat them as errors during development:

```bash
# Essential baseline
-Wall -Wextra -pedantic

# Recommended additions
-Wformat=2                  # Stricter format string checking
-Wshadow                    # Variable shadowing
-Wconversion                # Implicit type conversions
-Wstrict-prototypes         # Require full prototypes
-Wold-style-definition      # K&R function definitions
-Wmissing-prototypes        # Functions without prior prototype
-Wredundant-decls           # Redundant declarations
-Wnested-externs            # Extern declarations inside functions
-Wimplicit-fallthrough      # Unannotated switch fallthrough
-Wwrite-strings             # String literal to non-const pointer

# C-specific safety (errors, not warnings)
-Werror=implicit            # Implicit function declarations
-Werror=incompatible-pointer-types
-Werror=int-conversion

# During development (not for distribution)
-Werror                     # Treat all warnings as errors
```

### 11.2 Security Hardening Flags

For production builds, enable security-oriented compiler and linker options:

```bash
# Buffer overflow detection
-D_FORTIFY_SOURCE=3

# Stack protection
-fstack-protector-strong
-fstack-clash-protection

# Zero-initialize automatic variables
-ftrivial-auto-var-init=zero

# Conservative optimization assumptions
-fno-strict-overflow
-fno-strict-aliasing
-fno-delete-null-pointer-checks

# Position-independent executables (ASLR)
-fPIE -pie

# Linker hardening
-Wl,-z,relro -Wl,-z,now
-Wl,-z,noexecstack
```

See the [OpenSSF Compiler Options Hardening Guide][openssf-hardening] for a complete,
maintained list.

### 11.3 Static Analysis

Run static analysis tools as part of CI. They catch bugs that compiler warnings miss:

- **Clang Static Analyzer** (`scan-build`): Deep path-sensitive analysis for null
  dereferences, use-after-free, memory leaks, and logic errors.

```bash
scan-build make
# or
scan-build -o reports cc -std=c99 -Wall -c sayableage.c
```

- **Clang-Tidy**: Linter with auto-fix capabilities. Checks for readability,
  modernization, and bug-prone patterns.

```bash
clang-tidy -checks='*' sayableage.c -- -std=c99
```

- **Cppcheck**: Lightweight, false-positive-averse static analyzer.

```bash
cppcheck --enable=all --std=c99 --error-exitcode=1 src/
```

- **Coverity**, **PVS-Studio**, **CodeQL**: Commercial/enterprise-grade analyzers
  for larger projects.

### 11.4 Sanitizers

Sanitizers are runtime instrumentation tools that detect bugs at the moment they occur.
Use them during testing:

**AddressSanitizer (ASan)** -- detects memory errors:

```bash
cc -std=c99 -g -fsanitize=address -fno-omit-frame-pointer -o test test.c
ASAN_OPTIONS=detect_leaks=1 ./test
```

Detects: heap/stack/global buffer overflows, use-after-free, double-free, memory leaks.

**UndefinedBehaviorSanitizer (UBSan)** -- detects undefined behavior:

```bash
cc -std=c99 -g -fsanitize=undefined -o test test.c
```

Detects: signed integer overflow, null pointer dereference, misaligned access, shift
by negative or oversized amount, division by zero.

**MemorySanitizer (MSan)** -- detects use of uninitialized memory (Clang only, Linux
only):

```bash
clang -std=c99 -g -fsanitize=memory -fno-omit-frame-pointer -o test test.c
```

**ThreadSanitizer (TSan)** -- detects data races in multithreaded code:

```bash
cc -std=c99 -g -fsanitize=thread -o test test.c
```

Combine sanitizers during CI:

```bash
# Build with ASan + UBSan (these are compatible)
cc -std=c99 -g -fsanitize=address,undefined -fno-omit-frame-pointer -o test test.c
```

### 11.5 Formatting

Use `clang-format` for consistent, automated formatting. Define a `.clang-format`
file at the project root:

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 100
AllowShortFunctionsOnASingleLine: None
BreakBeforeBraces: Linux
```

Run it automatically in CI or as a pre-commit hook:

```bash
clang-format -i src/*.c include/*.h
```

### 11.6 Valgrind

Valgrind detects memory errors and leaks at runtime without recompilation. It is
complementary to sanitizers (works on unmodified binaries):

```bash
valgrind --leak-check=full --error-exitcode=1 ./test
```

Valgrind is slower than sanitizers (10-50x overhead) but catches issues in third-party
libraries and does not require recompilation.

---

## 12. References

### Standards and Coding Guidelines

- **CERT C Coding Standard** (SEI/CMU) -- Comprehensive rules for secure C
  programming, organized by topic (strings, memory, integers, I/O, concurrency).
  https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard

- **MISRA C:2023** -- 200 rules and 21 directives for safe, portable, reliable C.
  The de facto standard for automotive, aerospace, and medical device software.
  https://misra.org.uk/misra-c/

- **Linux Kernel Coding Style** -- Authoritative guide for C style in the world's
  largest C project. Key topics: indentation, naming, typedefs, function design,
  centralized exit with goto, inline discipline.
  https://www.kernel.org/doc/html/latest/process/coding-style.html

- **GNU Coding Standards** -- Formatting, naming, error handling, portability, and
  memory allocation conventions for GNU project code.
  https://www.gnu.org/prep/standards/standards.html

- **NASA/JPL Power of Ten Rules** (Gerard Holzmann) -- Ten rules for developing
  safety-critical C code: no recursion, all loops bounded, no dynamic allocation
  after init, assertions in every function, minimal scope, compiler warnings at
  maximum, static analysis from day one.
  https://spinroot.com/p10/

- **OpenSSF Compiler Options Hardening Guide for C and C++** -- Maintained reference
  for security-oriented compiler and linker flags.
  https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++

### Tools

- **Clang Static Analyzer**: https://clang-analyzer.llvm.org/
- **Clang-Tidy**: https://clang.llvm.org/extra/clang-tidy/
- **Cppcheck**: https://cppcheck.sourceforge.io/
- **AddressSanitizer**: https://clang.llvm.org/docs/AddressSanitizer.html
- **UndefinedBehaviorSanitizer**: https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
- **Valgrind**: https://valgrind.org/
- **clang-format**: https://clang.llvm.org/docs/ClangFormat.html

### Books

- *The C Programming Language* (Kernighan & Ritchie) -- The original style reference.
- *C Interfaces and Implementations* (David Hanson) -- Patterns for modular C: opaque
  types, memory management, error handling.
- *Effective C* (Robert Seacord) -- Modern C best practices from the author of the
  CERT C standard.
- *Modern C* (Jens Gustedt) -- Comprehensive coverage of C11/C17 features and idioms.

[openssf-hardening]: https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++

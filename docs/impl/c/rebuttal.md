# C Style Guide -- Senior Review and Rebuttal

Reviewer perspective: Senior Staff Engineer, reviewing for a team that ships a
zero-dependency formatting library across 29 languages. The C implementation is
auto-generated (codegen) and freestanding (`-ffreestanding`), which changes the
weight of several recommendations.

Overall assessment: This is a well-researched, well-organized guide. It cites
the right sources, covers the right topics, and the examples are almost all
correct. Most of what follows is refinement, not demolition. I would be
comfortable handing this guide to a mid-level engineer with the changes below
applied.

---

## Points of Disagreement

### 1. Section 1 lists VLAs as a C99 feature to use

> "Variable-length arrays (use sparingly -- prefer fixed buffers)"

**Problem:** The guide introduces VLAs in the "features C99 provides" list in
Section 1, giving them implicit endorsement, then reverses course in Section
10.2 by saying the Linux kernel bans them entirely and recommending against
them. This is an internal contradiction. A reader skimming Section 1 could
reasonably conclude VLAs are acceptable. Worse, the parenthetical "use
sparingly" is too weak -- there is no safe way to use VLAs when the size comes
from untrusted input, and even with trusted input they defeat static stack
analysis.

**Recommendation:** Remove VLAs from the Section 1 feature list entirely. The
mention in Section 10.2 is sufficient and correctly warns against them. If you
want to acknowledge their existence in Section 1, move them to a "notable but
discouraged" footnote.

---

### 2. Section 3.1 says "Never mix tabs and spaces" but should go further

> "Use **4 spaces** per indentation level. Never mix tabs and spaces."

**Problem:** The statement is correct but incomplete. It does not say "no tabs,
period." A reader could interpret "never mix" as "pick one and stick with it,"
which leaves the door open for a contributor to use all-tabs. The guide should
be unambiguous: tabs are not used in this project.

**Recommendation:** Change to: "Use **4 spaces** per indentation level. Do not
use tabs." One sentence, no ambiguity.

---

### 3. Section 3.2 allows braceless single-statement bodies

> "Single-statement bodies: braces are optional for truly simple cases"
> ```c
> if (!s)
>     return false;
> ```

**Problem:** This is the single most common source of maintenance bugs in C.
The Apple `goto fail` vulnerability (CVE-2014-1266) was caused by exactly this
pattern. The guide itself says "always use braces when any branch in an if/else
chain is multi-line," which means the rule is already conditional -- you have to
decide whether this `if` might later grow an `else`. That cognitive load is not
worth saving two characters. MISRA C (Rule 15.6) requires braces
unconditionally. Every modern C style guide that prioritizes safety over brevity
(CERT C, MISRA, JPL) agrees.

The guide cites MISRA C as a source in its introduction. Endorsing braceless
bodies contradicts that source.

**Recommendation:** Remove the braceless exemption. Require braces on all
control structures unconditionally. This is a zero-cost rule that eliminates an
entire class of bugs.

---

### 4. Section 3.6 gives a vague function length range

> "Functions should fit on **one or two screens** (roughly 40-80 lines)."

**Problem:** "One or two screens" is not a meaningful metric -- screen sizes
vary from 24 lines (classic terminal) to 60+ lines (modern monitors). The guide
then cites NASA/JPL at 60 lines and the Linux kernel at 24-48 lines, giving
three different numbers in one paragraph. A reader has no actionable target.

**Recommendation:** Pick a single concrete number as the guideline. 60 lines
(the JPL number) is a good choice: strict enough to encourage decomposition,
lenient enough to not be impractical. State it as a guideline, not a hard limit:
"Aim for **60 lines or fewer** per function. If a function exceeds this, it is
likely doing too much -- extract helpers."

---

### 5. Section 4.3 include order puts standard headers last

> 1. The corresponding header for this `.c` file
> 2. Other project headers
> 3. Third-party library headers
> 4. Standard library headers

**Problem:** This ordering is defensible (and used by Google's C++ style guide)
but the guide does not explain *why* standard headers go last. The rationale for
putting the corresponding header first is well-explained ("ensures it is
self-contained"), but the rationale for demoting standard headers is missing.
Many experienced C developers put standard headers first (the GNU convention)
and will find this ordering counterintuitive without justification.

More importantly, for this project specifically, the C implementation is
freestanding (`-ffreestanding` in CMakeLists.txt). It reimplements `strlen`,
`memcpy`, and `strstr` rather than including `<string.h>`. The include order
discussion is somewhat academic when half the standard library is unavailable.

**Recommendation:** Keep the "corresponding header first" rule (it is
universally good). For the remaining groups, add a one-sentence rationale: "This
ordering ensures project headers fail fast if they have missing includes, rather
than silently depending on standard headers that happened to be included above
them." Also note that in freestanding builds, standard library headers may be
limited or unavailable.

---

### 6. Section 5.5 recommends setting pointers to NULL after free

> "Set pointers to `NULL` after freeing to catch stale access under sanitizers."

**Problem:** This advice is outdated and gives a false sense of security. ASan
already detects use-after-free without the NULL assignment. Setting to NULL
after free *masks* bugs rather than catching them: a subsequent NULL dereference
is caught by the OS, but a NULL check (`if (ptr)`) will silently skip code that
should have run. The real bugs -- dangling aliases in other variables or data
structures -- are not fixed by NULLing one copy.

The Linux kernel explicitly does not follow this pattern. The CERT C standard
(MEM01-C) recommends it, but that recommendation is increasingly considered
debatable in the presence of modern sanitizers.

**Recommendation:** Replace with: "Prefer sanitizers (ASan, MSan) to detect
use-after-free and double-free at the point of occurrence. Setting pointers to
NULL after free is a secondary defense that can mask bugs as easily as it
catches them -- use it judiciously, not as a blanket rule."

---

### 7. Section 8.5 bans `strcpy` but recommends `strncpy` as a replacement

> | `strcpy` | `strncpy` + null termination, or `snprintf` |

**Problem:** `strncpy` is almost never the right replacement for `strcpy`. It
has two well-known foot-guns: (1) it does not null-terminate if the source is
longer than `n`, and (2) it zero-pads the entire remaining buffer, which is
wasteful for large buffers. The guide correctly identifies foot-gun #1 in
Section 8.3, but then still lists `strncpy` as a "safe replacement" in the
table. This is contradictory and misleading.

**Recommendation:** Remove `strncpy` from the "safe replacement" column
entirely. The replacement for `strcpy` is `snprintf(dst, sizeof(dst), "%s",
src)` or a hand-rolled bounded copy. Add `strncpy` to the banned list (or at
minimum a "use with extreme caution" note) since its non-termination behavior is
the root cause of so many vulnerabilities.

---

### 8. Section 9.2 callback pattern lacks a `const` on the context pointer

> ```c
> typedef void (*EventHandler)(int event_type, void *context);
> ```

**Problem:** The callback signature uses `void *context` (mutable). In most
callback patterns, the handler should not need to mutate the context through the
generic pointer. Using `void *` without `const` encourages careless mutation and
is inconsistent with the guide's own emphasis on const correctness (Section
7.1).

**Recommendation:** Show two variants: one with `const void *context` for the
common read-only case, and one with `void *context` for the rare case where
mutation is needed. Explain why the choice matters.

---

### 9. Section 9.4 ARRAY_SIZE macro is not type-safe

> ```c
> #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
> ```

**Problem:** The guide correctly notes "Never use this on pointers -- it will
silently produce the wrong result" and mentions that "some codebases use a
type-safe variant that triggers a compile error on pointers." But then it
provides only the unsafe version. If you know the safe version exists and that
the unsafe version silently produces wrong results, why not show the safe one?

**Recommendation:** Show the type-safe version as the primary recommendation.
For GCC/Clang (which covers every compiler this project targets), the safe
version is straightforward:

```c
#define ARRAY_SIZE(arr) \
    (sizeof(arr) / sizeof((arr)[0]) \
     + 0 * sizeof(&(arr) - (typeof(&(arr)))0))
```

Or with `__builtin_types_compatible_p` for GCC:

```c
#define ARRAY_SIZE(arr) \
    (sizeof(arr) / sizeof((arr)[0]) \
     + 0 * sizeof(char[1 - 2 * __builtin_types_compatible_p( \
         typeof(arr), typeof(&(arr)[0]))]))
```

If portability beyond GCC/Clang is needed, keep the simple version as a
fallback.

---

### 10. Section 10.7 bans `setjmp`/`longjmp` too broadly

> | `setjmp`/`longjmp` | Bypasses cleanup code, error-prone | Structured error handling with return codes |

**Problem:** `setjmp`/`longjmp` have legitimate uses in C, particularly for
implementing error recovery in parsers, test frameworks (implementing
`ASSERT`/`FAIL` that unwind), and coroutines. They are part of the C standard
and well-defined when used correctly. Banning them entirely is dogmatic. The
real issue is that they require discipline around resource cleanup, which is true
of C in general.

**Recommendation:** Downgrade from "banned" to "avoid in library code; use only
when the alternative (deeply nested return-code propagation) is significantly
worse, and ensure all resources are cleaned up across the jump." The guide
already has a strong error-handling section (Section 6) that makes return codes
the default -- that is sufficient without an outright ban.

---

### 11. Missing topic: thread safety and reentrancy

**Problem:** The guide has no section on thread safety or reentrancy. Section
9.1 (`sa_itoa`) uses a `static` local buffer, which is not thread-safe and not
reentrant. The actual codebase uses this pattern (the generated `sa_itoa`
function). For a library that could be called from multi-threaded applications,
this deserves at least a mention.

**Recommendation:** Add a subsection under Section 9 or Section 10 covering:
- Avoid `static` local buffers in functions that may be called from multiple
  threads (the `sa_itoa` pattern is a known hazard)
- Prefer caller-provided buffers over internal static storage
- When `static` storage is unavoidable, document the thread-safety implications
- Use `_Thread_local` (C11) or compiler-specific `__thread` if thread-local
  storage is needed

---

### 12. Missing topic: struct initialization and zero-initialization

**Problem:** The guide covers compound literals (Section 9.3) and designated
initializers, but does not discuss zero-initialization of structs. In C,
`struct foo x = {0};` zero-initializes all members, which is a critical pattern
for security (prevents information leaks from uninitialized padding bytes) and
correctness. The guide should explicitly recommend this.

**Recommendation:** Add to Section 9.3 or as a new subsection: "Zero-initialize
structs at declaration with `= {0}` unless every member is immediately assigned.
This prevents information leaks from uninitialized padding and ensures pointer
members start as NULL."

---

### 13. Section 11.2 recommends `-fno-strict-aliasing` as a hardening flag

> ```bash
> # Conservative optimization assumptions
> -fno-strict-overflow
> -fno-strict-aliasing
> -fno-delete-null-pointer-checks
> ```

**Problem:** `-fno-strict-aliasing` is not a "security hardening" flag. It is a
correctness crutch for code that violates the C standard's strict aliasing
rules. The guide already explains strict aliasing in Section 10.1 and shows the
correct `memcpy` approach. If the code follows the guide's own advice, it does
not need `-fno-strict-aliasing`. Including it in the "hardening" section sends
the wrong message: it tells developers "you might write aliasing violations and
that's fine, we'll just disable the optimization."

`-fno-strict-overflow` has a similar issue -- it is a workaround for code that
relies on signed overflow, which the guide already warns against.

`-fno-delete-null-pointer-checks` is the only genuinely defensive flag of the
three, and even that is debatable.

**Recommendation:** Move these three flags out of the "Security Hardening"
section into a separate "Conservative Optimization" or "Defensive Flags"
subsection, with a note explaining that they are workarounds for code that may
not strictly conform to the C standard. Make it clear that well-written code
following this guide should not need them.

---

### 14. Section 11.3 uses `clang-tidy -checks='*'`

> ```bash
> clang-tidy -checks='*' sayableage.c -- -std=c99
> ```

**Problem:** `-checks='*'` enables every available check, including many that
conflict with each other (e.g., `readability-braces-around-statements` vs.
allowing braceless bodies, various modernization checks that contradict each
other). Running `clang-tidy -checks='*'` on any real codebase produces hundreds
of false positives and contradictory suggestions. No one actually uses this
invocation. It is misleading as an example.

**Recommendation:** Show a realistic invocation with a curated set of checks:

```bash
clang-tidy -checks='-*,bugprone-*,cert-*,clang-analyzer-*,misc-*,performance-*' \
    sayableage.c -- -std=c99
```

Or better, recommend a `.clang-tidy` configuration file, analogous to the
`.clang-format` recommendation in Section 11.5.

---

### 15. The clang-format config contradicts the guide's brace rules

> ```yaml
> BreakBeforeBraces: Linux
> ```

**Problem:** The `Linux` brace style in clang-format puts the opening brace on
the same line for everything *except* function definitions, which get the brace
on the next line. This matches the guide's Section 3.2 recommendation. However,
the `BasedOnStyle: LLVM` base style conflicts with `BreakBeforeBraces: Linux`
in several edge cases (namespace braces, class braces in C++ mode, etc.). Since
this is a C-only project, the practical impact is minimal, but starting from
LLVM and overriding to Linux brace style is an unusual combination.

**Recommendation:** Use `BasedOnStyle: GNU` or `BasedOnStyle: WebKit` as a
starting point if you want function braces on their own line, or simply specify
each brace rule explicitly rather than relying on a base style that you
immediately override. At minimum, add a comment explaining why LLVM + Linux
braces was chosen.

---

## Points of Agreement (highlights)

These are areas where the guide makes notably good calls:

- **C99 baseline with C11 preferred** -- Exactly right for 2024+. C99 is the
  floor, C11 is the target, and specifying explicitly is better than relying on
  compiler defaults.

- **K&R brace style with function braces on their own line** -- The most
  readable C style and the one with the deepest historical precedent.

- **`sizeof(*ptr)` over `sizeof(Type)`** -- A small detail that prevents a
  large class of bugs. Good that this is called out explicitly.

- **The `goto cleanup` pattern** -- Correctly presented as idiomatic C, not a
  code smell. The example is clean and the label naming advice is good.

- **`snprintf` over `sprintf`, always** -- Non-negotiable. Good that this is
  both stated as a rule and reinforced in the banned functions table.

- **Caller-allocated buffers as the preferred pattern** -- This is exactly right
  for a library like sayable-age and matches how the actual API works.

- **The sanitizer section** -- Comprehensive, correct, and practical. The note
  about combining ASan + UBSan is good. The MSan note about Clang-only is
  important and often omitted.

- **The references section** -- Well-curated. The right books, the right
  standards, the right tools. No filler.

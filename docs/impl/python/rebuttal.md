# Rebuttal: Python Style Guide Review

Senior Staff Engineering review of the Python Style Guide (`docs/impl/python/README.md`).

This document identifies guidelines that are technically incorrect, misleading, overly dogmatic, contradictory, or counterproductive. Each entry quotes the specific guideline, explains the problem with technical analysis, and provides a recommended alternative.

---

## 1. Line length: 72 for docstrings is an anachronism presented as current practice

> **Quoted guideline (Section 2):**
> "Line length: 79 characters for code, 72 for docstrings and comments. Teams may agree on up to 99 characters for code, but docstrings and comments stay at 72."

**Problem:** The 72-character limit for docstrings dates from PEP 8's origins in 2001, when 80-column terminals were universal and docstrings were often viewed via `pydoc` in a terminal. In 2026, the ecosystem has moved on. The guide itself recommends Black (line length 88) and Ruff, neither of which enforce 72 for docstrings -- they apply a uniform line length. Telling developers to use Black at 88 while simultaneously insisting docstrings stay at 72 creates a contradiction. Developers will either fight the formatter or ignore the guideline.

Furthermore, the phrasing "docstrings and comments stay at 72" is presented as a hard rule with no exception, which contradicts PEP 8's own preface: "A style guide is about consistency... but know when to be inconsistent."

**Recommendation:** State that the project uses a single consistent line length (88, matching Black/Ruff defaults). Mention 79/72 as PEP 8's historical recommendation for standard-library code, but do not present it as a requirement for this project.

---

## 2. `date.today()` as a default argument is a latent bug presented as correct code

> **Quoted guideline (Section 2, Whitespace):**
> ```python
> def format_age(dob: date, as_of: date = date.today()) -> str:  # space around = with annotation
> ```

**Problem:** This example demonstrates whitespace rules around `=` in annotated function signatures -- but the default value `date.today()` is evaluated once at function definition time, not at call time. This is the exact same class of bug the guide warns about in Section 10 ("Mutable Default Arguments"). While `date.today()` is not mutable, it is temporal: the function will silently use the date from when the module was first loaded, which could be yesterday, last week, or in a long-running process, months ago. This is a well-known footgun.

Using this as a teaching example for whitespace is especially dangerous because a reader scanning the guide is primed to treat examples as correct patterns. A developer who copies this pattern into production will ship a subtle, hard-to-diagnose bug.

**Recommendation:** Replace the example with a safe default:

```python
def format_age(dob: date, as_of: date = date.min) -> str:
```

Or use `None` sentinel:

```python
def format_age(dob: date, as_of: date | None = None) -> str:
```

Either one demonstrates the whitespace rule without teaching a bug. Add a note that `date.today()` as a default argument is a common mistake.

---

## 3. The blanket ban on `@staticmethod` is unjustified and too dogmatic

> **Quoted guideline (Section 5):**
> "Avoid `@staticmethod`. If a method does not use `self` or `cls`, it should probably be a module-level function. Static methods break caller expectations around named arguments and provide no real benefit over free functions."

**Problem:** The claim that static methods "break caller expectations around named arguments" is vague and not technically substantiated. Static methods are callable with the same positional and keyword arguments as any other function. The real issue with `@staticmethod` is narrower: it suggests a method belongs to the class's namespace when it may not need to.

However, there are legitimate uses. `@staticmethod` is appropriate when:
1. The function logically belongs to the class's domain but needs no instance or class state (e.g., a validation helper for a dataclass).
2. Subclasses may want to override the behavior (you cannot override a module-level function).
3. The method is part of an interface defined by an ABC or Protocol that includes static methods.

Banning `@staticmethod` outright forces developers to either (a) use module-level functions that lose their logical grouping, or (b) use `@classmethod` and ignore the `cls` parameter, which is worse.

**Recommendation:** Replace the blanket ban with nuanced guidance: prefer module-level functions when the function has no logical association with the class; use `@staticmethod` when the function logically belongs to the class's namespace or when subclass overriding is a design goal. Note that `@classmethod` should not be used as a replacement for `@staticmethod` just to avoid it.

---

## 4. Global mutable state guidance is too absolute for practical Python

> **Quoted guideline (Section 10):**
> "Avoid module-level mutable variables. They create hidden coupling between components and make testing difficult."
>
> The "Wrong" example is a module-level cache dict with a `get_locale()` function.

**Problem:** Module-level mutable state for caches is one of the most common and well-understood patterns in Python. The standard library itself uses it extensively (`re` caches compiled patterns, `functools.lru_cache` creates module-level mutable state, `logging` maintains a global handler registry). The `get_locale` example shown as "Wrong" is a perfectly standard lazy-loading cache.

The "Better" alternative (a `LocaleRegistry` class) adds boilerplate and shifts the problem: the caller must now manage the registry instance's lifecycle, which means either (a) passing it everywhere via dependency injection (heavy-handed for a locale cache), or (b) instantiating it at module level as a singleton... which is module-level mutable state again, but wrapped in a class.

The guide does not address `functools.lru_cache` or `functools.cache`, which are the idiomatic solutions for exactly this pattern and are both module-level mutable state under the hood.

**Recommendation:** Reframe the guidance: warn against *unstructured* global mutable state that creates hidden side effects. Recommend `functools.cache` / `functools.lru_cache` for memoization patterns. Acknowledge that module-level registries and caches are acceptable when they are clearly documented and have well-defined access patterns. Reserve the class-based approach for cases where the cache has complex lifecycle requirements (e.g., TTL, bounded size, explicit invalidation).

---

## 5. EAFP presented as universally "more Pythonic" than LBYL is misleading

> **Quoted guideline (Section 6):**
> "Python favors **EAFP** (Easier to Ask Forgiveness than Permission) over **LBYL** (Look Before You Leap)."
>
> The EAFP example is `try: value = mapping[key] except KeyError: value = default`, and the guide then shows `dict.get()` as "even more Pythonic."

**Problem:** The guide presents EAFP as categorically preferred, then immediately shows `dict.get()` -- which is LBYL! `dict.get()` checks internally whether the key exists and returns the default without raising an exception. This contradicts the stated principle.

More substantively, EAFP was a practical idiom from a time when Python's `hasattr()` actually called `getattr()` and caught exceptions internally (CPython 2.x). Modern Python has efficient membership testing, `dict.get()`, `getattr(obj, attr, default)`, and other LBYL patterns that are both clearer and faster for the common case. EAFP is still valid when the failure case is rare (exceptions are expensive), but presenting it as a blanket preference is outdated.

Additionally, EAFP with broad exception types is a source of bugs: `try: x = d[key]` catches *any* `KeyError`, including ones raised from inside `__getitem__` overrides or nested dictionary accesses that are unrelated to the intended check.

**Recommendation:** Present EAFP and LBYL as complementary tools. EAFP is preferred when failure is rare and the check would be as expensive as the operation (e.g., file existence then open -- use try/except to avoid TOCTOU races). LBYL is preferred when a clean API exists for it (e.g., `dict.get()`, `hasattr()`, `in` operator) and when the common case needs to be fast. Remove the implication that LBYL is "less Pythonic."

---

## 6. The `isinstance` advice contradicts the type-checking advice

> **Quoted guideline (Section 9, "Type Checking with isinstance"):**
> "Use `isinstance` for type checks, never direct type comparison."
>
> **Quoted guideline (Section 10, "Overusing isinstance Checks"):**
> "Excessive type checking at runtime often signals a design problem. Use polymorphism, protocols, or pattern matching instead."

**Problem:** Section 9 says "always use `isinstance`, never `type()`." Section 10 says "stop using `isinstance`, use polymorphism." A developer reading this sequentially gets contradictory advice with no clear guidance on when each applies.

The real nuance is:
- If you must do a runtime type check, `isinstance` is correct (over `type() is`).
- But you should minimize runtime type checking in favor of structural typing, protocols, and polymorphism.
- Sometimes runtime type checking is unavoidable (deserializers, validators, union dispatch).

The `singledispatch` alternative shown in Section 10 is also not always appropriate -- it only dispatches on the first argument's type and cannot handle more complex dispatch patterns.

**Recommendation:** Consolidate this into a single section with a clear decision tree: (1) prefer polymorphism and protocols for type-varying behavior; (2) when runtime type checks are necessary, use `isinstance`, never `type() is`; (3) for single-argument type dispatch, consider `functools.singledispatch` or `match`/`case`; (4) for complex multi-type inputs (e.g., accepting `str | Path`), `isinstance` is fine and idiomatic.

---

## 7. The acronym naming advice will produce inconsistent results

> **Quoted guideline (Section 1):**
> "Use `CapWords` (PascalCase). Acronyms stay uppercase within the name."
>
> Example: `HTTPServerError` is "good", `HttpServerError` is "acceptable but less conventional."

**Problem:** PEP 8 does not actually say acronyms must stay uppercase. It says to use CapWords and notes only that "abbreviations in CapWords should be capitalized" without being prescriptive about multi-letter acronyms. The Python standard library itself is inconsistent: `HTTPError` (urllib), but `JsonDecodeError` and `IpAddress` would follow the other convention.

The real problem is readability at word boundaries. `HTTPSConnection` -- is that `HTTPS` + `Connection` or `HTTP` + `SConnection`? `XMLHTTPRequest` -- good luck. Google's Python style guide actually recommends capitalizing only the first letter of acronyms (`HttpServerError`) for exactly this reason.

This is a legitimate style choice, but presenting full-caps acronyms as the correct convention and the alternative as merely "acceptable" overstates the consensus.

**Recommendation:** Present both conventions as valid. Note that Python's standard library uses uppercase acronyms (e.g., `HTTPError`), while Google's style guide capitalizes only the first letter. Pick one for this project and state it as a project convention, not a language rule.

---

## 8. The `from __future__ import annotations` advice omits critical caveats

> **Quoted guideline (Section 3):**
> "Use `from __future__ import annotations` to enable postponed evaluation (string-ified annotations), which avoids forward reference issues and slightly reduces import-time overhead."

**Problem:** PEP 563 (`from __future__ import annotations`) makes all annotations into strings that are never evaluated at import time. This has significant consequences the guide does not mention:

1. It breaks any code that uses annotations at runtime, including `@dataclass` field introspection, Pydantic models, FastAPI type resolution, `typing.get_type_hints()` in certain edge cases, and `isinstance()` checks with `runtime_checkable` Protocol.
2. PEP 649 (deferred evaluation of annotations) was accepted for Python 3.14 as the replacement for PEP 563. The future import will eventually become the *non-default* behavior.
3. The combination of `from __future__ import annotations` with `@dataclass` can cause runtime errors when default values reference types that were only strings.

For a guide written in 2026, targeting Python 3.12+, this advice is already becoming stale. PEP 649 in Python 3.14 provides the benefits without the drawbacks.

**Recommendation:** If the project targets Python 3.14+, recommend nothing (PEP 649 is the default). For 3.12-3.13, mention `from __future__ import annotations` as an option but document the caveats: it breaks runtime annotation inspection, including dataclasses, Pydantic, and similar frameworks. Note that PEP 649 supersedes PEP 563 starting in Python 3.14.

---

## 9. `__init__` return type annotation advice is wrong

> **Quoted guideline (Section 3):**
> "Do not annotate `self`, `cls`, or `__init__` return types."

**Problem:** This conflates three different things. Not annotating `self` and `cls` is correct -- their types are inferred. But `__init__` return type annotation (`-> None`) is explicitly recommended by mypy, pyright, and PEP 484. When running mypy in `strict` mode (which this guide recommends), unannotated `__init__` methods will produce errors if `disallow_untyped_defs = true` is set.

The guide's own examples in Section 5 use `def __init__(self) -> None:` in the `Stack` class and `Point` class, directly contradicting this advice.

**Recommendation:** Change to: "Do not annotate `self` or `cls` -- their types are inferred. Always annotate `__init__` with `-> None`."

---

## 10. The logging advice against f-strings is outdated for modern Python

> **Quoted guideline (Section 8):**
> "Pass format strings and arguments separately to logging functions. This avoids formatting the string when the log level is disabled and allows log aggregation tools to group by pattern."
>
> The "Bad" example: `logger.info(f"Processing locale {code} with {len(units)} units")`

**Problem:** The performance argument -- "avoids formatting the string when the log level is disabled" -- is technically correct but practically negligible for the vast majority of code. Python f-string formatting for simple string interpolation takes nanoseconds. Unless you are in a hot loop logging millions of times, the difference is unmeasurable.

The log aggregation argument is more compelling, but it only matters if you are using structured logging tools that group by message template (e.g., Sentry, Datadog). For applications that log to files or stdout (which is what this project does), the grouping benefit does not apply.

Meanwhile, the `%`-style formatting:
- Cannot be type-checked by mypy/pyright (the format string is opaque).
- Silently produces wrong output if argument count mismatches the format string.
- Is harder to read than f-strings for complex expressions.
- Is flagged as a lint issue by some Ruff rules (`G` rules recommend f-strings in logging).

**Recommendation:** Present both approaches with honest trade-offs. Recommend %-style for libraries and code using structured log aggregation. Acknowledge that f-strings in logging are acceptable for application code where readability is prioritized, and note that the performance difference is negligible for most use cases. Do not categorically label f-string logging as "Bad."

---

## 11. The Ruff configuration example enables too few rules for "strict" guidance

> **Quoted guideline (Section 11):**
> ```toml
> [tool.ruff.lint]
> select = [
>     "E",    # pycodestyle errors
>     "W",    # pycodestyle warnings
>     "F",    # pyflakes
>     "I",    # isort
>     "UP",   # pyupgrade
>     "B",    # flake8-bugbear
>     "SIM",  # flake8-simplify
>     "RUF",  # ruff-specific rules
> ]
> ```

**Problem:** For a guide that insists on strict mypy, frozen dataclasses, and zero warnings in CI, this Ruff configuration is surprisingly lax. It omits several high-value rule sets:

- `"C4"` (flake8-comprehensions) -- catches inefficient comprehension patterns.
- `"PTH"` (flake8-use-pathlib) -- the guide recommends pathlib but does not enforce it.
- `"T20"` (flake8-print) -- catches stray `print()` calls in library code.
- `"PL"` (pylint) -- catches a broad class of code quality issues.
- `"PERF"` (perflint) -- catches performance anti-patterns.
- `"N"` (pep8-naming) -- the guide spends an entire section on naming but does not enforce it with tooling.
- `"ANN"` (flake8-annotations) -- the guide insists on type annotations but does not enforce them via linting.

**Recommendation:** Either expand the rule set to match the guide's strictness level, or acknowledge that the shown configuration is a starting point and link to Ruff's rule documentation for teams that want stricter enforcement.

---

## 12. The `__all__` guidance contradicts itself

> **Quoted guideline (Section 4):**
> "Define `__all__` to explicitly declare the public API of a module. This controls what `from module import *` exports (which you should never use anyway) and serves as documentation of the intended public interface."

**Problem:** The parenthetical "(which you should never use anyway)" undermines the primary stated purpose of `__all__`. If wildcard imports are banned, then `__all__`'s functional effect is irrelevant and its only value is as documentation. But as documentation, `__all__` is a poor substitute for proper API documentation, type stubs, or the `_` prefix convention.

The guide should either make a clear case for `__all__` as documentation-of-intent (which it is), or acknowledge that in projects with type annotations and `_`-prefix conventions, `__all__` is optional overhead. As written, it says "always do this thing for a reason that does not apply."

**Recommendation:** Reframe: `__all__` serves two purposes: it controls wildcard imports (relevant for libraries consumed by others) and it documents the intended public API at a glance. Recommend it for packages that are published as libraries. For internal modules, note that the `_` prefix convention is sufficient.

---

## 13. The "Truthiness" section oversimplifies and omits important edge cases

> **Quoted guideline (Section 9):**
> ```python
> # Good
> if items:            # non-empty sequence
> if count:            # non-zero number
>
> # Bad
> if len(items) > 0:
> if count != 0:
> ```

**Problem:** Truthiness checks on sequences are fine. But `if count:` for numeric values is dangerous when `0` is a valid value that should be handled differently from `None` or "not provided." Consider:

```python
def process(count=None):
    if count:      # BUG: treats 0 the same as None
        use(count)
```

The guide should mention that truthiness checks on numbers are only appropriate when zero genuinely means "nothing" or "false." When `0` is a valid value distinct from "absent," use explicit comparison: `if count is not None:`.

Similarly, `if name:` on strings conflates empty string `""` with `None`. In many APIs, an empty string is a valid value that is semantically different from "not provided."

**Recommendation:** Keep the truthiness advice for sequences and booleans. Add a warning about numeric and string truthiness: when `0` or `""` are valid values distinct from "absent," use explicit `is not None` checks. This is one of the most common bugs in Python code.

---

## 14. Missing any mention of docstrings and documentation conventions

**Problem:** The guide covers naming, formatting, types, modules, classes, errors, collections, strings, idioms, anti-patterns, and tooling -- but has zero guidance on docstrings. For a guide that references PEP 257 in its References section, this is a significant omission.

Docstrings are one of the most important aspects of Python style. The guide should cover:
- When to write docstrings (public modules, classes, functions, methods).
- Format: Google style, NumPy style, or reStructuredText -- pick one.
- What to include: summary line, parameter descriptions, return values, exceptions raised.
- The `"""one-liner."""` form versus multi-line form.

**Recommendation:** Add a Docstrings section covering the above. Since the guide already references the Google Python Style Guide, adopting Google-style docstrings is a natural fit.

---

## 15. No guidance on testing patterns beyond a minimal pytest example

**Problem:** Section 11 shows a basic pytest example but provides no guidance on:
- Test file and function naming conventions (`test_` prefix).
- Fixture design and scope.
- When to use `parametrize` vs. individual test functions.
- Mocking and patching patterns (and when not to mock).
- Test organization (unit vs. integration, directory structure).
- `conftest.py` usage.

For a project that mandates 100% test coverage and TDD, the testing section is conspicuously thin.

**Recommendation:** Expand the testing section with guidance on fixtures, parametrization patterns, test naming, and directory structure. At minimum, cover `conftest.py` and fixture scoping, which are the pytest patterns most commonly misunderstood.

---

## Summary

The guide is broadly solid in its fundamentals. The naming, formatting, and type system sections are accurate references. The main issues fall into three categories:

1. **Contradictions and inconsistencies** (items 2, 6, 9, 12) -- guidelines that conflict with each other or with the guide's own examples.
2. **Overly dogmatic positions** (items 3, 4, 5, 7, 10, 13) -- guidelines that present one valid approach as the only correct one, ignoring legitimate alternatives and edge cases.
3. **Significant omissions** (items 1, 8, 11, 14, 15) -- important topics that are either missing or underdeveloped relative to the guide's otherwise comprehensive scope.

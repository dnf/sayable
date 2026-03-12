# C++ Style Guide -- Rebuttal

Review by a Senior Staff Engineer. Each section quotes the specific guideline, explains the problem, and proposes an alternative.

---

## 1. Include guards vs. `#pragma once` -- unjustified dogma

**Quoted guideline:**

> Use traditional include guards. They are portable, work with every compiler, and avoid edge cases with symlinks or network drives that can confuse `#pragma once`.

**Analysis:**

The stated edge cases (symlinks, network drives) are real but vanishingly rare in practice and affect almost nobody in 2026. Every major compiler -- GCC, Clang, MSVC, and ICC -- has supported `#pragma once` for over a decade. The C++ Core Guidelines themselves do not take a position on this. The actual trade-off is:

- Traditional include guards require the programmer to invent a unique macro name, keep it in sync with the file path, and remember to update it on rename. In a project with 110 locale files across multiple directories, this is real maintenance burden and a real source of copy-paste bugs (duplicate guard names silently break compilation in hard-to-diagnose ways).
- `#pragma once` has zero maintenance burden and zero risk of name collision.

The guide's position is defensible for a library shipping as a public C++ header-only package where maximum portability across exotic build environments is a goal. But the guide does not qualify it that way -- it presents it as a universal rule. It should at least acknowledge `#pragma once` as the simpler default and restrict the include-guard recommendation to cases where portability to non-mainstream compilers actually matters.

**Recommendation:**

Present `#pragma once` as the default for internal and application code. Recommend traditional include guards only for public library headers where portability to every conceivable toolchain is an explicit requirement. Mention the duplicate-guard-name failure mode of traditional guards.

---

## 2. Forward declarations -- recommendation inverted from the Core Guidelines

**Quoted guideline:**

> Prefer including the required header over forward declarations.

**Analysis:**

This directly echoes the Google Style Guide, which bans forward declarations primarily because of Google's unusual build system (Blaze/Bazel) and monorepo constraints. The C++ Core Guidelines take the opposite stance -- they encourage forward declarations to reduce coupling and compilation time (see SF.10: "Avoid dependencies on implicitly-`#include`d names" and the general guidance to minimize header dependencies).

The guide's stated concerns are valid (forward declarations can hide dependencies, break on type changes). But "prefer including the header" as a blanket rule leads to deep transitive include chains, longer compile times, and tighter coupling. The guide should instead give balanced advice: use forward declarations when you only need a pointer or reference; include the header when you need the full definition.

The guide already lists the exceptions where forward declarations are appropriate, which contradicts the blanket "prefer including." The guideline and its exceptions should be restructured as a decision rule rather than a default-plus-exceptions pattern.

**Recommendation:**

Replace with: "Use forward declarations when only a pointer, reference, or function signature is needed. Include the full header when you need the complete type definition (sizeof, member access, inheritance). Never forward-declare standard library types."

---

## 3. `kPascalCase` for constants -- mixing Google and Core Guidelines conventions

**Quoted guideline:**

> | Constants | `kPascalCase` | `kMaxBufferSize`, `kDefaultPort` |
> | Constexpr values | `kPascalCase` | `kMaxAgeMonths` |

**Analysis:**

The `k` prefix convention is Google-specific. The C++ Core Guidelines do not recommend it. The guide claims to draw from both sources but does not acknowledge this is a Google-ism that the Core Guidelines community generally avoids. More importantly, the project's own code does not follow this convention:

```cpp
constexpr const char* VERSION = "0.5.0";  // in types.hpp -- ALL_CAPS, not kPascalCase
```

This is an internal contradiction. The guide mandates `kPascalCase` for constants, but the project's own header uses `ALL_CAPS` for a constexpr constant. The guide needs to either follow its own rule or change the rule.

Beyond the inconsistency, the `k` prefix is a Hungarian-notation remnant. It tells you "this is a constant" -- something the compiler already knows and enforces via `const`/`constexpr`. The guide explicitly rejects Hungarian notation for member variables (trailing underscore instead of `m_`), but then uses a prefix convention for constants. This is philosophically inconsistent.

**Recommendation:**

Drop the `k` prefix. Use `PascalCase` for constants (consistent with enum values and types), or use `ALL_CAPS` for true compile-time constants (consistent with existing code and the C/C++ tradition). Either way, the guide and the codebase must agree. Also fix the `VERSION` constant to match whatever convention is chosen.

---

## 4. 4-space indentation -- stated without justification

**Quoted guideline:**

> **4 spaces** per indentation level. No tabs.

**Analysis:**

This is fine as a choice, but the guide presents it without rationale. The C++ Core Guidelines do not mandate a specific indentation width. The Google Style Guide uses 2 spaces. LLVM uses 2 spaces. The Linux kernel uses 8-space tabs. Qt uses 4 spaces.

For a guide that carefully justifies most of its other positions, this one stands out as unjustified assertion. The guide should either justify the choice (e.g., "4 spaces balances readability with horizontal space; it is the most common setting in clang-format's BasedOnStyle presets") or acknowledge it as a project convention rather than presenting it as an inherent best practice.

This is a minor point -- it is a reasonable choice -- but the guide's credibility is stronger when every rule has a visible rationale.

**Recommendation:**

Add a one-line rationale, or frame it as "project convention" rather than an implied universal standard. Also mention that this should be enforced via `.clang-format` rather than relying on human discipline.

---

## 5. Missing `.clang-format` -- the formatting section's biggest gap

**Quoted guideline (by omission):**

The entire section 2 (Code formatting) specifies detailed formatting rules but never mentions `.clang-format` or any automated formatter.

**Analysis:**

This is the most significant omission in the guide. Manually enforcing formatting rules through code review is expensive and error-prone. The industry standard is to define a `.clang-format` file, run `clang-format` in CI, and stop arguing about formatting in reviews. The guide mentions clang-tidy in the Tooling section but somehow omits clang-format entirely.

Every rule in section 2 (brace placement, spacing, line length, blank lines, namespace comments) can be expressed as a `.clang-format` configuration. Without one, these rules are aspirational documentation rather than enforced policy.

**Recommendation:**

Add a `.clang-format` subsection to the Tooling section with a sample configuration that encodes all the rules from section 2. Mention that `clang-format` should be run as a pre-commit hook or CI check.

---

## 6. `std::expected` presented without adequate C++17 fallback guidance

**Quoted guideline:**

> For functions where failure is common and carries information, prefer `std::expected` over exceptions.

**Analysis:**

The guide's target standard is "C++17 minimum, C++20 preferred." `std::expected` is C++23. The guide does mention "(C++23)" in the heading, but then presents it as a recommendation ("prefer `std::expected`") without discussing what to do in the C++17 and C++20 codebases that the guide explicitly targets. Since the project itself builds with C++17 (confirmed in CMakeLists.txt), this recommendation is currently inapplicable to its own code.

The guide should either:
1. Present `std::expected` as a forward-looking note ("when targeting C++23, prefer...") and provide the C++17/C++20 equivalent pattern (return a struct with value + error, or use `std::variant`), or
2. Recommend a polyfill like `tl::expected` for pre-C++23 code.

As written, a developer reading this guide for a C++17 project (like sayable-age) gets a recommendation they cannot follow.

**Recommendation:**

Restructure the error handling section to give concrete C++17 patterns first (since that is the minimum target), then present `std::expected` as the modern replacement available in C++23. Mention `tl::expected` as a polyfill option.

---

## 7. `std::variant` example uses undefined `overloaded` helper

**Quoted guideline (code example):**

```cpp
std::visit(overloaded{
    [](int i)               { process_int(i); },
    [](const std::string& s){ process_string(s); },
}, value);
```

**Analysis:**

The `overloaded` helper is not part of the C++ standard library. It is a commonly shown pattern that requires a user-defined deduction guide:

```cpp
template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;
```

The guide uses `overloaded` in a code example without defining it or noting that it is not standard. A developer unfamiliar with this pattern will get a compilation error and be confused. The C++23 standard does not add this either -- it remains a user-provided utility.

**Recommendation:**

Either define the `overloaded` helper in the example (or show where to put it), or note that it is a user-defined utility that must be provided. Alternatively, show the `std::visit` example with a named visitor struct, which is self-contained.

---

## 8. Sanitizer section claims ASan and UBSan can be combined -- needs qualification

**Quoted guideline:**

> Run all three in separate CI jobs. ASan and UBSan can be combined; TSan must run separately.

**Analysis:**

This is technically correct but incomplete. Combining ASan and UBSan works on GCC and Clang, but the combined binary runs roughly 2-3x slower than ASan alone. The guide should mention the performance implications so teams can make informed decisions about CI job configuration. It should also mention MSan (MemorySanitizer), which catches uninitialized memory reads and is not covered at all.

**Recommendation:**

Add MSan to the sanitizer list. Note the performance cost of combining sanitizers. Mention that ASan and MSan cannot be combined (they conflict).

---

## 9. The guide says nothing about testing

**Analysis:**

This is a significant omission for a comprehensive style guide. The guide covers formatting, idioms, types, headers, classes, error handling, templates, the standard library, anti-patterns, and tooling -- but says nothing about testing conventions. The project itself has a test file with hand-rolled test macros (ASSERT_EQ, ASSERT_NULL, etc.) and no test framework. A style guide should at minimum address:

- Test file naming and organization (the guide mentions `_test.cpp` or `test_*.cpp` in the header extensions section but says nothing else)
- Test framework recommendation (Catch2, GoogleTest, doctest -- or a rationale for the hand-rolled approach)
- Test naming conventions
- What to test and what not to test

Given that the project's CLAUDE.md mandates TDD and 100% coverage, the style guide's silence on testing is a notable gap.

**Recommendation:**

Add a testing section covering framework choice, file organization, naming conventions for test cases, and the relationship between `tests.json` canonical tests and C++ test implementations.

---

## 10. `constexpr const char*` in the actual code -- the guide should address `constexpr` string constants

**Analysis:**

The project's `types.hpp` has:

```cpp
constexpr const char* VERSION = "0.5.0";
```

This is a `constexpr` pointer to a string literal, which is fine but subtly different from `constexpr std::string_view`. The guide's section on `constexpr` shows numeric examples only and does not address string constants. For C++17 and later, `constexpr std::string_view` or `inline constexpr std::string_view` is generally preferred over `constexpr const char*` because it carries the length and works with the `std::string_view` ecosystem. The guide should address this common pattern.

**Recommendation:**

Add guidance on string constants: prefer `inline constexpr std::string_view` over `constexpr const char*` in C++17 and later. Mention the ODR (One Definition Rule) implications of `constexpr` vs `inline constexpr` in headers.

---

## 11. CMake minimum version 3.14 is dated

**Quoted guideline:**

> Use **CMake** (3.14+) as the build system.

**Analysis:**

CMake 3.14 was released in 2019. As of 2026, CMake 3.21+ is a reasonable minimum, and 3.25+ is common. CMake 3.14 lacks several important features: `target_sources(FILE_SET)` (3.23), `CMAKE_CXX_STANDARD 23` support (3.20), improved presets (3.19+), and `FetchContent_MakeAvailable` improvements. The guide should recommend a more current minimum or at least note what features require higher versions.

**Recommendation:**

Update the minimum CMake version recommendation to 3.21+ (which added `CMAKE_CXX_STANDARD 23` and better toolchain file support), and note that the project itself may choose a different minimum based on its platform support matrix.

---

## 12. Minor issues

### `WarningsAsErrors: ''` in the `.clang-tidy` example

The example `.clang-tidy` config sets `WarningsAsErrors: ''` (empty string), meaning no warnings are treated as errors. This contradicts the guide's philosophy of zero-warning builds. The style guide should either set this to `'*'` in the example or explain why it is intentionally left empty (e.g., during initial adoption).

### No mention of `[[nodiscard]]`

The guide covers `noexcept`, `override`, `final`, and `explicit` but omits `[[nodiscard]]`, which is arguably the most impactful attribute for API correctness. Functions returning `std::optional`, error codes, or newly created objects should almost always be `[[nodiscard]]`. This is a significant omission for a guide targeting C++17+.

### No mention of `std::format` (C++20)

The guide recommends `'\n'` over `std::endl` but does not mention `std::format` as a replacement for `iostream` formatting. For a guide that targets C++20, this is worth addressing.

---

## Summary

The guide is well-structured, well-written, and covers most of the important ground. Its biggest strengths are the clear rationale sections, the consistent use of good/bad code examples, and the comprehensive compiler warning flags. The issues I have identified fall into three categories:

1. **Internal contradictions**: The `kPascalCase` convention vs. actual code, `WarningsAsErrors` being empty, and the C++23 recommendation for a C++17 project.
2. **Significant omissions**: `.clang-format`, testing, `[[nodiscard]]`, `std::format`, and string constant guidance.
3. **Overly dogmatic positions**: Include guards vs. `#pragma once`, and forward declaration discouragement, both of which present one valid option as the only option without adequate justification.

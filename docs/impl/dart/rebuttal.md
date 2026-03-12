# Rebuttal: Dart Style Guide

Reviewed by a Senior Staff Engineer. This document covers areas of disagreement, concern, or omission in the Dart Style Guide at `docs/impl/dart/README.md`.

---

## 1. "When NOT to Use async" -- Contradictory Example

**Quoted guideline:**

> ```dart
> // Good -- just forwarding
> Future<int> fetchCount() => http.get(uri).then((r) => int.parse(r.body));
>
> // Bad -- async adds no value here
> Future<int> fetchCount() async {
>   final response = await http.get(uri);
>   return int.parse(response.body);
> }
> // (Actually the async version is fine if you want try/catch, logging, etc.)
> ```

**Analysis:**

This example directly contradicts itself. It labels the `async`/`await` version as "Bad", then immediately backtracks in a parenthetical saying it is actually fine. A style guide must not present a pattern as bad and acceptable in the same breath. Furthermore, the `async`/`await` version has a concrete advantage the guide is ignoring: if `int.parse` throws, the `async` version wraps the error in the returned Future (asynchronous error), while the `.then()` version throws synchronously from `int.parse` inside the `.then` callback -- but the `http.get` error propagation differs subtly between the two forms. The "just forwarding" rationale is a micro-optimization (avoiding one state machine allocation) that is rarely meaningful and comes at the cost of inconsistent error propagation behavior.

The guideline earlier in the same section says "PREFER `async`/`await` over raw `.then()` chains", which is correct. This counterexample undermines that good advice.

**Recommendation:**

Remove the "When NOT to Use async" section entirely, or rewrite it to be much narrower: only omit `async` when the function body is a single `return someOtherFuture;` with no transformation. The `.then()` example should not be presented as preferable.

---

## 2. "Storing Computed Values" -- Overly Dogmatic

**Quoted guideline:**

> AVOID caching computed values in fields unless profiling proves it necessary. Stale caches cause subtle bugs. Compute on demand.
>
> ```dart
> // Bad -- redundant cache
> class Circle {
>   final double radius;
>   final double area;
>   Circle(this.radius) : area = pi * radius * radius;
> }
> ```

**Analysis:**

The example labeled "Bad" is actually a perfectly reasonable pattern when the class is immutable (all fields are `final`). In an immutable class there is no stale-cache risk because the inputs can never change after construction. Pre-computing `area` once in the initializer list of an immutable `Circle` is a valid design choice, especially if `area` is accessed frequently. The "stale cache" warning only applies to mutable objects.

**Recommendation:**

Qualify this advice: caching is dangerous on mutable classes, but pre-computing derived values in immutable (all-`final`) classes via initializer lists is safe and sometimes desirable. The example should use a mutable class to illustrate the actual danger.

---

## 3. "Avoid classes with only static members" -- Needs Nuance

**Quoted guideline:**

> **Avoid classes with only static members.** Use top-level functions and variables. Libraries serve as namespaces in Dart.

**Analysis:**

This is generally good advice, but the guide presents it as absolute. There are legitimate cases for static-only classes in Dart: when you want to group a set of related constants or factory methods under a discoverable name in an IDE autocomplete, or when you want to prevent instantiation while providing a clear namespace in a large library. The standard library itself uses this pattern (e.g., `Platform` contains only static members). Simply saying "avoid" without acknowledging the exceptions is misleading for an auditing guide.

**Recommendation:**

Add a qualifier: "Prefer top-level functions and variables for utility code. Static-only classes are acceptable when a namespace improves discoverability in large APIs, but do not create them reflexively."

---

## 4. Wildcard Parameters -- Version Gate Is Incomplete

**Quoted guideline:**

> In Dart 3.7+, name unused parameters `_` (wildcard). For earlier versions, use `__` or `___` to avoid collisions.

**Analysis:**

Wildcard declarations (`_`) were introduced in Dart 3.0 as part of patterns, but single `_` as a non-binding wildcard in regular parameter lists was only stabilized in Dart 3.1 (with the `wildcard-variables` language feature). The guide says "Dart 3.7+" which is not the correct version. As of writing, Dart 3.7 has not been released -- the current stable is in the 3.x range below that. This is factually wrong and will confuse readers who check the version number.

**Recommendation:**

Correct the version number. Wildcard variable declarations (`_`) in non-pattern contexts were stabilized in Dart 3.5. Verify against the actual Dart changelog before publishing.

---

## 5. analysis_options.yaml Example -- Includes Deprecated and Redundant Configuration

**Quoted guideline:**

The `analysis_options.yaml` example includes:
```yaml
include: package:lints/recommended.yaml
```
and then manually lists rules like `camel_case_types`, `constant_identifier_names`, `unnecessary_new`, etc.

**Analysis:**

If you include `package:lints/recommended.yaml`, many of those individually listed rules are already enabled by the included rule set. Listing them again is noise and creates a maintenance burden -- if the recommended set adds or changes rules, you now have duplicates. The guide should either show a minimal config that extends the recommended set and only adds/overrides what is needed, or show a standalone config without the `include`. Showing both is confusing.

Additionally, the example includes `library_names` which has been deprecated in favor of `library_prefixes` and the general `file_names` rule. Including deprecated lint rules in an auditing reference is problematic.

Also, the example is missing `strict-inference: true` in the `analyzer.language` block, despite the guide recommending it in Section 3 under "Strict Mode". The example should match the guide's own recommendations.

**Recommendation:**

Show two example configs: (1) a minimal one that extends `package:lints/recommended.yaml` and only adds project-specific overrides, and (2) note that the full standalone list exists in the linter rules catalog. Remove `library_names` or note its deprecation. Add `strict-inference: true` to match Section 3.

---

## 6. Missing: Effective Dart's `prefer_relative_imports` vs `prefer_adjacent_string_concatenation`

**Analysis:**

The guide covers import ordering but does not mention the `prefer_relative_imports` linter rule, which is relevant for package-internal imports. The Effective Dart guidelines recommend relative imports for files within the same package's `lib/` directory. This is a common source of inconsistency in Dart projects and is worth calling out explicitly, especially since the actual project codebase uses relative imports (e.g., `import 'types.dart';` in `format_age.dart`).

**Recommendation:**

Add a note in the Import Ordering section: "Within a package's `lib/` directory, prefer relative imports over `package:` imports for internal files." Reference `prefer_relative_imports`.

---

## 7. Missing: Sealed Classes and Exhaustive Switching

**Analysis:**

The guide mentions `sealed class` in the Class Modifiers table but does not explain its primary purpose: enabling exhaustive `switch` expressions. This is one of the most important Dart 3.0+ features for modeling closed type hierarchies, and it is directly relevant to patterns like `PluralCategory` and `Compactness` enums already in use in this project. The guide should show how `sealed` + `switch` expressions provide compile-time exhaustiveness checking.

**Recommendation:**

Add a short subsection under Class Modifiers or Pattern Matching showing how `sealed` classes enable exhaustive switching, with a practical example.

---

## 8. Missing: Extension Types (Dart 3.3+)

**Analysis:**

The guide covers extensions but omits extension types, which were introduced in Dart 3.3 and serve a different purpose: zero-cost wrappers that provide a different interface to an existing type without runtime overhead. This is a significant language feature that an auditing guide should at least mention, since it is easy to confuse extension methods with extension types.

**Recommendation:**

Add a brief subsection distinguishing extension methods (add methods to existing types) from extension types (create zero-cost wrapper types with a different API surface).

---

## 9. "DO NOT catch Error or its subtypes" -- Too Absolute

**Quoted guideline:**

> **DO NOT catch `Error` or its subtypes.** Let them propagate and crash. Fix the bug instead.

**Analysis:**

This is good default advice but is stated too absolutely. In practice, there are legitimate reasons to catch `Error` subtypes: test frameworks catch them, error-reporting/crash-logging infrastructure catches them to report before rethrowing, and long-running servers may catch `Error` in an isolate's top-level handler to log and restart. A style guide that says "DO NOT" with no escape hatch will be ignored by engineers who encounter these valid use cases, which undermines the guide's credibility.

**Recommendation:**

Soften to: "AVOID catching `Error` or its subtypes in application code. They indicate programmer mistakes that should be fixed at the source. Catching `Error` is acceptable in infrastructure code (crash reporters, test runners, isolate supervisors) that logs and rethrows or terminates gracefully."

---

## 10. Null-Shorting Cascade Example Has a Bug

**Quoted guideline:**

> ```dart
> querySelector('#confirm')
>   ?..text = 'Confirm'
>   ..classes.add('important');
> ```

**Analysis:**

This is misleading. The null-shorting cascade `?..` only applies to the first cascade operation. The second `..classes.add('important')` is not null-safe in this chain -- if `querySelector` returns null, the `?..` short-circuits the entire cascade chain, but the syntax shown mixes `?..` and `..` which can confuse readers into thinking only the first operation is null-safe. In reality, null-shorting does cover the whole chain, but mixing the two syntaxes looks like a mistake and the official Dart docs show consistent `?..` usage. The example should either use `?..` on all cascade operations, or explain that `?..` at the start short-circuits the entire chain.

**Recommendation:**

Add a one-sentence clarification that `?..` at the beginning of a cascade chain short-circuits all subsequent `..` operations in that chain, so mixing is intentional.

---

## 11. Section 8 "Effective Dart Principles" Is Largely Redundant

**Analysis:**

Section 8 repeats advice already given in detail in Sections 1-7 (formatting, naming, imports, documentation). It reads like a bullet-point summary of the Effective Dart guide pasted in without regard for what the document already covers. This creates two places a reader must check for the same rule, with slightly different phrasings that could diverge over time.

**Recommendation:**

Either remove Section 8 entirely and let the detailed sections stand on their own, or convert it into a concise "Quick Reference Checklist" at the end of the document that explicitly cross-references the detailed sections rather than restating them.

---

## 12. "final vs var" Fence-Sitting

**Quoted guideline:**

> Choose one convention (`final` for non-reassigned locals vs `var` everywhere) and apply it consistently across the codebase.

**Analysis:**

The guide enables the `prefer_final_locals` linter rule in the recommended `analysis_options.yaml`, which means the tooling enforces `final` for non-reassigned locals. Then the prose says choosing `var` everywhere is "also acceptable per some team conventions." A style guide should not recommend enabling a linter rule and then say violating it is fine. This project's actual codebase uses `var` extensively in `format_age.dart` (e.g., `var result`, `var clampedBirthday`, `var months`), which would conflict with `prefer_final_locals`.

**Recommendation:**

Pick one. Given that the actual codebase uses `var` for locals that get reassigned and `final` for locals that do not, state that as the convention and keep `prefer_final_locals` enabled. Remove the hedge about `var` everywhere being acceptable -- it conflicts with the linter config the guide itself recommends.

---

## Summary

The guide is a solid, well-organized reference that covers most of what an engineer needs for Dart auditing. The sources are authoritative and the structure is logical. The issues above are mostly about internal consistency (contradictory advice, examples that undermine the stated rules), factual accuracy (version numbers, deprecated rules), and completeness (missing Dart 3.3+ features). None of these are fatal, but a style guide loses authority when it contradicts itself or gets details wrong.

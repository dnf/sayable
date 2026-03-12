# Rebuttal: Groovy Style Guide Review

Reviewed by: Senior Staff Engineer
Date: 2026-03-11

---

## Overview

The style guide is well-structured and covers a broad set of Groovy idioms. Most of the naming, formatting, and tooling sections are solid. However, several guidelines are either technically misleading, internally contradictory, impractical for this codebase, or promote patterns that create more problems than they solve. This rebuttal covers each disagreement in detail.

---

## 1. `@CompileStatic` is recommended but not reflected in reality

### Guideline quoted

> **Section 4 (Type System):** Apply `@CompileStatic` to library code and performance-critical code. It enables compile-time type checking and generates faster bytecode by bypassing the Groovy Meta-Object Protocol (MOP).

> **Section 10 (Things to Avoid):** Library code should use `@CompileStatic` for type safety and performance.

> **Section 11 (Tooling):** `ast(groovy.transform.CompileStatic)` -- apply `@CompileStatic` globally

### Why it is problematic

The guide emphatically recommends `@CompileStatic` in three separate sections and even shows how to apply it globally via `compiler-config.groovy`. Yet the actual project's `compiler-config.groovy` is empty (it contains only a comment), and none of the source files use `@CompileStatic`. The `AgeLocale` class uses `Closure<PluralCategory>` and `Closure<String>` fields with `.call()` invocations. The `SayableAge` class references a package-level `static Closure<LocalDate> timeNow`. These patterns are fundamentally incompatible with `@CompileStatic` without significant refactoring, because `@CompileStatic` does not fully support Groovy closures as first-class typed callables in all contexts.

A style guide that mandates something the codebase it governs cannot actually adopt is worse than no guidance at all -- it trains engineers to ignore the guide. If you tell people "always do X" but the canonical code never does X, the guideline becomes noise.

### Recommended alternative

Acknowledge the tension honestly. `@CompileStatic` is appropriate for code that does not rely on closures as first-class function objects or dynamic dispatch. Recommend it for new utility classes and pure computation, but do not present it as a blanket requirement for all library code. Remove the suggestion to enable it globally via `compiler-config.groovy` unless the team is prepared to refactor all closure-based code to use `java.util.function` interfaces instead. If the project uses closures extensively (as this one does), say so and explain the trade-off.

---

## 2. The `NoDef` CodeNarc rule recommendation contradicts the guide's own `def` guidance

### Guideline quoted

> **Section 4 (Type System):** Local variables may use `def` when the type is obvious from context.

> **Section 11 (Tooling):** Notable convention rules to consider enabling: **NoDef** -- eliminate `def` in favor of explicit types

### Why it is problematic

These two guidelines directly contradict each other. Section 4 gives reasonable guidance: use explicit types on public APIs, allow `def` for locals where the type is obvious. Then Section 11 recommends enabling `NoDef`, which would flag every `def` in the codebase as a violation -- including the exact patterns Section 4 just approved.

The actual project code uses `def` frequently for local variables (e.g., `def parts`, `def count`). Enabling `NoDef` would either require rewriting hundreds of lines across the codebase or immediately create a disconnect between the linter configuration and the style guide.

### Recommended alternative

Remove `NoDef` from the recommended CodeNarc rules. The Section 4 guidance is correct: explicit types on API boundaries, `def` permitted for locals with obvious types. The tooling section should recommend CodeNarc rules that are consistent with the style guide, not rules that contradict it.

---

## 3. The `ImplicitClosureParameter` rule recommendation undermines idiomatic Groovy

### Guideline quoted

> **Section 11 (Tooling):** Notable convention rules to consider enabling: **ImplicitClosureParameter** -- flag implicit `it` usage

### Why it is problematic

The guide explicitly endorses `it` for simple one-liners in Section 3 and Section 10:

> Fine: simple one-liner
> `names.collect { it.toUpperCase() }`

Enabling `ImplicitClosureParameter` would flag this exact pattern. Implicit `it` is one of the most widely used Groovy idioms, and the guide itself correctly identifies when it is appropriate vs. when named parameters are better. The CodeNarc rule is a sledgehammer where the guide already provides a scalpel.

### Recommended alternative

Remove `ImplicitClosureParameter` from the recommended rules. The nuanced guidance in Sections 3 and 10 (use `it` for trivial one-liners, name parameters for multi-line or nested closures) is the correct approach. A binary lint rule cannot capture this nuance.

---

## 4. The `TrailingComma` rule recommendation is presented without justification

### Guideline quoted

> **Section 11 (Tooling):** Notable convention rules to consider enabling: **TrailingComma** -- require trailing commas in multiline list/map literals

### Why it is problematic

Trailing commas are a matter of preference, not correctness. The guide mentions this rule without explaining why it would be valuable. In a locale-heavy codebase where map and list literals are generated by codegen, mandating trailing commas creates a constraint on the code generator that provides marginal benefit. The primary argument for trailing commas (cleaner git diffs when appending elements) applies mainly to hand-edited code, not generated code.

Furthermore, the guide never mentions trailing commas anywhere in its formatting section (Section 2) or collections section (Section 6). Recommending a CodeNarc rule for a convention the guide itself never establishes is inconsistent.

### Recommended alternative

Either add trailing comma guidance to the formatting or collections section and then reference the CodeNarc rule, or remove the rule recommendation. Do not recommend lint rules for conventions the guide does not define.

---

## 5. The untyped catch advice is misleading about what it catches

### Guideline quoted

> **Section 7 (Error Handling):** When you do not need the specific exception type, you can omit the type entirely. The untyped catch variable will catch all `Exception` subclasses (not `Throwable`).

### Why it is problematic

This statement is factually incorrect in some Groovy versions and contexts. The behavior of an untyped catch has varied across Groovy versions. In Groovy 2.x, an untyped catch (`catch (e)`) catches `Exception`. But this is not guaranteed by a language specification; it is implementation behavior. More importantly, the example names the variable `any`, which is misleading -- it implies it catches anything, but the guide's own text says it does not catch `Throwable`. The naming creates a false sense of completeness.

Additionally, the guide does not clarify that under `@CompileStatic`, untyped catch blocks may behave differently or may not compile at all depending on the version, which directly conflicts with the guide's own strong recommendation to use `@CompileStatic` everywhere.

### Recommended alternative

Recommend always specifying the exception type explicitly. This is clearer, works consistently across compilation modes, and avoids version-dependent behavior. The untyped catch pattern saves a few characters but introduces ambiguity about what is actually caught. If the guide wants to mention it, it should be presented as an awareness item ("you may see this in existing code"), not as a recommended pattern.

---

## 6. The `@Immutable` section omits critical caveats

### Guideline quoted

> **Section 5 (Class Design):** `@Immutable` -- Creates immutable value objects with defensive copying and unmodifiable collections. Combines `@ToString`, `@EqualsAndHashCode`, and constructor generation. All fields become final.

### Why it is problematic

The guide presents `@Immutable` without mentioning its significant constraints:

1. All fields must be of known immutable types (primitives, `String`, other `@Immutable` classes, etc.), or you must explicitly declare them with `@Immutable(knownImmutableClasses = [...])`. Using `Closure`, `List`, `Map`, or custom classes without this annotation causes runtime errors or silently wraps collections.
2. `@Immutable` does not work with `@CompileStatic` in all cases (again conflicting with the guide's blanket recommendation).
3. The annotation was moved to `groovy.transform.Immutable` in Groovy 2.x and underwent behavioral changes in Groovy 3.x and 4.x. Code that works under one version may break under another.
4. The actual project's `AgeLocale` class -- the primary data type -- cannot use `@Immutable` because it contains `Closure` fields. A style guide for this codebase should acknowledge this rather than presenting `@Immutable` as a simple drop-in.

### Recommended alternative

Keep the `@Immutable` section but add caveats about field type restrictions, the `knownImmutableClasses` parameter, and incompatibility with closure-typed fields. Since the project's own locale type cannot use it, note that `@Immutable` is best suited for simple value objects with primitive and string fields.

---

## 7. The `with` / `tap` recommendation is incomplete and potentially confusing

### Guideline quoted

> **Section 9 (Common Idioms):** `with` executes a closure with `this` set to the receiver and returns the closure's last expression.

### Why it is problematic

The description says `with` sets `this` to the receiver. This is not accurate. `with` sets the *delegate* of the closure to the receiver and uses `DELEGATE_FIRST` resolution strategy. `this` inside a closure always refers to the enclosing class instance in Groovy -- it cannot be reassigned. This is a subtle but important distinction that affects how name resolution works, especially when the enclosing class has properties with the same names as the receiver.

An engineer reading this guide who encounters a name collision between the delegate and the enclosing class will be confused because the guide told them `this` was set to the receiver, which is not what happened.

### Recommended alternative

Use precise terminology: "`with` sets the closure's delegate to the receiver with `DELEGATE_FIRST` strategy, so unqualified property and method references resolve against the receiver first." This is the accurate description and helps engineers understand what happens during name conflicts.

---

## 8. The import ordering recommendation is impractical for this codebase

### Guideline quoted

> **Section 2 (Code Formatting):** Group imports in this order, separated by blank lines: 1. `java.*` / `javax.*` 2. Third-party libraries 3. `groovy.*` / Groovy-specific 4. Project-internal packages

### Why it is problematic

This is a fine general-purpose convention, but the project has zero dependencies. The "third-party libraries" group will always be empty. A four-tier ordering scheme with one perpetually empty tier adds cognitive overhead without benefit.

More importantly, the actual test file in the project (`FormatAgeTest.groovy`) does not follow this ordering: it imports `org.junit.jupiter` (which would be "third-party") and `java.time` (which is `java.*`) and `sayableage.*` (project-internal), but they are not separated by blank lines into the prescribed groups. A guideline that the existing code does not follow and that no one enforces is dead text.

### Recommended alternative

Simplify to two groups: (1) standard library and framework imports, (2) project imports. Alternatively, specify alphabetical ordering without grouping and configure CodeNarc or the IDE formatter to enforce it. The simpler the rule, the more likely it is followed.

---

## 9. The flow typing example encourages bad practice

### Guideline quoted

> **Section 4 (Type System):** Groovy's type checker performs flow typing -- a variable's inferred type changes as it is reassigned:
> ```groovy
> def o = 'foo'
> o = o.toUpperCase()    // o is String here
> o = 9d
> o = Math.sqrt(o)       // o is double here
> ```

### Why it is problematic

The example shows a variable being reassigned across completely unrelated types (`String` to `double`). This is exactly the kind of code that flow typing *enables* but that no style guide should *encourage*. Reusing a variable for semantically unrelated values makes code harder to read, reason about, and debug.

The guide presents this as a feature explanation with no warning that this pattern is an anti-pattern in practice. An engineer reading this might conclude that the guide endorses type-shifting reassignment, which it should not.

### Recommended alternative

Keep the flow typing explanation (engineers need to know the feature exists) but explicitly label the example as a demonstration of the mechanism, not a recommended pattern. Add a note: "In practice, avoid reassigning variables to unrelated types. Use separate variables with descriptive names."

---

## 10. The optional return guidance is too permissive

### Guideline quoted

> **Section 9 (Common Idioms):** The last expression in a method is implicitly returned. Omit `return` for short methods where intent is clear.

### Why it is problematic

The actual project code (`SayableAge.groovy`) uses explicit `return` statements throughout, including in methods that are simple enough to use implicit return. The guide says "omit `return` for short methods" but does not define "short." Is 3 lines short? 5 lines? The ambiguity means two engineers will make different choices, creating inconsistency within the codebase.

More critically, implicit return can mask bugs. If someone adds a line at the end of a method during refactoring, the return value silently changes. Explicit `return` makes the intent unambiguous.

### Recommended alternative

Take a stronger position: use explicit `return` in all methods that return a value, with a narrow exception for single-expression methods and property-style getters. This matches what the actual codebase does and eliminates the ambiguity of "short" vs. "not short."

---

## 11. The guide is silent on Groovy version compatibility

### Why it is problematic

The guide references features from different Groovy versions (`?=` is Groovy 3.0+, `::` is Groovy 3+, `invokedynamic` default in Groovy 4+) but never states which Groovy version the project targets. The `build.gradle` shows `localGroovy()` as the dependency, meaning the Groovy version comes from whatever Gradle bundles. Engineers need to know which features are safe to use.

### Recommended alternative

Add a section at the top specifying the minimum supported Groovy version and listing which features are available. This turns scattered version annotations into a clear compatibility matrix.

---

## 12. The Spock Framework section is irrelevant to the project

### Guideline quoted

> **Section 11 (Tooling):** Spock is the preferred testing framework for Groovy.

### Why it is problematic

The project uses JUnit 5, not Spock. The `build.gradle` depends on `org.junit.jupiter:junit-jupiter:5.10.1`. The test file extends no Spock `Specification` class. Declaring Spock as "preferred" in a style guide for a project that uses JUnit 5 is contradictory. An engineer reading this guide would either (a) attempt to use Spock for new tests, creating framework inconsistency, or (b) learn to distrust the guide.

### Recommended alternative

If the project uses JUnit 5, the guide should document JUnit 5 conventions and remove or demote the Spock section to "alternative framework" status. If the team intends to migrate to Spock, state that explicitly with a timeline. Do not declare a preference that conflicts with the actual dependency.

---

## 13. The guide recommends `sort(false)` without explaining the foot-gun

### Guideline quoted

> **Section 6 (Collections):** Note: `sort()` and `unique()` mutate the original list. Use `sort(false)` or `toUnique()` for non-mutating versions.

### Why it is problematic

This is a dangerous one-liner footnote for what is a well-known Groovy foot-gun. `sort()` and `unique()` mutating in place violates the principle of least surprise for engineers coming from any other language where `sort` returns a new collection. A parenthetical note at the end of a code block is not sufficient for a mutation hazard that has caused bugs in production Groovy codebases for years.

Furthermore, the examples above the note all show the mutating versions without any indication that they modify the input:

```groovy
def sorted = [3, 1, 2].sort()           // [1, 2, 3]
def unique = [1, 2, 2, 3, 3].unique()   // [1, 2, 3]
```

These examples are safe only because the lists are inline literals that are never referenced again. But the pattern -- `def x = list.sort()` -- looks identical to a non-mutating call, and an engineer following this example on a pre-existing list will introduce a mutation bug.

### Recommended alternative

Promote this warning to a dedicated subsection titled "Mutation hazard: `sort()` and `unique()`". Lead with the non-mutating versions (`sort(false)`, `toSorted()`, `toUnique()`) as the default recommendation. Show the mutating versions only as a deliberate optimization for when mutation is acceptable. Make the danger impossible to miss.

---

## 14. The `@Canonical` recommendation lacks version awareness

### Guideline quoted

> **Section 5 (Class Design):** `@Canonical` -- A meta-annotation combining `@ToString`, `@EqualsAndHashCode`, and `@TupleConstructor`. Use it for simple data classes.

### Why it is problematic

`@Canonical` has known issues with inheritance hierarchies and has undergone behavioral changes across Groovy versions. In Groovy 4.x, the recommended approach for simple data classes shifted toward records (Java-style `record` classes are supported). Recommending `@Canonical` without mentioning records (available since Groovy 4.0 with JDK 16+) or sealed classes means the guide is already dated.

### Recommended alternative

Mention `@Canonical` as a viable option for Groovy 2.x/3.x codebases, but also mention Groovy 4.x records as the modern alternative. Let the team choose based on their target version.

---

## Summary

The guide is strongest in its naming conventions, formatting rules, collections reference, and string type taxonomy. It is weakest where it:

1. Makes recommendations that conflict with the actual codebase (Spock, `@CompileStatic` everywhere, import ordering)
2. Contains internal contradictions (Section 4 vs. `NoDef` rule, `it` guidance vs. `ImplicitClosureParameter` rule)
3. Presents technically inaccurate descriptions (`with` and `this`, untyped catch behavior)
4. Buries critical warnings (`sort()` mutation, `@Immutable` constraints)
5. Omits essential context (target Groovy version, `@Canonical` vs. records)

A style guide should describe the code the team actually writes, enforced by the tools the team actually runs. Where there is a gap between aspiration and reality, the guide should acknowledge it explicitly rather than pretending it does not exist.

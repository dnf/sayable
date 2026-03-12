# Kotlin Style Guide -- Senior Engineering Review

Reviewer: Senior Staff Engineer
Date: 2026-03-11
Document under review: `docs/impl/kotlin/README.md`

---

## Overall Assessment

The guide is generally solid and covers the right topics. The sources are authoritative, the code examples are accurate, and it correctly emphasizes Kotlin's strengths (null safety, data classes, sealed classes, expression-oriented style). However, there are several guidelines that are overly rigid, internally contradictory, technically imprecise, or that present contextual advice as absolute rules. This review identifies each such issue and proposes a concrete alternative.

---

## Disagreement 1: Acronym Handling Is Internally Contradictory

### Quoted Guideline

> Two-letter acronyms stay fully uppercase. Longer acronyms capitalize only the first letter:
>
> | Prose form | Correct | Incorrect |
> |---|---|---|
> | "IO Stream" | `IOStream` | `IoStream` |

### Problem

The rule states "two-letter acronyms stay fully uppercase" and then demonstrates this with `IOStream`. But this directly contradicts the Kotlin coding conventions, which state:

> *"If a name is written in camel case, capitalize only the first letter of the acronym... even for two-letter acronyms."*

The official Kotlin coding conventions (linked in the guide's own Sources section) recommend `IoStream`, not `IOStream`. The Android Kotlin Style Guide (also cited) says the same:

> *"When a name contains an acronym or unusual construct, capitalize only the first letter."*

The guide's "two-letter acronym" exception comes from the older Java naming convention (`java.io.IOException`, `java.net.URL`). Kotlin's own conventions deliberately broke with Java on this point for consistency. By citing the Kotlin conventions as a source and then contradicting them, the guide creates confusion about which authority to follow.

In practice, the two-letter exception creates cognitive overhead: developers must remember that `IO` is kept uppercase but `Xml` is not, even though both are acronyms. The Kotlin convention of treating all acronyms uniformly is simpler to learn and apply.

### Recommendation

Follow the Kotlin coding conventions uniformly: capitalize only the first letter of any acronym, regardless of length. The table should show `IoStream` as correct. If the project needs Java interop compatibility for specific well-known names (like `IOException`), note those as legacy exceptions rather than as the general rule.

---

## Disagreement 2: Blanket Prohibition of `!!` Is Impractical

### Quoted Guideline

> The not-null assertion operator (`!!`) throws `NullPointerException` if the value is null. **Avoid it in production code.**

And in the checklist:

> - [ ] No `!!` without documented justification

### Problem

The body text says "avoid it in production code" (absolute prohibition), while the checklist says "no `!!` without documented justification" (conditional permission). These two positions are in tension. But more importantly, both are too strong.

There are legitimate, idiomatic uses of `!!` in production Kotlin code:

1. **After exhaustive control flow that the compiler cannot track.** When a `when` statement or loop guarantees that a variable has been assigned but smart casts cannot cross the boundary, `!!` is the clearest way to express that the programmer has verified nullability:

   ```kotlin
   val match = entries.firstOrNull { it.matches(input) }
   if (match == null) return fallback
   // Three lines later, in a different scope...
   process(match) // works here due to smart cast, but not always
   ```

   Sometimes the structure of the code means the compiler loses the smart cast (e.g., across lambda boundaries, captured variables, or `var` reassignment). In those cases, `!!` is a precise assertion about a known invariant.

2. **Test code.** The guide says "production code" but tests are production-quality code too. `!!` in tests is idiomatic and preferable to `assertNotNull` followed by a smart cast, because it produces the exact same failure mode (NPE/AssertionError) with less ceremony.

3. **Java interop boundaries.** When calling a Java method that you know never returns null but lacks `@NotNull` annotations, `!!` is the pragmatic choice. Wrapping every such call in `requireNotNull` with a message is boilerplate that obscures the actual logic.

The `requireNotNull` alternative is better when you need a custom error message for diagnosability. But when the null case genuinely cannot occur and the stack trace is sufficient context, `!!` is not a code smell -- it is an assertion.

### Recommendation

Replace the blanket prohibition with nuanced guidance: prefer `?.`, `?:`, `requireNotNull`, and smart casts as first choices. Use `!!` when the programmer has verified that null is impossible and the alternatives would add noise without improving diagnosability. Require a brief comment only when the reason for the assertion is non-obvious. Remove the separate checklist item -- it duplicates the guidance and the contradiction creates audit ambiguity.

---

## Disagreement 3: `ReturnCount` Limit of 2 Is Too Restrictive

### Quoted Guideline

> | `ReturnCount` | Limits return statements per function (default 2) |

### Problem

A limit of 2 return statements per function is one of detekt's most controversial defaults, and the guide presents it uncritically as something to enforce. This limit actively works against several idiomatic Kotlin patterns:

1. **Guard clauses.** Kotlin's convention is to use early returns to eliminate invalid states at the top of a function. A function that validates three preconditions and then does work already has 4 return points -- and that is perfectly readable:

   ```kotlin
   fun process(input: String?): Result {
       if (input == null) return Result.Empty
       if (input.isBlank()) return Result.Empty
       if (!isValid(input)) return Result.Invalid
       return compute(input)
   }
   ```

   Forcing this into 2 returns means nesting (`if/else` chains) or introducing a mutable `result` variable -- both of which reduce readability.

2. **`when` expressions with return.** The guide itself encourages using `when` for three or more branches. A `when` used as a statement (not expression) with early returns in each branch will trivially exceed 2 returns. This creates a conflict between two recommendations in the same guide.

3. **Real-world Kotlin code.** The actual Kotlin implementation in this project (`SayableAge.kt`, `formatAge` method) has 6 return points across the formatting tiers -- and it is clear, well-structured code. The guide's own codebase would fail this rule.

### Recommendation

Either recommend raising the `ReturnCount` limit to 5-6 (which accommodates guard clauses and `when` branches), or recommend disabling the rule and relying on `CyclomaticComplexity` and `LongMethod` to catch genuinely convoluted functions. The guide should acknowledge that early returns are idiomatic in Kotlin and should not be penalized.

---

## Disagreement 4: "Never Use Java Collection Types" Is Misleading

### Quoted Guideline

> Do not use Java collection types (`ArrayList`, `HashMap`, `HashSet`) directly. Use Kotlin's `mutableListOf()`, `mutableMapOf()`, `mutableSetOf()`:
>
> ```kotlin
> // Bad
> val list = ArrayList<String>()
>
> // Good
> val list = mutableListOf<String>()
> ```

### Problem

This guideline is technically misleading. `mutableListOf<String>()` returns an `ArrayList<String>`. They are the same type at runtime. The Kotlin standard library function is literally defined as:

```kotlin
public inline fun <T> mutableListOf(): MutableList<T> = ArrayList()
```

The real distinction is not about "Java types vs Kotlin types" -- it is about declaring the variable with an interface type (`MutableList`) vs a concrete class type (`ArrayList`). The guide's framing suggests that `ArrayList` is somehow un-Kotlin, when in reality it is the backing implementation that Kotlin itself uses.

There are also legitimate reasons to use specific collection implementations directly:

- `LinkedHashMap` when insertion order matters (and `mutableMapOf()` happens to return one, but relying on that is an implementation detail).
- `ArrayDeque` for a double-ended queue.
- `LinkedList` when you need O(1) head insertion (rare but real).
- Specifying initial capacity: `ArrayList<String>(1000)` avoids resizing. `mutableListOf()` does not accept a capacity parameter.

### Recommendation

Reframe the guideline: "Declare collection variables using Kotlin's interface types (`List`, `MutableList`, `Map`, `MutableMap`) rather than concrete Java implementations. Use `listOf()`, `mutableListOf()`, etc. as the default constructors. Use specific implementations (e.g., `ArrayList(initialCapacity)`, `LinkedHashMap`, `ArrayDeque`) when you need their specific behavioral guarantees, but still declare the variable with the interface type where possible."

---

## Disagreement 5: "Always Use Functional Operations Over Loops" Is Overly Dogmatic

### Quoted Guideline

> Prefer functional operations over manual loops:
>
> ```kotlin
> // Good: functional pipeline
> val adults = people
>     .filter { it.age >= 18 }
>     .sortedBy { it.name }
>     .map { it.name }
>
> // Avoid: imperative loop for the same result
> ```

### Problem

The word "avoid" for imperative loops is too strong. There are cases where a `for` loop is the right tool:

1. **Early termination with side effects.** When you need to break out of iteration based on a condition while accumulating state, a `for` loop with `break` is clearer than a `takeWhile`/`fold` chain.

2. **Performance-sensitive code.** Each functional operation in a non-sequence chain creates an intermediate collection. For hot paths on large data sets, a single loop that filters, transforms, and collects in one pass outperforms a chain of `.filter { }.map { }`. The guide mentions sequences as a mitigation, but sequences have their own overhead (iterator allocation, boxing of primitives) and are not always faster.

3. **Accumulating multiple results.** When a single pass needs to populate two or more output structures, a loop is natural. The functional equivalent (`fold` with a compound accumulator, or multiple passes) is usually harder to read.

4. **Index-dependent logic.** When the operation depends on the current index and interactions with neighboring elements, `forEachIndexed` with complex lambdas is often less readable than a plain `for (i in indices)`.

The existing Kotlin codebase in this project (`SayableAge.kt`) uses `for` loops in `safeAtoi` and `resolveUnit` -- appropriately, because they are tight, simple loops where functional alternatives would add indirection.

### Recommendation

Change "Avoid imperative loops" to "Prefer functional operations when they improve readability, particularly for filter/map/reduce pipelines. Use loops when they are clearer: early termination with side effects, accumulating multiple outputs, index-dependent logic, or performance-critical paths."

---

## Disagreement 6: Constants Rule Oversimplifies Top-Level `val`

### Quoted Guideline

> | Constants (`const val`, top-level `val`) | SCREAMING_SNAKE_CASE | `MAX_COUNT`, `USER_NAME_FIELD` |

### Problem

Grouping `const val` and top-level `val` together under the same naming rule is inaccurate. The Kotlin coding conventions distinguish between them:

- `const val` (compile-time constants): `SCREAMING_SNAKE_CASE`. Agreed.
- Top-level `val` that holds a deeply immutable value (e.g., a primitive, a string): `SCREAMING_SNAKE_CASE` is appropriate.
- Top-level `val` that holds an object with behavior or identity (e.g., a `Regex`, a `Comparator`, a `Logger`): `camelCase` is conventional.

The official Kotlin conventions say:

> *"Names of constants (properties marked with `const`, or top-level or object `val` properties with no custom `get` function that hold deeply immutable data) should use uppercase underscore-separated names."*

The key qualifier is "deeply immutable data." A `val regex = Regex("\\d+")` is immutable in the sense that the reference cannot change, but it holds an object with internal mutable state (compiled pattern caches). The conventions recommend `camelCase` for such values.

The guide's own codebase uses `val defaultPt = SayableAge(Locales.EN)` -- a top-level-like `val` in a companion object holding an object instance. By the guide's rule, this should be `DEFAULT_PT`, but `camelCase` is correct here because it is an object reference, not a primitive constant.

### Recommendation

Split the rule: `SCREAMING_SNAKE_CASE` for `const val` and for top-level/object `val` properties holding deeply immutable primitive or string values. `camelCase` for top-level/object `val` properties holding object references, even if the reference itself is immutable. Cite the "deeply immutable data" criterion from the Kotlin conventions.

---

## Disagreement 7: `ForbiddenComment` Rule for `TODO` Contradicts Section 9

### Quoted Guideline

In Section 11 (Tooling), the detekt rules table:

> | `ForbiddenComment` | Flags `TODO`/`FIXME`/`STOPSHIP` markers |

In Section 9 (Common Idioms):

> Use `TODO()` to mark incomplete code. It throws `NotImplementedError` at runtime and appears in IDE task lists:
>
> ```kotlin
> fun calculateTax(): BigDecimal = TODO("Waiting for accounting feedback")
> ```

### Problem

The guide recommends using `TODO()` as an idiom in Section 9, then recommends a detekt rule that flags `TODO` as forbidden in Section 11. This is a direct contradiction that will confuse developers: should they use `TODO()` or not?

The `ForbiddenComment` rule is designed to prevent `TODO` markers from shipping to production -- it is a CI gate, not a development-time prohibition. But the guide presents both positions without reconciling them.

### Recommendation

Clarify that `TODO()` is appropriate during development but that the `ForbiddenComment` rule should be enabled in CI to prevent unfinished code from being merged. Frame it as a workflow: "Use `TODO()` to mark incomplete work during development. Enable the `ForbiddenComment` detekt rule in CI to ensure no `TODO` markers reach production." This resolves the contradiction.

---

## Disagreement 8: The Line Length Discrepancy Between ktlint/detekt Sections

### Quoted Guideline

Section 2 (Code Formatting):

> Use **100 characters** as the column limit.

Section 11 (Tooling), detekt configuration:

> | `MaxLineLength` | Enforces line length limit (default 120) |
>
> ```yaml
> MaxLineLength:
>   active: true
>   maxLineLength: 100
> ```

### Problem

The guide correctly sets the column limit at 100, then notes detekt's default is 120, then configures it to 100. This is fine in isolation, but the presentation is confusing. A developer reading the detekt table sees "default 120" and may assume that is the project standard, especially if they do not read the yaml block below it.

More importantly, the guide does not explain why 100 was chosen over 120. The Android Kotlin Style Guide uses 100; the official Kotlin conventions do not specify a line length; detekt defaults to 120. The choice is legitimate but should be justified.

### Recommendation

Remove the "default 120" note from the rule description, or annotate it clearly as "overridden to 100 in this project." Add a one-sentence rationale for choosing 100 (e.g., "100 characters matches the Android Kotlin Style Guide and provides comfortable side-by-side diff viewing").

---

## Disagreement 9: Scope Function Table Oversimplifies `run`

### Quoted Guideline

> | `run` | `this` | Lambda result | Object configuration + computing a result |

And the example:

> ```kotlin
> val result = service.run {
>     port = 8080
>     query(prepareRequest())
> }
> ```

### Problem

The example for `run` is problematic because it conflates two operations: mutation (`port = 8080`) and computation (`query(prepareRequest())`). This is a side-effect-laden pattern that makes the code harder to reason about. The return value of `run` is the result of `query(...)`, but a reader must carefully notice that `port = 8080` is a side effect that happens along the way.

If you want to configure an object and return it, use `apply`. If you want to compute a result, use `let` or just call the function. The pattern of "configure and compute" in a single `run` block is a code smell because it mixes concerns.

The `run` scope function is most idiomatically used for two things: (1) limiting variable scope (non-extension `run { }`) and (2) performing operations on a nullable receiver with `this`-access where `let`'s `it` would be repetitive. The guide's description misses case (1) entirely.

### Recommendation

Revise the `run` description to: "Scope limitation; operations on a receiver with `this` reference when the result matters." Replace the example with a cleaner one that does not mix mutation and computation. Add a note about non-extension `run` for scoping:

```kotlin
val hexColor = run {
    val r = computeRed()
    val g = computeGreen()
    val b = computeBlue()
    "#%02x%02x%02x".format(r, g, b)
}
```

---

## Disagreement 10: Multiple Labeled Returns Advice Is Wrong

### Quoted Guideline

> Avoid multiple labeled returns in lambdas. Restructure for a single exit point or convert to an anonymous function:
>
> ```kotlin
> // Bad: multiple labeled returns
> list.forEach {
>     if (it == null) return@forEach
>     if (it.isEmpty()) return@forEach
>     process(it)
> }
>
> // Good: single expression
> list.filterNotNull().filter { it.isNotEmpty() }.forEach { process(it) }
> ```

### Problem

The "good" alternative is not equivalent to the "bad" one in the general case. The functional version creates two intermediate collections. For a simple example like this, that is fine. But the advice is stated as a general principle: "avoid multiple labeled returns."

More importantly, labeled returns in `forEach` are a standard Kotlin pattern for expressing `continue` semantics. The Kotlin documentation itself uses `return@forEach` as the idiomatic equivalent of `continue` in a `forEach` lambda. Calling this "bad" contradicts the language's own guidance.

The real advice should be: if the logic is purely filter-then-process, use functional operations. If the logic inside the loop is complex (multiple conditions, side effects, stateful accumulation), labeled returns are fine and are preferable to deeply nested `if` blocks.

### Recommendation

Remove the blanket "avoid" framing. Instead: "When a `forEach` with labeled returns is performing pure filtering, prefer `filter`/`filterNotNull` for clarity. When the loop body has complex control flow, labeled returns are the idiomatic way to express `continue` semantics in lambda-based iteration."

---

## Disagreement 11: Missing Guidance on `internal` Visibility

### Problem (Omission, Not a Quoted Guideline)

The guide covers naming, formatting, and many idioms, but entirely omits guidance on using `internal` visibility. This is a significant gap for a Kotlin style guide, because `internal` is one of Kotlin's most important visibility modifiers and has no direct equivalent in Java.

The actual codebase uses `internal` extensively and correctly -- `parseAge`, `parseDateParts`, `safeAtoi`, `stageKey`, `AgeComponents`, and `timeNow` are all `internal`. This is a deliberate design choice: these are implementation details of the library that should not be part of the public API but need to be accessible across files within the module.

Without guidance on `internal`, reviewers and contributors may default to `public` (Kotlin's default) or `private` (which would require putting everything in one file), leading to API surface area creep or monolithic files.

### Recommendation

Add a section on visibility modifiers that covers when to use `internal` (module-internal implementation details, test accessibility without `@VisibleForTesting`), when to use `private` (single-file implementation details), and the principle that public API surface should be minimized by default.

---

## Disagreement 12: Coroutines Section Is Irrelevant Scope Bloat

### Problem

Section 8 (Coroutines) is a 100-line treatment covering structured concurrency, suspend functions, coroutine builders, dispatchers, Flow, and cancellation. This is a general Kotlin guide topic, but:

1. The project this guide is auditing (`sayable-age`) has zero coroutine usage across any of its implementations. It is a pure, synchronous formatting library.
2. The guide is described as "intended for code auditing Kotlin implementations" -- specifically, the implementations in this project.
3. A coroutines guide that covers the topic in 100 lines is too shallow to be useful for a team actually writing concurrent code, and too long for a team that is not.

Including coroutines at this depth signals to reviewers that they should be looking for coroutine patterns in code that does not use them, which wastes audit time. It also inflates the guide's size, making it less likely that developers will read the parts that are relevant.

### Recommendation

Either remove the coroutines section entirely (since this is a project-specific audit guide, not a general Kotlin reference), or reduce it to a two-line note: "This project does not use coroutines. If coroutines are introduced in the future, follow the structured concurrency principles in the official Kotlin Coroutines Guide." If the guide is intended to be a general-purpose Kotlin reference beyond this project, that should be stated explicitly.

---

## Disagreement 13: Empty `catch` Block Example Contradicts Empty Blocks Section

### Quoted Guidelines

Section 2 (Code Formatting), Empty Blocks:

> Use K&R style even for empty blocks:
>
> ```kotlin
> try {
>     doSomething()
> } catch (e: Exception) {
> }
> ```

Section 10 (Things to Avoid), Empty catch Blocks:

> Never silently swallow exceptions. At minimum, log the error:
>
> ```kotlin
> // Bad
> try { riskyOperation() } catch (e: IOException) { }
> ```

### Problem

Section 2 shows an empty `catch` block as the correct example for formatting empty blocks. Section 10 says empty `catch` blocks should "never" occur. A reader who follows Section 2's example will violate Section 10's rule.

### Recommendation

Use a different example for the "empty blocks" formatting guideline -- one that is not a `catch` block. For instance, an empty method override or an empty `init` block. This avoids suggesting that empty `catch` blocks are acceptable while a later section prohibits them.

---

## Disagreement 14: Enum Naming "Pick One" Without Guidance

### Quoted Guideline

> | Enum constants | SCREAMING_SNAKE_CASE or PascalCase | `RED`, `Green` (pick one style per project) |

### Problem

Telling developers to "pick one style per project" without recommending one is an abdication of the guide's purpose. A style guide exists to make decisions so that individual developers do not have to debate them. Furthermore, the guide's own codebase uses `SCREAMING_SNAKE_CASE` for enums (`ZERO`, `ONE`, `TWO`, `FEW`, `MANY`, `OTHER` in `PluralCategory`; `NORMAL`, `SHORT`, `COMPACT` in `Compactness`).

The Kotlin coding conventions say either style is acceptable, which is why the guide hedges. But a project style guide should be more opinionated than a language spec.

### Recommendation

Pick `SCREAMING_SNAKE_CASE` as the project standard (it matches the existing code and is consistent with Java conventions, which matters for a JVM library). State it as the recommendation, not as one of two options.

---

## Summary

The guide's strongest sections are null safety (Section 3), type system (Section 4), and the quick reference checklist. The weakest areas are internal contradictions (empty blocks vs empty catches, TODO idiom vs ForbiddenComment rule, two-letter acronym exception), over-rigid rules that conflict with idiomatic Kotlin (`!!` prohibition, `ReturnCount` of 2, loop avoidance), and scope bloat (coroutines section for a synchronous library).

The revised guide should resolve these contradictions, relax the rules that fight the language's own idioms, add the missing `internal` visibility guidance, and remove or shrink the coroutines section to match the project's actual scope.

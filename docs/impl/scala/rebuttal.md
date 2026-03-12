# Rebuttal: Scala Style Guide Review

Reviewer: Senior Staff Engineer
Date: 2026-03-11

This is a detailed technical review of the Scala style guide at `docs/impl/scala/README.md`. For each issue, I quote the specific guideline, explain why it is problematic, and recommend an alternative.

---

## 1. Enum Case Casing: UPPER_CASE Should Not Be Presented as an Option

**Quoted guideline (Section 1, Naming Conventions table):**

> Enum cases | UPPER_CASE or UpperCamelCase | `ZERO`, `ONE`, `Small`, `Medium`

**Problem:**

The guide presents `UPPER_CASE` as an acceptable casing for enum cases, on equal footing with `UpperCamelCase`. This is misleading. The Scala 3 documentation and community convention strongly favor `UpperCamelCase` for enum cases. The `UPPER_CASE` style is a legacy Java carryover, not idiomatic Scala. In fact, the Scala pattern matcher treats identifiers starting with an uppercase letter as type-level or constant patterns, while lowercase identifiers are treated as variable bindings. Using `UPPER_CASE` works mechanically, but it clashes with Scala's own naming semantics and the convention used by the standard library (`Option.Some`, `Option.None`, `List.Nil`, `List.Cons`).

Worse, the actual codebase uses `UPPER_CASE` for both `PluralCategory` and `Compactness`:

```scala
enum PluralCategory:
    case ZERO, ONE, TWO, FEW, MANY, OTHER

enum Compactness:
    case NORMAL, SHORT, COMPACT
```

This is defensible only because these are cross-language domain constants that must be recognizable across 29 implementations. The guide should acknowledge this as a project-specific exception, not present it as generally acceptable Scala style.

**Recommendation:**

State that UpperCamelCase is the idiomatic Scala convention for enum cases. Note the project-specific exception for cross-language domain enums where UPPER_CASE is used for consistency across implementations.

---

## 2. The `safeAtoi` Example Contradicts the `return` Prohibition

**Quoted guideline (Section 10, return Statements):**

> Avoid explicit `return`. In Scala, the last expression in a block is the return value. Using `return` breaks referential transparency and interacts poorly with closures and lambdas.

**Quoted guideline (Section 10, Mutable vars):**

> ```scala
> private def safeAtoi(s: String): Option[Int] =
>   var n = 0
>   var i = 0
>   while i < s.length do
>     val c = s.charAt(i)
>     if c < '0' || c > '9' then return None
>     n = n * 10 + (c - '0')
>     i += 1
>   Some(n)
> ```

**Problem:**

The guide explicitly forbids `return` statements, then uses `return None` inside a `while` loop as the canonical example of acceptable mutable code. This is a direct self-contradiction that undermines the guide's credibility.

The guide correctly identifies `return` as problematic in general, but fails to acknowledge that early return from imperative loops is one of the few cases where `return` is defensible in Scala. The example should either be rewritten to avoid `return`, or the `return` prohibition should be softened to acknowledge this exception.

The actual codebase does use `return None` in `safeAtoi` (line 56 of `SayableAge.scala`), so this is not hypothetical.

**Recommendation:**

Either rewrite the `safeAtoi` example using a functional approach (tail recursion or `boundary`/`break` in Scala 3.3+), or explicitly acknowledge that early return from imperative loops is a narrow exception to the no-return rule. The current state of having a blanket rule and then immediately violating it is worse than having a nuanced rule.

A modern Scala 3.3+ rewrite:

```scala
import scala.util.boundary, boundary.break

private def safeAtoi(s: String): Option[Int] =
  boundary:
    var n = 0
    var i = 0
    while i < s.length do
      val c = s.charAt(i)
      if c < '0' || c > '9' then break(None)
      n = n * 10 + (c - '0')
      i += 1
    Some(n)
```

Or a tail-recursive alternative that avoids mutation entirely:

```scala
@tailrec
private def safeAtoi(s: String, i: Int = 0, acc: Int = 0): Option[Int] =
  if i >= s.length then Some(acc)
  else
    val c = s.charAt(i)
    if c < '0' || c > '9' then None
    else safeAtoi(s, i + 1, acc * 10 + (c - '0'))
```

---

## 3. `asOf: String = null` Is Presented Without Critique

**Quoted guideline (Section 4, Companion Objects):**

> ```scala
> class SayableAge(locale: AgeLocale, compactness: Compactness = Compactness.NORMAL):
>   def formatAge(dateOfBirth: String, asOf: String = null): Option[String] = ...
> ```

**Quoted guideline (Section 10, null):**

> Never use `null` in Scala code. Use `Option` instead.
> The only acceptable use of `null` is at Java interop boundaries, immediately wrapped with `Option(value)`.

**Problem:**

The guide correctly says "never use null" in Section 10, then shows `asOf: String = null` as a default parameter in a public API example in Section 4 without any comment. This pattern exists in the actual codebase (`SayableAge.scala` lines 116, 146, 163, 166) and is a deliberate design choice for cross-language API consistency. But the style guide should not present this uncritically -- it directly contradicts its own most prominent prohibition.

Using `null` as a default parameter value is particularly insidious because it leaks nullability into the type system. The parameter `asOf: String = null` has type `String`, not `Option[String]`, so the compiler provides no null-safety guarantees. Callers who inspect the signature see `String` and may not realize they need to handle null internally.

**Recommendation:**

If this pattern exists for cross-language API parity, acknowledge it explicitly as a project-specific compromise and explain the rationale. Better yet, present the idiomatic Scala signature (`asOf: Option[String] = None`) in the style guide and note the project deviation separately. A style guide should show the ideal, not normalize the compromise.

---

## 4. `.get` on Option Is Used in the Codebase Example

**Quoted guideline (Section 6, Avoid Partial Collection Methods):**

> Never call `.get` on an `Option`. It throws `NoSuchElementException` on `None`.

**Problem in companion guideline (Section 4, Companion Objects):**

The `_resolve` method in the actual codebase uses `.getOrElse`, which is fine. But `resolveUnit` on line 83 of `SayableAge.scala` chains `.flatMap(_.get(cat))` on a `Map` -- `Map.get` returns `Option`, which is safe. However, the style guide's `resolveUnit` example (in the source) shows `.getOrElse("{n}")` at the end, which is acceptable. This is not a direct violation, but the guide would benefit from distinguishing `Map.get` (which returns `Option` and is safe) from `Option.get` (which is unsafe). The blanket statement "No `.get` calls" in the checklist could confuse readers who see `Map.get` in the codebase.

**Recommendation:**

Clarify in the checklist that the prohibition is on `Option.get`, `Try.get`, and `Either` projection `.get` -- not on `Map.get`, `Map.getOrElse`, or other collection access methods that return `Option`.

---

## 5. The `foldLeft(identity)` Example Is Wrong

**Quoted guideline (Section 6, Avoid Partial Collection Methods):**

> ```scala
> // Safe alternatives
> list.headOption
> list.drop(1)
> list.reduceOption(_ + _)
> list.foldLeft(identity)(_ + _)
> ```

**Problem:**

`list.foldLeft(identity)(_ + _)` does not compile. `foldLeft` takes a zero value of the accumulator type, not a function. The signature is `foldLeft[B](z: B)(op: (B, A) => B): B`. Passing `identity` (a `Function1`) as the zero value is a type error.

If the intent was to show a safe alternative to `reduce`, the correct code is:

```scala
list.foldLeft(0)(_ + _)       // for Int
list.reduceOption(_ + _)       // for any type with +
```

Or if the intent was a generic "identity element" pattern:

```scala
import scala.math.Numeric
def safeSum[A: Numeric](list: List[A]): A =
  list.foldLeft(Numeric[A].zero)(_ + _)
```

**Recommendation:**

Remove the `foldLeft(identity)` line entirely. The `reduceOption` line already demonstrates the safe alternative. Having a code example that does not compile in a style guide is a serious credibility issue.

---

## 6. The Wildcard Import Prohibition Is Too Strict

**Quoted guideline (Section 10, Wildcard Imports in Production Code):**

> Avoid `import pkg.*` (or `import pkg._` in Scala 2) except when importing from a companion object, enum, or a well-known DSL. Wildcard imports obscure which names are in scope.

**Problem:**

This is overly restrictive and inconsistent with established Scala practice. The actual test file in the codebase uses explicit imports from JUnit:

```scala
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertTrue
```

This is verbose without adding clarity. Everyone knows what `assertEquals` is. More importantly, the guide already carves out exceptions for "companion objects, enums, or well-known DSLs" but fails to mention test assertions, which are the most common wildcard import in any Scala project.

The real risk with wildcard imports is namespace pollution from large, unfamiliar packages. Importing `Assertions.*` or `PluralCategory.*` is not that.

**Recommendation:**

Soften the rule: prefer explicit imports for production code, but allow wildcard imports for test assertion libraries, enum members, and small well-scoped companion objects. The six-name threshold mentioned in Section 2 (Import Ordering) already provides a reasonable heuristic -- use it consistently.

---

## 7. The `Vector` as Default Sequence Advice Is Misguided for This Project

**Quoted guideline (Section 6, Choosing the Right Collection):**

> Use **`Vector`** as the default general-purpose sequence. It has efficient indexed access, append, and prepend.

**Problem:**

This is reasonable general advice but poor advice for this specific project. The sayable-age library does no indexed access, no random access, no append. The data structures are small, fixed-size, and created once at initialization. `List` is the simpler, more memory-efficient choice for small sequences, and most of the actual code uses `Map` and `Option` rather than sequences at all.

Advising `Vector` as the default can lead developers to reach for `Vector` in cases where `List`, `Array`, or even a simple tuple would be more appropriate. The better advice is: choose the collection that matches your access pattern.

**Recommendation:**

Replace the blanket "use Vector as default" advice with access-pattern-based guidance. For this project specifically, most sequences are small and prepend/iterate-only, making `List` the natural choice. State that `Vector` is preferable when indexed access or both-end operations are needed.

---

## 8. Missing Guidance on `given`/`using` Scope and Import

**Quoted guideline (Section 8, Implicits and Givens):**

The section covers defining and using `given` instances, but says nothing about import scope. In Scala 3, given instances must be explicitly imported with `import pkg.given` or `import pkg.{given SomeType}`. This is a major practical concern that trips up developers migrating from Scala 2, where implicits were imported with the regular wildcard.

**Recommendation:**

Add a subsection on importing givens:

```scala
// Import all givens from a scope
import sayableage.given

// Import only specific given types
import sayableage.{given AgeLocale}

// In Scala 2: implicits come with wildcard imports
import sayableage._  // brings implicits in Scala 2
```

---

## 9. The Structural Types Warning Is Outdated for Scala 3

**Quoted guideline (Section 3, Structural Types):**

> Avoid structural types in production code. They use runtime reflection and are significantly slower than nominal types.

**Problem:**

This is true for Scala 2 but misleading for Scala 3. Scala 3 structural types can be implemented without reflection using `Selectable`, which compiles to direct field access. The blanket "avoid structural types" advice ignores this evolution and may discourage legitimate use of `Selectable`-based patterns.

**Recommendation:**

Update the guidance: in Scala 2, structural types use reflection and should be avoided. In Scala 3, structural types based on `Selectable` do not use reflection, but should still be used sparingly because they bypass the compiler's nominal type checking.

---

## 10. The Scaladoc Formatting Example Has Inconsistent Indentation

**Quoted guideline (Section 2, Scaladoc):**

> ```scala
> /** Returns the formatted age string.
>  *
>  *  Formats the age based on the locale's plural rules
>  *  and stage thresholds.
>  *
>  *  @param dateOfBirth  ISO 8601 date string (YYYY-MM-DD)
>  *  @param asOf         reference date for age calculation
>  *  @return formatted age string, or None if input is invalid
>  */
> ```

**Problem:**

The Scaladoc body text uses double-space indentation after `*` (` *  Formats...`) while the `@param` tags use single-space (` *  @param`). This is the "Scala Style Guide" format, but it is not what scalafmt produces by default, and it is not consistently used in practice. The extra space before body text is a visual convention that adds no semantic value and creates inconsistency when developers mix hand-written and formatter-produced Scaladoc.

**Recommendation:**

Use single-space after `*` consistently. This is what scalafmt enforces and what most modern Scala projects use:

```scala
/** Returns the formatted age string.
 *
 * Formats the age based on the locale's plural rules
 * and stage thresholds.
 *
 * @param dateOfBirth ISO 8601 date string (YYYY-MM-DD)
 * @param asOf        reference date for age calculation
 * @return formatted age string, or None if input is invalid
 */
```

---

## 11. Missing Guidance on Scala 3 `boundary`/`break`

The guide covers `@tailrec`, `return` avoidance, and imperative loops, but never mentions `boundary`/`break` (introduced in Scala 3.3 via `scala.util.boundary`). This is the modern, safe replacement for early `return` in Scala 3 and is directly relevant to the `safeAtoi`-style patterns shown in the guide. Its omission is a significant gap.

**Recommendation:**

Add a subsection in Section 5 (Functional Patterns) or Section 9 (Common Idioms) covering `boundary`/`break` as the preferred alternative to `return` for early exit.

---

## 12. The Checklist Mandates `@tailrec` on All Recursive Methods

**Quoted guideline (Quick Reference Checklist):**

> - [ ] `@tailrec` annotation on recursive methods

**Problem:**

Not all recursive methods are tail-recursive, and not all recursive methods should be rewritten to be tail-recursive. The `@tailrec` annotation is a verification tool -- it causes a compile error if the method is not actually tail-recursive. Mandating it on "recursive methods" (as opposed to "tail-recursive methods") implies that all recursion should be tail-recursive, which is not true. Tree traversals, divide-and-conquer algorithms, and many other patterns are naturally non-tail-recursive and are better expressed that way.

**Recommendation:**

Change to: "Use `@tailrec` annotation on methods that are intended to be tail-recursive." This makes the annotation a verification of intent, not a blanket mandate.

---

## 13. The `accept Seq[T] in method signatures` Advice Is Controversial

**Quoted guideline (Section 6, Choosing the Right Collection):**

> Accept **`Seq[T]`** in method signatures rather than a specific implementation, to keep APIs flexible.

**Problem:**

`Seq[T]` in Scala is `scala.collection.immutable.Seq` by default in Scala 2.13+ and Scala 3, but it was `scala.collection.Seq` (which includes mutable) before 2.13. This historical ambiguity has caused real bugs. More importantly, `Seq` provides no performance guarantees -- a method accepting `Seq` cannot assume O(1) indexed access, O(1) prepend, or any other specific characteristic. This can lead to accidentally quadratic algorithms when someone passes a `List` to code that indexes into it.

The Effective Scala guide (cited as a source) specifically recommends against `Seq` in public APIs, preferring `IndexedSeq` or `List` depending on the access pattern.

**Recommendation:**

Replace with: "In method signatures, prefer the most specific collection trait that matches the required access pattern: `IndexedSeq` for indexed access, `Iterable` for iteration-only, or the concrete type if performance characteristics matter. Avoid bare `Seq` in public APIs because it provides no performance guarantees."

---

## 14. The `align.preset = more` Recommendation Creates Noisy Diffs

**Quoted guideline (Section 2, scalafmt Configuration):**

> ```hocon
> align.preset = more
> ```

**Problem:**

`align.preset = more` enables vertical alignment of `=`, `=>`, `<-`, and other operators across adjacent lines. While this can improve readability in isolation, it creates significantly noisier git diffs. Adding or removing a single line can cause the formatter to realign every adjacent line, making the diff show changes to lines whose semantics did not change. This makes code review harder and `git blame` less useful.

**Recommendation:**

Recommend `align.preset = none` or `align.preset = some` (which only aligns `=>` in case expressions and `<-` in for-comprehensions). Note the tradeoff: `more` is prettier to read but noisier to review.

---

## Summary

The guide is thorough and covers the important territory well. Its main weaknesses are:

1. **Internal contradictions** -- the `null` and `return` prohibitions are violated by the guide's own examples
2. **One incorrect code example** -- `foldLeft(identity)` does not compile
3. **Missing Scala 3.3+ features** -- `boundary`/`break` is absent despite being directly relevant
4. **Overly rigid rules** that do not acknowledge project-specific tradeoffs (UPPER_CASE enums, null defaults for cross-language API parity)
5. **Outdated Scala 2 assumptions** applied to Scala 3 (structural types, `Seq` semantics)

None of these issues are fatal, but taken together they reduce confidence in the guide's precision, which is the one thing a style guide cannot afford to lose.

# Java Style Guide -- Senior Engineering Review

Reviewer role: Senior Staff Engineer
Date: 2026-03-11

---

## Summary

The guide is broadly solid. It cites the right sources, covers the right topics, and contains no outright falsehoods. However, several guidelines are internally contradictory, underspecified in ways that will cause team arguments, or present opinion as settled consensus when the ecosystem is genuinely split. Below are the items I would block on in a review.

---

## 1. Indentation: 4 spaces, but recommending google-java-format

**Quoted guideline (Section 2, Indentation):**

> Use **4 spaces** per indent level. Never tabs. (Google style uses 2 spaces; Oracle conventions use 4. This guide follows the Oracle/IntelliJ default of 4 spaces, which is the most common in the Java ecosystem.)

**Quoted guideline (Section 2, Google Java Format):**

> [google-java-format](https://github.com/google/google-java-format) is the standard automated formatter. It enforces the Google style (2-space indent, specific wrapping rules) deterministically. If your team uses it, let it own all formatting decisions -- do not fight the tool.

**Problem:**

These two guidelines are in direct conflict. The guide prescribes 4-space indentation as a rule, then recommends google-java-format as "the standard automated formatter," acknowledging that it enforces 2-space indentation. The parenthetical "if your team uses it" does not resolve the contradiction -- the guide is telling readers to adopt it as a CI check and pre-commit hook two paragraphs later, which *is* telling them to use it.

A team that follows this guide literally will configure google-java-format in CI (as Section 11 also recommends), and it will immediately reject every file in the codebase because they use 4-space indentation. The formatter has no configuration option for indent width -- it is 2 spaces, period. This is not a theoretical concern; it is the single most common complaint about google-java-format and the reason many teams do not adopt it.

The guide needs to pick one position: either use google-java-format and accept 2-space indentation, or use 4-space indentation and recommend a different formatter (Spotless with Palantir Java Format, IntelliJ's built-in formatter, or a Checkstyle formatting ruleset). Presenting both as recommendations is actively harmful because someone will set up the toolchain exactly as described and waste hours debugging the contradiction.

**Recommendation:**

State the indentation rule and the formatter choice as a single coherent decision. If the guide wants 4-space indentation, recommend Spotless with Palantir Java Format (which uses 4 spaces) or explicitly state that google-java-format is an alternative that requires accepting 2-space indentation. Do not present them as compatible defaults.

---

## 2. Import ordering: guide says one thing, google-java-format does another

**Quoted guideline (Section 2, Import Ordering):**

> Organize imports in two groups separated by a blank line:
> 1. **Static imports** (alphabetical)
> 2. **Non-static imports** (alphabetical)

**Problem:**

Google Java Style (and google-java-format) places static imports *after* non-static imports, not before. The guide's ordering matches neither Google style nor IntelliJ defaults. If a team adopts google-java-format as recommended in Section 11, the formatter will reorder imports on every run, contradicting this section.

Even ignoring the formatter conflict, putting static imports first is unusual. Both Google and IntelliJ default to non-static first. The guide should either match its recommended formatter or explicitly state it is diverging and explain why.

**Recommendation:**

Align the import ordering with whichever formatter the guide recommends. If google-java-format, use its ordering (non-static first, then static). If a different formatter, match that formatter's convention. The point of specifying import order in a style guide is to end debates, and that only works if the formatter enforces the same order.

---

## 3. Line length 100 characters is underspecified given the formatter recommendation

**Quoted guideline (Section 2, Line Length):**

> Limit lines to **100 characters**.

**Problem:**

google-java-format enforces a 100-character line limit by default, so this is actually consistent. However, the guide does not mention that google-java-format's line-wrapping algorithm will aggressively reformat code to fit within 100 characters in ways the developer may not expect. The guide's manual line-wrapping rules (Section 2, Line Wrapping) -- "indent continuation lines by at least 8 spaces" -- will be overridden by google-java-format's own wrapping logic, which uses 4-space (+2 from the 2-space base) continuation indentation.

This is another instance of the guide specifying manual rules that its recommended automated tool will override. The manual rules become dead text that misleads developers who read the guide but rely on the formatter.

**Recommendation:**

If the guide recommends an automated formatter, the manual formatting rules should be documented as "what the formatter does" rather than independent prescriptions. Mark them as "for understanding formatted output" rather than "rules to follow manually." Or, if the guide drops google-java-format, the manual rules stand on their own and become the authoritative reference.

---

## 4. "Never use Optional as a field type" is too absolute

**Quoted guideline (Section 3, Optional):**

> Never use `Optional` as a field type, method parameter, or collection element.

**Problem:**

The "never as a field" rule comes from the original Optional API design (Brian Goetz has said it was designed for return types). However, this absolutism creates a real problem for records. A record like:

```java
public record SearchResult(String query, Optional<Integer> totalCount) {}
```

is the only way to express "this field may be absent" in the record's type signature while preserving the record's auto-generated `equals`, `hashCode`, and `toString`. The alternatives are worse:

- Using `null` in a record component throws away the type-level documentation of optionality and makes the record's `equals` behave differently than callers expect (NPE on `toString` if null).
- Using `@Nullable` requires an annotation dependency and does not affect runtime behavior.
- Wrapping in a non-record class to hide the nullable field defeats the purpose of records.

The Jackson, Spring, and Hibernate ecosystems all handle `Optional` fields in records correctly now. The "never as a field" guidance made sense when Java had no records and fields were always private implementation details. With records, components *are* the API.

The "never as a method parameter" rule is also overly broad. It makes sense for public API boundaries (callers should not have to wrap values in Optional before calling you), but for internal builder-pattern or configuration methods, `Optional` parameters can be clearer than nullable parameters with `@Nullable` annotations.

**Recommendation:**

Soften to: "Avoid `Optional` as a field type in traditional classes. In records, `Optional` components are acceptable when the absence of a value is a meaningful part of the domain model. Avoid `Optional` as a method parameter in public APIs; prefer overloaded methods or explicit null-handling."

---

## 5. "Never call get() without first checking isPresent()" misses orElseThrow()

**Quoted guideline (Section 3, Optional):**

> Never call `get()` without first checking `isPresent()`. Prefer `orElse()`, `orElseGet()`, `orElseThrow()`, `map()`, or `ifPresent()`.

**Problem:**

This is correct advice but the phrasing implies that `isPresent()` followed by `get()` is the acceptable pattern, when in fact that pattern is itself an anti-pattern. The `isPresent()`-then-`get()` dance is exactly the kind of boilerplate Optional was designed to eliminate. Developers reading this will think "OK, I should check isPresent() first" and write:

```java
if (opt.isPresent()) {
    return opt.get();
}
```

...which is no better than a null check. The guide should explicitly discourage the `isPresent()/get()` pair and steer toward the functional methods (`map`, `flatMap`, `orElse`, `orElseThrow`).

**Recommendation:**

Rewrite to: "Never call `get()` directly. The `isPresent()`-then-`get()` pattern is also discouraged because it is equivalent to a null check without the type-safety benefit. Prefer `orElse()`, `orElseGet()`, `orElseThrow()`, `map()`, `flatMap()`, or `ifPresent()`."

---

## 6. Checked vs. unchecked exception guidance is oversimplified

**Quoted guideline (Section 6):**

> | Category                | When to use                                                     |
> | ----------------------- | --------------------------------------------------------------- |
> | Checked (`Exception`)   | Recoverable conditions the caller can reasonably handle (I/O failures, parse errors from user input) |
> | Unchecked (`RuntimeException`) | Programming errors, precondition violations, unrecoverable states |

**Problem:**

This is the textbook Effective Java answer, and it has been the subject of 20+ years of debate. The guide presents it as settled fact without acknowledging that the modern Java ecosystem has largely moved away from checked exceptions. Spring, Hibernate, the entire Jakarta EE platform, and most contemporary libraries throw unchecked exceptions almost exclusively. The Kotlin and Scala communities (both JVM languages) rejected checked exceptions entirely.

The practical problem with checked exceptions is that they infect every layer of the call stack. If a low-level method throws a checked exception, every intermediate method must either catch it or declare it in its throws clause, even if those intermediate methods have no idea how to handle it. This leads to the pervasive anti-pattern of wrapping checked exceptions in unchecked ones, or worse, catching and swallowing them.

A style guide should at minimum acknowledge this tension. Presenting "use checked exceptions for recoverable conditions" as unqualified advice will lead to teams wrapping every I/O operation in checked exceptions that bubble up through 15 layers of abstraction, annoying every developer along the way.

**Recommendation:**

Keep the table but add a pragmatic note: "In practice, many modern Java projects and frameworks use unchecked exceptions exclusively, reserving checked exceptions for cases where the *immediate* caller is expected to handle the failure (e.g., a method that parses user input and returns a result or throws). If your codebase or framework already has a convention, follow it. Do not introduce checked exceptions into a codebase that has standardized on unchecked ones."

---

## 7. Stream pipeline length guidance is vague

**Quoted guideline (Section 7):**

> **Keep pipelines short.** Three to five operations is a good ceiling.

**Problem:**

"Three to five operations" is arbitrary and imprecise. Does `.stream()` count? Does `.collect()` count? A pipeline like `.stream().filter(x).map(y).sorted().toList()` is five calls but perfectly readable. A pipeline like `.stream().flatMap(x).collect(groupingBy(y, mapping(z, toList())))` is three calls but significantly harder to read.

The complexity of a stream pipeline depends on the complexity of each operation, not the count. A pipeline of five trivial method references is simpler than a pipeline of two operations with multi-line lambdas.

**Recommendation:**

Replace the numeric ceiling with: "Keep each individual operation simple -- ideally a single method reference or a short lambda. When a lambda exceeds a single expression, extract it into a named method. When a pipeline becomes hard to read as a whole, break it into intermediate variables with descriptive names."

---

## 8. "Use StringBuilder when building a string in a loop" is outdated advice for modern Java

**Quoted guideline (Section 8, StringBuilder):**

> Use `StringBuilder` when building a string in a loop or across many conditional branches.

And:

**Quoted guideline (Section 10, String Concatenation in Loops):**

> Do not use `+` for string concatenation inside loops. Use `StringBuilder` or `StringJoiner`.

**Problem:**

Since Java 9, the JEP 280 "Indify String Concatenation" change means that `+` concatenation is compiled to `invokedynamic` calls that the JVM can optimize better than hand-written `StringBuilder` code in many cases. In a simple loop like:

```java
String result = "";
for (var item : items) {
    result += item.name() + ", ";
}
```

The `+=` is still suboptimal because it creates a new String on every iteration (the `invokedynamic` optimization applies to each individual concatenation expression, not across loop iterations). So the advice is technically still correct for the loop case.

However, the guide does not mention `String.join()` or `Collectors.joining()` as the *preferred* approaches for the most common loop-concatenation scenario (joining elements with a delimiter). These are more readable than both `StringBuilder` and `StringJoiner` for the common case, and the guide only mentions `Collectors.joining()` in passing in the Streams section.

The `StringBuilder` advice is not wrong, but it is incomplete. In 2026, the first recommendation for "joining strings in a loop" should be `String.join()` or a stream with `Collectors.joining()`, with `StringBuilder` reserved for cases where the building logic is genuinely complex (conditional appends, non-uniform formatting).

**Recommendation:**

Reorganize the string-building guidance: (1) `String.join()` or `Collectors.joining()` for delimiter-separated concatenation; (2) `StringBuilder` for complex conditional building; (3) note that `+` concatenation in a single expression is fine and well-optimized since Java 9, but `+=` in a loop remains suboptimal.

---

## 9. The "Boxing in Tight Loops" example is misleading

**Quoted guideline (Section 10, Boxing in Tight Loops):**

> ```java
> // Bad -- boxes every int
> List<Integer> sums = numbers.stream()
>         .map(n -> n + 1)
>         .collect(Collectors.toList());
>
> // Good -- stays in primitives
> int[] sums = IntStream.of(1, 2, 3)
>         .map(n -> n + 1)
>         .toArray();
> ```

**Problem:**

These two examples do not produce equivalent results. The "Bad" example produces a `List<Integer>` and the "Good" example produces an `int[]`. They serve different purposes. If the caller needs a `List<Integer>` (for example, to pass to an API that expects `List`), the "Good" alternative does not work. The guide is comparing apples to oranges and labeling one "Bad" without acknowledging the different use cases.

Additionally, the "Bad" example assumes `numbers` is a `Stream<Integer>` (so `.map` uses `Function<Integer, Integer>` which boxes), but this is not stated. If `numbers` were already an `IntStream`, `.map` would not box at all.

The advice about avoiding unnecessary boxing is sound, but the example should compare equivalent operations or explicitly state when the primitive alternative is applicable.

**Recommendation:**

Rewrite the example to show a case where the result type is the same, or add a clear caveat: "When you need a primitive result (array, sum, count), use primitive streams to avoid boxing. When you need a `List<Integer>`, boxing is unavoidable -- focus optimization effort elsewhere."

---

## 10. Missing: guidance on null-handling strategy

The guide has scattered null-related advice (Optional return types, `Objects.requireNonNull`, `@Override equals`) but never states a coherent null-handling strategy. Key questions left unanswered:

- Should the codebase use `@Nullable`/`@NonNull` annotations? If so, from which package (JSpecify, JetBrains, Jakarta, Checker Framework)?
- Should public API methods validate non-null parameters with `Objects.requireNonNull` in every case, or only when null would cause a confusing failure later?
- Should NullPointerException messages include the parameter name (as the JDK does since Java 14 with helpful NPEs)?

Null is the single largest source of bugs in Java codebases. A style guide that does not take a clear position on annotation-based null analysis is missing its highest-impact opportunity.

**Recommendation:**

Add a section on null safety. Recommend JSpecify annotations (`@Nullable`, `@NonNull`) as the emerging standard, require `Objects.requireNonNull` for public API parameters, and note that Java 14+ provides helpful NullPointerException messages by default.

---

## 11. Missing: guidance on Javadoc expectations

The guide covers naming, formatting, error handling, and tooling, but says nothing about when Javadoc is required. This is a significant gap for a comprehensive style guide. Questions left unanswered:

- Are Javadoc comments required on all public types and methods?
- What about package-private types?
- What is the expected format for `@param`, `@return`, `@throws`?
- Should Javadoc repeat information obvious from the method signature?

Checkstyle (recommended in Section 11) has `MissingJavadocMethod` and `MissingJavadocType` checks, but the guide does not say whether to enable them or what standard they should enforce.

**Recommendation:**

Add a Javadoc section. At minimum: require Javadoc on all public and protected types and methods; use `@param`, `@return`, `@throws` for non-obvious behavior; first sentence should be a summary sentence ending in a period; do not write Javadoc that restates the method signature with no additional information.

---

## 12. Missing: guidance on testing conventions

The guide mentions test class naming (Section 1: "Test classes end with `Test`") and nothing else about testing. For a comprehensive style guide, this is a gap. At minimum:

- Test method naming convention (e.g., `methodName_condition_expectedResult` vs. `shouldDoXWhenY` vs. display names with `@DisplayName`)
- Whether to use JUnit 5's `assertAll` for grouped assertions
- Assertion style: JUnit assertions, AssertJ, Hamcrest, or Truth
- Test organization: one test class per production class, or organized by behavior

**Recommendation:**

Either add a testing section or explicitly state that testing conventions are out of scope and covered by a separate document.

---

## 13. The record vs. class table oversimplifies

**Quoted guideline (Section 3, Records):**

> | Use a record when...                         | Use a class when...                          |
> | -------------------------------------------- | -------------------------------------------- |
> | Data is purely a transparent carrier          | You need mutable state                       |
> | `equals`/`hashCode` should use all fields    | You need custom equality semantics           |
> | No inheritance hierarchy is needed            | You need to extend a class                   |
> | All fields are part of the public API         | Some fields should be encapsulated           |

**Problem:**

The table omits the most practical consideration: records cannot have non-final fields (by definition), but they *can* have custom `equals`/`hashCode` implementations. The "use a class when you need custom equality semantics" row implies records cannot override `equals`, which is false. Records can and do override `equals` -- for example, to implement case-insensitive comparison of a string component.

The table also omits that records cannot extend other classes (they implicitly extend `java.lang.Record`), which is a stronger statement than "no inheritance hierarchy is needed." You *cannot* use a record if you need to extend a class, regardless of whether you want to.

**Recommendation:**

Fix the table to say "You must extend a concrete class" instead of "You need to extend a class," and replace "You need custom equality semantics" with "You need equality that ignores some fields" (which is the actual case records handle poorly, since their canonical equals uses all components).

---

## 14. Utility class pattern could mention Java 9+ modules

**Quoted guideline (Section 4, Utility Classes):**

> A class containing only static methods should have a private constructor to prevent instantiation. Do not make it `abstract` -- that implies it is designed for subclassing.

**Problem:**

This is correct but incomplete. The guide does not mention that since Java 9, if a utility class is in a module, the module system provides a stronger encapsulation boundary. More importantly, the guide does not mention the increasingly common alternative of putting utility methods on an interface with only static and default methods, which avoids the private-constructor boilerplate entirely. This is a minor point, but worth noting for completeness.

**Recommendation:**

Keep the private-constructor advice as the primary recommendation. Optionally note that utility methods can also live as static methods on an interface when no constructor suppression is needed.

---

## Items I agree with and would keep as-is

For completeness, these sections are well-written and I would keep them with at most minor editorial changes:

- Section 1 (Naming Conventions) -- thorough, correct, well-exemplified
- Section 3 (Generics, Sealed Classes, Enums, var) -- good modern Java coverage
- Section 4 (Encapsulation, Immutability, Static Factories, Builder, Composition over Inheritance) -- solid Effective Java distillation
- Section 5 (Collections) -- accurate, practical, well-tabled
- Section 6 (Try-with-Resources, Custom Exceptions, Exception Best Practices) -- correct
- Section 7 (Method References, Collectors, Functional Interfaces, Lambda Best Practices) -- comprehensive
- Section 8 (Text Blocks, String Comparison) -- accurate
- Section 9 (Switch Expressions, Pattern Matching, Enhanced For, Objects utility, @Override) -- good modern Java coverage
- Section 10 (Raw Types, Mutable Statics, Excessive Inheritance, Finalizers, Double-Brace Init, Wildcard Imports, Mutable Parameters, Catching Throwable) -- all correct and important

The guide's greatest strength is its breadth and its consistent use of project-relevant examples (SayableAge, AgeLocale, PluralCategory). Its greatest weakness is the internal contradiction between its formatting rules and its formatter recommendation.

# Rebuttal: Swift Style Guide Review

Senior Staff Engineer review of the Swift style guide at `docs/impl/swift/README.md`. This document catalogs specific disagreements with technical justification and recommended alternatives.

---

## 1. Indentation: Indecisive Guidance

**Quoted guideline:**

> Use **spaces**, not tabs. Two spaces or four spaces per indent level -- pick one and be consistent across the project. The Kodeco guide recommends 2 spaces; the Google guide uses 2 spaces. Apple's standard library uses 2 or 4.

**Why this is problematic:**

A style guide that says "pick one" is not a style guide. It is a menu. The entire purpose of codifying a convention is to eliminate this kind of ambiguity. Presenting two options and citing three different external sources with different preferences actively undermines the document's authority. Any engineer reading this will either (a) pick whichever they personally prefer, leading to inconsistency across contributors, or (b) have to escalate the decision elsewhere, which means the guide failed at its job.

The Swift ecosystem has a clear mainstream convention. Xcode defaults to 4 spaces. Apple's own Swift source code (the compiler, the standard library, Foundation) predominantly uses 4 spaces. The Swift API Design Guidelines examples use 4 spaces. `swift-format` defaults to 4 spaces (the guide itself shows this in section 11). The Google guide's 2-space preference is an internal deviation that reflects Google's cross-language preference for 2 spaces (Go, Java, etc.), not a Swift community norm.

**Recommended alternative:**

Use 4 spaces. State it definitively with no alternatives. This aligns with Apple's tooling defaults, the language's own source code, and the majority of the open-source Swift ecosystem.

---

## 2. Line Length: Two Contradictory Numbers

**Quoted guideline:**

> **100 characters** maximum per the Google Swift Style Guide. Exceptions: URLs in comments, import statements, and generated code.
> The Kodeco guide suggests a softer 70-character guideline. Choose a limit and enforce it.

**Why this is problematic:**

Same problem as indentation -- two numbers, no decision. Worse, one of the numbers (70) is absurdly short for a modern language. A single `public func formatAge(_ dateOfBirth: String?, _ asOf: String? = nil) -> String?` is already 77 characters. At 70 characters, basic function signatures would require wrapping. The 70-character Kodeco recommendation dates from an era of side-by-side Xcode editing on smaller screens and is not appropriate for a general style guide.

Additionally, the guide's own SwiftLint configuration table (section 11) lists `line_length` with "default 120 warning, 200 error." If the guide says 100 but the tool says 120, which wins? This creates confusion.

**Recommended alternative:**

120 characters. This matches SwiftLint's default warning threshold, works well with modern screen sizes, and avoids gratuitous wrapping of function signatures. Drop the Kodeco reference entirely.

---

## 3. Import Ordering: Over-Engineered for Typical Swift Projects

**Quoted guideline:**

> Order imports in three groups, separated by blank lines, each group sorted lexicographically:
> 1. Module/submodule imports (standard library, system frameworks)
> 2. Individual declaration imports
> 3. `@testable` imports (test files only)

**Why this is problematic:**

The three-group scheme with mandatory blank-line separators adds cognitive overhead that pays for itself only in large multi-framework projects (AppKit + CoreData + third-party dependencies). In this project, the actual Swift code has exactly this import block:

```swift
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
```

There are no Foundation imports, no individual declaration imports, no multi-framework imports. For a zero-dependency library, this rule is needless ceremony. More importantly, individual declaration imports (`import struct Foundation.Date`) are rare in practice and discouraged by the guide itself ("Prefer importing whole modules over individual declarations"). Dedicating an entire group to something you discourage is contradictory.

**Recommended alternative:**

Keep it simple: imports go at the top of the file, sorted lexicographically. `@testable` imports go after regular imports. Conditional compilation blocks (`#if canImport`) are ordered by convention (Darwin/Glibc/Musl). Drop the three-group taxonomy.

---

## 4. `Void` in Closure Types: Inconsistent Rule

**Quoted guideline:**

> In function declarations, omit `Void` return types entirely. In closure type signatures, write `Void` explicitly rather than `()`:
>
> ```swift
> // Closure type: write Void
> let completion: (Result<Data, Error>) -> Void
> ```

**Why this is problematic:**

This is a reasonable stylistic preference, but the guide fails to acknowledge the legitimate case where `()` is correct and `Void` is not: tuple contexts. `(Int, Void)` and `(Int, ())` mean different things in some generic contexts. More practically, `Void` and `()` are aliases and the Swift compiler treats them identically. The guide should just pick one and explain that they are interchangeable, rather than creating a rule that depends on whether you are writing a function declaration or a closure type annotation -- a distinction that requires the reader to think about syntactic context rather than just applying a uniform convention.

**Recommended alternative:**

Prefer `Void` over `()` as the return type in all type signatures (both functions and closures) when you need to write it explicitly. In function declarations, omit it entirely. This is simpler: either write `Void` or write nothing.

---

## 5. Protocol Conformances in Separate Extensions: Dogmatic

**Quoted guideline:**

> Place each protocol conformance in its own extension, separated by `// MARK: -` comments.

**Why this is problematic:**

This rule makes sense for conformances with significant method bodies (e.g., implementing `UITableViewDataSource`), but it is counterproductive when applied uniformly. Declaring `Equatable` conformance in a separate extension when the compiler can synthesize it means you now have a multi-line extension block with a MARK comment and an explicit `==` implementation for something the compiler would have done for you with a single protocol declaration:

```swift
// This:
struct Foo: Equatable {
    let x: Int
}

// Is better than this:
struct Foo {
    let x: Int
}

// MARK: - Equatable

extension Foo: Equatable {
    static func == (lhs: Foo, rhs: Foo) -> Bool {
        lhs.x == rhs.x
    }
}
```

For synthesizable conformances (`Equatable`, `Hashable`, `Codable`, `Sendable`), putting the protocol in the type declaration is strictly better: less code, compiler-verified correctness, and easier to see the full set of conformances at a glance. The separate-extension pattern should be guidance for substantial conformances, not a blanket rule.

**Recommended alternative:**

Declare synthesizable conformances (`Equatable`, `Hashable`, `Codable`, `Sendable`, `CaseIterable`, `RawRepresentable`) in the type declaration. Use separate extensions for protocol conformances that require hand-written method implementations, especially when those implementations are more than a few lines.

---

## 6. Access Control on Extensions: Too Absolute

**Quoted guideline:**

> Do not specify access levels on the extension itself. Instead, specify access on each member:
>
> ```swift
> // Avoid: access on extension
> public extension SayableAgeFormatter {
>     static func formatAgeDefault(...) -> String? { ... }
> }
> ```

**Why this is problematic:**

This rule ignores a common, legitimate use case. When you add an extension with five public methods, writing `public` on each method is repetitive noise. The `public extension` form communicates intent clearly: "everything in this block is public API." The per-member approach is better when an extension mixes access levels, but banning `public extension` outright is dogmatic.

The Google guide (cited as a source) actually allows access on the extension itself when all members share the same level. SwiftLint's `no_extension_access_modifier` rule is opt-in, not default, precisely because the community is split on this.

**Recommended alternative:**

Use access-level annotations on the extension when all members share the same level. Use per-member annotations when the extension mixes access levels. Both are acceptable.

---

## 7. `assertionFailure` in Catch Blocks: Wrong Advice

**Quoted guideline:**

> Never silently swallow errors. At minimum, log or assert:
>
> ```swift
> do {
>     try operation()
> } catch {
>     assertionFailure("Unexpected error: \(error)")
> }
> ```

**Why this is problematic:**

`assertionFailure` is stripped from release builds. This means the "at minimum" recommendation is actually a silent swallow in production. The code will hit the catch block, execute `assertionFailure` (which does nothing in release), and then fall through to whatever comes after the `do/catch`. If the intent is to crash on truly unexpected errors, use `fatalError`. If the intent is to handle the error gracefully, do that. `assertionFailure` sits in a dangerous middle ground where it looks like you are handling the error during development but silently ignoring it in production.

**Recommended alternative:**

If the error is genuinely unexpected and unrecoverable, use `fatalError("Unexpected error: \(error)")`. If it is recoverable, handle it (log it, return a default, propagate it). Do not use `assertionFailure` as an error-handling mechanism. Reserve `assertionFailure` for conditions that represent programmer error in debug builds, where the release-mode behavior is intentionally "continue despite the impossible."

---

## 8. `where` Clauses on `for` Loops: Overrecommended

**Quoted guideline:**

> Use `where` on `for` loops to fold simple conditions into the loop header:
>
> ```swift
> // Preferred: where clause
> for item in collection where item.isActive {
>     process(item)
> }
> ```

**Why this is problematic:**

The `where` clause on `for` loops is syntactic sugar that moves the condition into a less visible position. For simple boolean checks it can work, but the guide presents it as categorically "preferred" over the explicit `if` form. In practice, `where` clauses on `for` loops have several drawbacks:

1. They cannot be set as breakpoints in the debugger (the condition is part of the loop header, not a separate statement).
2. They compose poorly -- when you need to add a second condition or add an `else` branch, you have to refactor the entire loop.
3. They are less scannable. In `for item in collection { if item.isActive { ... } }`, the filtering is visually distinct from the iteration. In the `where` form, they are merged.

The `where` clause shines in `switch` cases and generic constraints, where it is the only way to express the condition. In `for` loops, it is a stylistic preference, not a clear improvement.

**Recommended alternative:**

Present both forms as acceptable. Use `where` when the condition is a single, simple predicate and the loop body is short. Use `if` when the condition is complex, when you might need an `else` branch, or when debuggability matters. Do not mark either as categorically preferred.

---

## 9. Property Wrappers Section: Misplaced in an Auditing Guide

**Quoted guideline (section 9, "Common Idioms"):**

> Property wrappers attach reusable logic to property declarations. Define them with `@propertyWrapper`:
>
> ```swift
> @propertyWrapper
> struct Clamped<Value: Comparable> { ... }
> ```

**Why this is problematic:**

The guide is described as "intended for code auditing Swift implementations." The property wrapper example (`@Clamped`) is a teaching example that belongs in a tutorial, not in an auditing checklist. The actual codebase uses no property wrappers. Including a full implementation example for a feature the project does not use inflates the guide without adding auditing value. An auditing guide should focus on "what to look for" and "what to flag," not "here is how to implement a feature you might use someday."

**Recommended alternative:**

Remove the property wrapper implementation example. If property wrappers are relevant to the project, add a brief note: "Keep property wrappers focused on a single responsibility. Ensure the `wrappedValue` getter and setter are side-effect-free or clearly documented." Otherwise, omit the section entirely.

---

## 10. Copy-on-Write Section: Irrelevant to This Project

**Quoted guideline (section 7):**

> When implementing your own large value types that wrap a reference-type buffer, implement CoW manually:
>
> ```swift
> struct LargeData {
>     private var storage: StorageRef
>
>     mutating func update(_ value: Int) {
>         if !isKnownUniquelyReferenced(&storage) {
>             storage = storage.copy()
>         }
>         storage.data = value
>     }
> }
> ```

**Why this is problematic:**

Manual Copy-on-Write is an advanced optimization technique used in a tiny fraction of Swift codebases (standard library, high-performance data structures). This project is a formatting library whose types are small structs with string properties. Including a manual CoW implementation example in an auditing guide for this project is like including guidance on kernel module development in a web application style guide. It adds noise and suggests to auditors that they should be looking for CoW patterns in code that will never need them.

**Recommended alternative:**

Mention that standard library collections use CoW in a single sentence (this is useful general knowledge). Remove the manual CoW implementation example entirely.

---

## 11. Actors Section: Scope Creep

**Quoted guideline (section 7):**

> When you need shared mutable state in a concurrent context, prefer `actor` over `class` with manual synchronization:
>
> ```swift
> actor FormatterCache { ... }
> ```

**Why this is problematic:**

This is a zero-dependency formatting library with no concurrency. All types are already `Sendable` structs. Including actor guidance with a `FormatterCache` example implies that auditors should be evaluating concurrent access patterns, which is not relevant here. The example also introduces a pattern (caching formatters) that the actual code does not use and should not use without profiling data showing it is needed.

**Recommended alternative:**

Remove the actor example. Keep a single sentence noting that types should be marked `Sendable` when they are safe to share across concurrency boundaries (this is already well-covered in section 9 and the checklist). If concurrency becomes relevant to the project, add a dedicated concurrency section at that time.

---

## 12. Missing: Guidance on String Interpolation vs. Concatenation

**What is missing:**

The actual codebase uses manual string concatenation (`+`) and custom `stringReplace` / `stringContains` functions that operate on UTF-8 byte arrays. This is a significant implementation pattern that the style guide completely ignores. An auditing guide for this codebase should address:

- When to use string interpolation (`"\(count) \(unit)"`) vs. concatenation (`count.description + " " + unit`)
- When manual UTF-8 byte manipulation is appropriate (as in the `stringReplace` function) vs. using Swift's native string operations
- The performance tradeoffs of these approaches

This is the kind of project-specific guidance that makes a style guide useful for auditing, as opposed to generic Swift knowledge that any engineer already has.

**Recommended addition:**

Add a section on string handling that acknowledges the project's zero-dependency constraint and provides guidance on when byte-level string operations are justified.

---

## 13. Missing: Guidance on Static Stored Properties and Initialization Order

**What is missing:**

The codebase uses `private static let defaultFormatter = SayableAgeFormatter(Locales.EN)`, which is a lazily-initialized static stored property. This is a common Swift pattern but has subtle implications: it is thread-safe (guaranteed by Swift), lazily initialized on first access, and never deallocated. The guide covers `static` in the access control section but does not discuss the initialization semantics of static stored properties, which are important for an auditing guide to cover.

**Recommended addition:**

Add a brief note in the "Common Idioms" section explaining that static stored properties in Swift are lazily initialized and thread-safe, and that they are appropriate for singletons and default instances.

---

## 14. `private` vs `fileprivate` Guidance Contains a Stale Caveat

**Quoted guideline:**

> **Use `private` over `fileprivate`** unless you need access from an extension in the same file that cannot see `private` members. Since Swift 4, `private` is visible to extensions of the same type in the same file, which reduces the need for `fileprivate`.

**Why this is problematic:**

The "unless you need access from an extension in the same file that cannot see `private` members" clause is confusing because it describes a situation that essentially no longer exists in Swift 4+. Since Swift 4, `private` members ARE visible in extensions of the same type in the same file. The only remaining use case for `fileprivate` is accessing a member from a different type defined in the same file, which is uncommon and arguably an indicator that the types should be in separate files. The caveat undermines the simplicity of the rule.

**Recommended alternative:**

State the rule plainly: use `private`. The only case for `fileprivate` is when two distinct types in the same file need to share members. If you find yourself reaching for `fileprivate`, consider whether the types belong in separate files.

---

## 15. Quick Reference Checklist: Missing Items, Includes Noise

**Quoted guideline:**

> - [ ] `self` is omitted when not required

**Why this is problematic:**

This is a trivially enforceable lint rule (SwiftLint's `redundant_self`). Including it in a manual auditing checklist wastes reviewer attention on something a tool should catch. Meanwhile, the checklist omits items that actually require human judgment:

- Are test functions named descriptively enough to serve as documentation?
- Are magic string literals (like date format patterns) handled consistently?
- Is the public API surface minimal (nothing is `public` that does not need to be)?
- Are `@Sendable` annotations on closures correct?

**Recommended alternative:**

Remove items from the checklist that are enforced by SwiftLint or swift-format. Add items that require human judgment and are relevant to this project's auditing goals.

---

## Summary

The guide is well-written and comprehensive in its coverage of Swift language features. Its primary weakness is that it reads as a generic Swift reference rather than a focused auditing guide for this specific project. It defers decisions where it should make them (indentation, line length), includes advanced topics the project does not need (CoW, actors, property wrappers), and misses project-specific patterns that would actually help auditors (string handling, static initialization, the zero-dependency constraint's impact on coding patterns).

The revised guide should be opinionated where the original is ambiguous, focused where the original is encyclopedic, and project-aware where the original is generic.

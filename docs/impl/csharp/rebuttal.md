# C# Style Guide -- Senior Staff Engineer Rebuttal

This document records my review of the C# Style Guide (`docs/impl/csharp/README.md`). The guide is generally solid and well-researched -- it draws from the right sources and covers the right territory. However, I have substantive disagreements on several points, ranging from incorrect technical advice to needlessly dogmatic rules to important omissions.

---

## 1. `var` for `foreach` loops -- dogmatic and wrong

**Guideline quoted:**

> **Do not** use implicit typing for `foreach` loop variables (the collection name alone is insufficient to infer the element type clearly).

**Analysis:**

This is overly dogmatic and the justification is weak. The collection name *frequently* makes the element type obvious:

```csharp
foreach (var customer in customers) { }
foreach (var entry in dictionary) { }
foreach (var file in Directory.GetFiles(path)) { }
```

Nobody is confused about what `customer` is when iterating `customers`. The guide itself advocates `var` when "the type is obvious from the right side," and a well-named collection on the right side of a `foreach` makes the type obvious. The blanket ban creates noise -- `foreach (KeyValuePair<string, List<CustomerOrder>> entry in lookupTable)` is worse than `foreach (var entry in lookupTable)` in every way.

Microsoft's own coding conventions document does not ban `var` in `foreach`. The .NET runtime codebase uses `var` in `foreach` routinely.

**Recommendation:** Apply the same rule as everywhere else: use `var` when the element type is obvious from context; spell it out when it is not. Drop the blanket prohibition.

---

## 2. `s_` and `t_` prefixes for static and thread-static fields

**Guideline quoted:**

> Private/internal static fields: camelCase with `s_` prefix -- `s_workerQueue`
> Thread-static fields: camelCase with `t_` prefix -- `t_timeSpan`

**Analysis:**

These prefixes come from the .NET runtime coding style, which is a massive, low-level runtime codebase with specific constraints (extensive interop, unsafe code, performance-critical paths where knowing a field's storage class at a glance matters). For application and library code, `s_` and `t_` are unusual conventions that most C# developers will not recognize. Microsoft's general C# coding conventions document does not recommend them.

Presenting these as the standard C# convention without qualification is misleading. A developer following this guide for a typical business application or library will produce code that looks foreign to most C# teams.

**Recommendation:** Present `_camelCase` as the standard convention for all private fields (instance and static). Mention `s_` and `t_` as an alternative used by the .NET runtime for codebases where distinguishing field storage class at the call site is important. Let teams decide.

---

## 3. Sealed classes -- "do not seal without a good reason" inverts the right default

**Guideline quoted:**

> **Do not seal classes without a good reason.** Sealing prevents extension, which frustrates consumers.

**Analysis:**

This is the historical .NET guidance, but it is increasingly considered backwards by the .NET team itself and the broader community. The *Framework Design Guidelines* (cited as a source for this guide) discusses the tension, and more recent thinking -- including from members of the .NET team -- favors sealing by default.

The reasoning: unsealed classes are part of your public contract. Every `virtual` method is a promise that subclasses can override it and the base class will still behave correctly. That is a heavy design burden. If you did not design for inheritance, leaving a class unsealed invites fragile-base-class bugs. Sealing is the conservative, safe default. You can always unseal later (that is a non-breaking change); sealing a previously-unsealed class is a breaking change.

Performance also favors sealing: the JIT can devirtualize calls on sealed types, and sealed classes enable more aggressive inlining.

The guide's own advice to "consider sealing overrides" already acknowledges the fragile-base-class problem. The overall guidance should be consistent with that.

**Recommendation:** Reverse the default: "Seal classes unless you have designed them for inheritance." Unsealing is a deliberate API decision that requires designing and documenting the extension points. This matches modern .NET practice and the performance guidance from the .NET team.

---

## 4. `ConfigureAwait(false)` guidance is outdated for modern .NET

**Guideline quoted:**

> In **library code**, use `ConfigureAwait(false)` on every `await` to avoid capturing the synchronization context. This prevents deadlocks when library code is called from UI threads.

**Analysis:**

This advice was critical in .NET Framework (4.x) where ASP.NET had a `SynchronizationContext` and deadlocks were a real risk. In modern .NET (Core, 5+), ASP.NET does not have a `SynchronizationContext`, so `ConfigureAwait(false)` is unnecessary in ASP.NET code and in libraries that only target modern .NET.

The guide does not mention this important distinction. A developer targeting .NET 8 who sprinkles `ConfigureAwait(false)` on every await is adding noise for no benefit (unless the library also targets .NET Framework or is used from WPF/WinForms/MAUI). The advice is not *wrong* in the general case, but presenting it without context leads to cargo-cult usage.

**Recommendation:** Keep the guidance but qualify it: `ConfigureAwait(false)` is important in library code that may be consumed from contexts with a `SynchronizationContext` (WPF, WinForms, MAUI, or .NET Framework ASP.NET). For libraries targeting only modern .NET (Core/5+) server applications, it is unnecessary but harmless. Do not apply it in application code.

---

## 5. Using declarations -- the blanket preference is wrong

**Guideline quoted:**

> Prefer the modern `using` declaration (without braces) over `using` statements

**Analysis:**

The `using` declaration (no braces) disposes at the end of the enclosing scope, which is *the entire method*. The braced `using` statement disposes at the end of the block. These have different semantics, and the right choice depends on the situation.

If you open a file, read it, and then do substantial additional work in the same method, the `using` declaration holds the file handle open for the entire method, which may be undesirable. The braced form lets you release the resource as soon as you are done with it.

Presenting the braceless form as a blanket preference obscures this tradeoff. Both forms exist for a reason.

**Recommendation:** Explain both forms and their scoping difference. Recommend the `using` declaration when the resource is needed for the rest of the method (the common case). Recommend the braced `using` statement when you need to release the resource before the method ends. Do not present either as a blanket preference.

---

## 6. Comments: "End with a period" is unnecessary prescription

**Guideline quoted:**

> Begin with an uppercase letter. End with a period.

**Analysis:**

Requiring a period at the end of every `// comment` is pedantic and inconsistently followed even in Microsoft's own codebases. For brief inline comments, the period adds nothing. XML doc comments (`///`) should be grammatically complete sentences -- that is a reasonable standard because they generate documentation. But enforcing sentence-ending punctuation on every `// Increment counter.` is the kind of rule that annoys developers without improving code quality.

**Recommendation:** Require proper punctuation for XML doc comments, which become external documentation. For inline `//` comments, recommend starting with an uppercase letter but drop the period requirement. Focus the energy on the guide's own (correct) advice that comments should explain "why" not "what."

---

## 7. The `var` guidance for method returns is too conservative

**Guideline quoted:**

> **Do not** use `var` when the type is unclear from the expression (method return values, complex chains).

with the example:

```csharp
int count = GetActiveCount();
Customer current = customers.FirstOrDefault();
```

**Analysis:**

The first example is reasonable. The second is debatable -- `customers.FirstOrDefault()` on a variable named `customers` makes it fairly clear you are getting a `Customer`. But more importantly, the guidance is too absolute. Consider:

```csharp
var connection = CreateConnection();    // clearly a connection
var response = await client.SendAsync(request);  // clearly a response
var logger = LoggerFactory.CreateLogger<MyClass>(); // clearly a logger
```

These are method returns where `var` is perfectly clear. The guide should acknowledge that well-named methods make the return type evident, rather than categorically banning `var` for all method returns.

**Recommendation:** Soften to: "Avoid `var` when the type cannot be readily inferred from the method name and context." The test is readability, not a mechanical rule about method returns.

---

## 8. Missing: primary constructors (C# 12)

**Analysis:**

The guide covers C# 12 collection expressions but omits primary constructors, which are one of the most significant additions in C# 12. Primary constructors for classes and structs (not just records) change how dependency injection and field initialization are written. A style guide that mentions C# 12 features should address:

- When to use primary constructors vs. traditional constructors
- The fact that primary constructor parameters are *not* fields -- they are captured in a closure, which has implications for mutability and serialization
- Naming conventions for primary constructor parameters (the guide does mention `camelCase` in the naming table but does not discuss the usage patterns)

**Recommendation:** Add a section on primary constructors covering usage guidance and the parameter capture semantics.

---

## 9. Missing: `IDisposable` / `IAsyncDisposable` implementation guidance

**Analysis:**

The guide covers *consuming* disposables (`using` declarations) and mentions `ObjectDisposedException` in the exception table, but says nothing about *implementing* `IDisposable`. The dispose pattern is one of the most commonly botched patterns in C#. A comprehensive style guide should cover:

- The standard dispose pattern (sealed vs. unsealed classes)
- `IAsyncDisposable` for async cleanup
- When to implement `IDisposable` (owning unmanaged resources or owning other disposable objects)

**Recommendation:** Add a section on implementing the dispose pattern correctly.

---

## 10. Missing: collection return types

**Guideline quoted (partial):**

> **Returning `null` from collections.** Return an empty collection instead.

**Analysis:**

The guide correctly says not to return null from collections, but says nothing about *which* collection type to return. This is a frequent API design question in C#. Should a method return `IEnumerable<T>`, `IReadOnlyList<T>`, `IList<T>`, `List<T>`, an array? The Framework Design Guidelines (cited as a source) have specific advice here:

- Return the most specific type that makes sense for the caller
- Prefer `IReadOnlyList<T>` or `IReadOnlyCollection<T>` for read-only results
- Avoid returning `IEnumerable<T>` when the caller will need to count or index

This is a gap worth filling.

**Recommendation:** Add guidance on collection return types, favoring `IReadOnlyList<T>` for read-only results and explaining when `IEnumerable<T>` is and is not appropriate.

---

## 11. The composition-over-inheritance example is a straw man

**Guideline quoted:**

```csharp
// Fragile: deep hierarchy
class Animal { }
class Mammal : Animal { }
class Dog : Mammal { }
class GuideDog : Dog { }
```

**Analysis:**

This example is not convincing because it strips away all implementation details. The four-level hierarchy shown is not inherently fragile -- it becomes fragile when base classes have virtual methods with implicit behavioral contracts. The "better" composition example also has problems: it introduces two interfaces and an optional nullable field for what might be a simple is-a relationship.

The principle (favor composition over inheritance) is correct, but the example does not demonstrate *why*. A better example would show the fragile-base-class problem in action: a base class change breaking a subclass because the subclass depended on implementation details of a virtual method.

**Recommendation:** Replace the example with one that actually demonstrates the problem, or remove the example and state the principle with a brief explanation of when inheritance becomes fragile (overriding virtual methods that have implicit contracts, or inheriting implementation details that may change).

---

## 12. "Never use tabs" is overly prescriptive for a style guide

**Guideline quoted:**

> Use **four spaces** for indentation. Never use tabs.

**Analysis:**

This is a minor point. Four spaces is indeed the overwhelming C# convention, and I agree with the recommendation. But "never use tabs" is enforced through `.editorconfig` (which the guide correctly covers). Stating it as a thou-shalt-not commandment adds an unnecessarily harsh tone. The `.editorconfig` section already sets `indent_style = space`.

**Recommendation:** Keep the four-spaces recommendation. Drop the "never use tabs" admonition -- the `.editorconfig` enforces this mechanically, which is where enforcement belongs.

---

## 13. String comparison: "never rely on the default" is too strong

**Guideline quoted:**

> Always specify a `StringComparison` for culture-sensitive or case-insensitive comparisons. Never rely on the default.

**Analysis:**

The phrasing "never rely on the default" could be read as requiring `StringComparison.Ordinal` on every `string.Equals()` call, even for simple ordinal equality. The `==` operator and `string.Equals(string)` use ordinal comparison by default, which is correct for the vast majority of comparisons. Requiring an explicit `StringComparison` enum value on every comparison adds verbosity for no benefit when ordinal is what you want.

The guide partly corrects itself with "Use `string.Equals(a, b, comparison)` rather than `==` when you need non-default comparison semantics," but the "never rely on the default" phrasing at the top contradicts this.

**Recommendation:** Rephrase: "Explicitly specify `StringComparison` whenever you need case-insensitive or culture-aware comparison. The default ordinal comparison (`==`, `string.Equals(string)`) is appropriate for most cases."

---

## 14. `Task.Run` guidance is imprecise

**Guideline quoted:**

> Use `Task.Run` for CPU-bound work that should not block the calling thread.

and later:

> `Task.Run` in library code -- Unnecessary thread pool hops -- Use `Task.Run` only in application code

**Analysis:**

The first statement is fine as a general principle. The pitfalls table is more nuanced but could mislead. The real issue with `Task.Run` in libraries is not that it is always wrong, but that it hides the CPU-bound nature of the work from the caller. The caller should decide whether to offload to a thread pool. However, there are legitimate cases for `Task.Run` in library code (e.g., parallelizing an internal computation that the caller should not need to know about).

The example `CalculateAsync` wrapping `Task.Run` also has a problem: the method signature suggests it is naturally async, but it is just wrapping synchronous work. Stephen Toub's guidance is that methods should not lie about their nature -- if the work is CPU-bound, expose it as a synchronous method and let the caller decide whether to use `Task.Run`.

**Recommendation:** Clarify: expose CPU-bound work as synchronous methods. Let the caller decide whether to offload with `Task.Run`. In library code, avoid wrapping synchronous work in `Task.Run` just to provide an async signature. Move the `CalculateAsync` example to the pitfalls section as something to avoid.

---

## 15. The Quick Reference Checklist conflates universal rules with context-dependent ones

**Analysis:**

The checklist mixes items that are always applicable (e.g., "no empty catch blocks", "throw; not throw ex;") with items that depend on context (e.g., "ConfigureAwait(false) in library code" -- only relevant for libraries consumed from SynchronizationContext-bearing environments). A developer auditing a .NET 8 API would waste time checking for `ConfigureAwait(false)` that is not needed.

**Recommendation:** Split the checklist into "Always" and "Context-dependent" sections, or add brief qualifiers to context-dependent items.

---

## Summary

The guide is a good foundation. The naming conventions, formatting rules, error handling guidance, and LINQ sections are largely correct and well-presented. The main issues fall into three categories:

1. **Outdated or context-missing advice** -- `ConfigureAwait(false)`, sealed classes, `s_`/`t_` prefixes
2. **Overly dogmatic rules** -- `var` in `foreach`, comment punctuation, blanket `using` declaration preference
3. **Important omissions** -- primary constructors, `IDisposable` implementation, collection return types

None of these are dealbreakers, but addressing them would make the guide more accurate and more useful for modern C# development.

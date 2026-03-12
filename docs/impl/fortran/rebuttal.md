# Fortran Style Guide -- Senior Engineering Review

Reviewer: Senior Staff Engineer
Date: 2026-03-11

This document is a detailed technical rebuttal of specific guidelines in the Fortran style guide that are problematic, misleading, incomplete, or insufficiently nuanced for production use.

---

## 1. Constants casing: mixed convention without a clear rule

**Quoted guideline:**

> | Constants/parameters | lowercase or UPPER_CASE | `dp`, `PT_MAX_STR_LEN` |

**Problem:**

"lowercase or UPPER_CASE" is not a guideline -- it is the absence of one. A style guide that says "either is fine" for the same syntactic category adds no value for that category. It actively encourages inconsistency within a codebase.

The existing codebase already demonstrates a coherent pattern: kind parameters and small numeric helpers are lowercase (`dp`, `sp`), while domain constants and enum-like parameters are UPPER_CASE with a prefix (`PT_ZERO`, `PT_MAX_STR_LEN`). That distinction is meaningful and should be codified.

**Recommendation:**

Split the row into two explicit rules:
- Kind parameters and numeric precision constants: lowercase (`dp`, `sp`, `qp`, `i32`, `i64`)
- Domain constants, enumerators, and configuration parameters: UPPER_CASE with a descriptive prefix (`PT_ZERO`, `PT_MAX_STR_LEN`, `PT_MAX_AGE_MONTHS`)

---

## 2. Indentation: "2 spaces" presented as community consensus, but it is not

**Quoted guideline:**

> Use **2 spaces** per indentation level. This is the most common choice in the Fortran community (3 and 4 spaces are also acceptable; pick one and be consistent).

**Problem:**

The claim that 2 spaces is "the most common choice in the Fortran community" is not supported by evidence and is likely wrong. The fortran-lang.org best practices page uses 4 spaces. The Fortran stdlib uses 4 spaces. The fpm project uses 4 spaces. NAG's examples use 3 spaces. Metcalf, Reid, and Cohen's textbook uses 2-3 spaces depending on edition. If anything, 4 spaces has the strongest claim to "most common in modern Fortran," and 2 spaces is the minority choice.

The parenthetical "(3 and 4 spaces are also acceptable; pick one and be consistent)" undermines the guideline by immediately equivocating.

The actual codebase in this project uses 2 spaces, so the guideline should recommend 2 spaces -- but it should do so as a project decision, not as a false appeal to community authority.

**Recommendation:**

State the project standard directly: "Use 2 spaces per indentation level. This is the project convention." Drop the unsupported claim about community consensus. If you want to acknowledge the broader ecosystem, note that 2-4 spaces are all common in Fortran projects, but this project standardizes on 2.

---

## 3. `use` with `only` presented as absolute rule, but the actual codebase violates it

**Quoted guideline:**

> **Always use explicit imports** with the `only` clause:
> ```fortran
> use sayableage_types, only: pt_locale, PT_MAX_STR_LEN
> ```

**Problem:**

The guide says "always," but the project's own main module (`sayableage.f90` line 2) uses a bare `use sayableage_types` with no `only` clause. When your own codebase contradicts an "always" rule on the very first `use` statement of the primary module, the rule is either wrong or the code needs to change.

Furthermore, there are legitimate cases where a bare `use` is defensible. When a module exists solely to define a cohesive set of types for another module that uses nearly all of them (as `sayableage_types` does for `sayableage`), listing every symbol in an `only` clause creates a maintenance burden with little benefit. If the types module adds a new public symbol, you must update the `only` clause in every consumer. This coupling is worse than the problem `only` solves.

The rule conflates two different concerns: (a) importing from large, kitchen-sink modules where `only` is genuinely important, and (b) importing from small, purpose-built companion modules where `only` adds noise.

**Recommendation:**

Change "always" to "prefer." State that `only` is required when importing from large or shared modules (like `iso_fortran_env`), but bare `use` is acceptable for small, tightly coupled companion modules where the consumer uses most or all of the module's public interface. Note that this is a pragmatic trade-off, not a license for laziness.

---

## 4. `result` clause presented as universally preferable, but that is debatable

**Quoted guideline:**

> Use the `result` clause on functions to give the return value a descriptive name:
> ```fortran
> pure function days_in_month(year, month) result(days)
> ```
> This is more readable than reusing the function name as the result variable.

**Problem:**

The claim that `result` is "more readable" is stated as fact but is a matter of style preference with trade-offs. When the function name is already descriptive (as in `days_in_month`), the `result` clause adds a level of indirection: the reader must now track that `days` is the return value, not just another local variable. In a short function, using the function name as the result variable is perfectly clear and has the advantage that every assignment to it is obviously "this is what we are returning."

The `result` clause genuinely helps when the function name is long or when the natural name for the return value differs from the function name. It should be recommended in those cases, not as a blanket rule.

**Recommendation:**

Present `result` as useful when the function name is long or when a more descriptive result name improves clarity. Acknowledge that for short, well-named functions, using the function name as the result variable is equally valid. The key principle is that the result variable's name should be obviously the return value; `result` is one tool for achieving that, not the only one.

---

## 5. Parameterized Derived Types: recommending a poorly-supported feature

**Quoted guideline:**

> Fortran 2003 supports parameterized types with `kind` and `len` parameters:
> ```fortran
> type :: fixed_string(max_len)
>   integer, len :: max_len
>   ...
> ```
> Note: compiler support for parameterized types varies; test with your target compilers.

**Problem:**

This is burying the lede. Parameterized derived types (PDTs) are one of the most notoriously broken features in Fortran compilers. As of 2026, gfortran's PDT support is still incomplete and has known ICE (internal compiler error) bugs. Intel's ifx has partial support with restrictions. NAG has the most complete implementation but still has edge cases. flang-new has minimal support.

Including PDTs in a style guide -- even with the soft caveat "compiler support varies" -- signals that they are a reasonable tool to reach for. In practice, using PDTs in production code is likely to cause compiler bugs, portability problems, and maintenance headaches. The caveat should be a warning, not a footnote.

**Recommendation:**

Either remove the PDT section entirely, or rewrite it as a "be aware this exists but avoid it in production" note. State clearly that PDT compiler support remains incomplete across all major compilers and that using them risks ICEs and portability failures. Recommend allocatable components or explicit kind parameters as the practical alternatives.

---

## 6. Elemental procedures: `elemental` implies `pure` is glossed over

**Quoted guideline:**

> Mark procedures as **`elemental`** when they operate on scalar arguments but should also accept arrays. Elemental implies pure.

**Problem:**

The guide states "elemental implies pure" as a side note, but this has a critical practical consequence that is not explained: if you mark something `elemental`, it must satisfy all `pure` constraints. A developer who adds `elemental` to a function that performs I/O or modifies module state will get a cryptic compiler error. The guide should make it explicit that `elemental` is a strict superset of `pure`'s restrictions.

Additionally, since Fortran 2008, `impure elemental` exists and allows elemental procedures with side effects. The guide does not mention this at all. For a guide targeting Fortran 2008 as the baseline, this is an omission.

**Recommendation:**

Expand the section to clearly state that `elemental` imposes all `pure` restrictions (no I/O, no modifying module state, no `stop`/`error stop`). Mention `impure elemental` (Fortran 2008) for cases where elemental application is desired but side effects are unavoidable (e.g., elemental I/O formatting). Warn that `impure elemental` procedures cannot be used in `do concurrent` or `forall`.

---

## 7. `do concurrent` requirements are incomplete

**Quoted guideline:**

> Requirements:
> - No iteration may depend on a previous iteration
> - No I/O operations inside the loop
> - No `exit`, `stop`, or `error stop`
> - All called procedures must be `pure`

**Problem:**

This list is incomplete and therefore dangerous. Missing constraints include:
- No `cycle` with a named construct outside the `do concurrent`
- No branching out of the construct (no `return` either)
- No advancing I/O (non-advancing I/O is also forbidden)
- Allocatable variables with `SAVE` attribute cannot be modified
- IEEE floating-point flag modifications have restrictions

Presenting an incomplete list of requirements for `do concurrent` can lead to code that compiles without diagnostics on one compiler but fails or produces wrong results on another. Compilers vary widely in how strictly they enforce `do concurrent` semantics.

**Recommendation:**

Either provide the complete set of restrictions (referencing the standard section 11.1.7.5), or simplify the guidance to: "The body of `do concurrent` must be equivalent to calling a `pure` procedure with no inter-iteration dependencies. When in doubt, consult your compiler's documentation and the standard."

---

## 8. `associate` construct: missing the major gotcha

**Quoted guideline:**

> Use `associate` to create temporary named aliases for complex expressions, improving readability:
> ```fortran
> associate(loc => locale%stages, lbl => stage%label)
> ```
> This avoids repeating deeply nested component references without introducing new variables or copies.

**Problem:**

The guide promotes `associate` without mentioning its most significant pitfall: whether the association is by reference or by copy depends on the associated expression, and this is a source of subtle bugs. When the selector is a variable (like `locale%stages`), the association is by reference and modifications are reflected. When the selector is an expression (like `a + b`), the associate name refers to a temporary. This distinction is not obvious and has caused real production bugs where developers assumed they could modify an associated name and have it persist.

Additionally, `associate` interacts poorly with some debuggers and can make debugging harder because the debugger may not recognize the associate names as steppable variables.

**Recommendation:**

Add a warning about the reference-vs-temporary semantics. State that associate names bound to variables are aliases (modifications through them modify the original), while associate names bound to expressions are read-only temporaries. Recommend using `associate` primarily for read-only aliasing of deeply nested access paths, where the semantics difference does not matter.

---

## 9. The `block` construct example is contrived and teaches bad habits

**Quoted guideline:**

> ```fortran
> subroutine process(data, n)
>   ...
>   block
>     real(dp) :: max_val
>     max_val = maxval(data)
>     if (max_val > 0.0_dp) data = data / max_val
>   end block
>   block
>     integer :: i
>     do i = 1, n
>       data(i) = sqrt(data(i))
>     end do
>   end block
> end subroutine process
> ```

**Problem:**

This example suggests using `block` to scope a single temporary variable (`max_val`) and a loop counter (`i`). This is over-engineering. In practice, declaring `max_val` and `i` at the top of the subroutine is simpler, clearer, and idiomatic Fortran. The `block` construct adds syntactic overhead (4 extra lines) for no practical benefit in this example.

`block` is genuinely useful for introducing variables in contexts where declarations are otherwise illegal (e.g., inside a `select case` body, or when you need an allocatable local in the middle of a procedure). Using it for simple temporaries teaches readers to reach for it unnecessarily.

**Recommendation:**

Replace the example with one where `block` genuinely helps -- for example, declaring a locally-scoped allocatable array within a branch of a `select case`, or isolating a temporary that would otherwise name-clash in a large procedure. State that `block` should not be used when a simple declaration at procedure scope suffices.

---

## 10. Floating-point literal suffixes: the `1.0d0` form is dismissed too casually

**Quoted guideline (in the checklist):**

> Floating-point literals carry kind suffix (`1.0_dp`, not `1.0d0` or `1.0`)

**Problem:**

The guide equates `1.0d0` with `1.0` as things to avoid, but they are very different. `1.0` is a single-precision literal and genuinely loses precision. `1.0d0` is a double-precision literal and does not lose precision -- it gives you exactly the same value as `1.0_real64` in all standard-conforming compilers.

The argument for `1.0_dp` over `1.0d0` is a style preference (parametric kind portability), not a correctness issue. The guide should not imply that `1.0d0` causes precision loss. It should explain that `_dp` is preferred because it is parametric -- if you change what `dp` maps to, all your literals follow -- while `d0` is hardcoded to double precision.

**Recommendation:**

Separate the two cases: `1.0` (genuinely wrong for double-precision work -- silent precision loss) vs. `1.0d0` (functionally correct but non-parametric). Recommend `1.0_dp` as the preferred form for its parametric flexibility, but do not lump `1.0d0` in with `1.0` as an equivalently bad practice.

---

## 11. Internal procedures promoted without discussing their drawbacks

**Quoted guideline:**

> Subroutines and functions defined after `contains` inside a program unit or another procedure have access to the host's variables by host association. Use them for small helpers that don't warrant a separate module procedure.

**Problem:**

The guide enthusiastically recommends internal procedures without discussing their significant drawbacks:
1. Internal procedures have access to all host variables by host association. This is the opposite of encapsulation -- they silently depend on and can modify any variable in the enclosing scope. Bugs from accidentally referencing a host variable instead of a local one are common and hard to catch.
2. Internal procedures cannot be `pure` if the host procedure is not pure, which limits optimization.
3. They cannot be passed as procedure arguments in standard Fortran (they are not module procedures).
4. They complicate unit testing because they cannot be called independently.

The example in the guide (`normalize` and `scale` modifying `x` from the host) is actually a demonstration of the problem: these procedures silently depend on the host's `x` and `n` variables, and there is no explicit interface showing this dependency.

**Recommendation:**

Keep internal procedures as an option but add warnings about host association. Recommend that internal procedures should be small (under ~10 lines), should document which host variables they access, and should generally be read-only with respect to host variables. For anything more substantial, a module procedure with explicit arguments is safer and more testable.

---

## 12. Missing guidance on `intent(out)` with derived types

**Problem (omission):**

The guide covers `intent(in)`, `intent(out)`, and `intent(inout)` for scalar arguments but fails to mention a critical gotcha with `intent(out)` and derived types: when a derived type argument has `intent(out)`, all components are undefined on entry -- even those with default initialization in the type definition. This means that if you have:

```fortran
type :: config
  integer :: mode = 0
  logical :: verbose = .false.
end type config

subroutine init(c)
  type(config), intent(out) :: c
  c%mode = 1
  ! c%verbose is now UNDEFINED, not .false.
end subroutine
```

This is one of the most common sources of bugs in Fortran code using derived types. The guide should cover it.

**Recommendation:**

Add a subsection to the intent attributes section warning that `intent(out)` causes all components of a derived type to become undefined on entry. Recommend either using `intent(inout)` when you want to preserve defaults, or explicitly setting all components in `intent(out)` procedures.

---

## 13. Missing guidance on string comparison and trailing blanks

**Problem (omission):**

The string handling section covers `trim()`, concatenation, and intrinsics, but does not mention a fundamental property of Fortran string comparison: Fortran's `==` operator on character strings pads the shorter string with blanks before comparing. This means `"Alice" == "Alice   "` is `.true.`, which is the opposite of what most developers from other languages expect.

This is especially relevant in code like this project's `sayableage.f90`, which does heavy string manipulation. The implicit blank-padding comparison can mask bugs or produce surprising results.

**Recommendation:**

Add a note explaining that Fortran's character comparison pads with trailing blanks, so `"abc" == "abc   "` is true. Recommend `trim()` for comparisons only when the distinction between padded and unpadded matters (which, given Fortran's semantics, is rare for `==` but critical for `//` concatenation).

---

## 14. The "Things to Avoid" section conflates obsolescent features with bad practices

**Problem:**

Section 10 mixes genuinely dangerous constructs (`COMMON`, `EQUIVALENCE`, `GOTO`) with features that are merely obsolescent or suboptimal (`FORALL`, `double precision`, `external`). The section also mixes features that are actively harmful in all contexts with features that are only problematic in new code but harmless to encounter in legacy code.

A reviewer using this as an audit checklist needs to distinguish between "this is a bug risk" and "this is a style violation." The section gives them no way to do so.

**Recommendation:**

Split into two subsections: "Dangerous constructs" (COMMON, EQUIVALENCE, GOTO, implicit typing, assumed-size arrays) for things that are genuine correctness risks, and "Obsolescent/deprecated features" (FORALL, double precision, external, include, fixed-form) for things that are stylistically outdated but not inherently dangerous. This helps reviewers prioritize findings.

---

## 15. CMake guidance is too superficial and omits the hard part

**Quoted guideline:**

> Note: Fortran source file order matters in CMake because of module dependencies. List files so that modules are compiled before the units that `use` them.

**Problem:**

This one-sentence note buries the single hardest problem with CMake and Fortran: dependency ordering. Unlike C/C++ where header includes can be resolved with a preprocessor pass, Fortran module dependencies require that `.mod` files exist before compiling dependent source files. CMake's built-in Fortran dependency scanning handles this automatically since CMake 3.20 (using Ninja or Make generators), but the guide does not mention this. Instead, it implies you must manually order source files, which is error-prone and does not scale.

**Recommendation:**

Update the CMake section to note that CMake 3.20+ automatically scans Fortran module dependencies (with Ninja or Makefile generators). The manual ordering note should be a fallback for older CMake versions or custom build scripts, not the primary guidance. Also mention `set(CMAKE_Fortran_MODULE_DIRECTORY ...)` as essential for keeping `.mod` files in a predictable location.

---

## Summary

The guide is well-structured and covers the right topics. Its biggest systemic issues are:

1. **Absolute rules that the codebase itself violates** (`use ... only`, `result` clause). Either fix the code or relax the rules; having both is worse than having neither.
2. **Poorly-supported features presented without adequate warnings** (parameterized derived types). A style guide for production code should not recommend features that cause compiler ICEs.
3. **Incomplete technical specifications presented as complete** (`do concurrent` requirements, `associate` semantics). Incomplete rules create false confidence.
4. **Missing coverage of common gotchas** (`intent(out)` with derived types, string comparison semantics, internal procedure host association). These are the things that actually bite people.
5. **False appeals to community consensus** (2-space indentation). State your project's convention and own it.

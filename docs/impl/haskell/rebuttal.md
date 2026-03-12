# Rebuttal: Haskell Style Guide Review

Senior Staff Engineer review of the Haskell Style Guide (`docs/impl/haskell/README.md`). Each item quotes the specific guideline, explains the technical concern, and provides a recommended alternative.

---

## 1. Abbreviation casing rule is over-prescriptive and conflicts with community norms

**Quoted guideline (Section 1, Types):**

> Write abbreviations in mixed case, not all-caps.
> ```haskell
> data TomlException   -- good: abbreviation in mixed case
> data TOMLException   -- bad: all-caps abbreviation
> ```

**Why this is problematic:**

This is a reasonable default, but presenting it as an absolute rule is wrong. The Haskell ecosystem is split on this. GHC itself uses `IORef`, `IOException`, `IOError`, `STRef` -- all with uppercase abbreviations. The `aeson` library uses `JSON` in several type names. The `http-client` library uses `HTTP`. A style guide that labels `TOMLException` as "bad" while the standard library ships `IOException` creates a contradiction that undermines the guide's authority.

The deeper issue: this is a cosmetic preference being presented with the same weight as structural guidance. It does not prevent bugs, does not affect code comprehension in a meaningful way, and contradicts what developers see in `base` and major libraries daily.

**Recommended alternative:**

Present both conventions, note the ecosystem is split, and recommend consistency within a project. If the project picks one, state which and move on. Do not label either as "bad."

---

## 2. The `Data.Text` table incorrectly describes its internal representation

**Quoted guideline (Section 9, Text and Strings):**

> | `Data.Text` | Packed UTF-8 array | Production text processing |

**Why this is problematic:**

The `text` package versions prior to 2.0 (released mid-2022) used UTF-16 internally, not UTF-8. Version 2.0+ switched to UTF-8. This matters because GHC 9.4 was the first GHC to ship `text-2.0` by default, and many production codebases still use older GHC versions. Stating "Packed UTF-8 array" without qualification will confuse anyone debugging text performance on `text < 2.0`, where the internal representation is fundamentally different (UTF-16 means different memory layout, different slicing costs, and different interop characteristics with C FFI code).

For a style guide that will be used for code auditing, precision about runtime representation matters.

**Recommended alternative:**

Note that `text >= 2.0` uses UTF-8 and older versions used UTF-16. Or simply say "Packed Unicode array" without specifying the encoding, since the public API is encoding-agnostic.

---

## 3. The `StrictData` recommendation is too aggressive for a general style guide

**Quoted guideline (Section 7, Laziness and Strictness):**

> The `StrictData` extension makes all fields in a module strict by default, which is appropriate for most application code.

And later in the Tier 1 extensions list:

> `StrictData` -- strict fields by default (application code)

**Why this is problematic:**

`StrictData` as a Tier 1 "safe default" is a significant overclaim. This extension changes the semantics of every data type definition in the module. It can introduce unintended bottom-forcing behavior, break existing code that relies on lazy fields for things like recursive data structures or deferred computation, and make certain patterns (like tying-the-knot) impossible without explicit `~` annotations that most Haskell developers will not think to add.

The guide's own parenthetical "(application code)" acknowledges this is not universally appropriate, yet it is still listed in Tier 1 alongside genuinely safe extensions like `OverloadedStrings` and `ScopedTypeVariables`. Those extensions do not change the runtime semantics of existing code. `StrictData` does.

Additionally, this project (sayable-age) is a *library*, not an application. The `.cabal` file specifies `default-language: Haskell2010` with no default extensions. `StrictData` in a library can force strictness on downstream consumers who do not expect it.

**Recommended alternative:**

Move `StrictData` to Tier 2 ("Use when needed"). Keep the recommendation that record fields holding fully-evaluated data should be strict, but recommend using explicit `!` bang annotations on individual fields rather than a module-wide pragma. This is more precise, more self-documenting, and does not silently change semantics of every type in the module.

---

## 4. The `RecordWildCards` extension should not be in Tier 2

**Quoted guideline (Section 11, GHC Extensions Policy):**

> **Tier 2: Use when needed** -- add per-module with `LANGUAGE` pragma:
> - `RecordWildCards` -- `MyRecord{..}` to bind all fields

**Why this is problematic:**

`RecordWildCards` introduces implicit variable bindings. When you write `let Locale{..} = loc`, every field of `Locale` is silently brought into scope. This means:

1. Adding a field to the record definition in another module silently introduces a new binding at every use site, potentially shadowing existing variables.
2. Removing a field causes compile errors at distant use sites with no indication of why.
3. Code reviewers cannot tell which variables are in scope without looking up the record definition.
4. It directly contradicts the guide's own advice in Section 4 about explicit imports: "Use either explicit import lists or qualified imports for all non-Prelude modules. This makes dependencies obvious and prevents breakage when upstream modules add new exports."

The same reasoning applies to bindings. If implicit imports are bad because they obscure dependencies, implicit record bindings are bad for the same reason.

**Recommended alternative:**

Move `RecordWildCards` to Tier 3 ("Use sparingly") or remove it entirely and recommend `NamedFieldPuns` instead, which requires listing the fields you want to bind explicitly. `NamedFieldPuns` gives the ergonomic benefit of not repeating `field = field` while maintaining explicitness.

---

## 5. The "Do not mix `let` and `where`" rule is overly rigid

**Quoted guideline (Section 2, Code Formatting):**

> Do not mix `let` and `where` in the same definition; it hurts readability.

**Why this is problematic:**

This is stated as an absolute rule but is actually a matter of judgment. There are legitimate cases where mixing `let` and `where` is the clearest option. Consider a function with a `do` block that needs local bindings (naturally `let`) but also has pure helper functions (naturally `where`):

```haskell
processFile path = do
    contents <- readFile path
    let trimmed = strip contents
    return (parse trimmed)
  where
    strip = dropWhile isSpace . reverse . dropWhile isSpace . reverse
    parse = ...
```

Here, `let trimmed = ...` is the natural choice inside the `do` block (it depends on `contents` which is only available there), while `strip` and `parse` are pure helpers that belong in `where`. Forcing everything into `where` would require threading `contents` through unnecessarily. Forcing everything into `let` would push the main logic down below a wall of helper definitions, defeating the top-down reading order that `where` is designed to support.

**Recommended alternative:**

Soften to a guideline: "Prefer not to mix `let` and `where` in the same definition. When you do, ensure the division is clear: `let` for bindings that depend on `do`-block variables, `where` for pure helpers."

---

## 6. The function composition advice gives bad guidance on `$` chaining

**Quoted guideline (Section 5, Function Design):**

> Do not chain `$` -- use `.` for intermediate steps.
> ```haskell
> -- good
> result = process . transform . parse $ input
>
> -- bad: chained $
> result = process $ transform $ parse $ input
> ```

**Why this is problematic:**

The "bad" example is not actually bad Haskell. It is a well-understood idiom, especially common in `do` blocks and IO code where the functions involved are not pure and cannot be composed with `.`. Consider:

```haskell
putStrLn $ show $ length $ filter even xs
```

This is perfectly readable. The composition-based alternative would be:

```haskell
putStrLn . show . length . filter even $ xs
```

Both are fine. But the guide labels one as categorically "bad," which is an overstatement. Additionally, the guide's own "good" example `process . transform . parse $ input` has a subtle readability issue: when functions take multiple arguments (which is common), the `.` chain breaks and you end up needing parentheses anyway, which is exactly what `$` chaining avoids.

The real thing to avoid is mixing `$` and `.` in confusing ways, not `$` chaining per se.

**Recommended alternative:**

"Prefer `.` for composing pure functions. `$` chaining is acceptable when it reads clearly. The key principle: do not mix `.` and `$` in ways that require the reader to mentally track operator precedence."

---

## 7. Recommending `deepseq` without caveats contradicts the zero-dependency rule

**Quoted guideline (Section 7, Laziness and Strictness):**

> `deepseq a b` (from the `deepseq` package) fully evaluates `a` to normal form.
> ```haskell
> import Control.DeepSeq (force, NFData)
> processStrict :: NFData a => a -> a
> processStrict x = force x
> ```

**Why this is problematic:**

The project has a **zero runtime dependencies** rule. `deepseq` is a separate package (not part of `base`). While it ships with GHC as a boot library, it is still listed as a separate dependency in `.cabal` files. The guide presents `deepseq` usage as standard practice without noting that it would violate the project's dependency constraint.

This is not just a hypothetical concern -- the actual `sayable-age.cabal` file lists `build-depends: base >= 4.16 && < 5` with no other dependencies. A developer following this style guide might add `deepseq` without realizing it violates a project invariant.

**Recommended alternative:**

Either note that `deepseq` is a boot library that ships with GHC (and clarify whether boot libraries are acceptable under the zero-dependency rule), or omit the `deepseq` recommendation and focus on `seq`, bang patterns, and `StrictData`/strict fields, which are all zero-dependency approaches.

---

## 8. The `ExceptT` and `MonadError` section is inappropriate for this codebase

**Quoted guideline (Section 6, Error Handling):**

> For applications with complex error handling across IO and pure code, use `ExceptT` from `transformers` or the `MonadError` class from `mtl`

**Why this is problematic:**

`transformers` and `mtl` are external packages. The zero-dependency rule prohibits their use. The actual codebase uses `Maybe` for all error handling, which is entirely sufficient for a formatting library. Including guidance about monad transformer stacks in a style guide for *this* project is misleading -- it suggests these are tools the developer should reach for, when in fact they cannot be used here.

More broadly, `ExceptT` and `MonadError` are sophisticated abstractions with significant learning curves and well-documented pitfalls (e.g., `ExceptT` does not catch IO exceptions, leading to a false sense of security). Including them in a style guide without discussing these pitfalls is incomplete.

**Recommended alternative:**

Remove the `ExceptT`/`MonadError` section entirely, or move it to an appendix clearly marked as "for applications with external dependencies." The error handling hierarchy should stop at `Either` for this project.

---

## 9. The partial functions table recommends a nonexistent function

**Quoted guideline (Section 10, Things to Avoid):**

> | `init xs` | `Data.List.unsnoc` or explicit recursion |
> | `last xs` | `Data.List.unsnoc` or explicit recursion |

**Why this is problematic:**

`Data.List.unsnoc` was added in `base-4.19.0.0` (GHC 9.8). The project's cabal file specifies `base >= 4.16 && < 5`, which includes GHC 9.2+. Developers using GHC 9.2 through 9.6 (three major releases) will not have `unsnoc` available. Recommending a function that does not exist on supported compiler versions will cause confusion and compile failures.

**Recommended alternative:**

Either recommend explicit pattern matching (which always works), or note the GHC version requirement for `unsnoc`. Better yet, for this project specifically, neither `init` nor `last` are used anywhere, so the guidance should focus on the partial functions that are actually tempting in this codebase: `head`, `read`, and `fromJust`.

---

## 10. The Weeder section recommends infrastructure the project cannot support

**Quoted guideline (Section 11, Tooling):**

> [Weeder](https://github.com/ocharles/weeder) performs whole-program dead code analysis.
> Setup:
> 1. Enable HIE file generation: add `-fwrite-ide-info` to GHC options

**Why this is problematic:**

HIE files are large -- typically 5-10x the size of the source code. For a project with 110 generated locale modules, this would generate substantial build artifacts. More importantly, Weeder requires the entire project to be built with HIE generation enabled, which slows compilation noticeably. For a library that is one of 29 implementations in a polyglot project, adding Weeder-specific infrastructure is disproportionate overhead.

GHC's built-in `-Wall -Wunused-binds -Wmissing-export-lists` (which the project already uses) catches the most common dead code issues. The marginal value of Weeder for a library this small (5 hand-written source files) is negligible.

**Recommended alternative:**

Remove the Weeder section. Mention it in passing in the References if desired, but do not include setup instructions that imply it should be adopted.

---

## 11. The Type Families and GADTs guidance is irrelevant to this codebase

**Quoted guideline (Section 3, Type System):**

> Use type families for type-level computation when needed. Use GADTs when you need the type checker to track more information through pattern matching.

Along with the Phantom Types section and the detailed GADT example.

**Why this is problematic:**

A style guide should be proportionate to its audience. This guide is described as "Intended for code auditing Haskell implementations" of sayable-age. The actual codebase uses plain ADTs, record types, and `String`. No type families, no GADTs, no phantom types, no type-level programming of any kind. Including multi-paragraph sections on these advanced features creates noise that obscures the guidance that actually matters.

A code auditor reading this guide will spend time absorbing GADT patterns they will never encounter in the codebase they are auditing. That is a failure of signal-to-noise ratio.

**Recommended alternative:**

Remove the Type Families, GADTs, and Phantom Types sections. Add a brief note: "For advanced type-level programming (GADTs, type families, phantom types), consult the GHC User's Guide. These features are not used in this codebase." Keep the focus on the type patterns actually present: ADTs, newtypes, record types, and deriving.

---

## 12. The guide recommends a formatter but does not pick one

**Quoted guideline (Section 2, Code Formatting):**

> Use an automated formatter for consistency. The two leading options:
> - **Ormolu** [...]
> - **Fourmolu** [...]
> Pick one and enforce it project-wide.

And again in Section 11:

> Choose one formatter and enforce it in CI.

**Why this is problematic:**

The guide says "pick one" but does not pick one. This is an abdication of the guide's purpose. A style guide that says "use a formatter but we won't tell you which one" provides zero enforceable constraint. Two developers reading this guide may each pick a different formatter and produce incompatible formatting.

Looking at the actual codebase, there is no `.ormolu` or `fourmolu.yaml` configuration file. The CI workflow (`ghc-options: -Wall -Wcompat -Werror`) has no formatter check. This means the style guide's advice about formatter enforcement is aspirational, not actual.

**Recommended alternative:**

Pick one and commit. Given the project uses 4-space indentation (visible in the source files) and leading commas (visible in the export lists), Fourmolu with a checked-in `fourmolu.yaml` is the natural choice. If the project genuinely does not want to enforce a formatter, say so explicitly rather than giving advice that will not be followed.

---

## 13. The stylish-haskell recommendation conflicts with formatter choice

**Quoted guideline (Section 11, Tooling):**

> stylish-haskell focuses on import sorting and alignment rather than full formatting. It is commonly used alongside (or instead of) a full formatter for import organization.

**Why this is problematic:**

Both Ormolu and Fourmolu handle import sorting. Running stylish-haskell alongside either formatter will cause conflicts -- stylish-haskell may reformat imports in a way the formatter then undoes, or vice versa. The guide does not address this conflict.

In practice, no modern Haskell project uses both a full formatter (Ormolu/Fourmolu) and stylish-haskell. You pick one approach. Including stylish-haskell as a recommendation alongside the formatter recommendation creates a "pick two from three" situation that will confuse developers.

**Recommended alternative:**

Remove the stylish-haskell section. If the project uses Fourmolu (or Ormolu), import sorting is handled. If the project does not use a formatter, then stylish-haskell is an option, but that contradicts the "use a formatter" advice.

---

## 14. Missing guidance on the actual patterns used in the codebase

**What the guide omits:**

The guide is comprehensive about general Haskell but thin on patterns actually used in sayable-age. The codebase has specific patterns that deserve guidance:

1. **FFI usage**: `Internal.hs` uses `foreign import ccall` for the `time()` system call. The guide says nothing about FFI conventions, safety annotations (`safe` vs `unsafe`), or `Foreign.C.Types`.

2. **String manipulation without `Text`**: The entire codebase uses `String`, not `Text`. The guide repeatedly advocates for `Text` but does not acknowledge that this codebase deliberately uses `String` (because it is a zero-dependency library and `text` is not in `base`). This creates a gap where an auditor might flag every `String` use as a style violation.

3. **Generated code patterns**: 110 of the project's modules are generated. The guide does not discuss conventions for generated Haskell code (e.g., relaxed linting, pragma suppression, formatting exceptions).

4. **The `read` function**: `Internal.hs` uses `read` (a partial function the guide warns against) after validating with `isDigit`. The guide should discuss this validated-then-read pattern explicitly, since it is a common and justified exception to the "never use `read`" rule.

**Recommended addition:**

Add a section on project-specific conventions covering: why `String` is used over `Text`, FFI conventions, generated code policy, and when partial functions are acceptable after validation.

---

## Summary

The guide is well-structured and covers the major areas of Haskell style. Its best sections are on pattern matching, guards, explicit exports, and the error handling hierarchy. However, it suffers from three systematic problems:

1. **Scope mismatch**: It tries to be both a general Haskell style guide and a project-specific auditing tool, and does neither well. The advanced type system sections are irrelevant to the codebase, while project-specific patterns (FFI, `String` usage, generated code) are absent.

2. **Dependency blindness**: Multiple recommendations (`deepseq`, `ExceptT`, `mtl`, `transformers`, `text`) conflict with the project's zero-dependency constraint. The guide should be grounded in what the project can actually use.

3. **False absolutes**: Several guidelines are stated as rules when they are actually preferences (`StrictData` as Tier 1, no mixed `let`/`where`, abbreviation casing, `$` chaining). A style guide gains authority by being precise about what is a hard rule vs. a soft preference.

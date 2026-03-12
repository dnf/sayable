# Rebuttal: OCaml Style Guide Review

Senior Staff Engineer review of `docs/impl/ocaml/README.md`. Each section identifies a specific guideline, explains why it is problematic, and recommends an alternative.

---

## 1. Exceptions for Control Flow (Section 10)

**Quoted guideline:**

> Do not use exceptions as a general-purpose control flow mechanism. They are for genuinely exceptional situations:
>
> ```ocaml
> (* Bad: exception as early return *)
> exception Found of int
> let find_first_positive l =
>   try List.iter (fun x -> if x > 0 then raise (Found x)) l; None
>   with Found x -> Some x
> ```

**Why this is problematic:**

This is one of the most persistent myths imported from Java/C++ culture into OCaml guidance. In OCaml, exceptions are cheap -- they are not stack-unwinding operations that construct stack traces. An OCaml exception raise is essentially a `longjmp`: it sets a pointer and jumps. There is no stack trace allocation, no object construction, no heap pressure.

The OCaml standard library itself uses exceptions for control flow pervasively. `Hashtbl.find` raises `Not_found`. `Map.find` raises `Not_found`. `Seq.Forced_twice` is a control flow signal. The `Stdlib.exit` function raises an exception internally. The `Scanf` module uses exceptions for parse backtracking.

More importantly, exception-based early exit from a deep loop or recursive traversal is *idiomatic OCaml* and sometimes the clearest way to express intent. The `List.find_opt` alternative the guide offers is fine for this trivial example, but the blanket prohibition is wrong. Consider searching a tree:

```ocaml
exception Found of node
let find_in_tree pred root =
  let rec walk = function
    | Leaf -> ()
    | Node (l, v, r) ->
      if pred v then raise (Found v);
      walk l; walk r
  in
  try walk root; None
  with Found n -> Some n
```

The functional alternative requires threading an `option` through every recursive call and checking it at every level, which is both slower (no short-circuiting without continuations) and harder to read.

The guide should distinguish between *exceptions crossing API boundaries* (bad -- callers cannot see them in the type signature) and *exceptions as local control flow within a function body* (often the cleanest solution).

**Recommended alternative:**

Replace the blanket prohibition with nuanced guidance:
- Do not let exceptions escape public API boundaries. Use `option` or `result` at module interfaces.
- Within a function body, exceptions for early exit from loops or deep recursion are idiomatic and efficient. OCaml exceptions have near-zero cost compared to JVM/CLR exceptions.
- Always catch locally raised control-flow exceptions within the same function. If the `try`/`with` and the `raise` are in the same lexical scope, this is a pattern, not an anti-pattern.

---

## 2. Avoid `l` as a Variable Name (Section 1)

**Quoted guideline:**

> **Avoid confusing single characters.** Do not use `l` (lowercase L) as a variable name -- it is visually indistinct from `1`.

**Why this is problematic:**

This rule contradicts decades of OCaml convention and the OCaml standard library itself. The standard library uses `l` everywhere: `List.map f l`, `List.iter f l`, `List.fold_left f init l`. The official OCaml Programming Guidelines on ocaml.org use `l` for list parameters. Real World OCaml uses `l` for lists. Every OCaml tutorial uses `l` for lists.

The visual confusion argument is a font problem, not a naming problem. In any reasonable programming font (and every font used by developers who have configured their editor for OCaml), `l` and `1` are easily distinguishable. The OCaml syntax itself disambiguates them -- `l` appears in identifier position, `1` appears in literal position. The compiler catches any confusion at the type level.

Banning `l` and suggesting `xs` instead imports a Haskell convention that is foreign to OCaml. While `xs` is not wrong, telling reviewers to flag `l` as a defect will generate noise against perfectly idiomatic code.

**Recommended alternative:**

Note that `l` is conventional for list parameters in OCaml but acknowledge the visual similarity concern as a reason to prefer `xs` or a descriptive name when the context is ambiguous. Do not frame `l` as something to avoid.

---

## 3. Phantom Types Section is Misleading (Section 3)

**Quoted guideline:**

> Phantom types are fragile without GADTs because the compiler cannot enforce that constructors produce specific phantom parameters. Use GADTs when the invariant is safety-critical.

**Why this is problematic:**

This statement is technically correct but practically misleading. Phantom types are not "fragile" in the way this implies -- they are perfectly sound when used with abstract types and smart constructors behind a module boundary, which is the standard usage pattern. The compiler cannot enforce phantom parameters *at the definition site*, but the `.mli` file (which the guide correctly advocates elsewhere) is exactly the mechanism that makes phantom types safe.

```ocaml
(* .mli -- the abstraction boundary makes this safe *)
type _ handle
val open_readonly : string -> [`Read] handle
val open_readwrite : string -> [`ReadWrite] handle
val write : [`ReadWrite] handle -> string -> unit
```

The implementation can use `Obj.magic` or type coercions internally, but callers cannot construct a `[`ReadWrite`]` handle without going through `open_readwrite`. This is not fragile -- it is the standard OCaml abstraction mechanism.

Suggesting GADTs as the solution for "safety-critical" phantom types is disproportionate. GADTs add significant complexity (locally abstract types, restricted type inference, limited ppx support) and are justified only when you need the *return type* of pattern matching to vary by constructor. For simple capability tagging, phantom types behind an abstract interface are both simpler and sufficient.

**Recommended alternative:**

Rewrite to say: "Phantom types are safe when the type is abstract behind a module signature. The `.mli` file prevents callers from constructing values with incorrect phantom parameters. Use GADTs only when you need the type checker to refine types within pattern match branches -- phantom types cannot do that."

---

## 4. ocamlformat Version is Stale and Prescriptive (Section 2 and 11)

**Quoted guideline:**

> ```
> profile = default
> version = 0.28.1
> ```

**Why this is problematic:**

Pinning a specific version number in a style guide is a maintenance liability. The guide will become stale the moment a new ocamlformat version is released (0.28.1 is not the latest as of this review). Anyone following the guide literally will pin an old version.

More importantly, the guide repeats the `.ocamlformat` configuration block verbatim in two separate sections (Section 2 and Section 11), which violates the single-source-of-truth principle. When the version needs updating, both locations must be found and changed.

**Recommended alternative:**

State the principle ("pin the version in `.ocamlformat`") without hardcoding a specific version number. Reference the ocamlformat releases page for the current version. Remove the duplicate configuration block -- present it once.

---

## 5. While Loop Guidance Quotes an Unhelpful Aphorism (Section 8)

**Quoted guideline:**

> **While loops** are rarely needed. The official guidelines warn: "A while loop is usually wrong, unless its loop invariant has been explicitly written."

**Why this is problematic:**

The quoted aphorism from the official OCaml guidelines is about formal verification methodology, not practical coding advice. Telling developers that they need to "explicitly write a loop invariant" before using a while loop is impractical for most codebases and will be ignored.

The guide then shows a while-loop-based `string_contains` as "acceptable" and offers a recursive `find_index` on lists as "better when feasible." But these are not equivalent operations -- one searches strings, the other searches lists. The comparison is misleading.

Furthermore, the actual sayable-age OCaml implementation (`formatter.ml`) uses while loops in `string_replace` and `string_contains`, and these are the correct choice: they are imperative algorithms operating on mutable indices into strings, where a recursive solution would either require manual index threading (no clearer) or `String.to_seq` conversions (slower and more allocating).

**Recommended alternative:**

Replace the aphorism with practical guidance: "Prefer recursion or higher-order functions (`List.fold_left`, `Array.iter`, `Seq.iter`) for iteration over data structures. While loops are appropriate for imperative algorithms with mutable state, particularly when operating on arrays, buffers, or I/O channels where indexed access is natural."

---

## 6. The GADTs Section is Premature for an Auditing Guide (Section 3)

**Quoted guideline:**

The entire GADTs subsection, including the typed expression evaluator example and the "when to use/avoid" table.

**Why this is problematic:**

This is a style guide "intended for code auditing OCaml implementations" of a formatting library. GADTs are an advanced type system feature that the sayable-age codebase does not use and has no reason to use. Including a GADTs tutorial with a typed expression evaluator example is scope creep that dilutes the guide's utility as an auditing reference.

An auditor reading this guide needs to know: are the names right, are the patterns exhaustive, is mutable state justified, are exceptions handled properly? They do not need to know how to write a GADT-based expression evaluator. Including this material signals that the guide is trying to be a language tutorial rather than an auditing checklist.

The same criticism applies to the Phantom Types subsection and, to a lesser extent, the First-Class Modules subsection. These are all language features that are irrelevant to auditing a formatting library.

**Recommended alternative:**

Remove the GADTs, Phantom Types, and First-Class Modules subsections entirely. If advanced type system features are encountered during an audit, the reviewer can consult Real World OCaml or the OCaml manual. A style guide for auditing should cover what the codebase actually uses, not serve as a comprehensive language reference.

---

## 7. The `begin...end` vs Parentheses Advice is Overly Prescriptive (Section 2)

**Quoted guideline:**

> Use `begin ... end` rather than parentheses for delimiting multi-expression blocks, especially within match arms and if/then/else

**Why this is problematic:**

This is a matter of taste, not correctness. The OCaml community is genuinely split on `begin...end` vs parentheses. Jane Street's style (which the guide cites as an authority) uses parentheses, not `begin...end`. ocamlformat's default profile uses parentheses for most delimiters. The actual sayable-age implementation uses `begin...end` (in `formatter.ml` line 13-18), so the guide at least matches the codebase, but framing this as a universal rule is inaccurate.

**Recommended alternative:**

Present both styles as acceptable. Note that the project convention is `begin...end` (if that is the project's choice), but do not claim this is the OCaml community standard. If ocamlformat is being used (which the guide advocates), this decision is made by the formatter profile anyway and should not require manual enforcement.

---

## 8. The Fold Section's String Concatenation Example is an Anti-Pattern (Section 7)

**Quoted guideline:**

> ```ocaml
> (* Build a string *)
> let csv = List.fold_left
>   (fun acc s -> if acc = "" then s else acc ^ "," ^ s)
>   "" items
> ```

**Why this is problematic:**

This is a textbook O(n^2) string concatenation pattern. Each `^` allocates a new string and copies the entire accumulated result. For a list of n strings, this performs approximately n^2/2 character copies. This is the exact anti-pattern that `Buffer` exists to solve, and that `String.concat` handles directly:

```ocaml
let csv = String.concat "," items
```

Including this in a style guide as an example of how to use `fold_left` teaches a bad habit. A reader seeing this in a style guide will reasonably conclude it is an endorsed pattern.

**Recommended alternative:**

Replace the string-building fold example with `String.concat` (which is the correct solution) and use a different example for fold -- something where fold is actually the right tool, such as building a map or computing a running statistic.

---

## 9. The `of` Conversion Convention Section Hedges Without Guiding (Section 1)

**Quoted guideline:**

> **Use `of` for conversion functions** from one type to another: `string_of_int`, `float_of_string`. The newer Base convention reverses this: `Int.of_string`, `Float.to_string`.

**Why this is problematic:**

This presents two contradictory conventions without telling the reader which to follow. The stdlib convention (`string_of_int`) and the Jane Street/Base convention (`Int.of_string`) are both mentioned, but no recommendation is made. An auditor reading this has no basis for flagging one style vs. the other.

The two conventions also have different semantics: `string_of_int` reads as "string from int" (target_of_source), while `Int.of_string` reads as "Int from string" (also target_of_source, but scoped to the target module). They are actually consistent in meaning, just different in syntax. The guide does not explain this.

**Recommended alternative:**

Pick one convention for the project. Since this is a zero-dependency project that does not use Jane Street's Base library, the stdlib convention (`string_of_int`, `float_of_string`) is the natural choice. State that the project follows stdlib naming conventions, and note that codebases using Base/Core will follow `Module.of_type`/`Module.to_type` instead.

---

## 10. Missing Guidance on `Scanf` vs Manual Parsing (Section 9 / General)

**Why this is problematic:**

The guide has no guidance on string parsing, which is one of the most common operations in the sayable-age codebase. The actual implementation (`internal.ml`) does manual character-by-character date parsing with index arithmetic and `String.sub`. This is a reasonable choice for a zero-dependency library, but the guide should acknowledge this pattern and explain why `Scanf.sscanf` (which is in the stdlib and therefore not an external dependency) was not used and when manual parsing is preferred.

**Recommended alternative:**

Add a brief note in the idioms section about string parsing: `Scanf.sscanf` is available in the stdlib for structured parsing, but manual parsing with `String.sub` and index arithmetic gives better control over error handling and avoids `Scanf`'s exception-based failure mode. For date/time parsing, manual extraction is standard practice.

---

## 11. The Quick Reference Checklist Includes Items Not Relevant to This Project (Section: Quick Reference)

**Quoted guideline (selected items):**

> - [ ] Labeled arguments used for functions with multiple same-type parameters
> - [ ] Optional arguments placed before mandatory ones
> - [ ] `Fun.protect` or equivalent used for resource cleanup

**Why this is problematic:**

The actual sayable-age OCaml implementation does not use labeled arguments, optional arguments in the labeled sense (it uses `option` types as regular parameters), or `Fun.protect`. The checklist includes items that are good general OCaml practice but that an auditor will never encounter in this codebase. Including them creates busywork -- the auditor checks for labeled arguments, finds none, and wonders if that is a deficiency.

Meanwhile, the checklist is missing items that are directly relevant:
- Are all 217 test cases from `tests.json` implemented with correct test ID annotations?
- Are generated locale files untouched (no manual edits)?
- Does the implementation handle the edge cases in the spec (empty string DOB, future birth dates, age > 6000 months)?

**Recommended alternative:**

Split the checklist into "General OCaml quality" and "Sayable-age specific." Move the labeled arguments, optional arguments, and resource cleanup items into the general section (or remove them). Add project-specific audit items that reflect what an auditor actually needs to verify.

---

## 12. The `list_length` Anti-Pattern Example is Not Tail-Recursive Either (Section 10)

**Quoted guideline:**

> ```ocaml
> (* Good: functional *)
> let rec list_length = function
>   | [] -> 0
>   | _ :: l -> 1 + list_length l
> ```

**Why this is problematic:**

The "good" example is not tail-recursive. It will stack-overflow on long lists. The imperative version it replaces, while ugly, at least does not have this problem. Presenting a non-tail-recursive function as the correct alternative to an imperative loop is misleading, especially in a style guide that is supposed to teach best practices.

The tail-recursive version is:

```ocaml
let list_length l =
  let rec aux acc = function
    | [] -> acc
    | _ :: tl -> aux (acc + 1) tl
  in
  aux 0 l
```

Or simply `List.length l`, which is the actual correct answer.

**Recommended alternative:**

Either use `List.length` as the "good" example (reinforcing the "use library functions" principle from Section 7) or show the tail-recursive accumulator version. Do not present a non-tail-recursive function as exemplary code in a style guide.

---

## 13. Missing Guidance on `Unix` Module Usage

**Why this is problematic:**

The actual implementation (`internal.ml`) uses `Unix.gettimeofday` and `Unix.gmtime`, which means the library has a dependency on the `unix` library (a stdlib companion, but a separate compilation unit that must be linked). The guide says nothing about when `Unix` module usage is acceptable, how to minimize it, or that it is the one "dependency" this zero-dependency library allows.

The dune file for the library presumably includes `(libraries unix)`. An auditor following the "zero runtime dependencies" checklist item might flag this.

**Recommended alternative:**

Add a note clarifying that `unix` is part of the OCaml distribution (not an opam package) and is acceptable for system clock access. Note that the `today()` function is the only callsite and is isolated in `internal.ml` so that the pure formatting logic in `formatter.ml` is testable without mocking time.

---

## Summary

The guide is well-structured and covers most important OCaml conventions correctly. The main categories of issues are:

1. **Imported myths from other language ecosystems** (exceptions-as-control-flow prohibition)
2. **Scope creep** (GADTs, phantom types, first-class modules in an auditing guide for a formatting library)
3. **Incorrect examples** (O(n^2) string concatenation, non-tail-recursive list_length)
4. **Missing project-specific guidance** (string parsing patterns, Unix module usage, test spec compliance)
5. **Stale or duplicated specifics** (hardcoded ocamlformat version, repeated config blocks)

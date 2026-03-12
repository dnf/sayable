# Rebuttal: Ada Style Guide

Reviewed by a Senior Staff Engineer. This document covers specific disagreements
with the Ada Style Guide at `docs/impl/ada/README.md`, along with analysis and
recommended changes.

---

## 1. Section 1.8 -- "Do not use `I` as a loop variable"

**Quoted guideline:**

> Do not use `I` as a loop variable (too easily confused with `1`). Use `J` or
> a descriptive name.

**Analysis:**

This recommendation originates from the GNAT compiler source coding style,
where it is a reasonable convention for a specific codebase. Elevating it to a
project-wide ban is overly dogmatic. `I` is the most universally understood loop
variable name across virtually all programming languages. The confusion with `1`
is a font problem, not a naming problem -- any modern editor or terminal renders
them distinctly. Furthermore, recommending `J` as a replacement is bizarre: if
`I` is confusable with `1`, then `J` is arguably confusable with `]` or `}` in
certain fonts, and it also breaks the universally understood convention without
improving clarity.

The actual GNAT Coding Style guide uses this convention for internal GNAT
development. This project is not the GNAT compiler.

The right advice is: use descriptive names when the loop body is long or the
iteration is non-obvious. For short loops iterating over a simple range, `I` is
fine and universally understood.

**Recommendation:**

Replace with: "For short, simple loops, `I` is acceptable. For loops with
longer bodies or where the iteration semantics are non-obvious, prefer a
descriptive name (e.g., `Col`, `Month_Idx`). Avoid `O` as a variable name
(genuinely confusable with `0`)."

---

## 2. Section 2.15 -- Subprogram Body Box Comment Headers

**Quoted guideline:**

> Each subprogram body should be preceded by a box comment:
>
> ```ada
> -------------------
> -- Is_Leap_Year --
> -------------------
> ```

**Analysis:**

This is a GNAT compiler convention that the GNAT team uses because they work on
an extremely large, decades-old codebase where navigating to subprogram
boundaries in a text editor was historically difficult. For a modern project
where every developer has an IDE or LSP with go-to-definition, these box
comments are pure visual noise and a maintenance burden. Every time you rename a
function, you have to update the box comment and recount the dashes. They add no
semantic information -- the function declaration on the very next line already
tells you the name.

The actual codebase (`sayableage.adb`) does not use these box comments, which
confirms they are not practical for this project.

**Recommendation:**

Remove this guideline entirely. Replace with: "Separate subprogram bodies with
blank lines. If a subprogram body benefits from explanatory context beyond what
the spec provides, add a comment explaining *why* the implementation takes the
approach it does -- not a box repeating the function name."

---

## 3. Section 2.15 -- "Sort subprogram bodies alphabetically"

**Quoted guideline:**

> Sort subprogram bodies alphabetically within a package body.

**Analysis:**

This is another GNAT-internal convention that does not transfer well to library
code. In the actual codebase, the subprograms in `sayableage.adb` are ordered by
dependency (helpers first, then the functions that call them) and by logical
grouping (parsing functions together, formatting functions together). This
*dependency order* is natural and readable -- you read top-to-bottom and each
function only calls things already defined above it.

Alphabetical ordering would scatter related functions and force readers to jump
around. It also conflicts with Ada's one-pass compilation model: if you
alphabetize bodies in a package body that uses forward declarations, you add
unnecessary forward declarations. If you are not using forward declarations,
alphabetical order may not even compile.

The `-gnatyo` style check flag enforces this, but the guide already notes this
flag is not in the default `-gnatyy` set -- with good reason.

**Recommendation:**

Replace with: "Order subprogram bodies by logical grouping: helper subprograms
before the subprograms that call them. Within a group, keep related functions
together. This makes top-to-bottom reading natural and minimizes the need for
forward declarations."

---

## 4. Section 2.6 -- Comment Spacing Rules are Internally Contradictory

**Quoted guideline:**

> A comment starts with `--` followed by **two spaces** [...]
> One space after `--` is acceptable only for end-of-line comments after code

**Analysis:**

This two-space rule comes from the GNAT Coding Style guide and is enforced by
`-gnatyc`. But look at section 2.6's own "additional comment rules":

> Mark dubious or incomplete comments with `???`.

Following the two-space rule, this would be `--  ???`. That is fine. But the
guide presents both `-gnatyc` (two spaces) and `-gnatyC` (one space) as options
in section 10.1 without clearly stating which one the project should use. The
guide should pick one and commit to it.

More importantly, the guide says end-of-line comments use one space, which means
the project needs `-gnatyC` (one space) rather than `-gnatyc` (two spaces) if
it wants the compiler to accept both forms. Or it should use `-gnatyc` and
require two spaces everywhere. This ambiguity should be resolved.

**Recommendation:**

Pick one convention and state it clearly. Since the GNAT convention (two spaces
for standalone, one space for end-of-line) is the most established and the
`-gnatyc` flag only checks standalone comments, state: "Standalone comments use
two spaces after `--`. End-of-line comments use one space after `--`. Enable
`-gnatyc` to enforce standalone comment spacing."

---

## 5. Section 3.1 -- "Compiler error: cannot mix Meters and Seconds" example

**Quoted guideline and example:**

> ```ada
> type Meters is new Float;
> type Seconds is new Float;
>
> --  Compiler error: cannot mix Meters and Seconds
> Distance : Meters  := 100.0;
> Duration : Seconds := 9.58;
> Speed    : Float   := Float (Distance) / Float (Duration);  --  explicit
> ```

**Analysis:**

The comment says "Compiler error: cannot mix Meters and Seconds" but then
immediately shows code that compiles fine by converting both to `Float`. The
comment is misleading -- it implies the last line would fail, but it would not.
The comment should be on a hypothetical line like `Speed := Distance / Duration`
which *would* fail.

Also, using `Duration` as a variable name shadows the predefined type
`Ada.Calendar.Duration`. Section 1.8 says "Do not declare local entities that
shadow global ones" -- so the example contradicts the guide's own rule.

**Recommendation:**

Fix the example so the comment about the compiler error applies to a line that
actually produces a compiler error. Rename the `Duration` variable to
`Elapsed` or `Time_Span` to avoid shadowing.

---

## 6. Section 3.7 -- Private Type Hierarchy is Misleading

**Quoted guideline:**

> The hierarchy of preference:
> 1. **Limited private** -- most restrictive; no assignment or equality
> 2. **Private** -- assignment and equality are available; implementation hidden
> 3. **Nonprivate** -- implementation exposed

**Analysis:**

Presenting this as a ranked preference list implies you should always reach for
limited private types first, then reluctantly fall back to private, then
nonprivate as a last resort. This is bad advice for a formatting library. The
types in this project (`Locale`, `Unit_Forms`, `Parse_Result`) are all
value-semantic data carriers. Making them limited private would make them
impossible to assign, which would make the entire locale system unworkable
-- you could not write `Day_UF := Loc.Units.Day`.

The right advice is: choose the abstraction level that matches the type's
semantics. Data-carrier types should be nonprivate records. Types with
invariants or resource semantics should be private or limited private. This is
not a hierarchy -- it is a design decision based on the type's role.

**Recommendation:**

Reframe as a decision guide rather than a ranked preference: "Choose the
visibility that matches the type's semantics. Use nonprivate records for
simple data carriers (like `Parse_Result`). Use private types when you need
to enforce invariants or hide representation. Use limited private types for
resource-owning types that should not be copied (handles, connections)."

---

## 7. Section 3.8 -- `not null` Access Contradicts Section 8.10

**Quoted guideline (3.8):**

> Prefer `not null` access subtypes when a null value is never valid:
> ```ada
> type Plural_Fn is not null access function ...
> ```

**Quoted guideline (8.10):**

> ```ada
> type Plural_Fn is access function (N : Natural) return Plural_Category;
>
> type Locale is record
>    Plural : Plural_Fn := null;
>    ...
> end record;
> ```

**Analysis:**

Section 3.8 says to prefer `not null` access and uses `Plural_Fn` as the
example. Section 8.10 defines `Plural_Fn` *without* `not null` and initializes
it to `null`. These two sections directly contradict each other.

The actual codebase (`sayableage_types.ads`) uses the nullable version, which
is correct -- locales are built incrementally and the plural function pointer
starts as null before being assigned during locale initialization.

**Recommendation:**

Remove the `Plural_Fn` example from section 3.8 or change it to a type where
`not null` is genuinely appropriate. Keep the nullable `Plural_Fn` in section
8.10 since it matches the codebase and is the correct design choice.

---

## 8. Section 4.5 -- "Minimize use clauses" is Impractical as Stated

**Quoted guideline:**

> Minimize `use` clauses. They obscure the origin of names and make maintenance
> harder. Prefer qualified names or package renames.

**Analysis:**

The guide recommends minimizing `use` clauses but the actual codebase opens with:

```ada
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
```

And this is exactly right. Writing
`Ada.Strings.Unbounded.To_Unbounded_String(...)` or even `ASU.To_Unbounded_String(...)`
dozens of times in a file that does heavy string manipulation would be unreadable
noise. The guide even acknowledges this in the same section: "When `use` clauses
are necessary (e.g., for `Unbounded_String` operations that appear
frequently)..."

The guideline contradicts itself by first saying "minimize" and then saying
"when necessary, go ahead." The practical advice should lead with the real
rule: use `use` clauses when not using them would obscure the actual logic
with qualification noise. Avoid them when the origin of a name matters for
understanding.

**Recommendation:**

Rewrite to lead with the practical principle: "Use `use` clauses for packages
whose operations appear frequently in the current scope (e.g.,
`Ada.Strings.Unbounded`). Prefer qualified names or renames for packages used
only a few times, or when the package origin is important for understanding the
code. Avoid `use` clauses in package specifications, as they affect all clients."

---

## 9. Section 6 -- Concurrency Section is Entirely Irrelevant

**Quoted guideline:**

> Ada has first-class concurrency support. While the sayable-age library does not
> use tasking (it is a pure computation library), these guidelines apply to Ada
> code in general.

**Analysis:**

A project-specific style guide should cover the patterns actually used in the
project. This section is 80 lines of content about tasks, protected objects,
`delay until`, and rendezvous -- none of which apply to a pure formatting
library. The section itself admits this in its opening sentence.

Including irrelevant material dilutes the guide. A reader looking for
project-relevant conventions has to wade through material that the guide itself
says does not apply. If someone needs concurrency guidance, the Ada Quality and
Style Guide and the ARM are the right references -- not a formatting library's
style guide.

**Recommendation:**

Remove the concurrency section entirely. Add a one-line note in the references
section: "For concurrency patterns, see the Ada Quality and Style Guide,
Chapter 6."

---

## 10. Section 7 -- Memory Management is Mostly Irrelevant

**Quoted guideline (sections 7.1-7.5):**

The guide covers stack vs. heap allocation, pool-specific vs. general access
types, `Unchecked_Deallocation`, controlled types (RAII), and `Storage_Error`
handling.

**Analysis:**

The actual codebase uses no dynamic memory allocation, no access types for data
(only `access function` for plural rule callbacks), no `Unchecked_Deallocation`,
no controlled types, and no `Storage_Error` handling. The `Unbounded_String`
usage is the only indirect heap allocation, and it is managed by the standard
library.

Like the concurrency section, this material is a generic Ada tutorial that does
not reflect the project's actual patterns. Sections 7.3-7.5 are particularly
irrelevant -- they cover patterns that would be actively wrong to introduce into
this codebase.

**Recommendation:**

Reduce to a brief section: "Prefer stack allocation and value semantics. This
library uses `Unbounded_String` for variable-length text and `access function`
types for plural rule callbacks. Avoid introducing dynamic allocation or
`Unchecked_Deallocation` -- they are unnecessary for this project's scope. For
general Ada memory management guidance, see the Ada Quality and Style Guide."

---

## 11. Missing Topic -- Ada 2012+ Standard and Compiler Version

**Analysis:**

The guide references Ada 2012 features (expression functions, contracts,
predicates, type invariants) but never states which Ada standard the project
targets or which GNAT version is required. This is a significant omission for a
multi-language project where different contributors may have different GNAT
versions installed.

**Recommendation:**

Add a section near the top stating the target Ada standard (Ada 2012 or Ada
2022) and the minimum GNAT version required. This informs contributors which
language features are available and prevents accidental use of features from a
newer standard.

---

## 12. Missing Topic -- Unbounded_String vs. Fixed String Guidance

**Analysis:**

The codebase makes heavy use of `Unbounded_String` for locale data and
intermediate results, but the guide only has a brief mention in section 8.8.
Given that string handling is the core of this library, there should be clear
guidance on when to use `String` (fixed), `Unbounded_String`, and
`Bounded_String`, and how to minimize unnecessary conversions between them.

**Recommendation:**

Add a subsection to the Common Idioms section covering string type choice for
this project: use `String` for function parameters and return values (the public
API), `Unbounded_String` for mutable state and locale data storage, and avoid
`Bounded_String` (it adds complexity with no benefit here).

---

## 13. Section 9.5 -- Blanket Ban on Subunits is Too Absolute

**Quoted guideline:**

> Avoid subunits (`separate`). With child packages available since Ada 95, there
> is almost never a reason to use subunits.

**Analysis:**

While I agree that child packages are usually preferable, the blanket "avoid"
is slightly too strong. Subunits have a legitimate use case: when a single
package body has one or two subprograms that are much larger than the rest, and
you want to keep the main body file readable without creating a new package.
This is uncommon but not pathological. The guide should say "prefer child
packages over subunits" rather than "avoid subunits."

This is a minor point. The advice is directionally correct.

**Recommendation:**

Soften to: "Prefer child packages over subunits. Subunits (`separate`) create
maintenance problems and confuse dependency tracking. Child packages provide
the same decomposition benefits with better tooling support."

---

## Summary

The guide is well-structured and covers important ground. The core Ada advice
(strong typing, named aggregates, short-circuit evaluation, minimize use clauses
in specs) is sound. The main problems are:

1. **Borrowed conventions applied uncritically**: Several guidelines (box
   comments, alphabetical body ordering, banning `I` as a loop variable) are
   GNAT compiler conventions that do not transfer well to application code.
2. **Internal contradictions**: The `not null` access advice contradicts the
   access-to-subprogram example. The `Duration` variable shadows a predefined
   type in a section that bans shadowing.
3. **Irrelevant material**: The concurrency and memory management sections are
   generic Ada tutorials with no connection to the project.
4. **Missing project-specific guidance**: No Ada standard version, no string
   type decision guide, no connection to the actual codebase patterns.

# Elm Style Guide -- Senior Staff Engineer Rebuttal

Reviewer: Senior Staff Engineer
Date: 2026-03-11
Document under review: `docs/impl/elm/README.md`

## Overall Assessment

This is a well-structured, well-sourced guide that covers the major concerns of Elm development. The examples are drawn from the actual codebase (sayable-age) which grounds the advice in reality rather than toy examples. The guide correctly identifies elm-format as non-negotiable, correctly emphasizes "making impossible states impossible," and provides good coverage of the type system.

That said, I have several points of disagreement ranging from factual errors to overly dogmatic recommendations to missing guidance. Below are my objections, in order of severity.

---

## Disagreement 1: The `\_ ->` over `always` recommendation is wrong

### Guideline quoted

> **Prefer `\_ ->` over `always` for discarding arguments:**
> ```elm
> -- Good
> Maybe.map (\_ -> ()) value
>
> -- Avoid
> Maybe.map (always ()) value
> ```

And later repeated under "Things to Avoid":

> **Using `always` Instead of `\_ ->`**
> The anonymous function `\_ ->` is more recognizable and easier to refactor than `always`:

### Analysis

This recommendation is stated twice (Section 5 and Section 10) and is wrong on both counts.

First, `always` is a named function in `Basics` that the Elm core team deliberately put there. It exists because it is the idiomatic way to produce a constant function. `always ()` reads as English: "always unit." `\_ -> ()` reads as syntactic noise.

Second, the claim that `\_ ->` is "easier to refactor" is unsupported and backwards. `always value` is a point-free expression that composes cleanly: you can pass `always ()` to higher-order functions without wrapping it in another lambda. If you later need to change the constant, you change one argument. With `\_ -> ()`, refactoring to accept the argument requires restructuring the lambda.

Third, this contradicts community norms. The Elm core library, the Elm guide, and most prominent Elm codebases (including NoRedInk's) use `always` freely. Banning it confuses newcomers who encounter it everywhere in real Elm code.

The guide should recommend `always` for constant functions and `\_ ->` for cases where you are discarding a specific argument that has contextual meaning (e.g., in an event handler where the argument is an event you do not need).

### Recommendation

Remove both occurrences of this advice. Replace with:

> Use `always value` when producing a constant function. Use `\_ -> expr` when discarding a specific argument where the discard is the important semantic point (e.g., an unused event parameter). Both are idiomatic; choose whichever reads more naturally in context.

---

## Disagreement 2: The `Expect.equal` argument order is stated incorrectly

### Guideline quoted

> Use `Expect.equal expected actual` (expected value first).

### Analysis

This is factually wrong about Elm's `Expect.equal`. The function signature is:

```elm
Expect.equal : a -> a -> Expectation
```

The elm-test documentation does not prescribe an "expected, actual" ordering the way JUnit does. More importantly, looking at the actual test file in this codebase:

```elm
Expect.equal Nothing (fmt "" "2025-06-15")
Expect.equal (Just "newborn") (fmt "2025-06-15" "2025-06-15")
```

The first argument is the expected value and the second is the actual -- which happens to match the guide's claim. However, this ordering is not mandated by the library. Elm's `Expect.equal` is symmetric: `Expect.equal a b` produces the same pass/fail result as `Expect.equal b a`. The error messages may differ slightly in which value is labeled "expected" vs "actual," but the elm-test library's diff output labels the first argument as the expected value only by convention, not by API contract.

The real issue is that the guide states this as if it were an API requirement ("expected value first") without acknowledging that it is a team convention. It should be framed as a convention for consistent error messages, not as a correctness requirement.

### Recommendation

Rewrite as:

> By convention, pass the expected value as the first argument to `Expect.equal` and the actual (computed) value as the second. This is not enforced by the API, but it produces clearer failure messages since elm-test labels the first argument in its diff output.

---

## Disagreement 3: The line length recommendation of 80 characters is unrealistic and contradicts elm-format

### Guideline quoted

> Keep lines under **80 characters**. Longer lines often indicate the code should be broken up. Locale data lines may exceed this, which is acceptable.

### Analysis

elm-format does not enforce an 80-character line limit. It will happily produce lines longer than 80 characters for record literals, long function applications, long strings, and various other constructs. Since the guide itself says "elm-format Is Canonical" and "Never argue about formatting," recommending a line length that elm-format does not enforce creates an internal contradiction.

If elm-format produces a line of 95 characters, what should the developer do? The guide says both "never argue about formatting" and "keep lines under 80 characters." These two rules conflict.

The 80-character convention comes from terminal limitations that are largely irrelevant today. Most developers use editors with soft-wrapping or wide terminals. The Elm community generally does not enforce a hard line limit beyond what elm-format produces.

### Recommendation

Remove the hard 80-character recommendation. Replace with:

> Let elm-format handle line length. If a line feels too long after formatting, it is usually a sign that the expression should be extracted into a named binding or helper function -- not that the line needs manual wrapping.

---

## Disagreement 4: The import organization recommendation (grouping by exposing style) is unusual and under-justified

### Guideline quoted

> Group imports in this order:
> 1. Non-exposing imports (qualified only)
> 2. Imports with explicit exposing lists
> 3. Wildcard imports (avoid these)

### Analysis

elm-format already sorts imports alphabetically by module name. It does not group them by exposing style. The guide's recommendation to group by exposing style would require developers to fight elm-format (adding blank lines between groups to prevent resorting) or accept that elm-format will reorder their carefully grouped imports.

Looking at the actual codebase, the test file imports are:

```elm
import Expect
import SayableAge.Formatter exposing (formatAge, formatStage)
import SayableAge.Locales exposing (getLocale)
import SayableAge.Locales.Am as Am
...
import SayableAge.Types exposing (..)
import Test exposing (..)
```

These are sorted alphabetically by module name, not grouped by exposing style. The guide's recommendation does not match the project's own code.

### Recommendation

Replace with:

> Sort imports alphabetically by module name. elm-format enforces this automatically. Do not try to group imports manually -- elm-format will undo it.

---

## Disagreement 5: The single-step pipeline prohibition is overly dogmatic

### Guideline quoted

> **Do not use a single-step pipeline.** If there is only one transformation, call the function directly:
> ```elm
> -- Good
> List.map toUpper names
>
> -- Bad: unnecessary pipeline
> names |> List.map toUpper
> ```

### Analysis

As a blanket rule, this is too strict. There are legitimate cases where a single-step pipeline improves readability:

1. When the data argument is a long or complex expression that benefits from appearing first for scannability.
2. When a single-step pipeline is being left in place because additional steps are likely to be added soon (common during development).
3. When the data argument naturally reads left-to-right and the pipeline emphasizes the subject-verb flow.

For example:

```elm
-- The pipeline makes the "subject" (the long expression) prominent
computeComplexResult model.settings model.data
    |> Maybe.withDefault fallback
```

vs.

```elm
-- Burying the long expression inside the function call
Maybe.withDefault fallback (computeComplexResult model.settings model.data)
```

The guide is right that `names |> List.map toUpper` is worse than `List.map toUpper names` for trivial cases. But making it an absolute rule ignores the cases where the pipeline genuinely helps.

### Recommendation

Soften to:

> Avoid single-step pipelines when the direct function call reads just as well. For simple cases like `names |> List.map toUpper`, prefer `List.map toUpper names`. However, a single-step pipeline is acceptable when the input expression is long or complex and benefits from appearing first.

---

## Disagreement 6: The phantom types section is misleading

### Guideline quoted

```elm
type Unit a
    = Unit String

type Meters
    = Meters

type Seconds
    = Seconds
```

> The compiler will reject: `combine distance duration` because `Unit Meters /= Unit Seconds`

### Analysis

The example declares `Meters` and `Seconds` as custom types with constructors, but those constructors are never used as values anywhere. The phantom types `Meters` and `Seconds` only appear as type parameters -- their constructors (`Meters` the value and `Seconds` the value) serve no purpose and could confuse readers into thinking they are used somewhere.

A cleaner pattern, common in the Elm community, is to use types with no constructors (sometimes called "never-constructed" types). Since Elm does not support empty custom types, the convention is to either accept the unused constructor or use a type alias to `Never` -- but the simplest approach is just to note that the constructors exist but are unused by design.

More importantly, the claim "The compiler will reject: combine distance duration" is incomplete. It depends entirely on the type signature of `combine`. If `combine : Unit a -> Unit a -> Unit a`, then yes, the compiler rejects it. But the example never shows `combine`, leaving the reader to guess how the type safety actually works. A style guide example should be self-contained enough to demonstrate its claim.

### Recommendation

Either remove the phantom types section (it is an advanced topic unlikely to appear in a formatting library's style guide) or make the example self-contained by showing the function signature that creates the type constraint. Add a note that the constructors of the phantom type tags exist but are intentionally unused.

---

## Disagreement 7: Missing guidance on `Debug` usage

### Analysis

The guide has no mention of `Debug.log`, `Debug.todo`, or `Debug.toString`. These are important to address because:

- `Debug.log` is extremely common during development but must never be committed.
- `Debug.todo` is useful for stub-driven development but is a runtime crash waiting to happen.
- Elm 0.19 prevents publishing packages with `Debug` calls, but application code has no such guard.

An elm-review rule (`NoDebug.Log`, `NoDebug.TodoOrToString`) can catch these, but the guide does not mention it even though it lists elm-review rules.

### Recommendation

Add a brief section under "Things to Avoid":

> Never commit `Debug.log`, `Debug.todo`, or `Debug.toString` calls. Use the `NoDebug.Log` and `NoDebug.TodoOrToString` elm-review rules to catch these in CI.

---

## Disagreement 8: Missing guidance on `elm.json` for packages vs. applications

### Guideline quoted

> `elm.json` is the project manifest. Key points:
> - List only direct dependencies, not transitive ones (Elm manages those automatically).
> - Keep `source-directories` minimal, typically just `["src"]`.
> - The `elm-version` field constrains which compiler versions can build the project.

### Analysis

The guidance about "list only direct dependencies" is misleading. In Elm application projects (which this project is, per the `elm.json` showing `"type": "application"`), `elm.json` lists *both* direct and indirect dependencies -- and both sections are managed by `elm install`. The developer does not manually curate the indirect list, but it is present in the file and committed to version control. Telling developers to "list only direct dependencies" could be confusing because they will see the `indirect` section and wonder if they should remove it.

The guide also does not mention the important distinction between `application` and `package` project types, which have materially different `elm.json` schemas (applications pin exact versions; packages specify version ranges).

### Recommendation

Rewrite the `elm.json` section to acknowledge the application vs. package distinction and clarify that `indirect` dependencies in application `elm.json` files are auto-managed and should not be manually edited.

---

## Disagreement 9: The "body on same line as =" bad example is misleading

### Guideline quoted

```elm
-- Bad: body on same line as =
homeDirectory : String
homeDirectory = "/root/files"
```

### Analysis

elm-format will automatically reformat this to put the body on the next line. Since the guide declares elm-format as canonical and non-negotiable, calling this out as a "bad" pattern implies it is something a developer might actually commit, which is impossible if elm-format is run on save as the guide requires.

Listing things that elm-format already prevents as "bad" patterns creates noise. The guide should focus on decisions that elm-format does *not* make for you -- those are the areas where human judgment matters.

### Recommendation

Remove formatting examples that elm-format already enforces. Add a note:

> Many formatting decisions (indentation, body placement, blank lines between declarations) are handled automatically by elm-format. The formatting rules described here document what elm-format does, for reference, not rules you need to manually enforce.

---

## Disagreement 10: The "two blank lines between declarations" rule is stated as a manual rule but is an elm-format behavior

### Guideline quoted

> Separate top-level declarations with **two blank lines**.

### Analysis

This is another case where the guide presents an elm-format behavior as if it were a manual rule. elm-format enforces two blank lines between top-level declarations. Stating it as a prescriptive rule suggests developers need to think about it, when in fact they do not.

### Recommendation

Roll this into the elm-format section as descriptive documentation of what elm-format does, not as a separate rule.

---

## Items I Agree With

The following guidelines are well-reasoned and should be kept as-is:

- **elm-format as canonical** -- Correct and non-negotiable.
- **Explicit exposing lists** -- Correct for production code. The reasoning is sound.
- **Qualified imports** -- Good default. The advice about meaningful aliases vs. cryptic ones is spot-on.
- **Making impossible states impossible** -- The cornerstone of Elm data modeling, well-explained with a good example.
- **Custom types over booleans and strings** -- Solid advice with clear examples drawn from the actual domain.
- **Opaque types** -- Well-explained with a correct, complete example.
- **Pattern matching guidance** -- Exhaustive matching advice is correct and important.
- **Error handling with Maybe/Result** -- Clear, well-structured, with good progression from simple to advanced.
- **andThen chaining** -- The nested-case vs. andThen comparison is compelling.
- **Pipeline design** -- The data-last convention is correctly stated and well-motivated.
- **Let binding guidance** -- Practical and well-calibrated.
- **Premature abstraction warnings** -- The "seen it twice" heuristic is appropriate.
- **Test structure** -- Good examples that match the actual codebase.
- **elm-review rule recommendations** -- Well-curated list of high-value rules.
- **Record formatting with leading commas** -- Correctly motivated by clean diffs.
- **Module organization by domain concept** -- Correct advice against the Model/Update/View split.
- **Wrapper types for identifiers** -- Good advice, well-motivated.
- **Extensible records** -- Correct that they should be used for narrowing arguments, not data modeling.

# Elixir Style Guide -- Senior Staff Engineer Rebuttal

Reviewer: Senior Staff Engineer
Date: 2026-03-11

## Overall Assessment

The guide is well-structured, comprehensive, and largely accurate. It correctly covers the key areas of Elixir style and successfully synthesizes the official Elixir documentation, the community style guide, and Credo's recommendations. The examples are relevant to the sayable-age project, which adds practical value.

That said, there are several points where the guide is misleading, internally contradictory, overly dogmatic, or missing important nuance. Below are my specific disagreements, ordered by section.

---

## Disagreement 1: Acronym Casing in Module Names

**Guideline as written:**

> Use `CamelCase`. Preserve uppercase for acronyms.
>
> ```elixir
> # Good
> defmodule MyApp.HTTPClient do
> defmodule MyApp.XMLParser do
> ```

**Analysis:**

This is outdated advice that contradicts the Elixir core team's own evolution on the topic. While Elixir allows fully-uppercased acronyms in module names, the community has been moving toward treating acronyms as regular CamelCase words for readability --- `HttpClient` rather than `HTTPClient`. The Elixir standard library itself is inconsistent (it has `URI` but also `GenServer`, not `GENServer`), and Phoenix, the most prominent Elixir framework, uses `Phoenix.HTML` in some places but `Jason` (not `JSON`), `Ecto` (not `ECTO`).

More importantly, marking `MyApp.HttpClient` as "Bad" is actively harmful. It discourages a perfectly reasonable and increasingly common convention. The real "bad" example is `MyApp.Xml_Parser` (which mixes styles), but that is conflated with the debatable acronym casing.

**Recommendation:**

Present both styles as acceptable. Call out the `Xml_Parser` mixed-style as the actual anti-pattern. Note the community is split on acronym treatment and recommend picking one convention per project and sticking with it.

---

## Disagreement 2: Blanket Ban on Single Pipes

**Guideline as written (Section 2, repeated in Section 7):**

> ```elixir
> # Bad -- single pipe (just use a function call)
> date_of_birth |> Date.diff(as_of)
> ```

**Analysis:**

The blanket "single pipe is always bad" rule is too dogmatic. There are legitimate cases where a single pipe improves readability, particularly when the piped value is the result of a complex expression, or when the pipe visually emphasizes a transformation step that would be buried as a nested argument:

```elixir
# The pipe makes the "what" and the "transformation" visually distinct
calculate_complex_value(a, b, c) |> format_output()
```

The community style guide recommends against single pipes as a general guideline, not an absolute rule. The reasoning is about chains that *only* have one step --- it is not about forbidding every single pipe.

**Recommendation:**

Soften to "Avoid single pipes when the expression reads clearly as a direct function call. Single pipes can be acceptable when they improve clarity by separating computation from transformation."

---

## Disagreement 3: The `do_name` Private Function Ban

**Guideline as written:**

> Do not name private functions `do_<public_name>`. Use a more descriptive name that communicates the function's distinct purpose.
>
> ```elixir
> # Bad
> def format(data), do: do_format(data, [])
> defp do_format(data, acc), do: ...
>
> # Good
> def format(data), do: build_output(data, [])
> defp build_output(data, acc), do: ...
> ```

**Analysis:**

This is well-intentioned but overly prescriptive. The `do_` prefix is a deeply entrenched Elixir idiom for the specific pattern of a public function that delegates to a private recursive or accumulator-based implementation. The Elixir standard library itself uses this pattern. Credo does flag it, but as a low-priority readability suggestion, not a hard rule.

The example given is misleading. `build_output` is not obviously better than `do_format` because both are private --- the caller never sees either name. The `do_` convention actually communicates something useful: "this is the recursive/accumulator guts of the public function above." Replacing it with an arbitrary verb does not inherently improve clarity and can sometimes obscure the relationship between the public and private function.

Where `do_` truly becomes problematic is when the private function does something conceptually different from the public one. But in the accumulator pattern, the `do_` prefix is idiomatic and widely understood.

**Recommendation:**

Soften to: "Prefer descriptive names for private functions when the private function does something conceptually distinct from the public one. The `do_` prefix is acceptable for the standard accumulator/recursion delegation pattern but should not be used as a catch-all for 'private version of public function.'"

---

## Disagreement 4: Missing Guidance on `@spec` for Private Functions

**Guideline as written:**

> Write a `@spec` for every public function.

**Analysis:**

The guide says to spec every public function but says nothing about private functions. This is a meaningful omission. In the actual codebase (`formatter.ex`), none of the private functions have specs, and several have complex type signatures (e.g., `resolve_locale/2` returns a 7-tuple). For a project with 29 implementations that must produce identical output, the type signatures of internal functions matter for correctness verification.

Dialyzer will infer types for private functions, but explicit specs on non-trivial private functions help reviewers and future maintainers. The guide should take a position.

**Recommendation:**

Add guidance: "Consider `@spec` annotations on private functions when the function has a non-obvious type signature, especially for functions that return complex data structures like tuples with many elements."

---

## Disagreement 5: The 300-Line Module Limit

**Guideline as written:**

> If a module exceeds ~300 lines, consider extracting logically distinct sections into separate modules.

**Analysis:**

The ~300 line limit is reasonable as a rule of thumb but overly simplistic for this project's context. The Sayable Age formatter (`formatter.ex`) is 185 lines and does five distinct things: tier dispatch, locale resolution, stage labels, date computation, and date parsing. By function count and responsibility, it could arguably be split. But the test file (`sayable_age_test.exs`) is ~967 lines and is entirely coherent -- splitting it would reduce readability.

A line count threshold without discussion of cohesion can lead to premature extraction, creating a scattered codebase where understanding requires jumping between many small files. The guide should emphasize cohesion over line count.

**Recommendation:**

Reframe: "Evaluate module size by cohesion, not line count. If a module handles multiple unrelated responsibilities, extract them regardless of length. A long module that addresses a single concern (like a comprehensive test file) is preferable to multiple small modules that fragment a logical unit. Use ~300 lines as a prompt to evaluate, not as a hard limit."

---

## Disagreement 6: Missing Guidance on Module Attribute Constants vs. Module-Level Functions

**Analysis:**

The guide discusses module attributes (`@default_locale :en`, `@max_age`) in the module structure section, but never discusses when to use a module attribute vs. a zero-arity function for exposing constants. The actual codebase uses `@version "0.5.0"` as an attribute and then exposes it via `def version, do: @version`. The guide should explain when to inline attributes vs. expose them, and when a constant belongs as a module attribute vs. computed at compile time.

**Recommendation:**

Add a subsection in Module Design or Common Idioms explaining: module attributes are compiled into the bytecode at every call site (they are not runtime references). This matters for values that might change between releases. For constants that are truly constant, module attributes are fine. For version strings or configuration values that callers need, expose them via a function.

---

## Disagreement 7: Uppercase Sigil Escape Behavior Example Is Incorrect

**Guideline as written:**

> ```elixir
> ~s(hello #{name})    # => "hello world"  (interpolated)
> ~S(hello #{name})    # => "hello \#{name}"  (literal)
> ```

**Analysis:**

The second example is misleading. `~S(hello #{name})` does not produce `"hello \#{name}"` with a literal backslash. It produces the string `hello #{name}` --- the `#` and braces are preserved literally, but there is no backslash in the output. The backslash in the comment implies escaping that does not actually happen. This could confuse someone testing in `iex`.

**Recommendation:**

Correct the example:

```elixir
~s(hello #{name})    # => "hello world"  (interpolated)
~S(hello #{name})    # => "hello #{name}"  (literal, no interpolation)
```

---

## Disagreement 8: Missing Guidance on Binary Pattern Matching

**Analysis:**

The actual codebase uses binary pattern matching extensively in `parse_date/1`:

```elixir
<<y::binary-size(4), ?-, m::binary-size(2), ?-, d::binary-size(2), _rest::binary>> <- s
```

This is a critical Elixir feature for a project that handles string parsing, yet the Pattern Matching section mentions only tuples, lists, maps, and structs. Binary/bitstring pattern matching is fundamental to Elixir and should be covered, especially given this project's actual usage.

**Recommendation:**

Add a subsection on binary pattern matching under Section 3 (Pattern Matching), covering `<<>>` syntax, size specifiers, and its use for string parsing.

---

## Disagreement 9: Credo Configuration Example Sets `strict: false` Without Discussion

**Guideline as written:**

The Credo configuration example sets `strict: false` without explaining why or what the implications are.

**Analysis:**

For a project that mandates "zero warnings in CI" (per CLAUDE.md), showing a Credo configuration with `strict: false` sends a mixed signal. The guide should explain the difference between normal and strict mode and recommend a setting consistent with the project's quality stance.

**Recommendation:**

Add a note: "For projects that enforce zero warnings in CI, consider running Credo in `--strict` mode to catch low-priority issues. Set `strict: true` in the configuration or pass `--strict` on the command line."

---

## Disagreement 10: The `assert` Pattern Match Explanation Is Incomplete

**Guideline as written:**

> ```elixir
> # Pattern matching (note: pattern on the left)
> assert {:ok, _value} = some_function()
> ```

**Analysis:**

This uses `=` (match operator) inside `assert`, which is correct but subtly different from `==` (equality). The guide does not explain why this uses `=` instead of `==`, or what happens when the match fails. With `assert {:ok, _value} = some_function()`, a match failure produces a detailed error showing the actual value. With `assert {:ok, _value} == some_function()`, you would get a compile error because `_value` is unbound on the left of `==`.

This is a common source of confusion for Elixir learners and warrants explicit explanation.

**Recommendation:**

Add a brief note: "Use `=` (match) in assert when you want to destructure the result and verify its shape. Use `==` (equality) when comparing concrete values. The match form produces clear error messages showing the actual value when the pattern does not match."

---

## Items I Agree With

The following sections are solid and well-presented:

- **Naming conventions** (Sections 1, except the acronym point above): Thorough and accurate.
- **mix format as non-negotiable** (Section 2): Correct and appropriately strong.
- **Pattern matching in function heads over branching** (Section 3): Excellent advice, well-illustrated.
- **Module structure ordering** (Section 4): The 8-step ordering is the established community convention and is correctly documented.
- **ok/error tuple conventions** (Section 6): Well-explained with clear examples.
- **with statement guidance** (Sections 3 and 6): Good coverage of both the happy-path-only and else-clause forms.
- **Enum vs. Stream** (Section 7): Clear criteria for choosing between them.
- **Testing section** (Section 8): Comprehensive and accurate coverage of ExUnit.
- **unless with else** (Section 10): Correctly identified as an anti-pattern.
- **Tooling section** (Section 11): Good overview of the essential Elixir toolchain.
- **Source references** (Sources): Excellent -- linking to official documentation adds credibility and enables verification.

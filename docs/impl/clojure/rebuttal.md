# Clojure Style Guide -- Senior Staff Engineer Rebuttal

This document covers points of disagreement with the Clojure style guide at
`docs/impl/clojure/README.md`. Each item includes the quoted guideline, analysis
of the problem, and a recommended alternative.

Overall assessment: this is a well-written guide that covers the important ground.
Most of the advice is sound. The issues below range from technically incorrect to
subtly misleading to missing important context. None are devastating, but several
could lead engineers astray if taken at face value.

---

## 1. Acronyms in types: "Keep acronyms uppercase: `HTTPClient`, `XMLParser`, `JSONCodec`"

**Quoted guideline (Section 1, Types/protocols/records):**
> Keep acronyms uppercase: `HTTPClient`, `XMLParser`, `JSONCodec`.

**Analysis:** This is the Java convention and is not the Clojure community norm.
The Clojure Style Guide by Batsov -- which this document cites as its primary
reference -- explicitly recommends treating acronyms as words in CamelCase:
`HttpClient`, `XmlParser`, `JsonCodec`. Rich Hickey's own code and the Clojure
contrib ecosystem follow this pattern (e.g., `clojure.data.json` uses `JsonReader`
style naming internally). All-caps acronyms create ambiguous word boundaries in
compound names: is `HTTPSServer` "HTTPS-Server" or "HTTP-SServer"?

**Recommendation:** Change to: "Treat acronyms as words in CamelCase:
`HttpClient`, `XmlParser`, `JsonCodec`." This matches Batsov's guide, Go's
convention, and avoids the word-boundary ambiguity.

---

## 2. `count` for emptiness checks: "traverses the entire collection"

**Quoted guideline (Section 10):**
> ```clojure
> ;; bad -- traverses the entire collection
> (if (> (count coll) 0) ...)
> (if (= (count coll) 0) ...)
> ```

**Analysis:** The comment "traverses the entire collection" is misleading for
most Clojure data structures. Clojure's persistent vectors, maps, sets, and lists
all implement `ICounted`, which means `count` is O(1), not O(n). The only case
where `count` is O(n) is on lazy sequences, and that matters not because of
traversal cost but because it forces realization of the entire lazy sequence
(which may be infinite or side-effecting). The guide's comment implies `count` is
always expensive, which is wrong and could confuse engineers into thinking
Clojure's data structures have poor performance characteristics.

`(seq coll)` is still preferred for emptiness checks, but for a different reason:
it is more idiomatic and works uniformly across all collection types including
lazy sequences. The correctness reason (not forcing lazy realization) is more
important than the performance reason.

**Recommendation:** Replace the comment with: "bad -- forces full realization of
lazy sequences; use seq for a uniform, idiomatic emptiness check" and add a note
that `count` is O(1) for Clojure's persistent data structures but O(n) for lazy
sequences.

---

## 3. `(person :name)` marked as "bad"

**Quoted guideline (Section 4, keywords as functions):**
> ```clojure
> ;; bad -- verbose
> (person :name)  ; works but unconventional for maps
> ```

**Analysis:** Calling `(person :name)` is not "bad" -- it is a legitimate and
sometimes useful pattern. When `person` might be `nil`, `(:name person)` returns
`nil`, while `(person :name)` throws a `NullPointerException`. In code where you
want to fail fast on nil maps rather than silently propagating nil values
downstream, `(map-value key)` is a deliberate choice. Labeling it "bad" is
overly prescriptive. More importantly, calling a map as a function is a
first-class Clojure feature, not a code smell.

The comment "works but unconventional for maps" is also slightly misleading.
`(:name person)` is preferred in most cases because keywords-as-functions
compose better with higher-order functions (e.g., `(map :name people)` vs
`(map #(% :name) people)`), but calling the map as a function is perfectly
conventional in certain contexts.

**Recommendation:** Change the label from "bad" to "less common" and explain the
trade-off: "Less common -- (:keyword map) is preferred because keywords compose
as lookup functions, but (map key) is valid and useful when you want nil maps to
fail fast."

---

## 4. Vertical alignment in `let` bindings presented as preferred style

**Quoted guideline (Section 2, vertical alignment):**
> Align `let` bindings and map key-value pairs vertically.
> ```clojure
> ;; good
> (let [name   (:name person)
>       age    (:age person)
>       locale (:locale person)]
>   ...)
> ```

**Analysis:** Presenting column-aligned `let` bindings as "good" (with the
non-aligned version as merely "acceptable") is a reasonable aesthetic preference,
but it creates a real maintenance burden. When one binding name changes length,
you have to re-pad every line. This is error-prone in manual editing, and
`cljfmt` -- the formatter the guide recommends three sections later -- does not
produce this alignment by default. So the guide's recommended style and the
guide's recommended tooling are in tension.

Additionally, the actual codebase in `age/impl/clojure/` uses a mix of both
styles, which suggests the team has not consistently adopted this preference.

**Recommendation:** Swap the labels: present the non-aligned form as "good"
(since it matches what `cljfmt` produces) and the column-aligned form as
"acceptable when it improves readability in static data definitions." This
eliminates the tension with the tooling section.

---

## 5. `comp` composition example has reversed operation order

**Quoted guideline (Section 3):**
> ```clojure
> (def process (comp str/trim str/lower-case))
> (process "  HELLO  ")  ;=> "hello"
> ```

**Analysis:** This is subtly wrong. `comp` applies functions right-to-left, so
`(comp str/trim str/lower-case)` first lowercases, then trims. The result is
"hello" and happens to be correct for this particular input. But the "also good"
alternative shown immediately below uses threading, which applies left-to-right:
`(-> s str/lower-case str/trim)` -- lowercase then trim, which is the same
effective order. So the output matches by coincidence.

However, if you had an input like `"  HELLO  "`, both `trim-then-lowercase` and
`lowercase-then-trim` yield `"hello"`, which masks the fact that the `comp` and
threading versions apply operations in the same effective order only because
`comp` is right-to-left. An engineer reading the `comp` line naturally reads left
to right and might think `trim` runs first, which would be wrong. The example
does not illustrate the right-to-left behavior clearly enough and risks teaching
the wrong mental model.

**Recommendation:** Either reorder to `(comp str/lower-case str/trim)` to make
the reading order match execution order (trim first, then lowercase), or add a
comment explicitly noting the right-to-left application: `; reads right-to-left:
lower-case first, then trim`.

---

## 6. Missing guidance on `defn-` limitations

**Quoted guideline (Section 1, Private functions and vars):**
> ```clojure
> ;; good
> (defn- helper-fn [x] ...)
> (def ^:private internal-state ...)
> ```

**Analysis:** The guide recommends `defn-` for private functions without
mentioning that `defn-` provides only advisory privacy -- it can be bypassed with
`@#'namespace/private-fn` or `(var namespace/private-fn)`. This is a meaningful
distinction for a team that might rely on `defn-` as an access control mechanism.
Engineers coming from Java/C# backgrounds may assume `defn-` provides the same
level of enforcement as `private`, and they should know it does not.

More importantly, the guide does not mention that `defn-` functions cannot be
tested directly from test namespaces without the `#'` escape hatch. This matters
for the testing section's guidance about test structure.

**Recommendation:** Add a brief note: "`defn-` is advisory -- it can be bypassed
via `#'ns/fn`. It serves as documentation of intent, not enforcement. For
testing private functions, access them via the var: `(#'sut/helper-fn arg)`."

---

## 7. Transducers section overpromises on lazy sequence behavior

**Quoted guideline (Section 4, Transducers):**
> ```clojure
> ;; lazy sequences -- creates intermediate collections
> (->> data
>      (filter valid?)
>      (map transform)
>      (take 10))
> ```

**Analysis:** The comment "creates intermediate collections" is misleading. Lazy
sequences in Clojure do not eagerly create full intermediate collections. Each
`map`/`filter` call returns a lazy sequence that computes elements on demand. The
actual overhead of chained lazy sequences is per-element wrapper allocation (each
step wraps the previous lazy seq), not materialized intermediate collections. For
the example shown (which includes `(take 10)`), only 10 elements flow through
the pipeline regardless of `data`'s size.

The transducer advantage is real -- fewer intermediate lazy seq objects, one pass,
better cache locality -- but the guide overstates the problem with lazy sequences
to make the case. Engineers reading this may develop an incorrect mental model of
how lazy evaluation works in Clojure.

**Recommendation:** Change the comment to: "lazy sequences -- allocates
intermediate lazy seq wrappers per step" and in the prose, clarify that lazy
sequences do not materialize full intermediate collections. The transducer
advantage is reduced allocation overhead and a single traversal pass, not
avoiding phantom intermediate collections.

---

## 8. `:else` clause advice is too prescriptive

**Quoted guideline (Section 9, `cond`):**
> Always include an `:else` clause (or document why it is intentionally omitted).

**Analysis:** This is overly prescriptive. In Clojure, a `cond` without `:else`
returns `nil` when no branch matches. This is a well-defined, intentional
behavior that is foundational to Clojure's nil-punning philosophy. Requiring
`:else` everywhere (or a comment justifying its absence) adds noise. For many
functions, returning `nil` on no match is exactly the right behavior and does not
need documentation.

The actual codebase demonstrates this: `formatter.clj` has `cond` expressions
with `:else` for the formatting tier (where a default is meaningful), but also
has `when-let` chains that rely on `nil` returns without comment.

**Recommendation:** Soften to: "Include an `:else` clause when the function
should always return a meaningful value. When `nil` is the correct result for
unmatched cases, `:else` is unnecessary."

---

## 9. Missing: no guidance on `require` vs `import` order consistency

**Quoted guideline (Section 5):**
> The conventional order is: docstring, `:require`, `:import`. Sort entries
> alphabetically within each clause.

**Analysis:** The guide says to sort alphabetically but does not address a common
inconsistency: should the sort be case-sensitive or case-insensitive? Should
`clojure.` namespaces come before project namespaces, or is it strictly
alphabetical? The Clojure Style Guide (Batsov) recommends grouping: `clojure.*`
first, then third-party, then project-internal, with alphabetical order within
each group. This project's actual code in `core_test.clj` does
`clojure.test` first then `sayableage.*` (which happens to be alphabetical
anyway), but the guide should be explicit about whether grouping is expected.

**Recommendation:** Add: "Within `:require`, group namespaces: `clojure.*` and
`clojure.java.*` first, then third-party libraries, then project namespaces.
Sort alphabetically within each group."

---

## 10. `with-open` example uses `doall` without explaining why

**Quoted guideline (Section 6, `with-open`):**
> ```clojure
> (with-open [rdr (io/reader "data.csv")]
>   (doall (line-seq rdr)))
> ```

**Analysis:** The `doall` call is critical here and the guide does not explain
why. Without `doall`, `line-seq` returns a lazy sequence. When `with-open`
closes the reader at the end of its body, the lazy sequence still holds a
reference to the now-closed reader. Any attempt to realize elements after
`with-open` exits will throw an `IOException`. This is one of the most common
Clojure pitfalls for intermediate developers. The guide shows the correct code
but misses the teaching moment.

**Recommendation:** Add a comment or note: "`doall` forces full realization
inside the `with-open` scope. Without it, the lazy `line-seq` would reference a
closed reader, throwing on later realization."

---

## 11. `clojure.pprint` alias should be `pprint`, not `pp`

**Quoted guideline (Section 5, standard aliases):**
> | `clojure.pprint` | `pp` |

**Analysis:** The community-standard alias for `clojure.pprint` is `pprint`, not
`pp`. Batsov's guide lists `pprint`. The `pp` alias is ambiguous -- `pp` is also
the name of a function in `clojure.pprint` (`clojure.pprint/pp`), which pretty-
prints the last REPL result. Using `pp` as the namespace alias would create
confusion: does `pp/pprint` mean "the pprint function in the pp-aliased
namespace" or is someone calling a function named `pprint` on something called
`pp`? Aliasing `clojure.pprint` as `pprint` avoids this ambiguity.

**Recommendation:** Change to `pprint`.

---

## 12. Missing: no mention of `clojure.spec` or schema validation

**Analysis:** The guide covers testing, error handling, and data structures, but
says nothing about `clojure.spec.alpha` (or its successor `clojure.spec2`),
`malli`, or any form of runtime schema validation. For a project with 110 locale
data structures that must conform to a specific shape, this is a notable gap.
Spec or Malli could validate locale maps at development time, generate test data,
and produce better error messages than `:pre` conditions.

The guide does mention `clojure.spec.alpha` in the standard aliases table (with
alias `s`), which implies the team is at least aware of it, but there is no
guidance on when or how to use it.

**Recommendation:** Add a subsection under "Data Structures" or "Error Handling"
with brief guidance: when to use spec for data validation (at boundaries, for
complex map shapes), when `malli` might be preferred (schema-as-data, better
error messages), and when `:pre`/`:post` conditions are sufficient (simple type
checks).

---

## 13. `as->` example uses Java interop unnecessarily

**Quoted guideline (Section 2, threading macros):**
> ```clojure
> (as-> [:foo :bar] v
>   (map name v)
>   (first v)
>   (.substring v 1))
> ```

**Analysis:** The example uses `.substring` (Java interop) when `subs` (the
Clojure wrapper) would be more idiomatic. The guide itself says in Section 7:
"Prefer Clojure wrappers when available... Use `clojure.string` over `String`
methods." This is an internal contradiction. The `as->` example should follow
the guide's own advice.

Additionally, `as->` is often a sign that the pipeline should be restructured.
The threading section should note that if you reach for `as->`, consider whether
the pipeline is doing too many different things and should be broken into named
`let` bindings instead.

**Recommendation:** Change `.substring` to `subs` in the example to be internally
consistent. Add a note: "If you find yourself reaching for `as->`, consider
whether named `let` bindings would be clearer."

---

## 14. Missing: no guidance on `lazy-seq` and chunking behavior

**Analysis:** The guide covers transducers and lazy sequences but says nothing
about chunking. Clojure's lazy sequences are chunked by default (chunks of 32
elements), which means `(first (map side-effect! huge-collection))` will execute
`side-effect!` 32 times, not once. This surprises many engineers and is relevant
to the guide's advice about isolating side effects. At minimum, a note in the
transducers section or the "things to avoid" section would help.

**Recommendation:** Add a brief note under the transducers section or "things to
avoid": "Be aware that lazy sequences are chunked (32 elements at a time).
`(first (map f coll))` may evaluate `f` on 32 elements, not one. When this
matters, use transducers or `sequence` with a transducer."

---

## 15. `format` example uses `%d` for what might not be an integer

**Quoted guideline (Section 9, `str` for string building):**
> ```clojure
> ;; good for complex formatting
> (format "%d%s%s%s" quantity half delimiter unit)
> ```

**Analysis:** Using `%d` for `quantity` assumes it is always an integer. In
Clojure, division and other operations can produce ratios (`3/2`) or doubles
(`3.5`). If `quantity` is ever a non-integer, `%d` will throw
`IllegalFormatConversionException`. The actual codebase uses `str` and string
replacement (`str/replace`), not `format`, which avoids this issue. A style guide
example should not introduce a latent type error.

**Recommendation:** Change to `(format "%s%s%s%s" quantity half delimiter unit)`
or remove the `format` example entirely since `str` is cleaner for this
concatenation pattern and the guide already shows it as the primary approach.

---

## Summary of agreed-upon guidelines

The following sections are well-written and accurate. They reflect genuine
Clojure community conventions and do not require changes:

- Naming conventions (except acronyms): `lisp-case`, predicates with `?`, side
  effects with `!`, `->` for conversions, `*earmuffs*`, `_` for unused bindings
- Trailing parentheses: gathering closing delimiters is fundamental Lisp style
- `seq` for emptiness, sets as predicates, `mapcat` over `apply concat`
- Threading macro guidance (except the `as->` example)
- Destructuring section: thorough and correct
- `if-let`/`when-let` guidance
- Multimethods vs. protocols decision framework
- Avoid `def` inside functions, avoid `require` outside `ns`
- Avoid unnecessary mutation, avoid macros when functions work
- `clj-kondo` and `cljfmt` tooling recommendations
- REPL-driven development section
- `use-fixtures` guidance: pragmatic and correct
- `are` for tabular tests

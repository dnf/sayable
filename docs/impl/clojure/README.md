# Clojure Style Guide

A comprehensive guide to idiomatic Clojure style for code auditing. Based on the
[Clojure Style Guide](https://guide.clojure.style/), the
[official Clojure guides](https://clojure.org/guides/getting_started), and
established community conventions.

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Functional Programming Patterns](#3-functional-programming-patterns)
4. [Data Structures](#4-data-structures)
5. [Namespace Design](#5-namespace-design)
6. [Error Handling](#6-error-handling)
7. [Java Interop](#7-java-interop)
8. [Testing](#8-testing)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)

---

## 1. Naming Conventions

### General rule: `lisp-case` everywhere

Functions, local bindings, vars, and namespace segments all use lowercase words
separated by hyphens.

```clojure
;; good
(def max-retries 3)
(defn calculate-age [date-of-birth as-of] ...)

;; bad
(def maxRetries 3)        ; camelCase (Java habit)
(defn calculateAge ...)   ; camelCase
(def MAX_RETRIES 3)       ; SCREAMING_SNAKE (Java/Python habit)
```

### Namespaces

Use `project.module` or `organization.project.module` patterns. Composite
segments use `lisp-case`.

```clojure
;; good
(ns sayableage.formatter)
(ns sayableage.locales.en)
(ns acme.web-server.middleware)

;; bad
(ns formatter)              ; single-segment -- risk of collisions
(ns sayableage.Formatter)   ; CapitalCase segment
(ns acme.webServer.auth)    ; camelCase segment
```

Avoid single-segment namespaces (they risk collisions). Keep namespaces to five
segments or fewer.

### Predicates end with `?`

A function returning a boolean ends with a question mark.

```clojure
;; good
(defn palindrome? [s] ...)
(defn adult? [age] (>= age 18))

;; bad
(defn is-palindrome [s] ...)   ; Java-style "is" prefix
(defn palindrome-p [s] ...)    ; Common Lisp style
```

### Side-effecting functions end with `!`

Functions that mutate state, perform I/O, or are unsafe in transactions signal
this with a trailing bang.

```clojure
;; good
(defn save-user! [user] (db/insert! user))
(defn reset-counter! [] (reset! counter 0))

;; bad -- missing warning about side effects
(defn save-user [user] (db/insert! user))
```

### Conversion functions use `->`

Use `->` instead of `to` for type-conversion names.

```clojure
;; good
(defn f->c [fahrenheit] ...)
(defn map->vec [m] ...)
(defn days->weeks [days] ...)

;; less idiomatic
(defn f-to-c [fahrenheit] ...)
```

### Dynamic vars wear `*earmuffs*`

Vars intended for rebinding via `binding` are surrounded by asterisks.

```clojure
;; good
(def ^:dynamic *locale* :en)

;; bad
(def ^:dynamic locale :en)
```

### Constants have no special notation

Everything in Clojure is constant by default unless explicitly marked dynamic.
Do not use `SCREAMING_CASE` or `+plus-signs+`.

```clojure
;; good
(def max-size 10)
(def default-locale :en)

;; bad
(def MAX-SIZE 10)       ; Java convention
(def +max-size+ 10)     ; Common Lisp convention
```

### Types, protocols, records: `CamelCase`

```clojure
;; good
(defprotocol Serializable ...)
(defrecord HttpRequest [method url headers body])
(deftype AgeLocale [units half-marker delimiter just-born stages])

;; bad
(defprotocol serializable ...)
(defrecord http-request ...)
```

Treat acronyms as words: `HttpClient`, `XmlParser`, `JsonCodec`. All-caps
acronyms create ambiguous word boundaries (is `HTTPSServer` "HTTPS-Server" or
"HTTP-SServer"?).

### Private functions and vars

Mark non-public API explicitly. Note that `defn-` is advisory -- it can be
bypassed via `#'ns/fn`. It serves as documentation of intent, not enforcement.
To test private functions from test namespaces, use `(#'sut/helper-fn arg)`.

```clojure
;; good
(defn- helper-fn [x] ...)
(def ^:private internal-state ...)

;; bad -- accidentally public
(defn helper-fn [x] ...)
```

### Unused bindings: `_`

Use `_` for bindings whose values will be ignored. Prefix with `_` when the
name aids readability.

```clojure
;; good
(let [[a _ c] [1 2 3]]
  (+ a c))

(dotimes [_ 3]
  (println "hello"))

;; good -- named for clarity, prefixed to suppress warnings
(defn handle-event [_context event]
  (process event))
```

### Idiomatic parameter names

Follow the conventions established in `clojure.core`:

| Parameter | Meaning               |
| --------- | --------------------- |
| `f`, `g`  | Function arguments    |
| `n`       | Integer size/count    |
| `x`, `y`  | Numeric values        |
| `xs`      | Sequence              |
| `s`       | String                |
| `coll`    | Collection            |
| `m`       | Map                   |
| `k`, `ks` | Key(s)                |
| `v`, `vs` | Value(s)              |
| `pred`    | Predicate function    |
| `xf`      | Transducer            |
| `re`      | Regular expression    |
| `expr`    | Expression (macros)   |
| `body`    | Macro body forms      |
| `this`    | Protocol method target|

---

## 2. Code Formatting

### Indentation

Use **spaces only**, never hard tabs. Use **2 spaces** to indent body forms
(`def`, `defn`, `let`, `loop`, `when`, `cond`, `if`, `do`, `fn`, `doseq`,
etc.).

```clojure
;; good -- 2-space body indent
(defn format-age
  [date-of-birth as-of locale]
  (let [days (days-between date-of-birth as-of)]
    (when (pos? days)
      (select-stage locale days))))

;; bad -- 4-space indent
(defn format-age
    [date-of-birth as-of locale]
    (let [days (days-between date-of-birth as-of)]
        (select-stage locale days)))
```

### Vertical alignment

Align function arguments that span multiple lines beneath the first argument.

```clojure
;; good -- arguments aligned
(format "%s %s%s"
        quantity
        unit
        suffix)

;; good -- single-space indent when nothing on first line
(format
  "%s %s%s"
  quantity
  unit
  suffix)

;; bad -- ragged alignment
(format "%s %s%s"
  quantity
  unit
  suffix)
```

For `let` bindings, standard single-space separation is the default. Column
alignment is acceptable when it improves readability in static data definitions,
but note that `cljfmt` does not produce column alignment by default.

```clojure
;; good -- standard spacing (matches cljfmt output)
(let [name (:name person)
      age (:age person)
      locale (:locale person)]
  (format-greeting name age locale))

;; acceptable -- column-aligned for readability
(let [name   (:name person)
      age    (:age person)
      locale (:locale person)]
  (format-greeting name age locale))
```

### Line length

Keep lines under **80 characters** where feasible. Teams may agree on 100-120,
but never exceed 120. Locale data files with long string literals are an
expected exception.

### Trailing parentheses

Gather closing delimiters on a single line. Never put closing parentheses on
their own lines (the "Java braces" anti-pattern).

```clojure
;; good
(when (valid? input)
  (process input)
  (save! input))

;; bad -- dangling parens
(when (valid? input)
  (process input)
  (save! input)
  )
)
```

### Blank lines

One blank line between top-level forms. No blank lines within a function body
(except to separate logical groups in `let`/`cond` bindings). Related `def`s
may be grouped without blank lines.

```clojure
(def default-locale :en)
(def default-delimiter " ")

(defn first-fn []
  ...)

(defn second-fn []
  ...)
```

### Commas

Commas are whitespace in Clojure. Do not use them in vectors or lists. In maps,
commas are optional and can aid readability on long single-line maps.

```clojure
;; good
[1 2 3 4 5]
{:name "Bruce" :age 30}

;; acceptable in compact maps
{:name "Bruce", :age 30, :city "Gotham"}

;; bad
[1, 2, 3, 4, 5]
```

### Threading macros

Use `->` (thread-first) for map/object operations and `->>` (thread-last) for
sequence pipelines.

```clojure
;; good -- thread-first for maps and object transforms
(-> person
    (assoc :hair-color :gray)
    (update :age inc))

;; good -- thread-last for sequences
(->> (range 1 10)
     (filter odd?)
     (map #(* % %))
     (reduce +))

;; bad -- deeply nested equivalent
(reduce + (map #(* % %) (filter odd? (range 1 10))))
```

Use `as->` when the threaded value must appear in varying argument positions.
If you find yourself reaching for `as->`, consider whether named `let` bindings
would be clearer.

```clojure
(as-> [:foo :bar] v
  (map name v)
  (first v)
  (subs v 1))
```

Use `some->` and `some->>` to short-circuit on `nil`.

```clojure
;; safe navigation -- returns nil if any step produces nil
(some-> config :database :host .trim)
```

Use `cond->` and `cond->>` for conditional pipeline steps.

```clojure
(cond-> base-map
  (some? name)  (assoc :name name)
  (pos? age)    (assoc :age age)
  use-defaults? (merge defaults))
```

### Anonymous functions

Use `#()` for short, single-expression anonymous functions. Use `fn` for
anything longer or multi-expression.

```clojure
;; good -- short
(map #(* % 2) [1 2 3])
(filter #(> (:age %) 18) users)

;; good -- too complex for #(), use fn
(map (fn [{:keys [first-name last-name]}]
       (str last-name ", " first-name))
     users)

;; bad -- nested #() is illegal and confusing
(map #(map #(* % 2) %) matrix)
```

Do not nest `#()` forms -- it is a reader error. Use named `fn` forms instead.

---

## 3. Functional Programming Patterns

### Prefer pure functions

The default should be pure functions: same inputs produce same outputs, no side
effects. Isolate side effects at the edges (entry points, I/O boundaries).

```clojure
;; good -- pure: computes a value from inputs
(defn select-unit [locale days]
  (->> (:stages locale)
       (filter #(<= (:min-days %) days))
       last
       :unit))

;; bad -- impure hidden inside pure logic
(defn select-unit [locale days]
  (println "Selecting unit for" days "days")  ; side effect!
  (->> (:stages locale) ...))
```

### Use higher-order functions over manual recursion

Prefer `map`, `filter`, `reduce`, `keep`, `some`, `every?`, `group-by`,
`sort-by`, and friends over explicit `loop`/`recur`.

```clojure
;; good
(map inc [1 2 3 4 5])
(filter even? (range 20))
(reduce + [1 2 3 4 5])

;; bad -- manual loop for a map operation
(loop [xs [1 2 3 4 5]
       result []]
  (if (empty? xs)
    result
    (recur (rest xs) (conj result (inc (first xs))))))
```

### Use `comp` and `partial` for point-free composition

`comp` applies functions right-to-left: the rightmost function runs first.

```clojure
;; good -- reads right-to-left: lower-case first, then trim
(def process (comp str/trim str/lower-case))
(process "  HELLO  ")  ;=> "hello"

;; acceptable -- explicit fn is fine when clearer
(defn process [s]
  (-> s str/lower-case str/trim))

;; good
(def positive-even? (every-pred pos? even?))
(def stringify-keys (partial map name))
```

### Prefer `reduce` with an explicit accumulator

```clojure
;; good -- explicit initial value
(reduce + 0 [1 2 3 4 5])

;; acceptable -- clojure.core handles empty case
(reduce + [1 2 3 4 5])

;; good -- building a result
(reduce (fn [acc x] (assoc acc x (* x x)))
        {}
        [1 2 3 4 5])
```

### Use `juxt` for parallel computation over the same input

```clojure
;; Extract multiple values at once
((juxt :name :age :city) person)
;=> ["Bruce" 30 "Gotham"]
```

### Closures for encapsulated state

When a function needs internal state, use closures over atoms rather than
top-level mutable state.

```clojure
;; good -- encapsulated
(defn make-counter []
  (let [n (atom 0)]
    (fn [] (swap! n inc))))

;; bad -- exposed global state
(def counter (atom 0))
(defn next-count [] (swap! counter inc))
```

---

## 4. Data Structures

### Prefer keywords as map keys

Keywords are interned (fast equality), self-evaluating, and double as lookup
functions.

```clojure
;; good
{:name "Bruce" :age 30}
(:name person)  ;=> "Bruce"

;; bad -- strings as keys
{"name" "Bruce" "age" 30}
(get person "name")
```

### Use keywords as functions for map lookup

```clojure
;; good -- keyword as function (composes well with map, filter, etc.)
(:name person)
(:age person 0)  ; with default

;; acceptable -- when key might not be a keyword
(get person :name)
(get-in nested [:address :city])

;; less common -- map as function
;; valid and useful when you want nil maps to fail fast rather than silently
;; propagating nil, but (:keyword map) is preferred in most contexts because
;; keywords compose as lookup functions (e.g., (map :name people))
(person :name)
```

### Maps vs. records

Use plain maps for most data. Reach for `defrecord` only when you need protocol
implementation or measurable performance gains from field access.

```clojure
;; good for most cases -- plain map
(def locale {:code "en" :just-born "just born" :delimiter " "})

;; justified when implementing a protocol
(defrecord AgeLocale [code units half-marker delimiter just-born stages]
  Formattable
  (format-age [this days] ...))
```

Records have fixed-field lookup performance and implement `IPersistentMap`, but
they introduce type rigidity. Plain maps are more flexible and compose better with
generic functions.

### Vectors over lists for data

Vectors provide O(1) indexed access and `conj` at the end. Reserve lists for
code forms.

```clojure
;; good -- vector for data
[1 2 3 4 5]
[:year :month :week :day]

;; bad -- list for data (O(n) indexed access)
'(1 2 3 4 5)
```

### Use `seq` for emptiness checks

```clojure
;; good -- nil-punning
(when (seq coll)
  (process coll))

;; bad -- double negative
(when-not (empty? coll)
  (process coll))
```

### Use sets as predicates

```clojure
;; good
(filter #{:admin :moderator} user-roles)
(#{:year :month :week :day} unit)

;; less idiomatic
(filter #(or (= % :admin) (= % :moderator)) user-roles)
```

### Transducers for performance-critical pipelines

When chaining multiple sequence transformations, transducers eliminate
intermediate lazy sequence wrapper allocation and process elements in a single
pass.

```clojure
;; lazy sequences -- allocates intermediate lazy seq wrappers per step
(->> data
     (filter valid?)
     (map transform)
     (take 10))

;; transducers -- single pass, no intermediate wrappers
(into []
      (comp (filter valid?)
            (map transform)
            (take 10))
      data)

;; transduce for a reduction
(transduce
  (comp (filter valid?) (map :score))
  +
  0
  data)
```

Note: lazy sequences do not materialize full intermediate collections -- each
step wraps the previous sequence and computes elements on demand. The transducer
advantage is reduced per-element allocation overhead and a single traversal pass,
which matters most for large collections and performance-critical paths.

When to use transducers:
- Processing large collections where per-element allocation overhead matters
- Building reusable transformation pipelines independent of input source
- Working with core.async channels

When lazy sequences are fine:
- Small collections
- When you genuinely need laziness (infinite sequences, early termination)
- Simple one-off transformations

### Be aware of lazy sequence chunking

Lazy sequences are chunked by default (32 elements at a time). This means
`(first (map f coll))` may evaluate `f` on up to 32 elements, not just one.
When side effects or expensive computation make this problematic, use
transducers or `sequence` with a transducer.

```clojure
;; surprising -- f runs on 32 elements, not 1
(first (map side-effecting-fn! large-coll))

;; predictable -- f runs on exactly 1 element
(first (sequence (map side-effecting-fn!) large-coll))
```

### Data validation with spec or schema libraries

For validating complex data shapes (locale maps, configuration, API boundaries),
consider `clojure.spec.alpha` or `malli`:

- **`clojure.spec.alpha`** -- built-in, good for validation, conforming, and
  generative testing. Best for documenting the shape of data flowing through your
  system.
- **`malli`** -- schema-as-data, better error messages, more flexible. Preferred
  when schemas need to be stored, transmitted, or composed programmatically.
- **`:pre`/`:post` conditions** -- sufficient for simple type/range checks at
  function boundaries. Not a substitute for structured schema validation.

---

## 5. Namespace Design

### Use `:require` with `:as` aliases

`:require` with `:as` is the standard way to declare dependencies. Prefer
aliases over bare `:refer`.

```clojure
;; good -- clear provenance
(ns sayableage.formatter
  (:require
    [clojure.string :as str]
    [sayableage.locale :as locale]
    [sayableage.types :as types]))

(str/join ", " items)
(locale/get-locale :en)
```

### Selective `:refer` for heavily-used names

Bring in specific vars when they are used frequently and their source is
unambiguous.

```clojure
;; acceptable -- is, deftest, testing used constantly in test files
(ns sayableage.core-test
  (:require
    [clojure.test :refer [deftest is testing are]]
    [sayableage.core :as core]))
```

### Never use `:refer :all` or `:use`

Both dump all vars into the current namespace, creating ambiguity and collision
risk.

```clojure
;; bad
(ns myapp.core
  (:use clojure.string))         ; everything imported

;; bad
(ns myapp.core
  (:require [clojure.string :refer :all]))  ; same problem
```

### Standard aliases

Follow community conventions for core libraries:

| Namespace              | Alias    |
| ---------------------- | -------- |
| `clojure.string`       | `str`    |
| `clojure.set`          | `set`    |
| `clojure.walk`         | `walk`   |
| `clojure.zip`          | `zip`    |
| `clojure.java.io`      | `io`     |
| `clojure.java.shell`   | `sh`     |
| `clojure.pprint`       | `pprint` |
| `clojure.spec.alpha`   | `s`      |
| `clojure.edn`          | `edn`    |

For project-internal namespaces, remove redundant leading segments:

```clojure
;; good
[sayableage.locales.en :as en]
[sayableage.formatter :as formatter]

;; bad -- alias repeats the project name
[sayableage.formatter :as sayableage-formatter]
```

### `:import` for Java classes

Group classes by package.

```clojure
(ns sayableage.formatter
  (:require
    [clojure.string :as str])
  (:import
    [java.time LocalDate Period]
    [java.time.temporal ChronoUnit]))
```

### Ordering within `ns`

The conventional order is: docstring, `:require`, `:import`. Within `:require`,
group namespaces: `clojure.*` and `clojure.java.*` first, then third-party
libraries, then project namespaces. Sort alphabetically within each group.

```clojure
(ns sayableage.formatter
  "Formats human ages into natural language."
  (:require
    [clojure.string :as str]

    [sayableage.locale :as locale]
    [sayableage.types :as types])
  (:import
    [java.time LocalDate]))
```

### One namespace per file

Each `.clj` file declares exactly one namespace, matching the file path. The
file `src/sayableage/formatter.clj` declares `(ns sayableage.formatter)`.

### Public API surface

Only expose what consumers need. Mark internal helpers with `defn-` or
`^:private`. Treat every public var as a commitment.

---

## 6. Error Handling

### Use `ex-info` for rich exceptions

`ex-info` creates exceptions carrying a data map, enabling structured error
handling without custom exception classes.

```clojure
;; good -- structured error data
(throw (ex-info "Invalid date of birth"
                {:date-of-birth dob
                 :as-of as-of
                 :reason :future-birth-date}))

;; catching and inspecting
(try
  (format-age dob as-of locale)
  (catch clojure.lang.ExceptionInfo e
    (let [{:keys [reason]} (ex-data e)]
      (handle-error reason))))
```

### Prefer existing exception types

Reuse standard Java exceptions (`IllegalArgumentException`,
`IllegalStateException`, `UnsupportedOperationException`) for simple cases.
Reserve `ex-info` for when you need to attach data.

```clojure
;; good -- standard exception for simple validation
(when (neg? days)
  (throw (IllegalArgumentException. "days must be non-negative")))

;; good -- ex-info when data context is useful
(when (neg? days)
  (throw (ex-info "days must be non-negative" {:days days})))
```

### Use `with-open` for resources

Guarantees cleanup of anything implementing `java.io.Closeable`. The `doall`
call below is critical: without it, `line-seq` returns a lazy sequence that
holds a reference to the reader. After `with-open` closes the reader, any
attempt to realize remaining elements would throw an `IOException`.

```clojure
;; good -- doall forces full realization inside the with-open scope
(with-open [rdr (io/reader "data.csv")]
  (doall (line-seq rdr)))

;; bad -- manual cleanup
(let [rdr (io/reader "data.csv")]
  (try
    (doall (line-seq rdr))
    (finally
      (.close rdr))))
```

### Validate inputs at boundaries

Check preconditions early, at public API entry points. Internal functions can
assume valid data when the boundary is guarded.

```clojure
(defn format-age [date-of-birth as-of locale]
  {:pre [(instance? LocalDate date-of-birth)
         (instance? LocalDate as-of)
         (not (.isAfter date-of-birth as-of))]}
  (format-age-impl date-of-birth as-of locale))
```

### Avoid swallowing exceptions

Never catch and ignore. At minimum, log the error.

```clojure
;; bad
(try
  (risky-operation)
  (catch Exception _))

;; good -- at least log
(try
  (risky-operation)
  (catch Exception e
    (log/warn e "risky-operation failed")))
```

---

## 7. Java Interop

### Use sugared syntax

Clojure provides concise syntax for Java interop. Use it instead of the
`clojure.lang.Reflector` forms.

```clojure
;; Constructor
(java.util.ArrayList. 100)       ; good
(new java.util.ArrayList 100)    ; verbose but acceptable

;; Instance method
(.substring "hello" 1 3)         ; good
(. "hello" substring 1 3)        ; verbose

;; Static method
(Math/pow 2 10)                  ; good
(. Math pow 2 10)                ; verbose

;; Instance field
(.-x point)                      ; good

;; Static field
Integer/MAX_VALUE                ; good
```

### Add type hints to avoid reflection

Reflection is slow. Add `^TypeName` hints on vars, function arguments, or return
values when the compiler warns about reflection.

```clojure
;; good -- eliminates reflection
(defn str-length ^long [^String s]
  (.length s))

;; good -- type hint on local binding
(let [^LocalDate dob (parse-date input)]
  (.getYear dob))

;; check for reflection warnings
;; set *warn-on-reflection* in project config
```

Enable reflection warnings project-wide during development:

```clojure
(set! *warn-on-reflection* true)
```

### Prefer Clojure wrappers when available

Use `clojure.string` over `String` methods, `clojure.java.io` over raw
`java.io`, etc. The Clojure wrappers handle nil gracefully and compose better.

```clojure
;; good
(str/lower-case name)
(str/join ", " items)

;; bad -- raw interop when a wrapper exists
(.toLowerCase name)
```

### Import only what you need

```clojure
;; good -- specific imports
(:import [java.time LocalDate Period])

;; bad -- wildcard (not supported anyway, but the instinct is wrong)
;; Clojure does not support wildcard imports
```

---

## 8. Testing

### Use `clojure.test`

It is the standard, built-in test framework. No dependencies needed.

### Test file naming and namespace

Mirror the source tree with a `-test` suffix.

| Source                         | Test                              |
| ------------------------------ | --------------------------------- |
| `src/sayableage/formatter.clj` | `test/sayableage/formatter_test.clj` |
| `sayableage.formatter`         | `sayableage.formatter-test`       |

### Structure with `deftest` and `testing`

Each `deftest` covers one function or one concern. Use `testing` to group
related assertions with descriptive strings.

```clojure
(deftest format-age-weeks-test
  (testing "formats age in weeks for infants"
    (is (= "6 weeks"
           (format-age (LocalDate/of 2024 1 1)
                       (LocalDate/of 2024 2 12)
                       en-locale))))

  (testing "uses half marker when applicable"
    (is (= "6\u00bd weeks"
           (format-age (LocalDate/of 2024 1 1)
                       (LocalDate/of 2024 2 15)
                       en-locale)))))
```

### Use `are` for tabular tests

When testing the same assertion shape with different data, `are` reduces
boilerplate.

```clojure
(deftest format-age-stages-test
  (are [dob as-of expected]
    (= expected (format-age (LocalDate/parse dob)
                            (LocalDate/parse as-of)
                            en-locale))

    "2024-01-01" "2024-01-01" "just born"
    "2024-01-01" "2024-01-15" "2 weeks"
    "2024-01-01" "2024-04-01" "3 months"
    "2022-01-01" "2024-01-01" "2 years"))
```

### Test one concept per `deftest`

Keep tests focused. A test that checks formatting, error handling, and locale
loading is doing too much.

### Test exception behavior

```clojure
(deftest format-age-invalid-input-test
  (testing "throws on future birth date"
    (is (thrown? IllegalArgumentException
                (format-age (LocalDate/of 2025 1 1)
                            (LocalDate/of 2024 1 1)
                            en-locale))))

  (testing "thrown-with-msg? checks the message"
    (is (thrown-with-msg? IllegalArgumentException
                         #"must not be in the future"
                         (format-age future-date past-date en-locale)))))
```

### Use fixtures sparingly

Prefer setting up test data inline or with helper functions. Use `use-fixtures`
only for genuinely shared setup/teardown (database connections, temp files).

```clojure
;; acceptable -- shared expensive setup
(use-fixtures :once
  (fn [tests]
    (with-test-db
      (tests))))

;; preferred for most cases -- inline data
(deftest my-test
  (let [locale (load-locale :en)]
    (is (= "3 years" (format-age dob as-of locale)))))
```

---

## 9. Common Idioms

### Destructuring

Use destructuring to extract values instead of explicit accessors. It works in
`let`, `fn`, `defn`, `loop`, `for`, `doseq`, and anywhere bindings appear.

**Sequential destructuring:**

```clojure
(let [[first-name last-name] ["Bruce" "Wayne"]]
  (str last-name ", " first-name))

;; & captures the rest
(let [[head & tail] [1 2 3 4 5]]
  {:head head :tail tail})

;; :as binds the whole thing
(let [[x y :as point] [10 20]]
  {:x x :y y :original point})
```

**Associative destructuring:**

```clojure
;; :keys shorthand (most common)
(defn greet [{:keys [name age]}]
  (str "Hello " name ", age " age))

;; nested destructuring
(let [{{:keys [city]} :address} person]
  city)

;; defaults with :or
(defn connect [{:keys [host port]
                :or {host "localhost" port 3000}}]
  (str host ":" port))
```

**Namespaced keys:**

```clojure
(let [{:person/keys [name age]} {:person/name "Bruce" :person/age 30}]
  (str name " is " age))
```

### `let` bindings

Use `let` to name intermediate computations. Each binding should add clarity.

```clojure
;; good -- each step is named
(defn format-stage [locale days]
  (let [stage      (find-stage (:stages locale) days)
        quantity   (compute-quantity stage days)
        unit       (pluralize (:unit stage) quantity (:plural-rule locale))
        half       (when (has-half? stage days) (:half-marker locale))]
    (str quantity half (:delimiter locale) unit)))

;; bad -- deeply nested, hard to follow
(defn format-stage [locale days]
  (str (compute-quantity (find-stage (:stages locale) days) days)
       (when (has-half? (find-stage (:stages locale) days) days)
         (:half-marker locale))
       (:delimiter locale)
       (pluralize (:unit (find-stage (:stages locale) days))
                  (compute-quantity (find-stage (:stages locale) days) days)
                  (:plural-rule locale))))
```

### `cond` for multi-branch conditionals

```clojure
;; good
(cond
  (< days 1)   (:just-born locale)
  (< days 14)  (format-days locale days)
  (< days 60)  (format-weeks locale days)
  (< days 365) (format-months locale days)
  :else        (format-years locale days))
```

Include an `:else` clause when the function should always return a meaningful
value. When `nil` is the correct result for unmatched cases, `:else` is
unnecessary -- Clojure's nil-punning makes this a well-defined behavior.

### `condp` for repeated predicate application

```clojure
;; good -- when comparing against the same value
(condp = (:unit stage)
  :day   (format-days n)
  :week  (format-weeks n)
  :month (format-months n)
  :year  (format-years n)
  (throw (ex-info "Unknown unit" {:unit (:unit stage)})))
```

### `case` for compile-time constants

`case` is O(1) dispatch -- use it when branching on known constants.

```clojure
(case unit
  :day   "day"
  :week  "week"
  :month "month"
  :year  "year")
```

`case` does not evaluate its test values -- they must be compile-time literals.

### Multimethods vs. protocols

**Protocols** -- use for single-dispatch on type. Fast (like Java interface
dispatch).

```clojure
(defprotocol Formattable
  (format-value [this locale]))

(defrecord Age [days]
  Formattable
  (format-value [this locale]
    (format-age-impl days locale)))
```

**Multimethods** -- use for dispatch on arbitrary criteria (multiple arguments,
value-based dispatch, ad-hoc hierarchies).

```clojure
(defmulti pluralize (fn [_word _n rule] rule))

(defmethod pluralize :one-other [word n _]
  (if (= n 1) (:one word) (:other word)))

(defmethod pluralize :one-two-other [word n _]
  (cond
    (= n 1) (:one word)
    (= n 2) (:two word)
    :else   (:other word)))
```

Rule of thumb: if you are dispatching on `(type x)`, use a protocol. If you are
dispatching on anything else (a value, a combination of arguments, a keyword),
use a multimethod.

### `if-let` and `when-let`

Combine binding with nil-checking. Use `when-let` for single-branch, `if-let`
when you need both branches.

```clojure
;; good
(when-let [locale (get locales code)]
  (format-age dob as-of locale))

(if-let [stage (find-stage stages days)]
  (format-stage stage days locale)
  (:just-born locale))

;; bad -- separate binding and check
(let [locale (get locales code)]
  (when locale
    (format-age dob as-of locale)))
```

### `str` for string building

```clojure
;; good
(str quantity half delimiter unit)

;; good for complex formatting with padding or precision
(format "%04d-%02d-%02d" year month day)

;; bad -- Java StringBuilder
(-> (StringBuilder.)
    (.append quantity)
    (.append half)
    (.toString))
```

### `->` and `->>` to replace `get-in` chains

```clojure
;; good
(get-in config [:database :connection :host])

;; also good for deeper navigation
(-> config :database :connection :host)
```

---

## 10. Things to Avoid

### Avoid `def` inside functions

Top-level state mutation hidden inside a function is a serious anti-pattern.

```clojure
;; bad -- creates or modifies a global var as a side effect
(defn init! []
  (def db-connection (connect!)))

;; good -- return the value, let the caller manage it
(defn connect! []
  (create-connection config))
```

### Avoid `require`/`use` outside `ns`

All namespace dependencies belong in the `ns` declaration at the top of the
file.

```clojure
;; bad
(require '[clojure.string :as str])

;; good
(ns myapp.core
  (:require [clojure.string :as str]))
```

Exception: REPL sessions, where runtime `require` is standard practice.

### Avoid unnecessary mutation

Reach for atoms, refs, and agents only when you genuinely need shared mutable
state. Most problems are solved with pure functions and immutable data.

```clojure
;; bad -- mutable accumulator
(let [result (atom [])]
  (doseq [x xs]
    (swap! result conj (transform x)))
  @result)

;; good -- mapv does this
(mapv transform xs)
```

### Avoid `do` when only one expression is needed

`when`, `let`, `defn`, and many macros already provide implicit `do`.

```clojure
;; bad -- redundant do
(when valid?
  (do
    (process)
    (save!)))

;; good
(when valid?
  (process)
  (save!))
```

### Avoid redundant `let` wrapping

```clojure
;; bad
(defn double [x]
  (let [result (* x 2)]
    result))

;; good
(defn double [x]
  (* x 2))
```

### Avoid `nil?` checks where `seq` or `when-let` suffice

```clojure
;; bad
(if (not (nil? x))
  (process x)
  default)

;; good
(if (some? x)
  (process x)
  default)

;; best when checking collection emptiness
(when (seq coll)
  (process coll))
```

### Avoid writing macros when functions work

Macros do not compose with higher-order functions (`map`, `apply`, `comp`).
Write a function first. Only write a macro when you need to control evaluation
or introduce new syntax.

```clojure
;; bad -- macro for something a function handles
(defmacro add [a b]
  `(+ ~a ~b))

;; good -- just a function
(defn add [a b]
  (+ a b))
```

### Avoid `apply concat` -- use `mapcat`

```clojure
;; bad
(apply concat (map f coll))

;; good
(mapcat f coll)
```

### Avoid `count` for emptiness checks

`count` is O(1) for Clojure's persistent vectors, maps, sets, and lists, but
O(n) for lazy sequences -- and worse, it forces full realization of the lazy
sequence (which may be infinite). Use `seq` for a uniform, idiomatic emptiness
check that works correctly across all collection types.

```clojure
;; bad -- forces realization of lazy sequences; non-idiomatic
(if (> (count coll) 0) ...)
(if (= (count coll) 0) ...)

;; good -- short-circuits immediately, works with lazy seqs
(if (seq coll) ...)
(if (empty? coll) ...)  ; acceptable, though (seq ...) is preferred
```

### Avoid premature type hints

Only add type hints where the compiler emits reflection warnings. Do not
sprinkle them prophylactically.

---

## 11. Tooling

### clj-kondo (static linter)

[clj-kondo](https://github.com/clj-kondo/clj-kondo) is the primary static
analysis tool for Clojure. It runs without evaluating code (GraalVM native
binary), making it fast enough for real-time editor integration.

**What it catches:**
- Wrong arity in function calls
- Unresolved symbols and namespaces
- Unused vars, imports, and bindings
- Redundant `do`, `let`, and `if` forms
- Duplicate map keys and set members
- Inline `def` inside functions
- Deprecated var usage
- Private var access from outside namespace
- Type-checking violations

**Configuration** via `.clj-kondo/config.edn`:

```edn
{:linters {:unused-binding {:level :warning}
           :unresolved-symbol {:level :error}
           :redundant-do {:level :warning}}}
```

### Eastwood (deep analysis linter)

[Eastwood](https://github.com/jonase/eastwood) complements clj-kondo with
deeper semantic analysis. It evaluates and macro-expands code (using
`tools.analyzer`), catching issues that static analysis misses.

**Additional catches beyond clj-kondo:**
- Reflection warnings
- Boxed math warnings
- Misplaced docstrings
- Non-dynamic earmuffed vars
- Suspicious test patterns
- Keyword typos (optional, disabled by default)
- Implicit namespace dependencies

Eastwood is best suited for CI pipelines rather than real-time editor
integration due to its evaluation-based approach.

### cljfmt (code formatter)

[cljfmt](https://github.com/weavejester/cljfmt) is the standard automatic
formatter for Clojure code. It enforces formatting conventions with minimal
structural changes.

**Default rules:**
- Removes trailing whitespace
- Removes surrounding whitespace inside forms
- Collapses consecutive blank lines
- Inserts missing whitespace between elements
- Corrects indentation

**Usage:**

```bash
# Check for formatting issues
clj -Tcljfmt check

# Auto-fix formatting
clj -Tcljfmt fix
```

**Configuration** via `.cljfmt.edn`:

```edn
{:indentation? true
 :remove-trailing-whitespace? true
 :remove-consecutive-blank-lines? true
 :sort-ns-references? false
 :indents {defrecord [[:inner 0]]}}
```

The `:community` indentation style (default) aligns with this style guide.

### REPL-driven development

Clojure development is fundamentally REPL-driven. Key practices:

- **Evaluate in-editor**, not in a terminal REPL. All major Clojure editors
  (Emacs/CIDER, VS Code/Calva, IntelliJ/Cursive, Neovim/Conjure) support
  sending forms to a connected REPL.
- **Reload incrementally** using editor keybindings to re-evaluate individual
  forms, not by restarting the JVM.
- **Use `comment` blocks** (rich comment forms) for exploratory code that
  should not run on load but is useful for development.

```clojure
(comment
  ;; scratch pad -- not evaluated on load
  (format-age (LocalDate/of 2020 1 1)
              (LocalDate/of 2024 6 15)
              (load-locale :en))
  ;=> "4\u00bd years"
  )
```

### Recommended project setup

Enable reflection warnings and direct linking in `deps.edn`:

```edn
{:paths ["src"]
 :deps {org.clojure/clojure {:mvn/version "1.12.0"}}
 :aliases
 {:dev {:jvm-opts ["-Dclojure.compiler.warn-on-reflection=true"]}
  :test {:extra-paths ["test"]
         :extra-deps {io.github.cognitect-labs/test-runner
                      {:git/tag "v0.5.1"
                       :git/sha "dfb30dd"}}}}}
```

---

## References

- [The Clojure Style Guide](https://guide.clojure.style/) -- Bozhidar Batsov's
  community-driven guide (the single most comprehensive reference)
- [Clojure Official Guides](https://clojure.org/guides/getting_started) --
  clojure.org tutorials and reference material
- [Clojure Threading Macros Guide](https://clojure.org/guides/threading_macros)
- [Clojure Destructuring Guide](https://clojure.org/guides/destructuring)
- [Clojure Namespace Guide](https://clojure.org/guides/learn/namespaces)
- [Clojure Transducers Reference](https://clojure.org/reference/transducers)
- [Clojure Protocols Reference](https://clojure.org/reference/protocols)
- [clj-kondo](https://github.com/clj-kondo/clj-kondo) -- Static linter
- [Eastwood](https://github.com/jonase/eastwood) -- Deep analysis linter
- [cljfmt](https://github.com/weavejester/cljfmt) -- Code formatter
- [Clojure Library Coding Standards](https://clojure.org/community/contrib_howto)
  -- Official guidelines for contrib libraries

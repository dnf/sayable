# Rebuttal: Go Style Guide Review

Senior Staff Engineer review of the Go style guide at `docs/impl/go/README.md`.

This document catalogs specific disagreements with the guidelines as written,
ordered by section. Each item quotes the problematic guideline, explains why
it is wrong or misleading, and offers a concrete alternative.

---

## 1. Naming Conventions

### 1.1 "Avoid meaningless package names: `util`, `common`, `misc`, `helpers`, `types`, `interfaces`, `models`, `api`"

> Avoid meaningless package names: `util`, `common`, `misc`, `helpers`, `types`,
> `interfaces`, `models`, `api`. These names convey nothing and invite dumping
> unrelated code together.

**Problem:** The blanket condemnation of `types`, `models`, and `api` is
overly dogmatic. The Go standard library itself uses `types` (`go/types`).
The `api` name is perfectly descriptive when a package's purpose is literally
to define the API surface (e.g., Kubernetes `api/v1`). Similarly, `models` is
standard in code generated from OpenAPI specs and database schema packages.

Lumping these in with genuinely meaningless names like `misc` and `helpers`
conflates two different issues: vague names (bad) versus domain-standard names
(often fine).

**Recommendation:** Condemn `util`, `common`, `misc`, and `helpers` as truly
meaningless. Note that `types`, `models`, and `api` are acceptable when the
package genuinely serves that focused purpose, but warn against using them as
catch-all dumping grounds. Cite `go/types` as a stdlib counterexample.

---

## 4. Error Handling

### 4.1 "Never discard errors with `_`"

> Never discard errors with `_`:
> ```go
> // Bad
> _ = f.Close()
> ```

**Problem:** This is too absolute and contradicts common Go practice. The
guide itself acknowledges the exception ("functions documented as never
returning non-nil errors (e.g., `bytes.Buffer.Write`)"), but the categorical
"Never" framing buries the nuance.

More importantly, `_ = f.Close()` after a successful read is a well-known,
widely-accepted pattern. When you have already consumed the data from a
read-only file, a `Close` error on a read-only fd is almost always a
non-actionable I/O error (NFS stale handle, etc.). Wrapping every `Close` in
an `if err != nil` block and logging it adds noise without value in many
real-world programs. The Go standard library examples frequently omit `Close`
error checks for read-only files.

Even more critically, the suggested "fix" -- logging the error -- can itself
be wrong. In short-lived CLI tools or formatting libraries (like this
project), there may be no logger configured, and writing to stderr on a
benign `Close` error would be user-hostile.

**Recommendation:** Replace "Never discard errors" with guidance that says:
always handle errors from operations where failure is actionable. Explicitly
call out that `Close` on read-only file descriptors is a common exception.
Keep the advice to check `Close` errors on *write* paths, where a `Close`
failure can mean data loss (unflushed buffers).

### 4.2 Error wrapping placement advice is too narrow

> Place `%w` at the end of the format string to maintain a readable error chain:
> ```go
> return fmt.Errorf("save user: %w", err)
> ```

**Problem:** This is good advice but omits an important post-Go-1.20 feature:
`fmt.Errorf` can now wrap *multiple* errors with multiple `%w` verbs. The
guide should mention this, as it significantly changes how you think about
error trees (not just chains). Without mentioning it, developers on Go 1.20+
will miss a powerful tool for representing compound failures.

**Recommendation:** Add a note about multi-error wrapping with `%w` in Go
1.20+ and when it is appropriate (e.g., aggregating errors from concurrent
operations).

---

## 5. Interfaces

### 5.1 "Do Not Define Interfaces Prematurely" is too aggressive against testing

> Do not create interfaces before they are needed. If there is only one
> implementation and no testing requirement, use the concrete type.

and

> Do not define interfaces that have only one implementation and exist only "for
> testing" or "for extensibility."

**Problem:** This advice, taken literally, is hostile to testability. In
practice, one of the most legitimate reasons to define an interface in Go is
to enable testing with fakes or stubs. The guide dismisses "for testing" as
if it were not a real requirement. It is.

Consider a type that wraps an HTTP client or a database connection. If you
do not define an interface, your unit tests must either use the real external
service (making them slow, flaky, and integration tests by definition) or use
`httptest` / in-memory DB (which works for some cases but not all).

The Go standard library itself is full of interfaces with exactly one
production implementation that exist primarily for testability and
composability (`io.Reader`, `io.Writer`, `net.Conn`).

The key distinction the guide misses: an interface is premature if no code
*consumes* it. An interface is not premature if you have a concrete consumer
(including tests) that benefits from the indirection.

**Recommendation:** Replace the blanket "do not define interfaces for testing"
with: "Define interfaces when they have at least one consumer that benefits
from the abstraction. Tests are legitimate consumers. Avoid defining
interfaces that have zero consumers -- neither production code nor tests use
the abstraction."

---

## 6. Concurrency

### 6.1 "Channel sizes should usually be 0 or 1"

> Channel sizes should usually be 0 or 1. Larger buffers need careful analysis
> of backpressure. Avoid arbitrary buffer sizes like 64 or 100 without
> justification.

**Problem:** The claim that channel sizes "should usually be 0 or 1" is
misleading. While unbuffered and size-1 channels are common for signaling and
synchronization, production concurrent pipelines routinely use buffers sized
to `runtime.NumCPU()` or to match batch sizes. Telling developers that
anything larger than 1 "needs careful analysis" creates unnecessary fear.

The real rule is simpler: the buffer size should be chosen deliberately, not
arbitrarily. A buffer of `runtime.NumCPU()` for a worker pool is not
"arbitrary" -- it is a well-reasoned default.

**Recommendation:** Say: "Choose buffer sizes deliberately. Unbuffered
channels (size 0) provide synchronization guarantees. Buffered channels
decouple producers from consumers; size them based on the concurrency level
or batch size, not arbitrary round numbers."

### 6.2 Loop variable capture advice is outdated

> ```go
> for _, url := range urls {
>     url := url // capture loop variable
>     g.Go(func() error {
>         return fetch(ctx, url)
>     })
> }
> ```

**Problem:** Since Go 1.22 (released February 2024), the loop variable
semantics changed. Each iteration of a `for` loop now creates a new variable,
eliminating the classic capture bug. The `url := url` line is no longer
necessary in Go 1.22+. The guide should note this, or it will teach
developers a stale idiom and make reviewers flag correct code as missing the
"capture fix."

**Recommendation:** Note that `url := url` is unnecessary in Go 1.22+ due to
the per-iteration variable scoping change. Keep the note for codebases that
must support Go < 1.22, but mark it as legacy.

### 6.3 "Never store `context.Context` in a struct"

> Never store `context.Context` in a struct. Always pass it as a function
> parameter. Never create custom context types.

**Problem:** "Never" is too strong. There are legitimate, well-known cases
where storing a `context.Context` in a struct is the right call:

1. **Request-scoped structs** -- An incoming HTTP request handler struct that
   lives for exactly one request and carries `ctx` alongside the request data.
   The `http.Request` struct itself stores a `Context()`.

2. **Builder/pipeline structs** -- A struct that accumulates configuration and
   then executes, where the context is logically part of the pipeline
   (e.g., `database/sql.Tx` carries a context internally).

3. **Long-lived structs with `Run(ctx)`** -- The `ctx` passed to `Run` is
   stored on the struct for the duration of `Run`. This is a standard pattern
   in libraries like `golang.org/x/sync/errgroup`.

The Go blog post "Contexts and structs" (2021) explicitly discusses when
storing context in a struct is appropriate (request-scoped data, not
long-lived configuration).

**Recommendation:** Replace "never store context in a struct" with: "Prefer
passing context as a function parameter. Storing context in a struct is
acceptable for request-scoped objects whose lifetime matches the context's
lifetime. Do not store context in long-lived objects like server configs or
connection pools."

---

## 7. Type System

### 7.1 "Be consistent: all methods on a type should use the same receiver type"

> Be consistent: all methods on a type should use the same receiver type.

**Problem:** This is the single most misleading guideline in the document. It
contradicts the official Go FAQ, which says:

> "If some of the methods of the type must have pointer receivers, the rest
> should too, so the method set is consistent regardless of how the type is
> used."

The FAQ is saying: if *any* method needs a pointer receiver (mutation,
sync.Mutex, large struct), then *all* should use pointer receivers for method
set consistency. But the reverse is not true: a type can legitimately mix
value and pointer receivers if none of its methods need pointer semantics. The
guide's absolute "all methods should use the same receiver type" discourages
valid designs where a type has both read-only value-receiver methods and
mutating pointer-receiver methods.

More importantly, the Go spec is clear that the method set of `*T` includes
methods of `T`, so mixing is well-defined. The reason to prefer consistency
is about interface satisfaction (the method set of `T` does NOT include
`*T` methods), which is a subtlety the guide should explain rather than
papering over with an absolute rule.

**Recommendation:** Explain the actual rule: "If any method requires a
pointer receiver, use pointer receivers for all methods on that type. This
ensures the type's method set is consistent whether accessed as `T` or `*T`.
If no method requires a pointer receiver, value receivers are fine."

### 7.2 Generics advice is too conservative

> Do not use generics to build frameworks, DSLs, or assertion libraries.

**Problem:** "Do not use generics to build assertion libraries" is a
surprising claim given that the Go ecosystem has widely adopted
`github.com/stretchr/testify` (which predates generics) and newer
generics-based assertion/testing helpers are growing in popularity.

The advice against "frameworks" and "DSLs" is reasonable as a general
heuristic, but the flat prohibition is unnecessarily limiting. Generics are
a natural fit for type-safe assertion helpers like `assertEqual[T](t, got,
want)` that provide better error messages than `interface{}`-based
alternatives.

**Recommendation:** Soften to: "Use generics for algorithms and data
structures that genuinely operate on multiple types. Avoid using generics
solely to create Java-style framework abstractions. When generics improve
type safety without adding complexity (e.g., type-safe containers, typed
assertion helpers), they are a good fit."

---

## 8. Testing

### 8.1 Assertion libraries stance is too dogmatic

> The Go community favors the standard `testing` package over assertion
> libraries. Google's style guide explicitly discourages assertion libraries.

and

> ```go
> // Discouraged -- assertion library hides the actual comparison
> assert.Equal(t, want, got)
> ```

**Problem:** The guide presents Google's internal opinion as community
consensus. This is misleading. `testify` is the most popular Go testing
library by a wide margin (over 23,000 GitHub stars, used in thousands of
projects including major ones like Docker, Kubernetes controllers, and
Terraform providers). Many well-respected Go developers use and recommend
assertion libraries.

The claim that `assert.Equal` "hides the actual comparison" is dubious --
it performs exactly the same comparison but with better default formatting
(including diffs for structs). The guide itself recommends `go-cmp` for
struct comparison, which is effectively an assertion helper.

The real issue with assertion libraries is not that they exist, but that they
can encourage shallow assertions (checking only equality when a more
meaningful check is warranted) and they add a dependency. For a zero-dependency
project like sayable, the stdlib approach is the right choice. But the guide
should frame it as a project decision, not a community mandate.

**Recommendation:** Present both approaches neutrally: "The standard
`testing` package provides explicit control over failure messages. Assertion
libraries like `testify` reduce boilerplate but add a dependency. For this
project, we use the standard library only (zero-dependency policy). For
complex struct comparisons, use `go-cmp`."

### 8.2 Missing guidance on test package naming

The guide covers table-driven tests and helpers but misses an important Go
testing convention: whether to use `package foo` or `package foo_test` for
test files. This is one of the most common questions in Go testing, and the
project's own code uses `package sayableage_test` (the external test package
pattern). The guide should explain when to use each.

**Recommendation:** Add a section explaining that `package foo_test` tests
the public API (black-box testing, preferred for most tests), while
`package foo` tests can access unexported identifiers (white-box testing, use
sparingly for internal logic). Note the `export_test.go` pattern for exposing
internals to external test packages.

---

## 9. Common Idioms

### 9.1 iota advice to "start at 1" is misleading

> Use `iota` for enumerated constants. Start at 1 (not 0) unless zero is a
> meaningful default.

**Problem:** This advice inverts the default. In Go, the zero value is a
first-class concept. The correct guidance is: the zero value of an enum type
should represent the *default* or *unset* state. This sometimes means
starting at 0 (when the first value is a valid default) and sometimes means
starting at 1 or using `_` to skip zero (when zero should mean "not set").

The guide's phrasing -- "start at 1 unless zero is meaningful" -- implies
that starting at 1 is the normal case and starting at 0 is the exception.
This is backwards for a language whose core philosophy is "make the zero
value useful." The guide even quotes this proverb in section 7 but
contradicts it here.

**Recommendation:** Say: "The zero value of a `const` enum should represent
either the default/unset state or be explicitly skipped with `_`. Start at 0
when the first constant is a sensible default. Skip zero with `_ = iota` or
start at `iota + 1` when an uninitialized variable should not silently match
a valid constant."

### 9.2 Functional options presented without alternatives

The guide presents functional options as the pattern for optional parameters,
but does not mention the simpler alternatives that should be preferred when
they suffice:

- **Config struct:** For constructors with many options that are set once,
  a plain config struct is simpler, requires no extra types, and is more
  discoverable via godoc.
- **Method chaining / builder:** For mutable configuration where options
  are set incrementally.

Functional options are powerful but have real costs: each option requires a
new function, they cannot be inspected or compared, and they are less
discoverable than struct fields. They should be presented as one tool among
several, not the default.

**Recommendation:** Present a config struct as the simpler default for
optional configuration. Show functional options as the upgrade path when you
need validation, private fields, or open extension across packages.

### 9.3 "Copy Slices and Maps at API Boundaries" is overstated

> When receiving or returning slices and maps, copy them to prevent the caller
> from mutating internal state.

**Problem:** This is good advice for public API boundaries of mutable
objects, but as stated, it implies you should *always* copy at boundaries.
This would be wasteful for:

- Read-only data (like locale tables in this project, which are initialized
  once and never mutated)
- Internal package boundaries where you control both sides
- Performance-sensitive code where the allocation cost matters

The guide should distinguish between public APIs (where defensive copying is
appropriate) and internal code or immutable data (where it is unnecessary
overhead).

**Recommendation:** Say: "For public APIs that store received slices or maps,
consider copying them to prevent callers from mutating internal state. This
is especially important for mutable, long-lived objects. For immutable or
internal data, copying adds cost without benefit."

---

## 10. Things to Avoid

### 10.1 "Naked returns" advice is too permissive

> Named return values are fine for documentation. Bare `return` statements using
> them are a readability trap -- they obscure what is being returned. Use them
> only in very short functions (a few lines):

**Problem:** The guide says naked returns are "acceptable" in tiny functions
and provides an example. This is the wrong default. Naked returns should be
actively discouraged in all new code, full stop. Even in a 3-line function,
`return x, y` is strictly more readable than a bare `return` with named
results. The "tiny function" exception invites judgment calls that lead to
inconsistency.

The *only* legitimate use of named returns is for documentation purposes
(naming the return values for godoc) and for modifying return values in
deferred functions. In both cases, you should still use explicit `return`
statements.

**Recommendation:** Drop the "acceptable in tiny functions" exception. Say:
"Name return values for documentation when it improves clarity. Always use
explicit return statements; never use bare `return`."

---

## 11. Tooling

### 11.1 CI pipeline is missing `go build`

> Recommended CI Pipeline:
> ```sh
> goimports -l .          # check formatting
> go vet ./...            # built-in checks
> staticcheck ./...       # advanced static analysis
> go test -race ./...     # tests with race detection
> govulncheck ./...       # vulnerability scan
> ```

**Problem:** The recommended CI pipeline omits `go build ./...` as a
distinct step. While `go test` implicitly compiles, a separate `go build`
step catches compilation errors in non-test code (e.g., `cmd/` binaries)
earlier and more clearly than a test failure.

Additionally, the pipeline omits `go mod tidy` verification, which is
important for catching stale or missing module dependencies:
```sh
go mod tidy && git diff --exit-code go.mod go.sum
```

**Recommendation:** Add `go build ./...` before the test step and a
`go mod tidy` check to catch dependency drift.

### 11.2 golangci-lint config example is too minimal

The example `.golangci.yml` enables only 6 linters. `golangci-lint` ships
with many more valuable linters enabled by default (as of v2). The example
should either show a realistic configuration or simply recommend using the
default linter set and disabling specific linters that produce false positives
for your codebase.

**Recommendation:** Either show a more complete configuration or simply say:
"Use the default linter set. Disable specific linters only with documented
justification."

---

## General Structural Issues

### G.1 The guide is too long and unfocused for a project style guide

At 1519 lines, this guide attempts to be both a Go language tutorial and a
project style guide. It re-explains language fundamentals (how goroutines
work, what `defer` does, how interfaces are satisfied implicitly) that any Go
developer already knows. A style guide should document *decisions* -- the
places where reasonable people might disagree and the project has chosen a
specific convention.

**Recommendation:** Cut the tutorial content. Assume the reader is a
competent Go developer. Focus on project-specific decisions and conventions
that differ from or add to the standard references (Effective Go, Go Code
Review Comments). Link to those references for fundamentals.

### G.2 No project-specific conventions

The guide does not mention any conventions specific to this project (sayable).
For example:

- The project uses `package sayableage_test` (external test package) with an
  `export_test.go` pattern -- the guide should call this out.
- The project uses zero dependencies -- the guide should explain what this
  means for Go specifically (no `testify`, custom `itoa` instead of `strconv`,
  etc.).
- The project uses `*string` return types for nullable results -- the guide
  should explain this API design decision.
- The project uses variadic `...string` for optional parameters -- this
  pattern has tradeoffs the guide should discuss.

**Recommendation:** Add a "Project Conventions" section covering
sayable-specific patterns, or frame the entire guide around the project's
actual decisions rather than generic Go advice.

### G.3 Go Proverbs listed without context

The guide ends with a raw list of Go Proverbs. Several of these are already
quoted inline in relevant sections. The duplicated list at the end adds no
value -- a reader who has read the guide has already seen the relevant ones.
Proverbs that are NOT discussed anywhere in the guide (`Cgo is not Go`,
`Syscall must always be guarded with build tags`, `Reflection is never clear`)
are listed without explanation of their relevance.

**Recommendation:** Remove the standalone proverbs list. The proverbs are
already used effectively inline where relevant. If any remaining proverbs are
important to the project, integrate them into the appropriate section with
context.

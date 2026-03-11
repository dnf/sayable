# Go Style Guide

A comprehensive guide to idiomatic Go coding style and best practices.
Used for auditing Go implementations in this project.

## Sources

This guide synthesizes conventions from:

- [Effective Go](https://go.dev/doc/effective_go) -- the official guide from the Go team
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments) -- common code review feedback
- [Google Go Style Guide](https://google.github.io/styleguide/go/guide) -- Google's internal style guide, made public
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md) -- widely adopted industry guide
- [Go Proverbs](https://go-proverbs.github.io/) -- Rob Pike's guiding principles

---

## 1. Naming Conventions

Go naming is one of the most distinctive aspects of the language. Names carry
semantic weight: the case of the first letter determines visibility.

### Packages

Package names are lowercase, single-word, no underscores, no mixedCaps.

```go
package strconv   // good
package httputil  // good

package str_conv  // bad -- no underscores
package myPackage // bad -- no mixedCaps
```

The package name is part of every qualified reference, so avoid stutter:

```go
// In package http:
http.Server     // good -- reads naturally
http.HTTPServer // bad -- "HTTP" already implied by package name

// In package chubby:
chubby.File     // good
chubby.ChubbyFile // bad -- redundant
```

Avoid meaningless package names: `util`, `common`, `misc`, `helpers`, `types`,
`interfaces`, `models`, `api`. These names convey nothing and invite dumping
unrelated code together.

A good package name should not need renaming at the import site.

### Exported vs. Unexported

Uppercase first letter exports. Lowercase keeps it package-private.

```go
func ParseJSON(data []byte) error  // exported -- visible outside package
func parseJSON(data []byte) error  // unexported -- package-internal only

type Client struct { }             // exported
type client struct { }             // unexported
```

Start unexported. Export only what callers need.

### Functions and Methods

Use MixedCaps, never underscores:

```go
func ReadFile(name string) ([]byte, error) // good
func read_file(name string) ([]byte, error) // bad
```

Getters omit `Get`:

```go
func (u *User) Name() string     // good -- getter
func (u *User) GetName() string  // bad -- Go convention drops "Get"
func (u *User) SetName(n string) // fine -- setters keep "Set"
```

### Variables

Name length is proportional to scope distance. Short names for tight scopes,
descriptive names for broader ones:

```go
// Single-letter for tiny scopes
for i, v := range items {
    process(v)
}

// Short for local variables
r, err := http.Get(url)

// Descriptive for package-level or struct fields
var defaultTimeout = 30 * time.Second
```

Conventional short names for common types:

| Type             | Name  |
| ---------------- | ----- |
| `io.Reader`      | `r`   |
| `io.Writer`      | `w`   |
| `context.Context`| `ctx` |
| `*testing.T`     | `t`   |
| `*http.Request`  | `r`, `req` |
| loop index       | `i`, `j`, `k` |

### Method Receivers

Use a one- or two-letter abbreviation of the type name. Be consistent across
all methods on the type. Never use `this`, `self`, or `me`:

```go
func (c *Client) Do(req *Request) (*Response, error)  // good
func (cl *Client) Do(req *Request) (*Response, error)  // acceptable
func (self *Client) Do(req *Request) (*Response, error) // bad
```

### Constants

Constants use MixedCaps like everything else. Never `ALL_CAPS`:

```go
const maxRetries = 3            // good -- unexported
const DefaultTimeout = 30       // good -- exported
const MAX_RETRIES = 3           // bad -- not Go style
```

### Initialisms and Acronyms

Keep all letters of an initialism in the same case:

```go
type HTTPClient struct{}   // good
type HttpClient struct{}   // bad

var xmlHTTPRequest         // good -- multiple initialisms
var userID string          // good -- "ID" not "Id"
var appURL string          // good -- "URL" not "Url"
```

### Interfaces

One-method interfaces are named with the method plus an `-er` suffix (or
similar agent noun):

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Stringer interface {
    String() string
}

type Formatter interface {
    Format(f fmt.State, verb rune)
}
```

Larger interfaces get noun-like names describing their role:

```go
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

### Error Naming

```go
// Sentinel errors: Err prefix
var ErrNotFound = errors.New("not found")
var errInternal = errors.New("internal error")  // unexported

// Error types: Error suffix
type NotFoundError struct {
    Name string
}

func (e *NotFoundError) Error() string {
    return fmt.Sprintf("%s not found", e.Name)
}
```

---

## 2. Code Formatting

### gofmt Is Non-Negotiable

All Go code must be formatted with `gofmt`. No exceptions. No debates about
brace placement, indentation width, or spacing. The tool decides.

> "Gofmt's style is no one's favorite, yet gofmt is everyone's favorite."
> -- Go Proverbs

Run `gofmt` or `goimports` (which is a superset that also manages import
grouping) before committing.

### Import Grouping

Organize imports into groups separated by blank lines. Standard library first:

```go
import (
    "context"
    "fmt"
    "os"

    "github.com/google/go-cmp/cmp"
    "golang.org/x/sync/errgroup"

    "myproject/internal/config"
)
```

Three groups: stdlib, external dependencies, internal packages. `goimports`
handles this automatically.

Avoid renaming imports unless there is a collision:

```go
import (
    "crypto/rand"
    mrand "math/rand"  // renamed to avoid collision
)
```

Never use dot imports (`. "pkg"`) in production code. They obscure where
names come from. The only acceptable use is in tests with circular dependency
issues.

### Line Length

Go has no rigid line length limit. Do not wrap lines artificially to hit a
number. Wrap based on semantics -- if a line is too long, the real problem is
usually that names should be shorter or logic should be extracted:

```go
// Fine as one line -- reads naturally
result, err := client.FetchUser(ctx, userID, WithTimeout(5*time.Second))

// If too long, extract a local variable
opts := WithTimeout(5 * time.Second)
result, err := client.FetchUser(ctx, userID, opts)
```

### Grouping Related Declarations

Group related `var` and `const` blocks:

```go
var (
    errNotFound  = errors.New("not found")
    errForbidden = errors.New("forbidden")
)

const (
    defaultHost = "localhost"
    defaultPort = 8080
)
```

---

## 3. Package Design

### Package Naming

The package name is a single lowercase word that summarizes the package's
purpose. It does not need to be globally unique -- import paths handle that.

```go
package http     // serves HTTP
package json     // encodes/decodes JSON
package user     // manages users
```

Avoid generic names. If you cannot describe what the package does in one
word, reconsider the design.

### Internal Packages

The `internal` directory restricts visibility to the parent tree:

```
myproject/
  internal/
    config/     # only myproject/ and its subtree can import this
  cmd/
    server/
```

Use `internal` for implementation details that should not become public API.

### API Surface

Export the minimum necessary. Unexported things can always be exported later;
removing exports is a breaking change.

> "A little copying is better than a little dependency." -- Go Proverbs

Return concrete types, not interfaces. Let callers define the interfaces they
need (see section 5).

### Godoc

Every exported name must have a doc comment. The comment is a complete
sentence starting with the name of the thing being documented:

```go
// Client manages communication with the API server.
type Client struct { ... }

// NewClient returns a Client configured with the given options.
func NewClient(opts ...Option) *Client { ... }

// Get retrieves the resource at the given path.
func (c *Client) Get(ctx context.Context, path string) (*Response, error) { ... }
```

Package-level doc comments appear immediately before the `package` clause:

```go
// Package httputil provides HTTP utility functions for request
// parsing and response formatting.
package httputil
```

Focus on *what* and *why*, not *how*. The implementation is right there in the
code.

---

## 4. Error Handling

Error handling is Go's most distinctive pattern. Errors are values, not
exceptions. Handle them explicitly.

### The Basic Pattern

```go
f, err := os.Open(filename)
if err != nil {
    return fmt.Errorf("opening config: %w", err)
}
defer f.Close()
```

Check errors immediately. Return early. Keep the happy path at minimal
indentation:

```go
// Good -- error handled first, happy path flows down
result, err := doSomething()
if err != nil {
    return err
}
process(result)

// Bad -- happy path nested inside else
if result, err := doSomething(); err != nil {
    return err
} else {
    process(result)
}
```

### Error Strings

Error strings are lowercase (unless starting with a proper noun or acronym)
and have no trailing punctuation. They are often printed following other
context:

```go
fmt.Errorf("opening file: %w", err)       // good
fmt.Errorf("Opening file: %w.", err)       // bad -- capital, period
```

### Wrapping with %w

Use `%w` to wrap errors when callers should be able to inspect the cause with
`errors.Is` or `errors.As`:

```go
if err := db.Query(ctx, sql); err != nil {
    return fmt.Errorf("user lookup: %w", err)
}

// Caller can now do:
if errors.Is(err, sql.ErrNoRows) {
    // handle missing user
}
```

Use `%v` instead when you want to add context but intentionally hide the
underlying error (preventing callers from depending on it):

```go
return fmt.Errorf("user lookup failed: %v", err)  // opaque -- callers cannot unwrap
```

Place `%w` at the end of the format string to maintain a readable error chain:

```go
// Produces: "save user: validate email: invalid format"
return fmt.Errorf("save user: %w", err)
```

### Sentinel Errors

Define package-level error values for conditions callers need to check:

```go
var (
    ErrNotFound   = errors.New("not found")
    ErrPermission = errors.New("permission denied")
)

// Callers use errors.Is:
if errors.Is(err, mypackage.ErrNotFound) {
    // handle
}
```

### Custom Error Types

Use custom types when errors carry structured data callers need:

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation: %s: %s", e.Field, e.Message)
}

// Callers use errors.As:
var ve *ValidationError
if errors.As(err, &ve) {
    fmt.Println("Bad field:", ve.Field)
}
```

### Handle Errors Once

Either log an error or return it. Never both -- that creates duplicate log
entries up the call stack:

```go
// Good -- return with context
if err != nil {
    return fmt.Errorf("connecting to db: %w", err)
}

// Good -- log and degrade
if err != nil {
    log.Printf("connecting to db: %v", err)
    return fallbackValue, nil
}

// Bad -- log AND return
if err != nil {
    log.Printf("connecting to db: %v", err)
    return fmt.Errorf("connecting to db: %w", err)
}
```

### Do Not Ignore Errors

Never discard errors with `_`:

```go
// Bad
_ = f.Close()

// Good -- handle or at minimum log
if err := f.Close(); err != nil {
    log.Printf("closing file: %v", err)
}
```

The only exception is functions documented as never returning non-nil errors
(e.g., `bytes.Buffer.Write`).

### Do Not Panic

`panic` is not for normal error handling. Use it only for genuinely
unrecoverable programmer errors (invariant violations). Return errors instead:

```go
// Good
func Parse(s string) (*Config, error) {
    if s == "" {
        return nil, errors.New("empty input")
    }
    // ...
}

// Acceptable -- Must* functions for program initialization
func MustParse(s string) *Config {
    cfg, err := Parse(s)
    if err != nil {
        panic(fmt.Sprintf("MustParse(%q): %v", s, err))
    }
    return cfg
}

// Usage at package init time only
var defaultConfig = MustParse("default.yaml")
```

---

## 5. Interfaces

### Implicit Implementation

Go interfaces are satisfied implicitly. There is no `implements` keyword. If
a type has the right methods, it satisfies the interface:

```go
type Writer interface {
    Write(p []byte) (n int, err error)
}

type MyBuffer struct {
    data []byte
}

// MyBuffer satisfies Writer by having a Write method with the right signature.
func (b *MyBuffer) Write(p []byte) (n int, err error) {
    b.data = append(b.data, p...)
    return len(p), nil
}
```

### Keep Interfaces Small

> "The bigger the interface, the weaker the abstraction." -- Go Proverbs

One- or two-method interfaces are the sweet spot. The standard library is full
of them: `io.Reader`, `io.Writer`, `fmt.Stringer`, `sort.Interface` (3
methods).

### Accept Interfaces, Return Structs

Functions should accept interfaces (to be flexible about inputs) and return
concrete types (to give callers full access to the type's methods):

```go
// Good -- accepts interface, returns concrete
func NewDecoder(r io.Reader) *Decoder { ... }

// Bad -- returns interface unnecessarily
func NewDecoder(r io.Reader) Decoder { ... }
```

### Define Interfaces at the Consumer

Interfaces belong in the package that *uses* them, not the one that
*implements* them:

```go
// In the consumer package:
package orderservice

type PaymentProcessor interface {
    Charge(amount int, currency string) error
}

func ProcessOrder(ctx context.Context, p PaymentProcessor, order Order) error {
    // ...
}

// In the producer package -- just export the concrete type:
package stripe

type Client struct { ... }

func (c *Client) Charge(amount int, currency string) error { ... }
```

This allows each consumer to define the minimal interface it needs, and
producers do not need to know about every consumer.

### Do Not Define Interfaces Prematurely

Do not create interfaces before they are needed. If there is only one
implementation and no testing requirement, use the concrete type:

```go
// Bad -- premature abstraction
type UserStore interface {
    Get(id string) (*User, error)
    Save(u *User) error
}

type userStore struct { ... }

func NewUserStore() UserStore { return &userStore{} }

// Good -- just export the concrete type
type UserStore struct { ... }

func (s *UserStore) Get(id string) (*User, error) { ... }
func (s *UserStore) Save(u *User) error { ... }
```

### Compile-Time Interface Compliance

Verify that a type satisfies an interface at compile time using the blank
identifier:

```go
var _ http.Handler = (*MyHandler)(nil)
var _ io.ReadWriteCloser = (*MyConn)(nil)
```

This fails at compile time if the type does not implement the interface,
catching errors early.

---

## 6. Concurrency

### The Fundamental Rule

> "Don't communicate by sharing memory; share memory by communicating."
> -- Go Proverbs

Prefer channels for coordination. Use mutexes when channels are awkward
(protecting a shared data structure accessed by multiple goroutines).

### Goroutines

Goroutines are cheap but not free. Every goroutine you start must have a
clear termination condition:

```go
// Good -- clear lifecycle with shutdown signal
func (s *Server) Run(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        case req := <-s.requests:
            s.handle(req)
        }
    }
}
```

Never fire-and-forget a goroutine without a way to stop it. Leaked goroutines
consume memory indefinitely and the garbage collector will not reclaim them.

### Channels

> "Channels orchestrate; mutexes serialize." -- Go Proverbs

Use unbuffered channels for synchronization (hand-off semantics) and buffered
channels for decoupling producer/consumer rates:

```go
done := make(chan struct{})        // unbuffered -- synchronization signal
work := make(chan Task, 10)        // buffered -- decouple producer/consumer
```

Channel sizes should usually be 0 or 1. Larger buffers need careful analysis
of backpressure. Avoid arbitrary buffer sizes like 64 or 100 without
justification.

### sync Package

Use `sync.Mutex` and `sync.RWMutex` for protecting shared state:

```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]Item
}

func (c *Cache) Get(key string) (Item, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    item, ok := c.items[key]
    return item, ok
}

func (c *Cache) Set(key string, item Item) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = item
}
```

Mutexes have valid zero values -- do not use pointers to them. Place the mutex
above the fields it protects, and never embed it in a public struct (to avoid
leaking `Lock`/`Unlock` methods):

```go
type SafeMap struct {
    mu    sync.Mutex     // guards entries
    entries map[string]int
}
```

Use `sync.WaitGroup` to wait for multiple goroutines:

```go
var wg sync.WaitGroup
for _, item := range items {
    wg.Add(1)
    go func(item Item) {
        defer wg.Done()
        process(item)
    }(item)
}
wg.Wait()
```

Use `sync.Once` for one-time initialization:

```go
var (
    instance *Client
    once     sync.Once
)

func GetClient() *Client {
    once.Do(func() {
        instance = &Client{ /* ... */ }
    })
    return instance
}
```

### context.Context

Pass `context.Context` as the first parameter to functions that may block,
do I/O, or need cancellation:

```go
func FetchUser(ctx context.Context, id string) (*User, error) { ... }
```

Never store `context.Context` in a struct. Always pass it as a function
parameter. Never create custom context types.

Use `context.Background()` only at the top of the call tree (`main`,
`init`, `TestXxx`).

### errgroup

For concurrent operations where any failure should cancel the rest, use
`golang.org/x/sync/errgroup`:

```go
g, ctx := errgroup.WithContext(ctx)

for _, url := range urls {
    url := url // capture loop variable
    g.Go(func() error {
        return fetch(ctx, url)
    })
}

if err := g.Wait(); err != nil {
    return fmt.Errorf("fetching urls: %w", err)
}
```

---

## 7. Type System

### Structs

Initialize with field names. Omit zero-value fields:

```go
// Good -- field names, zero values omitted
srv := &http.Server{
    Addr:         ":8080",
    ReadTimeout:  5 * time.Second,
    WriteTimeout: 10 * time.Second,
}

// Bad -- positional, fragile, unreadable
srv := &http.Server{":8080", nil, nil, 5 * time.Second, 10 * time.Second, ...}
```

### Make the Zero Value Useful

> "Make the zero value useful." -- Go Proverbs

Design types so that their zero value is ready to use without initialization:

```go
// Good -- zero value of sync.Mutex is an unlocked mutex
var mu sync.Mutex

// Good -- zero value of bytes.Buffer is an empty buffer
var buf bytes.Buffer
buf.WriteString("hello")
```

### Embedding

Struct embedding promotes the embedded type's methods and fields. Use it for
composition, not inheritance:

```go
type Logger struct {
    *log.Logger
}

// Logger now has Print, Printf, Println, etc.
```

Do not embed types in public structs unless the promoted methods are genuinely
part of the outer type's API. Embedding leaks implementation details and makes
API evolution harder. Prefer explicit delegation:

```go
// Prefer this for public types:
type Server struct {
    logger *log.Logger
}

func (s *Server) Log(msg string) {
    s.logger.Println(msg)
}
```

### Type Assertions

Always use the comma-ok form to avoid panics:

```go
// Good -- safe
s, ok := val.(string)
if !ok {
    return errors.New("expected string")
}

// Bad -- panics if val is not a string
s := val.(string)
```

Use type switches for multiple type checks:

```go
switch v := val.(type) {
case string:
    process(v)
case int:
    processInt(v)
default:
    return fmt.Errorf("unexpected type %T", v)
}
```

### Receiver Type: Pointer vs. Value

Use a **pointer receiver** when:
- The method mutates the receiver
- The receiver contains a `sync.Mutex` or other non-copyable field
- The receiver is a large struct or array
- When in doubt

Use a **value receiver** when:
- The receiver is a small, immutable struct or a basic type
- The receiver is a map, channel, or function (never use pointer for these)
- The receiver is a slice and the method does not reslice or reallocate

Be consistent: all methods on a type should use the same receiver type.

### Generics

Generics (added in Go 1.18) are powerful but should be used sparingly. Start
with concrete types. Add generics only when you have multiple implementations
of the same algorithm with different types, and the duplication is significant:

```go
// Good use -- truly generic algorithm
func Map[T, U any](s []T, f func(T) U) []U {
    result := make([]U, len(s))
    for i, v := range s {
        result[i] = f(v)
    }
    return result
}

// Questionable -- if you only have one concrete type, just use it
func Sum[T constraints.Integer | constraints.Float](vals []T) T { ... }
```

Do not use generics to build frameworks, DSLs, or assertion libraries.

---

## 8. Testing

### Table-Driven Tests

The standard Go testing pattern. Define test cases as a slice of structs, then
loop over them:

```go
func TestFormatAge(t *testing.T) {
    tests := []struct {
        name string
        days int
        want string
    }{
        {name: "newborn", days: 0, want: "just born"},
        {name: "one week", days: 7, want: "1 week"},
        {name: "two years", days: 730, want: "2 years"},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := FormatAge(tt.days)
            if got != tt.want {
                t.Errorf("FormatAge(%d) = %q, want %q", tt.days, got, tt.want)
            }
        })
    }
}
```

Use `t.Run` with descriptive names so failures are easy to find and individual
cases can be run with `-run`.

### Assertion Libraries vs. Standard Library

The Go community favors the standard `testing` package over assertion
libraries. Google's style guide explicitly discourages assertion libraries.
Write explicit comparisons with clear failure messages:

```go
// Preferred -- clear, explicit, good failure message
if got != want {
    t.Errorf("Encode(%q) = %q, want %q", input, got, want)
}

// Discouraged -- assertion library hides the actual comparison
assert.Equal(t, want, got)
```

For complex struct comparisons, use `go-cmp`:

```go
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("FetchUser() mismatch (-want +got):\n%s", diff)
}
```

### Test Helpers

Mark helper functions with `t.Helper()` so failure messages point to the
calling test, not the helper:

```go
func mustParseDate(t *testing.T, s string) time.Time {
    t.Helper()
    d, err := time.Parse("2006-01-02", s)
    if err != nil {
        t.Fatalf("mustParseDate(%q): %v", s, err)
    }
    return d
}
```

### t.Error vs. t.Fatal

Use `t.Error` (non-fatal) when subsequent checks are still meaningful. Use
`t.Fatal` only when the test cannot continue:

```go
// Use Error -- report all failures
for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        if got := f(tt.input); got != tt.want {
            t.Errorf("f(%v) = %v, want %v", tt.input, got, tt.want)
        }
    })
}

// Use Fatal -- cannot decode means cannot test further
data, err := Decode(input)
if err != nil {
    t.Fatalf("Decode(%q) failed: %v", input, err)
}
// ... test data
```

Never call `t.Fatal` from a goroutine -- use `t.Error` and return instead.

### Failure Messages

Always include: what function was called, what inputs were given, what was
returned, and what was expected:

```go
t.Errorf("FormatAge(%d, %q) = %q, want %q", days, locale, got, want)
```

### Example Tests

Write `Example` functions to demonstrate usage. They appear in godoc and run
as tests:

```go
func ExampleFormatAge() {
    fmt.Println(FormatAge(45))
    // Output: 6 weeks
}
```

---

## 9. Common Idioms

### The Blank Identifier

Use `_` to discard unwanted values:

```go
// Discard the index
for _, v := range items {
    process(v)
}

// Discard a return value (only when documented as safe)
_ = writer.Write([]byte("ok"))  // Write to bytes.Buffer never fails
```

Use the blank identifier for compile-time interface checks:

```go
var _ fmt.Stringer = (*MyType)(nil)
```

Use blank imports for side effects only (e.g., registering drivers):

```go
import _ "image/png"  // register PNG decoder
```

### init Functions

`init()` runs automatically at package initialization time, after all package-
level variables are initialized and all imported packages are fully initialized.

Use sparingly. `init` functions make it harder to reason about program startup
because they run implicitly and cannot be called directly. Prefer explicit
initialization in `main()`:

```go
// Acceptable -- registering a codec
func init() {
    image.RegisterFormat("png", pngHeader, Decode, DecodeConfig)
}

// Avoid -- complex setup with I/O or error handling
func init() {
    db, err := sql.Open("postgres", connStr)  // bad -- can't handle error
    if err != nil {
        log.Fatal(err)  // this is the only option, which is limiting
    }
    globalDB = db
}
```

### iota

Use `iota` for enumerated constants. Start at 1 (not 0) unless zero is a
meaningful default:

```go
type Weekday int

const (
    Monday Weekday = iota + 1
    Tuesday
    Wednesday
    Thursday
    Friday
    Saturday
    Sunday
)
```

Use the blank identifier to skip the zero value when zero should be invalid:

```go
type Color int

const (
    _ Color = iota  // skip zero
    Red
    Green
    Blue
)
```

### Functional Options

For constructors with many optional parameters, use the functional options
pattern:

```go
type Option func(*Server)

func WithPort(port int) Option {
    return func(s *Server) {
        s.port = port
    }
}

func WithTimeout(d time.Duration) Option {
    return func(s *Server) {
        s.timeout = d
    }
}

func NewServer(addr string, opts ...Option) *Server {
    s := &Server{
        addr:    addr,
        port:    8080,           // default
        timeout: 30 * time.Second, // default
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// Usage
srv := NewServer("localhost",
    WithPort(9090),
    WithTimeout(60*time.Second),
)
```

### defer

Use `defer` for cleanup. It runs when the enclosing function returns,
including on panic. Deferred calls execute in LIFO order:

```go
func readFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer f.Close()

    return io.ReadAll(f)
}
```

Defer has negligible overhead. Use it whenever cleanup is needed -- the
readability benefit far outweighs the nanosecond cost.

Defer after the error check, not before:

```go
// Good -- only defer if Open succeeded
f, err := os.Open(path)
if err != nil {
    return err
}
defer f.Close()

// Bad -- defers Close on a nil file
defer f.Close()
f, err = os.Open(path)
```

### Copy Slices and Maps at API Boundaries

When receiving or returning slices and maps, copy them to prevent the caller
from mutating internal state:

```go
func (s *Store) SetItems(items []Item) {
    s.items = make([]Item, len(items))
    copy(s.items, items)
}

func (s *Store) Items() []Item {
    result := make([]Item, len(s.items))
    copy(result, s.items)
    return result
}
```

### Nil Slices Are Fine

A nil slice and an empty slice behave identically for `len`, `cap`, `append`,
and `range`. Prefer `var s []string` (nil) over `s := []string{}` (empty).

The one exception is JSON encoding: nil slices encode as `null`, empty slices
as `[]`.

### Time Handling

Use `time.Time` for instants and `time.Duration` for periods. Do not use raw
integers for time:

```go
// Good
func Poll(interval time.Duration) { ... }

// Bad
func Poll(intervalMS int) { ... }
```

Use `time.Time.AddDate` for calendar arithmetic (respects DST, months of
varying length). Use `time.Time.Add` for fixed durations.

---

## 10. Things to Avoid

### Naked Returns

Named return values are fine for documentation. Bare `return` statements using
them are a readability trap -- they obscure what is being returned. Use them
only in very short functions (a few lines):

```go
// Acceptable -- tiny function
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return
}

// Bad -- in longer functions, naked returns are confusing
func processData(input []byte) (result []byte, err error) {
    // ... 30 lines of code ...
    return  // what is being returned?
}
```

### init Abuse

Do not use `init()` for:
- I/O operations (file reads, network calls)
- Complex setup that can fail
- Spawning goroutines
- Global state mutation that callers cannot control

### Interface Pollution

Do not define interfaces that have only one implementation and exist only "for
testing" or "for extensibility." This is premature abstraction that adds
indirection without value:

```go
// Bad -- one implementation, interface exists "just in case"
type UserRepository interface {
    FindByID(id string) (*User, error)
}

type postgresUserRepository struct { ... }

// Good -- just use the concrete type until you actually need the interface
type UserRepository struct { ... }
func (r *UserRepository) FindByID(id string) (*User, error) { ... }
```

### Premature Abstraction

> "A little copying is better than a little dependency." -- Go Proverbs

Resist the urge to DRY everything into shared packages. Duplicating a small
function across two packages is often better than creating a shared utility
package that couples them.

### Mutable Global State

Avoid package-level mutable variables. They make code hard to test and create
hidden dependencies between packages. Inject dependencies instead:

```go
// Bad
var db *sql.DB

func GetUser(id string) (*User, error) {
    return db.QueryRow(...)
}

// Good
type UserStore struct {
    db *sql.DB
}

func (s *UserStore) GetUser(id string) (*User, error) {
    return s.db.QueryRow(...)
}
```

### os.Exit Outside of main

Call `os.Exit` or `log.Fatal` only in `main()`. Everywhere else, return
errors. This makes code testable and composable:

```go
// Bad
func loadConfig() *Config {
    data, err := os.ReadFile("config.yaml")
    if err != nil {
        log.Fatal(err)  // untestable, kills the process
    }
    // ...
}

// Good
func loadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("reading config: %w", err)
    }
    // ...
}

func main() {
    cfg, err := loadConfig("config.yaml")
    if err != nil {
        log.Fatal(err)
    }
}
```

### In-Band Error Values

Do not use sentinel return values (-1, "", nil) to signal errors. Use Go's
multiple return values:

```go
// Bad
func Lookup(key string) string {
    // returns "" on not found -- caller cannot distinguish from empty value
}

// Good
func Lookup(key string) (string, bool) {
    // returns ("", false) on not found
}

// Also good
func Lookup(key string) (string, error) {
    // returns ("", ErrNotFound) on not found
}
```

### Embedding sync.Mutex in Public Structs

Never embed `sync.Mutex` (or `sync.RWMutex`) in a public struct. It exposes
`Lock` and `Unlock` as exported methods:

```go
// Bad -- Lock/Unlock are now part of the public API
type Cache struct {
    sync.Mutex
    items map[string]Item
}

// Good -- mutex is unexported field
type Cache struct {
    mu    sync.Mutex
    items map[string]Item
}
```

---

## 11. Tooling

### go vet

Built into the Go toolchain. Catches common mistakes: printf format mismatches,
unreachable code, suspicious struct tags, copying of locks, and more.

```sh
go vet ./...
```

Run on every commit. It has zero false positives by design.

### staticcheck

The gold-standard static analysis tool for Go. Catches bugs, performance
issues, and style violations that `go vet` does not:

```sh
staticcheck ./...
```

Checks include: deprecated API usage, unnecessary nil checks, inefficient
string concatenation, and many more.

- https://staticcheck.dev

### golangci-lint

A meta-linter that runs many linters in parallel (including `go vet`,
`staticcheck`, `errcheck`, `ineffassign`, `govet`, and dozens more). This is
the standard way to run linters in CI:

```sh
golangci-lint run ./...
```

Configure via `.golangci.yml`:

```yaml
linters:
  enable:
    - errcheck
    - govet
    - staticcheck
    - unused
    - ineffassign
    - gosimple
```

- https://golangci-lint.run

### govulncheck

Scans your code and dependencies for known vulnerabilities:

```sh
govulncheck ./...
```

Only reports vulnerabilities in code paths your program actually calls, not
just any vulnerability in a dependency.

- https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck

### goimports

A superset of `gofmt` that also manages import grouping and removes unused
imports:

```sh
goimports -w .
```

Many editors run this on save.

### go test -race

The race detector finds data races at runtime. Run tests with it enabled:

```sh
go test -race ./...
```

Essential for any code using goroutines. A data race found by the detector is
always a real bug.

### Recommended CI Pipeline

```sh
goimports -l .          # check formatting (should produce no output)
go vet ./...            # built-in checks
staticcheck ./...       # advanced static analysis
go test -race ./...     # tests with race detection
govulncheck ./...       # vulnerability scan
```

---

## Go Proverbs

These proverbs, from Rob Pike's 2015 talk, capture the philosophy of Go:

1. Don't communicate by sharing memory; share memory by communicating.
2. Concurrency is not parallelism.
3. Channels orchestrate; mutexes serialize.
4. The bigger the interface, the weaker the abstraction.
5. Make the zero value useful.
6. `interface{}` says nothing.
7. Gofmt's style is no one's favorite, yet gofmt is everyone's favorite.
8. A little copying is better than a little dependency.
9. Syscall must always be guarded with build tags.
10. Cgo must always be guarded with build tags.
11. Cgo is not Go.
12. With the unsafe package there are no guarantees.
13. Clear is better than clever.
14. Reflection is never clear.
15. Errors are values.
16. Don't just check errors, handle them gracefully.
17. Design the architecture, name the components, document the details.
18. Documentation is for users.
19. Don't panic.

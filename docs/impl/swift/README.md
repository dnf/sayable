# Swift Style Guide

A comprehensive reference for idiomatic Swift coding style and best practices. Intended for code auditing Swift implementations.

## Sources

This guide synthesizes conventions from the following authoritative references:

- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) -- the foundational naming and API design reference from Swift.org
- [Google Swift Style Guide](https://google.github.io/swift/) -- formatting, naming, and programming practices from Google's internal standard
- [Kodeco (Ray Wenderlich) Swift Style Guide](https://github.com/kodecocodes/swift-style-guide) -- community style guide emphasizing clarity, consistency, and brevity
- [Value and Reference Types (Swift.org)](https://www.swift.org/documentation/articles/value-and-reference-types.html) -- official guidance on structs vs classes
- [Choosing Between Structures and Classes (Apple)](https://developer.apple.com/documentation/swift/choosing-between-structures-and-classes) -- Apple's decision framework
- [The Swift Programming Language (Swift.org)](https://docs.swift.org/swift-book/) -- the language reference
- [SwiftLint](https://github.com/realm/SwiftLint) and its [Rule Directory](https://realm.github.io/SwiftLint/rule-directory.html)
- [SE-0413: Typed throws](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0413-typed-throws.md) -- Swift 6.0 typed error handling
- [SE-0386: `package` access modifier](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0386-package-access-modifier.md) -- Swift 5.9 package-level access control

---

## 1. Naming Conventions

### Casing Rules

| Element | Casing | Example |
|---|---|---|
| Types (structs, classes, enums, actors) | UpperCamelCase | `SayableAgeFormatter`, `AgeLocale` |
| Protocols | UpperCamelCase | `Collection`, `Equatable` |
| Functions, methods | lowerCamelCase | `formatAge(_:_:)`, `resolveUnit(_:_:_:)` |
| Properties, variables, constants | lowerCamelCase | `maxAgeMonths`, `delimiter` |
| Enum cases | lowerCamelCase | `case zero, one, two, few, many, other` |
| Generic type parameters | UpperCamelCase | `Element`, `Key`, `Value` |
| Global/static constants | lowerCamelCase | `let version = "0.5.0"` |

No Hungarian notation or prefix conventions. Swift uses module namespacing, not class prefixes.

### Acronyms and Initialisms

Treat acronyms uniformly according to their case position. When an acronym starts a lowerCamelCase name, it is all-lowercase. When it appears elsewhere or in UpperCamelCase, it is all-uppercase:

```swift
// Correct
var utf8Bytes: [UInt8]
var isRepresentableAsASCII: Bool
class HTMLParser { }
var urlString: String

// Wrong
var UTF8Bytes: [UInt8]
var isRepresentableAsAscii: Bool
class HtmlParser { }
```

### Protocols

Name protocols based on what they describe:

- **What something is** -- use a noun: `Collection`, `Sequence`, `IteratorProtocol`
- **What something can do** -- use the suffix `-able`, `-ible`, or `-ing`: `Equatable`, `Hashable`, `Sendable`, `ProgressReporting`

### Functions and Methods

- **Side-effect-free** methods read as noun phrases: `x.distance(to: y)`, `i.successor()`
- **Mutating** methods read as imperative verb phrases: `x.sort()`, `x.append(y)`
- **Factory methods** begin with `make`: `x.makeIterator()`
- **Boolean** methods and properties read as assertions: `x.isEmpty`, `line1.intersects(line2)`

### Mutating/Nonmutating Pairs

For verb-described operations, name the mutating variant with the imperative and the nonmutating variant with a past participle or present participle:

```swift
// Verb-based
x.sort()           // mutating
z = x.sorted()     // nonmutating (past participle: -ed)

x.stripNewlines()          // mutating (direct object)
t = x.strippingNewlines()  // nonmutating (present participle: -ing)

// Noun-based
x = y.union(z)      // nonmutating (noun)
y.formUnion(z)       // mutating (form- prefix)
```

### Arguments and Parameters

- **Name parameters for their role**, not their type: `greeting` not `string`, `supplier` not `widgetFactory`
- **Include all words needed to avoid ambiguity**: `employees.remove(at: x)` not `employees.remove(x)`
- **Omit needless words** that merely repeat type information: `allViews.remove(cancelButton)` not `allViews.removeElement(cancelButton)`
- **Compensate for weak type information** with descriptive nouns preceding weakly-typed parameters

### Argument Labels

- **Omit all labels** when arguments cannot be usefully distinguished: `min(number1, number2)`, `zip(sequence1, sequence2)`
- **Omit the first argument label** in value-preserving type conversions: `String(veryLargeNumber)`
- **Label narrowing conversions** descriptively: `init(truncating:)`, `init(saturating:)`
- **First argument forms a prepositional phrase** -- give it a label starting with the preposition: `x.removeBoxes(havingLength: 12)`
- **First argument forms part of a grammatical phrase** -- omit its label: `x.addSubview(y)`
- **Label all other arguments**

```swift
// Reads as natural English: "x, insert y at z"
x.insert(y, at: z)

// Do not form a phrase with the base name in initializers
Color(red: 32, green: 64, blue: 128)     // Correct
Color(havingRGBValuesRed: 32, ...)        // Wrong
```

### Generic Type Parameters

Use descriptive UpperCamelCase names when the parameter has a meaningful role (`Element`, `Key`, `Value`). Fall back to single uppercase letters (`T`, `U`, `V`) only when no meaningful relationship exists.

---

## 2. Code Formatting

### Indentation

- Use **spaces**, not tabs. Two spaces or four spaces per indent level -- pick one and be consistent across the project. The Kodeco guide recommends 2 spaces; the Google guide uses 2 spaces. Apple's standard library uses 2 or 4.
- Never mix tabs and spaces.

### Line Length

- **100 characters** maximum per the Google Swift Style Guide. Exceptions: URLs in comments, import statements, and generated code.
- The Kodeco guide suggests a softer 70-character guideline. Choose a limit and enforce it.

### Brace Style (K&R)

Opening braces appear on the same line as the declaration. Closing braces appear on their own line, aligned with the start of the statement:

```swift
public struct Formatter {
    func format() -> String {
        if condition {
            return value
        } else {
            return fallback
        }
    }
}
```

### Semicolons

Never use semicolons. Swift does not require them, and they add visual noise.

### One Statement Per Line

Place at most one statement per line. Single-statement guard clauses may remain on one line when short:

```swift
guard let value = value else { return nil }
```

### Import Ordering

Order imports in three groups, separated by blank lines, each group sorted lexicographically:

1. Module/submodule imports (standard library, system frameworks)
2. Individual declaration imports
3. `@testable` imports (test files only)

Prefer importing whole modules over individual declarations:

```swift
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

import Foundation

@testable import SayableAge  // test files only
```

Do not import both a framework and its parent when the parent re-exports it (e.g., `UIKit` includes `Foundation`).

### Horizontal Whitespace

- **Single space** around binary operators, assignment, arrows (`->`), and ampersands in protocol composition
- **Single space** after commas, colons in type annotations, and `//` comments
- **No space** around member access dots, range operators (`...`, `..<`), or inside empty argument lists

```swift
// Correct spacing
let range = 1...5
let result = a + b
func transform(_ input: String) -> Int
protocol Displayable: Hashable & Sendable

// No space around dots or ranges
view.bounds.width
array[0..<3]
```

### Trailing Commas

Use trailing commas in multiline collection literals. This produces cleaner diffs:

```swift
let keys = [
    "bufferSize",
    "compression",
    "encoding",
]
```

### Trailing Closures

- Single closure as the final parameter: always use trailing closure syntax
- Never write empty parentheses with a trailing closure: `map { $0 * 2 }` not `map() { $0 * 2 }`
- Multiple closure parameters: label all closures; do not use trailing syntax

### Parentheses

Do not wrap conditions in unnecessary parentheses:

```swift
// Correct
if user.isActive { }
while count > 0 { }

// Wrong
if (user.isActive) { }
while (count > 0) { }
```

---

## 3. Type System

### Structs vs. Classes

**Default to structs.** Use classes only when you need reference semantics or features exclusive to classes (subclassing, `deinit`).

| Use a struct when... | Use a class when... |
|---|---|
| The type models data without identity | Shared mutable state is genuinely needed |
| Value equality is the natural comparison | You need reference identity (`===`) |
| You want predictable copy semantics | You need inheritance or `deinit` |
| The type is small and short-lived | You need to conform to `AnyObject`-constrained protocols |

Swift's `Array`, `Dictionary`, `String`, and `Set` are all value types. Structs compose cleanly -- a struct containing only value types automatically has value semantics.

### Enums

Use enums for:

- **Fixed sets of cases**: `PluralCategory`, `Compactness`
- **Associated values**: when each case carries different data
- **Caseless enums as namespaces**: for grouping static members without allowing instantiation

```swift
// Fixed cases
public enum PluralCategory: Sendable {
    case zero, one, two, few, many, other
}

// Associated values
public enum UnitForms: Sendable {
    case simple(String)
    case plural([PluralCategory: String])
}

// Namespace (caseless enum)
enum Constants {
    static let maxRetries = 3
    static let timeout: TimeInterval = 30
}
```

Enum cases use `lowerCamelCase`. Place one case per line unless all cases are trivially simple (no associated values, no raw values, no docs needed) and fit on one line.

### Generics

Prefer generic constraints over casting:

```swift
// Preferred: constrained generic
func process<T: Encodable>(_ value: T) -> Data { ... }

// Avoid: runtime casting
func process(_ value: Any) -> Data {
    guard let encodable = value as? Encodable else { fatalError() }
    ...
}
```

Use `where` clauses for complex constraints, placing them on a new line when they are long:

```swift
func merge<S: Sequence>(_ sequences: S...) -> [S.Element]
    where S.Element: Comparable
{
    ...
}
```

### Opaque Types and `some`

Use opaque return types (`some Protocol`) when you want to hide the concrete type while preserving type identity:

```swift
func makeFormatter() -> some Formatter {
    ConcreteFormatter()
}
```

Use `any Protocol` (existential) when you need type erasure and do not care about the concrete type:

```swift
func formatters() -> [any Formatter] {
    [EnglishFormatter(), FrenchFormatter()]
}
```

Prefer `some` over `any` when possible -- it enables the compiler to optimize and preserves type information.

### Shorthand Type Syntax

Use shorthand for arrays, dictionaries, and optionals:

```swift
// Preferred
var names: [String]
var lookup: [String: Int]
var result: String?

// Avoid
var names: Array<String>
var lookup: Dictionary<String, Int>
var result: Optional<String>
```

### Void

In function declarations, omit `Void` return types entirely. In closure type signatures, write `Void` explicitly rather than `()`:

```swift
// Function: omit Void
func reset() { }

// Closure type: write Void
let completion: (Result<Data, Error>) -> Void
```

---

## 4. Optionals

### Optional Binding (`if let` / `if var`)

Use optional binding to safely unwrap optionals. Swift 5.7+ allows the shorthand form:

```swift
// Shorthand (Swift 5.7+)
if let name {
    print(name)
}

// Explicit binding (when renaming)
if let userName = response.user?.name {
    print(userName)
}
```

### `guard let` for Early Exit

Use `guard` to unwrap optionals that are required for the rest of the function. This keeps the "happy path" unindented:

```swift
func formatAge(_ dateOfBirth: String?, _ asOf: String? = nil) -> String? {
    guard let age = Self.parseAge(dateOfBirth, asOf) else { return nil }

    let months = age.months
    let diffDays = age.diffDays
    // ... happy path continues at top indentation level
}
```

### Nil-Coalescing Operator (`??`)

Use `??` to provide default values:

```swift
let name = user.nickname ?? user.fullName ?? "Unknown"
let template = forms[cat] ?? forms[.other] ?? "{n}"
```

### Optional Chaining

Chain optional access to avoid nested `if let` pyramids:

```swift
let city = user?.address?.city
let count = response?.data?.items?.count ?? 0
```

### Force Unwrapping (`!`)

**Avoid force unwraps in production code.** They crash on `nil` and provide no recovery path.

Acceptable exceptions:
- Unit tests where a `nil` value indicates a test infrastructure failure
- Immediately after a check that guarantees non-nil (prefer `guard let` instead)
- When force-unwrapping, add a comment explaining why it is safe

```swift
// In tests: acceptable
let result = formatter.formatAge("2020-01-15", "2020-02-15")!
XCTAssertEqual(result, "1 month")

// In production: avoid
let name = user.name!  // Crashes if nil -- use guard let instead
```

### Implicitly Unwrapped Optionals (`Type!`)

Use sparingly and only when:

- A property is initialized shortly after construction and is always non-nil thereafter (e.g., `@IBOutlet` in UIKit)
- Test fixtures initialized in `setUp()`
- Two-phase initialization patterns where the compiler cannot prove non-nil status

Never let implicitly unwrapped optionals propagate through multiple abstraction layers.

---

## 5. Protocol-Oriented Programming

### Protocol Extensions with Default Implementations

Provide default implementations in protocol extensions to share behavior without inheritance:

```swift
protocol Formattable {
    func format() -> String
}

extension Formattable {
    func formatUppercased() -> String {
        format().uppercased()
    }
}
```

### Protocol Composition

Combine protocols with `&` to express compound requirements:

```swift
func process(_ value: Encodable & Sendable) { ... }

typealias SerializableLocale = AgeLocale & Codable & Sendable
```

### Organize Conformances in Extensions

Place each protocol conformance in its own extension, separated by `// MARK: -` comments. This keeps conformance methods grouped and visible in Xcode's navigation bar:

```swift
struct AgeFormatter {
    // Core properties and methods
}

// MARK: - CustomStringConvertible

extension AgeFormatter: CustomStringConvertible {
    var description: String { ... }
}

// MARK: - Equatable

extension AgeFormatter: Equatable {
    static func == (lhs: AgeFormatter, rhs: AgeFormatter) -> Bool { ... }
}
```

### Protocol Witnesses vs. Protocol Types

Prefer concrete protocol conformances (static dispatch) over existential types (dynamic dispatch) for performance:

```swift
// Static dispatch: preferred when the concrete type is known
func format<L: LocaleProvider>(_ locale: L) -> String { ... }

// Dynamic dispatch: use when you need heterogeneous collections
func format(_ locale: any LocaleProvider) -> String { ... }
```

### Conditional Conformance

Use conditional conformance to extend generic types when their elements meet requirements:

```swift
extension Array: Formattable where Element: Formattable {
    func format() -> String {
        map { $0.format() }.joined(separator: ", ")
    }
}
```

---

## 6. Error Handling

### `throws` and `do/try/catch`

Use Swift's throwing mechanism for recoverable errors. Define error types as enums conforming to `Error`:

```swift
enum FormatError: Error {
    case invalidDate(String)
    case dateInFuture
    case ageTooLarge(months: Int)
}

func parseDate(_ string: String) throws -> DateComponents {
    guard string.count >= 10 else {
        throw FormatError.invalidDate(string)
    }
    // ...
}

do {
    let components = try parseDate(input)
} catch FormatError.invalidDate(let raw) {
    print("Bad date: \(raw)")
} catch {
    print("Unexpected error: \(error)")
}
```

### `try?` and `try!`

- `try?` converts a thrown error to `nil`. Use when you want to ignore the error and treat failure as absence:

```swift
let date = try? parseDate(input)  // nil on failure
```

- `try!` force-unwraps the result. Use only when failure is impossible (e.g., parsing a compile-time constant). Document why:

```swift
// Safe: literal is known-valid at compile time
let regex = try! NSRegularExpression(pattern: "^\\d{4}-\\d{2}-\\d{2}$")
```

### `Result` Type

Use `Result<Success, Failure>` when you need to capture success or failure for deferred handling, or when passing results across asynchronous boundaries without `async/await`:

```swift
func validate(_ input: String) -> Result<ParsedDate, FormatError> {
    guard let date = try? parseDate(input) else {
        return .failure(.invalidDate(input))
    }
    return .success(date)
}

switch validate(userInput) {
case .success(let date):
    process(date)
case .failure(let error):
    displayError(error)
}
```

### Typed Throws (Swift 6.0+)

SE-0413 allows specifying the exact error type a function can throw:

```swift
enum CopierError: Error {
    case outOfPaper
}

func copy(count: Int) throws(CopierError) {
    guard count <= pagesRemaining else {
        throw .outOfPaper  // shorthand: type inferred
    }
    pagesRemaining -= count
}

// Catch is exhaustive -- no catch-all needed
do {
    try copy(count: 10)
} catch .outOfPaper {
    refillPaper()
}
```

**When to use typed throws:**

- Embedded Swift or performance-critical paths where error type predictability matters
- Closed error domains where the set of possible errors is fixed and small
- Generic functions that propagate closure errors: `func map<E>(_ transform: (Element) throws(E) -> T) throws(E) -> [T]`

**When to use untyped `throws`:**

- Library APIs where the error set may expand in future versions
- Most application code -- untyped throws remains the default recommendation
- When wrapping calls to other throwing functions with different error types

### Prefer `nil` Over Throwing for Simple Absence

When a function's only failure mode is "value not found," returning an optional is more idiomatic than throwing:

```swift
// Idiomatic: nil means "not found"
func formatAge(_ dateOfBirth: String?, _ asOf: String? = nil) -> String?

// Overkill for simple absence
func formatAge(_ dateOfBirth: String?, _ asOf: String? = nil) throws -> String
```

---

## 7. Value Types vs. Reference Types

### Default to Structs

From [Swift.org](https://www.swift.org/documentation/articles/value-and-reference-types.html): "In general, prefer to use structs over classes. If you don't need the behavior of a reference type, there's no need to take on the added complexity and pitfalls."

Value types enable **local reasoning** -- you can understand a value's behavior by looking at the code that uses it, without worrying about distant mutations through shared references.

```swift
// Value type: each variable gets its own copy
struct Document {
    var text: String
}

var myDoc = Document(text: "Original")
var copy = myDoc
copy.text = "Modified"
print(myDoc.text)  // "Original" -- unaffected
```

### When Classes Are Appropriate

- **Shared mutable state**: when multiple parts of the program must observe and mutate the same instance
- **Identity matters**: when you need `===` identity checks
- **Inheritance**: when you need a class hierarchy (prefer protocols and composition first)
- **Deinitializers**: when you need cleanup on deallocation (`deinit`)
- **Objective-C interop**: when bridging to `@objc` APIs

### Copy-on-Write (CoW)

Swift's standard library collections (`Array`, `Dictionary`, `Set`, `String`) use copy-on-write internally: copies share storage until one copy is mutated. This makes value semantics efficient.

When implementing your own large value types that wrap a reference-type buffer, implement CoW manually:

```swift
struct LargeData {
    private var storage: StorageRef

    mutating func update(_ value: Int) {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
        storage.data = value
    }
}
```

### Actors for Concurrent Reference State

When you need shared mutable state in a concurrent context, prefer `actor` over `class` with manual synchronization:

```swift
actor FormatterCache {
    private var cache: [String: SayableAgeFormatter] = [:]

    func formatter(for localeCode: String) -> SayableAgeFormatter {
        if let cached = cache[localeCode] { return cached }
        let formatter = SayableAgeFormatter(locale(for: localeCode))
        cache[localeCode] = formatter
        return formatter
    }
}
```

---

## 8. Access Control

Swift provides six access levels, from most restrictive to most open:

| Level | Scope |
|---|---|
| `private` | Enclosing declaration only (including extensions in the same file) |
| `fileprivate` | Entire source file |
| `internal` (default) | Entire module |
| `package` (Swift 5.9+) | Entire package (all modules within the same SwiftPM package) |
| `public` | Any module that imports this one; cannot be subclassed/overridden externally |
| `open` | Any module; can be subclassed and overridden externally |

### Guidelines

- **Start restrictive, widen as needed.** Default to `private` for implementation details. Promote to `internal`, `package`, or `public` only when external access is required.
- **Omitting the access modifier** defaults to `internal`. This is acceptable for module-internal code but be explicit for anything at the module boundary.
- **Use `public` for library APIs.** Use `open` only when subclassing is an intentional extension point.
- **Use `private` over `fileprivate`** unless you need access from an extension in the same file that cannot see `private` members. Since Swift 4, `private` is visible to extensions of the same type in the same file, which reduces the need for `fileprivate`.
- **Use `package`** (SE-0386, Swift 5.9+) to share APIs between modules within the same SwiftPM package without exposing them to external consumers.
- **Do not use naming conventions** (leading underscores) as a substitute for access control. Use the language's access modifiers.

```swift
public struct SayableAgeFormatter: Sendable {
    public static let version = "0.5.0"

    private static let maxAgeMonths = 6000

    private let locale: AgeLocale
    private let day: UnitForms

    public init(_ locale: AgeLocale, compactness: Compactness = .normal) { ... }

    public func formatAge(_ dateOfBirth: String?, _ asOf: String? = nil) -> String? { ... }

    private func resolveUnit(_ count: Int, _ uf: UnitForms, _ half: String) -> String { ... }
}
```

### Extensions and Access Control

Do not specify access levels on the extension itself. Instead, specify access on each member:

```swift
// Preferred: access on members
extension SayableAgeFormatter {
    public static func formatAgeDefault(_ dob: String?, _ asOf: String? = nil) -> String? { ... }
    private static func parseAge(_ dob: String?, _ asOf: String?) -> AgeComponents? { ... }
}

// Avoid: access on extension
public extension SayableAgeFormatter {
    static func formatAgeDefault(...) -> String? { ... }
}
```

---

## 9. Common Idioms

### `guard` Statements

Use `guard` for early exits and precondition checks. This keeps the happy path at the top indentation level and avoids the "pyramid of doom":

```swift
func process(_ input: String?) -> Result {
    guard let input, !input.isEmpty else { return .empty }
    guard input.count >= 10 else { return .tooShort }

    // Main logic at top level
    let parsed = parse(input)
    return .success(parsed)
}
```

### `defer`

Use `defer` for cleanup that must happen regardless of how a scope exits:

```swift
func readFile(at path: String) throws -> String {
    let handle = try openFile(path)
    defer { closeFile(handle) }

    let contents = try readAll(handle)
    return contents
}
```

`defer` blocks execute in reverse order of their declaration. Prefer a single `defer` near the resource acquisition.

### `where` Clauses

Use `where` on `for` loops to fold simple conditions into the loop header:

```swift
// Preferred: where clause
for item in collection where item.isActive {
    process(item)
}

// Avoid: if-only body
for item in collection {
    if item.isActive {
        process(item)
    }
}
```

Use `where` in `switch` cases for conditional matching:

```swift
switch value {
case let x where x < 0:
    handleNegative(x)
case 0:
    handleZero()
case let x:
    handlePositive(x)
}
```

### Pattern Matching

Use pattern matching in `switch`, `if case`, `guard case`, and `for case`:

```swift
// Enum pattern matching with associated values
switch unitForms {
case .simple(let template):
    return template
case .plural(let forms):
    let cat = locale.plural(count)
    return forms[cat] ?? forms[.other] ?? "{n}"
}

// Optional pattern in for loops
for case let item? in optionalArray {
    process(item)
}

// Tuple pattern matching
switch (x, y) {
case (0, 0): return .origin
case (_, 0): return .onXAxis
case (0, _): return .onYAxis
case let (x, y): return .point(x, y)
}
```

### Key Paths

Use key paths for property references and as shorthand in closures:

```swift
let names = people.map(\.name)
let sorted = items.sorted(by: \.priority)
let adults = people.filter(\.isAdult)
```

### Property Wrappers

Property wrappers attach reusable logic to property declarations. Define them with `@propertyWrapper`:

```swift
@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>

    var wrappedValue: Value {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

struct Settings {
    @Clamped(0...100) var volume: Int = 50
}
```

Keep property wrappers focused on a single responsibility and document their behavior.

### Computed Properties

Use the shorthand getter when there is no setter:

```swift
// Read-only computed property: omit get { }
var isEmpty: Bool {
    count == 0
}

// Read-write: use get/set
var diameter: Double {
    get { radius * 2 }
    set { radius = newValue / 2 }
}
```

### `Sendable` and Concurrency

Mark types as `Sendable` when they are safe to share across concurrency boundaries. Value types composed entirely of `Sendable` members are implicitly `Sendable`, but explicitly marking the conformance documents the intent:

```swift
public struct AgeLocale: Sendable { ... }
public enum PluralCategory: Sendable { ... }
```

---

## 10. Things to Avoid

### Force Unwraps in Production Code

Force unwraps (`!`) crash on `nil`. Use `guard let`, `if let`, or `??` instead. Reserve `!` for tests and compile-time-known values (with a comment explaining safety).

### Implicitly Unwrapped Optionals

Use `Type!` only for two-phase initialization (IBOutlets, test fixtures). Never propagate them through multiple layers.

### `Any` and `AnyObject`

Avoid untyped containers. They discard type information and require runtime casting:

```swift
// Avoid
var items: [Any] = [1, "hello", true]
let value = items[0] as! Int

// Prefer: use generics or protocols
var items: [CustomStringConvertible] = [1, "hello", true]
```

### Stringly-Typed Code

Use enums or dedicated types instead of raw strings for status codes, keys, or identifiers:

```swift
// Avoid
func setStage(_ stage: String) { }
setStage("newborn")

// Prefer
func setStage(_ stage: Stage) { }
setStage(.newborn)
```

### Unnecessary `self`

Omit `self` when not required by the compiler. Swift only requires `self` in closures that capture it and in initializers to disambiguate from parameters:

```swift
init(name: String) {
    self.name = name  // Required: disambiguate parameter from property
}

func reset() {
    count = 0  // self is implied -- do not write self.count
}
```

### C-Style `for` Loops

Swift removed C-style `for` loops. Use `for-in` with ranges:

```swift
for i in 0..<count { ... }
for i in stride(from: 0, to: 100, by: 5) { ... }
```

### Empty Catch Blocks

Never silently swallow errors. At minimum, log or assert:

```swift
// Wrong
do { try operation() } catch { }

// Right
do {
    try operation()
} catch {
    assertionFailure("Unexpected error: \(error)")
}
```

### Deeply Nested Code

Excessive nesting harms readability. Use `guard` for early exits, extract helper functions, and prefer flat control flow.

### Magic Numbers

Extract numeric literals into named constants:

```swift
// Avoid
if months < 84 { ... }

// Prefer
private static let maxAgeMonths = 6000
private static let halfMarkerThresholdMonths = 84
```

### `fallthrough` in Switch

Avoid `fallthrough`. It carries meaning from C but is rarely idiomatic in Swift. Use comma-separated cases for shared behavior:

```swift
// Preferred: comma-separated
switch month {
case 1, 3, 5, 7, 8, 10, 12: return 31
case 4, 6, 9, 11: return 30
case 2: return isLeapYear(y) ? 29 : 28
default: return 30
}
```

### Mutable Global State

Avoid mutable global or static variables. They create hidden coupling and break testability. If needed for testing (like a time override), document the purpose clearly and mark appropriately:

```swift
// Testing hook -- not for production use
@usableFromInline
nonisolated(unsafe) static var _timeNow: () -> (Int, Int, Int) = { ... }
```

---

## 11. Tooling

### SwiftLint

[SwiftLint](https://github.com/realm/SwiftLint) enforces Swift style and conventions. Configure it with a `.swiftlint.yml` file in the project root.

**Key default rules:**

| Rule | What it enforces |
|---|---|
| `line_length` | Maximum line length (default 120 warning, 200 error) |
| `type_body_length` | Maximum type body length |
| `function_body_length` | Maximum function body length |
| `cyclomatic_complexity` | Limits branching complexity |
| `force_cast` | Warns on `as!` |
| `force_unwrapping` | Warns on `!` force unwraps |
| `unused_closure_parameter` | Flags unused closure parameters |
| `trailing_whitespace` | No trailing whitespace |
| `opening_brace` | Opening brace spacing |
| `colon` | Colon spacing (no space before, one after) |
| `comma` | Comma spacing |
| `control_statement` | No parentheses around conditions |

**Valuable opt-in rules** (from [SwiftLee](https://www.avanderlee.com/optimization/swiftlint-optin-rules/)):

| Rule | What it enforces |
|---|---|
| `empty_count` | Use `.isEmpty` instead of `.count == 0` |
| `empty_string` | Use `.isEmpty` instead of `== ""` |
| `first_where` | Use `.first(where:)` instead of `.filter { }.first` |
| `fatal_error_message` | Require messages in `fatalError()` calls |
| `modifier_order` | Consistent modifier ordering |
| `toggle_bool` | Use `.toggle()` for boolean flip |
| `convenience_type` | Use caseless enums for static-only containers |
| `unused_private_declaration` | Flag unused private declarations |

### swift-format

Apple's [swift-format](https://github.com/swiftlang/swift-format) is an official formatting tool. It handles indentation, brace placement, spacing, and other mechanical formatting. It can be run as a formatter (`swift-format format`) or a linter (`swift-format lint`).

Configure via a `.swift-format` configuration file:

```json
{
  "version": 1,
  "indentation": { "spaces": 4 },
  "lineLength": 100,
  "maximumBlankLines": 1,
  "respectsExistingLineBreaks": true,
  "indentConditionalCompilationBlocks": true
}
```

SwiftLint and swift-format can complement each other: swift-format handles mechanical formatting while SwiftLint covers style and correctness rules.

### Xcode Warnings

- Build with **all warnings enabled** and treat warnings as errors in CI
- Do not suppress warnings without a documented justification
- Address deprecation warnings promptly

### Swift Compiler Diagnostics

The Swift compiler provides increasingly sophisticated diagnostics:

- **Strict concurrency checking**: Enable in Swift 6 mode or with `-strict-concurrency=complete` for pre-migration. This catches data races at compile time.
- **Sendable checking**: The compiler warns when non-Sendable types cross concurrency boundaries.
- **Exhaustive switch checking**: The compiler requires all enum cases to be handled (or a `default` clause).
- **Unused result warnings**: Functions marked `@discardableResult` suppress the warning; otherwise the compiler flags ignored return values.

### MARK Comments

Use `// MARK: -` to organize code sections. These appear in Xcode's navigation bar and help readers scan large files:

```swift
// MARK: - Properties

// MARK: - Initialization

// MARK: - Public API

// MARK: - Private Helpers
```

---

## Quick Reference Checklist

For auditing a Swift implementation, verify:

- [ ] Types use UpperCamelCase; everything else uses lowerCamelCase
- [ ] Enum cases are lowerCamelCase
- [ ] Acronyms follow uniform casing rules (`utf8`, `HTMLParser`)
- [ ] Functions with side effects read as imperative verbs; without, as nouns
- [ ] Mutating/nonmutating pairs follow `-ed`/`-ing` or `form-` conventions
- [ ] Arguments are labeled for clarity at the call site
- [ ] Braces follow K&R style (opening on same line)
- [ ] No semicolons
- [ ] No unnecessary parentheses around conditions
- [ ] Imports are ordered and minimal
- [ ] Structs are used by default; classes only when reference semantics are needed
- [ ] Optionals are unwrapped safely (`guard let`, `if let`, `??`)
- [ ] No force unwraps in production code (or justified with a comment)
- [ ] No implicitly unwrapped optionals except for two-phase initialization
- [ ] `Any`/`AnyObject` is not used where generics or protocols would work
- [ ] Protocol conformances are organized in separate extensions
- [ ] Error types are enums conforming to `Error`
- [ ] `guard` is used for early exits; happy path is not deeply nested
- [ ] Access control starts restrictive (`private`) and widens as needed
- [ ] No mutable global state (or documented testing hooks only)
- [ ] `Sendable` is marked on types shared across concurrency boundaries
- [ ] No empty catch blocks
- [ ] No magic numbers -- constants are named
- [ ] `self` is omitted when not required
- [ ] Comments explain "why", not "what"
- [ ] SwiftLint or swift-format is configured and passing

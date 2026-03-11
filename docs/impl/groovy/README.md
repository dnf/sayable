# Groovy Style Guide

A practical style guide for writing idiomatic, maintainable Groovy code. Designed for code auditing.

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Groovy-Specific Features](#3-groovy-specific-features)
4. [Type System](#4-type-system)
5. [Class Design](#5-class-design)
6. [Collections](#6-collections)
7. [Error Handling](#7-error-handling)
8. [String Handling](#8-string-handling)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)

---

## 1. Naming Conventions

### Classes

Use `UpperCamelCase`. The name should match the file name.

```groovy
class AgeFormatter { }
class HttpClientFactory { }
```

CodeNarc enforces: `([A-Z]\w*\$?)*`

Abstract classes may optionally use an `Abstract` prefix when the class name would be ambiguous without it, but prefer a descriptive name that stands on its own.

### Interfaces

Use `UpperCamelCase`, same as classes. Do not prefix with `I` (that is a C#/.NET convention, not idiomatic in Groovy/JVM).

```groovy
interface Formattable { }
interface PluralResolver { }
```

### Methods

Use `lowerCamelCase`. Start with a verb or verb phrase that describes the action.

```groovy
String formatAge(String dateOfBirth) { }
int calculateMonths(LocalDate from, LocalDate to) { }
private boolean isValidDate(String input) { }
```

CodeNarc enforces: `[a-z]\w*`

Test methods may use quoted strings with spaces for readability (Groovy allows this):

```groovy
@Test
void 'empty string returns null'() { }

@Test
void 'future dob returns null'() { }
```

### Variables and Parameters

Use `lowerCamelCase`. Prefer descriptive names over abbreviations.

```groovy
String dateOfBirth
int diffDays
AgeLocale locale
```

CodeNarc enforces: `[a-z][a-zA-Z0-9]*`

Single-letter names are acceptable only for loop counters (`i`, `j`), closure parameters where context is obvious (`it` or short lambdas), and well-known conventions (`n` for count, `e` for exception).

### Constants

Use `UPPER_SNAKE_CASE` for `static final` fields.

```groovy
static final String VERSION = "0.5.0"
private static final int MAX_AGE_MONTHS = 6000
```

CodeNarc enforces: `[A-Z][A-Z0-9_]*` for static final fields.

### Packages

Use all lowercase with dots as separators. No underscores, no camelCase.

```groovy
package sayableage
package com.example.util
```

CodeNarc enforces: `[a-z]+[a-z0-9]*(\.[a-z0-9]+)*`

### Closures

When stored in a variable, use `lowerCamelCase` and name them as nouns or verb phrases describing what they compute.

```groovy
def formatNumber = { int n -> /* ... */ }
Closure<PluralCategory> plural = { int count -> /* ... */ }
```

---

## 2. Code Formatting

### Indentation

Use 4 spaces per level. Never use tabs.

```groovy
class Formatter {
    String format(int count) {
        if (count > 0) {
            return resolve(count)
        }
        return null
    }
}
```

### Braces

Opening braces go on the same line as the declaration (K&R / "One True Brace Style"). Closing braces go on their own line.

```groovy
// Good
class Formatter {
    String format(int count) {
        if (count > 0) {
            return resolve(count)
        } else {
            return null
        }
    }
}

// Bad: opening brace on its own line
class Formatter
{
    // ...
}
```

### Line Length

Keep lines to 120 characters or fewer. Locale data files are an expected exception.

### Spacing

Put a single space:

- After keywords (`if`, `for`, `while`, `switch`, `catch`) and before opening parenthesis
- Before opening braces
- After commas
- Around binary operators (`=`, `==`, `+`, `-`, `&&`, `||`, etc.)
- Around the closure arrow (`->`)
- After opening braces and before closing braces in single-line blocks

```groovy
// Good
if (count > 0) {
    return resolveUnit(count, day, locale, '')
}

list.each { item -> println item }

def result = a + b

// Bad
if(count>0){
    return resolveUnit(count,day,locale,'')
}
```

No space:

- Between method name and opening parenthesis in declarations or calls
- After `!` operator
- Inside parentheses

```groovy
// Good
formatAge(dateOfBirth, asOf)
if (!valid) { }

// Bad
formatAge (dateOfBirth, asOf)
if (! valid) { }
```

### Blank Lines

- One blank line between methods
- One blank line after import statements
- One blank line after the opening brace of a class (before the first member)
- No blank line immediately after an opening brace of a method/block or before a closing brace
- No consecutive blank lines

### Import Ordering

Group imports in this order, separated by blank lines:

1. `java.*` / `javax.*`
2. Third-party libraries
3. `groovy.*` / Groovy-specific
4. Project-internal packages

Within each group, sort alphabetically. Prefer explicit imports over star imports.

```groovy
import java.time.LocalDate
import java.time.temporal.ChronoUnit

import groovy.transform.CompileStatic

import sayableage.locales.Locales
```

---

## 3. Groovy-Specific Features

### GStrings (String Interpolation)

Use double quotes with `${}` for interpolation. Use simple `$variable` only for unambiguous standalone references. Prefer `${}` for anything involving method calls, property chains, or expressions.

```groovy
// Good
def greeting = "Hello ${name}"
def message = "Found ${results.size()} items"
def simple = "Value is $count"

// Bad: using concatenation when interpolation is clearer
def greeting = "Hello " + name
```

See [Section 8: String Handling](#8-string-handling) for the full string type reference.

### Closures

Closures are a core Groovy feature. Use them for callbacks, higher-order functions, and DSL-style code.

```groovy
// Single-parameter closure (implicit 'it')
list.each { println it }

// Named parameter (prefer this for clarity when logic is non-trivial)
list.each { item -> println item }

// Multi-parameter closure
map.each { key, value -> println "${key}: ${value}" }
```

When a closure is the last argument to a method, place it outside the parentheses:

```groovy
// Good
list.collect { it * 2 }
list.findAll { it > 3 }

// Acceptable but less idiomatic
list.collect({ it * 2 })
```

When there are no other arguments, omit parentheses entirely:

```groovy
list.each { println it }
```

Prefer explicit parameter names over the implicit `it` when the closure body is more than a single simple expression, or when `it` would be ambiguous:

```groovy
// Fine: simple one-liner
names.collect { it.toUpperCase() }

// Better: explicit name for multi-line or complex logic
people.findAll { person ->
    person.age >= 18 && person.name.startsWith('A')
}
```

### Safe Navigation Operator (`?.`)

Use `?.` to safely traverse object graphs that may contain nulls. This returns `null` if any intermediate value is null, preventing `NullPointerException`.

```groovy
String city = order?.customer?.address?.city
```

Do not overuse it as a substitute for proper null checking at boundaries. Use it for traversal, not to mask design problems.

### Elvis Operator (`?:`)

A concise default-value operator. The left side is returned if truthy (non-null, non-empty, non-zero); otherwise the right side.

```groovy
// Good
String displayName = user.name ?: 'Anonymous'

// Equivalent long form (avoid this when Elvis is clearer)
String displayName = user.name != null ? user.name : 'Anonymous'
```

### Elvis Assignment Operator (`?=`)

Groovy 3.0+. Assigns a value only if the left side is currently falsy.

```groovy
config.timeout ?= 30
```

### Spread Operator (`*.`)

Invokes a method or accesses a property on every element of a collection. It is null-safe.

```groovy
def names = people*.name           // equivalent to people.collect { it.name }
def lengths = ['one', 'two']*.size()  // [3, 3]
```

Use it for simple property/method access. For more complex transformations, prefer `collect` with a closure.

### Spaceship Operator (`<=>`)

Delegates to `compareTo`. Returns -1, 0, or 1. Useful in sort closures.

```groovy
people.sort { a, b -> a.lastName <=> b.lastName }
```

### Method Pointer Operator (`.&`) and Method Reference (`::`)

Convert a method into a closure for use as a first-class function.

```groovy
def upper = 'example'.&toUpperCase
assert upper() == 'EXAMPLE'

// Method reference (Groovy 3+)
[1G, 2G, 3G].stream().reduce(0G, BigInteger::add)
```

### Range Operator (`..` and `..<`)

Creates inclusive or exclusive ranges.

```groovy
def inclusive = 1..10    // 1 to 10
def exclusive = 1..<10   // 1 to 9

for (i in 1..5) { println i }
```

### Membership Operator (`in`)

Tests whether a value is contained in a collection, range, or anything with a `contains` or `isCase` method.

```groovy
if (status in ['active', 'pending']) { }
if (age in 13..19) { }
```

### Identity (`is` / `===`)

Groovy's `==` calls `equals()` (with null safety). To test reference identity, use `is()` or `===`.

```groovy
assert list1 == list2       // value equality
assert !list1.is(list2)     // different references
assert list1 !== list2      // shorthand for negated identity
```

---

## 4. Type System

### `def` vs Explicit Types

**Public API boundaries** (public method signatures, public fields, constructor parameters) should always use explicit types. This improves documentation, IDE support, and compile-time checking.

```groovy
// Good: explicit types on public API
class Formatter {
    String formatAge(String dateOfBirth, String asOf) { }
    int calculateMonths(LocalDate from, LocalDate to) { }
}

// Bad: def on public API hides the contract
class Formatter {
    def formatAge(def dateOfBirth, def asOf) { }
}
```

**Local variables** may use `def` when the type is obvious from context:

```groovy
def parts = dateString.split('-')   // obviously String[]
def count = items.size()            // obviously int
```

But prefer explicit types when the type is not immediately apparent or when it improves readability.

**Never combine `def` with an explicit type.** This is a syntax error in intent, even though Groovy allows it:

```groovy
// Wrong
def String name = "Guillaume"

// Correct
String name = "Guillaume"
```

**Untyped method parameters do not need `def`:**

```groovy
// Good
void doSomething(param1, param2) { }

// Bad: unnecessary def
void doSomething(def param1, def param2) { }
```

### `@CompileStatic`

Apply `@CompileStatic` to library code and performance-critical code. It enables compile-time type checking and generates faster bytecode by bypassing the Groovy Meta-Object Protocol (MOP).

```groovy
@CompileStatic
class AgeCalculator {
    int monthsBetween(LocalDate from, LocalDate to) {
        // compile-time verified, faster execution
    }
}
```

Use `@CompileDynamic` on specific methods that need dynamic features within an otherwise `@CompileStatic` class:

```groovy
@CompileStatic
class Service {
    String process(String input) { /* ... */ }

    @CompileDynamic
    def dynamicMethod() {
        // needs runtime dispatch
    }
}
```

### `@TypeChecked`

Like `@CompileStatic` but only performs type checking without changing the compilation strategy. Methods still go through dynamic dispatch at runtime. Use `@CompileStatic` when you want both type safety and performance; use `@TypeChecked` when you need type safety but must preserve dynamic dispatch behavior.

```groovy
@TypeChecked
class Validator {
    boolean isValid(String input) {
        input.length() > 0  // type-checked at compile time
    }
}
```

Skip type checking on specific methods:

```groovy
@TypeChecked
class Service {
    @TypeChecked(TypeCheckingMode.SKIP)
    def builderDsl() {
        // dynamic DSL code
    }
}
```

### Flow Typing

Groovy's type checker performs flow typing -- a variable's inferred type changes as it is reassigned:

```groovy
@TypeChecked
void example() {
    def o = 'foo'
    o = o.toUpperCase()    // o is String here
    o = 9d
    o = Math.sqrt(o)       // o is double here
}
```

---

## 5. Class Design

### POGOs (Plain Old Groovy Objects)

Groovy auto-generates getters and setters for properties (fields without explicit visibility modifiers). Omit the `public` keyword on classes and methods (it is the default). Only add visibility modifiers when restricting access.

```groovy
// Good: idiomatic POGO
class Person {
    String firstName
    String lastName
    int age
}

// The above automatically has getFirstName(), setFirstName(), etc.
// Access using property syntax:
def p = new Person(firstName: 'Ada', lastName: 'Lovelace', age: 36)
println p.firstName   // calls getFirstName()
```

### Named Parameter Construction

Groovy provides a default map-based constructor for POGOs. Use named parameters for clarity:

```groovy
def server = new Server(name: "Obelix", cluster: aCluster, port: 8080)
```

### `@Canonical`

A meta-annotation combining `@ToString`, `@EqualsAndHashCode`, and `@TupleConstructor`. Use it for simple data classes.

```groovy
@Canonical
class Point {
    int x
    int y
}

def p1 = new Point(1, 2)
def p2 = new Point(x: 1, y: 2)
assert p1 == p2
println p1  // Point(1, 2)
```

### `@Immutable`

Creates immutable value objects with defensive copying and unmodifiable collections. Combines `@ToString`, `@EqualsAndHashCode`, and constructor generation. All fields become final.

```groovy
@Immutable
class Color {
    String name
    int red, green, blue
}

def c = new Color(name: 'white', red: 255, green: 255, blue: 255)
// c.name = 'black'  // throws ReadOnlyPropertyException
```

### `@ToString`

Generates a `toString()` method. Commonly used options:

```groovy
@ToString(includeNames = true, excludes = ['password'])
class User {
    String name
    String email
    String password
}

println new User(name: 'Ada', email: 'ada@example.com', password: 'secret')
// User(name:Ada, email:ada@example.com)
```

### `@EqualsAndHashCode`

Generates `equals()` and `hashCode()` following effective Java practices:

```groovy
@EqualsAndHashCode(excludes = ['id'])
class Person {
    long id
    String firstName
    String lastName
}
```

### `@TupleConstructor`

Generates positional constructors with one parameter per property:

```groovy
@TupleConstructor
class Person {
    String firstName
    String lastName
}

def p = new Person('Ada', 'Lovelace')
```

### `@Builder`

Enables fluent builder-style construction:

```groovy
@Builder
class Person {
    String first
    String last
    int born
}

def p = Person.builder().first('Ada').last('Lovelace').born(1815).build()
```

### `@Sortable`

Implements `Comparable` with property-based comparison. Generates `compareTo()` and per-property comparator methods:

```groovy
@Sortable(includes = ['lastName', 'firstName'])
class Person {
    String firstName
    String lastName
}
```

### `@Delegate`

Implements delegation pattern by forwarding method calls to an internal field:

```groovy
class Event {
    @Delegate Date when
    String title
}

// Event now has all Date methods
```

### `@Memoized`

Caches method return values based on arguments:

```groovy
@Memoized
int expensiveComputation(int input) {
    // result is cached for each unique input
}
```

### Traits

Traits provide composable behavior with state and default implementations -- more powerful than Java interfaces with default methods.

```groovy
trait Greetable {
    String greeting() { "Hello, I'm ${name()}" }
    abstract String name()
}

trait Timestamped {
    Date createdAt = new Date()
}

class Person implements Greetable, Timestamped {
    String name
    String name() { name }
}
```

Prefer traits over abstract classes when you need to compose multiple behaviors, since Groovy supports multiple trait implementation.

### Visibility

Omit `public` (it is the default):

```groovy
// Good
class Formatter {
    String format(int count) { }
    private int parse(String s) { }
}

// Bad: redundant public
public class Formatter {
    public String format(int count) { }
}
```

---

## 6. Collections

### List and Map Literals

Use Groovy's native literal syntax. Lists create `ArrayList` by default; maps create `LinkedHashMap`.

```groovy
def numbers = [1, 2, 3, 4, 5]
def empty = []
def mixed = [1, 'two', true, null]

def colors = [red: '#FF0000', green: '#00FF00', blue: '#0000FF']
def empty = [:]
```

Use `as` for specific collection types:

```groovy
def set = [1, 2, 3] as Set
def linked = [1, 2, 3] as LinkedList
def array = [1, 2, 3] as int[]
```

### `each` / `eachWithIndex`

Iterate without building a new collection. Returns the original collection (not useful for chaining transformations).

```groovy
names.each { println it }
names.eachWithIndex { name, i -> println "${i}: ${name}" }
```

### `collect`

Transform each element into a new list. The Groovy equivalent of `map` in other languages.

```groovy
def lengths = ['one', 'two', 'three'].collect { it.size() }
assert lengths == [3, 3, 5]
```

### `find` / `findAll`

Find the first match or all matches.

```groovy
def first = numbers.find { it > 3 }        // 4
def all = numbers.findAll { it > 3 }        // [4, 5]
```

### `every` / `any`

Test predicates across a collection.

```groovy
assert [1, 2, 3].every { it > 0 }     // all positive
assert [1, -1, 3].any { it < 0 }      // at least one negative
```

### `inject` (fold/reduce)

Accumulate a value across a collection.

```groovy
def sum = [1, 2, 3, 4].inject(0) { acc, val -> acc + val }
assert sum == 10
```

### `groupBy`

Group elements into a map by a classifier.

```groovy
def words = ['ant', 'bear', 'cat', 'ape']
def grouped = words.groupBy { it[0] }
assert grouped == [a: ['ant', 'ape'], b: ['bear'], c: ['cat']]
```

### `collectEntries`

Transform a collection into a map.

```groovy
def map = ['a', 'bb', 'ccc'].collectEntries { [it, it.size()] }
assert map == [a: 1, bb: 2, ccc: 3]
```

### `sort` / `unique`

Sort or deduplicate. Both can take closures.

```groovy
def sorted = [3, 1, 2].sort()                          // [1, 2, 3]
def byLength = ['cat', 'a', 'bb'].sort { it.size() }   // ['a', 'bb', 'cat']
def unique = [1, 2, 2, 3, 3].unique()                  // [1, 2, 3]
```

Note: `sort()` and `unique()` mutate the original list. Use `sort(false)` or `toUnique()` for non-mutating versions.

### `sum` / `min` / `max` / `count`

Aggregate operations.

```groovy
assert [1, 2, 3].sum() == 6
assert [1, 2, 3].min() == 1
assert [1, 2, 3].max() == 3
assert [1, 2, 2, 3].count(2) == 2
```

### `flatten`

Flatten nested collections.

```groovy
assert [[1, 2], [3, [4, 5]]].flatten() == [1, 2, 3, 4, 5]
```

### Collection Membership

Use `in` for readability:

```groovy
if (status in ['active', 'pending', 'review']) { }
```

### Subscript and Property Access on Maps

Both are valid. Prefer dot notation for string keys that look like identifiers; use subscript for dynamic or non-identifier keys.

```groovy
def map = [name: 'Ada', age: 36]
map.name            // property notation (preferred for literal keys)
map['name']         // subscript notation
map[dynamicKey]     // required for variables
```

### The `<<` Operator

Appends to lists, string builders, and output streams:

```groovy
def list = [1, 2]
list << 3
assert list == [1, 2, 3]
```

---

## 7. Error Handling

### try/catch

Groovy's `try/catch` works like Java's but with some differences.

When you do not need the specific exception type, you can omit the type entirely. The untyped catch variable will catch all `Exception` subclasses (not `Throwable`):

```groovy
try {
    riskyOperation()
} catch (any) {
    log.error("Operation failed: ${any.message}")
}
```

If you need to catch `Throwable` (including `Error`), specify it explicitly:

```groovy
try {
    riskyOperation()
} catch (Throwable t) {
    // catches Error, Exception, and all subclasses
}
```

### Multi-catch

Groovy supports multi-catch with `|`:

```groovy
try {
    parse(input)
} catch (NumberFormatException | IllegalArgumentException e) {
    log.warn("Invalid input: ${e.message}")
}
```

### Exception Hierarchy

Follow standard JVM exception hierarchy practices:

- Throw the most specific exception type that callers will need to distinguish
- Catch the most specific type you can handle
- Never catch `Exception` or `Throwable` unless you are at the top-level error boundary
- Prefer standard JDK exception types (`IllegalArgumentException`, `IllegalStateException`, `UnsupportedOperationException`) over custom exceptions for common cases

### Custom Exceptions

Use `@InheritConstructors` to avoid constructor boilerplate:

```groovy
@InheritConstructors
class ParseException extends RuntimeException {}

throw new ParseException("Invalid date format: ${input}")
```

### Avoid Swallowing Exceptions

Never leave a catch block empty without explanation:

```groovy
// Bad
try { riskyOp() } catch (e) { }

// Acceptable if intentional and documented
try {
    optionalCleanup()
} catch (ignored) {
    // cleanup is best-effort; failure is non-fatal
}
```

---

## 8. String Handling

Groovy has six string types. Choosing the right one avoids unnecessary escaping and improves readability.

### Single-Quoted Strings

Plain `java.lang.String`. No interpolation. Use for string literals that do not need variable substitution.

```groovy
String name = 'Ada Lovelace'
String query = 'SELECT * FROM users'
```

### Double-Quoted Strings (GStrings)

Support `${}` interpolation. If interpolation is present, the type is `groovy.lang.GString`; otherwise it is `java.lang.String`.

```groovy
String greeting = "Hello ${name}"
String simple = "Count: $count"
String expr = "Total: ${a + b}"
```

Use `${}` for expressions, method calls, and property chains. Use bare `$variable` only for simple standalone variables.

For lazy evaluation (the closure re-evaluates each time the GString is used), use the closure form:

```groovy
def x = 1
def gs = "x = ${-> x}"
x = 2
assert gs == 'x = 2'
```

### Triple-Single-Quoted Strings

Multiline plain strings (no interpolation). Preserve whitespace and newlines.

```groovy
String text = '''
    This is a
    multiline string
'''
```

Use `.stripIndent()` to remove leading whitespace based on the smallest indentation, and `.stripMargin()` with a margin character:

```groovy
String text = '''\
    |First line
    |Second line
    '''.stripMargin()
```

### Triple-Double-Quoted Strings

Multiline strings with interpolation:

```groovy
String letter = """
    Dear ${name},
    Your order #${orderId} has shipped.
"""
```

### Slashy Strings

Delimited by `/`. Backslashes do not need double-escaping, making these ideal for regular expressions. Support interpolation.

```groovy
def pattern = ~/\d{4}-\d{2}-\d{2}/      // date pattern
def search = /foo\.bar\(.*\)/           // no double-escaping needed
```

Cannot be empty (`//` is a line comment).

### Dollar-Slashy Strings

Delimited by `$/` and `/$`. Use `$` as the escape character. Useful when the string contains many forward slashes.

```groovy
def path = $/
    /usr/local/bin/groovy
/$
```

### Regex Operators

```groovy
def text = '2025-06-15'

// Pattern operator: creates java.util.regex.Pattern
def datePattern = ~/\d{4}-\d{2}-\d{2}/

// Find operator: creates Matcher
def matcher = text =~ /(\d{4})-(\d{2})-(\d{2})/
assert matcher[0][1] == '2025'

// Match operator: boolean exact match
assert text ==~ /\d{4}-\d{2}-\d{2}/
```

### When to Use Which String Type

| Type | Interpolation | Multiline | Best For |
|------|--------------|-----------|----------|
| `'...'` | No | No | Simple literals, map keys |
| `"..."` | Yes | No | Messages with variables |
| `'''...'''` | No | Yes | Block text, SQL, templates |
| `"""..."""` | Yes | Yes | Block text with variables |
| `/.../` | Yes | Yes | Regex patterns |
| `$/.../$` | Yes | Yes | Strings with many slashes |

---

## 9. Common Idioms

### `with` and `tap`

`with` executes a closure with `this` set to the receiver and returns the closure's last expression. `tap` does the same but returns the receiver.

```groovy
// with: returns the last expression
def result = config.with {
    timeout = 30
    retries = 3
    toString()          // returned
}

// tap: returns the receiver (useful for initialization chains)
def person = new Person().tap {
    firstName = 'Ada'
    lastName = 'Lovelace'
}
// person is the Person object, not the last expression
```

### Groovy Truth

Groovy coerces values to boolean. Use this to simplify null/empty checks, but be explicit when zero or empty could be a valid (truthy-in-your-domain) value.

| Value | Boolean |
|-------|---------|
| `null` | `false` |
| `void` | `false` |
| `0`, `0.0`, `0L` | `false` |
| `''` (empty string) | `false` |
| `[]` (empty list) | `false` |
| `[:]` (empty map) | `false` |
| Everything else | `true` |

```groovy
// Good: idiomatic null/empty checks
if (name) { }           // instead of: if (name != null && name.length() > 0)
if (results) { }         // instead of: if (results != null && !results.isEmpty())

// Caution: this treats 0 as false
if (count) { }           // false when count == 0; use count != null if 0 is valid
```

Custom truthiness via `asBoolean()`:

```groovy
class Color {
    String name
    boolean asBoolean() { name != null }
}
```

### Default Parameters

Groovy methods support default parameter values, which generates multiple overloaded methods at the bytecode level.

```groovy
String formatAge(String dateOfBirth, String asOf = null) { }

// Can be called as:
formatAge('2020-01-01')
formatAge('2020-01-01', '2025-06-15')
```

### Named Parameters

When a method's first parameter is a `Map`, Groovy allows named-argument syntax:

```groovy
def create(Map attrs, String type) {
    // attrs contains the named params
}

create(name: 'Ada', age: 36, 'person')
```

POGOs get this for free with their default constructor:

```groovy
def p = new Person(firstName: 'Ada', lastName: 'Lovelace')
```

### Optional Return

The last expression in a method is implicitly returned. Omit `return` for short methods where intent is clear. Use explicit `return` for early exits, guard clauses, and multi-branch logic where it improves readability.

```groovy
// Good: implicit return in short method
String greeting(String name) {
    "Hello, ${name}"
}

// Good: explicit return for guard clauses and clarity
String formatAge(String dateOfBirth, String asOf) {
    int[] age = parseAge(dateOfBirth, asOf)
    if (age == null) return null    // early exit: explicit return

    int months = age[0]
    if (months < 3) return formatWeeks(months)

    return formatMonths(months)     // explicit for consistency in multi-branch
}
```

### Optional Semicolons

Semicolons are optional and should be omitted. This is universal Groovy convention.

```groovy
// Good
def x = 1
def y = 2

// Bad
def x = 1;
def y = 2;
```

### Optional Parentheses

Top-level statements can omit parentheses for method calls. This is common for DSL-style code and `println`:

```groovy
println 'Hello'
```

In library and application code, prefer parentheses for clarity. The no-parentheses style is mainly appropriate for DSLs, build scripts, and `println`.

### Equality with `==`

Groovy's `==` calls `equals()` with null safety. Use it instead of `.equals()`.

```groovy
// Good
if (status == 'active') { }

// Bad: verbose, null-unsafe
if (status != null && status.equals('active')) { }
```

### Switch Statements

Groovy's `switch` accepts any type and uses `isCase()` for matching. Cases can be literals, types, ranges, collections, closures, or regex patterns.

```groovy
switch (value) {
    case 'specific':
        handleSpecific()
        break
    case ~/\d+/:
        handleNumber()
        break
    case 1..10:
        handleRange()
        break
    case Integer:
        handleInt()
        break
    case { it > 100 }:
        handleLarge()
        break
    default:
        handleDefault()
}
```

### Import Aliasing

Use `as` to alias imports. Reduces verbosity and resolves naming conflicts.

```groovy
import java.util.List as JList
import static java.lang.Math.abs as mabs
```

### Class References

The `.class` suffix is unnecessary in Groovy:

```groovy
// Good
doSomething(String)

// Unnecessary
doSomething(String.class)
```

### Power Assert

Groovy's `assert` is always active (unlike Java) and provides detailed failure output showing every sub-expression value. Use it liberally in tests.

```groovy
assert result.size() == 3
// On failure, shows: result.size() == 3
//                     |      |
//                     [a,b]  2
//                              false
```

---

## 10. Things to Avoid

### Unnecessary `def`

Do not use `def` with an explicit type. Do not use `def` on parameters (it is implied for untyped parameters).

```groovy
// Bad
def String name = 'Ada'
void process(def String input) { }

// Good
String name = 'Ada'
void process(String input) { }
```

### Missing `@CompileStatic` on Library Code

Library code should use `@CompileStatic` for type safety and performance. Dynamic Groovy is appropriate for scripts, DSLs, and metaprogramming, but production library code benefits from compile-time checking.

### Over-Reliance on Dynamic Features

Avoid using metaprogramming (`methodMissing`, `propertyMissing`, `ExpandoMetaClass`) in library code unless building a DSL. Dynamic features make code harder to understand, debug, and refactor.

### Java-Style Boilerplate

Groovy exists to reduce ceremony. Avoid these Java patterns:

```groovy
// Bad: Java-style getter/setter
class Person {
    private String name
    String getName() { return name }
    void setName(String n) { this.name = n }
}

// Good: Groovy property
class Person {
    String name
}

// Bad: verbose null checking
if (name != null && name.length() > 0) { }

// Good: Groovy truth
if (name) { }

// Bad: explicit equals
if (status != null && status.equals('active')) { }

// Good: Groovy ==
if (status == 'active') { }
```

### Empty Catch Blocks

Never silently swallow exceptions. At minimum, log the error or add a comment explaining why it is intentionally ignored.

### Star Imports in Library Code

Prefer explicit imports. Star imports (`import java.util.*`) can cause unexpected name collisions and make dependencies unclear.

### Mutable State in Closures

Be cautious with closures that capture and mutate external variables. This can lead to subtle bugs, especially with concurrent code.

```groovy
// Risky: shared mutable state
def count = 0
threads.each { count++ }   // race condition

// Better: use thread-safe constructs
def count = new AtomicInteger(0)
threads.each { count.incrementAndGet() }
```

### Returning `null` from Collections

Prefer returning empty collections over `null`:

```groovy
// Bad
List<String> getNames() {
    if (noResults) return null
}

// Good
List<String> getNames() {
    if (noResults) return []
}
```

### Overusing `it`

The implicit closure parameter `it` obscures meaning in complex closures. Name parameters explicitly.

```groovy
// Bad: unclear what 'it' refers to in nested context
people.collect {
    it.addresses.findAll {
        it.city == 'London'   // which 'it'?
    }
}

// Good: explicit names
people.collect { person ->
    person.addresses.findAll { address ->
        address.city == 'London'
    }
}
```

---

## 11. Tooling

### CodeNarc

[CodeNarc](https://codenarc.org/) is the standard static analysis tool for Groovy, analogous to PMD/Checkstyle for Java. It provides over 350 rules organized into categories.

Key rule sets for style enforcement:

| Rule Set | Purpose |
|----------|---------|
| [Convention](https://codenarc.org/codenarc-rules-convention.html) | Coding patterns (type declarations, Elvis usage, method ordering) |
| [Formatting](https://codenarc.org/codenarc-rules-formatting.html) | Whitespace, braces, line length, indentation |
| [Naming](https://codenarc.org/codenarc-rules-naming.html) | Class/method/variable/package naming patterns |
| [Unnecessary](https://codenarc.org/codenarc-rules-unnecessary.html) | Redundant code (unnecessary getters, parentheses, semicolons) |
| [Unused](https://codenarc.org/codenarc-rules-unused.html) | Unused variables, imports, methods |
| [Design](https://codenarc.org/codenarc-rules-design.html) | Design issues (too many methods, abstract class without abstract method) |

Notable convention rules to consider enabling:

- **CompileStatic** -- require `@CompileStatic` or `@CompileDynamic` on classes
- **NoDef** -- eliminate `def` in favor of explicit types
- **MethodReturnTypeRequired** -- require explicit return types
- **FieldTypeRequired** -- require explicit field types
- **ImplicitClosureParameter** -- flag implicit `it` usage
- **TrailingComma** -- require trailing commas in multiline list/map literals

### Groovy Compiler Flags

Useful compiler configuration options:

```groovy
// compiler-config.groovy
withConfig(configuration) {
    ast(groovy.transform.CompileStatic)   // apply @CompileStatic globally
}
```

This makes `@CompileStatic` the default for all classes in the compilation unit. Individual methods can opt out with `@CompileDynamic`.

Other compiler flags:

- `--configscript` -- apply a compiler configuration script
- `-Werror` -- treat warnings as errors (Groovy 3+, limited support)
- `groovyc --indy` -- use invokedynamic for better performance (default in Groovy 4+)

### Spock Framework

[Spock](https://spockframework.org/) is the preferred testing framework for Groovy. It combines specification-style testing with powerful features.

Test structure uses labeled blocks:

```groovy
class FormatterSpec extends Specification {

    def 'formats age in weeks for infants'() {
        given: 'a formatter with English locale'
        def formatter = new SayableAge(Locales.EN)

        when: 'formatting a 2-week-old infant'
        def result = formatter.formatAge('2025-01-01', '2025-01-15')

        then: 'age is expressed in weeks'
        result == '2 weeks'
    }
}
```

Data-driven testing with `where` blocks:

```groovy
def 'age formatting for various inputs'() {
    expect:
    new SayableAge(Locales.EN).formatAge(dob, asOf) == expected

    where:
    dob          | asOf         || expected
    '2025-06-15' | '2025-06-15' || 'newborn'
    '2025-06-14' | '2025-06-15' || '1 day'
    '2025-06-08' | '2025-06-15' || '1 week'
}
```

Spock blocks:

| Block | Purpose |
|-------|---------|
| `given:` / `setup:` | Preconditions and test fixtures |
| `when:` | Stimulus / action under test |
| `then:` | Assertions (implicit `assert` on every expression) |
| `expect:` | Combined `when` + `then` for simple cases |
| `where:` | Data tables for parameterized tests |
| `cleanup:` | Teardown (always runs) |

### JUnit

JUnit 4 and 5 both work well with Groovy. `GroovyTestCase` extends JUnit 3's `TestCase` with additional helpers (`shouldFail`, `assertScript`, `notYetImplemented`), but JUnit 5 with `@Test` annotations is the modern standard.

### Build Tools

- **Gradle** -- the natural choice; its build scripts are Groovy (or Kotlin) DSLs
- **Maven** -- works via `gmavenplus-plugin` or `groovy-eclipse-compiler`

---

## Sources

- [Apache Groovy Style Guide](https://groovy-lang.org/style-guide.html) -- official style recommendations
- [Apache Groovy Language Documentation](https://groovy-lang.org/documentation.html) -- language specification, operators, closures, OOP, semantics
- [Apache Groovy Operators](https://groovy-lang.org/operators.html) -- complete operator reference
- [Apache Groovy Closures](https://groovy-lang.org/closures.html) -- delegation, currying, memoization, composition
- [Apache Groovy Object Orientation](https://groovy-lang.org/objectorientation.html) -- classes, traits, properties, annotations
- [Apache Groovy Semantics](https://groovy-lang.org/semantics.html) -- Groovy truth, type coercion, `@CompileStatic`, `@TypeChecked`
- [Apache Groovy Metaprogramming](https://groovy-lang.org/metaprogramming.html) -- AST transformations (`@Canonical`, `@Immutable`, `@Builder`, etc.)
- [Apache Groovy Syntax](https://groovy-lang.org/syntax.html) -- string types, literals, collection syntax
- [Apache Groovy Testing](https://groovy-lang.org/testing.html) -- Spock, JUnit, power asserts, mocking
- [CodeNarc Convention Rules](https://codenarc.org/codenarc-rules-convention.html)
- [CodeNarc Formatting Rules](https://codenarc.org/codenarc-rules-formatting.html)
- [CodeNarc Naming Rules](https://codenarc.org/codenarc-rules-naming.html)
- [Spock Framework](https://spockframework.org/) -- specification-based testing

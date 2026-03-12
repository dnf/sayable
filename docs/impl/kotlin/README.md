# Kotlin Style Guide

A reference for idiomatic Kotlin coding style, intended for auditing Kotlin implementations in this project.

## Sources

This guide synthesizes conventions from:

- [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- [Android Kotlin Style Guide](https://developer.android.com/kotlin/style-guide)
- [Kotlin Idioms](https://kotlinlang.org/docs/idioms.html)
- [Kotlin Null Safety](https://kotlinlang.org/docs/null-safety.html)
- [Kotlin Scope Functions](https://kotlinlang.org/docs/scope-functions.html)
- [Kotlin Exceptions](https://kotlinlang.org/docs/exceptions.html)
- [detekt Rules](https://detekt.dev/docs/rules/style)
- [ktlint](https://pinterest.github.io/ktlint/)

---

## 1. Naming Conventions

### Casing Rules

| Element | Casing | Example |
|---|---|---|
| Classes, objects, interfaces | PascalCase | `DeclarationProcessor`, `EmptyDeclarationProcessor` |
| Functions | camelCase | `processDeclarations()`, `sendMessage()` |
| Properties and local variables | camelCase | `declarationCount`, `currentMax` |
| `const val` and deeply immutable top-level `val` | SCREAMING_SNAKE_CASE | `MAX_COUNT`, `USER_NAME_FIELD` |
| Top-level/object `val` holding object references | camelCase | `defaultFormatter`, `logger` |
| Mutable top-level/object properties | camelCase | `mutableCollection` |
| Enum constants | SCREAMING_SNAKE_CASE | `RED`, `NORTH`, `OTHER` |
| Packages | lowercase, no underscores | `org.example.myproject` |
| Type parameters | Single capital letter, or name + `T` | `T`, `E`, `RequestT`, `FooBarT` |
| Backing properties | `_` prefix on private property | `_elementList` |
| Test methods | Backtick-quoted or underscore-separated | `` `ensure everything works`() ``, `pop_emptyStack()` |

**Constants vs object references.** `SCREAMING_SNAKE_CASE` is for `const val` and for top-level/object `val` properties holding deeply immutable data (primitives, strings). When a `val` holds an object with behavior or identity (a `Regex`, a `Comparator`, a class instance), use `camelCase` -- the reference is immutable but the value is not a simple constant:

```kotlin
const val MAX_AGE_MONTHS = 6000          // Compile-time constant
val DEFAULT_DELIMITER = ", "             // Deeply immutable string

val defaultFormatter = SayableAge(EN)    // Object reference, not a constant
val datePattern = Regex("\\d{4}-\\d{2}-\\d{2}")  // Object with behavior
```

**Enum constants.** Use `SCREAMING_SNAKE_CASE` consistently. This matches existing usage (`PluralCategory.ZERO`, `Compactness.NORMAL`) and is consistent with JVM conventions.

### Acronym Handling

Capitalize only the first letter of any acronym, regardless of length. This follows the Kotlin coding conventions (which deliberately departed from the older Java convention of keeping two-letter acronyms uppercase):

| Prose form | Correct | Incorrect |
|---|---|---|
| "XML Http Request" | `XmlHttpRequest` | `XMLHTTPRequest` |
| "new customer ID" | `newCustomerId` | `newCustomerID` |
| "supports IPv6 on iOS" | `supportsIpv6OnIos` | `supportsIPv6OnIOS` |
| "IO Stream" | `IoStream` | `IOStream` |

### Naming Principles

- **Classes and objects**: noun or noun phrase (`List`, `PersonReader`).
- **Functions**: verb or verb phrase (`close`, `readPersons`).
- **Distinguish mutating from returning**: `sort()` mutates in place; `sorted()` returns a copy.
- **Avoid meaningless words**: `Manager`, `Wrapper`, `Util`, `Helper`.
- **Prefer clarity over brevity.** `processDeclarations` over `procDecl`.

### Backing Properties

Use the `_` prefix convention when a private mutable property backs a public read-only property:

```kotlin
class TaskRepository {
    private val _tasks = mutableListOf<Task>()
    val tasks: List<Task> get() = _tasks
}
```

### Singleton References

When a `val` holds a singleton-like object reference, use PascalCase to signal its object-like nature:

```kotlin
val PersonComparator: Comparator<Person> = compareBy { it.lastName }
```

---

## 2. Code Formatting

### Indentation and Braces

- Use **4 spaces** for indentation. Never use tabs.
- Use **K&R style** (Egyptian brackets): opening brace at end of line, closing brace on its own line.
- `else`, `catch`, `finally`, and `while` (in do-while) go on the same line as the closing brace.

```kotlin
if (elements != null) {
    for (element in elements) {
        process(element)
    }
} else {
    handleEmpty()
}

try {
    riskyOperation()
} catch (e: IOException) {
    handleError(e)
} finally {
    cleanup()
}
```

### Line Length

Use **100 characters** as the column limit. This matches the Android Kotlin Style Guide and provides comfortable side-by-side diff viewing. Exceptions:

- `package` and `import` statements.
- Long URLs in KDoc.
- Command lines in comments intended for copy-paste.

### Line Wrapping

- Break at higher syntactic levels.
- Break **after** operators and infix function names.
- Break **before** `.`, `?.`, and `::`.
- Keep the method/constructor name attached to `(`.
- Keep commas attached to the preceding token.

```kotlin
val anchor = owner
    ?.firstChild!!
    .siblings(forward = true)
    .dropWhile { it is PsiComment || it is PsiWhiteSpace }

val result = veryLongExpression +
    anotherLongExpression +
    yetAnotherExpression
```

### Function Signatures

When a function signature does not fit on one line, break each parameter onto its own line with a single indent (+4 spaces). The closing `)` and return type go on their own line:

```kotlin
fun <T> Iterable<T>.joinToString(
    separator: CharSequence = ", ",
    prefix: CharSequence = "",
    postfix: CharSequence = "",
): String {
    // ...
}
```

### Class Headers

Short class headers fit on one line. Longer ones break each parameter onto its own line:

```kotlin
class Person(id: Int, name: String)

class Person(
    id: Int,
    name: String,
    surname: String,
) : Human(id, name),
    KotlinMaker {
    // ...
}
```

### Trailing Commas

Use trailing commas in multi-line parameter lists, argument lists, collection literals, when entries, and destructuring declarations. They simplify diffs and make reordering easier:

```kotlin
data class Person(
    val firstName: String,
    val lastName: String,
    val age: Int,
)

val colors = listOf(
    "red",
    "green",
    "blue",
)
```

### Import Ordering

- Imports are **ASCII sorted** (matching the Android Kotlin Style Guide).
- **No wildcard imports.** Always use explicit imports.
- Imports are not subject to the column limit and are never line-wrapped.

```kotlin
import android.app.Activity
import android.os.Bundle
import kotlin.collections.HashMap
import org.example.project.MyClass
```

### Whitespace

**Space required** around:
- Binary operators: `a + b`, `x == y` (exception: no spaces around range operator `0..n`).
- Lambda arrows: `{ value -> transform(value) }`.
- After `,` and `:` (but not before `:` in declarations).
- Control flow keywords and their `(`: `if (`, `when (`, `for (`, `while (`.

**No space** around:
- `.` and `?.`: `foo.bar()`, `foo?.bar()`.
- `::`: `String::length`, `Foo::class`.
- Before `?` in nullable types: `String?`.
- Unary operators: `a++`, `-b`.

### Colon Spacing

Space **before** `:` only when separating a type from a supertype or `object` keyword. No space before `:` between a declaration and its type:

```kotlin
abstract class Foo<out T : Any> : IFoo {
    abstract fun foo(a: Int): T
}

val x = object : IFoo { /* ... */ }
```

### Modifier Order

Follow the canonical modifier order:

```
public / protected / private / internal
expect / actual
final / open / abstract / sealed / const
external
override
lateinit
tailrec
vararg
suspend
inner
enum / annotation / fun
companion
inline / value
infix
operator
data
```

Place annotations before modifiers:

```kotlin
@Named("Foo")
private val foo: Foo
```

### Empty Blocks

Use K&R style for empty blocks. Choose an example that is not misleading -- an empty override, not an empty `catch` (see Section 10 on swallowed exceptions):

```kotlin
override fun onStart() {
}
```

---

## 3. Visibility

Kotlin defaults to `public` visibility. Actively manage your API surface by choosing the most restrictive visibility that works.

### Visibility Modifiers

| Modifier | Scope |
|---|---|
| `private` | Visible within the declaring file (top-level) or class only |
| `internal` | Visible within the same module (compilation unit) |
| `protected` | Visible within the class and its subclasses |
| `public` | Visible everywhere (default, can be omitted) |

### When to Use `internal`

Use `internal` for implementation details that must be accessible across files within a module but should not be part of the library's public API:

```kotlin
// Exposed to callers
public class SayableAge(private val locale: AgeLocale) {
    public fun formatAge(dateOfBirth: String, asOf: String? = null): String? { /* ... */ }
}

// Implementation detail: accessible within the module, hidden from consumers
internal fun parseAge(dateOfBirth: String, asOf: String? = null): AgeComponents? { /* ... */ }

internal data class AgeComponents(val months: Int, val diffDays: Int)
```

`internal` is also useful for making implementation details accessible to tests without the `@VisibleForTesting` annotation pattern.

### Minimizing Public API

- Start with `private`. Widen to `internal` when other files in the module need access. Widen to `public` only for the intended API surface.
- Omit the `public` modifier on declarations that are intentionally public -- it is the default, and explicit `public` is redundant (ktlint and IntelliJ flag it).
- Use `private` constructors with companion object factory methods when construction should be controlled.

---

## 4. Null Safety

Kotlin's type system distinguishes nullable types (`String?`) from non-nullable types (`String`). Use the type system to enforce null safety at compile time.

### Nullable Types

Explicitly annotate variables that can be null. Non-nullable types cannot hold `null`:

```kotlin
var a: String = "abc"   // Cannot be null
var b: String? = "abc"  // Can be null
b = null                // Valid
```

### Safe Call Operator (`?.`)

Access members safely on nullable receivers. Returns `null` if the receiver is null:

```kotlin
val length: Int? = name?.length
bob?.department?.head?.name  // Chains safely
```

### Elvis Operator (`?:`)

Provide a default value (or throw/return) when the left side is null:

```kotlin
val length = name?.length ?: 0
val parent = node.getParent() ?: return null
val email = values["email"] ?: throw IllegalStateException("Email missing")
```

### Safe Casts (`as?`)

Returns `null` if the cast fails instead of throwing `ClassCastException`:

```kotlin
val aInt: Int? = someValue as? Int
```

### `let` for Null Checks

Execute a block only when the value is non-null:

```kotlin
val email: String? = person.email
email?.let { sendEmail(it) }

// Transform nullable to non-nullable
val mapped = value?.let { transform(it) } ?: defaultValue
```

### `lateinit`

Use for non-nullable properties that cannot be initialized in the constructor (e.g., dependency injection, test setup). Access before initialization throws `UninitializedPropertyAccessException`:

```kotlin
class MyTest {
    lateinit var subject: SystemUnderTest

    @BeforeEach
    fun setUp() {
        subject = SystemUnderTest()
    }
}
```

Check initialization with `::property.isInitialized` when needed.

**Restrictions:** `lateinit` works only with `var`, not `val`. It does not work with primitive types.

### The Not-Null Assertion Operator (`!!`)

The `!!` operator throws `NullPointerException` if the value is null. Prefer safer alternatives as the default choice:

```kotlin
// Preferred: safe call with default
val length = name?.length ?: 0

// Preferred: smart cast after null check
if (name != null) {
    println(name.length)
}

// Preferred: require for preconditions (adds a diagnostic message)
fun process(name: String?) {
    requireNotNull(name) { "Name must not be null" }
    println(name.length)
}
```

`!!` is acceptable when you have verified that null is impossible but the compiler cannot prove it -- for example, after control flow that crosses lambda boundaries, or with `var` properties that smart casts cannot track. When the reason is non-obvious, add a brief comment explaining the invariant:

```kotlin
// Safe: we checked isEmpty() above and the map is not modified concurrently
val first = entries.firstEntry()!!.value
```

Avoid `!!` when `requireNotNull` would provide better diagnostics in the failure case.

The only possible sources of `NullPointerException` in Kotlin are: explicit `!!`, `throw NullPointerException()`, Java interop, and `this` leaking during initialization.

### Nullable Boolean

Use explicit equality checks, not truthiness:

```kotlin
if (value == true) { /* ... */ }
if (value == false) { /* ... */ }
```

### Nullable Collections

Use `filterNotNull()` to strip nulls from collections:

```kotlin
val nullableList: List<Int?> = listOf(1, 2, null, 4)
val intList: List<Int> = nullableList.filterNotNull()  // [1, 2, 4]
```

### Platform Types (Java Interop)

When calling Java code, the returned types have unknown nullability (platform types, shown as `String!` in error messages). **Always declare the Kotlin type explicitly** for public API boundaries:

```kotlin
// Public function: declare type explicitly
fun apiCall(): String = MyJavaApi.getProperty("name")

// Local variable: inference is acceptable
fun main() {
    val name = MyJavaApi.getProperty("name")
    println(name)
}
```

---

## 5. Type System

### Data Classes

Use data classes for types that primarily hold data. The compiler generates `equals()`, `hashCode()`, `toString()`, `copy()`, and `componentN()` functions from primary constructor parameters:

```kotlin
data class User(val name: String, val email: String)

val user = User("Alice", "alice@example.com")
val copy = user.copy(email = "new@example.com")
val (name, email) = user  // Destructuring
```

**Requirements:**
- Primary constructor must have at least one parameter.
- All primary constructor parameters must be `val` or `var`.
- Data classes cannot be `abstract`, `open`, `sealed`, or `inner`.

**Properties in the class body are excluded** from generated functions:

```kotlin
data class Person(val name: String) {
    var age: Int = 0  // Not included in equals/hashCode/toString/copy
}
```

**`copy()` is shallow.** Mutable objects within a data class are shared between the original and the copy.

### Sealed Classes and Interfaces

Use sealed classes/interfaces when you need a restricted hierarchy with exhaustive `when` expressions. All direct subclasses must be in the same package:

```kotlin
sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val exception: Exception) : Result<Nothing>()
    data object Loading : Result<Nothing>()
}

fun handleResult(result: Result<String>) = when (result) {
    is Result.Success -> println(result.data)
    is Result.Error -> println(result.exception.message)
    Result.Loading -> println("Loading...")
    // No else needed: compiler knows all cases are covered
}
```

**Sealed classes vs. enums:**
- Enums: single instance per constant, simple fixed sets.
- Sealed classes: multiple instances per subclass, each can hold different data.

Enums can implement sealed interfaces but cannot extend sealed classes.

**Common use cases:** state machines, UI state, error hierarchies, API responses.

### Value Classes (`@JvmInline`)

Use value classes for type-safe wrappers around a single value without runtime overhead:

```kotlin
@JvmInline
value class EmployeeId(private val id: String)

@JvmInline
value class CustomerId(private val id: String)

fun processEmployee(id: EmployeeId) { /* ... */ }
// processEmployee(CustomerId("123"))  // Compile error: type mismatch
```

### Enums

Use enums for fixed sets of constants:

```kotlin
enum class Direction { NORTH, SOUTH, EAST, WEST }

enum class Color(val rgb: Int) {
    RED(0xFF0000),
    GREEN(0x00FF00),
    BLUE(0x0000FF),
}
```

### Generics

Use meaningful type parameter names when the role is not obvious from a single letter:

```kotlin
// Single letter is fine for simple cases
class Box<T>(val content: T)

// Descriptive name for clarity
interface Repository<Entity, Id> {
    fun findById(id: Id): Entity?
}
```

Use `out` for covariant (producer) and `in` for contravariant (consumer) type parameters:

```kotlin
interface Source<out T> {
    fun next(): T
}

interface Sink<in T> {
    fun accept(value: T)
}
```

### Type Aliases

Use type aliases for frequently used complex types:

```kotlin
typealias MouseClickHandler = (Any, MouseEvent) -> Unit
typealias PersonIndex = Map<String, Person>
typealias NodeSet = Set<Network.Node>
```

---

## 6. Function Design

### Default Parameter Values

Prefer default values over function overloading:

```kotlin
// Good: single function with defaults
fun format(name: String, greeting: String = "Hello") = "$greeting, $name!"

// Avoid: Java-style overloading
fun format(name: String) = format(name, "Hello")
fun format(name: String, greeting: String) = "$greeting, $name!"
```

### Named Arguments

Use named arguments when the meaning of arguments is not clear from context, especially for multiple parameters of the same type or boolean parameters:

```kotlin
drawSquare(x = 10, y = 10, width = 100, height = 100, fill = true)

val result = listOf("a", "b").joinToString(separator = ", ", prefix = "[", postfix = "]")
```

### Single-Expression Functions

Use expression body when the function is a single expression:

```kotlin
fun square(x: Int): Int = x * x

fun transform(color: String): Int = when (color) {
    "Red" -> 0
    "Green" -> 1
    "Blue" -> 2
    else -> throw IllegalArgumentException("Invalid color: $color")
}
```

When the expression body wraps to the next line, put `=` at the end of the first line:

```kotlin
fun formatAge(years: Int, months: Int) =
    "$years years and $months months"
```

### Extension Functions

Use extension functions when operating primarily on a single object. Restrict visibility when the extension is not broadly useful:

```kotlin
fun String.toScreenName(): String = trim().uppercase()

// Restrict visibility
private fun String.isValidEmail(): Boolean =
    contains("@") && contains(".")
```

### Infix Functions

Use for functions with two objects in similar roles. Do not use for mutating operations:

```kotlin
infix fun <A, B> A.to(that: B): Pair<A, B> = Pair(this, that)
val pair = "key" to "value"
```

### Scope Functions (`let`, `run`, `with`, `apply`, `also`)

Each scope function differs in how it references the context object and what it returns:

| Function | Context reference | Return value | Use when |
|---|---|---|---|
| `let` | `it` | Lambda result | Null-safe transforms, introducing scoped variables |
| `run` | `this` | Lambda result | Limiting variable scope; `this`-based computation on a receiver |
| `with` | `this` | Lambda result | Grouping calls on an object (non-extension) |
| `apply` | `this` | Context object | Object configuration / initialization |
| `also` | `it` | Context object | Side effects (logging, validation) |

```kotlin
// let: transform nullable value
val length = name?.let { it.uppercase().length } ?: 0

// run (non-extension): limit variable scope
val hexColor = run {
    val r = computeRed()
    val g = computeGreen()
    val b = computeBlue()
    "#%02x%02x%02x".format(r, g, b)
}

// with: multiple operations, no result needed
with(turtle) {
    penDown()
    forward(100.0)
    turn(90.0)
    penUp()
}

// apply: configure and return the object
val person = Person("Adam").apply {
    age = 32
    city = "London"
}

// also: side effects in a chain
val numbers = mutableListOf("one", "two", "three")
    .also { println("Before adding: $it") }
    .apply { add("four") }
```

**Avoid:**
- Nesting scope functions (readability degrades rapidly).
- Overusing scope functions where a simple `if` or local variable suffices.
- Mixing mutation and computation in a single `run` block (use `apply` for mutation, separate the computation).

### `takeIf` and `takeUnless`

Embed conditional checks in call chains. Returns the object or `null` based on the predicate:

```kotlin
val evenOrNull = number.takeIf { it % 2 == 0 }
val index = input.indexOf(sub).takeIf { it >= 0 }
    ?.let { println("Found at position $it") }
```

### Factory Functions

Use named factory functions in companion objects instead of overloaded constructors:

```kotlin
class Point(val x: Double, val y: Double) {
    companion object {
        fun fromPolar(angle: Double, radius: Double) =
            Point(radius * cos(angle), radius * sin(angle))
    }
}
```

---

## 7. Collections

### Immutable by Default

Use read-only collection interfaces (`List`, `Set`, `Map`) unless mutation is required. Use `listOf`, `setOf`, `mapOf` for creation:

```kotlin
// Good: immutable interface
fun validateValue(actualValue: String, allowedValues: Set<String>) { }

val names = listOf("Alice", "Bob", "Charlie")
val scores = mapOf("Alice" to 95, "Bob" to 87)

// Only when mutation is needed
val mutableNames = mutableListOf("Alice", "Bob")
mutableNames.add("Charlie")
```

**Accept the most general read-only type** in function parameters. Return the most specific type callers need.

### Collection Type Declarations

Declare collection variables using Kotlin's interface types (`List`, `MutableList`, `Map`, `MutableMap`) and Kotlin's factory functions (`listOf`, `mutableListOf`, `mapOf`, `mutableMapOf`) as the default:

```kotlin
// Good: interface type, Kotlin factory
val list: MutableList<String> = mutableListOf()

// Acceptable: specific implementation when you need its guarantees
val buffer = ArrayList<String>(1000)  // Pre-sized for performance
val ordered: LinkedHashMap<String, Int> = linkedMapOf()  // Insertion order
val queue: ArrayDeque<Task> = ArrayDeque()  // Double-ended queue
```

The key principle is declaring the variable with an interface type when possible, even when using a specific implementation.

### Functional Operations and Loops

Prefer functional operations for filter/map/reduce pipelines where they improve readability:

```kotlin
val adults = people
    .filter { it.age >= 18 }
    .sortedBy { it.name }
    .map { it.name }
```

Use loops when they are clearer: early termination with side effects, accumulating multiple outputs, index-dependent logic, or performance-critical paths:

```kotlin
// Loop is appropriate: accumulating state with early exit
var total = 0
for (item in items) {
    if (item.isInvalid) break
    total += item.value
}

// Loop is appropriate: tight numeric conversion
var n = 0
for (c in s) {
    if (c < '0' || c > '9') return null
    n = n * 10 + (c - '0')
}
```

Common functional operations:

| Operation | Function |
|---|---|
| Transform | `map`, `flatMap`, `mapNotNull` |
| Filter | `filter`, `filterNot`, `filterNotNull`, `filterIsInstance` |
| Aggregate | `fold`, `reduce`, `sumOf`, `count` |
| Check | `any`, `all`, `none`, `first`, `firstOrNull` |
| Group | `groupBy`, `associateBy`, `partition` |
| Combine | `zip`, `unzip`, `flatMap` |
| Order | `sorted`, `sortedBy`, `sortedByDescending` |

### Sequences

Use sequences for large collections or chains with multiple intermediate operations. Sequences are lazy and avoid creating intermediate lists:

```kotlin
// Eager: creates intermediate lists at each step
val result = hugeList
    .filter { it.isActive }
    .map { it.name }
    .take(10)

// Lazy: processes element-by-element, stops after 10
val result = hugeList.asSequence()
    .filter { it.isActive }
    .map { it.name }
    .take(10)
    .toList()
```

Use sequences when:
- The collection is large (thousands of elements).
- The chain has multiple intermediate operations.
- You only need a subset of results (`take`, `first`).

Use regular collections when:
- The collection is small.
- There is only one operation.
- You need `sorted()` (sequences cannot sort lazily).

### Destructuring

Use destructuring for pairs, triples, data classes, and map entries:

```kotlin
val (name, age) = person  // Data class
for ((key, value) in map) { println("$key -> $value") }
val (match, rest) = list.partition { it > 0 }
```

### Map Access

Use index operator syntax for map access:

```kotlin
println(map["key"])
map["key"] = value
```

### Collection Creation

Use the appropriate builder for the situation:

```kotlin
val list = listOf(1, 2, 3)
val set = setOf("a", "b", "c")
val map = mapOf("one" to 1, "two" to 2)

// buildList for complex construction
val squares = buildList {
    for (i in 1..10) add(i * i)
}
```

---

## 8. Error Handling

### Exceptions

Kotlin has **no checked exceptions**. All exceptions are unchecked. Use exceptions for truly exceptional conditions, not normal control flow.

### Precondition Functions

Use the standard library precondition functions instead of manual `if`/`throw`:

| Function | Exception thrown | Use for |
|---|---|---|
| `require(condition)` | `IllegalArgumentException` | Validating function arguments |
| `requireNotNull(value)` | `IllegalArgumentException` | Ensuring arguments are non-null |
| `check(condition)` | `IllegalStateException` | Validating object/variable state |
| `checkNotNull(value)` | `IllegalStateException` | Ensuring state is non-null |
| `error(message)` | `IllegalStateException` | Signaling illegal state with a message |

```kotlin
fun setAge(age: Int) {
    require(age >= 0) { "Age must be non-negative, was $age" }
    this.age = age
}

fun process(name: String?) {
    val validName = requireNotNull(name) { "Name must not be null" }
    // validName is smart-cast to non-null String
}

fun getStatus(): Status {
    val state = checkNotNull(currentState) { "State not initialized" }
    check(state.isReady) { "System is not ready" }
    return state.status
}
```

### Try as Expression

`try`/`catch` is an expression in Kotlin:

```kotlin
val number: Int = try {
    input.toInt()
} catch (e: NumberFormatException) {
    -1
}
```

### The `Nothing` Type

Functions that never return normally (always throw) should return `Nothing`. This helps the compiler with type inference and dead code analysis:

```kotlin
fun fail(message: String): Nothing {
    throw IllegalArgumentException(message)
}

val name: String = person.name ?: fail("Name required")
// Compiler knows fail() never returns, so name is non-null
```

### `Result` Type and `runCatching`

Use `Result<T>` for operations that may fail but where exceptions are not the best API:

```kotlin
val result: Result<Int> = runCatching {
    riskyComputation()
}

result
    .onSuccess { value -> println("Got $value") }
    .onFailure { error -> println("Failed: ${error.message}") }

val value = result.getOrDefault(0)
val mapped = result.map { it * 2 }
```

**Caution:** `runCatching` catches all `Throwable` including `CancellationException`, which can break coroutine cancellation. In coroutine contexts, prefer explicit `try`/`catch` that rethrows `CancellationException`.

### Resource Management

Use `.use()` (Kotlin's equivalent of try-with-resources) for `Closeable`/`AutoCloseable` resources:

```kotlin
FileReader("data.txt").use { reader ->
    reader.readText()
}
```

### `@Throws` for Java Interop

Annotate functions with `@Throws` when they need to be callable from Java code that expects checked exceptions:

```kotlin
@Throws(IOException::class)
fun readFile(path: String): String { /* ... */ }
```

---

## 9. Common Idioms

### `when` Expressions

Use `when` for multi-branch conditionals. Prefer it over `if`/`else if` chains when there are three or more branches:

```kotlin
fun describe(obj: Any): String = when (obj) {
    1 -> "One"
    "Hello" -> "Greeting"
    is Long -> "Long"
    !is String -> "Not a string"
    else -> "Unknown"
}
```

Use `when` without an argument for complex boolean conditions:

```kotlin
fun categorize(x: Int) = when {
    x < 0 -> "negative"
    x == 0 -> "zero"
    x < 100 -> "small positive"
    else -> "large positive"
}
```

Use `when` as a statement for side effects, with exhaustive branches on sealed classes:

```kotlin
when (result) {
    is Success -> showData(result.data)
    is Error -> showError(result.message)
    Loading -> showSpinner()
}
```

### String Templates

Use string templates instead of concatenation. Omit braces for simple variable references:

```kotlin
println("$name has ${children.size} children")
```

Use multiline strings with `trimIndent()` or `trimMargin()` instead of `\n` escapes:

```kotlin
val text = """
    Dear $name,

    Thank you for your purchase.
""".trimIndent()

val code = """
    |if (a > 1) {
    |    return a
    |}
""".trimMargin()
```

### `if` and `try` as Expressions

Use the expression form to assign values directly:

```kotlin
val max = if (a > b) a else b

val number = try { input.toInt() } catch (e: NumberFormatException) { 0 }
```

### Companion Objects

Use companion objects for factory methods and constants associated with a class:

```kotlin
class MyClass private constructor(val value: Int) {
    companion object {
        const val MAX_VALUE = 100

        fun create(value: Int): MyClass {
            require(value <= MAX_VALUE) { "Value too large" }
            return MyClass(value)
        }
    }
}
```

### Lazy Properties

Use `by lazy` for expensive properties that should be computed on first access:

```kotlin
val expensiveValue: String by lazy {
    computeExpensiveValue()
}
```

### Ranges and Progressions

```kotlin
for (i in 1..100) { /* 1 to 100, inclusive */ }
for (i in 1..<100) { /* 1 to 99, open-ended */ }
for (i in 100 downTo 1) { /* 100 to 1 */ }
for (i in 2..10 step 2) { /* 2, 4, 6, 8, 10 */ }
if (x in 1..10) { /* range check */ }
```

### Singletons

Use `object` declarations for singletons:

```kotlin
object DatabaseConfig {
    val url = "jdbc:postgresql://localhost/mydb"
    val maxConnections = 10
}
```

### `TODO()`

Use `TODO()` to mark incomplete code during development. It throws `NotImplementedError` at runtime and appears in IDE task lists:

```kotlin
fun calculateTax(): BigDecimal = TODO("Waiting for accounting feedback")
```

Note: the `ForbiddenComment` detekt rule (see Section 11) should be enabled in CI to prevent `TODO` markers from reaching production. `TODO()` is a development aid, not a shipping construct.

---

## 10. Things to Avoid

### Unnecessary Not-Null Assertions

See Section 4 for the full guidance on `!!`. The short version: prefer `?.`, `?:`, `requireNotNull`, and smart casts. Use `!!` only when null is provably impossible and the alternatives would add noise.

### Java-Style Getters and Setters

Kotlin properties replace Java-style `getX()`/`setX()` methods. Do not write them manually:

```kotlin
// Bad: Java style
class Person {
    private var name: String = ""
    fun getName(): String = name
    fun setName(value: String) { name = value }
}

// Good: Kotlin property
class Person {
    var name: String = ""
}

// Good: property with custom accessors
class Person {
    var name: String = ""
        set(value) {
            require(value.isNotBlank()) { "Name must not be blank" }
            field = value.trim()
        }
}
```

### `it` Abuse in Nested Lambdas

When lambdas are nested, use explicit parameter names. `it` becomes ambiguous:

```kotlin
// Bad: which 'it' is which?
people.forEach {
    it.children.forEach {
        println(it.name)  // Bad: unclear which 'it'
    }
}

// Good: explicit names
people.forEach { person ->
    person.children.forEach { child ->
        println(child.name)
    }
}
```

### Overly Complex Scope Function Chains

Do not nest or chain multiple scope functions when a simple variable assignment would be clearer:

```kotlin
// Bad: hard to follow
value?.let { it.process() }?.also { log(it) }?.run { transform() }

// Good: straightforward
val processed = value?.process() ?: return
log(processed)
val result = processed.transform()
```

### Returning Mutable Collections from Public API

Return read-only collection types from public functions:

```kotlin
// Bad: exposes mutability
fun getNames(): MutableList<String> = names

// Good: read-only view
fun getNames(): List<String> = names.toList()
// Or use backing property pattern
private val _names = mutableListOf<String>()
val names: List<String> get() = _names
```

### Catching Broadly

Catch specific exception types. Broad catches hide bugs:

```kotlin
// Bad
try { parse(input) } catch (e: Exception) { null }

// Good
try { parse(input) } catch (e: NumberFormatException) { null }
```

### Empty `catch` Blocks

Never silently swallow exceptions. At minimum, log the error:

```kotlin
// Bad
try { riskyOperation() } catch (e: IOException) { }

// Good
try { riskyOperation() } catch (e: IOException) {
    logger.warn("Operation failed", e)
}
```

### Using `var` Where `val` Suffices

Prefer `val` (immutable) over `var` (mutable). Only use `var` when the value genuinely changes:

```kotlin
// Bad: never reassigned
var name = person.name

// Good
val name = person.name
```

### Magic Numbers

Extract numeric literals into named constants:

```kotlin
// Bad
if (age < 18) { /* ... */ }

// Good
const val LEGAL_ADULT_AGE = 18
if (age < LEGAL_ADULT_AGE) { /* ... */ }
```

### Labeled Returns in `forEach`

When a `forEach` with labeled returns is performing pure filtering, prefer functional operations:

```kotlin
// Prefer this:
list.filterNotNull().filter { it.isNotEmpty() }.forEach { process(it) }

// Over this, when the logic is purely filtering:
list.forEach {
    if (it == null) return@forEach
    if (it.isEmpty()) return@forEach
    process(it)
}
```

When the loop body has complex control flow (stateful accumulation, side effects, multiple branches), labeled returns are the idiomatic way to express `continue` semantics in lambda-based iteration and are acceptable.

---

## 11. Tooling

### ktlint

[ktlint](https://pinterest.github.io/ktlint/) is the standard Kotlin linter and formatter. It enforces the official Kotlin coding conventions and the Android Kotlin Style Guide with zero configuration.

Key enforced rules:
- 4-space indentation (no tabs).
- No wildcard imports.
- No semicolons.
- No unused imports.
- Consistent spacing around operators, colons, braces.
- Trailing commas in multi-line declarations.
- Proper blank line usage.

```bash
# Check
ktlint "src/**/*.kt"

# Format (auto-fix)
ktlint -F "src/**/*.kt"
```

Integrate via Gradle:

```kotlin
// build.gradle.kts
plugins {
    id("org.jlleitschuh.gradle.ktlint") version "12.1.0"
}
```

### detekt

[detekt](https://detekt.dev/) is a static analysis tool that goes beyond formatting. It catches code smells, complexity issues, and potential bugs.

Key rule sets:

| Rule set | Focus |
|---|---|
| `style` | Naming, magic numbers, max line length, modifier order, wildcard imports |
| `complexity` | Cyclomatic complexity, long methods, large classes, nested blocks |
| `potential-bugs` | Unreachable code, equals/hashCode contracts, unsafe casts |
| `performance` | Unnecessary object creation, spread operator misuse |
| `exceptions` | Broad exception catching, swallowed exceptions |

Important style rules:

| Rule | What it checks | Recommended configuration |
|---|---|---|
| `MagicNumber` | Flags hardcoded numeric values | Active; ignore -1, 0, 1, 2 |
| `MaxLineLength` | Enforces line length limit | Active; set to 100 (project standard) |
| `ModifierOrder` | Ensures canonical modifier ordering | Active |
| `WildcardImport` | Prohibits `*` imports | Active |
| `ReturnCount` | Limits return statements per function | Set to 5 or disable; early returns and `when` branches are idiomatic |
| `VarCouldBeVal` | Finds `var` that should be `val` | Active |
| `UnusedParameter` | Reports unused function parameters | Active |
| `ForbiddenComment` | Flags `TODO`/`FIXME`/`STOPSHIP` markers | Active in CI to prevent shipping incomplete code |

Configure via `detekt.yml`:

```yaml
style:
  MagicNumber:
    active: true
    ignoreNumbers:
      - '-1'
      - '0'
      - '1'
      - '2'
  MaxLineLength:
    active: true
    maxLineLength: 100
  ReturnCount:
    active: true
    max: 5
  ForbiddenComment:
    active: true
    comments:
      - 'TODO'
      - 'FIXME'
      - 'STOPSHIP'
```

### IntelliJ IDEA / Android Studio Inspections

IntelliJ provides hundreds of Kotlin-specific inspections. Key ones to keep enabled:

- **Redundant visibility modifier**: flags explicit `public` when it is the default.
- **Can be replaced with single-expression function**: suggests expression body.
- **Variable is never modified and can be declared immutable**: `var` to `val`.
- **Unnecessary safe call on a non-null receiver**: `nonNullValue?.method()`.
- **Platform declaration clash**: detects JVM signature conflicts.
- **Unused symbol**: unreferenced declarations.
- **Suspicious combination of == and ===**: identity vs. equality.

### Compiler Warnings

Treat warnings as errors in CI to prevent regressions:

```kotlin
// build.gradle.kts
tasks.withType<KotlinCompile> {
    compilerOptions {
        allWarningsAsErrors.set(true)
    }
}
```

Key compiler flags:
- `-Werror`: treat all warnings as errors.
- `-opt-in=kotlin.RequiresOptIn`: enable opt-in annotations.
- `-Xjsr305=strict`: treat Java `@Nullable`/`@NotNull` annotations as strict.

---

## Quick Reference Checklist

For auditing a Kotlin implementation, verify:

- [ ] `val` used unless mutation is required
- [ ] `!!` used only where null is provably impossible and alternatives would add noise
- [ ] Null safety expressed through types (`String?` vs `String`), not runtime checks
- [ ] `require`/`check`/`error` used for preconditions, not manual `if`/`throw`
- [ ] Data classes used for data holders
- [ ] Sealed classes used for restricted hierarchies with exhaustive `when`
- [ ] Collections are read-only interfaces unless mutation is needed
- [ ] Collection variables declared with interface types (`List`, `MutableList`), not concrete classes
- [ ] String templates used instead of concatenation
- [ ] Expression body used for single-expression functions
- [ ] `when` used for three or more branches (not `if`/`else if` chains)
- [ ] Named arguments used for ambiguous parameters
- [ ] Trailing commas in multi-line declarations
- [ ] No wildcard imports
- [ ] 4-space indentation, no tabs
- [ ] Line length under 100 characters
- [ ] Scope functions chosen appropriately (no nesting, no overuse)
- [ ] `it` not used in nested lambdas
- [ ] Extension functions used where appropriate, with minimal visibility
- [ ] `const val` and deeply immutable `val` are `SCREAMING_SNAKE_CASE`; object-reference `val` are `camelCase`
- [ ] Enum constants are `SCREAMING_SNAKE_CASE`
- [ ] Modifier order follows canonical ordering
- [ ] Visibility is as restrictive as possible (`private` > `internal` > `public`)
- [ ] No empty `catch` blocks
- [ ] Specific exception types caught, not `Exception`/`Throwable`
- [ ] `.use()` for `Closeable`/`AutoCloseable` resources
- [ ] KDoc on all public API members
- [ ] Compiler warnings treated as errors
- [ ] No `TODO` markers in code targeting production

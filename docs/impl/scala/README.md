# Scala Style Guide

A comprehensive reference for idiomatic Scala coding style and best practices. Intended for code auditing Scala implementations.

## Sources

This guide synthesizes conventions from the following authoritative references:

- [Scala Style Guide](https://docs.scala-lang.org/style/) (docs.scala-lang.org)
- [Effective Scala](https://twitter.github.io/effectivescala/) (Twitter)
- [Scala 3 Book](https://docs.scala-lang.org/scala3/book/introduction.html) (docs.scala-lang.org)
- [Scala 3 Reference: Optional Braces](https://docs.scala-lang.org/scala3/reference/other-new-features/indentation.html)
- [scalafmt Configuration](https://scalameta.org/scalafmt/docs/configuration.html)
- [WartRemover](https://www.wartremover.org/)
- [Scalafix](https://scalacenter.github.io/scalafix/)

---

## 1. Naming Conventions

### Casing Rules

| Element | Casing | Example |
|---|---|---|
| Classes | UpperCamelCase | `SayableAge`, `FormatAgeTest` |
| Traits | UpperCamelCase | `StageLabel`, `Ordered` |
| Objects | UpperCamelCase | `SayableAge`, `Locales` |
| Packages | lowercase dot-separated | `sayableage`, `com.example.util` |
| Methods | lowerCamelCase | `formatAge`, `resolveUnit` |
| Values (`val`) | lowerCamelCase | `defaultLocale`, `maxRetries` |
| Variables (`var`) | lowerCamelCase | `currentIndex`, `counter` |
| Constants (in objects) | UpperCamelCase | `MaxAgeMonths`, `Version` |
| Type parameters | Single uppercase letter or UpperCamelCase | `A`, `B`, `Key`, `Value` |
| Higher-kinded type params | Single uppercase letter with `[_]` | `F[_]`, `M[_]` |
| Enums | UpperCamelCase | `PluralCategory`, `Compactness` |
| Enum cases | UpperCamelCase | `Zero`, `One`, `Small`, `Medium` |
| Annotations | lowerCamelCase | `@volatile`, `@tailrec` |

**Project-specific exception:** This project uses `UPPER_CASE` for `PluralCategory` and `Compactness` enum cases (`ZERO`, `ONE`, `NORMAL`, `SHORT`) because these are cross-language domain constants that must be recognizable across all 29 implementations. In general Scala code, UpperCamelCase is idiomatic for enum cases -- it aligns with the standard library (`Option.Some`, `Option.None`, `List.Nil`) and with how the pattern matcher treats uppercase identifiers as stable references.

### Naming Principles

- **Prefer clarity over brevity** for public APIs. Parameter names are part of the public API (callers use named arguments).
- **Short names are acceptable** for narrow scopes (loop variables, simple lambdas): `x => x * 2`.
- **Treat acronyms as words**: use `xHtml` and `maxId`, not `XHTML` and `maxID`.
- **Avoid underscores in names.** Underscores have special meaning in Scala (`_` is a wildcard, `_=` is a setter suffix). The only exception is private backing fields: `private var _name: String`.
- **Use active names for side-effecting methods**: `user.activate()`, not `user.setActive()`.

### Accessors and Mutators

Scala rejects the Java `get`/`set` convention. Follow the property-style pattern:

```scala
// Accessor: use the property name directly
def name: String

// Boolean accessor: prepend "is" when no mutator exists
def isEmpty: Boolean

// Mutator: append _= to the property name
def bar_=(value: Bar): Unit
// Enables: foo.bar = newValue
```

### Parentheses on Methods

Methods with side effects use empty parentheses. Pure accessors omit them:

```scala
// Side-effecting: use parentheses
def close(): Unit
def println(): Unit

// Pure accessor: no parentheses
def length: Int
def isEmpty: Boolean
```

Scala 3 enforces this at call sites -- you cannot call a no-parens method with `()` or vice versa.

### Symbolic Method Names

Use symbolic names only for:

- DSLs with well-known domain operators (`actor ! message`)
- Mathematically standard operations (`a + b`, `c :: d`)

If you need to explain what the method does, give it a descriptive text name instead.

### Constants vs. Values

Constants defined in objects or package objects use UpperCamelCase:

```scala
object Config:
  val MaxRetries = 3
  val DefaultTimeout = 5000
```

Regular local values and variables use lowerCamelCase:

```scala
val currentUser = getUser()
var retryCount = 0
```

---

## 2. Code Formatting

### Indentation

- Use **two spaces** per indentation level. Never use tabs.
- Target line length is **80--100 characters**. Lines beyond 100 columns should be refactored or wrapped.

### scalafmt Configuration

Every Scala project should have a `.scalafmt.conf` file. A recommended starting configuration:

```hocon
version = 3.10.7
runner.dialect = scala3

maxColumn = 100
indent.main = 2
indent.callSite = 2
indent.defnSite = 4

align.preset = some
align.stripMargin = true
assumeStandardLibraryStripMargin = true

newlines.source = keep
newlines.beforeMultiline = fold
```

Key settings:

| Setting | Purpose | Recommended |
|---|---|---|
| `version` | scalafmt version (required) | Latest stable |
| `runner.dialect` | Scala version dialect | `scala3`, `scala213` |
| `maxColumn` | Maximum line width | 80--100 |
| `indent.main` | Primary indentation | 2 |
| `align.preset` | Vertical alignment level | `some` or `none` |
| `newlines.source` | How to handle existing line breaks | `keep` |

**A note on `align.preset`:** The `more` preset vertically aligns `=`, `=>`, `<-`, and other tokens across adjacent lines. This improves readability in isolation but creates noisy git diffs -- adding or removing one line can cause the formatter to realign every adjacent line, making diffs misleading and `git blame` less useful. Prefer `some` (aligns only `=>` in case expressions and `<-` in for-comprehensions) or `none` for projects that prioritize reviewable diffs.

### Line Wrapping

When a single expression exceeds the column limit, prefer extracting intermediate values over wrapping:

```scala
// Preferred: extract intermediate values
val ageInMonths = calculateMonths(dateOfBirth, asOf)
val formattedAge = formatMonths(ageInMonths, locale)

// Acceptable: wrap with 2-space continuation indent
val result = 1 + 2 + 3 + 4 +
  5 + 6 + 7 + 8
```

For methods with many parameters (five or more), place each on its own line:

```scala
val locale = AgeLocale(
  code = "en",
  plural = englishPlural,
  units = defaultUnits,
  half = "\u00bd",
  delimiter = ", ",
  justBorn = "newborn",
  stages = defaultStages,
)
```

### Import Ordering

- Sort imports alphabetically.
- Use braces for multiple imports from one package; use wildcards (`*`) for six or more names from the same package.
- Qualify mutable collection types explicitly to distinguish from immutable.
- In test files, wildcard imports for assertion libraries (e.g., `import org.scalatest.Assertions.*`) are acceptable.

```scala
import java.time.LocalDate
import java.time.temporal.ChronoUnit
import scala.collection.mutable

// Use qualified mutable reference
val buffer = mutable.ArrayBuffer[String]()
```

### Braces vs. Indentation Syntax (Scala 3)

Scala 3 supports optional braces with indentation-based syntax. A colon at the end of a line replaces the opening brace for class, trait, object, and enum bodies:

```scala
// Indentation syntax (Scala 3)
class SayableAge(locale: AgeLocale):
  def formatAge(dob: String): Option[String] =
    parseAge(dob).map { age =>
      formatMonths(age.months)
    }

// Brace syntax (works in both Scala 2 and 3)
class SayableAge(locale: AgeLocale) {
  def formatAge(dob: String): Option[String] =
    parseAge(dob).map { age =>
      formatMonths(age.months)
    }
}
```

Pick one style and be consistent within a project. If using indentation syntax, use `end` markers for constructs exceeding 15--20 lines or nested 4+ levels deep:

```scala
def largeMethod(args: Args): Result =
  // ... many lines ...
  if condition then
    // ... large block ...
  end if
  // ... more code ...
end largeMethod
```

### Comments

- Use `//` for single-line comments, not `/* */`.
- Place comments on their own line, not trailing code.
- **Comments should explain "why", not "what."** If code needs a "what" comment, extract it into a named function or variable.
- Use Scaladoc (`/** ... */`) for all public types and methods.

### Scaladoc

Three acceptable formats:

```scala
/** Short one-liner for simple descriptions. */
def simple: Unit = ()

/** Returns the formatted age string.
 *
 * Formats the age based on the locale's plural rules
 * and stage thresholds.
 *
 * @param dateOfBirth ISO 8601 date string (YYYY-MM-DD)
 * @param asOf        reference date for age calculation
 * @return formatted age string, or None if input is invalid
 */
def formatAge(dateOfBirth: String, asOf: String): Option[String]
```

Guidelines:

- First sentence summarizes what the method returns or does.
- Use active voice: "Returns the result" not "The result is returned".
- Document all `@param` and `@tparam` parameters.
- Link to other types with `[[scala.Option]]` syntax.
- Use single-space after `*` consistently. This matches what scalafmt produces.

---

## 3. Type System

### Case Classes

Use case classes for immutable data types. The compiler generates `equals`, `hashCode`, `toString`, `copy`, `apply`, and `unapply`:

```scala
case class AgeComponents(months: Int, diffDays: Int)

val age = AgeComponents(months = 14, diffDays = 420)
val updated = age.copy(months = 15)
```

Case class fields are `val` by default (immutable). Never use `var` in case classes.

### Sealed Traits and Enums

Use sealed traits (or Scala 3 enums) to model algebraic data types (sum types). The compiler checks for exhaustive pattern matches:

```scala
// Sealed trait hierarchy
sealed trait StageLabel:
  def resolve(gender: Option[String] = None): String

object StageLabel:
  case class Neutral(label: String) extends StageLabel:
    def resolve(gender: Option[String]): String = label

  case class Gendered(m: String, f: String) extends StageLabel:
    def resolve(gender: Option[String]): String =
      if gender.contains("f") then f else m
```

```scala
// Scala 3 enums for simple sum types
enum PluralCategory:
  case Zero, One, Two, Few, Many, Other

enum Compactness:
  case Normal, Short, Compact
```

Enums with parameters:

```scala
enum Color(val rgb: Int):
  case Red   extends Color(0xFF0000)
  case Green extends Color(0x00FF00)
  case Blue  extends Color(0x0000FF)
```

### Opaque Types (Scala 3)

Use opaque types for zero-overhead type safety. The underlying type is hidden outside the defining scope:

```scala
object Types:
  opaque type Months = Int

  object Months:
    def apply(n: Int): Months = n

  extension (m: Months)
    def value: Int = m
    def + (other: Months): Months = m + other
```

Prefer opaque types over value classes (`extends AnyVal`) for new code -- they have no boxing overhead and no restrictions on the underlying type.

### Type Aliases

Use type aliases to clarify intent, but avoid them for self-explanatory types:

```scala
// Good: clarifies the purpose
type PluralRule = Int => PluralCategory
type FormatNumber = Int => String

// Unnecessary: adds no clarity
type StringList = List[String]  // avoid
```

### Generics and Variance

- Immutable collections should be covariant (`+A`): `List[+A]`, `Option[+A]`.
- Mutable collections should be invariant: no variance annotation.
- Use descriptive type parameter names for multi-parameter generics:

```scala
class Map[Key, Value]           // clear
class Map[K, V]                 // acceptable for well-known patterns
class Function1[-Input, +Output] // variance annotations
```

### Type Annotations

- **Always annotate public methods** with explicit return types. This documents the API, improves compile times, and prevents accidental type changes.
- **Omit types for private and local values** when the assigned value makes the type obvious.
- **Annotate complex expressions** where the inferred type is non-obvious.

```scala
// Public method: always annotate
def formatAge(dob: String): Option[String] = ...

// Private with obvious type: omit
private val maxMonths = 6000

// Complex expression: annotate
private val localeMap: Map[String, AgeLocale] =
  locales.map(l => l.code -> l).toMap
```

### Structural Types

In Scala 2, structural types use runtime reflection and should be avoided in production code. In Scala 3, structural types can be implemented without reflection using `Selectable`, which compiles to direct field access. Even so, use them sparingly -- they bypass the compiler's nominal type checking and make code harder to trace.

---

## 4. Class Design

### Case Classes for Data

Use case classes for immutable data containers. They provide value equality, pattern matching, and the `copy` method out of the box:

```scala
case class Units(
  day: UnitForms,
  week: UnitForms,
  month: UnitForms,
  year: UnitForms,
)

case class AgeLocale(
  code: String,
  plural: Int => PluralCategory,
  units: Units,
  half: String,
  delimiter: String,
  justBorn: String,
  stages: Stages,
  short: Option[CompactnessOverride] = None,
  compact: Option[CompactnessOverride] = None,
)
```

### Objects (Singletons)

Use objects for:

- **Utility functions** that need no instance state
- **Factory methods** (companion objects)
- **Constants and configuration**

```scala
object StringUtils:
  def truncate(s: String, length: Int): String = s.take(length)
  def containsWhitespace(s: String): Boolean = s.matches(".*\\s.*")
```

### Companion Objects

Place factory methods and shared logic in the companion object. Companion objects can access private members of their companion class:

```scala
class SayableAge(locale: AgeLocale, compactness: Compactness = Compactness.Normal):
  def formatAge(dateOfBirth: String, asOf: Option[String] = None): Option[String] = ...

object SayableAge:
  private lazy val defaultInstance: SayableAge = new SayableAge(Locales.EN)

  def formatAge(dateOfBirth: String, asOf: Option[String] = None): Option[String] =
    defaultInstance.formatAge(dateOfBirth, asOf)
```

**Project-specific note:** The sayable-age codebase uses `asOf: String = null` instead of `Option[String]` for cross-language API consistency. This is a deliberate trade-off, not idiomatic Scala. If you encounter this pattern, note that the `null` should be wrapped with `Option(asOf)` immediately at the boundary. In new Scala code without cross-language constraints, always prefer `Option[String]` with a default of `None`.

### Traits for Composition

Keep traits short and focused. Prefer multiple small traits over monolithic ones:

```scala
trait HasCode:
  def code: String

trait HasPluralRules:
  def plural(n: Int): PluralCategory
```

Scala 3 traits support parameters:

```scala
trait Greetable(name: String):
  def greeting: String
```

### apply and unapply

The `apply` method enables construction without `new`. For case classes, it is auto-generated. For regular classes, define it in the companion object:

```scala
object Circle:
  def apply(radius: Double): Circle = new Circle(radius)
```

The `unapply` method enables pattern matching. Case classes generate it automatically. Write custom extractors only when the destruction pattern differs from construction.

### Constructor Parameter Lists

Keep constructors on one line when they fit within the column limit. When they exceed it, place each parameter on its own line with a trailing comma:

```scala
// Fits on one line
class Person(name: String, age: Int)

// Exceeds column limit: one param per line
class Person(
  name: String,
  age: Int,
  birthdate: LocalDate,
  favoriteColor: Color,
) extends Entity
  with Logging
  with Serializable:

  def firstMethod: Foo = ...
```

### Modifier Ordering

When multiple modifiers appear, order them as:

1. Annotations (each on a separate line)
2. `override`
3. Access modifier (`protected`, `private`)
4. `implicit` / `given`
5. `final`
6. `def` / `val` / `var` / `lazy val`

```scala
@tailrec
override protected final def traverse(node: Node): Unit = ...
```

---

## 5. Functional Patterns

### Immutability

Default to `val` over `var`. Mutable state should be the exception, not the rule:

```scala
// Preferred: immutable
val names = List("Alice", "Bob", "Charlie")
val updated = names :+ "Diana"

// Avoid unless necessary
var counter = 0
counter += 1
```

### Pattern Matching

Pattern matching is one of Scala's most powerful features. Use it for:

**Destructuring case classes:**

```scala
age match
  case AgeComponents(months, diffDays) if diffDays == 0 => justBorn
  case AgeComponents(months, diffDays) if diffDays < 7  => formatDays(diffDays)
  case AgeComponents(months, _) if months < 3           => formatWeeks(age)
  case AgeComponents(months, _)                         => formatMonths(months)
```

**Sealed trait hierarchies (exhaustive matching):**

```scala
label match
  case StageLabel.Neutral(text)    => text
  case StageLabel.Gendered(m, f)   => if gender == "f" then f else m
```

**Option handling:**

```scala
parseAge(dob) match
  case Some(age) => formatAge(age)
  case None      => "unknown"
```

**Type matching:**

```scala
def describe(x: Matchable): String = x match
  case s: String  => s"String: $s"
  case i: Int     => s"Int: $i"
  case l: List[?] => s"List of ${l.size} elements"
  case _          => "unknown"
```

Always include a wildcard `_` case or ensure exhaustive coverage with sealed types.

### For-Comprehensions

Use for-comprehensions to chain operations on monadic types (`Option`, `Either`, `Try`, `List`):

```scala
// Chaining Option operations
val result = for
  a <- makeInt(stringA)
  b <- makeInt(stringB)
  c <- makeInt(stringC)
yield a + b + c

// Single generator: use parentheses
for (i <- 0 to 10) yield i * 2

// Multiple generators: use braces or indentation
for
  x <- board.rows
  y <- board.files
  if isValid(x, y)
yield (x, y)
```

For loops without `yield` (side-effecting), use parentheses:

```scala
for (item <- items) println(item)
```

### Higher-Order Functions

Pass functions as values. Use concise lambda syntax:

```scala
// Full lambda
names.map(name => name.toUpperCase)

// Placeholder syntax for simple cases
names.map(_.toUpperCase)
names.filter(_.length > 3)
nums.foldLeft(0)(_ + _)

// Method reference when a named method exists
names.map(formatName)
```

Place function parameters last in multi-parameter-list methods to enable clean call-site syntax:

```scala
def withRetry[A](maxAttempts: Int)(block: => A): A = ...

// Clean call site
val result = withRetry(3) {
  fetchData()
}
```

### Partial Functions

Use partial functions for selective handling:

```scala
val handler: PartialFunction[Event, Unit] =
  case Click(x, y) => handleClick(x, y)
  case KeyPress(c)  => handleKey(c)

// Compose with orElse for fallback chains
val fullHandler = primaryHandler orElse fallbackHandler
```

### Tail Recursion

Annotate methods that are intended to be tail-recursive with `@tailrec`. This is a verification annotation -- the compiler will error if the method is not actually tail-recursive:

```scala
import scala.annotation.tailrec

@tailrec
def factorial(n: Int, acc: Int = 1): Int =
  if n <= 1 then acc
  else factorial(n - 1, n * acc)
```

Not all recursive methods are tail-recursive, and not all should be. Tree traversals, divide-and-conquer algorithms, and other naturally recursive patterns should be expressed as regular recursion. Use `@tailrec` only on methods where tail-call optimization is intended and necessary.

### Boundary and Break (Scala 3.3+)

For early exit from loops or nested computations, use `boundary`/`break` instead of `return`. This is the modern, safe alternative that does not break referential transparency:

```scala
import scala.util.boundary, boundary.break

def safeAtoi(s: String): Option[Int] =
  boundary:
    var n = 0
    var i = 0
    while i < s.length do
      val c = s.charAt(i)
      if c < '0' || c > '9' then break(None)
      n = n * 10 + (c - '0')
      i += 1
    Some(n)
```

`boundary`/`break` is scoped, type-safe, and works correctly inside closures and lambdas (unlike `return`). Prefer it for any new code that needs early exit.

Alternatively, express the same logic with tail recursion to avoid mutation entirely:

```scala
@tailrec
private def safeAtoi(s: String, i: Int = 0, acc: Int = 0): Option[Int] =
  if i >= s.length then Some(acc)
  else
    val c = s.charAt(i)
    if c < '0' || c > '9' then None
    else safeAtoi(s, i + 1, acc * 10 + (c - '0'))
```

---

## 6. Collections

### Immutable vs. Mutable

Default to immutable collections. They are referentially transparent and thread-safe:

```scala
// Immutable (default imports)
val names = List("Alice", "Bob")
val ages = Map("Alice" -> 30, "Bob" -> 25)
val ids = Set(1, 2, 3)

// Mutable: qualify explicitly
import scala.collection.mutable
val buffer = mutable.ArrayBuffer[String]()
buffer += "Alice"
```

### Choosing the Right Collection

| Need | Immutable | Mutable |
|---|---|---|
| Indexed random access | `Vector` | `ArrayBuffer` |
| Prepend-heavy linked list | `List` | `ListBuffer` |
| Key-value pairs | `Map` | `mutable.Map` |
| Unique elements | `Set` | `mutable.Set` |
| Lazy evaluation | `LazyList` | -- |

Decision rules:

- Use **`List`** when the algorithm is primarily prepend-based, iterate-only, or pattern-matches on `head :: tail`. For small, fixed collections this is the natural choice.
- Use **`Vector`** when indexed access or both-end operations (append and prepend) are needed. Its effectively-constant-time random access makes it appropriate for collections that will be indexed into.
- Use **`ArrayBuffer`** when building a collection incrementally with mutation.
- In method signatures, prefer the most specific collection trait that matches the required access pattern: **`IndexedSeq`** for indexed access, **`Iterable`** for iteration-only, or the concrete type if performance characteristics matter. Avoid bare `Seq` in public APIs -- it provides no performance guarantees, and code that indexes into a `Seq` that happens to be a `List` will be accidentally quadratic.

### Collection Operations

Prefer functional transformations over imperative loops:

```scala
// Preferred: functional pipeline
val result = items
  .filter(_.isActive)
  .map(_.name)
  .sorted
  .distinct

// Avoid: imperative accumulation
var result = List.empty[String]
for (item <- items)
  if (item.isActive)
    result = result :+ item.name
result = result.sorted.distinct
```

Common operations:

```scala
// Transforming
list.map(_ * 2)
list.flatMap(x => List(x, x * 2))
list.collect { case n if n > 0 => n.toString }

// Filtering
list.filter(_ > 0)
list.filterNot(_.isEmpty)
list.partition(_ > 0)  // (positives, nonPositives)

// Folding
list.foldLeft(0)(_ + _)
list.reduceOption(_ + _)  // safe: returns Option

// Grouping
items.groupBy(_.category)
items.groupMap(_.category)(_.name)

// Zipping
keys.zip(values).toMap
list.zipWithIndex
```

### Avoid Partial Collection Methods

Prefer safe alternatives over methods that throw on empty collections:

```scala
// Unsafe: throws on empty
list.head
list.tail
list.reduce(_ + _)

// Safe alternatives
list.headOption
list.drop(1)
list.reduceOption(_ + _)
```

---

## 7. Error Handling

### Option

Use `Option` to represent the possible absence of a value. Never use `null`:

```scala
def findUser(id: Int): Option[User] =
  users.find(_.id == id)

// Pattern matching
findUser(42) match
  case Some(user) => println(user.name)
  case None       => println("not found")

// Functional methods
findUser(42)
  .map(_.name)
  .getOrElse("unknown")

// for-comprehension
for
  user <- findUser(42)
  email <- user.emailAddress
yield sendEmail(email)
```

Never call `.get` on an `Option`. It throws `NoSuchElementException` on `None`:

```scala
// WRONG: throws on None
val name = optionalUser.get.name

// RIGHT: use getOrElse, fold, or pattern matching
val name = optionalUser.map(_.name).getOrElse("unknown")
val name = optionalUser.fold("unknown")(_.name)
```

**Clarification:** The prohibition is on `Option.get`, `Try.get`, and `Either` projection `.get` -- these are partial methods that throw on the failure case. `Map.get(key)` is safe (it returns `Option`) and is not subject to this rule.

### Either

Use `Either[Error, Success]` when you need to carry error information. By convention, `Left` is the error case and `Right` is the success case:

```scala
def parseInt(s: String): Either[String, Int] =
  try Right(s.trim.toInt)
  catch case _: NumberFormatException => Left(s"Invalid integer: $s")

// Pattern matching
parseInt("42") match
  case Right(n)    => println(n)
  case Left(error) => println(s"Error: $error")

// for-comprehension (Right-biased in Scala 2.12+)
val result = for
  a <- parseInt(inputA)
  b <- parseInt(inputB)
yield a + b
```

### Try

Use `Try` for wrapping operations that may throw exceptions (I/O, parsing, external libraries):

```scala
import scala.util.{Try, Success, Failure}

def readFile(path: String): Try[String] =
  Try(scala.io.Source.fromFile(path).mkString)

readFile("data.txt") match
  case Success(content) => process(content)
  case Failure(ex)      => log(s"Failed: ${ex.getMessage}")

// Functional chaining
readFile("data.txt")
  .map(parse)
  .recover { case _: FileNotFoundException => defaultData }
  .getOrElse(fallback)
```

### General Principles

- Encode expected failure modes explicitly using `Option`, `Either`, or `Try`. Reserve exceptions for truly exceptional conditions.
- When catching exceptions, use `scala.util.control.NonFatal` to avoid swallowing fatal errors:

```scala
import scala.util.control.NonFatal

try dangerousOperation()
catch case NonFatal(e) => handleError(e)
```

- Return `Option` for "might not exist" semantics.
- Return `Either` when callers need to know the reason for failure.
- Return `Try` when wrapping code that throws (interop with Java libraries).

---

## 8. Implicits and Givens

### Scala 3: given and using

Scala 3 replaces `implicit` with `given` (for defining instances) and `using` (for requesting them):

```scala
// Define a given instance
given defaultLocale: AgeLocale = Locales.EN

// Request it with a using clause
def formatAge(dob: String)(using locale: AgeLocale): String = ...

// The compiler fills in the given instance automatically
formatAge("2020-01-15")

// Explicitly pass when needed
formatAge("2020-01-15")(using customLocale)
```

You can omit the parameter name when you only summon the instance:

```scala
def formatAge(dob: String)(using AgeLocale): String =
  val locale = summon[AgeLocale]
  ...
```

### Importing Givens (Scala 3)

In Scala 3, given instances are not imported by regular wildcard imports. You must use `given` imports:

```scala
// Import all givens from a scope
import sayableage.given

// Import only specific given types
import sayableage.{given AgeLocale}

// Import both regular members and givens
import sayableage.{*, given}
```

This is a common source of confusion for developers migrating from Scala 2, where `import pkg._` brought implicit values into scope automatically.

### Extension Methods (Scala 3)

Extension methods add functionality to existing types without modifying them:

```scala
extension (s: String)
  def toOption: Option[String] =
    if s == null || s.isEmpty then None else Some(s)

// Usage
"hello".toOption  // Some("hello")
"".toOption       // None
```

Define multiple extensions in a single block:

```scala
extension (n: Int)
  def isEven: Boolean = n % 2 == 0
  def isOdd: Boolean = n % 2 != 0
  def days: Duration = Duration.ofDays(n)
```

### Type Classes

Combine traits, given instances, and extension methods to implement the type class pattern:

```scala
trait Show[A]:
  def show(a: A): String

given Show[Int] with
  def show(a: Int): String = a.toString

given Show[AgeLocale] with
  def show(a: AgeLocale): String = s"AgeLocale(${a.code})"

extension [A](a: A)(using s: Show[A])
  def show: String = s.show(a)

// Usage
42.show              // "42"
Locales.EN.show      // "AgeLocale(en)"
```

### Scala 2: implicit

In Scala 2, `implicit` serves multiple roles. Use it sparingly and document clearly:

```scala
// Implicit parameter (Scala 2 equivalent of using)
def formatAge(dob: String)(implicit locale: AgeLocale): String = ...

// Implicit class (Scala 2 equivalent of extension methods)
implicit class StringOps(val s: String) extends AnyVal:
  def toOption: Option[String] = if s.isEmpty then None else Some(s)

// Implicit value (Scala 2 equivalent of given)
implicit val defaultLocale: AgeLocale = Locales.EN
```

### When to Use Context Abstractions

Use `given`/`using` (or `implicit`) for:

- **Type class instances** (`Ordering`, `Show`, `Codec`)
- **Configuration / context propagation** (`ExecutionContext`, `Locale`)
- **Adapter patterns** (converting between types in a controlled way)

Avoid using them for:

- **Conversions between unrelated types** (use explicit conversions instead)
- **Anything that surprises the reader** (if the behavior is not obvious, make it explicit)

---

## 9. Common Idioms

### case class copy

Use `copy` for immutable updates:

```scala
case class Config(host: String, port: Int, debug: Boolean)

val prod = Config("prod.example.com", 443, debug = false)
val dev = prod.copy(host = "localhost", port = 8080, debug = true)
```

### Sealed Hierarchies for Exhaustive Matching

Model closed sets of variants with sealed traits or enums. The compiler warns about non-exhaustive matches:

```scala
sealed trait Shape
case class Circle(radius: Double) extends Shape
case class Rectangle(width: Double, height: Double) extends Shape
case class Triangle(base: Double, height: Double) extends Shape

def area(s: Shape): Double = s match
  case Circle(r)         => math.Pi * r * r
  case Rectangle(w, h)   => w * h
  case Triangle(b, h)    => 0.5 * b * h
  // No default needed: compiler knows all cases are covered
```

### String Interpolation

Use the `s` interpolator for string building. Prefer it over concatenation:

```scala
// s-interpolator: variable substitution
val msg = s"${name} is ${age} years old"

// Expressions in braces
val msg = s"Result: ${a + b}"

// f-interpolator: printf-style formatting
val msg = f"Pi is approximately ${math.Pi}%.4f"

// raw interpolator: no escape processing
val path = raw"C:\Users\name\docs"

// Multi-line with stripMargin
val json = s"""
  |{
  |  "name": "${name}",
  |  "age": ${age}
  |}""".stripMargin
```

### lazy val

Use `lazy val` for expensive computations that may not be needed, or for breaking initialization cycles:

```scala
object SayableAge:
  // Initialized on first access, not at class load
  private lazy val defaultInstance: SayableAge = new SayableAge(Locales.EN)
```

Be aware that `lazy val` uses synchronized access under the hood. In hot paths, prefer eager initialization or `by-name` parameters.

### By-Name Parameters

Use by-name parameters (`=> T`) for arguments that should be evaluated lazily or conditionally:

```scala
def unless(condition: Boolean)(block: => Unit): Unit =
  if !condition then block

// The block is only evaluated if condition is false
unless(list.isEmpty) {
  println(s"List has ${list.size} elements")
}
```

Common in logging, assertions, and custom control structures:

```scala
def debug(msg: => String): Unit =
  if debugEnabled then println(msg)

// The string interpolation only happens if debug is enabled
debug(s"Processing ${expensiveComputation()}")
```

### Option Construction from Nullable Values

Use `Option(value)` to safely wrap potentially null values (common at Java interop boundaries):

```scala
val asOfOpt = Option(asOf)  // None if asOf is null, Some(asOf) otherwise
```

### Match on the Method Body

When a method body is a single `match` expression, omit braces around the match:

```scala
// Correct: match directly
def stageKey(months: Int): String = months match
  case m if m < 2   => "newborn"
  case m if m < 12  => "infant"
  case m if m < 36  => "toddler"
  case _             => "adult"

// Wrong: unnecessary braces wrapping the match
def stageKey(months: Int): String = {
  months match {
    case m if m < 2 => "newborn"
    ...
  }
}
```

---

## 10. Things to Avoid

### null

Never use `null` in Scala code. Use `Option` instead:

```scala
// WRONG
def find(id: Int): User = if exists(id) then getUser(id) else null

// RIGHT
def find(id: Int): Option[User] = if exists(id) then Some(getUser(id)) else None
```

The only acceptable use of `null` is at Java interop boundaries, immediately wrapped with `Option(value)`.

**Project-specific exception:** The sayable-age codebase uses `null` as a default parameter value in public API methods (`asOf: String = null`) for cross-language API consistency. This is wrapped with `Option(asOf)` at the method boundary. In new Scala code without cross-language constraints, use `Option[String] = None` instead.

### return Statements

Avoid explicit `return`. In Scala, the last expression in a block is the return value. Using `return` breaks referential transparency and interacts poorly with closures and lambdas:

```scala
// WRONG
def add(a: Int, b: Int): Int = {
  return a + b
}

// RIGHT
def add(a: Int, b: Int): Int = a + b
```

For early exit from imperative loops, use `boundary`/`break` (Scala 3.3+) instead of `return`. See Section 5 (Boundary and Break).

**Narrow exception:** In Scala versions before 3.3 where `boundary`/`break` is unavailable, `return` inside a `while` loop in a private method is tolerable when the alternative is significantly less readable. This should not appear in public APIs.

### Mutable vars

Minimize `var` usage. When mutation is needed (performance-critical loops, local accumulators), keep the scope as narrow as possible and prefer `boundary`/`break` or tail recursion to avoid the need for mutable state:

```scala
// Preferred: tail recursion avoids mutation entirely
@tailrec
private def safeAtoi(s: String, i: Int = 0, acc: Int = 0): Option[Int] =
  if i >= s.length then Some(acc)
  else
    val c = s.charAt(i)
    if c < '0' || c > '9' then None
    else safeAtoi(s, i + 1, acc * 10 + (c - '0'))

// Acceptable: local mutation with boundary/break (Scala 3.3+)
private def safeAtoi(s: String): Option[Int] =
  boundary:
    var n = 0
    var i = 0
    while i < s.length do
      val c = s.charAt(i)
      if c < '0' || c > '9' then break(None)
      n = n * 10 + (c - '0')
      i += 1
    Some(n)
```

Prefer functional alternatives when they are comparably readable and performant.

### Procedure Syntax (Scala 2)

Never use the deprecated procedure syntax (methods without `=` that return `Unit`):

```scala
// WRONG: deprecated procedure syntax
def printResult(r: String) {
  println(r)
}

// RIGHT: explicit Unit return type
def printResult(r: String): Unit =
  println(r)
```

### Any/AnyRef Casts

Avoid `asInstanceOf` and `isInstanceOf`. Use pattern matching instead:

```scala
// WRONG: unsafe cast
val n = value.asInstanceOf[Int]

// RIGHT: pattern match
value match
  case n: Int => process(n)
  case _      => handleError()
```

### Throwing Exceptions for Expected Failures

Do not throw exceptions for conditions callers are expected to handle. Use `Option`, `Either`, or `Try`:

```scala
// WRONG: throws for expected invalid input
def parseAge(s: String): Int =
  if s.isEmpty then throw new IllegalArgumentException("empty")
  s.toInt

// RIGHT: returns Option for expected invalid input
def parseAge(s: String): Option[Int] =
  if s.isEmpty then None
  else Try(s.toInt).toOption
```

### Wildcard Imports in Production Code

Avoid `import pkg.*` (or `import pkg._` in Scala 2) in production code unless importing from a companion object, enum, or a small well-scoped object. Wildcard imports obscure which names are in scope.

Wildcard imports are acceptable for:

- Companion objects and enum members
- Test assertion libraries (`import org.scalatest.Assertions.*`)
- Well-known DSLs with a small, stable surface area
- Any package where you import six or more names (per Section 2, Import Ordering)

### Implicit Conversions

Avoid implicit conversions between unrelated types. They make code harder to understand and debug. Use extension methods instead:

```scala
// WRONG: implicit conversion
implicit def stringToInt(s: String): Int = s.toInt

// RIGHT: explicit conversion or extension method
extension (s: String)
  def toIntOption: Option[Int] = Try(s.toInt).toOption
```

### Other Anti-Patterns

- **`.get` on `Option`, `Try`, or `Either` projections.** These throw on failure. Use `getOrElse`, `fold`, or pattern matching. (Note: `Map.get(key)` is safe -- it returns `Option`.)
- **`Enumeration`** (the old `scala.Enumeration` trait). Use Scala 3 `enum` or sealed trait hierarchies instead -- `Enumeration` lacks exhaustive match checking and relies on reflection.
- **Overloading** when default parameters suffice. Method overloading complicates type inference and makes methods harder to pass as function values.
- **`???` in production code.** The `???` placeholder throws `NotImplementedError`. Use it only during development.
- **String concatenation with `+`.** Use string interpolation (`s"..."`) instead.
- **`while` loops when a functional alternative is clearer.** Prefer `map`, `filter`, `fold`, and recursion. Use `while` only when performance requires it.

---

## 11. Tooling

### scalafmt

The standard Scala code formatter. Integrates with sbt, Gradle, Maven, IntelliJ, VS Code, and CI pipelines.

- **Configuration:** `.scalafmt.conf` at project root (see Section 2)
- **sbt plugin:** `addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.5.2")`
- **Check in CI:** `sbt scalafmtCheckAll`
- **Format:** `sbt scalafmtAll`

Reference: [scalafmt.org](https://scalameta.org/scalafmt/)

### Scalafix

A refactoring and linting tool. Provides both built-in and community rules for code quality.

- **sbt plugin:** `addSbtPlugin("ch.epfl.scala" % "sbt-scalafix" % "0.12.1")`
- **Run rules:** `sbt scalafix`
- **Check in CI:** `sbt "scalafix --check"`

Common rules:

| Rule | Purpose |
|---|---|
| `RemoveUnused` | Remove unused imports and local definitions |
| `OrganizeImports` | Sort and group imports consistently |
| `LeakingImplicitClassVal` | Prevent leaking the underlying val in implicit classes |
| `NoAutoTupling` | Forbid auto-tupling of method arguments |

Reference: [scalacenter.github.io/scalafix](https://scalacenter.github.io/scalafix/)

### WartRemover

A Scala compiler plugin that detects common programming errors. Particularly valuable for enforcing functional programming discipline.

- **sbt plugin:** `addSbtPlugin("org.wartremover" % "sbt-wartremover" % "3.2.5")`
- **Enable all safe warts:** `wartremoverErrors ++= Warts.unsafe`

Key warts:

| Wart | Detects |
|---|---|
| `Null` | Usage of `null` values |
| `Return` | Explicit `return` statements |
| `Var` | Mutable variable declarations |
| `AsInstanceOf` | Unsafe type casts |
| `IsInstanceOf` | Type checks (use pattern matching) |
| `OptionPartial` | Calling `.get` on `Option` |
| `TryPartial` | Calling `.get` on `Try` |
| `Throw` | Throw expressions (prefer `Either`) |
| `StringPlusAny` | Implicit `.toString` in string concatenation |
| `Enumeration` | Usage of `scala.Enumeration` |
| `MutableDataStructures` | Usage of `scala.collection.mutable` |
| `NonUnitStatements` | Statements that discard non-Unit values |
| `Any` | Inferred `Any` type |

Reference: [wartremover.org](https://www.wartremover.org/)

### Metals (Language Server)

Metals is the Scala language server for VS Code, Vim/Neovim, Emacs, and Sublime Text. It provides:

- Code navigation (go to definition, find references)
- Type information on hover
- Completions with type signatures
- Automatic import management
- Inline error reporting
- Worksheet evaluation

Reference: [scalameta.org/metals](https://scalameta.org/metals/)

### Compiler Warnings

Enable and treat warnings as errors in CI. Key compiler flags:

```scala
// build.sbt
scalacOptions ++= Seq(
  "-deprecation",           // Warn on deprecated API usage
  "-feature",               // Warn on use of features requiring explicit import
  "-unchecked",             // Warn on unchecked type parameters
  "-Wunused:all",           // Warn on unused imports, values, parameters
  "-Wvalue-discard",        // Warn when non-Unit values are discarded
  "-Xfatal-warnings",       // Treat warnings as errors
)
```

For Scala 3 specifically:

```scala
scalacOptions ++= Seq(
  "-deprecation",
  "-feature",
  "-unchecked",
  "-Wunused:all",
  "-Wvalue-discard",
  "-Xfatal-warnings",
  "-new-syntax",            // Require Scala 3 syntax
  "-indent",                // Enable indentation-based syntax
)
```

### sbt

The standard Scala build tool. Key commands:

| Command | Purpose |
|---|---|
| `sbt compile` | Compile main sources |
| `sbt test` | Run all tests |
| `sbt test:compile` | Compile test sources without running |
| `sbt scalafmtAll` | Format all source files |
| `sbt scalafmtCheckAll` | Check formatting without changing files |
| `sbt scalafix` | Run Scalafix rules |
| `sbt clean` | Remove compiled artifacts |
| `sbt console` | Start a REPL with project classpath |

### Gradle (Alternative)

For projects using Gradle (as in this repository), configure Scala compilation in `build.gradle.kts`:

```kotlin
plugins {
    scala
}

dependencies {
    implementation("org.scala-lang:scala3-library_3:3.3.1")
    testImplementation("org.scalatest:scalatest_3:3.2.18")
}

tasks.withType<ScalaCompile> {
    scalaCompileOptions.additionalParameters = listOf(
        "-deprecation",
        "-feature",
        "-unchecked",
    )
}
```

---

## Quick Reference Checklist

For auditing a Scala implementation, verify:

- [ ] Naming follows conventions (UpperCamelCase for types/objects, lowerCamelCase for methods/values)
- [ ] No underscores in names (except private backing fields `_name`)
- [ ] Public methods have explicit return type annotations
- [ ] Case classes used for immutable data types (no `var` fields)
- [ ] Sealed traits or enums used for algebraic data types
- [ ] Pattern matches are exhaustive (no missing cases on sealed types)
- [ ] `Option` used instead of `null` for absent values
- [ ] No `.get` calls on `Option`, `Try`, or `Either` projections (`Map.get` is fine -- it returns `Option`)
- [ ] No explicit `return` statements (use `boundary`/`break` for early exit)
- [ ] No deprecated procedure syntax (methods without `=`)
- [ ] No `asInstanceOf` or `isInstanceOf` (use pattern matching)
- [ ] Immutable collections by default; mutable collections qualified with `mutable.`
- [ ] Functional transformations preferred over imperative loops
- [ ] String interpolation used instead of `+` concatenation
- [ ] `lazy val` used appropriately (expensive initialization, not in hot paths)
- [ ] For-comprehensions used for chaining monadic operations
- [ ] `@tailrec` annotation on methods intended to be tail-recursive
- [ ] Two-space indentation, no tabs
- [ ] scalafmt configuration present and applied
- [ ] Compiler warnings enabled and clean (zero warnings in CI)
- [ ] Scaladoc on all public types and methods
- [ ] Constants use UpperCamelCase, not SCREAMING_SNAKE_CASE
- [ ] No wildcard imports in production code (except companions, enums, and test assertions)
- [ ] Given instances imported with `import pkg.given` (Scala 3)

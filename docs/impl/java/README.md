# Java Style Guide

A comprehensive, actionable reference for writing idiomatic Java. This guide synthesizes conventions from the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html), [Oracle Code Conventions](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html), [Effective Java](https://www.oreilly.com/library/view/effective-java/9780134686097/) (3rd ed., Joshua Bloch), and the [OpenJDK Developer's Guide](https://openjdk.org/guide/). Where sources conflict, this guide follows the Google Java Style Guide unless noted.

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System](#3-type-system)
4. [Class Design](#4-class-design)
5. [Collections](#5-collections)
6. [Error Handling](#6-error-handling)
7. [Streams and Lambdas](#7-streams-and-lambdas)
8. [String Handling](#8-string-handling)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)

---

## 1. Naming Conventions

Good names eliminate the need for comments explaining *what* something is. Every identifier uses only ASCII letters and digits, with no special prefixes or suffixes (`m_`, `s_`, `_field`, `kConstant`).

### Packages

Lowercase only. Consecutive words are concatenated without separators.

```java
// Good
package com.example.deepspace;
package sayableage.locales;

// Bad
package com.example.deep_space;
package com.example.deepSpace;
```

### Classes and Interfaces

`UpperCamelCase`. Classes are typically nouns or noun phrases. Interfaces may be nouns (`List`) or adjectives (`Comparable`, `Serializable`).

```java
public class HttpClient { }
public interface Formattable { }
public record AgeComponents(int months, int diffDays) { }
public sealed interface Expr permits Constant, Plus, Negate { }
```

Test classes end with `Test`: `FormatAgeTest`, `LocaleParserTest`.

### Methods

`lowerCamelCase`. Methods are verbs or verb phrases. Boolean-returning methods typically start with `is`, `has`, `can`, or `should`.

```java
public String formatAge(String dateOfBirth) { }
public boolean isEmpty() { }
public static SayableAge of(AgeLocale locale) { }
private int parseYear(String input) { }
```

### Variables and Parameters

`lowerCamelCase`. Names should be descriptive enough to convey purpose. Avoid single-character names except for genuinely temporary variables in tight scopes (loop counters, lambda parameters).

```java
// Good
int monthCount = 24;
String delimiter = ", ";
var customers = repository.findAll();

// Bad -- cryptic
int mc = 24;
String d = ", ";
```

Avoid single-character names in public API parameters.

### Constants

`UPPER_SNAKE_CASE`. A constant is a `static final` field whose value is deeply immutable and has no observable side effects. Primitive values, strings, and immutable types (`List.of(...)`, `Map.of(...)`, `Optional.empty()`) qualify. Mutable objects, loggers, and arrays do not.

```java
// Constants
private static final int MAX_AGE_MONTHS = 6000;
private static final String DEFAULT_DELIMITER = ", ";
private static final List<String> SUPPORTED_LOCALES = List.of("en", "fr", "de");

// Not constants -- use lowerCamelCase
private static final Logger logger = Logger.getLogger(SayableAge.class.getName());
private static final int[] mutableArray = {1, 2, 3};
```

### Type Variables

Single capital letter, optionally followed by a digit (`T`, `E`, `K`, `V`, `T2`). For readability in complex generics, a class-style name suffixed with `T` is acceptable (`RequestT`, `ResponseT`).

```java
public class Pair<K, V> { }
public <T extends Comparable<T>> T max(List<T> items) { }
```

### Enums

Enum type names follow class naming (`UpperCamelCase`). Enum constants use `UPPER_SNAKE_CASE`.

```java
public enum PluralCategory {
    ZERO, ONE, TWO, FEW, MANY, OTHER
}

public enum Compactness {
    SHORT, COMPACT, NORMAL
}
```

### Camel Case Conversion

When an English phrase contains acronyms or unusual constructs, apply this deterministic algorithm:

1. Strip apostrophes. Split on spaces and remaining punctuation.
2. Lowercase everything.
3. Uppercase the first letter of each word (UpperCamelCase) or of each word except the first (lowerCamelCase).
4. Concatenate.

| Prose form        | UpperCamelCase   | lowerCamelCase   |
| ----------------- | ---------------- | ---------------- |
| XML HTTP request  | `XmlHttpRequest` | `xmlHttpRequest` |
| new customer ID   | `NewCustomerId`  | `newCustomerId`  |
| supports IPv6     | `SupportsIpv6`   | `supportsIpv6`   |
| YouTube importer  | `YouTubeImporter`| `youTubeImporter`|

---

## 2. Code Formatting

### Indentation

Use **4 spaces** per indent level. Never tabs. (Google style uses 2 spaces; Oracle conventions use 4. This guide follows the Oracle/IntelliJ default of 4 spaces, which is the most common in the Java ecosystem.)

### Braces

K&R style (Kernighan and Ritchie): opening brace on the same line, closing brace on its own line.

```java
public String formatAge(String dateOfBirth) {
    if (dateOfBirth == null) {
        return null;
    }
    return doFormat(dateOfBirth);
}
```

Always use braces for `if`, `else`, `for`, `while`, and `do`, even for single-line bodies. The only exception is an empty block, which may be written as `{}`.

```java
// Good
if (diffDays == 0) {
    return justBorn;
}

// Acceptable for empty blocks
try {
    channel.close();
} catch (IOException ignored) {}
```

### Line Length

Limit lines to **100 characters**. Exceptions:

- Package and import statements
- Long URLs in comments or Javadoc
- String literals that cannot be broken (e.g., a locale template)
- Command-line snippets in comments

### Line Wrapping

When a statement exceeds the line limit, break it at a higher syntactic level. Indent continuation lines by at least **8 spaces** (two indent levels) from the original.

```java
String result = resolveUnit(years, year, locale, "")
        + delimiter
        + resolveUnit(remainingMonths, month, locale, "");

public AgeLocale(
        String code,
        IntFunction<PluralCategory> plural,
        Units units,
        String half,
        String delimiter,
        String justBorn,
        Stages stages) {
    // ...
}
```

For method chains, break before the dot and align or indent:

```java
var result = items.stream()
        .filter(item -> item.isActive())
        .map(Item::name)
        .collect(Collectors.toList());
```

### Import Ordering

Organize imports in two groups separated by a blank line:

1. **Static imports** (alphabetical)
2. **Non-static imports** (alphabetical)

Within each group, sort alphabetically. Never use wildcard imports (`import java.util.*`).

```java
import static java.util.Objects.requireNonNull;
import static org.junit.jupiter.api.Assertions.assertEquals;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import sayableage.locales.Locales;
```

### Blank Lines

- One blank line between class members (fields, constructors, methods, nested classes).
- Optional blank line between consecutive field declarations with no logic between them.
- One blank line to separate logical sections within a method body.
- No blank line after an opening brace or before a closing brace.

### Whitespace

Spaces appear:

- After keywords (`if`, `for`, `while`, `catch`, `switch`) before the opening parenthesis
- On both sides of binary and ternary operators (`+`, `-`, `==`, `?`, `:`)
- After commas and semicolons (in `for` loops)
- After `//` in line comments
- Between a type and a variable name

Spaces do not appear:

- Between a method name and its opening parenthesis
- Inside parentheses or brackets
- Around the `::` method reference operator
- Around the `.` member access operator

### Modifier Order

Follow the JLS-recommended order:

```
public protected private
abstract default static final sealed non-sealed
transient volatile synchronized native strictfp
```

### Google Java Format

[google-java-format](https://github.com/google/google-java-format) is the standard automated formatter. It enforces the Google style (2-space indent, specific wrapping rules) deterministically. If your team uses it, let it own all formatting decisions -- do not fight the tool.

```bash
# Format a file
google-java-format --replace src/main/java/sayableage/SayableAge.java

# Check without modifying
google-java-format --dry-run --set-exit-if-changed src/**/*.java
```

Integrate it as a pre-commit hook or CI check to eliminate formatting debates.

---

## 3. Type System

### Generics

Always parameterize generic types. Raw types (`List` instead of `List<String>`) are a legacy concession and must not appear in new code.

```java
// Good
List<String> names = new ArrayList<>();
Map<String, AgeLocale> localeMap = new HashMap<>();

// Bad -- raw types
List names = new ArrayList();
```

Use bounded wildcards to increase API flexibility (PECS: Producer Extends, Consumer Super):

```java
// Accepts List<Integer>, List<Number>, etc.
public static double sum(List<? extends Number> numbers) { }

// Accepts List<Number>, List<Object>, etc.
public static void addNumbers(List<? super Integer> list) { }
```

### Records (Java 16+)

Records are the preferred way to model immutable data carriers. They automatically generate `equals()`, `hashCode()`, `toString()`, accessors, and a canonical constructor.

```java
public record AgeComponents(int months, int diffDays) {}

public record UnitForms(String simple, Map<PluralCategory, String> forms) {}
```

Use compact constructors for validation:

```java
public record Range(int start, int end) {
    public Range {
        if (end < start) {
            throw new IllegalArgumentException(
                    "end (%d) must be >= start (%d)".formatted(end, start));
        }
    }
}
```

Make defensive copies of mutable components:

```java
public record State(String name, List<String> cities) {
    public State {
        cities = List.copyOf(cities);
    }
}
```

When to use records vs. classes:

| Use a record when...                         | Use a class when...                          |
| -------------------------------------------- | -------------------------------------------- |
| Data is purely a transparent carrier          | You need mutable state                       |
| `equals`/`hashCode` should use all fields    | You need custom equality semantics           |
| No inheritance hierarchy is needed            | You need to extend a class                   |
| All fields are part of the public API         | Some fields should be encapsulated           |

### Sealed Classes and Interfaces (Java 17+)

Sealed types restrict which classes can extend them, enabling exhaustive pattern matching. Combine them with records for algebraic data types.

```java
public sealed interface Shape permits Circle, Rectangle, Triangle {}

public record Circle(double radius) implements Shape {}
public record Rectangle(double width, double height) implements Shape {}
public record Triangle(double a, double b, double c) implements Shape {}
```

Each permitted subtype must be `final`, `sealed`, or `non-sealed`. Records are implicitly `final`, making them a natural fit.

When all permitted subtypes are in the same source file, the `permits` clause may be omitted.

### Enums

Prefer enums over `int` constants or `String` constants for fixed sets of values.

```java
public enum PluralCategory {
    ZERO, ONE, TWO, FEW, MANY, OTHER
}
```

Enums can carry data and behavior:

```java
public enum Compactness {
    SHORT("short"),
    COMPACT("compact"),
    NORMAL("normal");

    private final String label;

    Compactness(String label) {
        this.label = label;
    }

    public String label() {
        return label;
    }
}
```

### Optional

`Optional<T>` is a return type for methods that may legitimately have no result. It is not a general-purpose replacement for `null`.

```java
// Good -- return type signals "might be absent"
public Optional<AgeLocale> findLocale(String code) {
    return Optional.ofNullable(localeMap.get(code));
}

// Good -- chaining transformations
String name = findLocale("en")
        .map(AgeLocale::code)
        .orElse("unknown");
```

Rules for Optional:

- Never use `Optional` as a field type, method parameter, or collection element.
- Never call `get()` without first checking `isPresent()`. Prefer `orElse()`, `orElseGet()`, `orElseThrow()`, `map()`, or `ifPresent()`.
- Never return `null` from a method declared to return `Optional`.
- For primitive values, use `OptionalInt`, `OptionalLong`, `OptionalDouble`.

### var (Local Variable Type Inference, Java 10+)

`var` reduces redundancy when the type is obvious from context. It applies only to local variables with initializers.

```java
// Good -- type is obvious from the right-hand side
var outputStream = new ByteArrayOutputStream();
var locales = List.of("en", "fr", "de");
var reader = Files.newBufferedReader(path);

// Good -- reduces noise in loops
for (var entry : map.entrySet()) {
    process(entry.getKey(), entry.getValue());
}

// Bad -- type is not obvious
var result = computeSomething();  // What type is result?
var x = getResponse();            // Opaque
```

Guidelines from the [OpenJDK LVTI Style Guide](https://openjdk.org/projects/amber/guides/lvti-style-guide):

- Use `var` when the variable name or initializer makes the type clear.
- Use descriptive variable names when using `var`. The name should compensate for the missing type.
- Avoid `var` with diamond (`<>`) or generic methods that infer `Object`: `var list = new ArrayList<>()` infers `ArrayList<Object>`.
- Keep `var` declarations close to their usage (narrow scope).
- Avoid `var` for numeric literals where the inferred type may surprise: `var count = 0` infers `int`, not `long` or `byte`.

---

## 4. Class Design

### Encapsulation

Fields should be `private`. Expose state through accessor methods (or record components). Minimize mutability.

```java
public final class SayableAge {
    private final AgeLocale locale;
    private final UnitForms day;
    private final String half;
    // ...

    public AgeLocale locale() {
        return locale;
    }
}
```

### Immutability

Prefer immutable classes. An immutable class:

1. Declares all fields `private final`.
2. Provides no setters.
3. Makes defensive copies of mutable inputs in the constructor and mutable outputs in accessors.
4. Is declared `final` (or has a private constructor with static factory methods) to prevent subclassing.

```java
public final class AgeLocale {
    private final String code;
    private final List<String> supportedGenders;

    public AgeLocale(String code, List<String> supportedGenders) {
        this.code = code;
        this.supportedGenders = List.copyOf(supportedGenders);
    }

    public String code() { return code; }
    public List<String> supportedGenders() { return supportedGenders; }
}
```

### Static Factory Methods

Prefer static factory methods over public constructors when:

- The method name adds clarity (`of`, `from`, `create`, `valueOf`, `newInstance`).
- You want to return a cached instance or a subtype.
- You want to control instantiation.

```java
// Named construction
public static SayableAge of(AgeLocale locale) {
    return new SayableAge(locale, Compactness.NORMAL);
}

public static SayableAge withCompactness(AgeLocale locale, Compactness compactness) {
    return new SayableAge(locale, compactness);
}
```

Common naming conventions for static factories:

| Name          | Usage                                      |
| ------------- | ------------------------------------------ |
| `of`          | Aggregation (`List.of`, `EnumSet.of`)      |
| `from`        | Type conversion (`Date.from(instant)`)     |
| `valueOf`     | Equivalent alternative (`Integer.valueOf`) |
| `getInstance` | Singleton or cached instances              |
| `newInstance` | Fresh instance guaranteed                  |
| `create`      | Fresh instance (alias for `newInstance`)   |

### Builder Pattern

Use the builder pattern when a constructor would have many parameters, especially when several are optional. Effective Java recommends builders when a constructor would need more than a few parameters.

```java
public final class FormatOptions {
    private final Compactness compactness;
    private final boolean includeStage;
    private final String gender;

    private FormatOptions(Builder builder) {
        this.compactness = builder.compactness;
        this.includeStage = builder.includeStage;
        this.gender = builder.gender;
    }

    public static class Builder {
        private Compactness compactness = Compactness.NORMAL;
        private boolean includeStage = false;
        private String gender = null;

        public Builder compactness(Compactness compactness) {
            this.compactness = compactness;
            return this;
        }

        public Builder includeStage(boolean includeStage) {
            this.includeStage = includeStage;
            return this;
        }

        public Builder gender(String gender) {
            this.gender = gender;
            return this;
        }

        public FormatOptions build() {
            return new FormatOptions(this);
        }
    }
}
```

### Composition Over Inheritance

Favor composition and delegation over class inheritance. Use interfaces for type abstraction. Reserve `extends` for genuine "is-a" relationships, and prefer `sealed` hierarchies when inheritance is appropriate.

### Utility Classes

A class containing only static methods should have a private constructor to prevent instantiation. Do not make it `abstract` -- that implies it is designed for subclassing.

```java
public final class DateParser {
    private DateParser() {}

    public static int[] parseDateParts(String s) { /* ... */ }
    public static int safeAtoi(String s, int from, int to) { /* ... */ }
}
```

---

## 5. Collections

### Creating Unmodifiable Collections

Use the factory methods introduced in Java 9+. These return compact, unmodifiable implementations.

```java
// Preferred
var names = List.of("Alice", "Bob", "Charlie");
var scores = Map.of("Alice", 95, "Bob", 87);
var tags = Set.of("urgent", "reviewed");

// For more than 10 entries in a map
var locales = Map.ofEntries(
        Map.entry("en", english),
        Map.entry("fr", french),
        Map.entry("de", german)
);
```

These factories:

- Return unmodifiable views (throws `UnsupportedOperationException` on mutation).
- Reject `null` keys and values.
- Reject duplicate keys (`Map.of`) and duplicate elements (`Set.of`).

### Wrapping Mutable Collections

When you receive a mutable collection and want to expose an unmodifiable snapshot:

```java
// Shallow copy + unmodifiable -- preferred for records and immutable classes
this.items = List.copyOf(mutableList);

// Unmodifiable view of the same backing collection (no copy)
var readOnly = Collections.unmodifiableList(mutableList);
```

`List.copyOf`, `Set.copyOf`, and `Map.copyOf` (Java 10+) create an independent, unmodifiable copy. They are null-hostile: any `null` element throws `NullPointerException`.

### Choosing the Right Collection

| Need                              | Use                     |
| --------------------------------- | ----------------------- |
| Ordered, indexed access           | `ArrayList`             |
| Frequent insert/remove at ends    | `ArrayDeque`            |
| Unique elements, fast lookup      | `HashSet`               |
| Unique elements, sorted           | `TreeSet`               |
| Key-value lookup                  | `HashMap`               |
| Key-value, sorted by key          | `TreeMap`               |
| Key-value, insertion order        | `LinkedHashMap`         |
| Thread-safe map                   | `ConcurrentHashMap`     |
| Enum keys                         | `EnumMap`               |
| Enum elements                     | `EnumSet`               |
| Fixed-size, unmodifiable list     | `List.of(...)`          |
| Fixed-size, unmodifiable map      | `Map.of(...)`           |
| FIFO queue                        | `ArrayDeque`            |
| Priority queue                    | `PriorityQueue`         |

### Program to the Interface

Declare variables and parameters using the interface type (`List`, `Map`, `Set`), not the implementation type, unless the implementation matters.

```java
// Good
List<String> names = new ArrayList<>();
Map<String, Integer> scores = new HashMap<>();

// Bad
ArrayList<String> names = new ArrayList<>();
HashMap<String, Integer> scores = new HashMap<>();
```

---

## 6. Error Handling

### Checked vs. Unchecked Exceptions

| Category                | When to use                                                     |
| ----------------------- | --------------------------------------------------------------- |
| Checked (`Exception`)   | Recoverable conditions the caller can reasonably handle (I/O failures, parse errors from user input) |
| Unchecked (`RuntimeException`) | Programming errors, precondition violations, unrecoverable states |
| `Error`                 | Never throw or catch. Reserved for JVM-level issues.            |

Effective Java Item 70: "Use checked exceptions for recoverable conditions and runtime exceptions for programming errors."

### Try-with-Resources

Always use try-with-resources for anything that implements `AutoCloseable`. Never rely on `finally` blocks for resource cleanup.

```java
// Good
try (var reader = new BufferedReader(new FileReader(path))) {
    return reader.readLine();
}

// Good -- multiple resources
try (var input = socket.getInputStream();
     var reader = new InputStreamReader(input, StandardCharsets.UTF_8);
     var buffered = new BufferedReader(reader)) {
    return buffered.readLine();
}

// Bad -- manual close in finally
BufferedReader reader = null;
try {
    reader = new BufferedReader(new FileReader(path));
    return reader.readLine();
} finally {
    if (reader != null) reader.close();
}
```

### Custom Exceptions

Create custom exception classes when the caller needs to distinguish specific failure modes. Keep exception hierarchies shallow.

```java
public class LocaleNotFoundException extends RuntimeException {
    private final String localeCode;

    public LocaleNotFoundException(String localeCode) {
        super("Locale not found: " + localeCode);
        this.localeCode = localeCode;
    }

    public String localeCode() {
        return localeCode;
    }
}
```

### Exception Best Practices

- **Catch specific exceptions.** Never catch `Exception` or `Throwable` without a strong reason.
- **Do not swallow exceptions silently.** If you must ignore an exception, document why with a comment.
- **Include context in exception messages.** State what went wrong and what the failing values were.
- **Throw early, catch late.** Validate preconditions at the entry point; handle exceptions at the level that can recover from them.
- **Prefer standard exceptions.** Use `IllegalArgumentException`, `IllegalStateException`, `NullPointerException`, `UnsupportedOperationException` before creating custom ones.

```java
// Good -- context in the message
if (months > MAX_AGE_MONTHS) {
    throw new IllegalArgumentException(
            "Month count %d exceeds maximum %d".formatted(months, MAX_AGE_MONTHS));
}

// Bad -- no context
throw new IllegalArgumentException("Invalid value");
```

### Never Ignore Caught Exceptions Without Comment

```java
// Acceptable -- with documented justification
try {
    channel.close();
} catch (IOException ignored) {
    // Channel cleanup is best-effort; failure here is non-fatal
}

// Unacceptable
try {
    channel.close();
} catch (IOException e) {
}
```

---

## 7. Streams and Lambdas

### When to Use Streams

Streams excel at bulk data transformations: filtering, mapping, grouping, reducing. Use them when the pipeline reads naturally as a sequence of transformations.

```java
var activeLocales = allLocales.stream()
        .filter(AgeLocale::isActive)
        .map(AgeLocale::code)
        .sorted()
        .toList();
```

Prefer a traditional loop when:

- The logic has complex control flow (early returns, `break`, `continue`).
- You need to mutate local variables.
- A single `for` loop is simpler and more readable.
- Performance-critical code where stream overhead matters.

### Readability Guidelines

- **Keep pipelines short.** Three to five operations is a good ceiling. Extract complex predicates or mappers into named methods.
- **One operation per line.** Break the chain so each `.filter()`, `.map()`, `.collect()` is on its own line.
- **Prefer method references** when they read naturally: `String::toLowerCase`, `Objects::nonNull`. Use lambdas when a method reference would be less clear.

```java
// Good -- method reference reads naturally
names.stream().map(String::trim).toList();

// Good -- lambda is clearer here
names.stream().filter(name -> name.length() > 3).toList();

// Bad -- lambda when method reference is clearer
names.stream().map(name -> name.trim()).toList();
```

### Method References

Four forms:

| Kind                     | Syntax                    | Equivalent lambda             |
| ------------------------ | ------------------------- | ----------------------------- |
| Static method            | `Integer::parseInt`       | `s -> Integer.parseInt(s)`    |
| Instance method (bound)  | `System.out::println`     | `x -> System.out.println(x)` |
| Instance method (unbound)| `String::length`          | `s -> s.length()`             |
| Constructor              | `ArrayList::new`          | `() -> new ArrayList<>()`     |

### Collectors

Common collectors:

```java
// To unmodifiable list (Java 16+)
var list = stream.toList();

// To mutable list
var mutableList = stream.collect(Collectors.toList());

// To set
var set = stream.collect(Collectors.toSet());

// To map
var map = stream.collect(Collectors.toMap(
        AgeLocale::code,
        Function.identity()));

// Grouping
var byCategory = items.stream()
        .collect(Collectors.groupingBy(Item::category));

// Joining strings
var csv = names.stream()
        .collect(Collectors.joining(", "));

// Counting
var countByType = items.stream()
        .collect(Collectors.groupingBy(Item::type, Collectors.counting()));
```

### Functional Interfaces

The four pillars in `java.util.function`:

| Interface            | Method           | Signature          |
| -------------------- | ---------------- | ------------------ |
| `Supplier<T>`        | `get()`          | `() -> T`          |
| `Consumer<T>`        | `accept(T)`      | `T -> void`        |
| `Predicate<T>`       | `test(T)`        | `T -> boolean`     |
| `Function<T, R>`     | `apply(T)`       | `T -> R`           |

Variants: `BiFunction<T, U, R>`, `BiConsumer<T, U>`, `BiPredicate<T, U>`, `UnaryOperator<T>` (extends `Function<T, T>`), `BinaryOperator<T>` (extends `BiFunction<T, T, T>`).

Primitive specializations (`IntFunction`, `LongConsumer`, `DoubleSupplier`, etc.) avoid boxing overhead in performance-critical code.

### Lambda Best Practices

- Keep lambdas short -- ideally a single expression. Extract multi-line logic into a named method.
- Captured variables must be effectively final. Do not work around this with single-element arrays or `AtomicReference`.
- Prefer `Predicate` composition (`predicate.and(...)`, `predicate.or(...)`, `predicate.negate()`) over complex boolean logic inside a single lambda.

```java
// Good -- composed predicates
Predicate<String> nonEmpty = s -> !s.isEmpty();
Predicate<String> shortEnough = s -> s.length() <= 100;
var valid = nonEmpty.and(shortEnough);

items.stream().filter(valid).toList();
```

---

## 8. String Handling

### Text Blocks (Java 15+)

Use text blocks for multi-line strings. The opening `"""` must be followed by a newline. The closing `"""` controls indentation.

```java
String json = """
        {
            "code": "en",
            "name": "English"
        }
        """;

String sql = """
        SELECT code, name
        FROM locales
        WHERE active = true
        ORDER BY code
        """;
```

### String Concatenation

For simple expressions, `+` concatenation is fine. The compiler optimizes it.

```java
// Fine for simple cases
String greeting = "Hello, " + name + "!";
return resolveUnit(years, year, locale, "") + delimiter + resolveUnit(rem, month, locale, "");
```

### StringBuilder

Use `StringBuilder` when building a string in a loop or across many conditional branches.

```java
var sb = new StringBuilder();
for (var locale : locales) {
    if (!sb.isEmpty()) {
        sb.append(", ");
    }
    sb.append(locale.code());
}
return sb.toString();
```

Never use `StringBuffer` (the synchronized version) unless you specifically need thread safety, which is almost never.

### String.format and formatted

`String.format` and the instance method `formatted` (Java 15+) are useful for complex formatting with positional arguments.

```java
// Traditional
String msg = String.format("Locale %s not found (searched %d entries)", code, count);

// Instance method (Java 15+)
String msg = "Locale %s not found (searched %d entries)".formatted(code, count);

// Prefer formatted() for readability -- the template is the receiver
throw new IllegalArgumentException(
        "end (%d) must be >= start (%d)".formatted(end, start));
```

### String Comparison

Always use `.equals()` for string comparison. Never use `==` to compare string content.

```java
// Good
if ("newborn".equals(stageKey)) { }

// Bad
if (stageKey == "newborn") { }
```

---

## 9. Common Idioms

### Switch Expressions (Java 14+)

Prefer arrow-style switch expressions (`->`) over colon-style switch statements (`:`). Switch expressions return a value and do not fall through.

```java
// Good -- expression with arrow syntax
String label = switch (stageKey(age.months())) {
    case "newborn"  -> locale.stages().newborn();
    case "infant"   -> locale.stages().infant();
    case "toddler"  -> locale.stages().toddler();
    case "child"    -> locale.stages().child();
    case "teenager" -> locale.stages().teenager();
    case "adult"    -> locale.stages().adult();
    default         -> null;
};

// Good -- enum exhaustiveness (no default needed)
CompactnessOverride ovr = switch (compactness) {
    case SHORT   -> locale.shortOverride();
    case COMPACT -> locale.compactOverride();
    case NORMAL  -> null;
};
```

Use `yield` for multi-statement cases:

```java
int numLetters = switch (day) {
    case MONDAY, FRIDAY, SUNDAY -> 6;
    case TUESDAY -> 7;
    case WEDNESDAY -> {
        log("midweek");
        yield 9;
    }
    default -> throw new IllegalStateException("Unexpected: " + day);
};
```

### Pattern Matching for instanceof (Java 16+)

Eliminate redundant casts with pattern variables.

```java
// Good
if (obj instanceof String s) {
    return s.length();
}

// Good -- negated pattern with early return
if (!(obj instanceof String s)) {
    return -1;
}
return s.length();

// Bad -- old style
if (obj instanceof String) {
    String s = (String) obj;
    return s.length();
}
```

### Pattern Matching in switch (Java 21+)

Combine type patterns, record patterns, and guarded patterns in switch.

```java
String describe(Object obj) {
    return switch (obj) {
        case Integer i when i > 0 -> "positive int: " + i;
        case Integer i            -> "non-positive int: " + i;
        case String s             -> "string of length " + s.length();
        case null                 -> "null";
        default                   -> "other: " + obj;
    };
}
```

### Record Patterns (Java 21+)

Deconstruct records directly in `instanceof` and `switch`:

```java
record Point(int x, int y) {}
record Circle(Point center, double radius) {}

// Deconstruct in instanceof
if (shape instanceof Circle(Point(var x, var y), var r)) {
    System.out.println("Circle at (%d, %d) with radius %.1f".formatted(x, y, r));
}

// Deconstruct in switch
String describe(Shape shape) {
    return switch (shape) {
        case Circle(Point(var x, var y), var r)   -> "Circle(%d,%d,%.1f)".formatted(x, y, r);
        case Rectangle(var w, var h)              -> "Rect(%.1f,%.1f)".formatted(w, h);
        case Triangle(var a, var b, var c)        -> "Tri(%.1f,%.1f,%.1f)".formatted(a, b, c);
    };
}
```

### Enhanced for Loop

Prefer enhanced `for` over indexed loops when you do not need the index.

```java
// Good
for (var locale : locales) {
    process(locale);
}

// Use indexed loop when you need the index
for (int i = 0; i < items.size(); i++) {
    items.set(i, transform(items.get(i)));
}
```

### Objects Utility Methods

Use `java.util.Objects` for null-safety:

```java
import java.util.Objects;

// Null check with message (throws NullPointerException)
this.code = Objects.requireNonNull(code, "code must not be null");

// Null-safe equals
Objects.equals(a, b);

// Null-safe hashCode
Objects.hash(code, name, plural);

// Null-safe toString with default
Objects.toString(value, "default");
```

### @Override

Always annotate overriding methods with `@Override`. The compiler will catch errors if the method signature does not actually override anything.

```java
@Override
public boolean equals(Object obj) {
    return obj instanceof Point p && x == p.x && y == p.y;
}

@Override
public int hashCode() {
    return Objects.hash(x, y);
}
```

---

## 10. Things to Avoid

### Raw Types

Never use raw types. They exist only for backward compatibility with pre-generics code.

```java
// Bad
List items = new ArrayList();
Map scores = new HashMap();

// Good
List<Item> items = new ArrayList<>();
Map<String, Integer> scores = new HashMap<>();
```

### Mutable Statics

Avoid mutable static fields. They create hidden global state, make testing difficult, and break thread safety.

```java
// Bad -- mutable shared state
public static List<String> registeredLocales = new ArrayList<>();

// Better -- unmodifiable
public static final List<String> SUPPORTED_LOCALES = List.of("en", "fr", "de");
```

If you must have a mutable static for test hooks (like a clock supplier), make it package-private and document why.

### Returning null Where Optional Works

When a method may legitimately produce no result and the caller is expected to handle absence, return `Optional<T>` instead of `null`. This makes the possibility of absence explicit in the type system.

```java
// Bad -- caller must remember to null-check
public AgeLocale findLocale(String code) {
    return localeMap.get(code);
}

// Good -- absence is explicit
public Optional<AgeLocale> findLocale(String code) {
    return Optional.ofNullable(localeMap.get(code));
}
```

However, do not force Optional everywhere. Returning `null` is appropriate for private/internal methods, and for methods where `null` signals "not applicable" in a well-understood context (e.g., `parseAge` returning `null` for invalid input in a private API).

### Excessive Inheritance

Prefer composition over inheritance. Deep class hierarchies are fragile and hard to reason about.

```java
// Bad -- inheritance for code reuse
public class FormattedOutput extends StringBuilder { }

// Good -- composition
public class FormattedOutput {
    private final StringBuilder buffer = new StringBuilder();

    public void append(String text) {
        buffer.append(text);
    }
}
```

### Finalizers and Cleaners

Never override `Object.finalize()` -- it is deprecated for removal. Use try-with-resources for resource cleanup. If you need clean-up logic for native resources, use `java.lang.ref.Cleaner` as a safety net, not as the primary mechanism.

### Double-Brace Initialization

Never use anonymous subclass initialization (double-brace initialization). It creates a hidden subclass, leaks the enclosing reference, and breaks serialization.

```java
// Bad -- double-brace initialization
Map<String, Integer> map = new HashMap<>() {{
    put("a", 1);
    put("b", 2);
}};

// Good
var map = Map.of("a", 1, "b", 2);
```

### Wildcard Imports

Never use `import java.util.*`. Explicit imports make dependencies visible and prevent ambiguity.

### Mutable Method Parameters

Do not modify method parameters or collection arguments passed in by the caller. Make defensive copies if you need to transform input.

### Catching Throwable or Exception Broadly

Do not catch `Throwable` or `Exception` at the top level as a general error-handling strategy. Catch specific exception types. The only acceptable place for broad catches is framework-level error handlers (e.g., a top-level request handler in a web server).

### String Concatenation in Loops

Do not use `+` for string concatenation inside loops. Use `StringBuilder` or `StringJoiner`.

```java
// Bad -- O(n^2) string copying
String result = "";
for (var item : items) {
    result += item.name() + ", ";
}

// Good
var joiner = new StringJoiner(", ");
for (var item : items) {
    joiner.add(item.name());
}
String result = joiner.toString();
```

### Boxing in Tight Loops

Avoid unnecessary autoboxing in performance-sensitive code. Use primitive specializations (`IntStream`, `LongStream`, `ToIntFunction`, etc.).

```java
// Bad -- boxes every int
List<Integer> sums = numbers.stream()
        .map(n -> n + 1)
        .collect(Collectors.toList());

// Good -- stays in primitives
int[] sums = IntStream.of(1, 2, 3)
        .map(n -> n + 1)
        .toArray();
```

---

## 11. Tooling

### google-java-format

The de facto standard for automated Java formatting. Enforces the Google Java Style Guide deterministically.

- **Repository:** [google/google-java-format](https://github.com/google/google-java-format)
- **Integration:** Available as a CLI, IntelliJ plugin, Maven/Gradle plugin, and pre-commit hook.
- **Usage:** `google-java-format --replace src/main/java/**/*.java`
- **CI check:** `google-java-format --dry-run --set-exit-if-changed`

### Checkstyle

A highly configurable static analysis tool that enforces coding standards. It checks formatting, naming conventions, Javadoc completeness, code complexity, and more.

- **Repository:** [checkstyle/checkstyle](https://github.com/checkstyle/checkstyle)
- **Reference:** [checkstyle.sourceforge.io](https://checkstyle.sourceforge.io/)
- **Key check categories:** Annotations, Coding, Design, Imports, Javadoc, Naming, Size Violations, Whitespace.
- **Notable checks:** `AvoidStarImport`, `UnusedImports`, `ImportOrder`, `MissingJavadocMethod`, `ConstantName`, `TypeName`, `LineLength`, `FileTabCharacter`.
- **Configuration:** Ship a `checkstyle.xml` in the project root. Use Google's config (`/google_checks.xml`) or Sun's config (`/sun_checks.xml`) as a starting point.

### SpotBugs

Finds real bugs through bytecode analysis (successor to FindBugs). Detects null pointer dereferences, infinite loops, resource leaks, synchronization problems, and more.

- **Repository:** [spotbugs/spotbugs](https://github.com/spotbugs/spotbugs)
- **Reference:** [spotbugs.readthedocs.io](https://spotbugs.readthedocs.io/)
- **Integration:** Maven/Gradle plugins.
- **Usage:** Add to CI to catch bugs that the compiler misses.

### Error Prone

A compile-time static analysis tool by Google that catches common Java mistakes as compiler errors or warnings. It plugs into `javac` as an annotation processor.

- **Repository:** [google/error-prone](https://github.com/google/error-prone)
- **Reference:** [errorprone.info](https://errorprone.info/)
- **470+ bug patterns** across ERROR, WARNING, and SUGGESTION severities.
- **Key patterns:** `NullArgumentForNonNullParameter`, `BoxedPrimitiveEquality`, `CheckReturnValue`, `MustBeClosedChecker`, `InfiniteRecursion`, `ArrayToString`, `CollectionIncompatibleType`.
- **Integration:** Add as a compiler plugin in Maven or Gradle.

### PMD

A source-code analyzer that finds common programming flaws: unused variables, empty catch blocks, unnecessary object creation, overly complex code.

- **Repository:** [pmd/pmd](https://github.com/pmd/pmd)
- **Reference:** [pmd.github.io](https://pmd.github.io/)
- **8 rule categories:** Best Practices, Code Style, Design, Documentation, Error Prone, Multithreading, Performance, Security.
- **Key rules:** `UnusedPrivateField`, `CyclomaticComplexity`, `GodClass`, `OverrideBothEqualsAndHashcode`, `CloseResource`, `AvoidSynchronizedAtMethodLevel`, `UseTryWithResources`.
- **Quick start:** Use the bundled `quickstart.xml` ruleset for a sensible default configuration.

### Recommended Toolchain

A robust Java project should run at minimum:

1. **Formatter** (google-java-format) -- eliminates style debates
2. **Linter** (Checkstyle) -- enforces conventions beyond formatting
3. **Bug finder** (Error Prone or SpotBugs) -- catches real defects
4. **All in CI** -- fail the build on violations

---

## References

- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html) -- the most widely adopted corporate Java style guide
- [Oracle Code Conventions for the Java Programming Language](https://www.oracle.com/java/technologies/javase/codeconventions-contents.html) -- the original Sun conventions (1997), still influential
- [Effective Java, 3rd Edition](https://www.oreilly.com/library/view/effective-java/9780134686097/) (Joshua Bloch) -- essential reading for Java design decisions
- [OpenJDK Developer's Guide](https://openjdk.org/guide/) -- guidelines for contributing to the JDK itself
- [OpenJDK LVTI Style Guide](https://openjdk.org/projects/amber/guides/lvti-style-guide) -- official `var` usage guidelines
- [dev.java/learn](https://dev.java/learn/) -- Oracle's modern Java tutorials (records, sealed classes, pattern matching, streams, lambdas)
- [JEP 361: Switch Expressions](https://openjdk.org/jeps/361) -- specification for switch expressions
- [JEP 394: Pattern Matching for instanceof](https://openjdk.org/jeps/394) -- specification for pattern matching
- [JEP 395: Records](https://openjdk.org/jeps/395) -- specification for records
- [JEP 409: Sealed Classes](https://openjdk.org/jeps/409) -- specification for sealed classes
- [Error Prone Bug Patterns](https://errorprone.info/bugpatterns) -- full catalog of Error Prone checks
- [PMD Java Rules](https://pmd.github.io/pmd/pmd_rules_java.html) -- full catalog of PMD rules
- [Checkstyle Checks](https://checkstyle.sourceforge.io/checks.html) -- full catalog of Checkstyle checks

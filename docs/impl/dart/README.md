# Dart Style Guide

A comprehensive reference for idiomatic Dart, compiled from official sources. Use this guide when auditing Dart implementations for correctness, consistency, and adherence to community conventions.

## Sources

- [Effective Dart: Style](https://dart.dev/effective-dart/style)
- [Effective Dart: Usage](https://dart.dev/effective-dart/usage)
- [Effective Dart: Design](https://dart.dev/effective-dart/design)
- [Effective Dart: Documentation](https://dart.dev/effective-dart/documentation)
- [Dart Language Tour](https://dart.dev/language)
- [Dart Type System](https://dart.dev/language/type-system)
- [Linter Rules Reference](https://dart.dev/tools/linter-rules)
- [Analysis Options](https://dart.dev/tools/analysis)

---

## 1. Naming Conventions

### Types, Classes, Enums, Typedefs, Extensions

Use `UpperCamelCase`. Every word is capitalized, including the first.

```dart
class SliderMenu {}
enum PluralCategory { zero, one, two, few, many, other }
typedef Predicate<T> = bool Function(T);
extension NumberParsing on String { ... }
```

Linter rules: `camel_case_types`, `camel_case_extensions`

### Libraries, Packages, Directories, Source Files

Use `lowercase_with_underscores`.

```dart
// File: format_age.dart
// Package: sayable_age
import 'dart:math' as dart_math;
```

Linter rules: `file_names`, `package_names`, `library_prefixes`

### Variables, Functions, Parameters, Named Parameters

Use `lowerCamelCase`. This includes constants.

```dart
var itemCount = 3;
const defaultTimeout = 1000;
const pi = 3.14;
void alignItems(bool clearFirst) { ... }
```

PREFER `lowerCamelCase` for constants rather than `SCREAMING_CAPS`. Dart convention diverges from many other languages here.

Linter rules: `non_constant_identifier_names`, `constant_identifier_names`

### Type Parameters

Follow mnemonic conventions:

| Letter | Meaning |
|--------|---------|
| `E` | Element type in collections |
| `K`, `V` | Key and value in maps |
| `R` | Return type |
| `T`, `S`, `U` | General single type parameters |

```dart
class Map<K, V> { ... }
class Future<T> { ... }
class List<E> { ... }
```

### Acronyms and Abbreviations

Capitalize acronyms longer than two letters like regular words. Two-letter acronyms that are capitalized in English stay capitalized (`ID`, `TV`, `UI`).

```dart
// Good
class HttpRequest {}
var httpConnection = connect();
class IOStream {}

// Bad
class HTTPRequest {}   // Treat as a word: Http
class DBManager {}     // Spell out or use Db
```

### Things to Avoid in Names

**No leading underscores on non-private identifiers.** Underscores signal library-private scope in Dart. Do not use them for local variables, parameters, or local functions.

**No prefix letters.** Avoid Hungarian notation like `kDefaultTimeout` or `iCount`. Dart's type system provides this information. Use `defaultTimeout` instead.

**No explicit library names.** Do not append names to the `library` directive. Dart generates unique URIs from the file path. Use a doc comment if the library needs a description.

```dart
// Good
/// Locale-aware age formatting utilities.
library;

// Bad
library my_library;
```

### Unused Callback Parameters

In Dart 3.5+, name unused parameters `_` (wildcard). For earlier versions, use `__` or `___` to avoid collisions.

```dart
future.onError((_, _) {
  handleError();
});
```

---

## 2. Code Formatting

### dart format

**Always format code with `dart format`.** The official style is whatever `dart format` produces. This is non-negotiable. Do not manually override its decisions.

If `dart format` produces hard-to-read output, restructure the code rather than fighting the formatter:
- Shorten variable names
- Extract subexpressions into local variables
- Simplify deeply nested expressions

### Line Length

PREFER 80 characters or fewer. The `dart format` tool defaults to 80 characters. This is configurable in `analysis_options.yaml`:

```yaml
formatter:
  page_width: 80
```

Exceptions: URIs or file paths in comments/strings may exceed the limit. Multi-line strings with embedded newlines may exceed it.

Linter rule: `lines_longer_than_80_chars`

### Trailing Commas

Use trailing commas in argument lists, parameter lists, and collection literals when they span multiple lines. This produces cleaner diffs and lets `dart format` place each item on its own line.

```dart
// With trailing comma -- dart format puts each on its own line
const AgeLocale(
  code: 'en',
  plural: _plural,
  day: pluralUnit({PluralCategory.one: '{n} day', PluralCategory.other: '{n} days'}),
  week: pluralUnit({PluralCategory.one: '{n} week', PluralCategory.other: '{n} weeks'}),
);

// Without trailing comma -- dart format may collapse to fewer lines
```

### Curly Braces

Use curly braces for all flow control statements to prevent dangling-else bugs.

```dart
// Good
if (isWeekDay) {
  print('Bike to work!');
} else {
  print('Go dancing or read a book!');
}

// Exception: single-line if with no else
if (arg == null) return defaultValue;

// Bad: body wraps to next line without braces
if (overflowChars != other.overflowChars)
  return overflowChars < other.overflowChars;
```

Linter rule: `curly_braces_in_flow_control_structures`

### Import Ordering

Organize imports in this order, with blank lines between sections. Sort alphabetically within each section. Within a package's `lib/` directory, prefer relative imports over `package:` imports for internal files.

```dart
// 1. dart: imports
import 'dart:async';
import 'dart:math';

// 2. package: imports
import 'package:test/test.dart';

// 3. Relative imports (preferred within the same package)
import 'types.dart';
import 'locales/locales.dart';

// 4. Exports (separate section)
export 'src/format_age.dart';
```

Linter rules: `directives_ordering`, `prefer_relative_imports`

---

## 3. Type System

### Sound Null Safety

Dart enforces sound null safety. A variable's type determines whether it can hold `null`.

```dart
String name = 'Alice';    // Cannot be null. Must be initialized.
String? name;              // Can be null. Defaults to null.
int? lineCount;            // Implicitly null -- do NOT write `int? lineCount = null;`
```

Key rules:
- Non-nullable variables must be initialized before use.
- Nullable variables default to `null`. Do not explicitly initialize to `null`.
- Optional nullable parameters default to `null`. Do not write `= null`.

```dart
// Good
void error([String? message]) { ... }

// Bad
void error([String? message = null]) { ... }
```

### Type Inference

Dart infers types for local variables, fields, closures, and generic type arguments. Let inference work when the type is obvious.

```dart
// Good -- type is obvious from the right-hand side
var items = <String>[];
var age = _parseAge(dateOfBirth, asOf);
final buffer = StringBuffer();

// Bad -- redundant annotation
List<String> items = <String>[];
_AgeComponents? age = _parseAge(dateOfBirth, asOf);
```

**Always annotate** when there is no initializer, on public API boundaries (function return types, parameters), and when the type is not obvious from context.

```dart
// Good -- no initializer, annotation required
List<AstNode> parameters;

// Good -- public API boundary
String formatAge(String dateOfBirth, [String? asOf]) { ... }

// Good -- type not obvious
Map<String, List<int>> groupedScores = buildScoreMap();
```

### Strict Mode

Enable strict type checking in `analysis_options.yaml` to catch implicit `dynamic` and raw type usage:

```yaml
analyzer:
  language:
    strict-casts: true       # No implicit casts from dynamic
    strict-raw-types: true   # No raw generic types (e.g., bare List instead of List<int>)
    strict-inference: true   # No fallback to dynamic when inference fails
```

### Generics

Always provide complete type arguments when inference cannot determine them. Never leave generic types raw.

```dart
// Good
var playerScores = <String, int>{};
var names = <String>[];

// Bad -- silently becomes Map<dynamic, dynamic>
var playerScores = {};

// Bad -- raw type, loses type safety
List numbers = [1, 2, 3];
```

When inference succeeds, omit type arguments to reduce noise:

```dart
// Good -- inference handles it
var items = Future.value([1, 2, 3]);

// Unnecessary -- inference already knows the types
var items = Future<List<int>>.value(<int>[1, 2, 3]);
```

### typedef

Use the modern `=` syntax, never the legacy syntax. Prefer inline function types over typedefs unless the type is used in multiple places.

```dart
// Good -- modern typedef syntax
typedef Comparison<T> = int Function(T, T);
typedef PluralRule = PluralCategory Function(int n);

// Bad -- legacy syntax
typedef int Comparison<T>(T a, T b);

// Prefer inline when used once
final bool Function(Event) _predicate;
```

### dynamic

Use `dynamic` only when you intentionally want to disable static checking. Write it explicitly to signal intent.

```dart
// Good -- intentional dynamic usage
dynamic mergeJson(dynamic original, dynamic changes) => ...

// Bad -- implicit dynamic from missing annotation
mergeJson(original, changes) => ...
```

### Type Tests and Casts

Use `is` for type tests. Dart promotes the variable's type within the `if` block, so you rarely need `as`.

```dart
// Good -- type promotion
if (employee is Person) {
  employee.firstName = 'Bob';  // No cast needed
}

// Risky -- throws if wrong type
(employee as Person).firstName = 'Bob';
```

---

## 4. Class Design

### Constructors

**Generative constructors** create new instances. Use initializing formals (`this.x`) to reduce boilerplate.

```dart
class Point {
  final double x;
  final double y;
  Point(this.x, this.y);
}
```

**Named constructors** clarify intent or provide alternative creation paths.

```dart
class Point {
  final double x;
  final double y;
  Point(this.x, this.y);
  Point.origin() : x = 0, y = 0;
}
```

**Factory constructors** return existing instances, subtypes, or computed instances. They cannot access `this`.

```dart
class Logger {
  static final Map<String, Logger> _cache = {};

  factory Logger(String name) {
    return _cache.putIfAbsent(name, () => Logger._internal(name));
  }

  Logger._internal(this.name);
  final String name;
}
```

**Constant constructors** enable compile-time constants. All fields must be `final`.

```dart
class ImmutablePoint {
  final double x;
  final double y;
  const ImmutablePoint(this.x, this.y);
}

// Identical instances
const a = ImmutablePoint(1, 1);
const b = ImmutablePoint(1, 1);
assert(identical(a, b));
```

**Redirecting constructors** delegate to another constructor in the same class.

```dart
class Point {
  final double x;
  final double y;
  Point(this.x, this.y);
  Point.alongXAxis(double x) : this(x, 0);
}
```

**Super parameters** (Dart 2.17+) forward parameters to the superclass without manual passing.

```dart
class Vector3d extends Vector2d {
  final double z;
  Vector3d(super.x, super.y, this.z);
}
```

### Constructor Style Rules

- Use `this.` initializing formals when the parameter directly initializes a field.
- Use `;` for empty constructor bodies, not `{}`.
- Never use `new` -- it is optional and discouraged.
- Do not use `const` redundantly in const contexts.
- Do not add type annotations to initializing formals -- the field type is used.

```dart
// Good
class Point {
  final double x;
  final double y;
  const Point(this.x, this.y);
}

// Bad
class Point {
  final double x;
  final double y;
  const Point(double this.x, double this.y) {}
}
```

### Initializer Lists

Use initializer lists to set fields before the constructor body runs. Useful for computed initialization and assertions.

```dart
class Point {
  final double x;
  final double y;
  final double distanceFromOrigin;

  Point(double x, double y)
      : x = x,
        y = y,
        distanceFromOrigin = sqrt(x * x + y * y);
}
```

Use `assert` in initializer lists for development-time validation:

```dart
Point.withAssert(this.x, this.y) : assert(x >= 0);
```

### Mixins

Mixins provide reusable behavior across class hierarchies without single-inheritance constraints. Declare with `mixin`, apply with `with`.

```dart
mixin Musical {
  bool canPlayPiano = false;

  void entertainMe() {
    if (canPlayPiano) print('Playing piano');
  }
}

class Musician extends Performer with Musical { ... }
```

Use `on` to restrict which classes can use the mixin (required for `super` calls):

```dart
mixin MusicalPerformer on Musician {
  void performerMethod() {
    super.musicianMethod();
  }
}
```

In Dart 3.0+, `mixin class` allows a declaration that works as both:

```dart
mixin class Musician {
  void play() { ... }
}

class Novice with Musician { }     // As mixin
class Beginner extends Musician { } // As class
```

### Extensions

Extensions add methods to existing types without subclassing. They resolve at compile time based on static type.

```dart
extension StringParsing on String {
  int parseInt() => int.parse(this);
  double parseDouble() => double.parse(this);
}

print('42'.parseInt());  // 42
```

Generic extensions:

```dart
extension MyFancyList<T> on List<T> {
  int get doubleLength => length * 2;
  List<T> operator -() => reversed.toList();
}
```

Extensions do not work on `dynamic` types -- they require a known static type.

### Extension Types (Dart 3.3+)

Extension types provide zero-cost wrappers around an existing type, giving it a different interface without runtime overhead. Unlike extension methods (which add methods to an existing type), extension types create a new static type that the compiler enforces.

```dart
extension type UserId(int id) {
  bool get isValid => id > 0;
}

extension type Email(String value) {
  bool get isValid => value.contains('@');
}

// Type-safe: cannot accidentally pass UserId where Email is expected
void sendEmail(Email to) { ... }
```

Extension types are erased at runtime -- the underlying representation type is all that exists. Use them for lightweight type safety over primitives without the cost of wrapper classes.

### Class Modifiers (Dart 3.0+)

Use modifiers to control how your class can be used outside its library:

| Modifier | Can construct | Can extend | Can implement |
|----------|:---:|:---:|:---:|
| `class` | Yes | Yes | Yes |
| `base class` | Yes | Yes | No |
| `interface class` | Yes | No | Yes |
| `final class` | Yes | No | No |
| `sealed class` | No | No | No (outside library) |
| `abstract class` | No | Yes | Yes |
| `mixin class` | Yes | Yes | Yes (as mixin) |

### Sealed Classes and Exhaustive Switching

The primary purpose of `sealed` classes is to enable exhaustive `switch` expressions. The compiler verifies that every subtype is handled, catching missing cases at compile time.

```dart
sealed class Shape {}
class Circle extends Shape { final double radius; Circle(this.radius); }
class Square extends Shape { final double side; Square(this.side); }

// Compiler guarantees all subtypes are handled -- no default needed
String describe(Shape shape) => switch (shape) {
  Circle(radius: var r) => 'Circle with radius $r',
  Square(side: var s) => 'Square with side $s',
};
// Adding a new Shape subclass causes a compile error here until handled.
```

This is especially valuable for modeling closed type hierarchies where the set of variants is fixed.

### Class Design Anti-Patterns

**Avoid one-member abstract classes.** Use a typedef for function types instead.

```dart
// Good
typedef Predicate<E> = bool Function(E element);

// Bad
abstract class Predicate<E> {
  bool test(E element);
}
```

**Prefer top-level functions for utility code.** Libraries serve as namespaces in Dart, so static-only classes are usually unnecessary. However, static-only classes are acceptable when a namespace improves discoverability in large APIs.

```dart
// Good -- top-level function
DateTime mostRecent(List<DateTime> dates) { ... }

// Usually unnecessary
class DateUtils {
  static DateTime mostRecent(List<DateTime> dates) { ... }
}
```

---

## 5. Collections

### Collection Literals

PREFER collection literals over constructor calls.

```dart
// Good
var points = <Point>[];
var addresses = <String, Address>{};
var uniqueNames = <String>{};

// Bad
var points = List<Point>();
var addresses = Map<String, Address>();
```

### Emptiness Checks

Use `.isEmpty` and `.isNotEmpty` instead of `.length == 0`. The `Iterable` contract does not guarantee constant-time `.length`.

```dart
// Good
if (lunchBox.isEmpty) return 'no lunch today';
if (words.isNotEmpty) processWords(words);

// Bad
if (lunchBox.length == 0) return 'no lunch today';
```

Linter rules: `prefer_is_empty`, `prefer_is_not_empty`

### Spread Operator

Insert all elements from one collection into another:

```dart
var a = [1, 2, 3];
var b = [0, ...a, 4];  // [0, 1, 2, 3, 4]
```

Null-aware spread for nullable collections:

```dart
List<int>? maybeList;
var items = [0, ...?maybeList, 5];  // [0, 5]
```

### Collection if and Collection for

Build collections declaratively with embedded control flow:

```dart
var nav = [
  'Home',
  'Furniture',
  if (proMember) 'Outlet',
];

var listOfStrings = [
  '#0',
  for (var i in listOfInts) '#$i',
];
```

Combine them for filter-map patterns:

```dart
var evenSquares = [
  for (var n in numbers)
    if (n.isEven) n * n,
];
```

### Iteration

PREFER `for` loops over `.forEach()` with function literals for readability. Using `.forEach()` with an existing function reference is acceptable.

```dart
// Good
for (final element in collection) {
  process(element);
}

// Acceptable -- existing function reference
elements.forEach(print);

// Avoid
elements.forEach((element) {
  process(element);
});
```

### Type Filtering

Use `.whereType<T>()` to filter by type rather than `.where()` with `is`.

```dart
// Good
var ints = objects.whereType<int>();

// Bad
var ints = objects.where((e) => e is int).cast<int>();
```

### Avoid cast()

Create collections with the correct types from the start. Use `List<T>.from()` for eager conversion. Avoid `.cast<T>()` which adds a lazy wrapper.

```dart
// Good
var ints = List<int>.from(dynamicList);

// Bad
var ints = dynamicList.cast<int>();
```

---

## 6. Error Handling

### Exception vs Error

Dart has two hierarchies for throwable objects:

- **`Exception`**: Conditions that a program can reasonably catch and recover from. Thrown for runtime failures external to the program (network errors, file not found, parse failures).
- **`Error`**: Programmer mistakes and bugs. `ArgumentError`, `StateError`, `RangeError`, `TypeError`, `StackOverflowError`. These indicate bugs that should be fixed in code rather than caught.

### Throwing

Use `throw` with `Exception` or `Error` subtypes. While Dart allows throwing any non-null object, prefer typed exceptions.

```dart
throw FormatException('Expected at least 1 section');
throw ArgumentError.value(port, 'port', 'Must be between 0 and 65535');

// Arrow functions
void notImplemented() => throw UnimplementedError();
```

### Catching

Use `on` to catch by type. Use `catch` when you need access to the exception object. Combine them.

```dart
try {
  parseConfig(input);
} on FormatException catch (e) {
  log.warning('Bad config: $e');
  return defaultConfig;
} on IOException {
  return cachedConfig;
}
```

Capture the stack trace with a second parameter:

```dart
try {
  await fetchData();
} catch (e, stackTrace) {
  log.severe('Fetch failed', e, stackTrace);
}
```

### Rethrow

Use `rethrow` (not `throw e`) to preserve the original stack trace.

```dart
try {
  processData();
} catch (e) {
  if (!canHandle(e)) rethrow;
  handleGracefully(e);
}
```

### Rules

- **AVOID catches without `on` clauses.** Catch-all handlers hide bugs and swallow critical errors like `StackOverflowError`. Always specify the exception type.
- **DO NOT discard errors.** Log them, display them, or rethrow them. Silent catches mask bugs.
- **DO throw `Error` only for programmer mistakes.** For runtime conditions, throw `Exception` subtypes.
- **AVOID catching `Error` or its subtypes in application code.** They indicate programmer mistakes that should be fixed at the source. Catching `Error` is acceptable in infrastructure code (crash reporters, test runners, isolate supervisors) that logs and rethrows or terminates gracefully.

### Assert

Use `assert` for development-time invariant checks. Assertions are stripped in production builds.

```dart
assert(googlesPerMinute > 0, 'Rate must be positive');
assert(googlesPerMinute > 0);  // Message is optional
```

Assertions work in debug mode, test runners, and with `--enable-asserts`. They are ignored in production.

---

## 7. Async Patterns

### async/await

PREFER `async`/`await` over raw `.then()` chains. It reads like synchronous code and integrates with `try`/`catch`.

```dart
// Good
Future<String> readConfig() async {
  final file = File('config.yaml');
  final contents = await file.readAsString();
  return contents.trim();
}

// Avoid
Future<String> readConfig() {
  return File('config.yaml')
      .readAsString()
      .then((contents) => contents.trim());
}
```

### When to Omit async

Omit `async` only when the function body is a single return of an existing Future with no transformation or error handling. In all other cases, prefer `async`/`await` for consistent error propagation and readability.

```dart
// OK to omit async -- pure forwarding, no transformation
Future<Response> fetchData() => _client.get(uri);

// Use async -- transformation or error handling involved
Future<int> fetchCount() async {
  final response = await http.get(uri);
  return int.parse(response.body);
}
```

The overhead of `async` (one state machine allocation) is negligible in practice. When in doubt, use `async`/`await`.

### Future<void>

Use `Future<void>` for async functions that produce no meaningful return value. Do not use bare `Future`.

```dart
// Good
Future<void> saveConfig(String data) async {
  await File('config.yaml').writeAsString(data);
}

// Bad
Future saveConfig(String data) async { ... }
```

### Streams

Streams provide sequences of values over time. Use `async*` and `yield` for generator-style streams.

```dart
Stream<int> countStream(int max) async* {
  for (var i = 0; i < max; i++) {
    yield i;
    await Future.delayed(Duration(seconds: 1));
  }
}
```

Process streams with `await for`:

```dart
Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (final value in stream) {
    sum += value;
  }
  return sum;
}
```

PREFER higher-order stream methods (`.map()`, `.where()`, `.transform()`) for stream transformation.

### Completer

AVOID using `Completer` directly. It is a low-level primitive for bridging callback-based APIs to Futures. Use `async`/`await` or `.then()` for typical scenarios.

```dart
// Bad -- unnecessary Completer
Future<String> getValue() {
  final completer = Completer<String>();
  fetchCallback((value) => completer.complete(value));
  return completer.future;
}

// Good -- only when bridging non-Future async APIs
Future<String> getValue() {
  final completer = Completer<String>();
  nativeCallback.onSuccess = (v) => completer.complete(v);
  nativeCallback.onError = (e) => completer.completeError(e);
  return completer.future;
}
```

### FutureOr<T>

AVOID using `FutureOr<T>` as a return type. Accept it as a parameter type when needed, but return either `T` or `Future<T>` consistently.

### Testing for Future<T> with FutureOr

When disambiguating `FutureOr<T>` where `T` could be `Object`, test for `Future<T>` first:

```dart
// Good
if (value is Future<T>) {
  // handle async
} else {
  // handle sync
}

// Bad -- Future<Object> is also Object
if (value is T) { ... }
```

---

## 8. Documentation

### Doc Comments

- Use `///` for doc comments, not `//` or `/** */`.
- Start with a single-sentence summary, followed by a blank line.
- Write doc comments for all public APIs.
- Use `[identifier]` to link to other APIs in doc comments.
- Describe parameters, return values, and exceptions in prose, not `@param` tags.

```dart
/// Formats an age as a human-friendly string.
///
/// Given a [dateOfBirth] in ISO 8601 format and an optional [asOf] reference
/// date, returns a string like "6 weeks" or "3 1/2 years".
///
/// Returns `null` if [dateOfBirth] is empty, unparseable, or in the future
/// relative to [asOf].
String? formatAge(String dateOfBirth, [String? asOf]) { ... }
```

- Format comments like sentences: capitalize the first word, end with a period.
- Do not use block comments (`/* */`) for documentation.
- Put doc comments before metadata annotations.

---

## 9. Common Idioms

### Cascade Notation (..)

Chain multiple operations on the same object without repeating the variable name. The cascade returns the original object, not the result of each call.

```dart
var paint = Paint()
  ..color = Colors.black
  ..strokeCap = StrokeCap.round
  ..strokeWidth = 5.0;
```

Null-shorting cascade: `?..` at the beginning of a cascade chain short-circuits all subsequent `..` operations in that chain. If the receiver is null, none of the cascade operations execute.

```dart
querySelector('#confirm')
  ?..text = 'Confirm'
  ..classes.add('important');
```

AVOID returning `this` from methods to enable chaining. Use cascades instead.

### Null-Aware Operators

```dart
// Conditional member access -- short-circuits if null
var name = employee?.name;

// Null-coalescing -- provide a default
var playerName = name ?? 'Guest';

// Null-coalescing assignment -- assign only if null
b ??= fallbackValue;

// Null-aware spread in collections
var items = [1, ...?maybeList, 5];
```

### final vs const

- `final`: Set once at runtime. The variable cannot be reassigned, but the object it points to can be mutated (if mutable).
- `const`: Compile-time constant. The object itself is deeply immutable.

```dart
final name = 'Bob';       // Set once, cannot reassign
final list = [1, 2, 3];   // Cannot reassign list, but CAN modify contents
list.add(4);               // OK

const bar = 1000000;       // Compile-time constant
const list = [1, 2, 3];   // Deeply immutable
// list.add(4);            // Runtime error
```

Use `final` for local variables that are not reassigned. Use `const` for values known at compile time. Use `var` only for variables that are reassigned.

```dart
// Good -- final for non-reassigned locals
final months = age.months;
final diffDays = age.diffDays;

// Good -- var when reassignment is needed
var clampedBirthday = dob.$3;
if (clampedBirthday > lastDay) clampedBirthday = lastDay;
```

Linter rules: `prefer_final_locals`, `prefer_final_fields`

### late Variables

`late` serves two purposes:

1. **Declare non-nullable variables initialized after declaration:**

```dart
late String description;

void initialize() {
  description = 'Feijoada!';
}
```

2. **Lazy initialization** (the initializer runs on first access):

```dart
late String temperature = readThermometer();  // Called only when accessed
```

AVOID `late` when initializer lists or nullable types suffice. `late` defers errors to runtime, where initializer lists catch them statically.

```dart
// Prefer -- static safety via initializer list
class Point {
  final double x;
  final double y;
  Point.polar(double theta, double radius)
      : x = cos(theta) * radius,
        y = sin(theta) * radius;
}

// Avoid -- late defers the error to runtime
class Point {
  late final double x;
  late final double y;
  Point.polar(double theta, double radius) {
    x = cos(theta) * radius;
    y = sin(theta) * radius;
  }
}
```

AVOID `late` variables when you need to check whether they have been initialized. Dart provides no safe way to test this. Use nullable types and check for `null` instead.

### Fields and Properties

Do not wrap fields in getters and setters unnecessarily. Fields and getter/setter pairs are interchangeable in Dart's API -- you can add logic later without breaking callers.

```dart
// Good -- expose the field directly
class Box {
  Object? contents;
}

// Unnecessary wrapper
class Box {
  Object? _contents;
  Object? get contents => _contents;
  set contents(Object? value) { _contents = value; }
}
```

Use `=>` for simple getters and single-expression methods:

```dart
double get area => width * height;
bool get isEmpty => length == 0;
String toString() => 'Point($x, $y)';
```

### this

Do not use `this.` except to disambiguate when a local variable shadows a field, or in constructor redirection.

```dart
// Good
class Box {
  Object? value;

  void update(Object? value) {
    this.value = value;  // Necessary -- local shadows field
  }

  void clear() {
    value = null;  // No shadowing -- omit this.
  }
}
```

Linter rule: `unnecessary_this`

### String Handling

- Use adjacent string literals for concatenation: `'Hello ' 'World'`.
- Prefer interpolation: `'Hi, $name!'` over `'Hi, ' + name + '!'`.
- Omit braces in interpolation for simple identifiers: `$name` not `${name}`.
- Use braces when followed by alphanumerics: `${decade}s`.

### Function Declarations and Tear-offs

- Use function declarations, not variable assignments, to bind named functions.
- Use tear-offs instead of wrapping in lambdas.

```dart
// Good -- tear-off
charCodes.forEach(print);

// Bad -- unnecessary lambda
charCodes.forEach((code) => print(code));
```

### Pattern Matching and Records (Dart 3.0+)

Dart 3.0 introduced records (lightweight tuples) and pattern matching.

```dart
// Records
(int, int, int)? _parseDateParts(String s) {
  // ...
  return (y, m, d);
}

// Destructuring
final parts = _parseDateParts(dateStr);
if (parts != null) {
  final (year, month, day) = parts;
}

// Switch expressions
String describe(Shape shape) => switch (shape) {
  Circle(radius: var r) => 'Circle with radius $r',
  Square(side: var s) => 'Square with side $s',
};
```

### Design Conventions

- Use terms consistently across an API.
- Avoid abbreviations unless the abbreviation is more recognized than the full word.
- Put the most descriptive noun last: `pageCount` not `countOfPages`.
- Use imperative verbs for side-effecting methods: `list.add()`, `queue.removeFirst()`.
- Use nouns or non-imperative verbs when the return value is the primary purpose: `list.elementAt(3)`.
- Do not start method names with `get` -- use a getter or a more specific verb.
- Name conversion methods `toX()` for copies, `asX()` for views.
- Follow `[start, end)` conventions for ranges: inclusive start, exclusive end.

---

## 10. Things to Avoid

### dynamic Abuse

Never use `dynamic` as a shortcut for "I don't know the type." It disables all static checking. Use `Object?` when you truly need to accept any value but still want type safety.

```dart
// Good -- still type-safe
void log(Object? value) {
  print(value.toString());
}

// Bad -- no static checking
void log(dynamic value) {
  print(value.toString());
}
```

### Unnecessary this

Do not qualify member access with `this.` unless resolving a name conflict. Dart scope rules are clear without it.

### print in Production

Do not use `print()` in production code. Use a proper logging framework. `print()` is acceptable in tests, scripts, and examples.

### Storing Computed Values in Mutable Classes

AVOID caching computed values in fields of mutable classes. Mutation can cause the cached value to become stale, leading to subtle bugs. Compute on demand instead.

```dart
// Good -- compute on demand in a mutable class
class Circle {
  double radius;
  Circle(this.radius);
  double get area => pi * radius * radius;
}

// Bad -- stale cache risk because radius is mutable
class Circle {
  double radius;
  double area;
  Circle(this.radius) : area = pi * radius * radius;
  // area becomes wrong if radius changes
}
```

Pre-computing derived values is safe in immutable (all-`final`) classes, since the inputs can never change:

```dart
// Safe -- all fields are final, no stale-cache risk
class Circle {
  final double radius;
  final double area;
  Circle(this.radius) : area = pi * radius * radius;
}
```

### Returning this for Fluent Interfaces

AVOID returning `this` to enable method chaining. Use Dart's cascade notation instead.

### Nullable Return Types for Collections, Futures, and Streams

AVOID returning `null` from functions that return collections, Futures, or Streams. Return empty containers to let callers use `.isEmpty` and avoid null checks.

```dart
// Good
List<String> getNames() => [];

// Bad
List<String>? getNames() => null;
```

### Positional Boolean Parameters

AVOID positional boolean parameters. They are cryptic at the call site. Use named parameters.

```dart
// Good
Widget build({required bool selected, required bool disabled}) { ... }
build(selected: true, disabled: false);

// Bad
Widget build(bool selected, bool disabled) { ... }
build(true, false);  // What do these mean?
```

### Overriding == on Mutable Classes

AVOID defining custom equality on mutable classes. Mutation can break hash-based collections (Maps, Sets) that rely on stable equality.

### Setters Without Getters

Do not define a setter without a corresponding getter. Properties are expected in pairs.

---

## 11. Tooling

### dart analyze

Runs static analysis on your project. Catches type errors, null safety violations, and linter rule violations.

```bash
dart analyze
dart analyze lib/src/format_age.dart
```

Aim for **zero warnings, zero info diagnostics** in CI. Suppress individual diagnostics only with justification.

### dart fix

Automatically applies fixes for many linter rules and deprecation warnings.

```bash
dart fix --dry-run    # Preview changes
dart fix --apply      # Apply fixes
```

### dart format

Formats code to the official Dart style. Run before every commit.

```bash
dart format .
dart format lib/src/format_age.dart
dart format --set-exit-if-changed .  # Fail in CI if unformatted
```

### analysis_options.yaml

Place at the package root. A minimal configuration that extends the recommended rule set:

```yaml
# Include the recommended rules -- most standard lints are already enabled
include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
    strict-inference: true
  exclude:
    - build/**
    - '**.g.dart'
  errors:
    # Promote specific diagnostics
    missing_return: error
    dead_code: info

linter:
  rules:
    # Additional rules beyond the recommended set
    - always_declare_return_types
    - avoid_dynamic_calls
    - prefer_final_locals
    - prefer_final_fields

    # Disable rules from the included set (with justification)
    # some_rule: false

formatter:
  page_width: 80
```

When not extending a rule set, the full standalone list of rules is available in the [linter rules catalog](https://dart.dev/tools/linter-rules). Only list rules individually when you are not using an `include` -- otherwise you create duplicates that add maintenance burden without benefit.

### Severity Levels

| Level | Effect |
|-------|--------|
| `error` | Fails `dart analyze` |
| `warning` | Reported but does not fail by default |
| `info` | Informational only |

Customize per diagnostic:

```yaml
analyzer:
  errors:
    invalid_assignment: error
    dead_code: info
```

### Suppressing Diagnostics

Suppress a single line:

```dart
// ignore: unused_local_variable
var temp = computeValue();
```

Suppress for an entire file:

```dart
// ignore_for_file: unused_local_variable
```

Always document why a suppression is necessary. Unexplained `ignore` comments are a code smell.

### Key Linter Rules for Auditing

These rules are particularly important when auditing Dart code:

| Rule | Purpose |
|------|---------|
| `always_declare_return_types` | Every function has an explicit return type |
| `annotate_overrides` | `@override` annotation on all overrides |
| `avoid_dynamic_calls` | Prevent calls on `dynamic` typed expressions |
| `avoid_init_to_null` | No redundant `= null` initializations |
| `camel_case_types` | Types use UpperCamelCase |
| `constant_identifier_names` | Constants use lowerCamelCase |
| `curly_braces_in_flow_control_structures` | Braces on all if/else/for/while |
| `non_constant_identifier_names` | Variables use lowerCamelCase |
| `prefer_const_constructors` | Use const when possible |
| `prefer_final_fields` | Mark fields final when not reassigned |
| `prefer_final_locals` | Mark locals final when not reassigned |
| `prefer_is_empty` | Use `.isEmpty` not `.length == 0` |
| `prefer_relative_imports` | Use relative imports within the same package |
| `slash_for_doc_comments` | Use `///` not `/** */` |
| `unnecessary_const` | Remove redundant const keywords |
| `unnecessary_new` | Remove all `new` keywords |
| `unnecessary_this` | Remove `this.` except when needed |

See the [full linter rules catalog](https://dart.dev/tools/linter-rules) for the complete list.

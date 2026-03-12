# PHP Style Guide

A reference for auditing and writing PHP implementations in this project. Covers naming, formatting, type system, class design, error handling, idiomatic patterns, and tooling. All recommendations align with PSR-1, PER Coding Style 3.0, and community consensus.

## Table of Contents

- [1. Naming Conventions](#1-naming-conventions)
- [2. Code Formatting](#2-code-formatting)
- [3. Type System](#3-type-system)
- [4. Class Design](#4-class-design)
- [5. Namespace and Autoloading](#5-namespace-and-autoloading)
- [6. Error Handling](#6-error-handling)
- [7. Array Handling](#7-array-handling)
- [8. String Handling](#8-string-handling)
- [9. Common Idioms](#9-common-idioms)
- [10. PHPDoc Annotations](#10-phpdoc-annotations)
- [11. Things to Avoid](#11-things-to-avoid)
- [12. Tooling](#12-tooling)
- [Sources](#sources)

---

## 1. Naming Conventions

### Classes, Interfaces, Traits, Enums

Use `StudlyCaps` (PascalCase). Each word starts with a capital letter, no underscores.

```php
class HttpClient {}
interface Stringable {}
trait HasTimestamps {}
enum PluralCategory {}
```

Avoid abbreviations and acronyms unless they are more widely used than the long form (e.g., `HTTP`, `URL`). When used, treat multi-letter acronyms as words: `HttpClient`, not `HTTPClient`.

### Methods and Functions

Use `camelCase`. Start with a lowercase letter.

```php
public function formatAge(): string {}
function calculateDaysBetween(DateTimeInterface $a, DateTimeInterface $b): int {}
```

Never prefix with underscores to indicate visibility. Use actual visibility keywords instead.

### Properties

PSR-1 intentionally leaves property naming open, but the PHP community overwhelmingly uses `camelCase`. Be consistent within a project.

```php
private int $dayCount;
protected string $delimiter;
public readonly string $name;
```

Never use the `var` keyword. Never prefix with underscores for visibility.

### Constants

Use `UPPER_CASE` with underscore separators for class constants and global constants.

```php
class Config
{
    public const MAX_RETRIES = 3;
    public const VERSION = '0.5.0';
    public const DATE_FORMAT = 'Y-m-d';
}
```

Enum cases use `PascalCase` (per PER Coding Style):

```php
enum Suit: string
{
    case Hearts = 'H';
    case Diamonds = 'D';
}
```

### Namespaces

Use `StudlyCaps` for each segment. Must include a top-level vendor namespace.

```php
namespace Sayable\Age;
namespace Sayable\Age\Locales;
```

### Summary Table

| Symbol         | Convention     | Example               |
| -------------- | -------------- | --------------------- |
| Class          | `StudlyCaps`   | `AgeLocale`           |
| Interface      | `StudlyCaps`   | `Stringable`          |
| Trait          | `StudlyCaps`   | `HasTimestamps`       |
| Enum           | `StudlyCaps`   | `PluralCategory`      |
| Enum case      | `PascalCase`   | `PluralCategory::One` |
| Method         | `camelCase`    | `formatAge()`         |
| Function       | `camelCase`    | `calculateDays()`     |
| Property       | `camelCase`    | `$dayCount`           |
| Constant       | `UPPER_CASE`   | `MAX_RETRIES`         |
| Namespace      | `StudlyCaps`   | `Sayable\Age`         |
| Variable       | `camelCase`    | `$ageInDays`          |

---

## 2. Code Formatting

### Standard

Follow **PER Coding Style 3.0** (which supersedes PSR-12). PSR-12 remains widely enforced; PER extends it for PHP 8.x features.

### Indentation

4 spaces. Never tabs.

### Line Length

- No hard limit.
- Soft limit: 120 characters.
- Lines should generally stay under 80 characters where practical.
- No trailing whitespace.
- One statement per line.

### File Structure

Every PHP-only file must omit the closing `?>` tag. Files must use Unix LF line endings and end with a single newline.

File header elements appear in this order, each separated by a single blank line:

```php
<?php

/**
 * File-level docblock (optional).
 */

declare(strict_types=1);

namespace Vendor\Package;

use Vendor\Package\ClassA;
use Vendor\Package\ClassB;

use function Vendor\Package\someFunction;

use const Vendor\Package\SOME_CONSTANT;

// Code begins here
```

### Braces

Opening braces for classes and methods go on the next line. Opening braces for control structures go on the same line.

```php
class Formatter
{
    public function format(int $days): string
    {
        if ($days < 0) {
            throw new InvalidArgumentException('Negative days');
        }

        return (string) $days;
    }
}
```

### Control Structures

One space after the keyword. No space after `(` or before `)`. Body always in braces.

```php
if ($expr1) {
    // ...
} elseif ($expr2) {
    // ...
} else {
    // ...
}

while ($condition) {
    // ...
}

for ($i = 0; $i < $count; $i++) {
    // ...
}

foreach ($items as $key => $value) {
    // ...
}

try {
    // ...
} catch (FirstException $e) {
    // ...
} catch (SecondException | ThirdException $e) {
    // ...
} finally {
    // ...
}
```

Use `elseif` rather than `else if`.

### Multi-line Conditions

First condition on the next line. Boolean operators at the beginning of each line. Closing parenthesis and opening brace on their own line.

```php
if (
    $longConditionA
    && $longConditionB
    && $longConditionC
) {
    // ...
}
```

### Multi-line Arguments

One argument per line, first on the next line, trailing comma on the last item. Closing parenthesis and opening brace together.

```php
public function createLocale(
    string $code,
    Units $units,
    Stages $stages,
    string $delimiter,
): AgeLocale {
    // ...
}
```

### Operators

Space before and after all binary operators (`+`, `-`, `*`, `/`, `%`, `.`, `===`, `!==`, `&&`, `||`, `??`, `=`, `+=`, etc.).

No space between unary operators and operands: `$i++`, `++$i`, `!$flag`.

Type casts: no space inside parentheses, one space before the variable: `(int) $value`.

### Trailing Commas

Required on the last item in multi-line lists (arguments, arrays, `match` arms, `use` lists). Not required in single-line lists.

```php
// Single-line: no trailing comma needed
$arr = ['a', 'b', 'c'];

// Multi-line: trailing comma required
$arr = [
    'alpha',
    'beta',
    'gamma',
];
```

### Ternary and Null Coalescing

Space before and after `?`, `:`, and `??`. When split across lines, operators at the beginning of each line, on three separate lines (never two).

```php
$value = $condition ? 'yes' : 'no';

$result = $possiblyNull ?? 'default';

$longResult = $veryLongConditionExpression
    ? 'true branch'
    : 'false branch';
```

---

## 3. Type System

### Always Use `declare(strict_types=1)`

Every PHP file must begin with strict type enforcement. This prevents silent type coercion and catches bugs at call time.

```php
<?php

declare(strict_types=1);
```

Without strict types, PHP silently coerces `sum(1.5, 2.5)` to `int(3)` if the signature is `function sum(int $a, int $b)`. With strict types, this throws a `TypeError`.

### Type Declarations

Declare types on all function parameters, return values, and class properties.

```php
class User
{
    public string $name;
    private int $age;

    public function __construct(string $name, int $age)
    {
        $this->name = $name;
        $this->age = $age;
    }

    public function isAdult(): bool
    {
        return $this->age >= 18;
    }
}
```

### Short Type Keywords

Always use the short form. These are lowercase.

| Use     | Not        |
| ------- | ---------- |
| `bool`  | `boolean`  |
| `int`   | `integer`  |
| `float` | `double`   |

Using `boolean` or `integer` in type declarations is a fatal error (PHP interprets them as class names).

### Nullable Types (PHP 7.1+)

Use the `?` prefix. No space between `?` and the type.

```php
public function find(int $id): ?User
{
    // Returns User or null
}
```

For union type syntax (PHP 8.0+), `Type|null` is equivalent but more verbose. Prefer `?Type` when only one type is involved.

### Union Types (PHP 8.0+)

No spaces around the `|` operator.

```php
public function process(int|string $value): int|string
{
    // ...
}
```

### Intersection Types (PHP 8.1+)

No spaces around the `&` operator. Only class/interface types allowed.

```php
public function handle(Countable&Iterator $collection): void
{
    // $collection must implement both Countable and Iterator
}
```

### DNF Types (PHP 8.2+)

Combine union and intersection with parentheses.

```php
function process((Countable&Iterator)|array $input): void
{
    // ...
}
```

### Special Return Types

```php
// void: function returns nothing (PHP 7.1+)
public function save(): void
{
    $this->persist();
}

// never: function always throws or exits (PHP 8.1+)
public function abort(): never
{
    throw new RuntimeException('Aborted');
}

// static: returns instance of the called class (PHP 8.0+)
public static function create(): static
{
    return new static();
}

// mixed: any type (PHP 8.0+) -- avoid when a more specific type is possible
public function transform(mixed $data): mixed
{
    // ...
}
```

### Readonly Properties (PHP 8.1+)

Can only be assigned once, in the constructor.

```php
class Locale
{
    public function __construct(
        public readonly string $code,
        public readonly string $name,
    ) {}
}
```

### Typed Class Constants (PHP 8.3+)

```php
class Config
{
    public const string VERSION = '1.0.0';
    public const int MAX_SIZE = 1024;
}
```

---

## 4. Class Design

### Visibility

Declare visibility on all properties, methods, and constants. Never use `var`.

```php
class Example
{
    public const VERSION = '1.0';
    private int $count = 0;
    protected string $name;

    public function increment(): void
    {
        $this->count++;
    }
}
```

### Modifier Keyword Order

When multiple modifiers are present, they must follow this order:

1. `abstract` or `final`
2. Visibility (`public`, `protected`, `private`)
3. `static`
4. `readonly`
5. Type declaration
6. Name

Not every combination of modifiers is valid in PHP. Examples of valid combinations:

```php
// abstract applies to methods only, not properties
abstract protected function compute(): int;

// final + visibility + static on a method
final public static function create(): static {}

// visibility + readonly on a promoted property
public readonly string $name;

// visibility + static on a property
private static int $instanceCount = 0;
```

### Constructor Promotion (PHP 8.0+)

Declare and assign properties directly in the constructor signature. Reduces boilerplate.

```php
class AgeLocale
{
    public function __construct(
        public readonly string $code,
        public readonly Units $units,
        public readonly Stages $stages,
        public readonly string $delimiter,
        public readonly string $justBorn,
    ) {}
}
```

### Enums (PHP 8.1+)

Preferred over class constants for fixed value sets. Cases use `PascalCase`.

```php
enum PluralCategory
{
    case Zero;
    case One;
    case Two;
    case Few;
    case Many;
    case Other;
}
```

Backed enums associate a scalar value with each case:

```php
enum Compactness: string
{
    case Full = 'full';
    case Compact = 'compact';
}
```

Enums can have methods, implement interfaces, and use traits (without state). They cannot be extended.

```php
enum Suit: string
{
    case Hearts = 'H';
    case Diamonds = 'D';
    case Clubs = 'C';
    case Spades = 'S';

    public function color(): string
    {
        return match ($this) {
            self::Hearts, self::Diamonds => 'red',
            self::Clubs, self::Spades => 'black',
        };
    }
}
```

Non-public enum methods must use `private` (never `protected`, since enums cannot be extended).

### Interfaces

Define contracts. Name for the capability, not with an `I` prefix.

```php
interface Formatter
{
    public function format(int $days): string;
}
```

### Traits

Use for horizontal code reuse across classes that do not share an is-a relationship. Traits can carry state -- that is one of their legitimate uses. The anti-pattern is using a trait as a substitute for inheritance when the consuming classes genuinely share a parent type, or accumulating unrelated behaviors in a single trait.

```php
trait HasTimestamps
{
    private DateTimeInterface $createdAt;

    public function getCreatedAt(): DateTimeInterface
    {
        return $this->createdAt;
    }
}
```

Trait `use` statements go on the line after the opening brace, one per line, with a blank line before other members.

```php
class Post
{
    use HasTimestamps;
    use SoftDeletes;

    private string $title;
}
```

### Final Classes

Use `final` to prevent inheritance when a class is not designed for extension.

```php
final class AgeFormatter
{
    // ...
}
```

### Readonly Classes (PHP 8.2+)

All declared properties are automatically readonly. No untyped or static properties allowed.

```php
readonly class Coordinate
{
    public function __construct(
        public float $latitude,
        public float $longitude,
    ) {}
}
```

A readonly class can only be extended by another readonly class.

### Abstract Classes

Use when you need shared implementation plus a contract for subclasses.

```php
abstract class BaseLocale
{
    abstract public function pluralize(int $count, string $singular, string $plural): string;

    public function formatUnit(int $count, string $singular, string $plural): string
    {
        return $count . ' ' . $this->pluralize($count, $singular, $plural);
    }
}
```

### Abbreviated Empty Bodies

Classes and methods with no body may use a compact form:

```php
class MyException extends RuntimeException {}

public function noop(): void {}
```

---

## 5. Namespace and Autoloading

### PSR-4

Map namespace prefixes to base directories. The terminating class name maps directly to a `.php` filename (case-sensitive).

```
\Sayable\Age\AgeLocale       -> src/AgeLocale.php
\Sayable\Age\Locales\EnUs    -> src/Locales/EnUs.php
```

Configured in `composer.json`:

```json
{
    "autoload": {
        "psr-4": {
            "Sayable\\Age\\": "src/"
        }
    }
}
```

### Use Statements

Group by category, separated by blank lines: classes first, then functions, then constants.

```php
use Sayable\Age\AgeLocale;
use Sayable\Age\PluralCategory;

use function Sayable\Age\formatAge;

use const Sayable\Age\VERSION;
```

Never begin a `use` statement with a leading backslash.

Compound use declarations are permitted. Each import should appear on its own line within the group:

```php
use Vendor\Package\Namespace\{
    SubOne\ClassA,
    SubTwo\ClassB,
    ClassC,
};
```

### Leading Backslash on Global Functions

In namespaced code, call global PHP functions with a leading backslash. This bypasses namespace-relative function lookup, preventing accidental shadowing if a function with the same name is defined in the current namespace.

```php
// In a namespaced file:
$len = \strlen($input);
$parts = \explode('-', $date);
$result = \intdiv($total, $divisor);
$now = \date('Y-m-d');
```

Without the leading backslash, PHP first looks for `SayableAge\strlen()` before falling back to the global `\strlen()`. The leading backslash eliminates that unnecessary lookup.

### One Class Per File

Each class, interface, trait, or enum resides in its own file. The filename matches the class name exactly.

---

## 6. Error Handling

### Exception Hierarchy

```
Throwable (interface)
+-- Error           (engine errors: TypeError, ValueError, etc.)
+-- Exception       (application errors)
    +-- LogicException
    |   +-- InvalidArgumentException
    |   +-- BadMethodCallException
    |   +-- DomainException
    |   +-- LengthException
    |   +-- OutOfRangeException
    |   +-- ...
    +-- RuntimeException
        +-- OutOfBoundsException
        +-- OverflowException
        +-- RangeException
        +-- UnderflowException
        +-- UnexpectedValueException
        +-- ...
```

### Use Specific Exception Types

Prefer SPL exceptions or custom exceptions over the base `Exception` class.

```php
// Good: specific
throw new InvalidArgumentException('Date of birth cannot be in the future');

// Avoid: generic
throw new Exception('Bad input');
```

### Custom Exceptions

Extend `RuntimeException` or `LogicException` depending on whether the error is recoverable at runtime or indicates a programming mistake.

```php
class LocaleNotFoundException extends RuntimeException
{
    public function __construct(string $code)
    {
        parent::__construct("Locale not found: {$code}");
    }
}
```

### Try/Catch/Finally

Each `try` must have at least one `catch` or `finally`. Catch the most specific exception first.

```php
try {
    $locale = loadLocale($code);
} catch (LocaleNotFoundException $e) {
    $locale = loadLocale('en');
} catch (Throwable $e) {
    log($e->getMessage());
    throw $e;
} finally {
    cleanup();
}
```

### Non-capturing Catches (PHP 8.0+)

Omit the variable when you do not need it.

```php
try {
    riskyOperation();
} catch (SpecificException) {
    return fallbackValue();
}
```

### Union Exception Types (PHP 8.0+)

Catch multiple exception types in a single `catch` block.

```php
try {
    process($data);
} catch (InvalidArgumentException | RangeException $e) {
    handleBadInput($e);
}
```

### Throw as Expression (PHP 8.0+)

```php
$value = $input ?? throw new InvalidArgumentException('Input required');
```

### Error vs. Exception

- `Error` and its subclasses (`TypeError`, `ValueError`, `ArithmeticError`) represent engine-level issues. Catch these only when you need to handle them gracefully.
- `Exception` and its subclasses represent application-level issues. These are what you should throw and catch in application code.
- Catch `Throwable` only at the outermost boundary (e.g., a global error handler).

---

## 7. Array Handling

### Short Array Syntax

Always use `[]`. Never use `array()`.

```php
$list = [1, 2, 3];
$map = ['key' => 'value'];
$empty = [];
```

### Multi-line Arrays

One element per line, trailing comma on the last element. Opening bracket on the same line as the assignment.

```php
$stages = [
    'newborn' => [0, 13],
    'weeks'   => [14, 90],
    'months'  => [91, 547],
    'years'   => [548, null],
];
```

### Array Functions

Prefer array functions over manual loops when the intent is clearer.

```php
// Mapping
$names = \array_map(fn(User $u): string => $u->name, $users);

// Filtering
$adults = \array_filter($users, fn(User $u): bool => $u->age >= 18);

// Reducing
$total = \array_reduce($items, fn(int $carry, Item $item): int => $carry + $item->price, 0);
```

### Spread Operator (PHP 7.4+ for arrays)

Use `...` to unpack arrays.

```php
$first = [1, 2, 3];
$second = [4, 5, 6];
$merged = [...$first, ...$second]; // [1, 2, 3, 4, 5, 6]
```

For named keys in function arguments (PHP 8.1+):

```php
$defaults = ['color' => 'blue', 'size' => 'large'];
$overrides = ['color' => 'red'];
$config = [...$defaults, ...$overrides]; // ['color' => 'red', 'size' => 'large']
```

### Destructuring

Use short list syntax for array unpacking.

```php
[$first, $second] = [1, 2];
['name' => $name, 'age' => $age] = $person;
```

---

## 8. String Handling

### Interpolation

Use double-quoted strings for simple variable interpolation. Prefer braces for clarity.

```php
$message = "Hello, {$user->name}";
$path = "locales/{$code}.json";
```

Use single-quoted strings when no interpolation is needed. This signals intent to the reader: the string is literal, no variable expansion will occur.

```php
$label = 'No variables here';
```

### String Concatenation

Use the `.` operator with spaces around it.

```php
$full = $first . ' ' . $last;
```

For building complex strings, prefer `sprintf` over concatenation chains.

```php
$msg = \sprintf('User %s (ID: %d) logged in at %s', $name, $id, $time);
```

### Heredoc and Nowdoc

Use nowdoc (no interpolation) where possible. Declare on the same line as the context, not on a separate line. Content indented past scope indentation. Closing identifier at proper indentation.

```php
// Nowdoc (no variable interpolation, preferred)
$template = <<<'EOT'
    This is literal text.
    No $variables are expanded.
    EOT;

// Heredoc (with variable interpolation)
$output = <<<EOT
    Hello, {$name}.
    You have {$count} messages.
    EOT;
```

### Byte Operations vs. Character Operations

PHP has two sets of string functions that serve different purposes:

- **Byte-level** (`strlen`, `substr`, `strpos`): Operate on raw bytes. Use for ASCII-only data, fixed-format parsing, protocol handling, and binary operations.
- **Character-level** (`mb_strlen`, `mb_substr`, `mb_strpos`): Operate on characters respecting encoding. Use for user-facing text that may contain multibyte characters.

Choose the function that matches your intent:

```php
// Byte-level: parsing a fixed-format ASCII date string
// strlen and substr are correct here -- we are checking byte positions
if (\strlen($s) < 10 || $s[4] !== '-' || $s[7] !== '-') {
    return null;
}
$year = (int) \substr($s, 0, 4);

// Character-level: truncating user-facing text that may contain Unicode
$truncated = \mb_substr($displayName, 0, 20, 'UTF-8');
$charCount = \mb_strlen($userInput, 'UTF-8');
```

Using `mb_strlen` for byte-level parsing is semantically wrong and slower. Using `strlen` for user-facing Unicode text will give incorrect results for multibyte characters. Match the function to the operation.

---

## 9. Common Idioms

### Null Coalescing

Use `??` instead of `isset()` ternaries. Use `??=` for null coalescing assignment.

```php
$name = $input['name'] ?? 'Anonymous';
$config['timeout'] ??= 30;
```

### Match Expressions (PHP 8.0+)

Prefer `match` over `switch` for value mapping. `match` uses strict comparison (`===`), returns a value, has no fall-through, and throws `UnhandledMatchError` if no arm matches.

```php
$label = match ($category) {
    PluralCategory::Zero  => $forms['zero'],
    PluralCategory::One   => $forms['one'],
    PluralCategory::Two   => $forms['two'],
    PluralCategory::Few   => $forms['few'],
    PluralCategory::Many  => $forms['many'],
    PluralCategory::Other => $forms['other'],
};
```

When matching an enum, exhaustiveness is enforced -- if a case is missing, PHP throws `UnhandledMatchError`. This makes omitting `default` a feature: the compiler tells you when you missed a case.

### `match(true)` for Condition-Based Branching

Use `match(true)` as a concise alternative to `if/elseif` chains when assigning a value based on conditions:

```php
$stage = match (true) {
    $days < 14  => 'newborn',
    $days < 91  => 'weeks',
    $days < 548 => 'months',
    default     => 'years',
};
```

Always include a `default` arm in `match(true)`. Unlike `if/elseif` (which simply falls through with no assignment), an unmatched `match(true)` throws `UnhandledMatchError` at runtime.

### Arrow Functions (PHP 7.4+)

Single-expression closures. They capture variables from the parent scope by value automatically.

```php
$doubled = \array_map(fn(int $n): int => $n * 2, $numbers);

$filtered = \array_filter(
    $locales,
    fn(AgeLocale $l): bool => $l->code !== 'test',
);
```

No space after `fn`. Spaces around `=>`.

### First-class Callable Syntax (PHP 8.1+)

Reference functions and methods as closures using `...`.

```php
$callback = strlen(...);
$method = $formatter->format(...);
$static = Formatter::create(...);

// Use in higher-order functions
$lengths = \array_map(\mb_strlen(...), $strings);
```

### Named Arguments (PHP 8.0+)

Improve readability for functions with many parameters or boolean flags.

```php
$locale = new AgeLocale(
    code: 'en',
    units: $units,
    stages: $stages,
    delimiter: ' ',
    justBorn: 'just born',
);
```

No space between the argument name and colon. One space between colon and value.

### Function-Scoped Static Variables

Use `static` variables inside functions for lazy initialization of values that should persist across calls within a single request (FPM) or process (CLI).

```php
function formatAge(?string $dateOfBirth, ?string $asOf = null): ?string
{
    static $default = null;
    $default ??= new SayableAge(Locales::EN());
    return $default->formatAge($dateOfBirth, $asOf);
}
```

This is appropriate for convenience wrappers that cache a default instance. Be aware of the testing implication: the static variable persists across test cases within the same process. If tests need isolation, provide a reset mechanism or use instance methods instead.

### Enum Methods and `from`/`tryFrom`

```php
// from() throws ValueError if invalid
$suit = Suit::from('H'); // Suit::Hearts

// tryFrom() returns null if invalid
$suit = Suit::tryFrom('X'); // null

// cases() returns all cases
$all = Suit::cases(); // [Suit::Hearts, Suit::Diamonds, ...]
```

---

## 10. PHPDoc Annotations

### When to Use PHPDoc

Use native PHP type declarations for everything the language can express. Use PHPDoc annotations only to provide additional type information that PHP's native type system cannot represent and that static analyzers (PHPStan, Psalm) can consume.

### Do Not Duplicate Native Types

If a parameter or return type is fully expressed by the native declaration, do not add a redundant `@param` or `@return`.

```php
// Bad: PHPDoc duplicates the native type
/** @param int $count */
public function format(int $count): string {}

// Good: native type is sufficient, no PHPDoc needed
public function format(int $count): string {}
```

### Use PHPDoc for Generic Arrays and Shapes

PHP's `array` type does not express key or value types. Use PHPDoc to describe them.

```php
/** @var array<string, string>|string */
private readonly string|array $day;

/**
 * @param array{int, int} $range  Tuple of [start, end]
 * @return array<string, AgeLocale>
 */
public function loadLocales(array $range): array {}
```

### Use PHPDoc for Callable Signatures

PHP's `callable` and `Closure` types do not express parameter or return types natively. Use PHPDoc annotations to document them.

```php
/**
 * @param Closure(int): PluralCategory $plural
 * @param (Closure(int): string)|null $formatNumber
 */
public function __construct(
    public readonly Closure $plural,
    public readonly ?Closure $formatNumber = null,
) {}
```

### Use PHPDoc for Return Type Narrowing

When a method's native return type is broad but the actual return is narrower, PHPDoc helps static analyzers and readers.

```php
/**
 * @return array{int, int}|null  [months, days] or null if invalid
 */
private static function parseAge(?string $dob, ?string $asOf): ?array {}
```

---

## 11. Things to Avoid

### Error Suppression Operator (`@`)

Never use `@` to suppress errors. It hides bugs and makes debugging difficult.

```php
// Bad
$value = @file_get_contents($path);

// Good
$value = file_get_contents($path);
if ($value === false) {
    throw new RuntimeException("Failed to read: {$path}");
}
```

### `eval()`

Never use `eval()`. It executes arbitrary code, creates security vulnerabilities, and defeats static analysis.

### `extract()`

Never use `extract()`. It creates variables from array keys, making code impossible to follow statically. Variables appear out of nowhere.

```php
// Bad: where do $name and $age come from?
extract($data);
echo $name;

// Good: explicit
$name = $data['name'];
$age = $data['age'];
```

### Variable Variables

Never use `$$var`. They defeat static analysis and make code unreadable.

```php
// Bad
$varName = 'foo';
$$varName = 'bar'; // creates $foo = 'bar'

// Good: use an array
$data['foo'] = 'bar';
```

### Mixed Return Types (Without Justification)

Avoid functions that return different types depending on the code path. Use union types only when the semantics genuinely require it (e.g., `find(): ?User`), not as a substitute for proper error handling.

```php
// Bad: returns string or false or null depending on conditions
function lookup(string $key): string|false|null { ... }

// Good: return nullable or throw
function lookup(string $key): ?string { ... }
```

### `global` Keyword

Never use `global` to access variables. Pass dependencies explicitly.

```php
// Bad
function format(): string {
    global $locale;
    return $locale->format();
}

// Good
function format(AgeLocale $locale): string {
    return $locale->format();
}
```

### Loose Comparisons

Always use strict comparison (`===`, `!==`). Loose comparison (`==`, `!=`) produces surprising results.

```php
// These are all true with ==, which is almost never what you want:
0 == 'foo'     // true in PHP 7, false in PHP 8
'' == null     // true
'' == false    // true
0 == null      // true
0 == false     // true
```

### Magic Methods as Public API

Avoid `__get`, `__set`, `__call` as core design mechanisms. They bypass static analysis, make code harder to understand, and prevent IDE support. Use them only for narrow, well-documented cases (e.g., ORM attribute access).

### Untyped Code

Do not leave parameters, return types, or properties untyped unless there is a specific technical reason (e.g., compatibility with a legacy interface). `mixed` is acceptable when truly any type is valid, but prefer specific types.

---

## 12. Tooling

### PHP-CS-Fixer (Project Standard)

This project uses PHP-CS-Fixer for automated code style enforcement with the `@PER-CS` ruleset.

```bash
# Check without modifying
vendor/bin/php-cs-fixer check

# Fix
vendor/bin/php-cs-fixer fix
```

Configuration in `.php-cs-fixer.php`:

```php
<?php

return (new PhpCsFixer\Config())
    ->setRules([
        '@PER-CS' => true,
        'strict_param' => true,
        'array_syntax' => ['syntax' => 'short'],
    ])
    ->setFinder(
        PhpCsFixer\Finder::create()
            ->in(__DIR__ . '/src')
            ->in(__DIR__ . '/tests')
    );
```

PHP_CodeSniffer (`phpcs`) is a widely-used alternative that supports PSR-12 and PER rulesets but focuses on detection rather than auto-fixing. If choosing between them, pick one -- running both on the same codebase without careful rule alignment causes conflicts.

### PHPStan

Static analysis tool. Finds bugs without running code. Rule levels 0 (basic) through 10 (strictest).

```bash
# Install
composer require --dev phpstan/phpstan

# Analyze
vendor/bin/phpstan analyse src tests
```

Configuration in `phpstan.neon`:

```neon
parameters:
    level: 9
    paths:
        - src
```

This project runs PHPStan at level 9. New code must pass at this level. Level 9 checks `mixed` type usage; level `max` (10) adds the strictest checks. For greenfield projects, starting at level 5 or 6 and working upward is reasonable, but this project's bar is level 9.

### Psalm

Alternative static analysis tool by Vimeo. More granular type system (template types, type aliases). Levels 1 (strictest) through 8 (most lenient).

```bash
# Install
composer require --dev vimeo/psalm

# Initialize config
vendor/bin/psalm --init

# Analyze
vendor/bin/psalm
```

### Rector

Automated refactoring and PHP version upgrades. Applies code transformations programmatically.

```bash
# Install
composer require --dev rector/rector

# Preview changes
vendor/bin/rector process src --dry-run

# Apply changes
vendor/bin/rector process src
```

Use cases: upgrade PHP version syntax (e.g., `array()` to `[]`), apply coding standard rules, modernize PHPUnit tests, enforce specific patterns across a codebase.

### Recommended Toolchain

| Purpose               | Tool          |
| --------------------- | ------------- |
| Code formatting       | PHP-CS-Fixer  |
| Static analysis       | PHPStan       |
| Automated refactoring | Rector        |
| Testing               | PHPUnit       |
| Dependency management | Composer      |

Run formatters and static analysis in CI. Treat all warnings as errors.

---

## Sources

- [PSR-1: Basic Coding Standard](https://www.php-fig.org/psr/psr-1/) -- class, method, and constant naming; file structure; side effects
- [PSR-12: Extended Coding Style Guide](https://www.php-fig.org/psr/psr-12/) -- formatting, braces, spacing, control structures, operators, closures
- [PER Coding Style 3.0](https://www.php-fig.org/per/coding-style/) -- supersedes PSR-12; adds PHP 8.x rules for enums, match, named arguments, union/intersection types, readonly, attributes, property hooks, trailing commas, arrow functions, heredoc/nowdoc
- [PSR-4: Autoloader](https://www.php-fig.org/psr/psr-4/) -- namespace-to-directory mapping
- [PHP: The Right Way](https://phptherightway.com/) -- community best practices, security, testing, dependency management
- [PHP Manual: Type Declarations](https://www.php.net/manual/en/language.types.declarations.php) -- scalar types, union types, intersection types, DNF types, nullable, void, never, mixed, static
- [PHP Manual: Enumerations](https://www.php.net/manual/en/language.enumerations.php) -- basic and backed enums, methods, interfaces
- [PHP Manual: Exceptions](https://www.php.net/manual/en/language.exceptions.php) -- try/catch/finally, exception hierarchy, custom exceptions
- [PHP Manual: Match Expression](https://www.php.net/manual/en/control-structures.match.php) -- syntax, strict comparison, exhaustiveness
- [PHPStan Documentation](https://phpstan.org/) -- static analysis rule levels and configuration
- [PHP-CS-Fixer](https://cs.symfony.com/) -- automated code style fixing

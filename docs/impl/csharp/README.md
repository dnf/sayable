# C# Style Guide

A comprehensive reference for idiomatic C# coding style and best practices. Intended for code auditing C# implementations.

## Sources

This guide synthesizes conventions from the following authoritative references:

- [Microsoft C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [C# Identifier Naming Rules and Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/identifier-names)
- [.NET Framework Design Guidelines](https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/)
- [.NET Runtime Coding Style](https://github.com/dotnet/runtime/blob/main/docs/coding-guidelines/coding-style.md)
- *Framework Design Guidelines*, 3rd Edition (Cwalina, Abrams, Barton)

---

## 1. Naming Conventions

### Casing Rules

| Element | Casing | Example |
|---|---|---|
| Classes, structs, enums, delegates | PascalCase | `DataService`, `ValueCoordinate` |
| Interfaces | PascalCase with `I` prefix | `IWorkerQueue`, `ISessionChannel<T>` |
| Public methods, properties, events, fields | PascalCase | `StartEventProcessing()`, `WorkerQueue` |
| Local functions | PascalCase | `CountQueueItems()` |
| Namespaces | PascalCase | `CoolStuff.AwesomeFeature` |
| Constants (fields and locals) | PascalCase | `MaxConnections`, `DefaultTimeout` |
| Private/internal instance fields | camelCase with `_` prefix | `_workerQueue` |
| Private/internal static fields | camelCase with `s_` prefix | `s_workerQueue` |
| Thread-static fields | camelCase with `t_` prefix | `t_timeSpan` |
| Method parameters | camelCase | `someNumber`, `isValid` |
| Local variables | camelCase | `seattleCustomers`, `currentMax` |
| Generic type parameters | PascalCase with `T` prefix | `TSession`, `TInput`, `TOutput` |
| Record positional parameters | PascalCase (they become public properties) | `Person(string FirstName, string LastName)` |
| Primary constructor params (class/struct) | camelCase | `DataService(IWorkerQueue workerQueue)` |

### Naming Principles

- **Prefer clarity over brevity.** Use meaningful, descriptive names for variables, methods, and classes.
- **Avoid abbreviations**, except widely known ones (`Id`, `Url`, `Html`).
- **Avoid single-letter names**, except for simple loop counters (`i`, `j`).
- **Do not encode type in the name.** Name the variable for its meaning, not its type. `inputInt` is wrong; `iterations` is right.
- **Do not use two consecutive underscores** (`__`). Those are reserved for compiler-generated identifiers.

### Special Naming Rules

```csharp
// Interfaces: always prefix with I
public interface IWorkerQueue { }

// Attributes: always suffix with Attribute
public class ObsoleteAttribute : Attribute { }

// Enums: singular noun for non-flags, plural for flags
public enum Color { Red, Green, Blue }

[Flags]
public enum Permissions { Read = 1, Write = 2, Execute = 4 }

// Async methods: suffix with Async
public Task<string> GetDataAsync() { }

// Generic type parameters: prefix with T, use descriptive names
public interface ISessionChannel<TSession> { }
public delegate TOutput Converter<TInput, TOutput>(TInput from);
// Single T is fine when meaning is obvious
public class List<T> { }
```

---

## 2. Code Formatting

### Indentation and Braces

- Use **four spaces** for indentation. Never use tabs.
- Use **Allman style** braces: opening and closing brace each on its own line, aligned with the current indentation level.
- Write **one statement per line** and **one declaration per line**.

```csharp
// Correct: Allman style
public class DataService
{
    public void ProcessData()
    {
        if (IsValid)
        {
            Execute();
        }
    }
}
```

### Line Length and Wrapping

- Keep lines to a reasonable length (120 characters is a common project-level limit; Microsoft docs use 65 for readability on mobile).
- Break long statements into multiple lines, indented one tab stop (four spaces) from the parent.
- **Line breaks occur before binary operators**, not after.

```csharp
var result = longVariableName
    + anotherLongVariable
    - yetAnother;
```

### Spacing

- One blank line between method definitions and property definitions.
- Use parentheses to make operator precedence explicit.

```csharp
if ((startX > endX) && (startX > previousX))
{
    // Take appropriate action.
}
```

### File-Scoped Namespaces

Use file-scoped namespace declarations when a file contains a single namespace (which is the common case):

```csharp
namespace Sayable.Age;

public class Formatter
{
    // ...
}
```

### Using Directives

Place `using` directives **outside** the namespace declaration. This avoids subtle resolution issues when nested namespaces shadow global ones.

```csharp
using System;
using System.Collections.Generic;

namespace Sayable.Age;
// ...
```

### Comments

- Use single-line comments (`//`) for brief explanations. Avoid multi-line `/* */` comments.
- Place comments on a separate line, not at the end of a line of code.
- Begin with an uppercase letter. End with a period.
- Insert one space between `//` and the text.
- Use XML doc comments (`///`) for all public members.
- **Comments should explain "why", not "what."** If a comment explains what code does, extract it into a named function or variable instead.

```csharp
// Postpone validation until both interrelated properties are set.
```

---

## 3. Type System

### Nullable Reference Types

Enable nullable reference types in every project:

```xml
<Nullable>enable</Nullable>
```

Key practices:

- **Annotate all reference types.** A type without `?` is non-nullable; `string?` is nullable.
- **Do not suppress warnings with `!` unless you have a clear justification.** The null-forgiving operator hides potential bugs.
- Use `ArgumentNullException.ThrowIfNull()` for runtime null checks on parameters, even when nullable annotations are enabled (callers can ignore warnings).
- Use nullable analysis attributes (`[NotNullWhen]`, `[MaybeNull]`, `[MemberNotNull]`) to communicate null-state semantics to the compiler.

```csharp
public string? MiddleName { get; init; }

public void PrintName(string name)
{
    ArgumentNullException.ThrowIfNull(name);
    Console.WriteLine(name.ToUpper());
}

bool IsNull([NotNullWhen(false)] string? s) => s == null;
```

**Known pitfalls:** `default` on structs with non-nullable reference fields silently produces nulls. Array elements initialized by `new string[10]` are null despite the non-nullable element type. Be vigilant in these cases.

### Records

Use records for immutable data-centric types where value equality is desired.

```csharp
// Positional record: generates init-only properties, Equals, GetHashCode, ToString, Deconstruct
public record Person(string FirstName, string LastName);

// Record struct: value type with value equality
public readonly record struct Point(double X, double Y);

// Nondestructive mutation with 'with' expressions
var updated = person with { LastName = "Smith" };
```

When to use records vs. classes:

| Use a record when... | Use a class when... |
|---|---|
| The type models immutable data | The type has significant mutable state |
| Value equality is the natural comparison | Identity (reference) equality matters |
| You want built-in `ToString` formatting | You need Entity Framework change tracking |
| You want `with`-expression support | You need complex inheritance hierarchies |

**Computed properties in records must compute on access**, not in the constructor, or `with` expressions will produce stale values:

```csharp
// Correct: computed on access
public record Point(int X, int Y)
{
    public double Distance => Math.Sqrt(X * X + Y * Y);
}
```

### Value Types vs. Reference Types

Use `struct` only for small, simple types that behave like primitives:

- Total instance size under ~16 bytes.
- Logically represents a single value.
- Immutable (prefer `readonly struct`).
- Short-lived, not frequently boxed.

For everything else, use a class (or record).

### Pattern Matching

Prefer pattern matching for type checks, null checks, and multi-branch logic. It is more concise and less error-prone than chains of `if`/`else` with casts.

```csharp
// Null check
if (message is not null) { }

// Type test with declaration
if (sequence is IList<T> list)
{
    return list[list.Count / 2];
}

// Switch expression for discrete values
string WaterState(int tempF) => tempF switch
{
    < 32 => "solid",
    32 => "solid/liquid transition",
    (> 32) and (< 212) => "liquid",
    212 => "liquid/gas transition",
    > 212 => "gas",
};

// Property pattern
decimal discount = order switch
{
    { Items: > 10, Cost: > 1000m } => 0.10m,
    { Items: > 5, Cost: > 500m } => 0.05m,
    { Cost: > 250m } => 0.02m,
    null => throw new ArgumentNullException(nameof(order)),
    _ => 0m,
};

// List pattern
balance += transaction switch
{
    [_, "DEPOSIT", _, var amount] => decimal.Parse(amount),
    [_, "WITHDRAWAL", .., var amount] => -decimal.Parse(amount),
    [_, "INTEREST", var amount] => decimal.Parse(amount),
    _ => throw new InvalidOperationException("Unexpected format"),
};
```

Always include a discard (`_`) or default arm to handle all possible inputs. The compiler warns about incomplete patterns.

---

## 4. Class Design

### Access Modifiers

- **Be explicit** about access modifiers. Do not rely on defaults.
- Start with the most restrictive access (`private`) and widen only as needed.
- Use `internal` for types and members that should not be part of the public API.

### Properties vs. Fields

- **Use properties for public/protected data**, even if they are simple auto-properties. Properties allow future additions (validation, change notification, lazy loading) without breaking callers.
- **Use fields only for private state.** Prefix with `_`.
- **Do not expose public fields** except in rare cases (simple data-holder types).
- Property getters should be simple and cheap. If a "getter" is expensive or can fail, make it a method instead.
- Do not provide set-only properties. If the getter cannot be provided, use a `SetXxx()` method.

```csharp
public class DataService
{
    private readonly IWorkerQueue _workerQueue;

    // Auto-property: preferred for public data
    public string Name { get; init; }

    // Computed property: cheap, no side effects
    public bool IsEmpty => _workerQueue.Count == 0;
}
```

### Init-Only and Required Properties

Use `init` accessors for properties that should be set only during initialization. Use `required` to force callers to supply values:

```csharp
public class LabelledContainer<T>
{
    public required string Label { get; init; }
    public required T Contents { get; init; }
}

var container = new LabelledContainer<int> { Label = "Count", Contents = 42 };
```

### Sealed Classes

- **Do not seal classes without a good reason.** Sealing prevents extension, which frustrates consumers.
- Good reasons to seal: static classes, security-sensitive inheritance chains, performance-critical attribute types, classes with many virtual members where sealing the overrides reduces maintenance cost.
- **Consider sealing overrides** of virtual members to prevent further fragile-base-class problems.
- **Do not declare protected or virtual members on sealed types** -- they serve no purpose.

### Interfaces

- Interfaces are the primary tool for polymorphism in C#. Prefer interfaces over abstract base classes when there is no shared implementation to inherit.
- Interface names always start with `I`.
- Keep interfaces focused (Interface Segregation Principle).

### Static Classes

Use `static class` for utility containers that have no instance state:

```csharp
public static class AgeFormatter
{
    public static string Format(DateOnly birthDate, DateOnly asOf) { ... }
}
```

---

## 5. LINQ

### Query Syntax vs. Method Syntax

Both are valid. Query syntax reads well for joins and nested `from` clauses; method syntax is more common for simple chains. Pick one style and be consistent within a file.

```csharp
// Query syntax: good for joins
var results = from customer in customers
              join order in orders on customer.Id equals order.CustomerId
              where order.Total > 100
              select new { customer.Name, order.Total };

// Method syntax: good for simple pipelines
var results = customers
    .Where(c => c.City == "Seattle")
    .OrderBy(c => c.Name)
    .Select(c => c.Name);
```

### LINQ Best Practices

- Use **meaningful names** for query variables: `seattleCustomers`, not `q`.
- Place `where` clauses **early** to filter before other operations.
- Use **implicit typing** (`var`) for query results -- the types are often anonymous or deeply nested generics.
- Rename properties in anonymous types to avoid ambiguity:

```csharp
var report = from c in customers
             join d in distributors on c.City equals d.City
             select new { CustomerName = c.Name, DistributorName = d.Name };
```

### Deferred Execution

LINQ queries are lazy. They do not execute until enumerated (`foreach`, `ToList()`, `ToArray()`, `Count()`, etc.). This matters especially with async code and database queries:

- If you need to start multiple async tasks from a LINQ projection, **force evaluation immediately** with `ToArray()` or `ToList()`:

```csharp
var tasks = userIds.Select(id => GetUserAsync(id)).ToArray();
var users = await Task.WhenAll(tasks);
```

- Be careful switching between `IQueryable<T>` (database-side) and `IEnumerable<T>` (client-side) in `foreach` statements -- it changes query execution.

---

## 6. Error Handling

### Exceptions Are the Primary Error-Reporting Mechanism

- **Do not return error codes.** Throw exceptions for execution failures.
- **Do not use exceptions for normal flow of control.** Use the Tester-Doer or Try-Parse pattern when callers need to handle expected conditions without exceptions.

### Standard Exception Types

| Exception | When to throw |
|---|---|
| `ArgumentNullException` | A required argument is `null` |
| `ArgumentOutOfRangeException` | An argument is outside the valid range |
| `ArgumentException` | An argument is invalid for another reason |
| `InvalidOperationException` | The object is in an inappropriate state for the operation |
| `NotSupportedException` | The operation is inherently unsupported by the type |
| `ObjectDisposedException` | The object has been disposed |
| `FormatException` | A string/input is not in the expected format |

- **Always set `ParamName`** when throwing `ArgumentException` or its subclasses.
- **Do not throw** `System.Exception`, `SystemException`, `NullReferenceException`, `IndexOutOfRangeException`, `StackOverflowException`, or `OutOfMemoryException`. These are reserved for the runtime.
- **Do not derive from** `ApplicationException`.

### Catching Exceptions

- Catch **specific exception types**, not `System.Exception` (except in top-level handlers).
- Use `throw;` to rethrow, preserving the stack trace. Never `throw ex;`.
- Use **exception filters** (`when`) to catch conditionally without unwinding the stack:

```csharp
try
{
    await httpClient.GetStringAsync(url);
}
catch (HttpRequestException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
{
    // Handle 404 specifically
}
```

### Custom Exceptions

- Derive from `Exception`, not `ApplicationException`.
- Name with an `Exception` suffix: `AgeCalculationException`.
- Provide the standard three constructors (parameterless, message, message + inner exception).
- Make them serializable only if cross-domain marshaling is needed.

### Using Declarations

Prefer the modern `using` declaration (without braces) over `using` statements:

```csharp
// Preferred: disposal at end of enclosing scope
using var stream = File.OpenRead(path);
var content = ReadAll(stream);

// Older style: explicit scope
using (var stream = File.OpenRead(path))
{
    var content = ReadAll(stream);
}
```

### Property Getters and Exceptions

- **Avoid throwing exceptions from property getters.** If the operation can fail, it should be a method.
- Indexers may throw exceptions for invalid arguments (this is the expected exception to the rule).

---

## 7. Async/Await

### Task-Based Patterns

- Use `async` and `await` for I/O-bound operations (network, file, database).
- Use `Task.Run` for CPU-bound work that should not block the calling thread.
- Return `Task` or `Task<T>`, never `void`, from async methods. The only exception: **event handlers must return `async void`**.

```csharp
// I/O-bound
public async Task<string> FetchDataAsync(string url)
{
    return await _httpClient.GetStringAsync(url);
}

// CPU-bound
public async Task<DamageResult> CalculateAsync()
{
    return await Task.Run(() => CalculateDamageDone());
}
```

### Naming

Append the `Async` suffix to all async method names: `GetDataAsync`, `SaveChangesAsync`. Event handlers and controller actions are exempt.

### ConfigureAwait

- In **library code**, use `ConfigureAwait(false)` on every `await` to avoid capturing the synchronization context. This prevents deadlocks when library code is called from UI threads.
- In **application code** (UI handlers, ASP.NET controllers), omit `ConfigureAwait` to stay on the original context.

```csharp
// Library code
public async Task<Data> LoadDataAsync()
{
    var json = await _httpClient.GetStringAsync(url).ConfigureAwait(false);
    return JsonSerializer.Deserialize<Data>(json);
}
```

### Cancellation Tokens

Accept a `CancellationToken` parameter in all async methods that may run for a significant time. Pass it through to all downstream async calls:

```csharp
public async Task<Report> GenerateReportAsync(CancellationToken cancellationToken = default)
{
    var data = await FetchDataAsync(cancellationToken).ConfigureAwait(false);
    cancellationToken.ThrowIfCancellationRequested();
    return ProcessData(data);
}
```

### Common Pitfalls

| Pitfall | Consequence | Fix |
|---|---|---|
| `async void` (non-event-handler) | Unobservable exceptions, untestable | Return `Task` |
| Blocking with `.Result` or `.Wait()` | Deadlocks in UI/ASP.NET contexts | Use `await` |
| Forgetting `await` on a `Task` | Fire-and-forget; exceptions swallowed | Always `await` or explicitly handle |
| `Task.Run` in library code | Unnecessary thread pool hops | Use `Task.Run` only in application code |
| Async lambdas in LINQ | Deferred execution causes unexpected timing | Force evaluation with `ToArray()`/`ToList()` |

### ValueTask

Consider `ValueTask<T>` for hot paths where the async method often completes synchronously (e.g., returning a cached result). `ValueTask<T>` avoids heap allocation in the synchronous path:

```csharp
public ValueTask<Data> GetCachedDataAsync()
{
    if (_cache.TryGetValue(key, out var data))
    {
        return new ValueTask<Data>(data); // No allocation
    }
    return new ValueTask<Data>(LoadFromDatabaseAsync());
}
```

**Restriction:** A `ValueTask<T>` can be awaited only once and cannot be consumed concurrently.

### Concurrent Tasks

Start independent tasks concurrently, then await them together:

```csharp
var usersTask = GetUsersAsync();
var ordersTask = GetOrdersAsync();
var settingsTask = GetSettingsAsync();

await Task.WhenAll(usersTask, ordersTask, settingsTask);

var users = await usersTask;
var orders = await ordersTask;
var settings = await settingsTask;
```

---

## 8. String Handling

### String Interpolation

Use string interpolation (`$""`) for concatenation:

```csharp
string displayName = $"{person.LastName}, {person.FirstName}";
```

Prefer expression-based interpolation over positional (`string.Format`):

```csharp
// Preferred
Console.WriteLine($"Score: {student.Score}");

// Avoid
Console.WriteLine("Score: {0}", student.Score);
```

### Raw String Literals

Use raw string literals (`"""`) for multi-line text or text containing special characters, to avoid escape sequences:

```csharp
var json = """
    {
        "name": "test",
        "value": 42
    }
    """;
```

### StringBuilder

Use `StringBuilder` when concatenating strings in a loop or building large strings:

```csharp
var builder = new StringBuilder();
for (var i = 0; i < 10_000; i++)
{
    builder.Append(phrases[i]);
}
```

### String Comparison

Always specify a `StringComparison` for culture-sensitive or case-insensitive comparisons. Never rely on the default:

```csharp
// Ordinal comparison: fastest, culture-independent
if (name.Equals("admin", StringComparison.OrdinalIgnoreCase)) { }

// Culture-sensitive: use for user-facing sorting/display
var sorted = names.OrderBy(n => n, StringComparer.CurrentCulture);
```

Use `string.Equals(a, b, comparison)` rather than `==` when you need non-default comparison semantics.

### Span-Based Parsing

For performance-critical string processing, use `ReadOnlySpan<char>` and `Span<char>` to avoid allocations:

```csharp
public State PerformOperation(ReadOnlySpan<char> command) => command switch
{
    "Start" => StartSystem(),
    "Stop" => StopSystem(),
    _ => throw new ArgumentException("Unknown command", nameof(command)),
};
```

---

## 9. Common Idioms

### Implicit Typing (var)

- Use `var` when the type is obvious from the right side of the assignment (constructor call, cast, literal).
- **Do not** use `var` when the type is unclear from the expression (method return values, complex chains).
- Use implicit typing for `for` loop variables.
- **Do not** use implicit typing for `foreach` loop variables (the collection name alone is insufficient to infer the element type clearly).
- Use `var` for LINQ query results (which may be anonymous types).

```csharp
// Type is obvious: use var
var message = "Hello";
var customers = new List<Customer>();
var item = (Customer)GetItem();

// Type is not obvious: spell it out
int count = GetActiveCount();
Customer current = customers.FirstOrDefault();
```

### Null-Conditional and Null-Coalescing Operators

```csharp
// Null-conditional: safe member access
int? length = message?.Length;
customer?.Orders?.FirstOrDefault()?.Cancel();

// Null-coalescing: default values
string name = input ?? "Unknown";

// Null-coalescing assignment
_cache ??= new Dictionary<string, Data>();
```

### Switch Expressions

Prefer switch expressions over switch statements when returning or assigning a value:

```csharp
string description = severity switch
{
    Severity.Low => "Informational",
    Severity.Medium => "Warning",
    Severity.High => "Error",
    Severity.Critical => "Fatal",
    _ => throw new ArgumentOutOfRangeException(nameof(severity)),
};
```

### Collection Expressions

Use collection expressions (C# 12+) to initialize collections:

```csharp
string[] vowels = ["a", "e", "i", "o", "u"];
List<int> numbers = [1, 2, 3, 4, 5];
```

### Target-Typed New

When the type is clear from the declaration, use target-typed `new()`:

```csharp
ExampleClass instance = new();
Dictionary<string, List<int>> map = new();
```

### Object Initializers

Prefer object initializers over sequential property assignment:

```csharp
var config = new AppConfig
{
    Name = "MyApp",
    MaxRetries = 3,
    Timeout = TimeSpan.FromSeconds(30),
};
```

### Delegates

Use `Func<>` and `Action<>` instead of custom delegate types unless the delegate needs XML documentation or a specific name for API clarity:

```csharp
Func<string, int> parse = s => int.Parse(s);
Action<string> log = message => Console.WriteLine(message);
```

### Boolean Logic

Use short-circuit operators `&&` and `||`, not `&` and `|`, for boolean expressions.

### Language Keywords for Types

Use the language keyword, not the framework type name:

```csharp
// Correct
string name;
int count;
object data;

// Avoid
String name;
Int32 count;
Object data;
```

Prefer `int` over unsigned types unless the API specifically requires unsigned semantics.

---

## 10. Things to Avoid

### Mutable Statics

Mutable static fields create hidden global state, making code harder to test, parallelize, and reason about. If you need shared state, use dependency injection or explicit configuration objects.

### Excessive Inheritance

Favor composition over inheritance. Deep inheritance hierarchies are brittle and hard to follow. Use interfaces and delegation instead:

```csharp
// Fragile: deep hierarchy
class Animal { }
class Mammal : Animal { }
class Dog : Mammal { }
class GuideDog : Dog { }

// Better: compose behaviors
class Dog
{
    private readonly IMovement _movement;
    private readonly IGuideBehavior? _guide;
}
```

### Stringly-Typed Code

Do not use strings where a stronger type exists. Use enums, strongly-typed IDs, or dedicated types instead of passing raw strings for status codes, configuration keys, or identifiers:

```csharp
// Avoid
void SetStatus(string status) { }
SetStatus("active");

// Prefer
void SetStatus(Status status) { }
SetStatus(Status.Active);
```

### Other Anti-Patterns

- **Catching `System.Exception` broadly.** Catch specific types.
- **Empty catch blocks.** They silently swallow errors. At minimum, log and rethrow.
- **`throw ex;` instead of `throw;`.** The former destroys the original stack trace.
- **Blocking on async code** (`.Result`, `.Wait()`, `.GetAwaiter().GetResult()` in contexts with a synchronization context). Use `await`.
- **`async void`** outside event handlers. Exceptions become unobservable.
- **Premature optimization** at the expense of readability. Profile first, then optimize.
- **Magic numbers.** Extract to named constants.
- **God classes.** Break large classes into cohesive, single-responsibility units.
- **Returning `null` from collections.** Return an empty collection instead.

---

## 11. Tooling

### .NET Analyzers

Enable the built-in .NET analyzers in your project file:

```xml
<PropertyGroup>
    <EnableNETAnalyzers>true</EnableNETAnalyzers>
    <AnalysisLevel>latest-recommended</AnalysisLevel>
    <EnforceCodeStyleInBuild>true</EnforceCodeStyleInBuild>
</PropertyGroup>
```

This enables CA-prefixed code analysis rules (security, performance, design, globalization, reliability) and IDE-prefixed style rules as build-time diagnostics.

### EditorConfig

Use an `.editorconfig` file to codify formatting and style rules. The compiler and IDE both respect it. Key settings:

```ini
[*.cs]
# Indentation
indent_style = space
indent_size = 4

# New-line preferences
csharp_new_line_before_open_brace = all
csharp_new_line_before_else = true
csharp_new_line_before_catch = true
csharp_new_line_before_finally = true

# Naming rules
dotnet_naming_rule.private_fields_should_be_camel_case.severity = warning
dotnet_naming_rule.private_fields_should_be_camel_case.symbols = private_fields
dotnet_naming_rule.private_fields_should_be_camel_case.style = camel_case_underscore

dotnet_naming_symbols.private_fields.applicable_kinds = field
dotnet_naming_symbols.private_fields.applicable_accessibilities = private, internal

dotnet_naming_style.camel_case_underscore.required_prefix = _
dotnet_naming_style.camel_case_underscore.capitalization = camel_case

# var preferences
csharp_style_var_for_built_in_types = false:suggestion
csharp_style_var_when_type_is_apparent = true:suggestion
csharp_style_var_elsewhere = false:suggestion

# Expression-bodied members
csharp_style_expression_bodied_methods = when_on_single_line:suggestion
csharp_style_expression_bodied_properties = true:suggestion

# Nullable
dotnet_diagnostic.CS8600.severity = warning
dotnet_diagnostic.CS8601.severity = warning
dotnet_diagnostic.CS8602.severity = warning
dotnet_diagnostic.CS8603.severity = warning
```

Reference: [dotnet/docs .editorconfig](https://github.com/dotnet/docs/blob/main/.editorconfig)

### StyleCop Analyzers

For additional style enforcement beyond the built-in analyzers, add the `StyleCop.Analyzers` NuGet package. It covers documentation requirements, ordering of members, spacing rules, and more. Configure via `stylecop.json` and suppress rules selectively when justified.

### Nullable Warnings

Treat nullable warnings as errors in CI to prevent regressions:

```xml
<PropertyGroup>
    <Nullable>enable</Nullable>
    <WarningsAsErrors>nullable</WarningsAsErrors>
</PropertyGroup>
```

### Code Analysis Categories

Key CA rule categories to pay attention to:

| Category | Prefix | Focus |
|---|---|---|
| Design | CA1xxx | API design, proper exception use, sealed/abstract |
| Globalization | CA13xx | Culture-aware string comparisons |
| Performance | CA18xx | Unnecessary allocations, span usage, async |
| Reliability | CA20xx | Proper disposal, race conditions |
| Security | CA21xx-CA53xx | Input validation, cryptography |
| Usage | CA22xx | Correct API usage patterns |
| Naming | CA17xx | Pascal/camel casing, parameter names |

---

## Quick Reference Checklist

For auditing a C# implementation, verify:

- [ ] Nullable reference types enabled (`<Nullable>enable</Nullable>`)
- [ ] Naming conventions followed (PascalCase for public, `_camelCase` for private fields)
- [ ] File-scoped namespaces used
- [ ] `using` directives outside namespace
- [ ] No `var` where type is ambiguous
- [ ] Exceptions are specific types, not `System.Exception`
- [ ] `throw;` not `throw ex;`
- [ ] `using` declarations for disposables
- [ ] Async methods return `Task`/`Task<T>`, not `void`
- [ ] Async method names end in `Async`
- [ ] `ConfigureAwait(false)` in library code
- [ ] No blocking on async (`.Result`, `.Wait()`)
- [ ] String interpolation over `string.Format`
- [ ] `StringComparison` specified for comparisons
- [ ] No mutable public fields (use properties)
- [ ] No empty catch blocks
- [ ] Constants are PascalCase, not SCREAMING_CASE
- [ ] Collection properties return empty, not null
- [ ] XML doc comments on all public APIs

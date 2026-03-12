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
| Private/internal fields (instance and static) | camelCase with `_` prefix | `_workerQueue` |
| Method parameters | camelCase | `someNumber`, `isValid` |
| Local variables | camelCase | `seattleCustomers`, `currentMax` |
| Generic type parameters | PascalCase with `T` prefix | `TSession`, `TInput`, `TOutput` |
| Record positional parameters | PascalCase (they become public properties) | `Person(string FirstName, string LastName)` |
| Primary constructor params (class/struct) | camelCase | `DataService(IWorkerQueue workerQueue)` |

**Note on `s_` and `t_` prefixes:** The .NET runtime codebase uses `s_` for private static fields and `t_` for thread-static fields. This is appropriate for large, low-level codebases where distinguishing field storage class at a glance matters. For typical application and library code, `_camelCase` for all private fields (instance and static) is the more common convention. Choose one style and be consistent within a project.

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

- Use **four spaces** for indentation.
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
- Begin with an uppercase letter.
- Insert one space between `//` and the text.
- Use XML doc comments (`///`) for all public members. XML doc comments should be grammatically complete sentences with proper punctuation, since they generate external documentation.
- **Comments should explain "why", not "what."** If a comment explains what code does, extract it into a named function or variable instead.

```csharp
// Postpone validation until both interrelated properties are set
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

### Primary Constructors (C# 12)

C# 12 extends primary constructors from records to classes and structs. Use them to reduce boilerplate for dependency injection and simple initialization:

```csharp
public class DataService(IWorkerQueue workerQueue, ILogger<DataService> logger)
{
    public void Process()
    {
        logger.LogInformation("Processing {Count} items", workerQueue.Count);
    }
}
```

Key considerations:

- **Primary constructor parameters are not fields.** They are captured in a compiler-generated closure. Do not assume they behave like fields for serialization or reflection.
- **Parameters are mutable** within the class body. If you need immutability, assign to a `readonly` field in the class body.
- **Prefer primary constructors** for classes whose constructor only assigns parameters to fields (the dependency injection pattern).
- **Use traditional constructors** when you need validation logic, multiple constructor overloads, or when the parameter-to-field mapping is not one-to-one.

```csharp
// When you need immutability guarantees, assign to readonly fields
public class CacheService(IDatabase database)
{
    private readonly IDatabase _database = database;
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

- **Seal classes unless you have explicitly designed them for inheritance.** Unsealed classes with virtual members create an implicit contract with subclasses that is difficult to maintain correctly. Sealing is the conservative default, and unsealing is a non-breaking change you can make later.
- Good reasons to unseal: the class is specifically designed as a base class with documented extension points, or you are building a framework where extensibility is a primary goal.
- **Seal overrides** of virtual members to prevent further fragile-base-class problems downstream.
- **Do not declare protected or virtual members on sealed types** -- they serve no purpose.
- Sealing also benefits performance: the JIT can devirtualize calls on sealed types, enabling more aggressive inlining.

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

### Using Declarations and Statements

Use `using` declarations (without braces) when the resource is needed for the remainder of the method:

```csharp
// Resource disposed at end of enclosing scope
using var stream = File.OpenRead(path);
var content = ReadAll(stream);
// stream disposed here, when the method returns
```

Use the braced `using` statement when you need to release the resource before the method ends:

```csharp
// Resource disposed at end of block, before additional work
string content;
using (var stream = File.OpenRead(path))
{
    content = ReadAll(stream);
}
// stream already disposed -- safe to do additional work without holding the handle
DoMoreWork(content);
```

The choice depends on resource lifetime, not stylistic preference. Pick the form that matches when you actually need the resource released.

### Implementing IDisposable

When your type owns unmanaged resources or owns other disposable objects, implement `IDisposable`:

```csharp
// Sealed class: simple pattern
public sealed class ResourceHolder : IDisposable
{
    private Stream? _stream;
    private bool _disposed;

    public void Dispose()
    {
        if (_disposed) return;
        _stream?.Dispose();
        _disposed = true;
    }
}

// Unsealed class: full dispose pattern for inheritance
public class ResourceHolder : IDisposable
{
    private bool _disposed;

    protected virtual void Dispose(bool disposing)
    {
        if (_disposed) return;
        if (disposing)
        {
            // Dispose managed resources
        }
        // Release unmanaged resources
        _disposed = true;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }
}
```

For types with async cleanup needs, implement `IAsyncDisposable` alongside `IDisposable`:

```csharp
public sealed class AsyncResourceHolder : IAsyncDisposable, IDisposable
{
    public async ValueTask DisposeAsync()
    {
        await _connection.CloseAsync();
        Dispose();
    }

    public void Dispose()
    {
        _connection.Close();
    }
}
```

### Property Getters and Exceptions

- **Avoid throwing exceptions from property getters.** If the operation can fail, it should be a method.
- Indexers may throw exceptions for invalid arguments (this is the expected exception to the rule).

---

## 7. Async/Await

### Task-Based Patterns

- Use `async` and `await` for I/O-bound operations (network, file, database).
- For CPU-bound work, expose it as a synchronous method and let the caller decide whether to offload with `Task.Run`. Do not wrap synchronous work in `Task.Run` just to provide an async-looking signature.
- Return `Task` or `Task<T>`, never `void`, from async methods. The only exception: **event handlers must return `async void`**.

```csharp
// I/O-bound: naturally async
public async Task<string> FetchDataAsync(string url)
{
    return await _httpClient.GetStringAsync(url);
}

// CPU-bound: expose as synchronous, let caller decide
public DamageResult CalculateDamage()
{
    return CalculateDamageDone();
}

// Caller offloads if needed
var result = await Task.Run(() => service.CalculateDamage());
```

### Naming

Append the `Async` suffix to all async method names: `GetDataAsync`, `SaveChangesAsync`. Event handlers and controller actions are exempt.

### ConfigureAwait

- In **library code that may be consumed from UI frameworks** (WPF, WinForms, MAUI) or .NET Framework ASP.NET, use `ConfigureAwait(false)` on every `await` to avoid capturing the synchronization context. This prevents deadlocks when library code is called from threads with a `SynchronizationContext`.
- In **modern .NET (Core/5+) server applications**, `ConfigureAwait(false)` is unnecessary because ASP.NET Core does not have a `SynchronizationContext`. It is harmless but adds noise.
- In **application code** (UI handlers, ASP.NET controllers), omit `ConfigureAwait` to stay on the original context.

```csharp
// Library code targeting broad audiences
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
| `Task.Run` wrapping sync work in a library | Hides CPU-bound nature from caller, unnecessary thread pool hops | Expose as sync method; let caller use `Task.Run` |
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

Explicitly specify `StringComparison` whenever you need case-insensitive or culture-aware comparison. The default ordinal comparison (`==`, `string.Equals(string)`) is appropriate for most cases:

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

- Use `var` when the type is obvious from the right side of the assignment (constructor call, cast, literal) or readily inferred from context (well-named method returning an obvious type).
- **Avoid** `var` when the type cannot be readily inferred from the variable name, method name, and surrounding context.
- Use implicit typing for `for` and `foreach` loop variables when the element type is clear from the collection name.

```csharp
// Type is obvious: use var
var message = "Hello";
var customers = new List<Customer>();
var item = (Customer)GetItem();
var connection = CreateConnection();
var logger = LoggerFactory.CreateLogger<MyClass>();

// Type is clear from collection name: use var
foreach (var customer in customers) { }

// Type is not obvious: spell it out
int count = GetActiveCount();
Dictionary<string, List<int>> lookup = BuildIndex();
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

Favor composition over inheritance. Deep inheritance hierarchies are brittle because subclasses depend on the implementation details of base class virtual methods. When those details change, subclasses break in subtle ways (the fragile-base-class problem). Prefer interfaces and delegation for polymorphism unless you have a genuine is-a relationship with stable, well-documented extension points.

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

### Collection Return Types

Return the most specific read-only collection type that serves the caller:

- **`IReadOnlyList<T>`** when callers need count and indexing (the most common case).
- **`IReadOnlyCollection<T>`** when callers need count but not indexing.
- **`IEnumerable<T>`** when callers only need to iterate and the data may be lazily produced.
- Avoid returning `List<T>` or `IList<T>` from public APIs unless the caller genuinely needs to mutate the collection.
- **Never return `null` from a collection-returning method.** Return an empty collection instead.

```csharp
// Preferred: caller gets count and index access, but cannot mutate
public IReadOnlyList<Customer> GetActiveCustomers() { ... }

// Appropriate for lazy/streaming data
public IEnumerable<LogEntry> ReadLogEntries() { ... }
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

### Always applicable

- [ ] Nullable reference types enabled (`<Nullable>enable</Nullable>`)
- [ ] Naming conventions followed (PascalCase for public, `_camelCase` for private fields)
- [ ] File-scoped namespaces used
- [ ] `using` directives outside namespace
- [ ] No `var` where type is ambiguous
- [ ] Exceptions are specific types, not `System.Exception`
- [ ] `throw;` not `throw ex;`
- [ ] `using` declarations/statements for disposables with appropriate scoping
- [ ] Async methods return `Task`/`Task<T>`, not `void`
- [ ] Async method names end in `Async`
- [ ] No blocking on async (`.Result`, `.Wait()`)
- [ ] String interpolation over `string.Format`
- [ ] `StringComparison` specified for case-insensitive or culture-aware comparisons
- [ ] No mutable public fields (use properties)
- [ ] No empty catch blocks
- [ ] Constants are PascalCase, not SCREAMING_CASE
- [ ] Collection properties return empty, not null; prefer `IReadOnlyList<T>` for return types
- [ ] XML doc comments on all public APIs
- [ ] `IDisposable` implemented correctly when owning disposable or unmanaged resources

### Context-dependent

- [ ] `ConfigureAwait(false)` in library code (needed when consumers may have a `SynchronizationContext` -- WPF, WinForms, MAUI, .NET Framework ASP.NET; unnecessary in .NET Core/5+ server-only libraries)
- [ ] Sealed classes (default to sealed unless explicitly designing for inheritance; relevant for public API surface)

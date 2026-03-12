# Zig Style Guide

A practical reference for idiomatic Zig, tailored to the sayable-age project. Covers naming, formatting, type system, error handling, memory patterns, testing, and tooling. When in doubt, follow the [official Zig style guide](https://ziglang.org/documentation/master/#Style-Guide).

## Sources

- [Zig Language Reference](https://ziglang.org/documentation/master/)
- [Zig Language Reference: Style Guide](https://ziglang.org/documentation/master/#Style-Guide)
- [Zig Standard Library Documentation](https://ziglang.org/documentation/master/std/)
- [zig.guide (community learning resource)](https://zig.guide/)
- [Zig GitHub Repository](https://github.com/ziglang/zig)

---

## 1. Naming Conventions

### Functions and Methods

Use `camelCase`. This includes public and private functions, as well as methods on structs.

```zig
fn formatAge(locale: *const Locale, dob: []const u8) ?[]const u8 { ... }
fn parseDate(s: []const u8) ?Date { ... }
fn writeStr(self: *Writer, s: []const u8) void { ... }
```

### Types

Use `PascalCase` for all type names: structs, enums, unions, error sets, and opaque types.

```zig
const PluralCategory = enum { zero, one, two, few, many, other };
const Locale = struct { code: []const u8, ... };
const UnitForms = union(enum) { simple: []const u8, forms: Forms };
const FileOpenError = error{ AccessDenied, OutOfMemory, FileNotFound };
```

### Constants

The Zig style guide draws a distinction based on how a constant gets its value:

- **`camelCase`** for `const` declarations that hold the result of a `comptime` expression or `@import`
- **`snake_case`** for `const` declarations that hold a simple literal value

```zig
// camelCase -- result of @import (comptime)
const std = @import("std");
const sayableAge = @import("sayableage.zig");

// snake_case -- simple literal values
const max_age_months = 6000;
const version = "0.5.0";
```

Zig does not use `SCREAMING_SNAKE_CASE`. The `const` keyword already communicates immutability.

### Variables and Parameters

Use `snake_case` for mutable variables and function parameters.

```zig
var diff_days: i32 = 0;
var clamped_birthday = if (dob_date.d < last_day) dob_date.d else last_day;
fn julianDay(year: i32, month: i32, day: i32) i32 { ... }
```

### Struct Fields

Use `snake_case` for struct fields.

```zig
const Locale = struct {
    code: []const u8,
    plural: *const fn (n: i32) PluralCategory,
    just_born: []const u8,
    short_override: ?CompactnessOverride = null,
};
```

### Enum Variants

Use `snake_case` for enum variants.

```zig
const Compactness = enum {
    normal,
    short_mode,
    compact,
};

const PluralCategory = enum(u3) {
    zero = 0,
    one = 1,
    two = 2,
    few = 3,
    many = 4,
    other = 5,
};
```

### Files

Use `snake_case` for file names, matching the convention for module names.

```
sayableage.zig
test_format_age.zig
build.zig
locales.zig
```

File names should reflect what they export: a file defining the formatter and types is `sayableage.zig`; a file containing tests is `test_format_age.zig`.

### Comptime Parameters

Use the `comptime` keyword before the parameter. The parameter itself follows standard naming: `PascalCase` for types, `snake_case` for values.

```zig
fn makeArray(comptime size: usize) [size]u8 { ... }
fn List(comptime T: type) type { ... }
```

### Test Block Names

Use descriptive string literals that read as sentences.

```zig
test "formatAge returns null for empty date of birth" { ... }
test "formatAge with 0 days returns just_born" { ... }
test "plural rule selects correct category for Arabic" { ... }
```

### Things to Avoid in Names

**No underscore prefixes.** The Zig style guide says: "Refrain from underscore prefixes." Do not use `_private` or `__internal` patterns.

```zig
// Good
fn parseDigits(s: []const u8) ?i32 { ... }
const max_buffer = 256;

// Bad
fn _parseDigits(s: []const u8) ?i32 { ... }
const _max_buffer = 256;
```

The one exception is `_` as a discard name for unused variables or captures:

```zig
for (items) |_| { count += 1; }
_ = someFunction();
```

**Avoid redundancy in names.** Do not repeat the container name in its members.

```zig
// Good
const Locale = struct {
    code: []const u8,
    units: UnitSet,
};

// Bad -- redundant "locale" prefix
const Locale = struct {
    locale_code: []const u8,
    locale_units: UnitSet,
};
```

**Avoid redundancy in fully-qualified namespaces.** The container name already provides context.

```zig
// Good
const locale = locales.en;
const cat = PluralCategory.one;

// Bad -- redundant qualification
const locale = locales.locale_en;
const cat = PluralCategory.plural_one;
```

---

## 2. Visibility

### pub

Only mark declarations `pub` when they are part of the module's public API. Internal helpers, types, and constants should remain private (no `pub`).

```zig
// Public API -- consumers need these
pub const Locale = struct { ... };
pub const PluralCategory = enum(u3) { ... };
pub fn formatAge(buf: []u8, locale: *const Locale, ...) ?[]const u8 { ... }

// Internal -- not pub
const Writer = struct { ... };
const Date = struct { y: i32, m: i32, d: i32 };
fn parseDate(s: []const u8) ?Date { ... }
fn julianDay(year: i32, month: i32, day: i32) i32 { ... }
```

In `build.zig`, only expose modules that consumers need. Test files can `@import` the module under test and access its `pub` declarations.

### Nested pub

Declarations inside a `pub` struct that form part of the API should also be `pub`:

```zig
pub const UnitForms = union(enum) {
    simple: []const u8,
    forms: Forms,

    // Part of the public API for this type
    pub const Forms = struct { ... };
    pub fn resolve(self: UnitForms, cat: PluralCategory) ?[]const u8 { ... }
};
```

---

## 3. Code Formatting

### zig fmt

**Always format code with `zig fmt`.** This is the canonical formatter. Its output is the official style. Do not fight it.

```bash
zig fmt src/sayableage.zig
zig fmt src/                    # Format all .zig files in directory
zig fmt --check src/            # Check without modifying (for CI)
```

If `zig fmt` produces hard-to-read output, restructure the code rather than adding manual formatting.

### Indentation

Use 4 spaces. No tabs. `zig fmt` enforces this.

### Line Length

There is no hard line length limit in Zig's style guide. `zig fmt` will not wrap long lines. Aim for readable line lengths (roughly 100-120 characters). Long lines in generated locale data files are expected and acceptable.

### Alignment

Do not manually align assignments or fields into columns. `zig fmt` does not preserve column alignment, and it adds maintenance burden.

```zig
// Good
const a = 1;
const long_name = 2;
const x = 3;

// Avoid -- will be destroyed by zig fmt
const a         = 1;
const long_name = 2;
const x         = 3;
```

### Braces

Opening braces go on the same line. Closing braces go on their own line. `zig fmt` enforces this.

### Trailing Commas

Use trailing commas in multi-line struct literals, function calls, and enum definitions. Trailing commas cause `zig fmt` to keep each item on its own line.

```zig
// With trailing comma -- zig fmt keeps multi-line
const date = Date{
    .y = 2024,
    .m = 3,
    .d = 15,
};

// Without trailing comma -- zig fmt may collapse to one line
const date = Date{ .y = 2024, .m = 3, .d = 15 };
```

### Comments

Use `//` for regular comments. Use `///` for doc comments (attached to the following declaration). Use `//!` for top-level module doc comments.

```zig
//! sayable-age Zig implementation -- types and formatter.

/// Formats a human-readable age string from date of birth and reference date.
///
/// Returns null if either date is invalid or dob is after as_of.
pub fn formatAge(...) ?[]const u8 {
    // Tier 1: 0 days
    if (diff_days == 0) { ... }
}
```

---

## 4. Type System

### Structs

Structs are Zig's primary composite type. Fields can have default values.

```zig
const Locale = struct {
    code: []const u8,
    plural: *const fn (n: i32) PluralCategory,
    units: UnitSet,
    half: []const u8,
    delimiter: []const u8,
    just_born: []const u8,
    stages: Stages,
    short_override: ?CompactnessOverride = null,
    compact_override: ?CompactnessOverride = null,
};
```

Structs can contain methods and declarations:

```zig
const Writer = struct {
    buf: []u8,
    pos: usize,
    overflow: bool,

    fn init(buf: []u8) Writer {
        return .{ .buf = buf, .pos = 0, .overflow = false };
    }

    fn writeStr(self: *Writer, s: []const u8) void {
        if (self.overflow) return;
        if (self.pos + s.len > self.buf.len) {
            self.overflow = true;
            return;
        }
        @memcpy(self.buf[self.pos..][0..s.len], s);
        self.pos += s.len;
    }

    fn slice(self: *const Writer) []const u8 {
        return self.buf[0..self.pos];
    }
};
```

Use `self: *StructName` for mutating methods, `self: *const StructName` or `self: StructName` for non-mutating methods. Use the struct name directly rather than a `const Self = @This();` alias -- the explicit name is clearer, especially in code with nested structs. Reserve `@This()` for generic structs returned from comptime functions, where the struct has no other name.

### Anonymous Struct Literals

Use `.{ ... }` when the type can be inferred from context:

```zig
return .{ .y = y, .m = m, .d = d };
return .{ .buf = buf, .pos = 0, .overflow = false };
```

### Enums

Enums define a set of named values. They can have an explicit integer tag type.

```zig
const PluralCategory = enum(u3) {
    zero = 0,
    one = 1,
    two = 2,
    few = 3,
    many = 4,
    other = 5,
};
```

Enums can contain methods:

```zig
const Color = enum {
    red,
    green,
    blue,

    fn isWarm(self: Color) bool {
        return self == .red;
    }
};
```

Use `@intFromEnum` and `@enumFromInt` for conversions:

```zig
const val: u3 = @intFromEnum(PluralCategory.few);  // 3
const cat: PluralCategory = @enumFromInt(2);         // .two
```

Non-exhaustive enums allow for forward compatibility:

```zig
const Status = enum(u8) {
    ok = 0,
    err = 1,
    _,  // Non-exhaustive -- allows other values
};
```

### Tagged Unions

Tagged unions combine a tag (enum) with associated data. They are type-safe discriminated unions.

```zig
const UnitForms = union(enum) {
    simple: []const u8,
    forms: Forms,

    pub fn resolve(self: UnitForms, cat: PluralCategory) ?[]const u8 {
        return switch (self) {
            .simple => |s| s,
            .forms => |f| {
                const arr = [6]?[]const u8{ f.zero, f.one, f.two, f.few, f.many, f.other };
                return arr[@intFromEnum(cat)] orelse f.other;
            },
        };
    }
};
```

Switch on tagged unions must be exhaustive (cover all variants) or include an `else` branch.

### Optional Types

Optional types use `?T` syntax. An optional can hold a value of type `T` or `null`.

```zig
var result: ?[]const u8 = null;
result = "hello";
```

Unwrap with `orelse` to provide a default or early return:

```zig
const value = optional_value orelse "default";
const date = parseDate(input) orelse return null;
```

Unwrap with `.?` (equivalent to `orelse unreachable`) -- panics if null in safe build modes:

```zig
const value = optional_value.?;
```

Unwrap with `if` for conditional handling:

```zig
if (optional_value) |value| {
    process(value);
} else {
    // optional_value is null
}
```

### Error Unions

Error unions combine an error set with a value type using `!`:

```zig
const FileError = error{ NotFound, PermissionDenied };
fn readFile(path: []const u8) FileError![]const u8 { ... }
```

Use `!T` (inferred error set) when the compiler can determine all possible errors:

```zig
fn compute(x: i32) !i32 {
    if (x < 0) return error.InvalidInput;
    return x * 2;
}
```

### Error Sets

Error sets are like enums of errors. They can be merged with `||`:

```zig
const ReadError = error{ NotFound, PermissionDenied };
const WriteError = error{ DiskFull, ReadOnly };
const IOError = ReadError || WriteError;
```

The global error set `anyerror` contains all possible errors. Prefer concrete error sets -- they document failure modes and enable exhaustive handling.

### Comptime Types

`comptime_int` and `comptime_float` are arbitrary-precision types that exist only at compile time. They coerce to concrete types when assigned to a runtime variable or passed to a runtime parameter:

```zig
const x = 42;         // comptime_int, coerces to any integer type
const z: u8 = x;      // Coerced to u8
```

### type

The `type` type represents Zig types themselves. It can only exist at comptime:

```zig
fn List(comptime T: type) type {
    return struct {
        items: []T,
        len: usize,
    };
}
```

---

## 5. Error Handling

### try

The `try` keyword unwraps an error union. If the value is an error, it immediately returns the error from the current function:

```zig
fn doWork() !void {
    const result = try riskyOperation();
    process(result);
}
```

`try x` is shorthand for `x catch |err| return err`.

### catch

The `catch` keyword provides a fallback when an error union contains an error:

```zig
// Provide a meaningful default
const config = loadConfig() catch default_config;

// Handle the error explicitly
const value = riskyOperation() catch |err| {
    std.log.err("Operation failed: {}", .{err});
    return err;
};
```

Use `catch` with a default value when the fallback genuinely makes sense for the domain. Use `catch` with error propagation or logging when failures need visibility.

### errdefer

`errdefer` schedules cleanup that runs only when the function returns an error. This is essential for cleanup in functions that can partially succeed:

```zig
fn createResource() !Resource {
    const handle = try allocate();
    errdefer deallocate(handle);  // Only runs if we return an error below

    try configure(handle);
    return Resource{ .handle = handle };
}
```

### Error Return Traces

In Debug and ReleaseSafe modes, Zig captures error return traces that show the path an error took through the call stack. These are printed automatically on unhandled errors and in test failures.

### Idiomatic Error Handling Patterns

**Propagate errors with `try` when the caller should handle them:**

```zig
fn parseAndFormat(input: []const u8) ![]const u8 {
    const parsed = try parse(input);
    return try format(parsed);
}
```

**Use error sets to document what can go wrong:**

```zig
const ParseError = error{
    InvalidFormat,
    OutOfRange,
    EmptyInput,
};

fn parse(s: []const u8) ParseError!Date { ... }
```

**Prefer concrete error sets over `anyerror`.** Concrete error sets document the function's failure modes and enable the compiler to verify exhaustive handling.

---

## 6. Memory Management

### No Hidden Allocations

Zig's standard library never allocates memory behind your back. Every allocation is explicit and requires an allocator parameter. This is a fundamental design principle.

```zig
var list = std.ArrayList(u8).init(allocator);
defer list.deinit();
```

### Allocator Interface

All allocators implement `std.mem.Allocator`, providing:

- `alloc(comptime T: type, n: usize)` -- allocate a slice of `n` items
- `free(slice)` -- deallocate a previously allocated slice
- `create(comptime T: type)` -- allocate a single item
- `destroy(ptr)` -- deallocate a single item

### Common Allocator Types

| Allocator | Use Case |
|-----------|----------|
| `std.testing.allocator` | Tests -- detects leaks automatically |
| `std.heap.GeneralPurposeAllocator` | General-purpose, detects double-free and use-after-free |
| `std.heap.ArenaAllocator` | Batch allocation with single bulk deallocation |
| `std.heap.FixedBufferAllocator` | Stack-based, no heap, for embedded or performance-critical code |
| `std.heap.page_allocator` | OS page allocation, simple but wasteful for small allocations |

### Arena Allocators

Arena allocators are ideal when many allocations share the same lifetime. All memory is freed at once:

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();
const allocator = arena.allocator();

const buf1 = try allocator.alloc(u8, 1024);
const buf2 = try allocator.alloc(u8, 2048);
// No individual free() calls needed -- arena.deinit() frees everything
```

### defer and errdefer for Cleanup

Use `defer` to guarantee cleanup regardless of how a scope exits:

```zig
const file = try std.fs.cwd().openFile("data.txt", .{});
defer file.close();
```

Multiple `defer` statements execute in reverse order (LIFO):

```zig
defer std.debug.print("1\n", .{});
defer std.debug.print("2\n", .{});
defer std.debug.print("3\n", .{});
// Prints: 3, 2, 1
```

### Stack-Based Buffers

For small, bounded allocations, prefer stack buffers over heap allocation. This avoids allocator overhead entirely and is the standard pattern in formatting and parsing code:

```zig
var buf: [256]u8 = undefined;
var writer = Writer.init(&buf);
writer.writeStr("hello");
const result = writer.slice();
```

This is the approach used throughout sayable-age: the caller provides a stack buffer, and `formatAge` writes into it, returning a slice of the written portion.

---

## 7. Slices and Arrays

### Arrays

Arrays have a compile-time known length. The type is `[N]T`:

```zig
const arr = [_]u8{ 1, 2, 3, 4 };       // [4]u8, length inferred
const zeros: [10]u8 = .{0} ** 10;        // [10]u8, all zeros
var buf: [256]u8 = undefined;            // Uninitialized buffer
```

### Slices

Slices are runtime-length views into contiguous memory. The type is `[]T` or `[]const T`:

```zig
const arr = [_]u8{ 1, 2, 3, 4, 5 };
const slice: []const u8 = arr[1..4];  // Elements at indices 1, 2, 3
```

Slices have `.len` (runtime) and `.ptr` (pointer to first element).

### Sentinel-Terminated Slices

Sentinel-terminated slices guarantee a specific value at the end. The most common form is null-terminated strings:

```zig
const str: [:0]const u8 = "hello";  // Null-terminated string slice
```

### String Literals

String literals are `*const [N:0]u8` -- pointers to null-terminated byte arrays. They coerce to both `[]const u8` (slice) and `[*:0]const u8` (sentinel-terminated pointer):

```zig
const hello = "hello";                    // *const [5:0]u8
const as_slice: []const u8 = hello;       // Coerce to slice
```

Do not assume a `[]const u8` is null-terminated. Only `[:0]const u8` or `[*:0]const u8` carry that guarantee.

### Array Concatenation and Repetition

Compile-time arrays support `++` (concatenation) and `**` (repetition):

```zig
const a = [_]u8{ 1, 2 };
const b = [_]u8{ 3, 4 };
const c = a ++ b;          // [_]u8{ 1, 2, 3, 4 }
const d = a ** 3;          // [_]u8{ 1, 2, 1, 2, 1, 2 }
```

### Bounds Checking

Slices and arrays perform bounds checking in Debug and ReleaseSafe modes. Out-of-bounds access triggers a panic with a clear error message. In ReleaseFast and ReleaseSmall modes, bounds checking is removed for performance.

### Slice Patterns

**Iterate with index:**

```zig
for (data, 0..) |byte, i| {
    // byte is the element, i is the index
}
```

**Mutate through pointer capture:**

```zig
for (&mutable_array) |*item| {
    item.* += 1;
}
```

**Sub-slicing:**

```zig
const first_four = data[0..4];
const rest = data[4..];
const last_three = data[data.len - 3..];

// Bounded sub-slice (compile-time length)
const exact: *const [4]u8 = data[0..4];
```

**Multi-object for loops (iterate over multiple sequences in lockstep):**

```zig
for (keys, values) |key, value| {
    map.put(key, value);
}
```

---

## 8. Comptime

### Compile-Time Evaluation

The `comptime` keyword forces evaluation at compile time. Zig can execute most code at compile time, including loops, function calls, and arithmetic.

```zig
comptime var x: i32 = 0;
comptime {
    x = computeValue();
}
```

### Comptime Parameters

Functions accept comptime parameters for generic programming. This is Zig's approach to generics -- no separate generic syntax, just comptime parameters:

```zig
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

const result = max(i32, 10, 20);  // T is resolved at compile time
```

### Generic Data Structures via Comptime

Create generic types by returning types from functions:

```zig
fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();  // @This() needed here -- the struct has no other name
        items: []T,
        count: usize,

        pub fn push(self: *Self, value: T) void { ... }
        pub fn pop(self: *Self) ?T { ... }
    };
}

var stack: Stack(i32) = undefined;
```

### @import

`@import` loads a Zig source file or package at compile time, returning its public declarations as a struct:

```zig
const std = @import("std");
const locales = @import("locales/locales.zig");
```

Each `@import` of the same path returns the same cached value.

### @embedFile

Embeds a file's contents as a comptime byte array:

```zig
const data = @embedFile("locales/en.json");
```

### Comptime Blocks for Initialization

Use labeled comptime blocks to compute complex initial values:

```zig
const lookup_table = comptime init: {
    var table: [256]u8 = undefined;
    for (&table, 0..) |*entry, i| {
        entry.* = computeEntry(i);
    }
    break :init table;
};
```

### @typeInfo

Inspect types at compile time for metaprogramming:

```zig
fn fieldNames(comptime T: type) []const []const u8 {
    const info = @typeInfo(T);
    switch (info) {
        .@"struct" => |s| {
            comptime var names: [s.fields.len][]const u8 = undefined;
            inline for (s.fields, 0..) |field, i| {
                names[i] = field.name;
            }
            return &names;
        },
        else => @compileError("Expected struct type"),
    }
}
```

### inline

The `inline` keyword forces function inlining or loop unrolling at compile time:

```zig
inline fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

Use `inline` sparingly -- the compiler usually makes better inlining decisions. It is appropriate when comptime semantics require it (e.g., `inline for` over struct fields, or when returning comptime-known types).

### @compileError and @compileLog

Use `@compileError` to produce a custom compile error for invalid comptime states:

```zig
fn validate(comptime n: usize) void {
    if (n == 0) @compileError("n must be non-zero");
}
```

Use `@compileLog` for compile-time debugging. Remove all `@compileLog` calls before committing -- they cause compilation to fail.

---

## 9. Integer Division and Modulo

The codebase relies heavily on integer division and modulo for date arithmetic. Zig provides four builtins, and choosing the wrong one produces incorrect results:

| Builtin | Behavior | Example with (-7, 3) |
|---------|----------|----------------------|
| `@divTrunc(a, b)` | Truncates toward zero | -2 |
| `@divFloor(a, b)` | Rounds toward negative infinity | -3 |
| `@mod(a, b)` | Euclidean modulo (always non-negative for positive divisor) | 2 |
| `@rem(a, b)` | Remainder (sign matches dividend) | -1 |

The date arithmetic in sayable-age uses `@divTrunc` and `@mod` because:
- `@divTrunc` matches the truncating division behavior expected by the Julian day and month-difference calculations
- `@mod` ensures non-negative remainders when computing leftover days or months

Do not substitute `@rem` for `@mod` or `@divFloor` for `@divTrunc` without verifying the mathematical semantics. The difference matters when negative intermediate values are possible.

---

## 10. Testing

### Test Blocks

Tests are declared with the `test` keyword. They have an implicit return type of `anyerror!void`:

```zig
const std = @import("std");

test "addition works" {
    try std.testing.expectEqual(@as(i32, 4), 2 + 2);
}
```

**Note on `expectEqual` and `@as`:** `expectEqual` uses the type of the `expected` argument to determine the comparison type. If `expected` is a `comptime_int` literal (e.g., `4`) and `actual` is an `i32`, you may need `@as(i32, 4)` to coerce the expected value. In newer Zig versions (0.13+), peer type resolution handles more cases automatically.

### std.testing Functions

| Function | Purpose |
|----------|---------|
| `expect(condition)` | Assert a boolean condition is true |
| `expectEqual(expected, actual)` | Assert two values are equal, with clear error messages |
| `expectEqualStrings(expected, actual)` | Compare byte slices with diff output on failure |
| `expectEqualSlices(T, expected, actual)` | Compare slices element-by-element |
| `expectError(expected, error_union)` | Assert a specific error is returned |
| `expectFmt(expected, fmt, args)` | Assert formatted output matches |

### Testing Patterns

**Use `expectEqualStrings` for string comparisons:**

```zig
test "formatAge returns correct output" {
    var buf: [256]u8 = undefined;
    const result = sayableage.formatAge(&buf, &locale_en, .normal, "2024-01-01", "2024-01-15");
    try std.testing.expectEqualStrings("2 weeks", result.?);
}
```

**Use `expect` for boolean conditions:**

```zig
test "parseDate rejects invalid input" {
    try std.testing.expect(parseDate("not-a-date") == null);
}
```

**Use `expectError` to verify error conditions:**

```zig
test "division by zero returns error" {
    try std.testing.expectError(error.DivisionByZero, divide(10, 0));
}
```

### Test Allocator

`std.testing.allocator` detects memory leaks automatically. Tests that leak memory will fail:

```zig
test "no memory leaks" {
    const allocator = std.testing.allocator;
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();  // Without this, the test fails with a leak report
    try list.append('a');
}
```

### Running Tests

```bash
zig build test                                          # Run tests via build system
zig test src/test_format_age.zig                        # Run tests directly
zig test src/test_format_age.zig --test-filter "age"    # Filter tests by name
zig test -O ReleaseSafe src/test_format_age.zig         # Test in ReleaseSafe mode
```

### Test Organization

Tests can live in the same file as the code they test or in separate test files. For large test suites (like sayable-age's 217 canonical tests), use separate test files that `@import` the module under test:

```zig
// test_format_age.zig
const sayableage = @import("sayableage.zig");

test "format age for newborn" {
    var buf: [256]u8 = undefined;
    const result = sayableage.formatAge(&buf, ...);
    try std.testing.expectEqualStrings("Newborn", result.?);
}
```

### Skipping Tests

Return `error.SkipZigTest` to skip a test programmatically:

```zig
test "platform-specific test" {
    const builtin = @import("builtin");
    if (builtin.os.tag != .linux) return error.SkipZigTest;
    // Linux-only test code
}
```

---

## 11. Common Idioms

### Optional Unwrapping with orelse

The most common pattern for optional handling is `orelse` for early returns:

```zig
const date = parseDate(input) orelse return null;
```

### Optional Unwrapping with if

Use `if` with payload capture when you need the unwrapped value in a larger block:

```zig
if (parseDate(input)) |date| {
    process(date);
} else {
    return error.InvalidDate;
}
```

### Payload Captures in switch

Switch on tagged unions with payload captures:

```zig
return switch (self) {
    .simple => |s| s,
    .forms => |f| f.other,
};
```

### Compactness Override Pattern

Resolve optional overrides with `if`:

```zig
if (ovr) |o| {
    if (o.day) |d| day_uf = d;
    if (o.week) |w| week_uf = w;
}
```

### for with Index

Iterate over a collection with its index:

```zig
for (items, 0..) |item, i| {
    buffer[i] = transform(item);
}
```

### inline for

Use `inline for` when the loop body must be unrolled at compile time (e.g., iterating over struct fields):

```zig
inline for (std.meta.fields(T)) |field| {
    @field(result, field.name) = @field(source, field.name);
}
```

### Labeled Blocks

Use labeled blocks for complex expressions that need early exit:

```zig
const value = blk: {
    if (condition) break :blk default_value;
    break :blk computed_value;
};
```

### unreachable

Use `unreachable` to mark code paths that should never execute. In safe build modes, hitting `unreachable` is a panic. In unsafe modes, it is undefined behavior:

```zig
fn getPluralCategory(n: u3) PluralCategory {
    return switch (n) {
        0 => .zero,
        1 => .one,
        2 => .two,
        3 => .few,
        4 => .many,
        5 => .other,
        else => unreachable,
    };
}
```

### @as for Type Coercion

Use `@as` for explicit type coercion when the compiler cannot infer the target type:

```zig
const x = @as(u32, 42);
```

Prefer letting the compiler infer types when possible. Use `@as` only when needed to resolve ambiguity.

### Discarding Values

Use `_ =` to explicitly discard a return value. Zig requires this -- ignoring return values silently is a compile error:

```zig
_ = someFunction();
```

---

## 12. Things to Avoid

### Using undefined Without Subsequent Initialization

`undefined` marks memory as intentionally uninitialized. Reading it before writing is illegal behavior:

```zig
// OK -- only accessing the initialized portion
var buf: [256]u8 = undefined;
const n = try reader.read(&buf);
process(buf[0..n]);

// Bad -- reading undefined memory
var x: i32 = undefined;
const y = x + 1;  // Illegal behavior
```

In Debug mode, `undefined` memory is filled with `0xAA` bytes as a debugging aid. Do not rely on this value.

### Static Mutable State via Nested Structs

Avoid using nested struct variables to create static mutable buffers. This pattern creates hidden global state that is not thread-safe and returns slices that become invalid on the next call:

```zig
// Avoid -- hidden global mutable state, not reentrant
fn itoa(n: i32) []const u8 {
    const S = struct {
        var buf: [12]u8 = undefined;
    };
    var w = Writer.init(&S.buf);
    w.writeInt(n);
    return w.slice();
}

// Prefer -- caller provides the buffer
fn itoa(buf: *[12]u8, n: i32) []const u8 {
    var w = Writer.init(buf);
    w.writeInt(n);
    return w.slice();
}
```

If this pattern is used deliberately in a known single-threaded context for convenience, document that constraint with a comment.

### Global Mutable State

Avoid `var` at container (file/struct) scope. Container-level variables are shared across all references to the file and interact poorly with comptime:

```zig
// Avoid -- mutable global state
var counter: u32 = 0;

// Prefer -- pass state explicitly
fn increment(counter: *u32) void {
    counter.* += 1;
}
```

The exception is thread-local variables (`threadlocal var`) and variables in test-only code.

### Unnecessary @intCast Chains

Avoid long chains of casts. Restructure the types to avoid the need:

```zig
// Bad
const result: u8 = @intCast(@as(u32, @intCast(@mod(val, 10))) + '0');

// Better -- use intermediate variables with clear types
const digit: u32 = @intCast(@mod(val, 10));
const char: u8 = @intCast(digit + '0');
```

### Using anyerror When a Concrete Error Set Will Do

```zig
// Avoid -- loses information about what can go wrong
fn parse(s: []const u8) anyerror!Date { ... }

// Prefer -- documents failure modes
fn parse(s: []const u8) ParseError!Date { ... }
```

---

## 13. Tooling

### zig fmt

The canonical code formatter. Run it on every file before committing.

```bash
zig fmt src/sayableage.zig         # Format a single file
zig fmt src/                        # Format all .zig files in a directory
zig fmt --check src/                # Check formatting without modifying (CI)
```

`zig fmt --check` returns a non-zero exit code if any file needs formatting, making it suitable for CI gates.

### zig build

The build system driver. It reads `build.zig` and executes the build graph:

```bash
zig build                           # Default build
zig build test                      # Run tests via build system
zig build -Doptimize=ReleaseSafe    # Build with specific optimization
```

### build.zig

The build script replaces Makefiles. It is written in Zig and runs at compile time:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sayableage_mod = b.addModule("sayableage", .{
        .root_source_file = b.path("src/sayableage.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/test_format_age.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "sayableage", .module = sayableage_mod },
        },
    });

    const tests = b.addTest(.{
        .root_module = test_mod,
    });

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_tests.step);
}
```

### Build Modes

| Mode | Safety Checks | Optimizations | Compile Speed | Use Case |
|------|:---:|:---:|:---:|-----------|
| `Debug` | Yes | None | Fast | Development, debugging |
| `ReleaseSafe` | Yes | Speed | Slow | Production with safety |
| `ReleaseFast` | No | Speed | Slow | Maximum performance |
| `ReleaseSmall` | No | Size | Slow | Embedded, WASM |

Debug and ReleaseSafe both perform bounds checking, detect integer overflow, fill `undefined` memory with `0xAA`, and capture error return traces. The key difference beyond optimization is compile time: ReleaseSafe runs the full LLVM optimization pipeline and compiles 10-50x slower than Debug. Use Debug for the development edit-compile-test cycle. Use ReleaseSafe for CI and production builds.

### Cross-Compilation

Zig is a cross-compiler out of the box. No separate toolchain installation is needed:

```bash
zig build -Dtarget=x86_64-linux-gnu
zig build -Dtarget=aarch64-macos
zig build -Dtarget=wasm32-freestanding
```

### Caching

Zig caches compilation artifacts in `.zig-cache/` (local) and `~/.cache/zig/` (global). The cache is content-addressed and generally does not need manual management. Add `.zig-cache/` to `.gitignore`.

---

## Quick Reference

| Category | Convention |
|----------|-----------|
| Types (struct, enum, union, error set) | `PascalCase` |
| Functions and methods | `camelCase` |
| Variables and parameters | `snake_case` |
| Constants (comptime / @import result) | `camelCase` |
| Constants (simple literals) | `snake_case` |
| Struct fields | `snake_case` |
| Enum variants | `snake_case` |
| File names | `snake_case` |
| Comptime type parameters | `PascalCase` (e.g., `T: type`) |
| Comptime value parameters | `snake_case` (e.g., `size: usize`) |
| Test names | Descriptive string literals |
| Formatter | `zig fmt` (always) |
| Build system | `build.zig` |
| Recommended build mode | `Debug` for dev, `ReleaseSafe` for prod |

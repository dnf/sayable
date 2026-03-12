# C++ Style Guide

A comprehensive, opinionated style guide for writing modern C++. Intended as an auditing reference for C++ implementations -- covering naming, formatting, idioms, type safety, error handling, templates, testing, and tooling.

**Target standard:** C++17 minimum, C++20 preferred, C++23 features adopted as compiler support matures.

## Source material

This guide draws from these authoritative references:

- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines) (Stroustrup & Sutter)
- [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- [CppReference](https://en.cppreference.com/)
- [ISO C++ FAQ](https://isocpp.org/wiki/faq)
- [Effective Modern C++](https://www.oreilly.com/library/view/effective-modern-c/9781491908419/) (Scott Meyers)

Rule numbers like `[C.21]` or `[F.16]` refer to the C++ Core Guidelines.

---

## Table of contents

1. [Naming conventions](#1-naming-conventions)
2. [Code formatting](#2-code-formatting)
3. [Modern C++ idioms](#3-modern-c-idioms)
4. [Type system](#4-type-system)
5. [Header design](#5-header-design)
6. [Class design](#6-class-design)
7. [Error handling](#7-error-handling)
8. [Templates](#8-templates)
9. [Standard library usage](#9-standard-library-usage)
10. [Things to avoid](#10-things-to-avoid)
11. [Testing](#11-testing)
12. [Tooling](#12-tooling)

---

## 1. Naming conventions

### Summary table

| Entity              | Convention       | Example                          |
|---------------------|------------------|----------------------------------|
| Classes / structs   | `PascalCase`     | `AgeLocale`, `UnitForms`         |
| Functions           | `snake_case`     | `format_age`, `parse_date`       |
| Variables (local)   | `snake_case`     | `diff_days`, `total_months`      |
| Private members     | `snake_case_`    | `locale_`, `delimiter_`          |
| Constants           | `PascalCase`     | `MaxBufferSize`, `DefaultPort`   |
| Constexpr values    | `PascalCase`     | `MaxAgeMonths`, `Version`        |
| Namespaces          | `lowercase`      | `sayableage`, `locales`          |
| Template parameters | `PascalCase`     | `T`, `Container`, `Predicate`    |
| Enum types          | `PascalCase`     | `PluralCategory`, `Compactness`  |
| Enum values         | `PascalCase`     | `PluralCategory::Other`          |
| Macros              | `ALL_CAPS`       | `SAYABLEAGE_TYPES_HPP`           |
| File names          | `snake_case`     | `format_age.cpp`, `types.hpp`    |

### Rationale

- **Functions use `snake_case`**, aligning with the standard library (`std::make_unique`, `std::to_string`) and the C++ Core Guidelines.
- **Private members use a trailing underscore** to distinguish them from local variables without Hungarian notation.
- **Constants use `PascalCase`** without a prefix, consistent with enum values and type names. The compiler enforces constness via `const`/`constexpr` -- a naming prefix adds no safety. `ALL_CAPS` is reserved for macros.
- **Enum values use `PascalCase`** (scoped enums) rather than `ALL_CAPS`, which is reserved for macros. Scoped enums (`enum class`) already prevent name collisions.
- **Macros are the only `ALL_CAPS` names.** If you find yourself writing `ALL_CAPS`, ask whether a `constexpr` variable, `inline` function, or template would work instead.

### Names should convey intent

```cpp
// Bad: what is n? what is d?
int n = (ref_y - dob_y) * 12 + (ref_m - dob_m);
int d = julian_day(ref_y, ref_m, ref_d) - julian_day(dob_y, dob_m, dob_d);

// Good: the name tells you what the value represents
int months = (ref_y - dob_y) * 12 + (ref_m - dob_m);
int diff_days = julian_day(ref_y, ref_m, ref_d) - julian_day(dob_y, dob_m, dob_d);
```

Single-letter names are acceptable only for:
- Loop counters (`i`, `j`, `k`)
- Template parameters (`T`, `U`)
- Short lambdas where the type makes the meaning obvious

---

## 2. Code formatting

All formatting rules in this section should be enforced via `.clang-format` rather than relying on manual review. See the [clang-format](#clang-format) subsection under Tooling.

### Indentation and braces

- **4 spaces** per indentation level. No tabs. This is a project convention -- enforce it via `.clang-format` with `IndentWidth: 4`.
- **Opening brace** on the same line as the control structure or declaration.
- **Closing brace** on its own line, aligned with the opening statement.

```cpp
namespace sayableage {

class SayableAge {
public:
    explicit SayableAge(const AgeLocale& locale);

    std::optional<std::string> format_age(const std::string& date_of_birth,
                                          const std::string& as_of = "") const;

private:
    const AgeLocale* locale_;
};

} // namespace sayableage
```

### Line length

- **100 characters** soft limit, **120 characters** hard limit.
- Break long function signatures after the opening parenthesis, aligning parameters.
- Break long expressions at operators, placing the operator at the start of the continuation line.

```cpp
// Break after opening paren, align parameters
std::optional<std::string> SayableAge::format_age(
    const std::string& date_of_birth,
    const std::string& as_of) const {

// Break at operators
const int diff_days = julian_day(ref_y, ref_m, ref_d)
                    - julian_day(dob_y, dob_m, dob_d);
```

### Spacing

- **One space** after control keywords: `if (`, `for (`, `while (`, `switch (`.
- **No space** between function name and parenthesis: `format_age(`.
- **One space** around binary operators: `a + b`, `x == y`, `months < 24`.
- **No space** inside parentheses: `(x + y)` not `( x + y )`.
- **One space** after commas: `f(a, b, c)`.

### Blank lines

- One blank line between function definitions.
- One blank line between logical sections within a function.
- No multiple consecutive blank lines.
- No blank line after an opening brace or before a closing brace.

### Namespace closing comments

Always annotate closing braces of namespaces:

```cpp
namespace sayableage {
// ...
} // namespace sayableage
```

---

## 3. Modern C++ idioms

### RAII (Resource Acquisition Is Initialization)

RAII is the foundational resource management idiom in C++. Every resource (memory, files, locks, sockets) must be owned by an object whose destructor releases it. [P.8]

```cpp
// Bad: manual resource management
void process_file(const std::string& path) {
    FILE* f = fopen(path.c_str(), "r");
    // ... if an exception or early return happens, f leaks
    fclose(f);
}

// Good: RAII via std::ifstream
void process_file(const std::string& path) {
    std::ifstream file(path);
    // file is automatically closed when it goes out of scope
}
```

Standard RAII types to prefer:

| Resource       | RAII Type                     |
|----------------|-------------------------------|
| Heap memory    | `std::unique_ptr`, `std::shared_ptr` |
| Mutex lock     | `std::lock_guard`, `std::unique_lock` |
| File handle    | `std::ifstream`, `std::ofstream` |
| Thread         | `std::jthread` (C++20)        |
| Dynamic array  | `std::vector`                 |

### Move semantics

Move semantics transfer ownership of resources without copying. They enable efficient return-by-value and container operations.

```cpp
// Return by value -- the compiler applies RVO or move
std::string build_greeting(const std::string& name) {
    std::string result = "Hello, " + name + "!";
    return result;  // Do NOT write std::move(result) -- it inhibits RVO [F.48]
}

// Accept by value and move into place when the caller can give up ownership
class Widget {
public:
    explicit Widget(std::string name) : name_(std::move(name)) {}
private:
    std::string name_;
};

// Use X&& for "will-move-from" parameters [F.18]
void add_item(std::vector<std::string>& items, std::string&& item) {
    items.push_back(std::move(item));
}
```

Key rules:
- **Do not `std::move` a return value** from a local variable. The compiler applies Named Return Value Optimization (NRVO). [F.48]
- **Mark move constructors and move assignment `noexcept`** to enable optimizations in standard containers. [C.66]
- **Accept sink parameters by value** and `std::move` them into members when the function always takes ownership.

### Smart pointers

Use smart pointers for any dynamically allocated object. Raw `new`/`delete` should never appear in application code. [I.11]

```cpp
// Exclusive ownership
auto widget = std::make_unique<Widget>("example");

// Shared ownership (use sparingly -- shared ownership is often a design smell)
auto config = std::make_shared<Config>(load_config());

// Transfer ownership through function boundaries
void register_handler(std::unique_ptr<Handler> handler);
```

Decision tree:
1. **Can you use a stack object or value type?** Do that. No pointer needed.
2. **Need heap allocation with a single owner?** `std::unique_ptr`.
3. **Need genuinely shared ownership?** `std::shared_ptr`. Document why.
4. **Non-owning reference?** Raw pointer `T*` or reference `T&`.

### `auto` type deduction

Use `auto` when the type is obvious from context or when it avoids repetition. Do not use `auto` when the type is not immediately clear from the initializer.

```cpp
// Good: type is obvious from the right side
auto it = container.find(key);
auto result = std::make_unique<Widget>();
auto count = static_cast<int>(vec.size());

// Good: range-based for with auto
for (const auto& [city, population] : city_map) {
    // ...
}

// Bad: what type is this? Spell it out.
auto val = compute_result();  // unclear -- write the type explicitly

// Good: explicit type when the initializer is ambiguous
double ratio = compute_result();
```

### Range-based for loops

Prefer range-based `for` over index-based loops. Use `const auto&` for read-only access, `auto&` for mutation. [P.3]

```cpp
// Read-only iteration
for (const auto& item : items) {
    process(item);
}

// Mutation
for (auto& item : items) {
    item.normalize();
}

// With structured bindings (C++17)
for (const auto& [key, value] : map) {
    std::cout << key << ": " << value << '\n';
}
```

### Structured bindings (C++17)

Use structured bindings to decompose aggregates, pairs, and tuples into named variables.

```cpp
// Decomposing a struct
struct Point { double x; double y; };
auto [x, y] = compute_point();

// Decomposing a pair from map insertion
auto [iter, inserted] = my_map.insert({key, value});

// Decomposing in a range-based for
for (const auto& [name, score] : scores) {
    if (score > threshold) { /* ... */ }
}
```

Use `const auto&` to avoid copies, plain `auto` for small trivially-copyable types, and `auto&&` for forwarding.

---

## 4. Type system

### Const correctness

Apply `const` early and consistently. Retrofitting const correctness into an existing codebase causes a cascading "snowball effect" (ISO C++ FAQ).

```cpp
// Const reference parameters for inputs [F.16]
std::string format(const AgeLocale& locale, int months);

// Const member functions for observers
class SayableAge {
public:
    std::optional<std::string> format_age(const std::string& dob,
                                          const std::string& as_of) const;
};

// Const local variables for values that don't change
const int diff_days = julian_day(ref_y, ref_m, ref_d)
                    - julian_day(dob_y, dob_m, dob_d);
const auto it = uf.forms.find(cat);
```

Rules:
- **Mark member functions `const`** unless they modify the object's logical state.
- **Pass by `const&`** for inputs that are not cheap to copy. Pass cheap-to-copy types (int, double, pointer, string_view) by value.
- **Prefer `const` local variables.** If a variable's value is assigned once, make it `const`.
- **Use `mutable`** for internal caches that don't affect observable state (logical constness).

### References vs. pointers

Use references when null is not a valid state. Use pointers when null is meaningful. [F.60]

```cpp
// Reference: null is not valid, cannot be reseated
void format(const AgeLocale& locale);

// Pointer: null is valid (optional parameter)
void format(const AgeLocale* locale);  // nullptr means "use default"

// Non-owning pointer to stored reference (cannot use reference as member
// if you need assignment/rebinding)
class SayableAge {
    const AgeLocale* locale_;  // non-owning, never null after construction
};
```

### Strong types and `std::optional`

Prefer `std::optional` over sentinel values, magic numbers, or out-parameters for values that may not exist.

```cpp
// Bad: using empty string as sentinel
std::string format_age(const std::string& dob);  // returns "" on error

// Good: optional clearly communicates "may not have a value"
std::optional<std::string> format_age(const std::string& dob);

// Accessing optional values
if (auto result = format_age(dob)) {
    use(*result);
}

// With value_or for defaults
std::string display = format_age(dob).value_or("unknown");
```

### `std::variant` for type-safe unions

Use `std::variant` (C++17) instead of raw unions or type-switching on integers. [P.4]

```cpp
// Bad: raw union with manual type tag
struct Value {
    enum Type { Int, String } type;
    union { int i; std::string s; };
};

// Good: std::variant is type-safe
using Value = std::variant<int, std::string>;

// Visit with overloaded lambdas (requires a user-defined helper)
// Define this utility once in your project:
template<class... Ts> struct overloaded : Ts... { using Ts::operator()...; };
template<class... Ts> overloaded(Ts...) -> overloaded<Ts...>;

std::visit(overloaded{
    [](int i)               { process_int(i); },
    [](const std::string& s){ process_string(s); },
}, value);
```

Note: The `overloaded` helper shown above is not part of the standard library. It is a widely-used pattern that must be defined in your codebase. The deduction guide (second line) is required in C++17; in C++20 and later, CTAD handles it automatically.

### `std::string_view` for non-owning string references

Use `std::string_view` (C++17) for function parameters that read but do not store or modify a string. It works with `std::string`, string literals, and substrings without copying.

```cpp
// Accepts std::string, "literals", string_view, and substrings
bool starts_with(std::string_view text, std::string_view prefix);

// Caution: do not store a string_view beyond the lifetime of its source
class Bad {
    std::string_view name_;  // Dangling if the source string is destroyed
};
```

### String constants

For compile-time string constants in C++17 and later, prefer `inline constexpr std::string_view` over `constexpr const char*`. It carries the string length, works with the `std::string_view` ecosystem, and `inline` ensures a single definition across translation units (avoiding ODR issues in headers).

```cpp
// Acceptable but limited: no length, no string_view integration
constexpr const char* Version = "0.5.0";

// Preferred: carries length, works with string_view APIs, ODR-safe in headers
inline constexpr std::string_view Version = "0.5.0";
```

---

## 5. Header design

### Include guards and `#pragma once`

Use `#pragma once` for internal and application headers. It has zero maintenance burden and no risk of name collisions from copy-paste errors. Every major compiler (GCC, Clang, MSVC, ICC) has supported it for over a decade.

For public library headers that must compile on exotic or embedded toolchains, use traditional include guards instead:

```cpp
#ifndef SAYABLEAGE_TYPES_HPP
#define SAYABLEAGE_TYPES_HPP

// ... declarations ...

#endif // SAYABLEAGE_TYPES_HPP
```

Guard naming convention: `PROJECT_PATH_FILE_HPP`. Use uppercase with underscores. The primary risk of traditional guards is duplicate macro names across files -- always derive the name from the full path.

### Forward declarations

Use forward declarations when only a pointer, reference, or function signature is needed. Include the full header when you need the complete type definition (for `sizeof`, member access, inheritance, or value semantics). [SF.10]

```cpp
// Forward declaration is sufficient: only a pointer is needed
class AgeLocale;
void format(const AgeLocale& locale);

// Full include is required: need the complete definition
#include "types.hpp"
AgeLocale locale = load_locale("en");  // value type, needs complete definition
```

Never forward-declare types from the `std` namespace (undefined behavior).

### Include order

Group includes in this order, separated by blank lines:

1. **Corresponding header** (the `.hpp` for this `.cpp`)
2. **Project headers** (quoted `"..."`)
3. **Third-party library headers** (angle brackets `<...>`)
4. **C++ standard library headers** (angle brackets `<...>`)
5. **C compatibility headers** (angle brackets `<...>`)

Within each group, sort alphabetically.

```cpp
#include "sayableage/sayableage.hpp"

#include "sayableage/locales/locales.hpp"

#include <algorithm>
#include <chrono>
#include <optional>
#include <string>

#include <ctime>
```

Rationale: Placing the corresponding header first ensures it is self-contained -- if it is missing an include, the `.cpp` file will fail to compile.

### Self-contained headers

Every header must compile independently. Include everything the header needs. Do not rely on transitive includes.

### Header file extensions

- Headers: `.hpp` (C++ headers), `.h` (C-compatible headers)
- Implementation: `.cpp`
- Tests: `_test.cpp` or `test_*.cpp`

---

## 6. Class design

### Rule of zero

If a class does not manage resources directly, do not declare any special member functions. The compiler-generated defaults will do the right thing. [C.20]

```cpp
// Good: rule of zero -- all members have value semantics
struct UnitSet {
    UnitForms day;
    UnitForms week;
    UnitForms month;
    UnitForms year;
};
```

### Rule of five

If you must define any of the five special member functions (destructor, copy constructor, copy assignment, move constructor, move assignment), define or explicitly default/delete all five. [C.21]

```cpp
class ResourceOwner {
public:
    ResourceOwner();
    ~ResourceOwner();

    ResourceOwner(const ResourceOwner& other);
    ResourceOwner& operator=(const ResourceOwner& other);

    ResourceOwner(ResourceOwner&& other) noexcept;
    ResourceOwner& operator=(ResourceOwner&& other) noexcept;
};
```

If the class should be move-only:

```cpp
class UniqueHandle {
public:
    UniqueHandle();
    ~UniqueHandle();

    UniqueHandle(const UniqueHandle&) = delete;
    UniqueHandle& operator=(const UniqueHandle&) = delete;

    UniqueHandle(UniqueHandle&&) noexcept;
    UniqueHandle& operator=(UniqueHandle&&) noexcept;
};
```

### Inheritance vs. composition

Prefer composition over inheritance. Use inheritance only for genuine "is-a" relationships with polymorphic behavior. [C.120]

```cpp
// Bad: inheritance for code reuse
class SayableAge : public DateParser { ... };

// Good: composition
class SayableAge {
    DateParser parser_;  // has-a, not is-a
};
```

When using inheritance:
- **Mark overriding functions `override`**, never redundantly `virtual`. [C.128]
- **Mark leaf classes or methods `final`** when no further derivation is intended. [C.139]
- **Base classes intended for polymorphic use must have virtual destructors.** [C.127]
- **Prefer abstract interfaces** (pure virtual classes with no data members) over deep hierarchies. [I.25]

### Access control

- Data members should be `private` (or `protected` if truly needed by subclasses).
- Use `struct` for passive data aggregates with all-public members and no invariants.
- Use `class` for anything that maintains invariants, has private state, or provides behavior.
- Declare in order: `public`, `protected`, `private`.

```cpp
// struct: passive data, no invariants
struct AgeComponents {
    int months;
    int diff_days;
};

// class: has invariants, private state, meaningful behavior
class SayableAge {
public:
    explicit SayableAge(const AgeLocale& locale,
                        Compactness compactness = Compactness::Normal);
    std::optional<std::string> format_age(...) const;

private:
    const AgeLocale* locale_;
    UnitForms day_;
};
```

### Explicit constructors

Mark single-argument constructors `explicit` to prevent accidental implicit conversions. [C.46]

```cpp
class SayableAge {
public:
    explicit SayableAge(const AgeLocale& locale,
                        Compactness compactness = Compactness::Normal);
};
```

Exception: copy constructors and constructors taking `std::initializer_list` should not be `explicit`.

### Declaration order within a class

Within each access level, declare in this order:

1. Type aliases and nested types
2. Static constants
3. Factory functions
4. Constructors and assignment operators
5. Destructor
6. Other member functions
7. Data members

---

## 7. Error handling

### Error handling strategy by standard version

The right error handling mechanism depends on which C++ standard you target:

| Standard | For expected absence | For recoverable errors with info | For programming errors |
|----------|---------------------|----------------------------------|----------------------|
| C++17    | `std::optional`     | Exceptions, or `std::variant<T, Error>` | Exceptions or assertions |
| C++20    | `std::optional`     | Exceptions, or `std::variant<T, Error>` | Exceptions or assertions |
| C++23    | `std::optional`     | `std::expected<T, E>`            | Exceptions or assertions |

### Exceptions

Exceptions are the standard C++ error-reporting mechanism for truly exceptional conditions that a function cannot handle locally. [E.1]

```cpp
// Throw on precondition violation
void set_month(int month) {
    if (month < 1 || month > 12) {
        throw std::invalid_argument("month must be 1-12");
    }
    month_ = month;
}

// Catch at an appropriate boundary
try {
    process_all_records(records);
} catch (const std::exception& e) {
    log_error(e.what());
    return EXIT_FAILURE;
}
```

Rules:
- **Throw by value, catch by `const` reference.** [E.15]
- **Use standard exception types** (`std::runtime_error`, `std::invalid_argument`, `std::out_of_range`) or derive from them.
- **Do not use exceptions for control flow.** They are for errors, not expected outcomes.
- **Do not throw from destructors.** Destructors must be implicitly `noexcept`. [C.36]

### `std::optional` for expected absence

When a function may legitimately have no result (not an error), return `std::optional`:

```cpp
// "No result" is not an error -- it's a valid outcome
std::optional<std::string> format_age(const std::string& date_of_birth,
                                      const std::string& as_of) const;
```

### `std::expected` (C++23)

When targeting C++23 and later, prefer `std::expected` for functions where failure is common and carries information. It makes the error path explicit in the type system.

For C++17/C++20 codebases, use `std::variant<T, Error>` or a simple result struct to achieve a similar pattern. Alternatively, consider the [`tl::expected`](https://github.com/TartanLlama/expected) polyfill library which provides the same API on C++14 and later.

```cpp
enum class ParseError { EmptyInput, InvalidFormat, FutureDate };

// C++23: std::expected
std::expected<AgeComponents, ParseError> parse_age(
    std::string_view date_of_birth,
    std::string_view as_of);

// Caller handles both paths explicitly
auto result = parse_age(dob, as_of);
if (result) {
    use(result->months);
} else {
    handle_error(result.error());
}

// Monadic chaining (C++23)
auto formatted = parse_age(dob, as_of)
    .and_then(compute_tier)
    .transform(render_string);

// C++17 alternative: variant-based result type
using ParseResult = std::variant<AgeComponents, ParseError>;
ParseResult parse_age(std::string_view dob, std::string_view as_of);
```

### `noexcept`

Mark functions `noexcept` when they cannot throw and you want to communicate that guarantee. [F.6]

Critical uses:
- **Move constructors and move assignment operators** -- containers like `std::vector` will fall back to copying if move is not `noexcept`. [C.66]
- **Destructors** -- implicitly `noexcept`; never throw from them.
- **Swap functions.**
- **Leaf functions** with no failure modes (simple getters, arithmetic).

```cpp
class Widget {
public:
    Widget(Widget&& other) noexcept;
    Widget& operator=(Widget&& other) noexcept;

    int count() const noexcept { return count_; }
};
```

Do not mark a function `noexcept` if it calls functions that might throw and you are not prepared to have `std::terminate` called.

---

## 8. Templates

### Concepts (C++20)

Use concepts to constrain template parameters with clear, readable requirements. They replace SFINAE and `enable_if` with declarative constraints. [T.10]

```cpp
// Define a concept
template<typename T>
concept Formattable = requires(T t) {
    { t.format() } -> std::convertible_to<std::string>;
};

// Use as a constraint (terse syntax)
void print(const Formattable auto& item) {
    std::cout << item.format() << '\n';
}

// Use with requires clause
template<typename T>
    requires std::integral<T>
T safe_divide(T a, T b) {
    if (b == 0) throw std::domain_error("division by zero");
    return a / b;
}

// Constrain multiple parameters
template<typename Container, typename Pred>
    requires std::ranges::range<Container>
          && std::predicate<Pred, std::ranges::range_value_t<Container>>
auto filter(const Container& c, Pred pred);
```

Standard library concepts to know:
- `std::integral`, `std::floating_point`, `std::signed_integral`
- `std::same_as<T, U>`, `std::convertible_to<From, To>`
- `std::invocable<F, Args...>`, `std::predicate<F, Args...>`
- `std::ranges::range`, `std::ranges::input_range`
- `std::copyable`, `std::movable`, `std::regular`

### Avoid SFINAE in new code

SFINAE (`enable_if`, `void_t` tricks) is hard to read and error messages are terrible. In C++20 and later, use concepts instead. In C++17, prefer `if constexpr` for compile-time branching.

```cpp
// Bad: SFINAE (C++11/14 style)
template<typename T, typename = std::enable_if_t<std::is_integral_v<T>>>
T double_value(T x) { return x * 2; }

// Good: concept (C++20)
template<std::integral T>
T double_value(T x) { return x * 2; }

// Good: if constexpr (C++17)
template<typename T>
auto process(T value) {
    if constexpr (std::is_integral_v<T>) {
        return value * 2;
    } else {
        return value;
    }
}
```

### `constexpr` and `consteval`

Use `constexpr` for functions and variables that can be evaluated at compile time. [F.4]

```cpp
// constexpr variable
constexpr int MaxAgeMonths = 6000;

// constexpr function: usable at both compile time and runtime
constexpr int days_in_month(int year, int month) {
    if (month == 2) {
        return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    }
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
}

// consteval (C++20): must be evaluated at compile time
consteval int compile_time_hash(const char* str) {
    int hash = 0;
    while (*str) hash = hash * 31 + *str++;
    return hash;
}
```

Use `constexpr` liberally. It costs nothing at runtime and enables the compiler to optimize aggressively.

---

## 9. Standard library usage

### Prefer algorithms over raw loops

Standard algorithms are well-tested, optimized, and communicate intent better than hand-written loops. [P.13]

```cpp
// Bad: manual search loop
int found = -1;
for (int i = 0; i < vec.size(); ++i) {
    if (vec[i] == target) { found = i; break; }
}

// Good: std::find
auto it = std::find(vec.begin(), vec.end(), target);

// Good: std::any_of
bool has_negative = std::any_of(values.begin(), values.end(),
                                [](int v) { return v < 0; });

// Good: std::transform
std::transform(input.begin(), input.end(), std::back_inserter(output),
               [](const auto& item) { return item.name(); });
```

Key algorithms to reach for:

| Need                    | Algorithm                              |
|-------------------------|----------------------------------------|
| Search                  | `find`, `find_if`, `binary_search`     |
| Test condition          | `any_of`, `all_of`, `none_of`          |
| Transform               | `transform`, `for_each`                |
| Sort                    | `sort`, `stable_sort`, `partial_sort`  |
| Remove                  | `remove_if` + `erase` (erase-remove)   |
| Accumulate              | `accumulate`, `reduce`                 |
| Count                   | `count`, `count_if`                    |
| Min/Max                 | `min_element`, `max_element`, `minmax` |

### Ranges (C++20)

Prefer ranges and views for composable, lazy operations on sequences:

```cpp
namespace views = std::views;
namespace ranges = std::ranges;

// Composable pipeline
auto active_names = people
    | views::filter([](const Person& p) { return p.is_active(); })
    | views::transform([](const Person& p) { return p.name(); });

// ranges:: algorithms work directly on containers
ranges::sort(items, {}, &Item::priority);
```

### Container selection

| Need                                 | Container                 |
|--------------------------------------|---------------------------|
| Sequential, dynamic size             | `std::vector`             |
| FIFO queue                           | `std::deque`, `std::queue`|
| Associative (ordered)                | `std::map`, `std::set`    |
| Associative (fast lookup)            | `std::unordered_map`, `std::unordered_set` |
| Fixed size, stack-allocated          | `std::array`              |
| Sorted, cache-friendly (C++23)       | `std::flat_map`, `std::flat_set` |
| String                               | `std::string`             |

**Default to `std::vector`** unless you have a specific reason to choose something else. It has the best cache locality and is almost always the fastest container for small-to-medium sizes.

### `std::string_view` and `std::span`

Use `std::string_view` (C++17) for read-only string parameters. Use `std::span` (C++20) for read-only array/buffer parameters. Both avoid copies and work with multiple source types. [I.13, F.24]

```cpp
// string_view: works with std::string, const char*, string_view
bool is_valid_date(std::string_view s);

// span: works with std::vector, std::array, C arrays
double mean(std::span<const double> values);
int sum(std::span<const int> data);
```

### `std::format` (C++20)

Prefer `std::format` over `iostream` formatting and `sprintf`. It is type-safe, extensible, and avoids the performance pitfalls of `iostream` manipulators.

```cpp
// Bad: iostream formatting is verbose and stateful
std::cout << std::setw(4) << std::setfill('0') << month << "-"
          << std::setw(2) << std::setfill('0') << day << '\n';

// Good: std::format is concise and stateless
std::cout << std::format("{:04}-{:02}\n", month, day);

// Building strings without streams
std::string msg = std::format("{} is {} days old", name, days);
```

Note: `std::format` requires C++20 and a sufficiently recent standard library (libstdc++ 13+, libc++ 17+, MSVC 19.29+). For C++17 codebases, consider the [{fmt}](https://github.com/fmtlib/fmt) library which `std::format` was based on.

---

## 10. Things to avoid

### Raw `new` and `delete`

Never use `new` and `delete` in application code. Use value types, `std::unique_ptr`, or `std::shared_ptr`. [R.11]

```cpp
// Bad
Widget* w = new Widget();
// ... who deletes this?
delete w;

// Good
auto w = std::make_unique<Widget>();
// automatically deleted when w goes out of scope
```

### C-style casts

C-style casts `(int)x` bypass the type system silently. Use named casts that express intent and are searchable. [ES.49]

```cpp
// Bad
double d = (double)count;
Widget* w = (Widget*)raw_ptr;

// Good
auto d = static_cast<double>(count);
auto w = static_cast<Widget*>(raw_ptr);
auto c = const_cast<char*>(str);       // explicitly removes const (rare, document why)
auto b = dynamic_cast<Derived*>(base);  // runtime-checked downcast
auto r = reinterpret_cast<uintptr_t>(ptr);  // bit reinterpretation (very rare)

// Best: brace initialization for safe numeric conversions
auto d = double{count};  // compile error if narrowing
```

### Macros where alternatives exist

Macros ignore scope, namespaces, and type safety. Prefer:

| Instead of macro...    | Use...                                    |
|------------------------|-------------------------------------------|
| `#define PI 3.14159`   | `constexpr double Pi = 3.14159;`          |
| `#define MAX(a,b) ...` | `std::max(a, b)` or a template function   |
| `#define SQUARE(x) ...`| `constexpr` or `inline` function          |
| `#define DEBUG_LOG ...` | `if constexpr` or logging library         |
| `#define FOR_EACH ...`  | Range-based `for` or `std::for_each`      |

Acceptable macro uses:
- Include guards (`#ifndef HEADER_HPP`)
- Platform-specific conditional compilation (`#ifdef _WIN32`)
- Stringification / token pasting (when genuinely needed)

### `using namespace` in headers

Never place `using namespace` in a header file. It pollutes every file that includes the header.

```cpp
// Bad: in a header
using namespace std;  // now every includer has std:: names in scope

// Acceptable: in a .cpp file, in a limited scope
void render() {
    using namespace std::literals;
    auto duration = 5s;
}
```

### Non-const global variables

Global mutable state creates hidden dependencies, thread-safety issues, and testing difficulties. [I.2]

```cpp
// Bad
int g_count = 0;  // anyone can modify, hard to track

// Better: encapsulate in a function if you need lazy initialization
const Config& global_config() {
    static const Config config = load_config();
    return config;
}
```

### `goto`

Almost never justified. Use structured control flow, RAII, and early returns instead.

### `std::endl`

`std::endl` flushes the stream buffer, which is almost never desired and hurts performance. Use `'\n'`.

```cpp
// Bad: flushes after every line
std::cout << "hello" << std::endl;

// Good: just a newline character
std::cout << "hello" << '\n';
```

### Implicit conversions

Mark single-argument constructors and conversion operators `explicit` unless you intentionally want implicit conversion. [C.46]

```cpp
// Bad: allows accidental implicit conversion from int
class Distance {
public:
    Distance(int meters);  // Distance d = 42; compiles silently
};

// Good: requires explicit construction
class Distance {
public:
    explicit Distance(int meters);  // Distance d = 42; is a compile error
};
```

### Ignoring return values

Use `[[nodiscard]]` on functions whose return value should not be silently discarded. This catches a common class of bugs at compile time.

```cpp
// Bad: caller can silently ignore the result
std::optional<std::string> format_age(std::string_view dob);

// Good: compiler warns if result is discarded
[[nodiscard]] std::optional<std::string> format_age(std::string_view dob);

// Apply to an entire class when all return values matter
class [[nodiscard]] ParseResult { ... };
```

Mark functions `[[nodiscard]]` when they:
- Return `std::optional`, error codes, or status values
- Create newly allocated objects
- Perform pure computations with no side effects
- Return iterators or handles that must be used

---

## 11. Testing

### Framework

Use a lightweight, header-only test framework such as [Catch2](https://github.com/catchorg/Catch2), [doctest](https://github.com/doctest/doctest), or [GoogleTest](https://github.com/google/googletest). Hand-rolled test macros are acceptable for projects with a zero-dependency constraint, but document the test infrastructure clearly.

### File organization

- Test files live alongside or mirror the source tree: `tests/test_format_age.cpp` or `src/format_age_test.cpp`.
- Each test file should be self-contained and compilable as a standalone executable.
- Use the naming convention `test_<module>.cpp` or `<module>_test.cpp` -- pick one and be consistent.

### Test naming

Name tests descriptively. Each test name should read as a sentence describing the expected behavior:

```cpp
// Good: describes the behavior
void test_born_today_returns_newborn() { ... }
void test_future_date_returns_nullopt() { ... }
void test_exactly_500_years_is_accepted() { ... }

// Bad: vague or redundant
void test1() { ... }
void test_format_age() { ... }  // what about format_age?
```

### Test ID annotations

When tests derive from a canonical test specification (e.g., `tests.json`), annotate each test with its canonical ID:

```cpp
ASSERT_EQ("born today", format_age("2025-06-15", "2025-06-15"), "Newborn"); // 2.1
```

### What to test

- All public API functions
- Edge cases: empty input, boundary values, maximum values, off-by-one scenarios
- Error paths: invalid input, missing data, future dates
- Locale-specific behavior when applicable

---

## 12. Tooling

### Compiler warnings

Enable aggressive warnings and treat them as errors. A clean build with zero warnings is a baseline requirement.

Recommended flags (GCC/Clang):

```cmake
target_compile_options(mylib PRIVATE
    -Wall               # Standard warnings
    -Wextra             # Extra warnings beyond -Wall
    -Wpedantic          # Strict ISO C++ compliance
    -Werror             # Treat warnings as errors
    -Wshadow            # Variable shadowing
    -Wnon-virtual-dtor  # Classes with virtual functions but non-virtual destructors
    -Woverloaded-virtual # Accidentally hiding base class virtual functions
    -Wold-style-cast    # C-style casts
    -Wcast-align        # Pointer casts that increase alignment requirements
    -Wunused            # Unused variables, parameters, functions
    -Wconversion        # Implicit narrowing conversions
    -Wsign-conversion   # Implicit sign conversions
    -Wnull-dereference  # Potential null pointer dereferences
    -Wdouble-promotion  # Implicit float-to-double promotion
    -Wformat=2          # Format string vulnerabilities
    -Wimplicit-fallthrough  # Missing break/fallthrough in switch
)
```

Additional GCC-specific flags worth enabling:
- `-Wduplicated-cond` -- identical conditions in if/else chains
- `-Wduplicated-branches` -- identical code in if/else branches
- `-Wlogical-op` -- suspicious logical operations
- `-Wuseless-cast` -- unnecessary casts
- `-Wmisleading-indentation` -- indentation that suggests incorrect control flow

### clang-format

Use [clang-format](https://clang.llvm.org/docs/ClangFormat.html) to enforce all formatting rules automatically. Run it as a pre-commit hook or CI check. Manual formatting review is a waste of engineering time.

Example `.clang-format` configuration encoding the rules from section 2:

```yaml
---
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 120
BreakBeforeBraces: Attach
AllowShortFunctionsOnASingleLine: Inline
AllowShortIfStatementsOnASingleLine: Never
AllowShortLoopsOnASingleLine: false
AlignAfterOpenBracket: Align
BinPackParameters: false
BinPackArguments: false
SpaceBeforeParens: ControlStatements
FixNamespaceComments: true
SortIncludes: CaseInsensitive
IncludeBlocks: Regroup
IncludeCategories:
  - Regex: '^".*'
    Priority: 1
  - Regex: '^<.*'
    Priority: 2
```

### clang-tidy

[clang-tidy](https://clang.llvm.org/extra/clang-tidy/) is a static analysis tool that catches bugs, enforces style, and suggests modernization. Configure it with a `.clang-tidy` file at the project root.

Recommended check categories:

| Category              | Purpose                                     |
|-----------------------|---------------------------------------------|
| `bugprone-*`          | Common bug patterns                         |
| `clang-analyzer-*`    | Clang Static Analyzer checks                |
| `cppcoreguidelines-*` | C++ Core Guidelines enforcement             |
| `misc-*`              | Miscellaneous useful checks                 |
| `modernize-*`         | Suggest modern C++ alternatives             |
| `performance-*`       | Performance anti-patterns                   |
| `readability-*`       | Code readability improvements               |

Example `.clang-tidy` configuration:

```yaml
---
Checks: >
  -*,
  bugprone-*,
  clang-analyzer-*,
  cppcoreguidelines-*,
  misc-*,
  modernize-*,
  performance-*,
  readability-*,
  -modernize-use-trailing-return-type,
  -readability-magic-numbers,
  -cppcoreguidelines-avoid-magic-numbers,
  -readability-identifier-length,
  -bugprone-easily-swappable-parameters

WarningsAsErrors: '*'

HeaderFilterRegex: 'include/.*'

CheckOptions:
  - key: readability-identifier-naming.ClassCase
    value: CamelCase
  - key: readability-identifier-naming.FunctionCase
    value: lower_case
  - key: readability-identifier-naming.VariableCase
    value: lower_case
  - key: readability-identifier-naming.PrivateMemberSuffix
    value: '_'
```

Note: `WarningsAsErrors: '*'` treats all clang-tidy warnings as errors, consistent with the zero-warning philosophy. Set it to `''` only during initial adoption when incrementally fixing existing violations.

### cppcheck

[cppcheck](https://cppcheck.sourceforge.io/) is a complementary static analysis tool that catches issues clang-tidy may miss, particularly around undefined behavior and memory leaks.

```sh
cppcheck --enable=all --std=c++17 --suppress=missingIncludeSystem \
    --error-exitcode=1 src/ include/
```

### Sanitizers

Use sanitizers during development and in CI to catch runtime errors.

```cmake
# Address Sanitizer: buffer overflows, use-after-free, memory leaks
target_compile_options(mylib PRIVATE -fsanitize=address -fno-omit-frame-pointer)
target_link_options(mylib PRIVATE -fsanitize=address)

# Undefined Behavior Sanitizer: signed overflow, null deref, alignment
target_compile_options(mylib PRIVATE -fsanitize=undefined)
target_link_options(mylib PRIVATE -fsanitize=undefined)

# Memory Sanitizer: uninitialized memory reads (Clang only, not available on macOS)
target_compile_options(mylib PRIVATE -fsanitize=memory -fno-omit-frame-pointer)
target_link_options(mylib PRIVATE -fsanitize=memory)

# Thread Sanitizer: data races
target_compile_options(mylib PRIVATE -fsanitize=thread)
target_link_options(mylib PRIVATE -fsanitize=thread)
```

Run these in separate CI jobs. ASan and UBSan can be combined in a single build (at the cost of ~2-3x slower execution). TSan and MSan must each run separately -- they conflict with ASan and with each other.

### Compiler Explorer

Use [Compiler Explorer (godbolt.org)](https://godbolt.org/) to verify codegen, compare compiler output across versions, and investigate optimization behavior.

### Build system

Use **CMake** (3.21+) as the build system. Key CMake hygiene:

```cmake
cmake_minimum_required(VERSION 3.21)
project(mylib VERSION 1.0.0 LANGUAGES CXX)

# Require the C++ standard, no extensions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Generate compile_commands.json for clang-tidy and IDE support
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

---

## Quick reference checklist

Use this checklist when auditing C++ code:

- [ ] **Naming**: Classes `PascalCase`, functions `snake_case`, constants `PascalCase`, macros `ALL_CAPS`
- [ ] **Formatting**: Consistent indentation, braces on same line, namespace closing comments, `.clang-format` present
- [ ] **RAII**: No manual `new`/`delete`, resources bound to object lifetimes
- [ ] **Move semantics**: Move operations marked `noexcept`, no `std::move` on return values
- [ ] **Smart pointers**: `unique_ptr` for ownership, raw pointers only for non-owning references
- [ ] **Const correctness**: `const` on parameters, locals, and member functions where appropriate
- [ ] **`auto`**: Used where type is obvious, spelled out where it is not
- [ ] **Error handling**: `std::optional` for absence, exceptions for errors, `noexcept` where guaranteed
- [ ] **`[[nodiscard]]`**: Applied to functions returning `optional`, error codes, or pure computations
- [ ] **Headers**: Include guards or `#pragma once` present, self-contained, includes ordered correctly
- [ ] **Classes**: Rule of zero preferred, `explicit` constructors, `struct` for data / `class` for behavior
- [ ] **No C-style casts**: Named casts only (`static_cast`, `const_cast`, etc.)
- [ ] **No macros**: Unless genuinely needed (include guards, platform detection)
- [ ] **Warnings**: `-Wall -Wextra -Wpedantic -Werror` enabled
- [ ] **Static analysis**: clang-tidy configured with `WarningsAsErrors: '*'` and passing
- [ ] **Formatting**: clang-format configured and enforced in CI
- [ ] **Standard library**: Algorithms preferred over raw loops, `string_view` for read-only strings
- [ ] **Tests**: All canonical test cases implemented with ID annotations

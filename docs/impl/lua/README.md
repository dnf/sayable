# Lua Style Guide

A comprehensive style guide for auditing Lua implementations. Drawn from
community conventions, authoritative references, and widely adopted open-source
standards.

## Sources

- [Lua Style Guide (lua-users.org)](http://lua-users.org/wiki/LuaStyleGuide) --
  community-maintained wiki guide
- [Programming in Lua (PiL)](https://www.lua.org/pil/) -- the authoritative
  language reference by Roberto Ierusalimschy
- [Olivine Labs Lua Style Guide](https://github.com/Olivine-Labs/lua-style-guide) --
  widely adopted open-source style guide (Busted/LuaRocks ecosystem)
- [LuaRocks conventions](https://github.com/luarocks/luarocks/wiki/Recommended-practices) --
  package manager community practices
- [Luacheck documentation](https://luacheck.readthedocs.io/en/stable/) --
  the standard Lua linter

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Table Patterns](#3-table-patterns)
4. [Module Design](#4-module-design)
5. [Function Design](#5-function-design)
6. [Error Handling](#6-error-handling)
7. [String Handling](#7-string-handling)
8. [Metatables and OOP](#8-metatables-and-oop)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)

---

## 1. Naming Conventions

### General rules

| Element | Convention | Example |
|---------|-----------|---------|
| Local variables | `snake_case` | `line_count`, `max_retries` |
| Local functions | `snake_case` | `parse_date`, `is_leap_year` |
| Module-level functions | `snake_case` | `format_age`, `get_locale` |
| Module tables | `PascalCase` or single uppercase letter | `SayableAge`, `M` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_AGE_MONTHS`, `VERSION` |
| Boolean variables/functions | `is_` or `has_` prefix | `is_valid`, `has_children` |
| Loop throwaway variables | `_` (underscore) | `for _, v in ipairs(t) do` |
| Short loop indices | `i`, `j`, `k` | `for i = 1, 10 do` |
| Metatables | `mt` suffix or `__` prefix by convention | `Account_mt` |
| Private fields | `_` prefix (convention only) | `self._internal_state` |

### Specific guidance

- **Avoid single-letter names** outside of loop variables and very short lambdas.
  Use descriptive names that convey intent.
- **Match filenames to module names.** A module returned as `sayableage` should
  live in `sayableage.lua`.
- **Use `_` for intentionally unused values:**
  ```lua
  for _, value in ipairs(items) do
      process(value)
  end
  ```
- **Lua reserved words** (`and`, `break`, `do`, `else`, `elseif`, `end`,
  `false`, `for`, `function`, `if`, `in`, `local`, `nil`, `not`, `or`,
  `repeat`, `return`, `then`, `true`, `until`, `while`) cannot be used as
  identifiers. Use a trailing underscore if unavoidable: `end_`.

---

## 2. Code Formatting

### Indentation

Use **4 spaces** per indentation level. Never use tabs. (Note: the Olivine Labs
guide recommends 2 spaces. Both are common in the Lua community. The important
thing is consistency within a project. This project uses 4 spaces.)

```lua
local function calculate(x, y)
    if x > 0 then
        return x + y
    else
        return y
    end
end
```

### Line length

Target **80-100 characters** per line. Break long lines at logical boundaries:

```lua
-- Break after operators or before arguments
local result = very_long_function_name(
    first_argument,
    second_argument,
    third_argument
)

-- Break long conditions
if condition_one
    and condition_two
    and condition_three then
    do_something()
end
```

### Spacing

- **One space** after commas: `f(a, b, c)`
- **One space** around binary operators: `x = a + b`, `if x > 0 then`
- **No space** between function name and opening parenthesis: `print("hello")`
- **No space** inside parentheses: `f(x)` not `f( x )`
- **One space** inside table braces for single-line tables:
  `{ one = 1, two = 2 }`
- **Blank lines** between function definitions and between logical sections
- **One trailing newline** at end of file

### Semicolons

Do not use semicolons to terminate statements. Lua does not require them. Use
line breaks to separate statements:

```lua
-- Good
local x = 1
local y = 2

-- Bad
local x = 1;
local y = 2;
```

The one exception is disambiguating a function call from a statement when a line
begins with `(`:

```lua
local x = f()
;(function() end)()  -- semicolon prevents parsing as f()()
```

This situation is rare and usually indicates the code should be restructured.

### Blank lines

- One blank line between top-level function definitions
- One blank line between logical sections within a function
- No trailing whitespace on any line
- No multiple consecutive blank lines

---

## 3. Table Patterns

### Array-style tables

Use integer keys starting at 1 (Lua convention). Access length with `#`:

```lua
local fruits = { "apple", "banana", "cherry" }
print(#fruits)  --> 3

for i, fruit in ipairs(fruits) do
    print(i, fruit)
end
```

### Dictionary-style tables

Use string keys with `=` syntax in constructors:

```lua
local config = {
    host = "localhost",
    port = 8080,
    debug = false,
}
```

Trailing commas are permitted and encouraged in multi-line tables -- they make
diffs cleaner and reordering easier.

### Mixed tables

Avoid mixing array and dictionary entries in a single table. If you must, be
aware that `#` only counts the array part:

```lua
-- Avoid this pattern
local mixed = { "a", "b", name = "mixed" }
print(#mixed)  --> 2 (only counts array portion)
```

### Nested tables

Indent nested tables consistently:

```lua
local stages = {
    {
        name = "newborn",
        up_to = 14,
        unit = "day",
    },
    {
        name = "infant",
        up_to = 90,
        unit = "week",
        secondary = "day",
    },
}
```

### Module tables

The standard pattern uses a local table that is returned at the end:

```lua
local M = {}

M.VERSION = "1.0.0"

function M.greet(name)
    return "Hello, " .. name
end

return M
```

### Constructor syntax for short tables

Single-line constructors are fine when they fit within the line length limit:

```lua
local point = { x = 10, y = 20 }
local lengths = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
```

---

## 4. Module Design

### The return-table pattern

Every module should be a single file that returns a table (or a function). This
is the idiomatic Lua module pattern since Lua 5.1+:

```lua
-- mymodule.lua
local M = {}

local helper_constant = 42

local function private_helper(x)
    return x * helper_constant
end

function M.public_function(x)
    return private_helper(x) + 1
end

return M
```

Key rules:

- **Declare everything `local`** unless it is intentionally part of the module's
  public API.
- **Return the module table** as the last statement.
- **Private functions and data** are simply `local` -- they are invisible to
  callers by virtue of lexical scoping.
- **Public functions** are assigned to the module table (`M.func_name`).

### Requiring modules

Use `local` when requiring:

```lua
local sayableage = require("sayableage")
local json = require("cjson")
```

- Place all `require` calls at the top of the file, before any other code.
- Never use bare `require` without assigning to a local (except for side-effect
  modules, which should be avoided).

### Lazy requires

For modules that are expensive to load or only sometimes needed, require inside
the function that uses them:

```lua
function M.get_locale(code)
    local registry = require("locales.init")
    return registry.get_locale(code)
end
```

This is acceptable but should be documented with a comment if it is not obvious
why the require is deferred.

### Avoid `module()` and `setfenv()`

The `module()` function (Lua 5.1) is deprecated and removed in 5.2+. The
`setfenv()` function is also removed in 5.2+. Always use the return-table
pattern instead.

### File and directory layout

- One module per file.
- Filenames match module names: `sayableage.lua` for the `sayableage` module.
- Subdirectories map to nested require paths: `locales/en.lua` is
  `require("locales.en")`.
- Use an `init.lua` file for directory modules:
  `locales/init.lua` is `require("locales")`.

---

## 5. Function Design

### Local functions

Always declare functions as `local` unless they are part of a module's public
API:

```lua
-- Preferred: local function syntax (supports recursion)
local function factorial(n)
    if n == 0 then return 1 end
    return n * factorial(n - 1)
end

-- Also valid: local variable assignment
local double = function(x)
    return x * 2
end
```

The `local function` syntax is syntactic sugar that handles recursive
self-reference correctly. Prefer it over the variable-assignment form.

### Forward declarations for mutual recursion

When two local functions call each other, forward-declare:

```lua
local is_even, is_odd

function is_even(n)
    if n == 0 then return true end
    return is_odd(n - 1)
end

function is_odd(n)
    if n == 0 then return false end
    return is_even(n - 1)
end
```

### Closures

Lua functions are first-class values with lexical scoping. Use closures to
capture state:

```lua
local function make_counter(start)
    local count = start or 0
    return function()
        count = count + 1
        return count
    end
end

local counter = make_counter()
print(counter())  --> 1
print(counter())  --> 2
```

### Multiple return values

Lua functions can return multiple values. This is idiomatic for returning a
result and an error:

```lua
local function parse_date(s)
    if not s or s == "" then return nil end
    local y, m, d = s:match("^(%d+)-(%d+)-(%d+)$")
    if not y then return nil end
    return tonumber(y), tonumber(m), tonumber(d)
end

local year, month, day = parse_date("2025-06-15")
```

Important: multiple return values are only fully captured when the function call
is the **last** expression in an assignment, argument list, or return statement.
Otherwise only the first value is kept:

```lua
local a, b = f(), g()  -- a gets first return of f(); b gets first return of g()
local a, b = g()       -- a and b get both returns of g()
```

### Varargs

Use `...` for variable arguments. In Lua 5.2+, use `select` and `{...}` (not
the deprecated `arg` table):

```lua
local function log(level, fmt, ...)
    local msg = string.format(fmt, ...)
    print(string.format("[%s] %s", level, msg))
end

log("INFO", "User %s logged in at %d", "alice", 1234)
```

### Function length

Keep functions short and focused. If a function needs a comment to explain what
a block does, extract that block into a named function instead. The name
replaces the comment.

### Validate inputs early

Check preconditions at the top of the function and return immediately on
failure:

```lua
local function process(data)
    if not data then return nil end
    if type(data) ~= "table" then return nil, "expected table" end
    -- ... proceed with valid data
end
```

---

## 6. Error Handling

### pcall and xpcall

Use `pcall` (protected call) to catch errors without crashing:

```lua
local ok, result = pcall(function()
    return risky_operation()
end)

if not ok then
    print("Error: " .. tostring(result))
end
```

Use `xpcall` when you need a stack traceback:

```lua
local ok, result = xpcall(risky_operation, debug.traceback)
if not ok then
    print("Error with traceback:\n" .. result)
end
```

### error()

Raise errors with `error()`. The second argument controls the error level
(which function the error is attributed to):

```lua
local function validate_age(age)
    if type(age) ~= "number" then
        error("age must be a number, got " .. type(age), 2)  -- blame caller
    end
end
```

- Level 1 (default): error points to the `error()` call itself
- Level 2: error points to the function that called the erroring function
- Level 0: no location info added

### assert

Use `assert` for preconditions that should never fail in correct usage:

```lua
local data = assert(load_file(path))  -- crashes with error message if nil

-- assert with custom message
assert(type(x) == "number", "expected number, got " .. type(x))
```

`assert` is equivalent to:

```lua
if not condition then
    error(message or "assertion failed!")
end
```

### Error objects vs. strings

For simple cases, string error messages suffice. For structured error handling,
pass a table to `error()`:

```lua
-- String errors (simple, common)
error("file not found: " .. path)

-- Table errors (structured, for programmatic handling)
error({ code = "NOT_FOUND", path = path, message = "file not found" })

-- Catching structured errors
local ok, err = pcall(function()
    error({ code = 121 })
end)
if not ok then
    print(err.code)  --> 121
end
```

### Return-nil-plus-error pattern

For expected failures (not bugs), return `nil` plus an error message instead of
raising an error. This is the dominant Lua convention for I/O and parsing:

```lua
local function parse_config(path)
    local f, err = io.open(path, "r")
    if not f then return nil, err end
    local content = f:read("*a")
    f:close()
    return decode(content)
end

-- Caller checks:
local config, err = parse_config("app.conf")
if not config then
    print("Failed to load config: " .. err)
end
```

### When to use which

| Situation | Approach |
|-----------|----------|
| Programming error (bug) | `error()` with descriptive message |
| Precondition violation | `assert()` or `error(..., 2)` |
| Expected failure (I/O, parsing) | Return `nil, error_message` |
| Calling untrusted/risky code | Wrap in `pcall` or `xpcall` |

---

## 7. String Handling

### String library basics

Strings in Lua are **immutable**. Every operation creates a new string:

```lua
local s = "hello"
local upper = string.upper(s)      -- "HELLO"
local sub = string.sub(s, 1, 3)    -- "hel"
local len = #s                      -- 5 (prefer # over string.len)
local rep = string.rep("-", 40)    -- forty dashes
```

### Method syntax

Lua strings have a metatable that allows method-style calls:

```lua
-- These are equivalent:
string.upper(s)
s:upper()

-- Method syntax is preferred for readability:
local y, m, d = s:match("^(%d+)-(%d+)-(%d+)$")
```

### string.format

Use `string.format` for formatted output, similar to C's `printf`:

```lua
local msg = string.format("Name: %s, Age: %d", name, age)
local hex = string.format("%04x", 255)         -- "00ff"
local float = string.format("%.2f", 3.14159)   -- "3.14"
local padded = string.format("%10s", "right")   -- "     right"
```

### Patterns (not regex)

Lua uses its own pattern-matching syntax, not POSIX or PCRE regular
expressions. Key differences:

| Lua Pattern | Meaning |
|------------|---------|
| `%a` | Any letter |
| `%d` | Any digit |
| `%l` | Lowercase letter |
| `%u` | Uppercase letter |
| `%w` | Alphanumeric |
| `%s` | Whitespace |
| `%p` | Punctuation |
| `.` | Any character |
| `%A`, `%D`, etc. | Complement (non-letter, non-digit, etc.) |

Repetition modifiers: `+` (1 or more), `*` (0 or more), `-` (0 or more,
shortest match), `?` (0 or 1).

Anchors: `^` (start of string), `$` (end of string).

Magic characters that need `%` escaping: `( ) . % + - * ? [ ^ $`

```lua
-- Match a date string
local y, m, d = s:match("^(%d+)-(%d+)-(%d+)$")

-- Check if a string is a valid identifier
if s:match("^[_%a][_%w]*$") then
    print("valid identifier")
end

-- Replace all occurrences
local cleaned = s:gsub("%s+", " ")  -- collapse whitespace
```

### Long strings

Use double square brackets for multi-line strings or strings containing quotes:

```lua
local sql = [[
    SELECT *
    FROM users
    WHERE active = 1
]]

-- With level (to allow nested brackets):
local code = [==[
    local s = [[nested brackets]]
]==]
```

Long strings do not interpret escape sequences. Use them for embedded data,
not for strings that need `\n` or `\t`.

### String concatenation

Use `..` for simple concatenation. For building strings in a loop, use
`table.concat` to avoid O(n^2) performance:

```lua
-- Good: table.concat for loops
local parts = {}
for i = 1, 1000 do
    parts[i] = tostring(i)
end
local result = table.concat(parts, ", ")

-- Bad: repeated .. in a loop (O(n^2) due to immutable strings)
local result = ""
for i = 1, 1000 do
    result = result .. tostring(i) .. ", "  -- creates 2000 intermediate strings
end
```

### String quoting

Use double quotes for strings by default. Single quotes are also acceptable --
the important thing is consistency within a project. (The Olivine Labs guide
recommends single quotes.)

---

## 8. Metatables and OOP

### Metatable basics

Every table can have a metatable that defines behavior for operations:

```lua
local t = {}
local mt = {}
setmetatable(t, mt)
assert(getmetatable(t) == mt)
```

### Common metamethods

| Metamethod | Triggered by |
|-----------|-------------|
| `__index` | Accessing an absent key |
| `__newindex` | Setting an absent key |
| `__tostring` | `tostring(obj)` |
| `__len` | `#obj` |
| `__eq` | `==` comparison |
| `__add` | `+` operator |
| `__sub` | `-` operator |
| `__mul` | `*` operator |
| `__concat` | `..` operator |
| `__call` | Calling as a function |
| `__metatable` | Protects metatable from access/modification |
| `__gc` | Garbage collection finalizer (Lua 5.2+) |

### The `__index` metamethod

`__index` is the foundation of Lua's prototype-based OOP. It can be a table
(for simple inheritance) or a function (for computed lookups):

```lua
-- Table-based __index (simple inheritance)
local defaults = { x = 0, y = 0, width = 100, height = 100 }
local mt = { __index = defaults }
local window = setmetatable({ x = 10, y = 20 }, mt)
print(window.width)  --> 100 (inherited from defaults)

-- Function-based __index (computed lookup)
local mt = {
    __index = function(table, key)
        return defaults[key]
    end,
}
```

### The `__tostring` metamethod

Provide human-readable string representations:

```lua
local Point = {}
Point.__index = Point

function Point.new(x, y)
    return setmetatable({ x = x, y = y }, Point)
end

function Point:__tostring()
    return string.format("(%g, %g)", self.x, self.y)
end

local p = Point.new(3, 4)
print(p)  --> (3, 4)
```

### Prototype pattern (class emulation)

The standard OOP pattern in Lua uses a table as both the class and the
`__index` target:

```lua
local Account = {}
Account.__index = Account

function Account.new(balance)
    return setmetatable({ balance = balance or 0 }, Account)
end

function Account:deposit(amount)
    self.balance = self.balance + amount
end

function Account:withdraw(amount)
    if amount > self.balance then
        error("insufficient funds")
    end
    self.balance = self.balance - amount
end

-- Usage
local acct = Account.new(100)
acct:deposit(50)
acct:withdraw(30)
```

### Colon syntax for method calls

The colon `:` is syntactic sugar that passes the table as the first argument
(`self`):

```lua
-- These are equivalent:
acct:deposit(50)        -- colon syntax (preferred for methods)
Account.deposit(acct, 50)  -- dot syntax with explicit self

-- Definition equivalence:
function Account:deposit(amount)    -- colon: implicit self parameter
function Account.deposit(self, amount)  -- dot: explicit self parameter
```

**Rule:** Use `:` when the function operates on the object (a method). Use `.`
when it does not (a plain function or constructor).

### Inheritance

Create subclasses by setting the parent as the metatable's `__index`:

```lua
local SpecialAccount = setmetatable({}, { __index = Account })
SpecialAccount.__index = SpecialAccount

function SpecialAccount.new(balance, limit)
    local instance = Account.new(balance)
    instance.limit = limit or 0
    return setmetatable(instance, SpecialAccount)
end

function SpecialAccount:withdraw(amount)
    if amount - self.balance >= self.limit then
        error("insufficient funds")
    end
    self.balance = self.balance - amount
end
```

### When not to use OOP

Lua is a multi-paradigm language. Not everything needs to be an object. For
simple data-processing modules, the return-table pattern with plain functions
is cleaner and more idiomatic:

```lua
-- Preferred for utility modules: plain functions in a table
local M = {}

function M.format_age(dob, as_of)
    -- ...
end

return M
```

Reserve metatables and OOP for cases where you need inheritance, operator
overloading, or instance-specific state management.

---

## 9. Common Idioms

### Default values

Use `or` to provide defaults for `nil` and `false`:

```lua
local name = input_name or "Anonymous"
local count = opts and opts.count or 10
```

**Caveat:** `or` treats `false` the same as `nil`. If `false` is a valid value,
use an explicit nil check:

```lua
-- When false is a valid value:
local verbose
if opts.verbose ~= nil then
    verbose = opts.verbose
else
    verbose = true  -- default
end
```

### Ternary pattern

Lua has no ternary operator. Use `and`/`or`:

```lua
local label = is_plural and "items" or "item"
local status = success and "ok" or "failed"
```

**Caveat:** This fails if the "true" branch is `false` or `nil`:

```lua
-- BUG: returns "default" even when condition is true
local x = true and false or "default"  --> "default"
```

For those cases, use an `if`/`else` block.

### ipairs vs. pairs

- `ipairs(t)` -- iterates array portion in order: `1, 2, 3, ...` until the
  first `nil` gap. Use for arrays.
- `pairs(t)` -- iterates all keys in unspecified order. Use for dictionaries.

```lua
-- Array iteration (ordered, stops at first nil)
local fruits = { "apple", "banana", "cherry" }
for i, fruit in ipairs(fruits) do
    print(i, fruit)
end

-- Dictionary iteration (unordered)
local config = { host = "localhost", port = 8080 }
for key, value in pairs(config) do
    print(key, value)
end
```

### Length operator `#`

`#t` returns the length of the array portion of table `t`. It is only reliable
for **sequence tables** (contiguous integer keys starting at 1 with no `nil`
gaps):

```lua
local t = { "a", "b", "c" }
print(#t)  --> 3

-- UNRELIABLE: table with nil gaps
local t = { "a", nil, "c" }
print(#t)  --> could be 1 or 3 (undefined behavior)
```

### Checking for nil

Use truthiness checks unless you need to distinguish `nil` from `false`:

```lua
-- Good: concise nil check
if not value then return end

-- When you must distinguish nil from false:
if value == nil then return end
```

### Swap values

Lua supports multiple assignment, enabling concise swaps:

```lua
a, b = b, a
```

### Type checking

Use `type()` for runtime type checks:

```lua
if type(x) == "string" then
    -- ...
elseif type(x) == "table" then
    -- ...
end
```

### String method on literals

Wrap string literals in parentheses to call methods:

```lua
local upper = ("hello"):upper()  -- "HELLO"
```

### Numeric for with step

```lua
-- Count down
for i = 10, 1, -1 do
    print(i)
end
```

---

## 10. Things to Avoid

### Global variables

**Never use globals.** Always declare variables with `local`. Globals are the
single most common source of bugs in Lua code:

```lua
-- Bad: creates a global
count = 0

-- Good: local variable
local count = 0
```

Use luacheck to catch accidental globals (warning codes 111, 112, 113).

### String concatenation in loops

Repeated `..` in a loop creates O(n^2) garbage. Use `table.concat`:

```lua
-- Bad: O(n^2)
local s = ""
for i = 1, n do
    s = s .. items[i]
end

-- Good: O(n)
local parts = {}
for i = 1, n do
    parts[i] = items[i]
end
local s = table.concat(parts)
```

### rawget/rawset abuse

`rawget` and `rawset` bypass metatables. They have legitimate uses (avoiding
infinite `__index`/`__newindex` recursion), but using them to circumvent
metatable behavior elsewhere makes code fragile and hard to reason about.

### Deeply nested callbacks

Lua's closures make it easy to create deeply nested callback chains. Flatten
them using named local functions:

```lua
-- Bad: deeply nested
do_thing(function(result)
    process(result, function(data)
        save(data, function(ok)
            if ok then finalize() end
        end)
    end)
end)

-- Better: named functions
local function on_saved(ok)
    if ok then finalize() end
end
local function on_processed(data)
    save(data, on_saved)
end
local function on_done(result)
    process(result, on_processed)
end
do_thing(on_done)
```

### Modifying tables during iteration

Never add or remove keys from a table while iterating over it with `pairs` or
`ipairs`. Collect changes and apply them after:

```lua
-- Bad: modifying during iteration
for k, v in pairs(t) do
    if v < 0 then t[k] = nil end  -- undefined behavior
end

-- Good: collect then modify
local to_remove = {}
for k, v in pairs(t) do
    if v < 0 then to_remove[#to_remove + 1] = k end
end
for _, k in ipairs(to_remove) do
    t[k] = nil
end
```

### Using `arg` as a parameter name

In Lua 5.0, `arg` was a special implicit variable for varargs. Avoid using it
as a parameter name to prevent confusion across Lua versions. Use `...`
(varargs) or a descriptive name instead.

### Relying on `#` with non-sequence tables

The length operator `#` is only defined for sequence tables. Using it on tables
with `nil` holes or non-integer keys produces undefined results.

### Comparing with `==` on tables

`==` on tables compares **identity** (same reference), not structural equality.
To compare table contents, write a deep-equality function or use a testing
library.

### Overusing `tostring` coercion

Lua automatically coerces numbers to strings in concatenation contexts, but
relying on this makes code less clear:

```lua
-- Implicit coercion (works but unclear intent)
local s = "count: " .. count

-- Explicit (preferred when formatting matters)
local s = string.format("count: %d", count)
```

---

## 11. Tooling

### Luacheck

[Luacheck](https://luacheck.readthedocs.io/en/stable/) is the standard Lua
linter. It detects:

- Accidental global variables (read and write)
- Unused local variables and values
- Unreachable code
- Shadowed variables
- Line length violations
- Cyclomatic complexity issues
- Unbalanced assignments

**Installation:**

```sh
luarocks install luacheck
```

**Configuration** via `.luacheckrc` at the project root:

```lua
-- .luacheckrc
std = "lua51+lua52+lua53"
max_line_length = 100

-- Project-specific globals
globals = {}

-- Per-file overrides
files["test_*.lua"] = {
    std = "+busted",  -- allow busted globals (describe, it, assert)
}

-- Ignore specific warnings
ignore = {
    "212",  -- unused argument (common in callbacks)
}
```

**Common warning codes:**

| Code | Meaning |
|------|---------|
| 111 | Setting an undefined global variable |
| 112 | Mutating an undefined global variable |
| 113 | Accessing an undefined global variable |
| 211 | Unused local variable |
| 212 | Unused argument |
| 311 | Value assigned to a local variable is unused |
| 411 | Variable was previously defined in the same scope |
| 421 | Shadowing a local variable |
| 431 | Shadowing an upvalue |
| 531 | Unreachable code |
| 611 | Line contains only whitespace |
| 631 | Line is too long |

**Inline suppression:**

```lua
local _ = unused_but_needed  -- luacheck: ignore 211
```

### Busted

[Busted](https://lunarmodules.github.io/busted/) is the standard Lua testing
framework (BDD-style). It provides `describe`, `it`, `assert`, `spy`, `mock`,
and more:

```lua
describe("my module", function()
    it("does something", function()
        assert.are.equal(4, 2 + 2)
    end)

    it("handles nil", function()
        assert.is_nil(my_function(nil))
    end)
end)
```

Run with: `busted` or `busted --verbose`

### LuaFormatter / StyLua

- [LuaFormatter](https://github.com/Koihik/LuaFormatter) -- configurable Lua
  code formatter
- [StyLua](https://github.com/JohnnyMorganz/StyLua) -- opinionated Lua
  formatter inspired by rustfmt/prettier (more actively maintained)

Both can enforce consistent indentation, spacing, and line length. StyLua is
the more modern choice.

### LuaRocks

[LuaRocks](https://luarocks.org/) is the standard package manager for Lua.
Conventions for published packages:

- Use a `.rockspec` file for package metadata
- Follow semantic versioning
- Place source files in `src/`
- Place tests in `spec/`
- Use lowercase, hyphenated module names: `my-module`

### LDoc

[LDoc](https://github.com/lunarmodules/LDoc) generates documentation from
source comments using `---` doc comments:

```lua
--- Format a human-friendly age string.
-- @param date_of_birth YYYY-MM-DD date string
-- @param as_of YYYY-MM-DD reference date (defaults to today)
-- @return Formatted age string, or nil on invalid input
function M.format_age(date_of_birth, as_of)
    -- ...
end
```

---

## Quick Reference Checklist

For code auditing, verify the following:

- [ ] All variables are `local` (no accidental globals)
- [ ] No unused variables or arguments (without justification)
- [ ] All `require` calls are at the top of the file and assigned to locals
- [ ] Module uses the return-table pattern
- [ ] Functions are short, focused, and named descriptively
- [ ] No string concatenation in loops (use `table.concat`)
- [ ] Error handling uses the appropriate pattern for the situation
- [ ] Naming follows `snake_case` for variables/functions, `UPPER_SNAKE_CASE`
  for constants
- [ ] Tables use trailing commas in multi-line constructors
- [ ] `ipairs` for arrays, `pairs` for dictionaries
- [ ] Colon syntax (`:`) for method definitions and calls
- [ ] Dot syntax (`.`) for plain functions and constructors
- [ ] No reliance on `#` for non-sequence tables
- [ ] Luacheck passes with zero warnings

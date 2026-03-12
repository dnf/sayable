# Lua Style Guide

A style guide for auditing Lua implementations in this project. Drawn from
community conventions, authoritative references, and the project's own
codebase patterns.

## Target Lua version

This project targets **Lua 5.1+** compatibility. Do not use features
exclusive to 5.2+ (`goto`, integer division `//`, bitwise operators) unless
the project explicitly migrates. The `utf8` standard library (5.3+) is not
available; see the UTF-8 section for alternatives.

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
8. [UTF-8 and Multi-byte Strings](#8-utf-8-and-multi-byte-strings)
9. [Metatables and OOP](#9-metatables-and-oop)
10. [Common Idioms](#10-common-idioms)
11. [Things to Avoid](#11-things-to-avoid)
12. [Tooling](#12-tooling)

---

## 1. Naming Conventions

### General rules

| Element | Convention | Example |
|---------|-----------|---------|
| Local variables | `snake_case` | `line_count`, `max_retries` |
| Local functions | `snake_case` | `parse_date`, `is_leap_year` |
| Module-level functions | `snake_case` | `format_age`, `get_locale` |
| Local module table (return-table pattern) | Single uppercase letter | `M` |
| Class tables (prototype/OOP pattern) | `PascalCase` | `Account`, `Point` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_AGE_MONTHS`, `VERSION` |
| Boolean variables/functions | `is_` or `has_` prefix | `is_valid`, `has_children` |
| Loop throwaway variables | `_` (underscore) | `for _, v in ipairs(t) do` |
| Short loop indices | `i`, `j`, `k` | `for i = 1, 10 do` |
| Metatables | `mt` suffix or `__` prefix by convention | `Account_mt` |
| Private fields | `_` prefix (convention only) | `self._internal_state` |

### Specific guidance

- **Avoid single-letter names** outside of loop variables, very short lambdas,
  and the local module table `M`.
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

Consistency within a project matters more than any specific width. The Lua
community is split between 2-space and 4-space indentation. **This project
uses 4 spaces.** Never use tabs.

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

### String quoting

This project uses double quotes for strings. Be consistent.

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

Lazy requires are acceptable only for large optional subsystems (such as the
locale registry in this project, which loads 110 locale files). Always include
a justification comment:

```lua
function M.get_locale(code)
    -- Lazy: locales registry is large and only needed on lookup
    local registry = require("locales.init")
    return registry.get_locale(code)
end
```

Do not use lazy requires for routine dependencies. They make dependency
tracking harder and hide a module's true requirements from readers scanning
the file header.

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
self-reference correctly. Prefer it over the variable-assignment form for
standalone functions.

### Forward declarations for mutual recursion

When two local functions call each other, forward-declare and use the
assignment form to keep the local binding visually explicit:

```lua
local is_even, is_odd

is_even = function(n)
    if n == 0 then return true end
    return is_odd(n - 1)
end

is_odd = function(n)
    if n == 0 then return false end
    return is_even(n - 1)
end
```

Using `function is_even(n)` (without `local`) after a forward declaration
works because it assigns to the existing local, but it is visually
indistinguishable from a global function declaration. If someone later removes
the forward declaration, the functions silently become globals. The assignment
form makes the relationship explicit.

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

### Error taxonomy

| Situation | Approach |
|-----------|----------|
| Programming error (bug) | `error()` with descriptive message |
| Precondition violation | `assert()` or `error(..., 2)` |
| Expected failure (I/O, parsing) | Return `nil, error_message` |
| No meaningful result (not an error) | Return `nil` |
| Calling untrusted/risky code | Wrap in `pcall` or `xpcall` |

The distinction between "expected failure" and "no meaningful result" matters.
When invalid input is a normal case (like `format_age(nil)`), returning bare
`nil` is appropriate. When failure carries diagnostic information the caller
needs (like an I/O error), return `nil, error_message`.

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

### Error objects vs. strings

For simple cases, string error messages suffice. For structured error handling,
pass a table to `error()`:

```lua
-- String errors (simple, common)
error("file not found: " .. path)

-- Table errors (structured, for programmatic handling)
error({ code = "NOT_FOUND", path = path, message = "file not found" })
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

---

## 7. String Handling

### String library basics

Strings in Lua are **immutable** byte sequences. Every operation creates a new
string:

```lua
local s = "hello"
local upper = string.upper(s)      -- "HELLO"
local sub = string.sub(s, 1, 3)    -- "hel"
local len = #s                      -- 5 (byte length; prefer # over string.len)
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

Use `string.format` for formatted output when you need padding, precision,
hexadecimal, or multiple substitutions:

```lua
local msg = string.format("Name: %s, Age: %d", name, age)
local hex = string.format("%04x", 255)         -- "00ff"
local float = string.format("%.2f", 3.14159)   -- "3.14"
local padded = string.format("%10s", "right")   -- "     right"
```

For simple string-number concatenation, `..` is idiomatic and clear:

```lua
local label = "count: " .. count
```

### Patterns (not regex)

Lua uses its own pattern-matching syntax, not POSIX or PCRE regular
expressions. Key differences:

| Lua Pattern | Meaning |
|------------|---------|
| `%a` | Any ASCII letter |
| `%d` | Any digit |
| `%l` | Lowercase ASCII letter |
| `%u` | Uppercase ASCII letter |
| `%w` | ASCII alphanumeric |
| `%s` | Whitespace |
| `%p` | Punctuation |
| `.` | Any byte |
| `%A`, `%D`, etc. | Complement (non-letter, non-digit, etc.) |

Repetition modifiers: `+` (1 or more), `*` (0 or more), `-` (0 or more,
shortest match), `?` (0 or 1).

Anchors: `^` (start of string), `$` (end of string).

Magic characters that need `%` escaping: `( ) . % + - * ? [ ^ $`

**Important:** Pattern character classes (`%a`, `%l`, `%u`, `%w`, `%p`) only
match ASCII characters. They do not match accented Latin characters, Cyrillic,
Arabic, Hebrew, CJK, or any other non-ASCII code points. See the UTF-8 section
for handling multi-byte text.

```lua
-- Match a date string (ASCII digits -- safe)
local y, m, d = s:match("^(%d+)-(%d+)-(%d+)$")

-- Check if a string is a valid ASCII identifier
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

---

## 8. UTF-8 and Multi-byte Strings

This project handles 110 locales including Hebrew, Arabic, Amharic, Thai, and
Chinese. Understanding how Lua handles multi-byte strings is essential.

### Lua strings are byte sequences

Lua strings are sequences of bytes, not characters. All standard string
operations work on bytes:

```lua
local s = "cafe\xCC\x81"  -- "cafe" + combining accent (UTF-8 for "cafe\u0301")
print(#s)                   --> 6 (bytes, not characters)
print(s:sub(1, 4))          --> "cafe" (works because ASCII chars are single-byte)
```

### What is safe for UTF-8

These operations work correctly on UTF-8 strings without special handling:

- **Concatenation** (`..`): joining UTF-8 strings produces valid UTF-8
- **Equality** (`==`): byte-for-byte comparison works if strings are in the
  same normalization form
- **`string.find` / `string.match` with literal patterns**: searching for a
  UTF-8 substring within a UTF-8 string works (bytes match bytes)
- **`string.format` with `%s`**: inserts the string as-is
- **`table.concat`**: joins strings without modification

### What is NOT safe for UTF-8

- **`#s`**: returns byte count, not character count
- **`string.sub(s, i, j)`**: slices at byte positions, can split a multi-byte
  character
- **`string.reverse(s)`**: reverses bytes, corrupts multi-byte characters
- **`string.upper` / `string.lower`**: only works for ASCII letters
- **Character classes** (`%a`, `%l`, `%u`, `%w`): only match ASCII

### Practical guidance for this project

The locale data in this project consists of pre-formed UTF-8 strings (locale
labels, unit templates). The formatter substitutes `{n}` placeholders with
numeric values (ASCII digits) and concatenates the results. This is safe
because:

1. Template substitution uses `string.gsub` with literal patterns (`{n}`,
   `{0}`), which are ASCII-only search targets
2. The replacement values are numeric strings (ASCII digits)
3. The final assembly uses concatenation (`..`), which preserves UTF-8

Do not use `#`, `string.sub`, `string.reverse`, `string.upper`, or
`string.lower` on locale strings unless you are certain they contain only ASCII.

---

## 9. Metatables and OOP

This project uses plain function-table modules (the return-table pattern), not
OOP. Reserve metatables and prototype-based OOP for cases where you genuinely
need inheritance, operator overloading, or instance-specific state management.
For data-processing and formatting modules, plain functions are cleaner and more
idiomatic:

```lua
-- Preferred for utility modules: plain functions in a table
local M = {}

function M.format_age(dob, as_of)
    -- ...
end

return M
```

### Colon vs. dot syntax

Even without OOP, understanding the colon/dot distinction matters because
libraries like Busted use colon syntax:

```lua
-- Colon syntax passes the table as the first argument (self):
acct:deposit(50)               -- equivalent to Account.deposit(acct, 50)

-- Dot syntax does not:
M.format_age(dob, as_of)      -- plain function call, no implicit self
```

**Rule:** Use `:` when the function operates on the object (a method). Use `.`
when it does not (a plain function or constructor).

### Reference material

For projects that do use metatables and OOP, see [Programming in Lua,
Chapter 16: Object-Oriented Programming](https://www.lua.org/pil/16.html) for
the prototype pattern, `__index`, inheritance, and metamethod reference.

---

## 10. Common Idioms

### Default values with `or`

Use `or` to provide defaults for string and numeric parameters:

```lua
local name = input_name or "Anonymous"
local count = opts and opts.count or 10
```

**Never use `or` for boolean defaults.** The `or` operator treats `false` the
same as `nil`, so `opts.verbose or true` always returns `true` -- even when
`opts.verbose` is explicitly `false`. This is a frequent source of bugs:

```lua
-- BUG: always returns true, even when opts.verbose is false
local verbose = opts.verbose or true

-- Correct: explicit nil check for boolean defaults
local verbose
if opts.verbose ~= nil then
    verbose = opts.verbose
else
    verbose = true
end
```

### Conditional expressions with `and`/`or`

Lua has no ternary operator. The `and`/`or` pattern works as a conditional
expression, but **only when the `and` operand is guaranteed to be truthy**
(not `false` or `nil`):

```lua
-- Safe: both branches are truthy strings
local label = is_plural and "items" or "item"
local status = success and "ok" or "failed"
```

When either branch could be `false` or `nil`, use `if`/`else` instead:

```lua
-- BROKEN: returns "default" even when condition is true
local x = true and false or "default"  --> "default"

-- Correct: use if/else when branches can be falsy
local x
if condition then
    x = false
else
    x = "default"
end
```

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

### Numeric for with step

```lua
-- Count down
for i = 10, 1, -1 do
    print(i)
end
```

---

## 11. Things to Avoid

### Global variables

**Never use globals.** Always declare variables with `local`. Globals are the
single most common source of bugs in Lua code:

```lua
-- Bad: creates a global
count = 0

-- Good: local variable
local count = 0
```

Use Luacheck to catch accidental globals (warning codes 111, 112, 113).

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
as a parameter name to prevent confusion across Lua versions.

### Relying on `#` with non-sequence tables

The length operator `#` is only defined for sequence tables. Using it on tables
with `nil` holes or non-integer keys produces undefined results.

### Comparing with `==` on tables

`==` on tables compares **identity** (same reference), not structural equality.
To compare table contents, write a deep-equality function or use a testing
library.

### Using `rawget`/`rawset` outside metamethods

`rawget` and `rawset` bypass metatables. Their primary legitimate use is inside
`__index` and `__newindex` metamethods to avoid infinite recursion. Using them
elsewhere to bypass metatable behavior (e.g., circumventing `__newindex`
validation from outside the class) breaks the abstraction the metatable
provides and makes the code fragile.

---

## 12. Tooling

### Luacheck

[Luacheck](https://luacheck.readthedocs.io/en/stable/) is the standard Lua
linter. It detects:

- Accidental global variables (read and write)
- Unused local variables and values
- Unreachable code
- Shadowed variables
- Line length violations
- Unbalanced assignments

**Installation:**

```sh
luarocks install luacheck
```

**Configuration** via `.luacheckrc` at the project root:

```lua
-- .luacheckrc
std = "lua51"
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

### StyLua

[StyLua](https://github.com/JohnnyMorganz/StyLua) is an opinionated Lua code
formatter inspired by rustfmt/prettier. It enforces consistent indentation,
spacing, and line length. It is the most actively maintained Lua formatter.

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

### Automated checks (Luacheck verifiable)

- [ ] All variables are `local` (no accidental globals)
- [ ] No unused variables or arguments (without justification)
- [ ] No unreachable code
- [ ] No shadowed variables (without justification)
- [ ] Lines within length limit
- [ ] Luacheck passes with zero warnings

### Manual review

- [ ] All `require` calls are at the top of the file (lazy requires have
  justification comments)
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
- [ ] No `or` used for boolean parameter defaults
- [ ] UTF-8 locale strings handled with safe operations only

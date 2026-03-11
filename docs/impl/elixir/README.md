# Elixir Style Guide

A comprehensive style guide for auditing Elixir implementations. Covers idiomatic conventions, formatting, patterns, and tooling based on the official Elixir guides, the community style guide, and Credo's static analysis rules.

## Table of Contents

- [1. Naming Conventions](#1-naming-conventions)
- [2. Code Formatting](#2-code-formatting)
- [3. Pattern Matching](#3-pattern-matching)
- [4. Module Design](#4-module-design)
- [5. Data Structures](#5-data-structures)
- [6. Error Handling](#6-error-handling)
- [7. Functional Patterns](#7-functional-patterns)
- [8. Testing](#8-testing)
- [9. Common Idioms](#9-common-idioms)
- [10. Things to Avoid](#10-things-to-avoid)
- [11. Tooling](#11-tooling)
- [Sources](#sources)

---

## 1. Naming Conventions

### Modules

Use `CamelCase`. Preserve uppercase for acronyms.

```elixir
# Good
defmodule MyApp.HTTPClient do
defmodule MyApp.XMLParser do
defmodule ExUnit.CaptureIO do

# Bad
defmodule MyApp.HttpClient do
defmodule MyApp.Xml_Parser do
```

Filenames mirror the module name in `snake_case`. A module `MyApp.HTTPClient` lives in `my_app/http_client.ex`. Nested modules map to directory structures: `Parser.Core.XMLParser` lives at `parser/core/xml_parser.ex`.

### Functions and Variables

Use `snake_case` for all function names, variable names, and module attributes.

```elixir
# Good
def calculate_age(date_of_birth, as_of) do
  total_days = Date.diff(as_of, date_of_birth)
  ...
end

# Bad
def calculateAge(dateOfBirth, asOf) do
def calculate-age(date_of_birth, as_of) do
```

### Atoms

Use `snake_case` for atoms.

```elixir
# Good
:ok
:error
:not_found
:date_of_birth

# Bad
:notFound
:DateOfBirth
```

### Trailing `?` (Question Mark)

Functions that return a boolean use a trailing `?`.

```elixir
def valid?(date), do: ...
def leap_year?(year), do: ...
String.contains?(string, "hello")
Keyword.keyword?(term)
```

### Trailing `!` (Bang)

Functions that raise on failure use a trailing `!`. They typically pair with a non-bang variant that returns `{:ok, value}` or `{:error, reason}`.

```elixir
# Non-bang: returns {:ok, value} or {:error, reason}
File.read("path")     # => {:ok, contents} | {:error, reason}

# Bang: returns value or raises
File.read!("path")    # => contents | raises File.Error
```

### `is_` Prefix

Guard-safe boolean functions use the `is_` prefix. This convention signals that the function can be used in guard clauses.

```elixir
defguard is_even(value) when is_integer(value) and rem(value, 2) == 0

# Usage in a function head
def process(n) when is_even(n), do: ...
```

### Underscore Prefix

Prefix unused variables with `_` to suppress compiler warnings. Prefix functions with `_` to signal they should never be imported.

```elixir
# Unused variable
def handle({:ok, _result}), do: :ok

# Named but unused (documents what the value represents)
def handle({:ok, _user_count}), do: :ok

# Private-by-convention function (never imported by default)
def _internal_helper, do: ...
```

### Semantic Name Conventions

The standard library uses specific naming patterns with precise semantic meaning:

| Pattern    | Meaning                              | Example                  |
|------------|--------------------------------------|--------------------------|
| `size`     | O(1) constant time                   | `map_size/1`             |
| `length`   | O(n) linear time                     | `String.length/1`        |
| `get`      | Returns default/nil if key absent    | `Map.get/3`              |
| `fetch`    | Returns `{:ok, val}` or `:error`     | `Map.fetch/2`            |
| `fetch!`   | Returns value or raises              | `Map.fetch!/2`           |
| `compare`  | Returns `:lt`, `:eq`, or `:gt`       | `Date.compare/2`         |

---

## 2. Code Formatting

### mix format

`mix format` is the authoritative formatter for all Elixir code. Configure it in `.formatter.exs`:

```elixir
# .formatter.exs
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 98
]
```

Run `mix format` before every commit. Never override it with manual formatting. The formatter handles:

- Indentation (2 spaces, no tabs)
- Trailing whitespace removal
- Consistent parenthesization
- Operator spacing
- Collection formatting

### Line Length

The default line length is 98 characters. Configure via `:line_length` in `.formatter.exs`. Locale data files with long lines are an expected exception.

### Indentation

Two spaces. No tabs. No exceptions.

```elixir
def format_age(date_of_birth, as_of, locale) do
  days = Date.diff(as_of, date_of_birth)
  months = div(days, 30)
  years = div(days, 365)

  cond do
    days < 14 -> locale.just_born
    days < 60 -> format_weeks(days, locale)
    months < 24 -> format_months(months, locale)
    true -> format_years(years, months, locale)
  end
end
```

### Pipe Operator Formatting

When chaining with `|>`, place each step on its own line with consistent indentation:

```elixir
# Good
date_of_birth
|> Date.diff(as_of)
|> div(30)
|> format_months(locale)

# Bad — single pipe (just use a function call)
date_of_birth |> Date.diff(as_of)

# Instead write:
Date.diff(as_of, date_of_birth)
```

### Parentheses

Always include parentheses in function calls. Omit them only for zero-argument function definitions and macros where convention dictates (e.g., `defstruct`, `use`, `import`, `alias`, `require`).

```elixir
# Good
String.downcase(name)
Enum.map(list, &String.upcase/1)

# Good — zero-arity definitions omit parens
def version, do: "1.0.0"

# Good — macros conventionally omit parens
use ExUnit.Case, async: true
import MyModule
alias MyApp.Formatter
```

Always use parentheses for zero-arity function *calls* to distinguish them from variables:

```elixir
# Good — clearly a function call
version()

# Ambiguous — is this a variable or a function?
version
```

### Multiline Collections

Opening bracket stays on the same line. Each element on its own line. Closing bracket on its own line.

```elixir
locale = %AgeLocale{
  just_born: "just born",
  week: "week",
  weeks: "weeks",
  month: "month",
  months: "months"
}

stages = [
  {:weeks, 2, 8},
  {:months, 2, 24},
  {:years, 2, nil}
]
```

### Blank Lines

- Separate function definitions with a blank line.
- No blank line immediately after `defmodule`.
- One blank line after `@moduledoc`.
- Separate logical groups within a module with blank lines.
- Group single-line function clauses together without blank lines between them.

```elixir
defmodule Formatter do
  @moduledoc "Formats ages the way humans speak."

  def format(:weeks, 1, locale), do: "1 #{locale.week}"
  def format(:weeks, n, locale), do: "#{n} #{locale.weeks}"
  def format(:months, 1, locale), do: "1 #{locale.month}"
  def format(:months, n, locale), do: "#{n} #{locale.months}"

  def format(:years, n, half, locale) do
    base = "#{n} #{locale.years}"
    if half, do: "#{base}#{locale.half}", else: base
  end
end
```

---

## 3. Pattern Matching

### Function Heads

Use multiple function clauses instead of branching inside a single function body. Each clause handles one case.

```elixir
# Good — multiple clauses
def pluralize(1, singular, _plural), do: "1 #{singular}"
def pluralize(n, _singular, plural), do: "#{n} #{plural}"

# Bad — branching inside a single body
def pluralize(n, singular, plural) do
  if n == 1 do
    "1 #{singular}"
  else
    "#{n} #{plural}"
  end
end
```

### Destructuring

Pattern match directly in function arguments to extract values:

```elixir
# Good — destructure in the argument
def format_locale(%{just_born: just_born, week: week}) do
  ...
end

# Good — destructure a tuple
def handle_result({:ok, value}), do: value
def handle_result({:error, reason}), do: raise(reason)

# Good — head | tail
def first([head | _tail]), do: head
```

### case / cond / with

Use `case` when matching a single value against multiple patterns:

```elixir
case Date.compare(date_of_birth, as_of) do
  :lt -> calculate_age(date_of_birth, as_of)
  :eq -> locale.just_born
  :gt -> {:error, :future_date}
end
```

Use `cond` when evaluating multiple independent boolean conditions:

```elixir
cond do
  days < 14 -> locale.just_born
  days < 60 -> format_weeks(days, locale)
  months < 24 -> format_months(months, locale)
  true -> format_years(years, months, locale)
end
```

Use `with` to chain operations that may fail, flattening nested `case` expressions:

```elixir
with {:ok, dob} <- parse_date(dob_string),
     {:ok, as_of} <- parse_date(as_of_string),
     :lt <- Date.compare(dob, as_of) do
  {:ok, format_age(dob, as_of, locale)}
else
  :gt -> {:error, :future_date}
  :eq -> {:ok, locale.just_born}
  {:error, reason} -> {:error, reason}
end
```

### Guard Clauses

Guards add conditions beyond what pattern matching alone can express. Use `when` in function heads, `case` clauses, and custom guards.

```elixir
def format_weeks(days, locale) when days >= 14 and days < 60 do
  weeks = div(days, 7)
  pluralize(weeks, locale.week, locale.weeks)
end

case value do
  n when is_integer(n) and n > 0 -> :positive
  n when is_integer(n) and n < 0 -> :negative
  0 -> :zero
end
```

Only a limited set of expressions is allowed in guards: comparison operators, arithmetic, boolean operators, type-check functions (`is_integer/1`, `is_binary/1`, etc.), and a few standard library functions. Arbitrary function calls are not permitted.

Define custom guards with `defguard` / `defguardp`:

```elixir
defguard is_adult(age) when is_integer(age) and age >= 18
```

### Pin Operator

Use `^` to match against an existing binding rather than rebinding:

```elixir
expected_locale = :en
%{locale: ^expected_locale} = config  # Matches only if locale is :en
```

The pin operator is essential in `case`, `with`, and function heads when you need to match a computed value:

```elixir
target = :en

case Map.fetch(locales, code) do
  {:ok, ^target} -> :found_target
  {:ok, other} -> {:found_other, other}
  :error -> :not_found
end
```

---

## 4. Module Design

### Module Structure

Follow this ordering within a module:

```elixir
defmodule MyApp.AgeFormatter do
  @moduledoc """
  Formats human ages the way people actually speak.
  """

  # 1. Behaviours
  @behaviour MyApp.Formatter

  # 2. use / import / require / alias (alphabetical within each group)
  use GenServer
  import MyApp.PluralRules
  require Logger
  alias MyApp.AgeLocale
  alias MyApp.Types

  # 3. Module attributes
  @default_locale :en
  @max_age 150

  # 4. Struct definition
  defstruct [:name, :value, locale: :en]

  # 5. Type definitions
  @type t :: %__MODULE__{
    name: String.t(),
    value: non_neg_integer(),
    locale: atom()
  }

  @type age_result :: {:ok, String.t()} | {:error, atom()}

  # 6. Callback implementations
  @impl true
  def format(data), do: ...

  # 7. Public functions
  def format_age(dob, as_of, locale \\ @default_locale) do
    ...
  end

  # 8. Private functions
  defp calculate_days(dob, as_of) do
    ...
  end
end
```

### @moduledoc

Every public module must have a `@moduledoc`. Place it immediately after `defmodule`. Use `@moduledoc false` for intentionally undocumented internal modules.

```elixir
defmodule MyApp.Internal.Helper do
  @moduledoc false
  ...
end
```

### @doc

Document every public function. Use heredoc strings with Markdown. Include an `## Examples` section with `iex>` doctests when the function is side-effect-free.

```elixir
@doc """
Formats an age as a human-readable string.

Returns the age formatted according to the given locale's conventions,
using the same phrasing a parent would use.

## Examples

    iex> format_age(~D[2020-01-15], ~D[2020-03-15], :en)
    "2 months"

    iex> format_age(~D[2020-01-15], ~D[2020-01-15], :en)
    "just born"
"""
@spec format_age(Date.t(), Date.t(), atom()) :: String.t()
def format_age(date_of_birth, as_of, locale) do
  ...
end
```

### @spec

Write a `@spec` for every public function. Place it directly before the function definition, after `@doc`, with no blank line between `@spec` and `def`.

```elixir
@doc "Calculates the number of complete weeks."
@spec weeks(Date.t(), Date.t()) :: non_neg_integer()
def weeks(from, to) do
  div(Date.diff(to, from), 7)
end
```

Use meaningful type names and custom `@type` definitions for domain concepts:

```elixir
@type locale_code :: atom()
@type age_string :: String.t()

@spec format_age(Date.t(), Date.t(), locale_code()) :: age_string()
```

### Behaviours

Define a behaviour to specify a contract that multiple modules must implement:

```elixir
defmodule MyApp.Formatter do
  @callback format(term()) :: String.t()
  @callback supported_locales() :: [atom()]
  @optional_callbacks supported_locales: 0
end
```

Annotate implementations with `@impl true` (or `@impl ModuleName` for explicitness):

```elixir
defmodule MyApp.AgeFormatter do
  @behaviour MyApp.Formatter

  @impl MyApp.Formatter
  def format(data), do: ...
end
```

### Protocols

Use protocols for type-based polymorphism. Prefer protocols over behaviours when the dispatch is based on data type.

```elixir
defprotocol Formattable do
  @doc "Formats the value as a human-readable string."
  @spec format(t()) :: String.t()
  def format(value)
end

defimpl Formattable, for: Date do
  def format(date), do: Date.to_iso8601(date)
end
```

### Alias and Import Guidelines

- Use `alias` to shorten frequently-referenced module names.
- Use `import` sparingly --- only when you call the imported functions many times and the origin is obvious from context.
- Prefer `alias` over `import` for clarity.
- Use `require` only when you need macros from another module.
- Sort each group (`alias`, `import`, `require`) alphabetically.

```elixir
# Good — alias for clarity
alias MyApp.AgeLocale
AgeLocale.new(:en)

# Acceptable — importing well-known functions used heavily
import MyApp.PluralRules, only: [pluralize: 3]

# Bad — wildcard import obscures origins
import MyApp.Helpers
```

---

## 5. Data Structures

### When to Use Which

| Structure      | Use When                                                         |
|----------------|------------------------------------------------------------------|
| **Tuple**      | Fixed-size, positional data. Return values (`{:ok, val}`).       |
| **List**       | Ordered, variable-length, homogeneous collections.               |
| **Keyword List** | Ordered key-value pairs, duplicate keys allowed. Function opts. |
| **Map**        | Key-value lookup with unique keys. Dynamic keys.                 |
| **Struct**     | Typed maps with known fields and compile-time validation.        |

### Tuples

Use tuples for fixed-size, positional data. The most common pattern is tagged tuples for return values:

```elixir
{:ok, "2 months"}
{:error, :invalid_date}
{:ok, value} = some_function()
```

Do not use tuples as variable-length collections. Use lists instead.

### Lists

Lists are linked lists, efficient for prepending and sequential access:

```elixir
# Prepend (O(1))
[head | tail]

# Pattern match
[first, second | rest] = [1, 2, 3, 4, 5]
# first = 1, second = 2, rest = [3, 4, 5]
```

### Keyword Lists

Keyword lists are lists of `{atom, value}` tuples. Use them for function options and when key order matters or duplicate keys are needed.

```elixir
# These are equivalent
[name: "en", code: :en]
[{:name, "en"}, {:code, :en}]

# Common use: function options
def format(value, opts \\ []) do
  locale = Keyword.get(opts, :locale, :en)
  ...
end
```

Omit the brackets when a keyword list is the last argument to a function:

```elixir
# Good
String.split(string, trim: true)

# Unnecessary brackets
String.split(string, [trim: true])
```

### Maps

Use maps for key-value data with unique keys:

```elixir
# Atom keys (shorthand syntax)
%{name: "English", code: :en}

# Non-atom keys (arrow syntax)
%{"en" => english_locale, "fr" => french_locale}

# Do not mix syntaxes
# Bad
%{:name => "English", code: :en}
```

Update maps with the `|` syntax:

```elixir
updated = %{locale | name: "British English"}
```

The `|` syntax raises if the key does not exist. Use `Map.put/3` for new keys.

### Structs

Use structs for data with a known set of fields. Structs provide compile-time field validation and clear documentation of shape.

```elixir
defmodule AgeLocale do
  @enforce_keys [:code]
  defstruct [
    :code,
    :just_born,
    week: "week",
    weeks: "weeks",
    month: "month",
    months: "months"
  ]

  @type t :: %__MODULE__{
    code: atom(),
    just_born: String.t(),
    week: String.t(),
    weeks: String.t(),
    month: String.t(),
    months: String.t()
  }
end
```

List bare atom fields (defaulting to `nil`) before keyword pairs with explicit defaults:

```elixir
# Good
defstruct [:name, :email, role: :user, active: true]

# Bad — atom fields after keyword pairs
defstruct [role: :user, :name, :email]
```

Use `@enforce_keys` to require fields at struct creation time:

```elixir
@enforce_keys [:code, :just_born]
defstruct [:code, :just_born, half: ""]
```

Pattern match on structs for type-checked destructuring:

```elixir
def format(%AgeLocale{just_born: just_born} = locale) do
  ...
end
```

---

## 6. Error Handling

### ok/error Tuples

The standard pattern for functions that can fail. Return `{:ok, value}` on success and `{:error, reason}` on failure.

```elixir
def parse_date(string) do
  case Date.from_iso8601(string) do
    {:ok, date} -> {:ok, date}
    {:error, _} -> {:error, :invalid_date}
  end
end
```

### Bang Functions

Provide a `!` variant that raises instead of returning an error tuple. Use the bang version when failure is unexpected and should crash the process.

```elixir
def parse_date!(string) do
  case parse_date(string) do
    {:ok, date} -> date
    {:error, reason} -> raise ArgumentError, "invalid date: #{reason}"
  end
end
```

### with Statement

Use `with` to chain multiple operations that each return `{:ok, value}` or `{:error, reason}`:

```elixir
def process(params) do
  with {:ok, dob} <- parse_date(params.dob),
       {:ok, as_of} <- parse_date(params.as_of),
       {:ok, locale} <- fetch_locale(params.locale) do
    {:ok, format_age(dob, as_of, locale)}
  end
end
```

When non-matching values fall through, the `with` returns the first non-matching result. Add an `else` clause only when you need to normalize or transform error values:

```elixir
with {:ok, dob} <- parse_date(params.dob),
     {:ok, as_of} <- parse_date(params.as_of) do
  {:ok, format_age(dob, as_of)}
else
  {:error, :invalid_date} -> {:error, "date must be in ISO 8601 format"}
  {:error, reason} -> {:error, "unexpected error: #{reason}"}
end
```

### raise vs. throw

- **`raise`** is for exceptional, unexpected errors (programming mistakes, violated invariants). Rescue with `try/rescue`.
- **`throw`** is for flow control in rare cases where no better alternative exists. Catch with `try/catch`. Almost never needed in well-designed code.
- **Prefer ok/error tuples** over exceptions for expected failure modes.

```elixir
# raise for invariant violations
def format_age(dob, as_of, _locale) when as_of < dob do
  raise ArgumentError, "as_of date must not precede date_of_birth"
end

# ok/error for expected failures
def fetch_locale(code) do
  case Map.fetch(@locales, code) do
    {:ok, locale} -> {:ok, locale}
    :error -> {:error, :unknown_locale}
  end
end
```

### Exception Naming

Name custom exceptions with a trailing `Error`. Use lowercase error messages without trailing punctuation.

```elixir
defmodule MyApp.LocaleError do
  defexception [:message]
end

raise MyApp.LocaleError, message: "unknown locale code"
```

---

## 7. Functional Patterns

### Pipe Operator

The pipe operator `|>` passes the result of the left expression as the first argument to the right function. Use it to express data transformation pipelines.

```elixir
# Good — clear transformation pipeline
date_of_birth
|> Date.diff(as_of)
|> div(7)
|> format_weeks(locale)

# Bad — single pipe (just call the function)
value |> String.downcase()
# Better:
String.downcase(value)

# Bad — bare value not at the start
String.downcase(value) |> String.trim()
# Better:
value
|> String.downcase()
|> String.trim()
```

Always use parentheses on functions in a pipe chain, even for zero-arity functions:

```elixir
# Good
list
|> Enum.sort()
|> Enum.reverse()

# Bad — ambiguous without parens
list
|> Enum.sort
|> Enum.reverse
```

### Enum vs. Stream

**Enum** is eager --- each function produces a complete intermediate collection:

```elixir
# Processes the full list at each step
1..100_000
|> Enum.map(&(&1 * 3))
|> Enum.filter(&(rem(&1, 2) == 1))
|> Enum.sum()
```

**Stream** is lazy --- builds a pipeline of computations, evaluated only when consumed:

```elixir
# No intermediate lists; processes elements one at a time
1..100_000
|> Stream.map(&(&1 * 3))
|> Stream.filter(&(rem(&1, 2) == 1))
|> Enum.sum()
```

Use `Stream` when:
- Working with large or potentially infinite collections.
- Reading from files or slow I/O sources.
- You only need a subset of results.

Use `Enum` when:
- The collection is small to medium-sized.
- You need the full result immediately.
- Code clarity matters more than memory optimization.

### Comprehensions

Use `for` comprehensions as concise alternatives to `Enum.map` + `Enum.filter`:

```elixir
# Comprehension with generator and filter
for {code, locale} <- locales, locale.complete? do
  {code, format_name(locale)}
end

# Comprehension with :into to produce a map
for {code, locale} <- locales, into: %{} do
  {code, normalize(locale)}
end

# Multiple generators (cartesian product)
for lang <- languages, locale <- locales do
  {lang, locale}
end
```

Pattern matching in generators acts as an implicit filter --- non-matching elements are silently skipped:

```elixir
for {:ok, value} <- results do
  value
end
```

### Recursion

Use recursion for custom iteration, especially with accumulators. Prefer tail-recursive functions with accumulators for linear processing:

```elixir
# Tail-recursive with accumulator
def sum(list), do: sum(list, 0)

defp sum([], acc), do: acc
defp sum([head | tail], acc), do: sum(tail, acc + head)
```

Prefer `Enum` functions over hand-written recursion when a standard function exists:

```elixir
# Good — use the standard library
Enum.sum(list)
Enum.map(list, &transform/1)

# Unnecessary — hand-rolling what Enum already provides
def map([], _fun), do: []
def map([h | t], fun), do: [fun.(h) | map(t, fun)]
```

### Anonymous Functions

Use the capture operator `&` for short, simple anonymous functions:

```elixir
# Good — capture syntax
Enum.map(list, &String.upcase/1)
Enum.map(list, &(&1 * 2))

# Good — explicit fn for multi-line or complex logic
Enum.map(list, fn item ->
  item
  |> normalize()
  |> format()
end)

# Bad — fn for trivial operations
Enum.map(list, fn x -> x * 2 end)
```

---

## 8. Testing

### ExUnit Setup

Tests live in the `test/` directory. Filenames end in `_test.exs`. Each test module uses `ExUnit.Case`.

```elixir
defmodule MyApp.FormatterTest do
  use ExUnit.Case, async: true

  test "formats newborn age" do
    assert format_age(~D[2024-01-15], ~D[2024-01-15], :en) == "just born"
  end
end
```

Enable `async: true` for test modules that have no shared mutable state. Tests within a module run serially, but async modules run concurrently with other async modules.

### describe Blocks

Group related tests with `describe`. The description typically names the function being tested:

```elixir
describe "format_age/3" do
  test "returns 'just born' for same date" do
    assert format_age(~D[2024-01-01], ~D[2024-01-01], :en) == "just born"
  end

  test "formats weeks for 2-8 week range" do
    assert format_age(~D[2024-01-01], ~D[2024-01-22], :en) == "3 weeks"
  end

  test "formats months for 2-24 month range" do
    assert format_age(~D[2024-01-01], ~D[2024-04-01], :en) == "3 months"
  end
end
```

`describe` blocks cannot be nested.

### Assertions

Use `assert` for truthy checks, `refute` for falsy checks, and pattern matching for structured values:

```elixir
# Value equality
assert result == "3 weeks"

# Pattern matching (note: pattern on the left)
assert {:ok, _value} = some_function()

# Boolean
assert valid?(date)
refute expired?(token)

# Exception
assert_raise ArgumentError, fn ->
  format_age(~D[2024-06-01], ~D[2024-01-01], :en)
end

# Exception with message
assert_raise ArgumentError, "as_of must not precede date_of_birth", fn ->
  format_age(~D[2024-06-01], ~D[2024-01-01], :en)
end
```

Put the expression under test on the left and the expected value on the right, unless the assertion is a pattern match (where the pattern must be on the left):

```elixir
# Good — expression on the left
assert format_age(dob, as_of, :en) == "3 weeks"

# Good — pattern match (pattern must be on left)
assert {:ok, result} = process(params)

# Bad — expected on the left
assert "3 weeks" == format_age(dob, as_of, :en)
```

### Setup Callbacks

Use `setup` for per-test initialization. Use `setup_all` for one-time module initialization.

```elixir
describe "format_age/3 with English locale" do
  setup do
    locale = MyApp.Locales.get(:en)
    {:ok, locale: locale}
  end

  test "formats weeks", %{locale: locale} do
    assert format_age(~D[2024-01-01], ~D[2024-01-22], locale) == "3 weeks"
  end
end
```

### Doctests

Enable doctests for a module by adding `doctest ModuleName` to a test module:

```elixir
defmodule MyApp.FormatterTest do
  use ExUnit.Case, async: true
  doctest MyApp.Formatter
end
```

Doctest examples in `@doc` must use the `iex>` prompt:

```elixir
@doc """
Pluralizes a unit.

## Examples

    iex> MyApp.Formatter.pluralize(1, "week", "weeks")
    "1 week"

    iex> MyApp.Formatter.pluralize(3, "week", "weeks")
    "3 weeks"
"""
```

### Tags

Use tags to categorize tests, control timeouts, or skip tests:

```elixir
@tag :slow
test "processes all locales" do
  ...
end

@tag timeout: 120_000
test "handles large dataset" do
  ...
end

@tag :skip
test "not yet implemented" do
  ...
end
```

Filter on the command line: `mix test --only slow` or `mix test --exclude slow`.

---

## 9. Common Idioms

### defstruct

Always define a `@type t` alongside `defstruct` to document the struct's shape:

```elixir
defmodule AgeLocale do
  @enforce_keys [:code, :just_born]
  defstruct [:code, :just_born, half: "", delimiter: " "]

  @type t :: %__MODULE__{
    code: atom(),
    just_born: String.t(),
    half: String.t(),
    delimiter: String.t()
  }
end
```

### @type

Define custom types to document domain concepts and improve `@spec` readability:

```elixir
@type locale_code :: atom()
@type days :: non_neg_integer()
@type age_string :: String.t()
@type plural_category :: :one | :two | :few | :many | :other
```

Use `@typep` for private types (internal to the module) and `@opaque` for types whose internal structure should be hidden from callers.

### Guards

Combine built-in guards for expressive function dispatch:

```elixir
def format(n, locale) when is_integer(n) and n >= 0 do
  ...
end

# Custom guard
defguard is_valid_age(days) when is_integer(days) and days >= 0
```

Allowed expressions in guards include:
- Comparison: `==`, `!=`, `===`, `!==`, `<`, `>`, `<=`, `>=`
- Arithmetic: `+`, `-`, `*`, `/`, `div`, `rem`, `abs`
- Boolean: `and`, `or`, `not`, `!`
- Type checks: `is_atom/1`, `is_binary/1`, `is_integer/1`, `is_float/1`, `is_list/1`, `is_map/1`, `is_tuple/1`, `is_nil/1`, `is_boolean/1`, `is_number/1`
- Other: `in/2`, `length/1`, `map_size/1`, `tuple_size/1`, `hd/1`, `tl/1`, `elem/2`, `byte_size/1`, `bit_size/1`

### Sigils

Use sigils for concise literal construction:

```elixir
# Regex
~r/^\d{4}-\d{2}-\d{2}$/

# Word list (strings)
~w(en fr de es pt ja zh)

# Word list (atoms)
~w(en fr de es pt ja zh)a

# String with special characters (no escaping needed)
~s(string with "quotes" inside)

# Calendar types
~D[2024-01-15]
~T[14:30:00]
~N[2024-01-15 14:30:00]
~U[2024-01-15 14:30:00Z]
```

Uppercase sigils disable interpolation and escape sequences:

```elixir
~s(hello #{name})    # => "hello world"  (interpolated)
~S(hello #{name})    # => "hello \#{name}"  (literal)
```

### String Interpolation

Prefer interpolation over concatenation:

```elixir
# Good
"#{count} #{unit}"

# Bad
Integer.to_string(count) <> " " <> unit
```

### __MODULE__

Use `__MODULE__` to refer to the current module. This survives renaming:

```elixir
defmodule MyApp.AgeFormatter do
  defstruct [:locale]

  @type t :: %__MODULE__{locale: atom()}

  def new(locale), do: %__MODULE__{locale: locale}
end
```

### Multiclause Functions with Default Arguments

Define a function head (no body) for default arguments, then pattern match in the clauses:

```elixir
def format(date_of_birth, as_of, locale \\ :en)

def format(date_of_birth, as_of, locale) when is_atom(locale) do
  ...
end

def format(date_of_birth, as_of, %AgeLocale{} = locale) do
  ...
end
```

---

## 10. Things to Avoid

### Unnecessary Macros

Do not use macros when a function suffices. Macros are harder to read, debug, and test. Reserve them for genuine compile-time code generation and DSLs.

```elixir
# Bad — macro for something a function handles fine
defmacro double(x) do
  quote do: unquote(x) * 2
end

# Good — just use a function
def double(x), do: x * 2
```

### Deep Nesting

Flatten nested `case`/`if` blocks using `with`, pattern matching in function heads, or early returns via multiple clauses.

```elixir
# Bad — deeply nested
def process(params) do
  case parse_date(params.dob) do
    {:ok, dob} ->
      case parse_date(params.as_of) do
        {:ok, as_of} ->
          case fetch_locale(params.locale) do
            {:ok, locale} -> {:ok, format_age(dob, as_of, locale)}
            error -> error
          end
        error -> error
      end
    error -> error
  end
end

# Good — flat with `with`
def process(params) do
  with {:ok, dob} <- parse_date(params.dob),
       {:ok, as_of} <- parse_date(params.as_of),
       {:ok, locale} <- fetch_locale(params.locale) do
    {:ok, format_age(dob, as_of, locale)}
  end
end
```

### Ignoring Pattern Matching Opportunities

Use pattern matching instead of accessor calls or conditional branching.

```elixir
# Bad — accessor then conditional
def handle(result) do
  if elem(result, 0) == :ok do
    elem(result, 1)
  else
    raise "error"
  end
end

# Good — pattern match
def handle({:ok, value}), do: value
def handle({:error, reason}), do: raise(reason)
```

### unless with else

Never use `unless` with an `else` block. Rewrite with `if`:

```elixir
# Bad
unless valid?(date) do
  :invalid
else
  :valid
end

# Good
if valid?(date) do
  :valid
else
  :invalid
end
```

### Negated Conditions in if

Prefer `unless` over `if !condition` for simple negative checks:

```elixir
# Bad
if !valid?(date), do: :invalid

# Good
unless valid?(date), do: :invalid
```

But do not use `unless` with `else` or with complex conditions. In those cases, `if` is clearer.

### do_name Private Functions

Do not name private functions `do_<public_name>`. Use a more descriptive name that communicates the function's distinct purpose.

```elixir
# Bad
def format(data), do: do_format(data, [])
defp do_format(data, acc), do: ...

# Good
def format(data), do: build_output(data, [])
defp build_output(data, acc), do: ...
```

### Bare map/struct access on untrusted data

Use `Map.get/3` or `Map.fetch/2` instead of `map.key` when the key might not exist:

```elixir
# Raises KeyError if :locale is absent
config.locale

# Returns nil or default safely
Map.get(config, :locale, :en)
```

### Large Modules

If a module exceeds ~300 lines, consider extracting logically distinct sections into separate modules. A module should have a single, clear responsibility.

---

## 11. Tooling

### mix format

The built-in code formatter. Non-negotiable for all Elixir projects.

```bash
# Format all files
mix format

# Check without modifying (CI mode)
mix format --check-formatted

# Format a specific file
mix format lib/my_app/formatter.ex
```

Configuration in `.formatter.exs`:

```elixir
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 98,
  import_deps: [:ecto],
  locals_without_parens: [assert: 1, refute: 1]
]
```

### Credo

A static analysis tool focused on code consistency and teaching. It checks five categories:

| Category       | Focus                                           |
|----------------|--------------------------------------------------|
| **Consistency** | Tabs vs. spaces, spacing, line endings           |
| **Readability** | Naming, line length, module docs, complexity     |
| **Refactoring** | Nesting depth, redundant operations, simplification |
| **Warning**     | Debug code, unsafe patterns, unused return values |
| **Design**      | Alias usage, TODO/FIXME tags, module dependencies |

```bash
# Run all checks
mix credo

# Strict mode (includes low-priority checks)
mix credo --strict

# Check a specific file
mix credo lib/my_app/formatter.ex

# Generate config
mix credo gen.config
```

Configuration in `.credo.exs`:

```elixir
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: []
      },
      checks: %{
        enabled: [
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Readability.MaxLineLength, [max_length: 120]},
          {Credo.Check.Refactor.Nesting, [max_nesting: 3]}
        ]
      },
      strict: false
    }
  ]
}
```

### Dialyzer

A static analysis tool that finds type inconsistencies, unreachable code, and other errors by analyzing typespecs. Use via the `dialyxir` package.

```bash
# Run Dialyzer
mix dialyzer

# Build the PLT (Persistent Lookup Table) — first run only
mix dialyzer --plt
```

Dialyzer uses `@spec` annotations. The more specs you write, the more Dialyzer can catch. Common issues it detects:
- Functions that never return the declared type.
- Pattern matches that can never succeed.
- Calls with arguments of the wrong type.
- Unreachable code branches.

### ExUnit

The built-in test framework. No additional dependencies required.

```bash
# Run all tests
mix test

# Run a specific file
mix test test/formatter_test.exs

# Run a specific test by line number
mix test test/formatter_test.exs:42

# Run with a seed for reproducibility
mix test --seed 12345

# Run only tagged tests
mix test --only slow

# Verbose output (shows each test name)
mix test --trace
```

### mix xref

Analyzes cross-references between modules. Useful for understanding dependencies and finding unused code.

```bash
# Find callers of a function
mix xref callers MyApp.Formatter.format_age/3

# Show the dependency graph
mix xref graph
```

---

## Sources

- [Elixir Official Naming Conventions](https://hexdocs.pm/elixir/naming-conventions.html) --- canonical naming rules from the Elixir team.
- [The Elixir Style Guide (christopheradams)](https://github.com/christopheradams/elixir_style_guide) --- community-maintained style guide with comprehensive formatting and idiom guidelines.
- [Elixir Official Documentation: Writing Documentation](https://hexdocs.pm/elixir/writing-documentation.html) --- @moduledoc, @doc, @spec, and doctest conventions.
- [Elixir Official Documentation: Typespecs](https://hexdocs.pm/elixir/typespecs.html) --- @type, @spec, @callback, and built-in types.
- [Elixir Official Documentation: Pattern Matching](https://hexdocs.pm/elixir/pattern-matching.html) --- match operator, pin operator, destructuring.
- [Elixir Official Documentation: case, cond, and if](https://hexdocs.pm/elixir/case-cond-and-if.html) --- control flow with pattern matching and guards.
- [Elixir Official Documentation: Structs](https://hexdocs.pm/elixir/structs.html) --- defstruct, enforce_keys, struct vs. map.
- [Elixir Official Documentation: Protocols](https://hexdocs.pm/elixir/protocols.html) --- defining and implementing protocols.
- [Elixir Official Documentation: Comprehensions](https://hexdocs.pm/elixir/comprehensions.html) --- for generators, filters, and :into.
- [Elixir Official Documentation: Sigils](https://hexdocs.pm/elixir/sigils.html) --- ~r, ~s, ~w, ~D, ~T, and custom sigils.
- [Elixir Official Documentation: Enumerables and Streams](https://hexdocs.pm/elixir/enumerable-and-streams.html) --- eager vs. lazy evaluation.
- [Kernel.SpecialForms.with/1](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1) --- with statement for chaining matches.
- [ExUnit Documentation](https://hexdocs.pm/ex_unit/ExUnit.html) --- test framework setup and conventions.
- [ExUnit.Case Documentation](https://hexdocs.pm/ex_unit/ExUnit.Case.html) --- describe, setup, tags, async.
- [Mix.Tasks.Format](https://hexdocs.pm/mix/Mix.Tasks.Format.html) --- formatter configuration and usage.
- [Credo Documentation](https://hexdocs.pm/credo/) --- static analysis checks, configuration, and categories.
- [Dialyxir (Dialyzer for Elixir)](https://hexdocs.pm/dialyxir/) --- type-checking via @spec analysis.

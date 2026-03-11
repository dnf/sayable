# Ruby Style Guide

A comprehensive style guide for auditing and writing idiomatic Ruby code. Draws from
community standards, the RuboCop Ruby Style Guide, and Shopify's production conventions.

---

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Class Design](#3-class-design)
4. [Method Design](#4-method-design)
5. [Blocks and Iterators](#5-blocks-and-iterators)
6. [Error Handling](#6-error-handling)
7. [Collections](#7-collections)
8. [String Handling](#8-string-handling)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)
12. [Sources](#12-sources)

---

## 1. Naming Conventions

### Identifiers

| Kind | Convention | Example |
|------|-----------|---------|
| Local variables | `snake_case` | `user_name`, `total_count` |
| Instance variables | `@snake_case` | `@first_name` |
| Class variables | `@@snake_case` | `@@instance_count` (avoid; see Section 10) |
| Global variables | `$snake_case` | `$stdout` (avoid defining new ones) |
| Methods | `snake_case` | `calculate_total`, `format_age` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES`, `DEFAULT_TIMEOUT` |
| Classes / Modules | `PascalCase` | `SayableAge`, `AgeLocale` |
| Symbols | `snake_case` | `:just_born`, `:other` |

### Methods with Special Suffixes

**Predicate methods** end with `?` and return a boolean-like value:

```ruby
def empty?
  @items.length.zero?
end
```

Do not prefix predicates with `is_`, `has_`, `can_`, or `does_`. Write `valid?` not
`is_valid?`, `admin?` not `is_admin?`.

**Bang methods** end with `!` and indicate a "dangerous" variant. A bang method should only
exist when a non-bang counterpart exists. The bang typically means the method mutates the
receiver, raises on failure, or has some other surprising side effect:

```ruby
# Non-bang returns a new array; bang mutates in place.
array.sort    # => new sorted array
array.sort!   # => sorts array in place

# Non-bang returns nil on failure; bang raises.
user.save     # => true/false
user.save!    # => raises on failure
```

Never use `!` on a method that has no safe counterpart.

### File and Directory Names

Use `snake_case` for all file names and directories. Match the file name to the primary
class or module it defines:

```
sayable_age.rb          -> module SayableAge
sayable_age/formatter.rb -> class SayableAge::Formatter
sayable_age/locale.rb    -> SayableAge::AgeLocale (types/structs)
```

### Numbers in Identifiers

Do not separate numbers from letters with underscores:

```ruby
# Good
some_var1
level3_value

# Bad
some_var_1
level_3_value
```

### Acronyms in Class Names

Keep acronyms uppercase in PascalCase names:

```ruby
# Good
HTTPClient
XMLParser
HTMLRenderer

# Bad
HttpClient
XmlParser
```

---

## 2. Code Formatting

### Indentation

Use **two spaces** per indentation level. Never use hard tabs.

```ruby
def format_age(date_of_birth, as_of = nil)
  age = parse_age(date_of_birth, as_of)
  return nil if age.nil?

  months, diff_days = age
  process(months, diff_days)
end
```

### Line Length

Limit lines to **80 characters** (community standard). Some teams allow up to 120, but
never exceed 120. Long locale data lines are an acceptable exception.

### Spacing

Spaces around operators and after commas, colons, and semicolons:

```ruby
# Good
sum = 1 + 2
a, b = 1, 2
{ name: "Ruby", version: 3 }

# Bad
sum=1+2
a,b = 1,2
{name:"Ruby",version:3}
```

No spaces after `(`, `[`, or `!`, and no spaces before `)` or `]`:

```ruby
# Good
method(arg1, arg2)
array[0]
!valid?

# Bad
method( arg1, arg2 )
array[ 0 ]
! valid?
```

No spaces in range literals:

```ruby
# Good
1..10
'a'..'z'

# Bad
1 .. 10
```

Safe navigation operator has no spaces:

```ruby
# Good
user&.name

# Bad
user &. name
```

### Multi-line Method Chains

Use a leading dot on continuation lines, indented one level:

```ruby
result = collection
  .select(&:active?)
  .map(&:name)
  .sort
```

### Multi-line Method Arguments

Indent arguments one level from the method call. Use a trailing comma in multi-line
argument lists:

```ruby
AgeLocale.new(
  code: "en",
  plural: ->(n) { n == 1 ? :one : :other },
  units: units,
  half: "\u00BD",
  delimiter: ", ",
  just_born: "Newborn",
  stages: stages,
)
```

### Frozen String Literal Comment

Always add the frozen string literal magic comment as the first line of every `.rb` file:

```ruby
# frozen_string_literal: true
```

Separate it from the rest of the file with a blank line. This enables string
immutability by default, improving performance and catching accidental mutations.

### Blank Lines

- One blank line between method definitions.
- One blank line after `require` / `require_relative` blocks.
- One blank line after module/class-level `include`, `extend`, `prepend`.
- One blank line after access modifiers (`private`, `protected`, `public`).
- No blank lines at the beginning or end of a class/module/method body.

### End-of-File Newline

Always end files with a single newline character.

---

## 3. Class Design

### Access Control with `attr_*`

Use `attr_reader`, `attr_writer`, and `attr_accessor` instead of hand-written getters
and setters:

```ruby
# Good
class Person
  attr_reader :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end
end

# Bad — manual getters
class Person
  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def first_name
    @first_name
  end
end
```

### Struct for Simple Value Objects

Use `Struct.new` with `keyword_init: true` for simple data-holding classes:

```ruby
AgeLocale = Struct.new(
  :code, :plural, :units, :half, :delimiter, :just_born, :stages,
  keyword_init: true
) do
  def initialize(**kwargs)
    super
    freeze
  end
end
```

Key points:
- Structs provide `==`, `eql?`, `hash`, `to_a`, `to_h` automatically.
- Structs are mutable by default. Call `freeze` in the constructor for immutability.
- Prefer `keyword_init: true` when the struct has more than two or three fields.

### Data for Immutable Value Objects (Ruby 3.2+)

`Data.define` creates immutable value classes. Instances are frozen automatically:

```ruby
Point = Data.define(:x, :y)
p = Point.new(x: 1, y: 2)
p.x  # => 1
# p.x = 3  # => NoMethodError — no setters

# Create modified copies with `with`:
q = p.with(x: 10)  # => Point(x: 10, y: 2)
```

`Data` provides `==`, `eql?`, `hash`, `to_h`, `deconstruct`, and `deconstruct_keys` for
pattern matching. Prefer `Data.define` over `Struct.new` when the object should be
immutable and you are on Ruby 3.2+.

### Comparable

Include `Comparable` and define `<=>` to get `<`, `<=`, `==`, `>=`, `>`, `between?`, and
`clamp` for free:

```ruby
class AgeInMonths
  include Comparable

  attr_reader :months

  def initialize(months)
    @months = months
  end

  def <=>(other)
    @months <=> other.months
  end
end
```

### Visibility

Group methods by visibility. Place `private` (and `protected`, if needed) on its own line,
indented to the class level, with all private methods below it:

```ruby
class Formatter
  def format_age(date_of_birth, as_of = nil)
    # public API
  end

  private

  def parse_age(date_of_birth, as_of)
    # internal logic
  end

  def stage_key(months)
    # internal logic
  end
end
```

### Class Methods

For a small number of class methods, use `def self.method_name`. For many class methods,
use `class << self`:

```ruby
# Few class methods
class SayableAge
  def self.format_age(date_of_birth, as_of = nil)
    @default_formatter ||= Formatter.new(Locales::EN)
    @default_formatter.format_age(date_of_birth, as_of)
  end
end

# Many class methods — group in class << self
module Utilities
  class << self
    def helper_one
      # ...
    end

    def helper_two
      # ...
    end

    private

    def internal_helper
      # ...
    end
  end
end
```

### Modules as Namespaces

Modules serve two purposes: namespacing and mixins. When a module is purely a namespace
(no instances), use `extend self` or `module_function`:

```ruby
module SayableAge
  extend self

  def format_age(date_of_birth, as_of = nil)
    # ...
  end
end
```

### One Class per File

Each file should define one primary class or module. The file name should match the class
name in `snake_case`.

---

## 4. Method Design

### Keep Methods Small

Methods should do one thing. If a method exceeds 10--15 lines, consider extracting helper
methods. Name the extracted method to explain *what* it does, replacing the need for a
comment.

### Implicit Return

Ruby returns the last evaluated expression. Omit explicit `return` at the end of methods:

```ruby
# Good
def full_name
  "#{first_name} #{last_name}"
end

# Bad — unnecessary return
def full_name
  return "#{first_name} #{last_name}"
end
```

Use `return` explicitly for **guard clauses** (early exits):

```ruby
def format_age(date_of_birth, as_of = nil)
  age = parse_age(date_of_birth, as_of)
  return nil if age.nil?

  # ... main logic
end
```

### Keyword Arguments

Prefer keyword arguments over positional arguments when a method has optional parameters
or when the caller benefits from named parameters:

```ruby
# Good — keyword argument with default
def initialize(locale, compactness: :normal)
  @locale = locale
  @compactness = compactness
end

# Bad — positional optional
def initialize(locale, compactness = :normal)
  @locale = locale
  @compactness = compactness
end
```

### Omit `self`

Omit `self` when calling methods on the current object, except when calling a setter or
when `self` is required for disambiguation:

```ruby
# Good
def full_name
  "#{first_name} #{last_name}"
end

# self is required for setters
def reset!
  self.name = "Unknown"
end
```

### Method Parentheses

Include parentheses when a method has arguments. Omit them when it has none:

```ruby
# Good
def format_age(date_of_birth, as_of = nil)
def initialize

# Bad
def format_age date_of_birth, as_of = nil
def initialize()
```

Omit parentheses for DSL-style / declarative methods:

```ruby
attr_reader :name, :code
private
require_relative "sayable_age/locale"
include Comparable
```

### Limit Parameters

Keep method signatures to five or fewer parameters. When you need more, consider a
keyword arguments hash, a configuration object, or breaking the method apart.

---

## 5. Blocks and Iterators

### Brace Style

Use `{ }` for single-line blocks and `do...end` for multi-line blocks:

```ruby
# Single-line
names.map { |name| name.upcase }

# Multi-line
names.each do |name|
  formatted = format(name)
  puts formatted
end
```

### Symbol-to-Proc Shorthand

Use `&:method_name` when a block calls a single method with no arguments:

```ruby
# Good
names.map(&:upcase)
values.select(&:positive?)

# Bad — unnecessarily verbose
names.map { |name| name.upcase }
```

### Prefer Enumerable Methods over Manual Loops

Use `each`, `map`, `select`, `reject`, `reduce`, and friends instead of `for` or `while`:

```ruby
# Good
results = items.map { |item| transform(item) }
active = users.select(&:active?)

# Bad
results = []
for item in items
  results << transform(item)
end
```

### Block vs Proc vs Lambda

| Feature | Block | Proc | Lambda |
|---------|-------|------|--------|
| Object? | No (syntax) | Yes | Yes |
| Arity | Flexible | Flexible | Strict |
| `return` | Returns from enclosing method | Returns from enclosing method | Returns from lambda only |
| Creation | `{ }` or `do...end` | `Proc.new { }` | `->() { }` or `lambda { }` |

Prefer lambdas over procs when you need a callable object, because lambdas check arity
and their `return` behavior is more intuitive:

```ruby
# Good — stabby lambda
pluralize = ->(n) { n == 1 ? :one : :other }

# Calling
pluralize.call(5)  # => :other
pluralize.(5)      # => :other (shorthand)
```

### Capturing Blocks

Use `&block` in the parameter list only when you need to pass the block to another method
or store it. Otherwise, use `yield`:

```ruby
# When you just invoke the block
def with_logging
  puts "Start"
  yield
  puts "End"
end

# When you need to pass it along
def wrap(&block)
  other_method(&block)
end
```

---

## 6. Error Handling

### The Exception Hierarchy

```
Exception
  NoMemoryError
  ScriptError
  SecurityError
  SignalException (includes Interrupt)
  SystemExit
  SystemStackError
  StandardError          <-- rescue catches this by default
    ArgumentError
    IOError
    NameError
    RangeError
    RuntimeError         <-- raise with no class uses this
    TypeError
    ZeroDivisionError
    ...
```

### Raising Exceptions

Use `raise`, not `fail`. Pass the exception class and message as separate arguments:

```ruby
# Good
raise ArgumentError, "date_of_birth must be a string"

# Good — RuntimeError is implied when no class given
raise "something went wrong"

# Bad — explicit RuntimeError
raise RuntimeError, "something went wrong"

# Bad — instantiating the exception
raise ArgumentError.new("date_of_birth must be a string")
```

### Rescuing Exceptions

Rescue specific exception classes, ordered from most specific to most general. A bare
`rescue` (no class) catches `StandardError`:

```ruby
def read_config(path)
  File.read(path)
rescue Errno::ENOENT => e
  warn "Config not found: #{e.message}"
  DEFAULT_CONFIG
rescue IOError => e
  warn "IO error: #{e.message}"
  DEFAULT_CONFIG
end
```

### Implicit Begin in Methods

Use the method body as the implicit `begin` block rather than adding an explicit
`begin...rescue...end`:

```ruby
# Good
def process
  dangerous_operation
rescue SpecificError => e
  handle_error(e)
end

# Bad — unnecessary begin
def process
  begin
    dangerous_operation
  rescue SpecificError => e
    handle_error(e)
  end
end
```

### Custom Exceptions

Inherit from `StandardError`, not `Exception`. Name them with an `Error` suffix:

```ruby
module SayableAge
  class FormatError < StandardError; end
  class LocaleNotFoundError < StandardError; end
end
```

### `retry`

Use `retry` sparingly and always with a counter to prevent infinite loops:

```ruby
def fetch_with_retry(url, max_attempts: 3)
  attempts = 0
  begin
    attempts += 1
    http_get(url)
  rescue Timeout::Error
    retry if attempts < max_attempts
    raise
  end
end
```

### `ensure`

Use `ensure` for cleanup that must happen whether or not an exception was raised. Never
`return` from an `ensure` block (it silently swallows exceptions):

```ruby
def with_temp_file
  file = Tempfile.new("work")
  yield file
rescue => e
  log_error(e)
  raise
ensure
  file&.close
  file&.unlink
end
```

### Do Not Suppress Exceptions Silently

```ruby
# Bad — swallows all errors
begin
  dangerous_operation
rescue StandardError
end

# Good — at minimum, log it
begin
  dangerous_operation
rescue StandardError => e
  logger.warn("Ignored: #{e.message}")
end
```

---

## 7. Collections

### Literal Syntax

Always use literal syntax for arrays and hashes:

```ruby
# Good
arr = []
hash = {}

# Bad
arr = Array.new
hash = Hash.new
```

### Array Shortcuts

```ruby
# Word arrays
%w[day week month year]   # => ["day", "week", "month", "year"]

# Symbol arrays
%i[one other few many]    # => [:one, :other, :few, :many]
```

### Hash Syntax

Use symbol shorthand for symbol keys. Use hash rockets when keys are not symbols:

```ruby
# Good — symbol keys
{ code: "en", half: "\u00BD" }

# Good — non-symbol keys
{ "day" => day_forms, "week" => week_forms }

# Bad — hash rockets with symbol keys
{ :code => "en", :half => "\u00BD" }
```

### Hash Access

Use `fetch` when a missing key is an error or when you need a default:

```ruby
# Raises KeyError if missing
locale.units.fetch("day")

# Returns default if missing
locale.units.fetch("century", "{n} centuries")

# Direct access is fine when nil is acceptable
optional_value = config[:debug]
```

Prefer `key?` over `has_key?`:

```ruby
# Good
hash.key?(:name)

# Bad
hash.has_key?(:name)
```

### Enumerable Methods

Prefer semantic method names:

| Preferred | Avoid |
|-----------|-------|
| `map` | `collect` |
| `select` / `filter` | `find_all` |
| `find` | `detect` |
| `reduce` | `inject` (acceptable but less clear) |
| `include?` | `member?` |
| `size` | `length` (both acceptable; be consistent) |

### Useful Enumerable Methods

```ruby
# filter_map — filter + transform in one pass (Ruby 2.7+)
[1, nil, 3, nil, 5].filter_map { |x| x&.to_s }
# => ["1", "3", "5"]

# tally — count occurrences (Ruby 2.7+)
["a", "b", "a", "c", "a"].tally
# => {"a"=>3, "b"=>1, "c"=>1}

# each_with_object — accumulate without needing to return the accumulator
%w[foo bar baz].each_with_object({}) do |str, hash|
  hash[str] = str.length
end
# => {"foo"=>3, "bar"=>3, "baz"=>3}

# group_by
users.group_by(&:role)
# => { admin: [...], member: [...] }

# flat_map — map + flatten(1)
[[1, 2], [3, 4]].flat_map { |a| a.map { |x| x * 2 } }
# => [2, 4, 6, 8]

# min_by / max_by / sort_by
users.min_by(&:age)
users.sort_by { |u| [u.last_name, u.first_name] }

# chunk / chunk_while — group consecutive elements
[1, 1, 2, 2, 3].chunk { |n| n }.to_a
# => [[1, [1, 1]], [2, [2, 2]], [3, [3]]]
```

### Lazy Enumerators

Use `lazy` for potentially infinite sequences or when you want to avoid materializing
large intermediate arrays:

```ruby
# Process a huge file line by line without loading it all
File.open("huge.log").each_line.lazy
  .select { |line| line.include?("ERROR") }
  .first(10)
```

### Pattern Matching (Ruby 3.0+)

Use `case`/`in` for structural matching against arrays, hashes, and custom objects:

```ruby
case response
in { status: 200, body: String => body }
  process(body)
in { status: 404 }
  handle_not_found
in { status: (500..) }
  handle_server_error
end
```

Pin existing variables with `^`:

```ruby
expected_code = "en"
case locale
in { code: ^expected_code }
  # matches only when code == "en"
end
```

Find patterns search arrays:

```ruby
case items
in [*, { type: "error", message: String => msg }, *]
  warn msg
end
```

### Do Not Mutate During Iteration

```ruby
# Bad — modifying the array while iterating
items.each { |item| items.delete(item) if item.expired? }

# Good — use reject or select
items.reject!(&:expired?)
```

---

## 8. String Handling

### Interpolation over Concatenation

```ruby
# Good
"Hello, #{user.name}! You are #{age} years old."

# Bad
"Hello, " + user.name + "! You are " + age.to_s + " years old."
```

No padding inside interpolation braces:

```ruby
# Good
"#{first_name} #{last_name}"

# Bad
"#{ first_name } #{ last_name }"
```

Always use explicit braces for instance/class variables in interpolation:

```ruby
# Good
"#{@first_name} #{@last_name}"

# Bad — implicit, works but fragile
"#@first_name #@last_name"
```

### Quote Style

Both single and double quotes are acceptable. Pick one and be consistent across the
project.

- **Single-quote camp**: Use `'plain string'` for strings without interpolation or special
  characters. Use `"interpolated #{value}"` only when needed.
- **Double-quote camp** (Shopify convention): Always use `"double quotes"` for all strings,
  whether or not they contain interpolation.

The community guide is agnostic. Whatever the project chooses, enforce it with RuboCop.

### Heredocs

Use squiggly heredocs (`<<~`) for multi-line strings. They strip leading indentation:

```ruby
message = <<~TEXT
  Hello #{name},

  Your account has been created.
  Welcome aboard!
TEXT
```

### Symbols vs Strings

Use symbols for identifiers, hash keys, and enum-like values. Use strings for text content:

```ruby
# Symbols — identity, keys, flags
status = :active
options = { compactness: :short }

# Strings — text content
greeting = "Hello, world"
locale_code = "en"
```

Symbols are immutable and interned (deduplicated in memory). They are ideal for things
that are compared by identity. Strings are for data that is compared by value or
displayed to users.

### Frozen Strings

With `# frozen_string_literal: true`, all string literals are frozen. To create a mutable
string, use `String.new` or `+"mutable"`:

```ruby
# frozen_string_literal: true

frozen = "cannot modify this"  # frozen
mutable = +"can modify this"   # unfrozen (unary +)
mutable << " safely"
```

### String Replacement

Use `sub` for single replacements and `gsub` for global replacements. Use `tr` for
character-level transliteration:

```ruby
# Single replacement
url.sub("http://", "https://")

# Character replacement — faster than gsub for single chars
"lisp-case".tr("-", "_")  # => "lisp_case"
```

### `sprintf` / `format`

Use `format` or `sprintf` for complex string formatting:

```ruby
format("%-10s %5d", name, count)
```

---

## 9. Common Idioms

### Guard Clauses

Return early to avoid deep nesting:

```ruby
# Good
def format_age(date_of_birth, as_of = nil)
  return nil if date_of_birth.nil? || date_of_birth.empty?

  # main logic (not nested)
end

# Bad — deep nesting
def format_age(date_of_birth, as_of = nil)
  unless date_of_birth.nil? || date_of_birth.empty?
    # main logic (nested)
  end
end
```

### Ternary for Simple Conditionals

Use the ternary operator for simple, single-line conditionals. Use `if`/`else` for
anything more complex:

```ruby
# Good
status = active? ? "on" : "off"

# Bad — ternary for complex logic
result = condition ? (a + b * c / d) : (e + f * g / h)

# Bad — nested ternaries
result = a ? (b ? x : y) : z
```

### `unless` for Negative Conditions

Use `unless` instead of `if !` for simple negative conditions. Never use `unless` with
`else` or with compound conditions:

```ruby
# Good
return unless valid?
process unless items.empty?

# Bad
return if !valid?

# Bad — unless with else (confusing)
unless success?
  handle_failure
else
  handle_success
end

# Bad — unless with compound condition (confusing)
unless a? && b?
  # hard to reason about
end
```

### Modifier `if` / `unless`

Use modifier form for simple one-liners:

```ruby
return nil if age.nil?
months -= 1 if ref_d < clamped_birthday
```

### Safe Navigation Operator (`&.`)

Use `&.` to safely call methods on potentially `nil` objects:

```ruby
# Good
user&.profile&.avatar_url

# Instead of
user && user.profile && user.profile.avatar_url
```

### `dig` for Nested Access

Use `dig` to safely traverse nested hashes and arrays:

```ruby
config.dig(:database, :primary, :host)
# Returns nil if any intermediate key is missing
```

### `then` (alias `yield_self`)

Use `then` for pipeline-style transformations (Ruby 2.6+):

```ruby
url
  .then { |u| URI.parse(u) }
  .then { |uri| Net::HTTP.get(uri) }
  .then { |body| JSON.parse(body) }
```

### `||=` for Memoization

```ruby
@default_formatter ||= Formatter.new(Locales::EN)
```

Do not use `||=` for booleans (it will not memoize `false`):

```ruby
# Bad — fails when @enabled is false
@enabled ||= compute_enabled

# Good
@enabled = compute_enabled if @enabled.nil?

# Or use defined?
defined?(@enabled) ? @enabled : (@enabled = compute_enabled)
```

### Predicate Methods on Numbers

```ruby
count.zero?       # instead of count == 0
count.positive?   # instead of count > 0
count.negative?   # instead of count < 0
```

### `freeze` for Constants

Freeze mutable constants to prevent accidental modification:

```ruby
STAGES = %i[newborn infant toddler child teenager adult].freeze
DEFAULT_DELIMITER = ", ".freeze  # Not needed with frozen_string_literal: true
```

With `# frozen_string_literal: true`, string literals are already frozen. You still need
to freeze arrays, hashes, and other mutable objects assigned to constants.

### `case` as an Expression

Use `case` (and `if`) as expressions that return values:

```ruby
stage = case months
        when 0...2   then :newborn
        when 2...12  then :infant
        when 12...36 then :toddler
        else              :child
        end
```

### `next` in Loops

Use `next` instead of wrapping the loop body in a conditional:

```ruby
# Good
items.each do |item|
  next unless item.processable?
  process(item)
end

# Bad
items.each do |item|
  if item.processable?
    process(item)
  end
end
```

---

## 10. Things to Avoid

### `for` Loops

`for` does not create a new scope. The loop variable leaks into the surrounding scope:

```ruby
# Bad
for item in items
  process(item)
end
# `item` is still defined here

# Good
items.each do |item|
  process(item)
end
# `item` is not defined here
```

### `rescue Exception`

Rescuing `Exception` catches `SignalException` (including `Interrupt`), `SystemExit`,
`NoMemoryError`, and other fatal conditions. Always rescue `StandardError` (the default)
or a more specific class:

```ruby
# Bad — catches Ctrl-C, kill signals, out-of-memory
begin
  work
rescue Exception => e
  log(e)
end

# Good
begin
  work
rescue StandardError => e
  log(e)
end

# Also good — bare rescue catches StandardError
begin
  work
rescue => e
  log(e)
end
```

### Class Variables (`@@`)

Class variables are shared across the entire inheritance hierarchy, leading to surprising
behavior:

```ruby
# Dangerous
class Parent
  @@count = 0
end

class Child < Parent
  @@count = 1  # Also changes Parent's @@count!
end
```

Use class-level instance variables instead:

```ruby
class Parent
  @count = 0

  class << self
    attr_accessor :count
  end
end
```

### `method_missing` Abuse

Avoid `method_missing` for regular dispatch. It is slow, hard to debug, does not appear in
`respond_to?` (without also implementing `respond_to_missing?`), and breaks introspection.
If you must use it, always define `respond_to_missing?` as well.

### Monkey-Patching Core Classes

Never reopen `String`, `Array`, `Hash`, or other core classes in library code. It creates
global side effects and version conflicts.

### `and` / `or` for Boolean Logic

`and` and `or` have lower precedence than `=`, which causes subtle bugs:

```ruby
# Surprising — assigns "hello" to x, then evaluates `or`
x = something or raise "oops"
# Equivalent to: (x = something) or (raise "oops")

# Use && and || for boolean logic
valid = a && b
result = x || default
```

Reserve `and` / `or` for control flow only (and even then, prefer explicit `if`/`unless`).

### Perl-Style Special Variables

Avoid `$!`, `$@`, `$&`, `$~`, `$1`, etc. Use named captures and explicit exception
variables:

```ruby
# Bad
if /(?:(\d+))/ =~ str
  puts $1
end

# Good
if /(?<number>\d+)/ =~ str
  puts number
end
```

### Returning from `ensure`

An explicit `return` in an `ensure` block silently discards any exception that was raised:

```ruby
# Bad — swallows the exception
def process
  raise "error"
ensure
  return "done"  # exception is silently lost
end
```

### `BEGIN` / `END` Blocks

Avoid `BEGIN` and `END`. Use regular code flow and `at_exit` if needed.

### Nested Method Definitions

Do not define methods inside other methods. Each call redefines the inner method:

```ruby
# Bad
def outer
  def inner
    "surprise"
  end
  inner
end
```

---

## 11. Tooling

### RuboCop

[RuboCop](https://docs.rubocop.org/rubocop/) is the standard Ruby linter and formatter.
It enforces style rules from the community guide and is highly configurable.

Departments (cop categories):
- **Layout** — Indentation, spacing, alignment, line length.
- **Lint** — Suspicious code patterns (unused variables, unreachable code).
- **Naming** — Identifier naming conventions.
- **Style** — Idiomatic Ruby patterns (guard clauses, ternaries, `unless`).
- **Metrics** — Method length, cyclomatic complexity, parameter counts.
- **Security** — Dangerous patterns (eval, open with user input).

Configuration lives in `.rubocop.yml`:

```yaml
AllCops:
  TargetRubyVersion: 3.2
  NewCops: enable

Layout/LineLength:
  Max: 120

Style/FrozenStringLiteralComment:
  Enabled: true
  EnforcedStyle: always

Style/StringLiterals:
  EnforcedStyle: single_quotes
```

Use Shopify's config as a solid starting point:

```yaml
# .rubocop.yml
inherit_gem:
  rubocop-shopify: rubocop.yml
```

### Sorbet (Static + Runtime Type Checking)

[Sorbet](https://sorbet.org/) adds gradual type checking to Ruby. It has two components:

- **`srb`** (CLI): Static type checker that analyzes code before execution.
- **`sorbet-runtime`** (gem): Runtime type enforcement via `sig` annotations.

```ruby
class Calculator
  extend T::Sig

  sig { params(x: Integer, y: Integer).returns(Integer) }
  def add(x, y)
    x + y
  end
end
```

Sorbet supports gradual adoption: you can type-check one file at a time.

### Steep (RBS-based Type Checking)

[Steep](https://github.com/soutaro/steep) is an alternative type checker that uses RBS
(Ruby Signature) files rather than inline annotations:

```bash
steep init       # Generate Steepfile
steep check      # Run type checking
```

Type declarations live in `.rbs` files in a `sig/` directory:

```rbs
# sig/formatter.rbs
class Formatter
  def format_age: (String?, ?String?) -> String?
end
```

### Warnings Mode

Run Ruby with warnings enabled to catch potential issues:

```bash
ruby -w script.rb
RUBYOPT=-w ruby script.rb
```

### Minitest

[Minitest](https://github.com/minitest/minitest) is Ruby's built-in test framework.
It is lightweight, fast, and requires no external dependencies:

```ruby
require "minitest/autorun"

class TestFormatter < Minitest::Test
  def test_returns_nil_for_nil_input
    assert_nil SayableAge.format_age(nil, "2025-06-15")
  end

  def test_born_today_newborn
    assert_equal "Newborn", SayableAge.format_age("2025-06-15", "2025-06-15")
  end
end
```

Key assertions:
- `assert_equal expected, actual` — Value equality.
- `assert_nil value` — Value is `nil`.
- `refute_nil value` — Value is not `nil`.
- `assert_match pattern, string` — Regex or string match.
- `assert_predicate obj, :method?` — Predicate method returns truthy.
- `assert_raises(ExceptionClass) { block }` — Block raises expected exception.
- `assert_includes collection, item` — Collection includes item.

### RSpec

[RSpec](https://rspec.info/) is the other major test framework, using a BDD-style DSL:

```ruby
RSpec.describe SayableAge do
  describe ".format_age" do
    it "returns nil for nil input" do
      expect(SayableAge.format_age(nil, "2025-06-15")).to be_nil
    end
  end
end
```

Choose one framework per project and stick with it. Minitest is preferred for libraries
that target zero dependencies.

---

## 12. Sources

### Primary References

- [The Ruby Style Guide](https://rubystyle.guide) (rubocop/ruby-style-guide) -- The
  canonical community style guide, maintained by the RuboCop team. The single most
  authoritative source for Ruby coding conventions.

- [Shopify Ruby Style Guide](https://ruby-style-guide.shopify.dev/) -- Production-tested
  conventions from one of the largest Ruby shops. Notable differences from the community
  guide: 120-char line limit, double quotes always, trailing commas in multi-line
  collections.

- [RuboCop Documentation](https://docs.rubocop.org/rubocop/) -- Full reference for all
  cops (lint rules) organized by department: Layout, Lint, Naming, Style, Metrics,
  Security.

### Ruby Documentation

- [Ruby Core API](https://docs.ruby-lang.org/en/3.3/) -- Official documentation for
  built-in classes and modules.

- [Enumerable](https://docs.ruby-lang.org/en/3.3/Enumerable.html) -- The most important
  mixin in Ruby. Every Ruby developer should know its methods.

- [Comparable](https://docs.ruby-lang.org/en/3.3/Comparable.html) -- Include this module
  and define `<=>` to get comparison operators for free.

- [Data](https://docs.ruby-lang.org/en/3.3/Data.html) -- Immutable value objects
  (Ruby 3.2+).

- [Struct](https://docs.ruby-lang.org/en/3.3/Struct.html) -- Lightweight classes for
  structured data.

- [Pattern Matching](https://docs.ruby-lang.org/en/3.3/syntax/pattern_matching_rdoc.html)
  -- `case`/`in` structural pattern matching (Ruby 3.0+).

### Type Checking

- [Sorbet](https://sorbet.org/) -- Gradual type system with inline `sig` annotations and
  static analysis.

- [Steep](https://github.com/soutaro/steep) -- Type checker using RBS signature files.

- [RBS](https://github.com/ruby/rbs) -- The standard language for describing Ruby program
  types, included in Ruby since 3.0.

### Testing

- [Minitest](https://github.com/minitest/minitest) -- Built-in, lightweight test
  framework.

- [RSpec](https://rspec.info/) -- BDD-style test framework with rich matcher DSL.

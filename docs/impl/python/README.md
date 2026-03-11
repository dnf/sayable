# Python Style Guide

A comprehensive reference for writing idiomatic, maintainable Python. This guide is used for code auditing Python implementations in the Sayable project. It synthesizes conventions from PEP 8, PEP 20, the Google Python Style Guide, and community best practices.

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Type System](#3-type-system)
4. [Module Design](#4-module-design)
5. [Class Design](#5-class-design)
6. [Error Handling](#6-error-handling)
7. [Collections and Comprehensions](#7-collections-and-comprehensions)
8. [String Handling](#8-string-handling)
9. [Common Idioms](#9-common-idioms)
10. [Things to Avoid](#10-things-to-avoid)
11. [Tooling](#11-tooling)
12. [References](#12-references)

---

## 1. Naming Conventions

Python naming conventions are codified in [PEP 8](https://peps.python.org/pep-0008/#naming-conventions). Following them is not optional --- it is how other Python developers will read your code.

### Modules and Packages

Use short, all-lowercase names. Underscores are acceptable in module names for readability but discouraged in package names.

```python
# Modules
import format_age        # good: lowercase with underscores
import formatage         # acceptable: short lowercase

# Packages
import sayableage        # good: no underscores in package names
```

C extension modules that provide a Python wrapper use a leading underscore: `_socket`, `_csv`.

### Classes

Use `CapWords` (PascalCase). Acronyms stay uppercase within the name.

```python
class AgeFormatter:       # good
class HTTPServerError:    # good: acronym stays uppercase
class age_formatter:      # wrong: not CapWords
class HttpServerError:    # acceptable but less conventional
```

### Exceptions

Exception classes follow `CapWords` and should end with `Error` (when they represent error conditions).

```python
class InvalidDateError(ValueError):   # good
class FormatError(Exception):         # good
class BadInput(Exception):            # less clear: missing Error suffix
```

### Functions and Methods

Use `lowercase_with_underscores`.

```python
def format_age(date_of_birth, as_of):    # good
def formatAge(date_of_birth, as_of):     # wrong: mixedCase
```

### Variables

Follow the same `lowercase_with_underscores` convention as functions.

```python
birth_date = date(2023, 1, 15)    # good
birthDate = date(2023, 1, 15)     # wrong: mixedCase
```

### Constants

Use `UPPER_CASE_WITH_UNDERSCORES`. Define constants at module level.

```python
MAX_MONTHS = 24
DEFAULT_LOCALE = "en"
DAYS_PER_YEAR = 365.2425
```

### Private and Protected

Python has no access modifiers. Convention communicates intent:

| Prefix | Meaning | Behavior |
|--------|---------|----------|
| `name` | Public | Part of the API |
| `_name` | Internal | Not part of the public API; excluded from `from module import *` |
| `__name` | Name-mangled | Mangled to `_ClassName__name` to avoid subclass collisions |
| `name_` | Trailing underscore | Avoids conflict with Python keywords (`class_`, `type_`) |

```python
class Formatter:
    def format(self):          # public API
        return self._compute()

    def _compute(self):        # internal: callers should not rely on this
        return self.__value    # name-mangled: _Formatter__value

    def __init__(self, type_):  # trailing underscore avoids keyword clash
        self.__value = type_
```

Use a single leading underscore for internal APIs. Reserve double leading underscores for cases where you genuinely need to prevent name collisions in inheritance hierarchies --- not as a general "private" marker.

### Dunder Methods

Names with double leading and trailing underscores (`__init__`, `__repr__`, `__eq__`) are reserved for Python's protocol methods. Never invent new dunder names; use only those defined by the language.

### Method Arguments

Always use `self` for the first argument of instance methods and `cls` for class methods. These are not negotiable.

```python
class Locale:
    @classmethod
    def from_code(cls, code: str) -> "Locale":
        ...

    def format(self, value: int) -> str:
        ...
```

### Type Variables

Use `CapWords`, preferring short names: `T`, `K`, `V`, `AnyStr`. Add `_co` for covariant and `_contra` for contravariant type variables.

```python
from typing import TypeVar

T = TypeVar("T")
T_co = TypeVar("T_co", covariant=True)
```

### Names to Avoid

Never use `l` (lowercase L), `O` (uppercase O), or `I` (uppercase I) as single-character variable names. They are visually indistinguishable from `1` and `0` in many fonts.

---

## 2. Code Formatting

### PEP 8 Fundamentals

[PEP 8](https://peps.python.org/pep-0008/) is the authoritative style guide. The essentials:

- **Indentation:** 4 spaces. Never tabs. Python 3 forbids mixing tabs and spaces.
- **Line length:** 79 characters for code, 72 for docstrings and comments. Teams may agree on up to 99 characters for code, but docstrings and comments stay at 72.
- **Encoding:** UTF-8 (the default). No encoding declaration needed.

### Imports

Imports go at the top of the file, after the module docstring and `from __future__` imports. Group them in this order, separated by blank lines:

1. Standard library imports
2. Third-party imports
3. Local application/library imports

Each import gets its own line. Sort alphabetically within each group.

```python
"""Format ages the way humans speak."""

from __future__ import annotations

import math
from collections.abc import Sequence
from datetime import date

from dateutil.relativedelta import relativedelta

from sayableage.locale import AgeLocale
from sayableage.types import PluralCategory
```

Never use wildcard imports (`from module import *`) in production code. They pollute the namespace and make it impossible to determine where names originate.

Prefer absolute imports over relative imports. Explicit relative imports (`from . import sibling`) are acceptable within packages but absolute imports are clearer.

### Blank Lines

- **Two blank lines** before and after top-level function and class definitions.
- **One blank line** between methods inside a class.
- Use blank lines sparingly within functions to indicate logical sections.

### Whitespace

Follow PEP 8 whitespace rules precisely:

```python
# Good
spam(ham[1], {eggs: 2})
foo = (0,)
if x == 4:
    print(x, y)
    x, y = y, x
ham[1:9], ham[1:9:3], ham[:9:3]
spam(1)
dct["key"]

# Bad
spam( ham[ 1 ], { eggs: 2 } )
foo = (0, )
if x == 4 :
    print(x , y)
    x , y = y , x
ham[1: 9], ham[1 :9 :3]
spam (1)
dct ['key']
```

Surround binary operators with a single space on each side. Exception: in function signatures, no spaces around `=` for default values (unless the parameter has a type annotation).

```python
# Function defaults
def format_age(dob: date, as_of: date = date.today()) -> str:  # space around = with annotation
    ...

def format_age(dob, as_of=None):  # no space around = without annotation
    ...

# Expressions: space around operators
x = x + 1
ratio = (width + height) / 2
```

### Line Continuation

Use implicit continuation inside parentheses, brackets, and braces. Avoid backslash continuation.

```python
# Good: implicit continuation
result = (
    first_value
    + second_value
    - third_value
)

# Good: aligned with opening delimiter
foo = long_function_name(var_one, var_two,
                         var_three, var_four)

# Good: hanging indent
foo = long_function_name(
    var_one,
    var_two,
    var_three,
    var_four,
)

# Bad: backslash continuation
result = first_value + \
         second_value
```

When breaking around a binary operator, break **before** the operator:

```python
# Good: operator at start of line (Knuth style)
income = (
    gross_wages
    + taxable_interest
    + (dividends - qualified_dividends)
    - ira_deduction
)

# Bad: operator at end of line
income = (
    gross_wages +
    taxable_interest +
    (dividends - qualified_dividends) -
    ira_deduction
)
```

### Trailing Commas

Use trailing commas in multi-line collections and function arguments. They make diffs cleaner.

```python
# Good: trailing comma
FILES = [
    "setup.cfg",
    "tox.ini",
    "pyproject.toml",
]

# Good: single-element tuple requires trailing comma
single = ("value",)
```

### String Quotes

PEP 8 does not prescribe single vs. double quotes --- pick one and be consistent. Use the opposite quote type to avoid backslash escaping. Always use double quotes for docstrings.

```python
name = "sayable-age"                    # consistent with project convention
message = 'He said "hello"'            # avoids escaping
docstring = """Format an age value."""  # always double quotes for docstrings
```

### Formatter: Black

[Black](https://black.readthedocs.io/) is the standard opinionated formatter. It enforces consistent style with minimal configuration. Key Black defaults:

- Line length: 88 characters (a deliberate compromise between 79 and 99)
- Double quotes for strings
- Trailing commas in multi-line structures
- Consistent parenthesization of long expressions

Black is non-negotiable in many projects. If your project uses it, do not fight it.

---

## 3. Type System

Python's type system is gradual: type hints are optional and do not affect runtime behavior. They exist for static analysis, documentation, and IDE support. Authoritative reference: the [`typing` module documentation](https://docs.python.org/3/library/typing.html).

### Basic Annotations

```python
# Variables
name: str = "en"
count: int = 0
ratio: float = 0.5
active: bool = True

# Functions
def format_age(date_of_birth: date, as_of: date) -> str:
    ...

# None return
def log(message: str) -> None:
    ...
```

### Collections (3.9+)

Use built-in collection types directly. The capitalized `typing` versions (`List`, `Dict`, `Set`, `Tuple`) are deprecated since Python 3.9.

```python
# Modern (3.9+)
names: list[str] = []
config: dict[str, int] = {}
unique: set[str] = set()
point: tuple[float, float] = (1.0, 2.0)
record: tuple[str, ...] = ("a", "b", "c")  # variable-length

# Deprecated (avoid)
from typing import List, Dict
names: List[str] = []
```

### Union and Optional Types (3.10+)

Use the `|` operator for union types. `X | None` replaces `Optional[X]`.

```python
# Modern (3.10+)
def find(key: str) -> str | None:
    ...

def parse(value: str | int) -> float:
    ...

# Deprecated
from typing import Optional, Union
def find(key: str) -> Optional[str]:     # avoid
    ...
def parse(value: Union[str, int]) -> float:  # avoid
    ...
```

### Callable Types

Use `collections.abc.Callable` instead of `typing.Callable`.

```python
from collections.abc import Callable

PluralRule = Callable[[int], str]

def apply_rule(n: int, rule: Callable[[int], str]) -> str:
    return rule(n)
```

### Abstract Collection Types

For function parameters, prefer abstract types from `collections.abc` over concrete types. This makes the function more flexible.

```python
from collections.abc import Sequence, Mapping, Iterable

# Good: accepts lists, tuples, or any sequence
def first(items: Sequence[str]) -> str:
    return items[0]

# Too restrictive: only accepts lists
def first(items: list[str]) -> str:
    return items[0]
```

### TypeVar and Generics

For Python 3.12+, use the native type parameter syntax. For earlier versions, use `TypeVar`.

```python
# Python 3.12+ (PEP 695)
def first[T](items: Sequence[T]) -> T:
    return items[0]

class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

# Python 3.11 and earlier
from typing import TypeVar, Generic

T = TypeVar("T")

def first(items: Sequence[T]) -> T:
    return items[0]

class Stack(Generic[T]):
    ...
```

### Type Aliases

```python
# Python 3.12+ (PEP 695)
type Vector = list[float]
type ConnectionOptions = dict[str, str]

# Python 3.10-3.11
from typing import TypeAlias

Vector: TypeAlias = list[float]
```

### Protocol (Structural Subtyping)

`Protocol` defines interfaces through structure rather than inheritance. This is Python's type-safe version of duck typing.

```python
from typing import Protocol, runtime_checkable

class Formattable(Protocol):
    def format(self, locale: str) -> str: ...

# Any class with a matching format() method satisfies this protocol
# No explicit inheritance required
class AgeValue:
    def format(self, locale: str) -> str:
        return f"{self.years} years"

def render(item: Formattable) -> str:
    return item.format("en")

render(AgeValue())  # type-checks without AgeValue inheriting from Formattable
```

Use `@runtime_checkable` only when you need `isinstance()` checks at runtime. It only verifies method existence, not signatures.

### Overload

Use `@overload` to describe functions that return different types based on input types.

```python
from typing import overload

@overload
def process(value: str) -> str: ...
@overload
def process(value: int) -> int: ...

def process(value: str | int) -> str | int:
    if isinstance(value, str):
        return value.upper()
    return value * 2
```

### ParamSpec (Decorators)

Use `ParamSpec` to preserve function signatures in decorators.

```python
from typing import ParamSpec
from collections.abc import Callable

P = ParamSpec("P")

def log_call[**P, R](f: Callable[P, R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {f.__name__}")
        return f(*args, **kwargs)
    return wrapper
```

### Self

Use `Self` for methods that return their own type, especially in class hierarchies.

```python
from typing import Self

class Builder:
    def with_name(self, name: str) -> Self:
        self._name = name
        return self
```

### Dataclass Type Hints

Dataclass fields are inherently annotated. Use `ClassVar` for class-level attributes that are not instance fields, and `InitVar` for init-only parameters.

```python
from dataclasses import dataclass, field
from typing import ClassVar

@dataclass
class AgeLocale:
    code: str
    units: dict[str, str]
    stages: list[tuple[int, str]] = field(default_factory=list)
    instance_count: ClassVar[int] = 0
```

### Practical Guidance

- Annotate all public API functions and methods.
- Use `from __future__ import annotations` to enable postponed evaluation (string-ified annotations), which avoids forward reference issues and slightly reduces import-time overhead.
- Prefer `X | None` over `Optional[X]`.
- Use abstract types (`Sequence`, `Mapping`, `Iterable`) for parameters; concrete types (`list`, `dict`) for return values.
- Do not annotate `self`, `cls`, or `__init__` return types.
- Never use `Any` to silence a type checker. If you must, add a comment explaining why.

---

## 4. Module Design

### `__init__.py`

An `__init__.py` file marks a directory as a Python package. Keep it minimal:

```python
"""Sayable Age: format ages the way humans speak."""

from sayableage.formatter import format_age
from sayableage.locale import AgeLocale
from sayableage.types import PluralCategory

__all__ = ["format_age", "AgeLocale", "PluralCategory"]
__version__ = "0.6.0"
```

Use `__init__.py` to define the public API surface. Import only the symbols users need. Heavy initialization logic does not belong here.

### `__all__`

Define `__all__` to explicitly declare the public API of a module. This controls what `from module import *` exports (which you should never use anyway) and serves as documentation of the intended public interface.

```python
__all__ = ["format_age", "AgeLocale", "PluralCategory"]
```

### Import Style

Use absolute imports. Explicit relative imports are acceptable within a package but absolute imports are preferred for clarity.

```python
# Absolute (preferred)
from sayableage.locale import AgeLocale

# Explicit relative (acceptable within a package)
from .locale import AgeLocale

# Implicit relative (forbidden in Python 3)
from locale import AgeLocale  # this imports the stdlib locale module
```

### Public API Design

- Export types, functions, and constants that users need. Keep everything else internal (prefix with `_`).
- Organize code so that each module has a clear, singular responsibility.
- Avoid circular imports by structuring dependencies as a DAG. If module A needs something from module B and vice versa, extract the shared dependency into module C.

### Module-Level Dunder Names

Place module-level dunders after the docstring but before imports (except `from __future__`):

```python
"""Module docstring."""

from __future__ import annotations

__all__ = ["format_age"]
__version__ = "0.6.0"
__author__ = "Sayable Contributors"

import math
from datetime import date
```

---

## 5. Class Design

### Dataclasses

Use `@dataclass` for classes that are primarily data containers. They auto-generate `__init__`, `__repr__`, and `__eq__`.

```python
from dataclasses import dataclass, field

@dataclass(frozen=True, slots=True)
class AgeLocale:
    code: str
    just_born: str
    units: dict[str, str]
    stages: list[tuple[int, str]] = field(default_factory=list)
```

Key options:

| Option | When to Use |
|--------|-------------|
| `frozen=True` | Value objects that should be immutable |
| `slots=True` | Memory-sensitive applications; prevents dynamic attribute assignment |
| `order=True` | When instances need comparison operators (`<`, `<=`, `>`, `>=`) |
| `kw_only=True` | When all fields should be keyword-only arguments |

Use `field(default_factory=...)` for mutable defaults --- never use bare `[]`, `{}`, or `set()` as defaults.

Use `__post_init__` for derived fields or validation:

```python
@dataclass
class DateRange:
    start: date
    end: date
    days: int = field(init=False)

    def __post_init__(self) -> None:
        if self.end < self.start:
            raise ValueError("end must be >= start")
        self.days = (self.end - self.start).days
```

### `__slots__`

Without dataclasses, define `__slots__` manually to restrict attribute creation and reduce memory usage:

```python
class Point:
    __slots__ = ("x", "y")

    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y
```

### Properties

Use `@property` for computed attributes that should look like simple attribute access. Do not use properties for trivial getters/setters --- just make the attribute public.

```python
class Circle:
    def __init__(self, radius: float) -> None:
        self.radius = radius  # public: no property needed

    @property
    def area(self) -> float:
        return math.pi * self.radius ** 2

    @property
    def diameter(self) -> float:
        return self.radius * 2
```

### Class Methods and Static Methods

Use `@classmethod` for alternative constructors and factory methods:

```python
class AgeLocale:
    @classmethod
    def from_json(cls, data: dict[str, object]) -> "AgeLocale":
        return cls(
            code=data["code"],
            units=data["units"],
        )
```

Avoid `@staticmethod`. If a method does not use `self` or `cls`, it should probably be a module-level function. Static methods break caller expectations around named arguments and provide no real benefit over free functions.

### Abstract Base Classes

Use `abc.ABC` and `@abstractmethod` to define interfaces when you need nominal (inheritance-based) typing:

```python
from abc import ABC, abstractmethod

class Formatter(ABC):
    @abstractmethod
    def format(self, value: int, locale: str) -> str: ...

    @abstractmethod
    def supports(self, locale: str) -> bool: ...
```

Prefer `Protocol` over ABC when you do not need to share implementation. Protocol-based interfaces are more flexible because they do not require explicit inheritance.

### When to Use What

| Need | Use |
|------|-----|
| Data container with few methods | `@dataclass` |
| Immutable value object | `@dataclass(frozen=True)` |
| Lightweight immutable tuple | `NamedTuple` |
| Interface with no shared implementation | `Protocol` |
| Interface with shared implementation | `ABC` |
| Complex behavior, deep hierarchy | Regular class |

---

## 6. Error Handling

### Catch Specific Exceptions

Never catch `Exception` or use bare `except:` unless you are at the top-level boundary of a system (e.g., a request handler that must not crash). Bare `except:` catches `SystemExit`, `KeyboardInterrupt`, and `GeneratorExit`, which is almost never correct.

```python
# Good: specific exception
try:
    value = int(text)
except ValueError:
    value = 0

# Bad: catches KeyboardInterrupt, SystemExit, etc.
try:
    value = int(text)
except:
    value = 0

# Bad: overly broad
try:
    value = int(text)
except Exception:
    value = 0
```

### Exception Chaining

Use `raise ... from ...` to chain exceptions. This preserves the causal chain in tracebacks.

```python
try:
    data = parse_config(path)
except json.JSONDecodeError as exc:
    raise ConfigError(f"Invalid config at {path}") from exc
```

Use `raise ... from None` to suppress the original exception when chaining would be misleading:

```python
try:
    return registry[name]
except KeyError:
    raise LookupError(f"Unknown locale: {name}") from None
```

### Custom Exception Hierarchies

Derive from `Exception`, not `BaseException`. Design exception hierarchies around what callers need to distinguish:

```python
class SayableError(Exception):
    """Base for all sayable errors."""

class InvalidDateError(SayableError):
    """Raised when date of birth is after the as-of date."""

class UnknownLocaleError(SayableError):
    """Raised when a locale code is not recognized."""
```

### Context Managers

Use `with` statements for resource management. This guarantees cleanup even when exceptions occur.

```python
# Good
with open(path) as f:
    data = json.load(f)

# Bad: relies on manual close or garbage collection
f = open(path)
data = json.load(f)
f.close()
```

Write custom context managers with `contextlib.contextmanager` or by implementing `__enter__` and `__exit__`:

```python
from contextlib import contextmanager

@contextmanager
def temporary_locale(code: str):
    previous = get_locale()
    set_locale(code)
    try:
        yield
    finally:
        set_locale(previous)
```

### EAFP vs. LBYL

Python favors **EAFP** (Easier to Ask Forgiveness than Permission) over **LBYL** (Look Before You Leap). Use `try`/`except` rather than pre-checking conditions, especially for operations that could race or where the check is as expensive as the operation.

```python
# EAFP (Pythonic)
try:
    value = mapping[key]
except KeyError:
    value = default

# Even more Pythonic: use dict.get()
value = mapping.get(key, default)

# LBYL (less Pythonic, but acceptable for clarity)
if key in mapping:
    value = mapping[key]
else:
    value = default
```

LBYL is acceptable when the `try`/`except` would be hard to read or when you need to distinguish between different failure modes.

### Minimize `try` Block Scope

Keep `try` blocks as small as possible. The larger the `try` block, the more likely you will catch an exception from a line you did not intend to guard.

```python
# Good: narrow try block
try:
    value = int(text)
except ValueError:
    return None
return process(value)

# Bad: process() errors are also caught
try:
    value = int(text)
    return process(value)
except ValueError:
    return None
```

### `assert` Is Not for Validation

`assert` statements are removed when Python runs with optimization (`-O`). Never use them for input validation, precondition checks, or anything that must execute in production.

```python
# Wrong: removed with -O flag
assert isinstance(date_of_birth, date), "Expected a date"

# Right: always executes
if not isinstance(date_of_birth, date):
    raise TypeError(f"Expected date, got {type(date_of_birth).__name__}")
```

---

## 7. Collections and Comprehensions

### List Comprehensions

Use them for simple transformations and filters. Avoid nested comprehensions --- they sacrifice readability.

```python
# Good: clear transformation
squares = [x * x for x in range(10)]

# Good: simple filter
adults = [p for p in people if p.age >= 18]

# Bad: multiple for-clauses and conditions
result = [
    (x, y)
    for x in range(10)
    for y in range(10)
    if x != y
    if x + y > 5
]
# Rewrite as a loop for clarity.
```

### Dict and Set Comprehensions

```python
# Dict comprehension
locale_map = {code: load_locale(code) for code in codes}

# Set comprehension
unique_codes = {person.locale_code for person in people}
```

### Generator Expressions

Use generators when you only need to iterate once and do not need the full list in memory.

```python
# Generator: memory-efficient for large sequences
total = sum(item.price for item in catalog)

# Pass directly to functions that accept iterables
any(is_valid(x) for x in inputs)
all(len(name) > 0 for name in names)
```

### `itertools`

The `itertools` module provides efficient building blocks for working with iterables.

```python
from itertools import chain, groupby, islice, zip_longest

# Chain multiple iterables
all_items = chain(list_a, list_b, list_c)

# Group consecutive elements
for key, group in groupby(sorted(data, key=attrgetter("category")), key=attrgetter("category")):
    process(key, list(group))

# Take first N elements
first_ten = list(islice(iterable, 10))
```

### Choosing the Right Collection

| Need | Type |
|------|------|
| Ordered, mutable sequence | `list` |
| Immutable sequence | `tuple` |
| Fast membership testing | `set` or `frozenset` |
| Key-value mapping | `dict` |
| Ordered + deduplication | `dict.fromkeys()` (3.7+ preserves insertion order) |
| Stack (LIFO) | `list` (use `append`/`pop`) |
| Queue (FIFO) | `collections.deque` |
| Counting elements | `collections.Counter` |
| Default values for missing keys | `collections.defaultdict` |

---

## 8. String Handling

### f-strings (3.6+)

f-strings are the preferred way to format strings. They are readable, concise, and fast.

```python
name = "Alice"
age = 30
message = f"{name} is {age} years old"

# Expressions are allowed
label = f"{count} {'item' if count == 1 else 'items'}"

# Format specs
percentage = f"{ratio:.1%}"
padded = f"{value:>10}"
```

### `str.format()`

Use `str.format()` when you need to reuse a template or when the template comes from external data (e.g., locale strings).

```python
template = "{count} {unit}"
result = template.format(count=3, unit="months")
```

### String Concatenation

Never concatenate strings in a loop with `+=`. This creates a new string object on every iteration, resulting in O(n^2) behavior. Use `str.join()` instead.

```python
# Good: O(n)
parts = []
for item in items:
    parts.append(str(item))
result = ", ".join(parts)

# Even better: list comprehension + join
result = ", ".join(str(item) for item in items)

# Bad: O(n^2)
result = ""
for item in items:
    result += str(item) + ", "
```

### Multiline Strings

Use triple quotes for multiline strings. Use implicit string concatenation for strings that should not contain newlines:

```python
# Multiline (preserves newlines)
docstring = """
This is a long description
that spans multiple lines.
"""

# Adjacent string literals (no newlines in result)
message = (
    "This is a very long message "
    "that is split across lines "
    "for readability."
)
```

### Logging

Pass format strings and arguments separately to logging functions. This avoids formatting the string when the log level is disabled and allows log aggregation tools to group by pattern.

```python
import logging

logger = logging.getLogger(__name__)

# Good: deferred formatting
logger.info("Processing locale %s with %d units", code, len(units))

# Bad: eager formatting with f-string
logger.info(f"Processing locale {code} with {len(units)} units")
```

### `pathlib` for File Paths

Use `pathlib.Path` instead of `os.path` string manipulation.

```python
from pathlib import Path

config_dir = Path(__file__).parent / "config"
locale_file = config_dir / "locales" / f"{code}.json"

if locale_file.exists():
    data = json.loads(locale_file.read_text())

# Avoid
import os
locale_file = os.path.join(os.path.dirname(__file__), "config", "locales", f"{code}.json")
```

---

## 9. Common Idioms

### Truthiness

Python has well-defined truthiness rules. Use them directly --- do not compare to `True`, `False`, or check lengths.

```python
# Good
if items:            # non-empty sequence
if not items:        # empty sequence
if name:             # non-empty string
if count:            # non-zero number

# Bad
if len(items) > 0:
if items != []:
if name != "":
if count != 0:
if flag == True:
if flag is True:     # only correct when you literally need identity check with True
```

### `None` Comparison

Always use `is` and `is not` for `None` comparisons. `None` is a singleton.

```python
# Good
if result is None:
    ...
if result is not None:
    ...

# Bad
if result == None:
    ...
if not result is None:
    ...
```

### `enumerate`

Use `enumerate` instead of manual index tracking.

```python
# Good
for index, value in enumerate(items):
    print(f"{index}: {value}")

# With start index
for number, value in enumerate(items, start=1):
    print(f"{number}. {value}")

# Bad
index = 0
for value in items:
    print(f"{index}: {value}")
    index += 1
```

### `zip`

Iterate over parallel sequences with `zip`. Use `zip(strict=True)` (3.10+) when the sequences must be the same length.

```python
names = ["Alice", "Bob"]
scores = [95, 87]

for name, score in zip(names, scores, strict=True):
    print(f"{name}: {score}")
```

### Unpacking

Python's unpacking is powerful. Use it.

```python
# Swap
a, b = b, a

# Extended unpacking
first, *rest = [1, 2, 3, 4, 5]
first, *middle, last = [1, 2, 3, 4, 5]

# Ignore values with _
_, value, _ = get_triple()

# Function return
x, y = get_coordinates()

# Dictionary unpacking
defaults = {"color": "red", "size": 10}
config = {**defaults, "size": 20}  # override size
```

### Walrus Operator `:=` (3.8+)

The assignment expression (walrus operator) assigns and evaluates in one step. Use it to avoid redundant computation, but do not overuse it --- readability comes first.

```python
# Good: avoids calling len() twice or using a temp variable
if (n := len(items)) > 10:
    print(f"Too many items: {n}")

# Good: filter and use in comprehension
valid = [result for x in data if (result := process(x)) is not None]

# Good: read loop
while (line := file.readline()):
    process(line)

# Bad: overused, hard to read
if (x := f(a)) and (y := g(x)) and (z := h(y)):
    print(z)
```

### `match`/`case` (3.10+)

Structural pattern matching replaces complex `if`/`elif` chains for destructuring data.

```python
match command:
    case "quit":
        sys.exit(0)
    case "help":
        show_help()
    case str(other):
        print(f"Unknown command: {other}")

# Destructuring
match point:
    case (0, 0):
        print("Origin")
    case (x, 0):
        print(f"On x-axis at {x}")
    case (0, y):
        print(f"On y-axis at {y}")
    case (x, y):
        print(f"Point at ({x}, {y})")
```

### Type Checking with `isinstance`

Use `isinstance` for type checks, never direct type comparison.

```python
# Good
if isinstance(value, str):
    ...

# Good: check against multiple types
if isinstance(value, (int, float)):
    ...

# Bad
if type(value) is str:
    ...
if type(value) == str:
    ...
```

### Ternary Expression

Use conditional expressions for simple cases. For complex logic, use a full `if`/`else` block.

```python
# Good: simple
status = "active" if user.is_active else "inactive"

# Bad: too complex for one line
value = transform(x) if x is not None and validate(x) else default_transform(fallback(x))
```

### Dictionary Access Patterns

```python
# Get with default
value = config.get("key", "default")

# setdefault: get or insert
cache.setdefault(key, []).append(item)

# collections.defaultdict for repeated pattern
from collections import defaultdict
groups = defaultdict(list)
for item in items:
    groups[item.category].append(item)
```

### Use `def` Instead of Assigning Lambdas

If you are assigning a lambda to a name, use `def` instead. Named functions produce better tracebacks and are easier to document.

```python
# Good
def double(x: int) -> int:
    return x * 2

# Bad
double = lambda x: x * 2
```

Lambdas are fine as inline arguments to `sorted()`, `map()`, `filter()`, and similar higher-order functions.

---

## 10. Things to Avoid

### Mutable Default Arguments

This is perhaps the most common Python gotcha. Mutable default arguments are shared across all calls.

```python
# WRONG: the default list is shared between calls
def append_to(element, target=[]):
    target.append(element)
    return target

append_to(1)  # [1]
append_to(2)  # [1, 2] -- not [2]!

# CORRECT: use None and create inside the function
def append_to(element, target=None):
    if target is None:
        target = []
    target.append(element)
    return target
```

### Bare `except`

Never use bare `except:`. It catches `SystemExit`, `KeyboardInterrupt`, and `GeneratorExit`, making your program impossible to interrupt cleanly.

```python
# Wrong
try:
    do_something()
except:
    pass

# Right: catch what you expect
try:
    do_something()
except SpecificError:
    handle_error()
```

### `import *`

Wildcard imports pollute the namespace, hide the origin of names, confuse static analysis tools, and create fragile dependencies.

```python
# Wrong
from os.path import *
from sayableage.locales import *

# Right
from os.path import join, dirname
from sayableage.locales import en, fr
```

### Global Mutable State

Avoid module-level mutable variables. They create hidden coupling between components and make testing difficult.

```python
# Wrong: global mutable state
_cache = {}

def get_locale(code):
    if code not in _cache:
        _cache[code] = load_locale(code)
    return _cache[code]

# Better: use a class or pass the cache explicitly
class LocaleRegistry:
    def __init__(self):
        self._cache: dict[str, AgeLocale] = {}

    def get(self, code: str) -> AgeLocale:
        if code not in self._cache:
            self._cache[code] = load_locale(code)
        return self._cache[code]
```

Module-level **constants** (immutable values with `UPPER_CASE` names) are fine and encouraged.

### Overusing `isinstance` Checks

Excessive type checking at runtime often signals a design problem. Use polymorphism, protocols, or pattern matching instead.

```python
# Smell: manual dispatch
def process(value):
    if isinstance(value, str):
        return handle_string(value)
    elif isinstance(value, int):
        return handle_int(value)
    elif isinstance(value, list):
        return handle_list(value)

# Better: use functools.singledispatch or match/case
from functools import singledispatch

@singledispatch
def process(value):
    raise TypeError(f"Unsupported type: {type(value)}")

@process.register
def _(value: str):
    return handle_string(value)

@process.register
def _(value: int):
    return handle_int(value)
```

### Metaclasses, `__del__`, and Reflection Abuse

These are power features. Application code should almost never need metaclasses, `__del__` methods, bytecode manipulation, or deep reflection. If you think you need them, you probably do not.

### Deeply Nested Code

If you are nesting more than 3 levels deep, refactor. Extract functions, use early returns, or restructure the logic.

```python
# Bad
def process(data):
    if data:
        for item in data:
            if item.is_valid():
                for sub in item.children:
                    if sub.active:
                        handle(sub)

# Good
def process(data):
    if not data:
        return
    for item in data:
        if item.is_valid():
            process_children(item)

def process_children(item):
    for sub in item.children:
        if sub.active:
            handle(sub)
```

### `# type: ignore` Without Explanation

If you must suppress a type error, always explain why:

```python
# Bad
result = some_call()  # type: ignore

# Good
result = some_call()  # type: ignore[return-value]  # returns str at runtime despite Any signature
```

---

## 11. Tooling

### Ruff

[Ruff](https://docs.astral.sh/ruff/) is a fast Python linter and formatter written in Rust. It replaces Flake8, isort, pyupgrade, autoflake, pydocstyle, and Black in a single tool. It runs 10-100x faster than the tools it replaces.

```toml
# pyproject.toml
[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "SIM",  # flake8-simplify
    "RUF",  # ruff-specific rules
]

[tool.ruff.format]
quote-style = "double"
```

Ruff can both lint and format. Use `ruff check` for linting and `ruff format` for formatting.

### mypy

[mypy](https://mypy-lang.org/) is the reference static type checker for Python.

```toml
# pyproject.toml
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
```

Run with `mypy .` or `mypy src/`. The `strict` flag enables all strictness options --- this is the recommended starting point for new projects.

### pyright

[Pyright](https://github.com/microsoft/pyright) is Microsoft's type checker, used in VS Code's Pylance extension. It is faster than mypy and supports some features mypy does not (and vice versa). Using both on CI catches the most issues.

```toml
# pyproject.toml
[tool.pyright]
pythonVersion = "3.12"
typeCheckingMode = "strict"
```

### Black

[Black](https://black.readthedocs.io/) is the standard opinionated formatter. If your project uses Ruff for formatting, Black is redundant --- Ruff's formatter is Black-compatible.

### isort

[isort](https://pycqa.github.io/isort/) sorts imports. Ruff includes isort functionality via the `I` rule set, so a standalone isort installation is unnecessary if you use Ruff.

### pytest

[pytest](https://docs.pytest.org/) is the standard testing framework. Prefer it over `unittest`.

```python
# test_format_age.py
import pytest
from datetime import date
from sayableage import format_age

def test_newborn():
    dob = date(2024, 1, 1)
    as_of = date(2024, 1, 1)
    assert format_age(dob, as_of) == "just born"

def test_invalid_date_raises():
    with pytest.raises(InvalidDateError):
        format_age(date(2024, 6, 1), date(2024, 1, 1))

@pytest.mark.parametrize("dob,as_of,expected", [
    (date(2024, 1, 1), date(2024, 2, 1), "1 month"),
    (date(2024, 1, 1), date(2024, 3, 1), "2 months"),
])
def test_months(dob, as_of, expected):
    assert format_age(dob, as_of) == expected
```

### Recommended Toolchain

| Purpose | Tool |
|---------|------|
| Linting | Ruff |
| Formatting | Ruff (or Black) |
| Import sorting | Ruff (`I` rules) |
| Type checking | mypy and/or pyright |
| Testing | pytest |
| Coverage | pytest-cov / coverage.py |
| Package management | uv (or pip + pip-tools) |

---

## 12. References

### PEPs

- [PEP 8 -- Style Guide for Python Code](https://peps.python.org/pep-0008/) -- The foundational style guide.
- [PEP 20 -- The Zen of Python](https://peps.python.org/pep-0020/) -- Guiding principles (`import this`).
- [PEP 257 -- Docstring Conventions](https://peps.python.org/pep-0257/) -- How to write docstrings.
- [PEP 484 -- Type Hints](https://peps.python.org/pep-0484/) -- Introduction of type hints.
- [PEP 544 -- Protocols: Structural Subtyping](https://peps.python.org/pep-0544/) -- Protocol for duck typing.
- [PEP 557 -- Data Classes](https://peps.python.org/pep-0557/) -- The `@dataclass` decorator.
- [PEP 604 -- Allow writing union types as X | Y](https://peps.python.org/pep-0604/) -- Union syntax (3.10+).
- [PEP 612 -- Parameter Specification Variables](https://peps.python.org/pep-0612/) -- ParamSpec for decorators.
- [PEP 613 -- Explicit Type Aliases](https://peps.python.org/pep-0613/) -- TypeAlias annotation.
- [PEP 673 -- Self Type](https://peps.python.org/pep-0673/) -- Self for return types.
- [PEP 695 -- Type Parameter Syntax](https://peps.python.org/pep-0695/) -- `type` statement and generic syntax (3.12+).

### Style Guides

- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html) -- Comprehensive, opinionated, widely adopted.
- [The Hitchhiker's Guide to Python -- Code Style](https://docs.python-guide.org/writing/style/) -- Practical idioms and patterns.

### Tools

- [Ruff](https://docs.astral.sh/ruff/) -- Fast linter and formatter.
- [mypy](https://mypy-lang.org/) -- Static type checker.
- [Pyright](https://github.com/microsoft/pyright) -- Fast type checker from Microsoft.
- [Black](https://black.readthedocs.io/) -- Opinionated formatter.
- [pytest](https://docs.pytest.org/) -- Testing framework.

### Python Documentation

- [`typing` module](https://docs.python.org/3/library/typing.html) -- Type hints reference.
- [`dataclasses` module](https://docs.python.org/3/library/dataclasses.html) -- Dataclass reference.
- [`collections.abc`](https://docs.python.org/3/library/collections.abc.html) -- Abstract base classes for containers.
- [`itertools`](https://docs.python.org/3/library/itertools.html) -- Iterator building blocks.
- [`pathlib`](https://docs.python.org/3/library/pathlib.html) -- Object-oriented filesystem paths.

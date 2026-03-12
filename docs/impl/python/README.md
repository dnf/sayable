# Python Style Guide

A comprehensive reference for writing idiomatic, maintainable Python. This guide is used for code auditing Python implementations in the Sayable project. It synthesizes conventions from PEP 8, PEP 20, the Google Python Style Guide, and community best practices.

## Table of Contents

1. [Naming Conventions](#1-naming-conventions)
2. [Code Formatting](#2-code-formatting)
3. [Docstrings](#3-docstrings)
4. [Type System](#4-type-system)
5. [Module Design](#5-module-design)
6. [Class Design](#6-class-design)
7. [Error Handling](#7-error-handling)
8. [Collections and Comprehensions](#8-collections-and-comprehensions)
9. [String Handling](#9-string-handling)
10. [Common Idioms](#10-common-idioms)
11. [Things to Avoid](#11-things-to-avoid)
12. [Testing](#12-testing)
13. [Tooling](#13-tooling)
14. [References](#14-references)

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

Use `CapWords` (PascalCase).

```python
class AgeFormatter:       # good
class age_formatter:      # wrong: not CapWords
```

For classes containing acronyms, two conventions are in common use:

```python
class HTTPServerError:    # standard library convention: full-caps acronym
class HttpServerError:    # Google style guide convention: capitalized first letter only
```

The standard library uses full-caps acronyms (`HTTPError`, `HTMLParser`). The Google Python Style Guide capitalizes only the first letter for readability at word boundaries. Either is acceptable --- pick one and be consistent within the project.

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

### Private and Internal

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

### Line Length

This project uses a line length of **88 characters** for all code, comments, and docstrings, matching the Black/Ruff formatter default. This is a deliberate compromise between PEP 8's 79-character recommendation (designed for standard-library code and 80-column terminals) and the practical needs of modern codebases.

PEP 8 itself notes: "Some teams strongly prefer a longer line length. For code maintained exclusively or primarily by a team that can reach agreement on this issue, it is okay to increase the line length limit up to 99 characters."

### PEP 8 Fundamentals

- **Indentation:** 4 spaces. Never tabs. Python 3 forbids mixing tabs and spaces.
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

Surround binary operators with a single space on each side. In function signatures, no spaces around `=` for default values unless the parameter has a type annotation:

```python
# With type annotation: space around =
def format_age(dob: date, as_of: date | None = None) -> str:
    ...

# Without type annotation: no space around =
def format_age(dob, as_of=None):
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

### Formatter: Ruff / Black

[Ruff](https://docs.astral.sh/ruff/) (or [Black](https://black.readthedocs.io/)) is the standard opinionated formatter. Key defaults:

- Line length: 88 characters
- Double quotes for strings
- Trailing commas in multi-line structures
- Consistent parenthesization of long expressions

If the project uses an autoformatter, do not fight it. Let it own all formatting decisions.

---

## 3. Docstrings

[PEP 257](https://peps.python.org/pep-0257/) defines docstring conventions. This project uses **Google-style** docstrings.

### When to Write Docstrings

Write docstrings for:
- All public modules, classes, functions, and methods.
- Non-obvious internal functions (prefix with `_` but still document if the logic is complex).

Omit docstrings for:
- Trivial `__init__` methods where the class docstring suffices.
- Private helper methods where the function name is self-explanatory.

### One-Line Docstrings

Use for functions whose behavior is immediately obvious:

```python
def is_leap_year(year: int) -> bool:
    """Return True if year is a leap year."""
```

The closing `"""` is on the same line. The docstring is a phrase ending in a period. It describes what the function does, not how.

### Multi-Line Docstrings (Google Style)

```python
def format_age(date_of_birth: date, as_of: date, locale: str = "en") -> str:
    """Format a person's age in natural language.

    Computes the age from date_of_birth to as_of and returns a
    human-readable string appropriate for the given locale.

    Args:
        date_of_birth: The person's date of birth.
        as_of: The date to compute age relative to.
        locale: BCP 47 locale code. Defaults to "en".

    Returns:
        A human-readable age string (e.g., "6 weeks", "14 months", "3 years").

    Raises:
        InvalidDateError: If date_of_birth is after as_of.
        UnknownLocaleError: If the locale code is not recognized.
    """
```

### Class Docstrings

Document the class purpose in the class docstring. Document `__init__` parameters there as well, unless `__init__` has complex logic that warrants its own docstring.

```python
class AgeLocale:
    """Locale configuration for age formatting.

    Attributes:
        code: BCP 47 locale code (e.g., "en", "fr").
        just_born: String for age zero (e.g., "just born").
        units: Mapping of unit names to their singular/plural forms.
    """
```

### Module Docstrings

Every module should start with a docstring describing its purpose:

```python
"""Format ages the way humans speak.

This module provides the core formatting logic for the sayable-age
library. It supports 110 locales and produces output matching natural
human speech patterns.
"""
```

---

## 4. Type System

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

### `from __future__ import annotations`

PEP 563 introduced `from __future__ import annotations` to defer annotation evaluation, avoiding forward reference issues and reducing import-time overhead. However, it has important caveats:

- It converts all annotations to strings, breaking code that inspects annotations at runtime. This affects `@dataclass` field introspection, Pydantic models, FastAPI, and `typing.get_type_hints()` in edge cases.
- PEP 649 (accepted for Python 3.14) provides deferred evaluation without stringification, superseding PEP 563 for new code.

**Guidance:** For Python 3.14+, you do not need the future import --- PEP 649 is the default. For Python 3.12-3.13, use the future import only if you need forward references and your code does not inspect annotations at runtime.

### Practical Guidance

- Annotate all public API functions and methods.
- Prefer `X | None` over `Optional[X]`.
- Use abstract types (`Sequence`, `Mapping`, `Iterable`) for parameters; concrete types (`list`, `dict`) for return values.
- Do not annotate `self` or `cls` --- their types are inferred. Always annotate `__init__` with `-> None`.
- Never use `Any` to silence a type checker. If you must, add a comment explaining why.

---

## 5. Module Design

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

`__all__` serves two purposes: it controls what `from module import *` exports, and more importantly, it documents the intended public API of a module at a glance. For published libraries, define `__all__` in every module that has public symbols. For internal modules, the `_` prefix convention is sufficient --- `__all__` is optional.

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

## 6. Class Design

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

Use `@staticmethod` when a function logically belongs to a class's namespace but needs no instance or class state, and especially when subclasses may want to override the behavior:

```python
class Validator:
    @staticmethod
    def is_valid_locale_code(code: str) -> bool:
        return len(code) >= 2 and code.isascii()
```

If a function has no logical association with the class, make it a module-level function instead. Do not use `@classmethod` as a substitute for `@staticmethod` just to avoid the latter --- an unused `cls` parameter misleads readers.

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

## 7. Error Handling

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

### EAFP and LBYL

Python supports two approaches to handling conditions that might fail:

- **EAFP** (Easier to Ask Forgiveness than Permission): use `try`/`except`.
- **LBYL** (Look Before You Leap): check conditions before acting.

Both are idiomatic. Choose based on the situation:

**Use LBYL** when a clean API exists for the check:

```python
# dict.get() is cleaner than try/except KeyError
value = mapping.get(key, default)

# 'in' operator is clearer than catching KeyError
if key in mapping:
    value = mapping[key]
```

**Use EAFP** when the check would be as expensive as the operation, when the failure case is rare, or when you need to avoid TOCTOU (time-of-check-to-time-of-use) races:

```python
# File access: avoid TOCTOU race between exists() and open()
try:
    with open(path) as f:
        data = f.read()
except FileNotFoundError:
    data = default_data

# Permission check: just try it
try:
    os.remove(path)
except PermissionError:
    log.warning("Cannot remove %s", path)
```

**Caution with EAFP:** keep `try` blocks narrow. Broad `try` blocks can catch exceptions from unrelated code:

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

## 8. Collections and Comprehensions

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

## 9. String Handling

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

Two conventions exist for log message formatting, each with valid trade-offs:

**%-style (preferred for libraries and structured logging):**

```python
import logging

logger = logging.getLogger(__name__)

# Deferred formatting: string is only formatted if the log level is enabled.
# Allows log aggregation tools (Sentry, Datadog) to group by message template.
logger.info("Processing locale %s with %d units", code, len(units))
```

**f-strings (acceptable for application code):**

```python
# Eagerly formatted, but more readable for complex expressions.
# The performance cost of f-string formatting is negligible in most code.
logger.info(f"Processing locale {code} with {len(units)} units")
```

Use %-style in libraries and code that feeds structured log aggregation. Use f-strings in application code where readability is the priority and structured grouping is not needed.

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

## 10. Common Idioms

### Truthiness

Python has well-defined truthiness rules. Use them for sequences and booleans:

```python
# Good
if items:            # non-empty sequence
if not items:        # empty sequence
if name:             # non-empty string (when "" means "absent")
if flag:             # boolean

# Bad
if len(items) > 0:
if items != []:
if flag == True:
```

**Caution with numeric and string truthiness:** When `0` or `""` are valid values distinct from "absent" or `None`, use explicit checks:

```python
# Bug: treats 0 the same as None/absent
def process(count=None):
    if count:          # wrong: skips when count is 0
        use(count)

# Correct: distinguish 0 from None
def process(count=None):
    if count is not None:
        use(count)

# Bug: treats "" the same as None
if name:               # wrong if "" is a valid, distinct value
    ...

# Correct:
if name is not None:
    ...
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

### Runtime Type Checking

Minimize runtime type checking in favor of structural typing, protocols, and polymorphism. When runtime type checks are necessary, use `isinstance`, never direct type comparison:

```python
# Good: isinstance when you need a runtime check
if isinstance(value, str):
    ...

# Good: check against multiple types
if isinstance(value, (int, float)):
    ...

# Bad: direct type comparison
if type(value) is str:
    ...
if type(value) == str:
    ...
```

For functions that dispatch on argument type, prefer `functools.singledispatch` or `match`/`case` over `isinstance` chains:

```python
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

For simple multi-type inputs (e.g., accepting `str | Path`), a single `isinstance` check is fine and idiomatic.

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

## 11. Things to Avoid

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

The same principle applies to temporal defaults. `date.today()` as a default argument is evaluated once at function definition time, not at each call:

```python
# WRONG: date.today() is evaluated once when the module loads
def format_age(dob: date, as_of: date = date.today()) -> str:
    ...

# CORRECT: use None sentinel
def format_age(dob: date, as_of: date | None = None) -> str:
    if as_of is None:
        as_of = date.today()
    ...
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

Avoid unstructured module-level mutable variables. They create hidden coupling between components and make testing difficult.

For caching and memoization, use `functools.cache` or `functools.lru_cache` instead of hand-rolled module-level dicts:

```python
# Good: standard library caching
from functools import cache

@cache
def load_locale(code: str) -> AgeLocale:
    return _parse_locale_file(code)

# Acceptable: module-level registry with well-defined access pattern
class LocaleRegistry:
    def __init__(self) -> None:
        self._cache: dict[str, AgeLocale] = {}

    def get(self, code: str) -> AgeLocale:
        if code not in self._cache:
            self._cache[code] = load_locale(code)
        return self._cache[code]

# Avoid: unstructured global mutable state
_cache = {}

def get_locale(code):
    if code not in _cache:
        _cache[code] = load_locale(code)
    return _cache[code]
```

Module-level **constants** (immutable values with `UPPER_CASE` names) are fine and encouraged.

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

## 12. Testing

### Framework

[pytest](https://docs.pytest.org/) is the standard testing framework. Prefer it over `unittest`.

### Naming Conventions

- Test files: `test_<module>.py` (e.g., `test_format_age.py`).
- Test functions: `test_<behavior>` --- describe what is being tested, not how.
- Test classes (optional): `TestFormatAge`, `TestLocaleLoading`.

```python
# Good: describes the behavior
def test_newborn_returns_just_born():
    ...

def test_negative_age_raises_invalid_date_error():
    ...

# Bad: describes the implementation
def test_format_age_function():
    ...
```

### Basic Tests

```python
import pytest
from datetime import date
from sayableage import format_age

def test_newborn():
    """T001: just born."""
    dob = date(2024, 1, 1)
    as_of = date(2024, 1, 1)
    assert format_age(dob, as_of) == "just born"

def test_invalid_date_raises():
    """T099: future date of birth."""
    with pytest.raises(InvalidDateError):
        format_age(date(2024, 6, 1), date(2024, 1, 1))
```

### Parametrize

Use `@pytest.mark.parametrize` for testing the same behavior with different inputs. This is especially useful for spec-driven tests:

```python
@pytest.mark.parametrize("dob,as_of,expected", [
    (date(2024, 1, 1), date(2024, 2, 1), "1 month"),      # T010
    (date(2024, 1, 1), date(2024, 3, 1), "2 months"),     # T011
    (date(2024, 1, 1), date(2024, 7, 1), "6 months"),     # T015
])
def test_months(dob, as_of, expected):
    assert format_age(dob, as_of) == expected
```

### Fixtures

Use fixtures for shared setup. Prefer the narrowest scope that works:

```python
@pytest.fixture
def en_locale():
    return AgeLocale.from_code("en")

@pytest.fixture(scope="module")
def locale_registry():
    """Expensive setup shared across all tests in the module."""
    return LocaleRegistry.load_all()

def test_english_formatting(en_locale):
    result = format_with_locale(date(2024, 1, 1), date(2024, 2, 1), en_locale)
    assert result == "1 month"
```

Place shared fixtures in `conftest.py`. pytest automatically discovers fixtures from `conftest.py` files at each directory level.

### Test Organization

```
tests/
    conftest.py          # shared fixtures
    test_format_age.py   # core formatting tests
    test_locales.py      # locale loading and validation
    test_plural_rules.py # plural rule tests
```

### What Not to Mock

Do not mock the code under test. Mock external dependencies (network, filesystem, time) when necessary. For pure functions like age formatting, prefer real inputs and outputs over mocks.

---

## 13. Tooling

### Ruff

[Ruff](https://docs.astral.sh/ruff/) is a fast Python linter and formatter written in Rust. It replaces Flake8, isort, pyupgrade, autoflake, pydocstyle, and Black in a single tool. It runs 10-100x faster than the tools it replaces.

```toml
# pyproject.toml
[tool.ruff]
target-version = "py312"
line-length = 88

[tool.ruff.lint]
select = [
    "E",     # pycodestyle errors
    "W",     # pycodestyle warnings
    "F",     # pyflakes
    "I",     # isort
    "UP",    # pyupgrade
    "B",     # flake8-bugbear
    "SIM",   # flake8-simplify
    "RUF",   # ruff-specific rules
    "N",     # pep8-naming
    "C4",    # flake8-comprehensions
    "PTH",   # flake8-use-pathlib
    "PERF",  # perflint
    "T20",   # flake8-print (catches stray print() in library code)
]

[tool.ruff.format]
quote-style = "double"
```

This is a starting point. See [Ruff's rule documentation](https://docs.astral.sh/ruff/rules/) for additional rule sets (`PL` for pylint rules, `ANN` for annotation enforcement, `D` for docstring checks, etc.).

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

## 14. References

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
- [PEP 649 -- Deferred Evaluation of Annotations](https://peps.python.org/pep-0649/) -- Replaces PEP 563 in Python 3.14+.
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

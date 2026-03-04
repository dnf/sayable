# sayable-age — Python

A thoughtful time formatting library that reflects how we think about little ones.

```python
format_age("2025-06-01", "2025-06-15")  # "2 weeks"
format_age("2025-01-15", "2025-07-15")  # "6 months"
format_age("2022-06-15", "2025-12-15")  # "3½ years"
```

## Installation

```bash
pip install sayable-age
```

Requires Python 3.10+. Zero runtime dependencies.

## Usage

```python
from sayable_age import format_age, format_stage

# Human-readable age string
format_age("2025-06-15", "2025-06-15")  # "Newborn"
format_age("2025-06-01", "2025-06-15")  # "2 weeks"
format_age("2025-01-15", "2025-07-15")  # "6 months"
format_age("2024-06-15", "2025-06-15")  # "12 months"
format_age("2023-06-15", "2025-07-15")  # "2 years, 1 month"
format_age("2022-06-15", "2025-12-15")  # "3½ years"
format_age("2018-06-15", "2025-06-15")  # "7 years"

# Developmental stage label
format_stage("2025-06-15", "2025-06-15")  # "Newborn"
format_stage("2025-01-15", "2025-06-15")  # "Infant"
format_stage("2024-06-15", "2025-06-15")  # "Toddler"
format_stage("2022-06-15", "2025-06-15")  # "Child"
format_stage("2012-06-15", "2025-06-15")  # "Teenager"
format_stage("2007-06-15", "2025-06-15")  # "Adult"

# Defaults to today if no reference date given
format_age("2020-01-01")  # "5 years" (if today is 2025-06-15)

# Returns None for None/empty/future dates or ages exceeding 500 years
format_age(None)                          # None
format_stage("2030-01-01", "2025-06-15")  # None
```

## Internationalization

```python
from sayable_age import SayableAge, JA

pt = SayableAge(JA)
pt.format_age("2025-01-01", "2025-07-15")   # "6ヶ月"
pt.format_stage("2025-01-01", "2025-07-15") # "乳児"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```python
from sayable_age import SayableAge, EN

normal  = SayableAge(EN)                 # "3 months", "2 years, 1 month"
short   = SayableAge(EN, "short")        # "3 mo", "2 yr, 1 mo"
compact = SayableAge(EN, "compact")      # "3m", "2y1m"
```

## API

```python
class SayableAge:
    def __init__(self, locale: AgeLocale, compactness: Compactness = "normal") -> None: ...
    def format_age(self, date_of_birth: str | None, as_of: str | None = None) -> str | None: ...
    def format_stage(self, date_of_birth: str | None, as_of: str | None = None) -> str | None: ...

# Bare functions — English default
def format_age(date_of_birth: str | None, as_of: str | None = None) -> str | None: ...
def format_stage(date_of_birth: str | None, as_of: str | None = None) -> str | None: ...
```

**Parameters:**

- `date_of_birth` — `YYYY-MM-DD` string. Returns `None` if `None` or empty.
- `as_of` — Reference date as `YYYY-MM-DD`. Defaults to today.

**Returns:** A human-readable string, or `None` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
pip install -e ".[dev]"   # Install with dev dependencies
pytest tests/ -v          # Run tests
ruff check src/ tests/    # Lint
pyright                   # Type check
```

## Code quality

- ruff with 11 rule categories
- pyright in strict mode
- See [code quality docs](../../docs/code-quality-dynamic.md#python) for details

## License

[MIT](../../LICENSE.md)

# parent-time

Human-friendly age formatting the way parents actually talk.

```
"Newborn" · "2 weeks, 4 days" · "14 months" · "2 years, 3 months" · "4½ years"
```

Most age-formatting libraries just give you years, or maybe years and months. But parents of young children don't say "0 years" — they say "she's 6 weeks old" or "he just turned 14 months." `parent-time` formats ages the way parents, pediatricians, and baby apps actually talk.

## Functions

### `formatAge` / `format_age` / `FormatAge`

Returns a human-readable age string with granularity that matches the child's developmental stage:

| Age range | Format | Examples |
|---|---|---|
| Born today | `"Newborn"` | Newborn |
| 1–6 days | `"N days"` | 1 day, 5 days |
| 1 week – <3 months | `"N weeks, N days"` | 2 weeks, 3 weeks, 4 days |
| 3–23 months | `"N months"` | 3 months, 14 months |
| 24–35 months | `"N years, N months"` | 2 years, 2 years, 7 months |
| 3–6 years | `"N years"` / `"N½ years"` | 3 years, 3½ years, 5½ years |
| 7+ years | `"N years"` | 7 years, 45 years |

Calendar-month boundaries use **day-of-month clamping**: a child born on the 31st turns N months old on the last day of a shorter month (e.g., Feb 28/29, Apr 30).

### `formatStage` / `format_stage` / `FormatStage`

Returns the developmental stage label (AAP/CDC consensus boundaries):

| Stage | Age range |
|---|---|
| Newborn | 0–1 months |
| Infant | 2–11 months |
| Toddler | 1–2 years |
| Child | 3–12 years |
| Teenager | 13–17 years |
| Adult | 18+ years |

## Installation

### TypeScript / JavaScript

```bash
npm install parent-time
```

### Python

```bash
pip install parent-time
```

### Go

```bash
go get github.com/dnf/parent-time/go
```

### Ruby

```ruby
# Gemfile
gem "parent_time"
```

## Usage

### TypeScript

```typescript
import { formatAge, formatStage } from 'parent-time';

// formatAge — human-readable age string
formatAge('2025-06-15', '2025-06-15');  // "Newborn"
formatAge('2025-06-01', '2025-06-15');  // "2 weeks"
formatAge('2025-05-31', '2025-06-15');  // "2 weeks, 1 day"
formatAge('2025-01-15', '2025-07-15');  // "6 months"
formatAge('2024-06-15', '2025-06-15');  // "12 months"
formatAge('2023-06-15', '2025-07-15');  // "2 years, 1 month"
formatAge('2022-06-15', '2025-12-15');  // "3½ years"
formatAge('2018-06-15', '2025-06-15');  // "7 years"

// formatStage — developmental stage label
formatStage('2025-06-15', '2025-06-15');  // "Newborn"
formatStage('2025-01-15', '2025-06-15');  // "Infant"
formatStage('2024-06-15', '2025-06-15');  // "Toddler"
formatStage('2022-06-15', '2025-06-15');  // "Child"
formatStage('2019-06-15', '2025-06-15');  // "Child"
formatStage('2012-06-15', '2025-06-15');  // "Teenager"
formatStage('2007-06-15', '2025-06-15');  // "Adult"

// Defaults to today if no reference date given
formatAge('2020-01-01');                // "5 years" (if today is 2025-06-15)

// Returns null for null/undefined/empty/future dates
formatAge(null);                        // null
formatStage('2030-01-01', '2025-06-15');  // null
```

### Python

```python
from parent_time import format_age, format_stage

# format_age — human-readable age string
format_age("2025-06-15", "2025-06-15")  # "Newborn"
format_age("2025-06-01", "2025-06-15")  # "2 weeks"
format_age("2025-05-31", "2025-06-15")  # "2 weeks, 1 day"
format_age("2025-01-15", "2025-07-15")  # "6 months"
format_age("2024-06-15", "2025-06-15")  # "12 months"
format_age("2023-06-15", "2025-07-15")  # "2 years, 1 month"
format_age("2022-06-15", "2025-12-15")  # "3½ years"
format_age("2018-06-15", "2025-06-15")  # "7 years"

# format_stage — developmental stage label
format_stage("2025-06-15", "2025-06-15")  # "Newborn"
format_stage("2025-01-15", "2025-06-15")  # "Infant"
format_stage("2024-06-15", "2025-06-15")  # "Toddler"
format_stage("2022-06-15", "2025-06-15")  # "Child"
format_stage("2019-06-15", "2025-06-15")  # "Child"
format_stage("2012-06-15", "2025-06-15")  # "Teenager"
format_stage("2007-06-15", "2025-06-15")  # "Adult"

# Defaults to today if no reference date given
format_age("2020-01-01")                # "5 years" (if today is 2025-06-15)

# Returns None for None/empty/future dates
format_age(None)                        # None
format_stage("2030-01-01", "2025-06-15")  # None
```

### Go

```go
package main

import (
    "fmt"
    parenttime "github.com/dnf/parent-time/go"
)

func main() {
    // Package-level functions — English default
    age := parenttime.FormatAge("2025-01-15", "2025-07-15")
    fmt.Println(*age)  // "6 months"

    stage := parenttime.FormatStage("2025-01-15", "2025-06-15")
    fmt.Println(*stage)  // "Infant"

    // Returns nil for empty/future dates
    fmt.Println(parenttime.FormatAge(""))  // <nil>

    // Class-based with locale
    pt := parenttime.NewParentTime(parenttime.EN)
    fmt.Println(*pt.FormatAge("2022-06-15", "2025-12-15"))  // "3½ years"
    fmt.Println(*pt.FormatStage("2022-06-15", "2025-06-15")) // "Child"
}
```

### Ruby

```ruby
require "parent_time"

# Module-level methods — English default
ParentTime.format_age("2025-01-15", "2025-07-15")  # "6 months"
ParentTime.format_stage("2025-01-15", "2025-06-15") # "Infant"

# Returns nil for nil/empty/future dates
ParentTime.format_age(nil)  # nil

# Class-based with locale
pt = ParentTime::Formatter.new(ParentTime::Locales::EN)
pt.format_age("2022-06-15", "2025-12-15")   # "3½ years"
pt.format_stage("2022-06-15", "2025-06-15") # "Child"
```

## Internationalization (i18n)

`parent-time` supports formatting ages in any language via locale objects. The `ParentTime` class takes a locale at construction time:

### TypeScript

```typescript
import { ParentTime, en, type AgeLocale } from 'parent-time';

// Use built-in English locale
const pt = new ParentTime(en);
pt.formatAge('2025-01-01', '2025-07-15');   // "6 months"
pt.formatStage('2025-01-01', '2025-07-15'); // "Infant"

// Create a custom locale
const ja: AgeLocale = {
  code: 'ja',
  plural: () => 'other',  // Japanese has no plural forms
  units: {
    day:   '{n}日',
    week:  '{n}週',
    month: '{n}ヶ月',
    year:  '{n}歳',
  },
  half: '半',
  delimiter: '',
  justBorn: '新生児',
  stages: {
    newborn: '新生児', infant: '乳児', toddler: '幼児',
    child: '子供', teenager: '十代', adult: '成人',
  },
};

const ptJa = new ParentTime(ja);
ptJa.formatAge('2025-01-01', '2025-07-15');   // "6ヶ月"
ptJa.formatStage('2025-01-01', '2025-07-15'); // "乳児"
```

### Python

```python
from parent_time import ParentTime, EN, AgeLocale

# Use built-in English locale
pt = ParentTime(EN)
pt.format_age("2025-01-01", "2025-07-15")   # "6 months"
pt.format_stage("2025-01-01", "2025-07-15") # "Infant"

# Create a custom locale
ja = AgeLocale(
    code="ja",
    plural=lambda _: "other",
    units={
        "day": "{n}日", "week": "{n}週",
        "month": "{n}ヶ月", "year": "{n}歳",
    },
    half="半",
    delimiter="",
    just_born="新生児",
    stages={
        "newborn": "新生児", "infant": "乳児", "toddler": "幼児",
        "child": "子供", "teenager": "十代", "adult": "成人",
    },
)

pt_ja = ParentTime(ja)
pt_ja.format_age("2025-01-01", "2025-07-15")   # "6ヶ月"
pt_ja.format_stage("2025-01-01", "2025-07-15") # "乳児"
```

### Go

```go
pt := parenttime.NewParentTime(parenttime.JA)
age := pt.FormatAge("2025-01-01", "2025-07-15")
fmt.Println(*age)  // "6ヶ月"
```

### Ruby

```ruby
pt = ParentTime::Formatter.new(ParentTime::Locales::JA)
pt.format_age("2025-01-01", "2025-07-15")  # "6ヶ月"
```

The standalone `formatAge` / `format_age` / `FormatAge` and `formatStage` / `format_stage` / `FormatStage` functions default to English and are fully backward compatible.

### Compactness

Each `ParentTime` instance can use one of three compactness levels:

```typescript
import { ParentTime, en } from 'parent-time';

const normal  = new ParentTime(en);            // "3 months", "2 years, 1 month"
const short   = new ParentTime(en, 'short');   // "3 mo", "2 yr, 1 mo"
const compact = new ParentTime(en, 'compact'); // "3m", "2y1m"
```

```python
from parent_time import ParentTime, EN

normal  = ParentTime(EN)                 # "3 months", "2 years, 1 month"
short   = ParentTime(EN, "short")        # "3 mo", "2 yr, 1 mo"
compact = ParentTime(EN, "compact")      # "3m", "2y1m"
```

```go
normal  := parenttime.NewParentTime(parenttime.EN)              // "3 months", "2 years, 1 month"
short   := parenttime.NewParentTime(parenttime.EN, parenttime.Short)   // "3 mo", "2 yr, 1 mo"
compact := parenttime.NewParentTime(parenttime.EN, parenttime.Compact) // "3m", "2y1m"
```

```ruby
normal  = ParentTime::Formatter.new(ParentTime::Locales::EN)                       # "3 months", "2 years, 1 month"
short   = ParentTime::Formatter.new(ParentTime::Locales::EN, compactness: :short)   # "3 mo", "2 yr, 1 mo"
compact = ParentTime::Formatter.new(ParentTime::Locales::EN, compactness: :compact) # "3m", "2y1m"
```

Compactness overrides are defined per-locale. Currently the English locale provides distinct short and compact forms; all other built-in locales return the same output for all three levels (you can add overrides for any locale via the `short` and `compact` fields).

### Built-in locales

| Code | Language | Import |
|------|----------|--------|
| `en` | English | `en` (TS) / `EN` (Python/Go/Ruby) |
| `ar` | Arabic | `ar` / `AR` |
| `bn` | Bengali | `bn` / `BN` |
| `de` | German | `de` / `DE` |
| `es` | Spanish | `es` / `ES` |
| `fa` | Persian (Farsi) | `fa` / `FA` |
| `fr` | French | `fr` / `FR` |
| `gu` | Gujarati | `gu` / `GU` |
| `hi` | Hindi | `hi` / `HI` |
| `it` | Italian | `it` / `IT` |
| `ja` | Japanese | `ja` / `JA` |
| `jv` | Javanese | `jv` / `JV` |
| `ko` | Korean | `ko` / `KO` |
| `mr` | Marathi | `mr` / `MR` |
| `ms` | Malay | `ms` / `MS` |
| `pa` | Punjabi | `pa` / `PA` |
| `pt` | Portuguese | `pt` / `PT` |
| `ru` | Russian | `ru` / `RU` |
| `ta` | Tamil | `ta` / `TA` |
| `te` | Telugu | `te` / `TE` |
| `th` | Thai | `th` / `TH` |
| `tr` | Turkish | `tr` / `TR` |
| `ur` | Urdu | `ur` / `UR` |
| `vi` | Vietnamese | `vi` / `VI` |
| `zh` | Chinese | `zh` / `ZH` |

```typescript
import { ParentTime, ja } from 'parent-time';
const pt = new ParentTime(ja);
pt.formatAge('2025-01-01', '2025-07-15'); // "6ヶ月"
```

```python
from parent_time import ParentTime, JA
pt = ParentTime(JA)
pt.format_age("2025-01-01", "2025-07-15")  # "6ヶ月"
```

```go
pt := parenttime.NewParentTime(parenttime.JA)
fmt.Println(*pt.FormatAge("2025-01-01", "2025-07-15"))  // "6ヶ月"
```

```ruby
pt = ParentTime::Formatter.new(ParentTime::Locales::JA)
pt.format_age("2025-01-01", "2025-07-15")  # "6ヶ月"
```

### Locale object

| Field | Type | Description |
|-------|------|-------------|
| `code` | `string` | BCP 47 language tag |
| `plural` | `(count) → PluralCategory` | CLDR plural rule (`zero`, `one`, `two`, `few`, `many`, `other`) |
| `units` | `{ day, week, month, year }` | `string` template or `{ one, other, … }` map — use `{n}` as placeholder |
| `half` | `string` | Half-year template — `{n}` modifies the number (e.g. `"{n}½"` → "3½ years"), `{0}` wraps the expression (e.g. `"{0}半"` → "3歳半") |
| `short?` | `CompactnessOverride` | Optional overrides for short display mode |
| `compact?` | `CompactnessOverride` | Optional overrides for compact display mode |
| `delimiter` | `string` | Separator between compound parts (e.g. `", "`) |
| `justBorn` | `string` | Day-zero label (e.g. `"Newborn"`) |
| `stages` | `{ newborn, infant, … }` | Stage name strings |
| `formatNumber?` | `(n) → string` | Override number rendering (e.g. for non-Latin digits) |
| `formatUnit?` | `(count, label) → string` | Override final unit assembly (e.g. for word order) |

## API

### TypeScript

```typescript
// Class — locale set once at construction
class ParentTime {
  constructor(locale: AgeLocale, compactness?: Compactness);
  formatAge(dateOfBirth: string | null | undefined, asOf?: string): string | null;
  formatStage(dateOfBirth: string | null | undefined, asOf?: string): string | null;
}

// Bare functions — English default, backward compatible
function formatAge(dateOfBirth: string | null | undefined, asOf?: string): string | null
function formatStage(dateOfBirth: string | null | undefined, asOf?: string): string | null
```

### Python

```python
# Class — locale set once at construction
class ParentTime:
    def __init__(self, locale: AgeLocale, compactness: Compactness = "normal") -> None: ...
    def format_age(self, date_of_birth: str | None, as_of: str | None = None) -> str | None: ...
    def format_stage(self, date_of_birth: str | None, as_of: str | None = None) -> str | None: ...

# Bare functions — English default, backward compatible
def format_age(date_of_birth: str | None, as_of: str | None = None) -> str | None
def format_stage(date_of_birth: str | None, as_of: str | None = None) -> str | None
```

### Go

```go
// Struct — locale set once at construction
type ParentTime struct { ... }
func NewParentTime(locale AgeLocale, compactness ...Compactness) *ParentTime
func (pt *ParentTime) FormatAge(dateOfBirth string, asOf ...string) *string
func (pt *ParentTime) FormatStage(dateOfBirth string, asOf ...string) *string

// Package-level functions — English default
func FormatAge(dateOfBirth string, asOf ...string) *string
func FormatStage(dateOfBirth string, asOf ...string) *string
```

### Ruby

```ruby
# Class — locale set once at construction
class ParentTime::Formatter
  def initialize(locale, compactness: :normal)
  def format_age(date_of_birth, as_of = nil) # => String or nil
  def format_stage(date_of_birth, as_of = nil) # => String or nil
end

# Module-level methods — English default
ParentTime.format_age(date_of_birth, as_of = nil) # => String or nil
ParentTime.format_stage(date_of_birth, as_of = nil) # => String or nil
```

**Parameters:**

- `dateOfBirth` / `date_of_birth` — Date of birth as a `YYYY-MM-DD` string. Returns `null`/`None`/`nil` if `null`, `undefined`, `None`, `nil`, or empty.
- `asOf` / `as_of` — Reference date as a `YYYY-MM-DD` string. Defaults to today.

**Returns:** A human-readable string, or `null`/`None`/`nil` if the input is missing or the date of birth is in the future.

## Why not just use moment/dayjs/date-fns?

Those libraries calculate precise durations, but none of them format ages the way parents talk. You'd need to write the tiered logic yourself — handle the newborn case, switch from weeks to months at 3 months, keep saying "months" until 24 months instead of switching to years, show years+months for toddlers... and get the short-month clamping right for February and 30-day months.

That's exactly what `parent-time` does, in two zero-dependency functions, tested against 145+ deterministic date pairs including leap years, born-on-31st edge cases, and cross-year February boundaries.

## Design decisions

- **Zero dependencies.** Pure date arithmetic — no runtime deps in any language.
- **Deterministic.** Every test uses explicit `(dob, asOf)` pairs. No flaky tests from "today."
- **Calendar-month clamping.** Born Jan 31 → turns 1 month on Feb 28 (or 29 in a leap year). This matches how hospitals and pediatricians count months.
- **"Months" not "1 year" at 12 months.** Parents say "he's 14 months" until about 2 years. The library follows this convention.
- **½ marker for 3–6 year olds.** Parents say "she's four and a half." The ½ character (U+00BD) kicks in at 6+ months and drops off at age 7.
- **"Newborn" at 0 days.** Because nobody says "0 days old."
- **Stage boundaries follow AAP/CDC.** Newborn (<2 mo), Infant (2–11 mo), Toddler (1–2 yr), Child (3–12 yr), Teenager (13–17 yr), Adult (18+).
- **i18n via locale objects.** No framework, no dependency — just a plain data object with a pluralization callback. Supports any language's plural rules, number formatting, and word order.

## Contributing

All four implementations share identical test cases. If you add a test, add it in all directories.

```bash
# TypeScript
cd typescript && npm test

# Python
cd python && pytest

# Go
cd go && go test -v ./...

# Ruby
cd ruby && bundle exec rake test
```

## License

MIT

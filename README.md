# parent-time

Human-friendly age formatting the way parents actually talk.

```
"Newborn" · "2 weeks, 4 days" · "14 months" · "2 years, 3 months" · "4½ years"
```

Most age-formatting libraries just give you years, or maybe years and months. But parents of young children don't say "0 years" — they say "she's 6 weeks old" or "he just turned 14 months." `parent-time` formats ages the way parents, pediatricians, and baby apps actually talk:

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

## Installation

### TypeScript / JavaScript

```bash
npm install parent-time
```

### Python

```bash
pip install parent-time
```

## Usage

### TypeScript

```typescript
import { formatAge } from 'parent-time';

// Born today
formatAge('2025-06-15', '2025-06-15');  // "Newborn"

// Newborn in weeks + days
formatAge('2025-06-01', '2025-06-15');  // "2 weeks"
formatAge('2025-05-31', '2025-06-15');  // "2 weeks, 1 day"

// Baby in months
formatAge('2025-01-15', '2025-07-15');  // "6 months"
formatAge('2024-06-15', '2025-06-15');  // "12 months"

// Toddler in years + months
formatAge('2023-06-15', '2025-07-15');  // "2 years, 1 month"

// Preschooler with half-year marker
formatAge('2022-06-15', '2025-06-15');  // "3 years"
formatAge('2022-06-15', '2025-12-15');  // "3½ years"

// Older child / adult in years
formatAge('2018-06-15', '2025-06-15');  // "7 years"

// Defaults to today if no reference date given
formatAge('2020-01-01');                // "5 years" (if today is 2025-06-15)

// Returns null for null/undefined/empty/future dates
formatAge(null);                        // null
formatAge('2030-01-01', '2025-06-15');  // null
```

### Python

```python
from parent_time import format_age

# Born today
format_age("2025-06-15", "2025-06-15")  # "Newborn"

# Newborn in weeks + days
format_age("2025-06-01", "2025-06-15")  # "2 weeks"
format_age("2025-05-31", "2025-06-15")  # "2 weeks, 1 day"

# Baby in months
format_age("2025-01-15", "2025-07-15")  # "6 months"
format_age("2024-06-15", "2025-06-15")  # "12 months"

# Toddler in years + months
format_age("2023-06-15", "2025-07-15")  # "2 years, 1 month"

# Preschooler with half-year marker
format_age("2022-06-15", "2025-06-15")  # "3 years"
format_age("2022-06-15", "2025-12-15")  # "3½ years"

# Older child / adult in years
format_age("2018-06-15", "2025-06-15")  # "7 years"

# Defaults to today if no reference date given
format_age("2020-01-01")                # "5 years" (if today is 2025-06-15)

# Returns None for None/empty/future dates
format_age(None)                        # None
format_age("2030-01-01", "2025-06-15")  # None
```

## API

### TypeScript

```typescript
function formatAge(
  dateOfBirth: string | null | undefined,
  asOf?: string
): string | null
```

### Python

```python
def format_age(
    date_of_birth: str | None,
    as_of: str | None = None,
) -> str | None
```

**Parameters:**

- `dateOfBirth` / `date_of_birth` — Date of birth as a `YYYY-MM-DD` string. Returns `null`/`None` if `null`, `undefined`, `None`, or empty.
- `asOf` / `as_of` — Reference date as a `YYYY-MM-DD` string. Defaults to today.

**Returns:** A human-readable age string, or `null`/`None` if the input is missing or the date of birth is in the future.

## Why not just use moment/dayjs/date-fns?

Those libraries calculate precise durations, but none of them format ages the way parents talk. You'd need to write the tiered logic yourself — handle the newborn case, switch from weeks to months at 3 months, keep saying "months" until 24 months instead of switching to years, show years+months for toddlers... and get the short-month clamping right for February and 30-day months.

That's exactly what `parent-time` does, in a single zero-dependency function, tested against 80 deterministic date pairs including leap years, born-on-31st edge cases, and cross-year February boundaries.

## Design decisions

- **Zero dependencies.** Pure date arithmetic — no runtime deps in either language.
- **Deterministic.** Every test uses explicit `(dob, asOf)` pairs. No flaky tests from "today."
- **Calendar-month clamping.** Born Jan 31 → turns 1 month on Feb 28 (or 29 in a leap year). This matches how hospitals and pediatricians count months.
- **"Months" not "1 year" at 12 months.** Parents say "he's 14 months" until about 2 years. The library follows this convention.
- **½ marker for 3–6 year olds.** Parents say "she's four and a half." The ½ character (U+00BD) kicks in at 6+ months and drops off at age 7.
- **"Newborn" at 0 days.** Because nobody says "0 days old."

## Contributing

Both implementations share identical test cases. If you add a test, add it in both `typescript/tests/` and `python/tests/`.

```bash
# TypeScript
cd typescript && npm test

# Python
cd python && pytest
```

## License

MIT

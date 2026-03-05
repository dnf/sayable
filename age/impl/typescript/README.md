# sayable-age — TypeScript

Human-friendly age formatting — how parents actually talk about little ones.

```typescript
formatAge('2025-06-01', '2025-06-15');  // "2 weeks"
formatAge('2025-01-15', '2025-07-15');  // "6 months"
formatAge('2022-06-15', '2025-12-15');  // "3½ years"
```

## Installation

```bash
npm install sayable-age
```

## Usage

```typescript
import { formatAge, formatStage } from 'sayable-age';

// Human-readable age string
formatAge('2025-06-15', '2025-06-15');  // "Newborn"
formatAge('2025-06-01', '2025-06-15');  // "2 weeks"
formatAge('2025-01-15', '2025-07-15');  // "6 months"
formatAge('2024-06-15', '2025-06-15');  // "12 months"
formatAge('2023-06-15', '2025-07-15');  // "2 years, 1 month"
formatAge('2022-06-15', '2025-12-15');  // "3½ years"
formatAge('2018-06-15', '2025-06-15');  // "7 years"

// Developmental stage label
formatStage('2025-06-15', '2025-06-15');  // "Newborn"
formatStage('2025-01-15', '2025-06-15');  // "Infant"
formatStage('2024-06-15', '2025-06-15');  // "Toddler"
formatStage('2022-06-15', '2025-06-15');  // "Child"
formatStage('2012-06-15', '2025-06-15');  // "Teenager"
formatStage('2007-06-15', '2025-06-15');  // "Adult"

// Defaults to today if no reference date given
formatAge('2020-01-01');  // "5 years" (if today is 2025-06-15)

// Returns null for null/undefined/empty/future dates or ages exceeding 500 years
formatAge(null);                          // null
formatStage('2030-01-01', '2025-06-15');  // null
```

## Internationalization

```typescript
import { SayableAge, ja } from 'sayable-age';

const pt = new SayableAge(ja);
pt.formatAge('2025-01-01', '2025-07-15');   // "6ヶ月"
pt.formatStage('2025-01-01', '2025-07-15'); // "乳児"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```typescript
import { SayableAge, en } from 'sayable-age';

const normal  = new SayableAge(en);            // "3 months", "2 years, 1 month"
const short   = new SayableAge(en, 'short');   // "3 mo", "2 yr, 1 mo"
const compact = new SayableAge(en, 'compact'); // "3m", "2y1m"
```

## API

```typescript
// Class — locale set once at construction
class SayableAge {
  constructor(locale: AgeLocale, compactness?: Compactness);
  formatAge(dateOfBirth: string | null | undefined, asOf?: string): string | null;
  formatStage(dateOfBirth: string | null | undefined, asOf?: string): string | null;
}

// Bare functions — English default
function formatAge(dateOfBirth: string | null | undefined, asOf?: string): string | null
function formatStage(dateOfBirth: string | null | undefined, asOf?: string): string | null
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `null` if `null`, `undefined`, or empty.
- `asOf` — Reference date as `YYYY-MM-DD`. Defaults to today.

**Returns:** A human-readable string, or `null` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
npm run build    # Build with tsup
npm run lint     # Type check + ESLint
npm test         # Run vitest
```

## Code quality

- TypeScript `strict` + 7 additional flags (see `tsconfig.json`)
- ESLint with `@typescript-eslint/strict-type-checked`
- See [code quality docs](../../docs/code-quality-dynamic.md#typescript) for details

## License

[MIT](../../LICENSE.md)

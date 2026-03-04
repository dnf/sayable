# sayable-date (TypeScript)

Human-friendly date formatting — how people reference dates in conversation.

## Installation

```bash
npm install sayable-date
```

## Usage

```typescript
import { SayableDate, en, formatDate, formatRelative } from 'sayable-date';

// Using convenience functions (English, normal compactness)
formatDate('2025-03-15');                          // "March 15th"
formatRelative('2025-03-16', '2025-03-15');        // "tomorrow"

// Using the class for locale and compactness control
const sd = new SayableDate(en);
sd.formatDate('2025-03-15');                        // "March 15th"
sd.formatRelative('2025-03-16', '2025-03-15');     // "tomorrow"
sd.formatRelative('2025-03-20', '2025-03-15');     // "this Thursday"
sd.formatRelative('2025-04-10', '2025-03-15');     // "April 10th"

// Short compactness
const sdShort = new SayableDate(en, 'short');
sdShort.formatDate('2025-03-15');                   // "Mar 15"

// Compact
const sdCompact = new SayableDate(en, 'compact');
sdCompact.formatDate('2025-03-15');                 // "3/15"
```

## API

### `new SayableDate(locale, compactness?)`

Create a formatter with a specific locale and compactness level.

- **locale**: A `DateLocale` object (e.g., `en`, `de`, `fr`, `ja`)
- **compactness**: `'normal'` | `'short'` | `'compact'` (default: `'normal'`)

### `formatDate(date): string | null`

Format a calendar date. Always absolute — no proximity logic.

### `formatRelative(date, asOf): string | null`

Format a date relative to `asOf`, picking the most natural reference.

Returns `null` for invalid input.

## Locales

71 locales available. Import by code:

```typescript
import { de } from 'sayable-date/locales/de.js';
import { getLocale } from 'sayable-date';

const locale = getLocale('fr');  // look up by code string
```

## License

[MIT](../../../LICENSE.md)

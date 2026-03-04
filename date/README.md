# sayable-date

Human-friendly date formatting — how people reference dates in conversation.

Part of the [Sayable](https://github.com/dnf/sayable) family of formatting libraries.

## Features

- **format_date** — Formats dates in locale-appropriate form ("March 15th", "15. März", "3月15日")
- **format_relative** — Picks the most natural reference ("today", "tomorrow", "next Thursday", "April 10th")
- Three compactness levels: normal, short, compact
- 71 locales
- Zero runtime dependencies
- Python and TypeScript implementations

## Quick Start

```python
from sayable_date import SayableDate, EN

sd = SayableDate(EN)
sd.format_date("2025-03-15")                             # "March 15th"
sd.format_relative("2025-03-16", as_of="2025-03-15")    # "tomorrow"
sd.format_relative("2025-03-20", as_of="2025-03-15")    # "this Thursday"
sd.format_relative("2025-04-10", as_of="2025-03-15")    # "April 10th"
```

```typescript
import { SayableDate, en } from 'sayable-date';

const sd = new SayableDate(en);
sd.formatDate('2025-03-15');                             // "March 15th"
sd.formatRelative('2025-03-16', '2025-03-15');           // "tomorrow"
```

## License

[MIT](LICENSE.md)

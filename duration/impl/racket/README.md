# sayable-duration -- Racket

Human-friendly duration and relative time formatting -- how people talk about time spans.

```racket
(require "format-duration.rkt")
(require "locales/registry.rkt")

(define en (get-locale "en"))
(format-duration en 3600)                                                ; "1 hour"
(format-duration en 5400)                                                ; "1½ hours"
(format-since en "2025-01-15T10:00:00" "2025-01-15T10:45:00")           ; "45 minutes ago"
```

## Installation

Copy the Racket source files into your project. Requires Racket 8.0+. Zero external dependencies.

## Usage

```racket
#lang racket
(require "format-duration.rkt")
(require "locales/registry.rkt")

(define en (get-locale "en"))

;; Duration from seconds
(format-duration en 0)         ; "just now"
(format-duration en 45)        ; "45 seconds"
(format-duration en 3600)      ; "1 hour"
(format-duration en 5400)      ; "1½ hours"
(format-duration en 86400)     ; "1 day"

;; Duration from ISO timestamps
(format-duration en "2025-01-15T10:00:00" "2025-01-15T11:30:00")  ; "1½ hours"

;; Elapsed time (ago)
(format-since en "2025-01-15T10:00:00" "2025-01-15T10:45:00")     ; "45 minutes ago"

;; Remaining time (in)
(format-until en "2025-01-15T13:00:00" "2025-01-15T10:00:00")     ; "in 3 hours"

;; Returns #f for invalid input
(format-duration en #f)        ; #f
(format-duration en -1)        ; #f
```

## Internationalization

```racket
(define ja (get-locale "ja"))
(format-duration ja 120)       ; "2分"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```racket
(format-duration en 3600)                              ; "1 hour"
(format-duration en 3600 #f #:compactness 'short)      ; "1h"
(format-duration en 3600 #f #:compactness 'compact)    ; "1h"
```

## API

```racket
(format-duration locale seconds-or-start [end] [#:compactness compactness]) -> (or/c string? #f)
(format-since locale start as-of [compactness]) -> (or/c string? #f)
(format-until locale target as-of [compactness]) -> (or/c string? #f)
(get-locale code) -> (or/c duration-locale? #f)
```

**Parameters:**

- `seconds-or-start` -- Integer seconds or ISO datetime start string.
- `end` -- ISO datetime end string (required for timestamp mode).
- `start` / `target` / `as-of` -- ISO datetime strings.
- `compactness` -- `'normal`, `'short`, or `'compact`.

**Returns:** A string, or `#f` if input is invalid.

## Development

```bash
raco test test-format-duration.rkt
```

## License

[MIT](../../LICENSE.md)

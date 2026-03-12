# sayable-date -- Racket

Human-friendly date formatting -- how people reference dates in conversation.

```racket
(require "format-date.rkt")
(require "locales/registry.rkt")

(define en (get-locale "en"))
(format-date en "2025-03-15")                          ; "March 15th"
(format-relative en "2025-03-16" "2025-03-15")         ; "tomorrow"
(format-relative en "2025-03-19" "2025-03-15")         ; "this Wednesday"
```

## Installation

Copy the Racket source files into your project. Requires Racket 8.0+. Zero external dependencies.

## Usage

```racket
#lang racket
(require "format-date.rkt")
(require "locales/registry.rkt")

(define en (get-locale "en"))

;; Absolute date
(format-date en "2025-03-15")                          ; "March 15th"
(format-date en "2025-01-01")                          ; "January 1st"

;; Date with year
(format-date-with-year en "2025-03-15")                ; "March 15th, 2025"

;; Relative date
(format-relative en "2025-03-16" "2025-03-15")         ; "tomorrow"
(format-relative en "2025-03-19" "2025-03-15")         ; "this Wednesday"
(format-relative en "2025-03-22" "2025-03-15")         ; "next Saturday"

;; Returns #f for invalid input
(format-date en "")                                    ; #f
```

## Internationalization

```racket
(define ja (get-locale "ja"))
(format-date ja "2025-03-15")                          ; "3月15日"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```racket
(format-date en "2025-03-15")                          ; "March 15th"
(format-date en "2025-03-15" 'short)                   ; "Mar 15"
(format-date en "2025-03-15" 'compact)                 ; "3/15"
```

## API

```racket
(format-date locale date-str [compactness]) -> (or/c string? #f)
(format-date-with-year locale date-str [compactness]) -> (or/c string? #f)
(format-relative locale date-str as-of [compactness]) -> (or/c string? #f)
(get-locale code) -> (or/c date-locale? #f)
```

**Parameters:**

- `date-str` -- `YYYY-MM-DD` or ISO datetime string.
- `as-of` -- Reference date as `YYYY-MM-DD`.
- `compactness` -- `'normal`, `'short`, or `'compact`.

**Returns:** A string, or `#f` if input is invalid.

## Development

```bash
raco test test-format-date.rkt
```

## License

[MIT](../../LICENSE.md)

# sayable-time -- Racket

Human-friendly clock time formatting -- tells time the way people talk.

```racket
(require "format-time.rkt")
(require "locales/registry.rkt")

(define en (get-locale "en"))
(format-time en "14:15")       ; "a quarter past two"
(format-time en "09:30")       ; "half past nine"
(format-time en "00:00")       ; "midnight"
```

## Installation

Copy the Racket source files into your project. Requires Racket 8.0+. Zero external dependencies.

## Usage

```racket
#lang racket
(require "format-time.rkt")
(require "locales/registry.rkt")

(define en (get-locale "en"))

;; Natural spoken time
(format-time en "00:00")       ; "midnight"
(format-time en "12:00")       ; "noon"
(format-time en "15:00")       ; "three o'clock"
(format-time en "14:15")       ; "a quarter past two"
(format-time en "09:30")       ; "half past nine"
(format-time en "10:45")       ; "a quarter to eleven"

;; Returns #f for invalid input
(format-time en "")            ; #f
(format-time en "25:00")       ; #f
```

## Internationalization

```racket
(define ja (get-locale "ja"))
(format-time ja "15:30")       ; "三時半"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```racket
(format-time en "14:15")                               ; "a quarter past two"
(format-time en "14:15" 'short)                        ; "2:15 PM"
(format-time en "14:15" 'compact)                      ; "2:15p"
```

## API

```racket
(format-time locale time-str [compactness]) -> (or/c string? #f)
(get-locale code) -> (or/c time-locale? #f)
```

**Parameters:**

- `time-str` -- `HH:MM` or ISO datetime string.
- `compactness` -- `'normal`, `'short`, or `'compact`.

**Returns:** A string, or `#f` if input is invalid.

## Development

```bash
raco test test-format-time.rkt
```

## License

[MIT](../../LICENSE.md)

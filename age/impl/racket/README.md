# sayable-age — Racket

Human-friendly age formatting — how parents actually talk about little ones.

```racket
(require "main.rkt")
(format-age "2025-06-01" "2025-06-15")  ; "2 weeks"
(format-age "2025-01-15" "2025-07-15")  ; "6 months"
(format-age "2022-06-15" "2025-12-15")  ; "3½ years"
```

## Installation

Copy the Racket source files into your project. Requires Racket 8.0+. Zero external dependencies.

## Usage

```racket
#lang racket
(require "main.rkt")

;; Human-readable age string
(format-age "2025-06-15" "2025-06-15")  ; "Newborn"
(format-age "2025-06-01" "2025-06-15")  ; "2 weeks"
(format-age "2025-01-15" "2025-07-15")  ; "6 months"
(format-age "2023-06-15" "2025-07-15")  ; "2 years, 1 month"
(format-age "2022-06-15" "2025-12-15")  ; "3½ years"

;; Developmental stage label
(format-stage "2025-06-15" "2025-06-15")  ; "Newborn"
(format-stage "2025-01-15" "2025-06-15")  ; "Infant"
(format-stage "2024-06-15" "2025-06-15")  ; "Toddler"

;; Returns #f for empty/future dates or ages exceeding 500 years
(format-age "" "2025-06-15")  ; #f
```

## Internationalization

```racket
(define ja (get-locale "ja"))
(format-age ja "2025-01-01" "2025-07-15")  ; "6ヶ月"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```racket
(format-age en "2025-01-15" "2025-07-15")               ; "6 months"
(format-age en "2025-01-15" "2025-07-15" #:compact 'short)   ; "6 mo"
(format-age en "2025-01-15" "2025-07-15" #:compact 'compact) ; "6m"
```

## API

```racket
;; With locale
(format-age locale dob as-of [#:compact compactness]) -> (or/c string? #f)
(format-stage locale dob as-of [#:gender gender]) -> (or/c string? #f)

;; Locale lookup
(get-locale code) -> (or/c locale? #f)
```

**Parameters:**

- `dob` — `YYYY-MM-DD` string.
- `as-of` — Reference date as `YYYY-MM-DD`.
- `gender` — `"m"` or `"f"` for gendered stage labels.

**Returns:** A string, or `#f` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
raco test test/
```

## License

[MIT](../../LICENSE.md)

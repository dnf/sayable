# sayable-age -- Common Lisp

Human-friendly age formatting -- how parents actually talk about little ones.

```lisp
(format-age formatter "2025-06-01" "2025-06-15")  ; "2 weeks"
(format-age formatter "2025-01-15" "2025-07-15")  ; "6 months"
(format-age formatter "2022-06-15" "2025-12-15")  ; "3½ years"
```

## Installation

Requires SBCL. Load with ASDF:

```lisp
(require :asdf)
(push (truename "/path/to/age/impl/lisp/") asdf:*central-registry*)
(asdf:load-system "sayable-age")
```

Zero runtime dependencies.

## Usage

```lisp
(in-package :sayable-age)

;; Create a formatter with a locale
(let ((f (make-formatter (get-locale "en"))))
  (format-age f "2025-06-15" "2025-06-15")    ; "Newborn"
  (format-age f "2025-06-01" "2025-06-15")    ; "2 weeks"
  (format-age f "2025-01-15" "2025-07-15")    ; "6 months"
  (format-age f "2024-06-15" "2025-06-15")    ; "12 months"
  (format-age f "2023-06-15" "2025-07-15")    ; "2 years, 1 month"
  (format-age f "2022-06-15" "2025-12-15")    ; "3½ years"
  (format-age f "2018-06-15" "2025-06-15"))   ; "7 years"

;; Developmental stage label
(let ((f (make-formatter (get-locale "en"))))
  (format-stage f "2025-06-15" "2025-06-15")  ; "Newborn"
  (format-stage f "2025-01-15" "2025-06-15")  ; "Infant"
  (format-stage f "2024-06-15" "2025-06-15")) ; "Toddler"

;; Returns NIL for nil/empty/future dates or ages exceeding 500 years
(format-age f nil "2025-06-15")  ; NIL
```

## Internationalization

```lisp
(let ((f (make-formatter (get-locale "ja"))))
  (format-age f "2025-01-01" "2025-07-15"))  ; "6ヶ月"
```

168 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```lisp
(let ((normal  (make-formatter (get-locale "en")))              ; "3 months"
      (short   (make-formatter (get-locale "en") :short))       ; "3 mo"
      (compact (make-formatter (get-locale "en") :compact)))    ; "3m"
  ...)
```

## API

```lisp
;; Locale lookup
(get-locale "en")         ; => #S(AGE-LOCALE ...) or NIL

;; Create formatter
(make-formatter locale &optional (compactness :normal))

;; Format age
(format-age formatter date-of-birth &optional as-of)   ; => String or NIL

;; Format stage
(format-stage formatter date-of-birth &optional as-of gender)  ; => String or NIL
```

**Parameters:**

- `date-of-birth` -- `YYYY-MM-DD` string. Returns `NIL` if `NIL` or empty.
- `as-of` -- Reference date as `YYYY-MM-DD`. Defaults to today (not supported in this implementation; always pass explicitly).
- `gender` -- `"m"` or `"f"` for gendered locales (defaults to masculine/neutral).

**Returns:** A string, or `NIL` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
# Run tests
cd age/impl/lisp
sbcl --noinform --non-interactive \
  --eval '(require :asdf)' \
  --eval '(push (truename ".") asdf:*central-registry*)' \
  --eval '(asdf:load-system "sayable-age")' \
  --load test/test-formatter.lisp \
  --eval '(sayable-age-test:run-tests)'
```

## License

[MIT](../../LICENSE.md)

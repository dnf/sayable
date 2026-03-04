# sayable-age — Clojure

A thoughtful time formatting library that reflects how we think about little ones.

```clojure
(require '[sayableage.core :as pt]
         '[sayableage.locales.en :as en])

(pt/format-age en/locale :normal "2025-06-01" "2025-06-15")
;; => "2 weeks"
```

## Setup

Add the source path to your `deps.edn`. Not published to Clojars — use as a local dependency.

```edn
{:paths ["src"]
 :deps {}}
```

Requires Clojure 1.11+. Zero external dependencies.

## Usage

```clojure
(require '[sayableage.core :as pt]
         '[sayableage.locales.en :as en])

(pt/format-age en/locale :normal "2025-01-15" "2025-07-15")
;; => "6 months"

(pt/format-stage en/locale "2025-01-15" "2025-06-15" nil)
;; => "Infant"
```

## Internationalization

```clojure
(require '[sayableage.locales.ja :as ja])

(pt/format-age ja/locale :normal "2025-01-01" "2025-07-15")
;; => "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## API

```clojure
(format-age locale compactness dob as-of)       ;; => string or nil
(format-stage locale dob as-of gender)           ;; => string or nil
(format-age-pure locale compactness dob as-of)   ;; pure — no fallback to today
(format-stage-pure locale dob as-of gender)      ;; pure — no fallback to today
(get-locale code)                                ;; => locale map or nil
```

**Parameters:**

- `locale` — A locale map (e.g., `en/locale`).
- `compactness` — `:normal`, `:short`, or `:compact`.
- `dob` — `"YYYY-MM-DD"` string. Returns `nil` for empty strings.
- `as-of` — Reference date. The non-pure variants default to today if `nil`.

## Development

```bash
clojure -X:test    # Run tests
```

## License

[MIT](../../LICENSE.md)

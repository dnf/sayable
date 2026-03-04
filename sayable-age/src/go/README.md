# sayable-age — Go

A thoughtful time formatting library that reflects how we think about little ones.

```go
age := sayableage.FormatAge("2025-06-01", "2025-06-15")
fmt.Println(*age)  // "2 weeks"
```

## Installation

```bash
go get github.com/dnf/sayable/sayable-age/src/go
```

Requires Go 1.21+. Zero external dependencies.

## Usage

```go
package main

import (
    "fmt"
    sayableage "github.com/dnf/sayable/sayable-age/src/go"
)

func main() {
    // Package-level functions — English default
    age := sayableage.FormatAge("2025-01-15", "2025-07-15")
    fmt.Println(*age)  // "6 months"

    stage := sayableage.FormatStage("2025-01-15", "2025-06-15")
    fmt.Println(*stage)  // "Infant"

    // Returns nil for empty/future dates or ages exceeding 500 years
    fmt.Println(sayableage.FormatAge(""))  // <nil>

    // Struct-based with locale
    pt := sayableage.NewSayableAge(sayableage.EN)
    fmt.Println(*pt.FormatAge("2022-06-15", "2025-12-15"))  // "3½ years"
    fmt.Println(*pt.FormatStage("2022-06-15", "2025-06-15")) // "Child"
}
```

## Internationalization

```go
pt := sayableage.NewSayableAge(sayableage.JA)
age := pt.FormatAge("2025-01-01", "2025-07-15")
fmt.Println(*age)  // "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```go
normal  := sayableage.NewSayableAge(sayableage.EN)                       // "3 months"
short   := sayableage.NewSayableAge(sayableage.EN, sayableage.Short)     // "3 mo"
compact := sayableage.NewSayableAge(sayableage.EN, sayableage.Compact)   // "3m"
```

## API

```go
// Struct — locale set once at construction
type SayableAge struct { ... }
func NewSayableAge(locale AgeLocale, compactness ...Compactness) *SayableAge
func (pt *SayableAge) FormatAge(dateOfBirth string, asOf ...string) *string
func (pt *SayableAge) FormatStage(dateOfBirth string, asOf ...string) *string

// Package-level functions — English default
func FormatAge(dateOfBirth string, asOf ...string) *string
func FormatStage(dateOfBirth string, asOf ...string) *string
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `nil` for empty strings.
- `asOf` — Optional reference date. Defaults to today.

**Returns:** `*string` (pointer to string), or `nil` if input is missing, DOB is in the future, or age exceeds 500 years.

**Go idioms:** Uses `*string` for nullable returns. Uses variadic `asOf ...string` for the optional parameter.

## Development

```bash
go test -v ./...     # Run tests
go vet ./...         # Static analysis
```

## Code quality

- golangci-lint v2 with 10 linters + gofmt/goimports formatters
- See [code quality docs](../../docs/code-quality-compiled.md#go) for details

## License

[MIT](../../LICENSE.md)

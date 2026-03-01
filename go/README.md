# parent-time — Go

Human-friendly age formatting the way parents actually talk.

```go
age := parenttime.FormatAge("2025-06-01", "2025-06-15")
fmt.Println(*age)  // "2 weeks"
```

## Installation

```bash
go get github.com/dnf/parent-time/go
```

Requires Go 1.21+. Zero external dependencies.

## Usage

```go
package main

import (
    "fmt"
    parenttime "github.com/dnf/parent-time/go"
)

func main() {
    // Package-level functions — English default
    age := parenttime.FormatAge("2025-01-15", "2025-07-15")
    fmt.Println(*age)  // "6 months"

    stage := parenttime.FormatStage("2025-01-15", "2025-06-15")
    fmt.Println(*stage)  // "Infant"

    // Returns nil for empty/future dates
    fmt.Println(parenttime.FormatAge(""))  // <nil>

    // Struct-based with locale
    pt := parenttime.NewParentTime(parenttime.EN)
    fmt.Println(*pt.FormatAge("2022-06-15", "2025-12-15"))  // "3½ years"
    fmt.Println(*pt.FormatStage("2022-06-15", "2025-06-15")) // "Child"
}
```

## Internationalization

```go
pt := parenttime.NewParentTime(parenttime.JA)
age := pt.FormatAge("2025-01-01", "2025-07-15")
fmt.Println(*age)  // "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../docs/locales.md) for details.

## Compactness

```go
normal  := parenttime.NewParentTime(parenttime.EN)                       // "3 months"
short   := parenttime.NewParentTime(parenttime.EN, parenttime.Short)     // "3 mo"
compact := parenttime.NewParentTime(parenttime.EN, parenttime.Compact)   // "3m"
```

## API

```go
// Struct — locale set once at construction
type ParentTime struct { ... }
func NewParentTime(locale AgeLocale, compactness ...Compactness) *ParentTime
func (pt *ParentTime) FormatAge(dateOfBirth string, asOf ...string) *string
func (pt *ParentTime) FormatStage(dateOfBirth string, asOf ...string) *string

// Package-level functions — English default
func FormatAge(dateOfBirth string, asOf ...string) *string
func FormatStage(dateOfBirth string, asOf ...string) *string
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `nil` for empty strings.
- `asOf` — Optional reference date. Defaults to today.

**Returns:** `*string` (pointer to string), or `nil` if input is missing or DOB is in the future.

**Go idioms:** Uses `*string` for nullable returns. Uses variadic `asOf ...string` for the optional parameter.

## Development

```bash
go test -v ./...     # Run tests
go vet ./...         # Static analysis
```

## Code quality

- golangci-lint v2 with 10 linters + gofmt/goimports formatters
- See [code quality docs](../docs/code-quality-compiled.md#go) for details

## License

[MIT](../LICENSE.md)

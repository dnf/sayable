# parent-time — Rust

Human-friendly age formatting the way parents actually talk.

```rust
use parent_time::{format_age, format_stage};

assert_eq!(format_age("2025-06-01", Some("2025-06-15")), Some("2 weeks".into()));
assert_eq!(format_age("2025-01-15", Some("2025-07-15")), Some("6 months".into()));
assert_eq!(format_age("2022-06-15", Some("2025-12-15")), Some("3½ years".into()));
```

## Installation

Add to your `Cargo.toml`:

```toml
[dependencies]
parent-time = "0.1"
```

Requires Rust 1.80+. Zero external dependencies (uses only `std`).

## Usage

```rust
use parent_time::{format_age, format_stage, ParentTime, Compactness, locales};

// Free functions — English default
let age = format_age("2025-06-15", Some("2025-06-15"));
assert_eq!(age, Some("Newborn".to_string()));

let age = format_age("2025-06-01", Some("2025-06-15"));
assert_eq!(age, Some("2 weeks".to_string()));

let stage = format_stage("2025-01-15", Some("2025-06-15"));
assert_eq!(stage, Some("Infant".to_string()));

// Returns None for empty/future dates
assert_eq!(format_age("", None), None);

// Struct-based with locale
let pt = ParentTime::new(&locales::EN, Compactness::Normal);
let age = pt.format_age("2022-06-15", Some("2025-12-15"));
assert_eq!(age, Some("3½ years".to_string()));
```

## Internationalization

```rust
use parent_time::{ParentTime, Compactness, locales};

let pt = ParentTime::new(&locales::JA, Compactness::Normal);
let age = pt.format_age("2025-01-01", Some("2025-07-15"));
assert_eq!(age, Some("6ヶ月".to_string()));
```

63 built-in locales are available. See the [locale documentation](../docs/locales.md) for details.

## Compactness

```rust
let normal  = ParentTime::new(&locales::EN, Compactness::Normal);  // "3 months"
let short   = ParentTime::new(&locales::EN, Compactness::Short);   // "3 mo"
let compact = ParentTime::new(&locales::EN, Compactness::Compact); // "3m"
```

## API

```rust
// Struct — locale set once at construction
pub struct ParentTime { ... }
impl ParentTime {
    pub fn new(locale: &AgeLocale, compactness: Compactness) -> Self;
    pub fn format_age(&self, dob: &str, as_of: Option<&str>) -> Option<String>;
    pub fn format_stage(&self, dob: &str, as_of: Option<&str>) -> Option<String>;
}

// Free functions — English default
pub fn format_age(dob: &str, as_of: Option<&str>) -> Option<String>;
pub fn format_stage(dob: &str, as_of: Option<&str>) -> Option<String>;
```

**Parameters:**

- `dob` — Date of birth as `YYYY-MM-DD`. Returns `None` for empty strings.
- `as_of` — Optional reference date. `None` defaults to today.

**Returns:** `Option<String>` — `Some(formatted)` or `None` if input is invalid or DOB is in the future.

## Development

```bash
cargo test       # Run tests
cargo clippy     # Lint
cargo doc        # Generate docs
```

## Code quality

- `unsafe_code = "forbid"` — no unsafe code permitted
- clippy: `all = deny`, `pedantic = warn` with targeted allows
- See [code quality docs](../docs/code-quality-compiled.md#rust) for details

## License

MIT

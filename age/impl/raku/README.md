# sayable-age — Raku

Human-friendly age formatting — how parents actually talk about little ones.

```raku
use SayableAge;
say format-age("2025-06-01", "2025-06-15");  # "2 weeks"
say format-age("2025-01-15", "2025-07-15");  # "6 months"
say format-age("2022-06-15", "2025-12-15");  # "3½ years"
```

## Installation

Copy the Raku module files into your project. Requires Rakudo 2023.02+. Zero external dependencies.

## Usage

```raku
use SayableAge;

# Module-level functions — English default
say format-age("2025-06-15", "2025-06-15");  # "Newborn"
say format-age("2025-06-01", "2025-06-15");  # "2 weeks"
say format-age("2025-01-15", "2025-07-15");  # "6 months"
say format-age("2023-06-15", "2025-07-15");  # "2 years, 1 month"
say format-age("2022-06-15", "2025-12-15");  # "3½ years"

# Developmental stage label
say format-stage("2025-06-15", "2025-06-15");  # "Newborn"
say format-stage("2025-01-15", "2025-06-15");  # "Infant"

# Returns Nil for empty/future dates or ages exceeding 500 years
say format-age("", "2025-06-15");  # Nil
```

## Internationalization

```raku
use SayableAge::Locales::Registry;
use SayableAge::Formatter;

my %ja = get-locale("ja");
my $f = SayableAge::Formatter.new(%ja);
say $f.format-age("2025-01-01", "2025-07-15");  # "6ヶ月"
```

159 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```raku
use SayableAge::Formatter;
use SayableAge::Locales::Registry;

my %en = get-locale("en");
my $normal  = SayableAge::Formatter.new(%en);                      # "6 months"
my $short   = SayableAge::Formatter.new(%en, compactness => 'short');   # "6 mo"
my $compact = SayableAge::Formatter.new(%en, compactness => 'compact'); # "6m"
```

## API

```raku
# Module-level functions (English default)
sub format-age(Str $dob?, Str $as-of? --> Str) is export
sub format-stage(Str $dob?, Str $as-of?, Str :$gender = '' --> Str) is export

# Formatter class
class SayableAge::Formatter {
    method format-age(Str $dob?, Str $as-of? --> Str)
    method format-stage(Str $dob?, Str $as-of?, Str :$gender = '' --> Str)
}

# Locale lookup
sub get-locale(Str $code --> Hash)
```

**Parameters:**

- `$dob` — `YYYY-MM-DD` string.
- `$as-of` — Reference date as `YYYY-MM-DD`.
- `$gender` — `"m"` or `"f"` for gendered stage labels.

**Returns:** A `Str`, or `Nil` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
prove6 -Ilib t/
```

## License

[MIT](../../LICENSE.md)

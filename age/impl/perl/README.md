# sayable-age — Perl

Human-friendly age formatting — how parents actually talk about little ones.

```perl
use SayableAge;

SayableAge->format_age("2025-06-01", "2025-06-15");  # "2 weeks"
SayableAge->format_age("2025-01-15", "2025-07-15");  # "6 months"
SayableAge->format_age("2022-06-15", "2025-12-15");  # "3½ years"
```

## Installation

Copy the `lib/` directory into your project. Requires Perl 5.10+. Zero non-core dependencies (uses only `Time::Local` from core).

## Usage

```perl
use SayableAge;

# Class methods — English default
SayableAge->format_age("2025-06-15", "2025-06-15");  # "Newborn"
SayableAge->format_age("2025-06-01", "2025-06-15");  # "2 weeks"
SayableAge->format_age("2025-01-15", "2025-07-15");  # "6 months"
SayableAge->format_age("2024-06-15", "2025-06-15");  # "12 months"
SayableAge->format_age("2023-06-15", "2025-07-15");  # "2 years, 1 month"
SayableAge->format_age("2022-06-15", "2025-12-15");  # "3½ years"
SayableAge->format_age("2018-06-15", "2025-06-15");  # "7 years"

# Developmental stage label
SayableAge->format_stage("2025-06-15", "2025-06-15");  # "Newborn"
SayableAge->format_stage("2025-01-15", "2025-06-15");  # "Infant"
SayableAge->format_stage("2024-06-15", "2025-06-15");  # "Toddler"

# Returns undef for undef/empty/future dates or ages exceeding 500 years
SayableAge->format_age(undef);  # undef

# Object-oriented with locale
use SayableAge::Formatter;
use SayableAge::Locales;

my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('en'));
$pt->format_age("2022-06-15", "2025-12-15");   # "3½ years"
$pt->format_stage("2022-06-15", "2025-06-15");  # "Child"
```

## Internationalization

```perl
my $pt = SayableAge::Formatter->new(SayableAge::Locales->get('ja'));
$pt->format_age("2025-01-01", "2025-07-15");  # "6ヶ月"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```perl
my $normal  = SayableAge::Formatter->new(SayableAge::Locales->get('en'));                           # "3 months"
my $short   = SayableAge::Formatter->new(SayableAge::Locales->get('en'), compactness => 'short');   # "3 mo"
my $compact = SayableAge::Formatter->new(SayableAge::Locales->get('en'), compactness => 'compact'); # "3m"
```

## API

```perl
# SayableAge::Formatter
my $pt = SayableAge::Formatter->new($locale, compactness => 'normal');
$pt->format_age($date_of_birth, $as_of);                  # String or undef
$pt->format_stage($date_of_birth, $as_of, gender => $g);  # String or undef

# Class methods — English default
SayableAge->format_age($date_of_birth, $as_of);                  # String or undef
SayableAge->format_stage($date_of_birth, $as_of, gender => $g);  # String or undef
```

**Parameters:**

- `$date_of_birth` — `YYYY-MM-DD` string. Returns `undef` if `undef` or empty.
- `$as_of` — Reference date as `YYYY-MM-DD`. Defaults to today.
- `gender` — `'m'` or `'f'` for gendered stage labels. Defaults to masculine.

**Returns:** A string, or `undef` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
prove -Ilib t/   # Run tests
```

## Code quality

- `use strict` and `use warnings` enforced in all modules
- `use utf8` for Unicode locale data

## License

[MIT](../../LICENSE.md)

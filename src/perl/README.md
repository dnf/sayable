# parent-time — Perl

A thoughtful time formatting library that reflects how we think about little ones.

```perl
use ParentTime;

ParentTime->format_age("2025-06-01", "2025-06-15");  # "2 weeks"
ParentTime->format_age("2025-01-15", "2025-07-15");  # "6 months"
ParentTime->format_age("2022-06-15", "2025-12-15");  # "3½ years"
```

## Installation

Copy the `lib/` directory into your project. Requires Perl 5.10+. Zero non-core dependencies (uses only `Time::Local` from core).

## Usage

```perl
use ParentTime;

# Class methods — English default
ParentTime->format_age("2025-06-15", "2025-06-15");  # "Newborn"
ParentTime->format_age("2025-06-01", "2025-06-15");  # "2 weeks"
ParentTime->format_age("2025-01-15", "2025-07-15");  # "6 months"
ParentTime->format_age("2024-06-15", "2025-06-15");  # "12 months"
ParentTime->format_age("2023-06-15", "2025-07-15");  # "2 years, 1 month"
ParentTime->format_age("2022-06-15", "2025-12-15");  # "3½ years"
ParentTime->format_age("2018-06-15", "2025-06-15");  # "7 years"

# Developmental stage label
ParentTime->format_stage("2025-06-15", "2025-06-15");  # "Newborn"
ParentTime->format_stage("2025-01-15", "2025-06-15");  # "Infant"
ParentTime->format_stage("2024-06-15", "2025-06-15");  # "Toddler"

# Returns undef for undef/empty/future dates or ages exceeding 500 years
ParentTime->format_age(undef);  # undef

# Object-oriented with locale
use ParentTime::Formatter;
use ParentTime::Locales;

my $pt = ParentTime::Formatter->new(ParentTime::Locales->get('en'));
$pt->format_age("2022-06-15", "2025-12-15");   # "3½ years"
$pt->format_stage("2022-06-15", "2025-06-15");  # "Child"
```

## Internationalization

```perl
my $pt = ParentTime::Formatter->new(ParentTime::Locales->get('ja'));
$pt->format_age("2025-01-01", "2025-07-15");  # "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```perl
my $normal  = ParentTime::Formatter->new(ParentTime::Locales->get('en'));                           # "3 months"
my $short   = ParentTime::Formatter->new(ParentTime::Locales->get('en'), compactness => 'short');   # "3 mo"
my $compact = ParentTime::Formatter->new(ParentTime::Locales->get('en'), compactness => 'compact'); # "3m"
```

## API

```perl
# ParentTime::Formatter
my $pt = ParentTime::Formatter->new($locale, compactness => 'normal');
$pt->format_age($date_of_birth, $as_of);                  # String or undef
$pt->format_stage($date_of_birth, $as_of, gender => $g);  # String or undef

# Class methods — English default
ParentTime->format_age($date_of_birth, $as_of);                  # String or undef
ParentTime->format_stage($date_of_birth, $as_of, gender => $g);  # String or undef
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

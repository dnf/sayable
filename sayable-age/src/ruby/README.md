# sayable-age — Ruby

A thoughtful time formatting library that reflects how we think about little ones.

```ruby
SayableAge.format_age("2025-06-01", "2025-06-15")  # "2 weeks"
SayableAge.format_age("2025-01-15", "2025-07-15")  # "6 months"
SayableAge.format_age("2022-06-15", "2025-12-15")  # "3½ years"
```

## Installation

```ruby
# Gemfile
gem "sayable_age"
```

Requires Ruby 3.0+. Zero runtime dependencies.

## Usage

```ruby
require "sayable_age"

# Module-level methods — English default
SayableAge.format_age("2025-06-15", "2025-06-15")  # "Newborn"
SayableAge.format_age("2025-06-01", "2025-06-15")  # "2 weeks"
SayableAge.format_age("2025-01-15", "2025-07-15")  # "6 months"
SayableAge.format_age("2024-06-15", "2025-06-15")  # "12 months"
SayableAge.format_age("2023-06-15", "2025-07-15")  # "2 years, 1 month"
SayableAge.format_age("2022-06-15", "2025-12-15")  # "3½ years"
SayableAge.format_age("2018-06-15", "2025-06-15")  # "7 years"

# Developmental stage label
SayableAge.format_stage("2025-06-15", "2025-06-15")  # "Newborn"
SayableAge.format_stage("2025-01-15", "2025-06-15")  # "Infant"
SayableAge.format_stage("2024-06-15", "2025-06-15")  # "Toddler"

# Returns nil for nil/empty/future dates or ages exceeding 500 years
SayableAge.format_age(nil)  # nil

# Class-based with locale
pt = SayableAge::Formatter.new(SayableAge::Locales::EN)
pt.format_age("2022-06-15", "2025-12-15")   # "3½ years"
pt.format_stage("2022-06-15", "2025-06-15") # "Child"
```

## Internationalization

```ruby
pt = SayableAge::Formatter.new(SayableAge::Locales::JA)
pt.format_age("2025-01-01", "2025-07-15")  # "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```ruby
normal  = SayableAge::Formatter.new(SayableAge::Locales::EN)                       # "3 months"
short   = SayableAge::Formatter.new(SayableAge::Locales::EN, compactness: :short)   # "3 mo"
compact = SayableAge::Formatter.new(SayableAge::Locales::EN, compactness: :compact) # "3m"
```

## API

```ruby
class SayableAge::Formatter
  def initialize(locale, compactness: :normal)
  def format_age(date_of_birth, as_of = nil)   # => String or nil
  def format_stage(date_of_birth, as_of = nil) # => String or nil
end

# Module-level methods — English default
SayableAge.format_age(date_of_birth, as_of = nil)   # => String or nil
SayableAge.format_stage(date_of_birth, as_of = nil) # => String or nil
```

**Parameters:**

- `date_of_birth` — `YYYY-MM-DD` string. Returns `nil` if `nil` or empty.
- `as_of` — Reference date as `YYYY-MM-DD`. Defaults to today.

**Returns:** A `String`, or `nil` if input is missing, DOB is in the future, or age exceeds 500 years.

## Development

```bash
bundle install
bundle exec rake test   # Run minitest
```

## Code quality

- RuboCop with `NewCops: enable`, frozen string literals, practical metric thresholds
- See [code quality docs](../../docs/code-quality-dynamic.md#ruby) for details

## License

[MIT](../../LICENSE.md)

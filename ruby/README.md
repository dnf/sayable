# parent-time — Ruby

Human-friendly age formatting the way parents actually talk.

```ruby
ParentTime.format_age("2025-06-01", "2025-06-15")  # "2 weeks"
ParentTime.format_age("2025-01-15", "2025-07-15")  # "6 months"
ParentTime.format_age("2022-06-15", "2025-12-15")  # "3½ years"
```

## Installation

```ruby
# Gemfile
gem "parent_time"
```

Requires Ruby 3.0+. Zero runtime dependencies.

## Usage

```ruby
require "parent_time"

# Module-level methods — English default
ParentTime.format_age("2025-06-15", "2025-06-15")  # "Newborn"
ParentTime.format_age("2025-06-01", "2025-06-15")  # "2 weeks"
ParentTime.format_age("2025-01-15", "2025-07-15")  # "6 months"
ParentTime.format_age("2024-06-15", "2025-06-15")  # "12 months"
ParentTime.format_age("2023-06-15", "2025-07-15")  # "2 years, 1 month"
ParentTime.format_age("2022-06-15", "2025-12-15")  # "3½ years"
ParentTime.format_age("2018-06-15", "2025-06-15")  # "7 years"

# Developmental stage label
ParentTime.format_stage("2025-06-15", "2025-06-15")  # "Newborn"
ParentTime.format_stage("2025-01-15", "2025-06-15")  # "Infant"
ParentTime.format_stage("2024-06-15", "2025-06-15")  # "Toddler"

# Returns nil for nil/empty/future dates
ParentTime.format_age(nil)  # nil

# Class-based with locale
pt = ParentTime::Formatter.new(ParentTime::Locales::EN)
pt.format_age("2022-06-15", "2025-12-15")   # "3½ years"
pt.format_stage("2022-06-15", "2025-06-15") # "Child"
```

## Internationalization

```ruby
pt = ParentTime::Formatter.new(ParentTime::Locales::JA)
pt.format_age("2025-01-01", "2025-07-15")  # "6ヶ月"
```

71 built-in locales are available. See the [locale documentation](../docs/locales.md) for details.

## Compactness

```ruby
normal  = ParentTime::Formatter.new(ParentTime::Locales::EN)                       # "3 months"
short   = ParentTime::Formatter.new(ParentTime::Locales::EN, compactness: :short)   # "3 mo"
compact = ParentTime::Formatter.new(ParentTime::Locales::EN, compactness: :compact) # "3m"
```

## API

```ruby
class ParentTime::Formatter
  def initialize(locale, compactness: :normal)
  def format_age(date_of_birth, as_of = nil)   # => String or nil
  def format_stage(date_of_birth, as_of = nil) # => String or nil
end

# Module-level methods — English default
ParentTime.format_age(date_of_birth, as_of = nil)   # => String or nil
ParentTime.format_stage(date_of_birth, as_of = nil) # => String or nil
```

**Parameters:**

- `date_of_birth` — `YYYY-MM-DD` string. Returns `nil` if `nil` or empty.
- `as_of` — Reference date as `YYYY-MM-DD`. Defaults to today.

**Returns:** A `String`, or `nil` if input is missing or DOB is in the future.

## Development

```bash
bundle install
bundle exec rake test   # Run minitest
```

## Code quality

- RuboCop with `NewCops: enable`, frozen string literals, practical metric thresholds
- See [code quality docs](../docs/code-quality-dynamic.md#ruby) for details

## License

MIT

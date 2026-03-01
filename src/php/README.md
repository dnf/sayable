# parent-time — PHP

A thoughtful time formatting library that reflects how we think about little ones.

```php
use function ParentTime\formatAge;
use function ParentTime\formatStage;

formatAge('2025-06-01', '2025-06-15');  // "2 weeks"
formatAge('2025-01-15', '2025-07-15');  // "6 months"
formatAge('2022-06-15', '2025-12-15');  // "3½ years"
```

## Installation

```bash
composer require dnf/parent-time
```

Requires PHP 8.1+. Zero runtime dependencies.

## Usage

```php
use ParentTime\ParentTime;
use ParentTime\Locales;
use function ParentTime\formatAge;
use function ParentTime\formatStage;

// Free functions — English default
formatAge('2025-06-15', '2025-06-15');    // "Newborn"
formatAge('2025-06-01', '2025-06-15');    // "2 weeks"
formatAge('2025-01-15', '2025-07-15');    // "6 months"
formatAge('2024-06-15', '2025-06-15');    // "12 months"
formatAge('2023-06-15', '2025-07-15');    // "2 years, 1 month"
formatAge('2022-06-15', '2025-12-15');    // "3½ years"
formatAge('2018-06-15', '2025-06-15');    // "7 years"

// Developmental stage label
formatStage('2025-06-15', '2025-06-15');  // "Newborn"
formatStage('2025-01-15', '2025-06-15');  // "Infant"
formatStage('2024-06-15', '2025-06-15');  // "Toddler"

// Returns null for null/empty/future dates or ages exceeding 500 years
formatAge(null);   // null
formatAge('');     // null

// Class-based with locale
$pt = new ParentTime(Locales::EN());
$pt->formatAge('2022-06-15', '2025-12-15');   // "3½ years"
$pt->formatStage('2022-06-15', '2025-06-15'); // "Child"
```

## Internationalization

```php
use ParentTime\ParentTime;
use ParentTime\Locales;

$pt = new ParentTime(Locales::JA());
$pt->formatAge('2025-01-01', '2025-07-15');   // "6ヶ月"
$pt->formatStage('2025-01-01', '2025-07-15'); // "乳児"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```php
use ParentTime\ParentTime;
use ParentTime\Locales;
use ParentTime\Compactness;

$normal  = new ParentTime(Locales::EN());                       // "3 months"
$short   = new ParentTime(Locales::EN(), Compactness::Short);   // "3 mo"
$compact = new ParentTime(Locales::EN(), Compactness::Compact); // "3m"
```

## API

```php
namespace ParentTime;

class ParentTime {
    public function __construct(AgeLocale $locale, Compactness $compactness = Compactness::Normal);
    public function formatAge(?string $dateOfBirth, ?string $asOf = null): ?string;
    public function formatStage(?string $dateOfBirth, ?string $asOf = null): ?string;
}

// Free functions — English default
function formatAge(?string $dateOfBirth, ?string $asOf = null): ?string;
function formatStage(?string $dateOfBirth, ?string $asOf = null): ?string;
```

**Parameters:**

- `$dateOfBirth` — `YYYY-MM-DD` string. Returns `null` for `null` or empty strings.
- `$asOf` — Optional reference date as `YYYY-MM-DD`. Defaults to today.

**Returns:** `?string` — the formatted string, or `null` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
composer install
composer test          # Run PHPUnit tests
composer analyse       # Run PHPStan static analysis
composer cs-check      # Check code style
composer cs-fix        # Fix code style
```

## Code quality

- PHPStan level 9 (maximum strictness)
- PHP-CS-Fixer with PER-CS2.0 + risky rules + native function invocation
- `declare(strict_types=1)` in every file
- `readonly` classes for immutable data types
- PHPUnit with `failOnRisky` and `failOnWarning` enabled
- See [code quality docs](../../docs/code-quality-dynamic.md#php) for details

## License

[MIT](../../LICENSE.md)

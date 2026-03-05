# sayable-age -- Groovy

Human-friendly age formatting — how parents actually talk about little ones.

```groovy
def age = SayableAge.formatAgeDefault('2025-06-01', '2025-06-15')  // "2 weeks"
def stage = SayableAge.formatStageDefault('2025-01-15', '2025-06-15')  // "Infant"
```

## Installation

Add to your `build.gradle`:

```groovy
dependencies {
    implementation 'com.github.dnf:sayable-age:0.1.0'
}
```

Requires JVM 17+. Zero external dependencies.

## Usage

```groovy
import sayableage.SayableAge
import sayableage.locales.Locales

// Static convenience methods -- English default
def age = SayableAge.formatAgeDefault('2025-06-15', '2025-06-15')    // "Newborn"
def age2 = SayableAge.formatAgeDefault('2025-06-01', '2025-06-15')   // "2 weeks"
def age3 = SayableAge.formatAgeDefault('2025-01-15', '2025-07-15')   // "6 months"
def age4 = SayableAge.formatAgeDefault('2022-06-15', '2025-12-15')   // "3½ years"

def stage = SayableAge.formatStageDefault('2025-01-15', '2025-06-15')  // "Infant"

// Returns null for empty/future dates or ages exceeding 500 years
def nothing = SayableAge.formatAgeDefault('')  // null

// Class-based with locale
def pt = new SayableAge(Locales.EN)
pt.formatAge('2022-06-15', '2025-12-15')   // "3½ years"
pt.formatStage('2022-06-15', '2025-06-15') // "Child"
```

## Internationalization

```groovy
import sayableage.SayableAge
import sayableage.locales.Locales

def pt = new SayableAge(Locales.JA)
pt.formatAge('2025-01-01', '2025-07-15')   // "6ヶ月"
pt.formatStage('2025-01-01', '2025-07-15') // "乳児"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```groovy
import sayableage.Compactness

def normal  = new SayableAge(Locales.EN)                       // "3 months"
def short_  = new SayableAge(Locales.EN, Compactness.SHORT)    // "3 mo"
def compact = new SayableAge(Locales.EN, Compactness.COMPACT)  // "3m"
```

## API

```groovy
class SayableAge {
    SayableAge(AgeLocale locale, Compactness compactness = Compactness.NORMAL)

    String formatAge(String dateOfBirth, String asOf = null)
    String formatStage(String dateOfBirth, String asOf = null, String gender = null)

    static String formatAgeDefault(String dateOfBirth, String asOf = null)
    static String formatStageDefault(String dateOfBirth, String asOf = null, String gender = null)
}
```

**Parameters:**

- `dateOfBirth` -- `YYYY-MM-DD` string. Returns `null` for empty strings.
- `asOf` -- Optional reference date. Defaults to today.

**Returns:** `String` -- the formatted string, or `null` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
./gradlew test    # Run tests
./gradlew build   # Build
```

## Code quality

- `-Werror` -- Java compiler warnings treated as errors
- Groovy compiler configuration via `compiler-config.groovy`
- JVM target: 17 (current LTS)
- See [code quality docs](../../docs/code-quality-compiled.md#groovy) for details

## License

[MIT](../../LICENSE.md)

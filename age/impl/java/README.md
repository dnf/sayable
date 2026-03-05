# sayable-age — Java

Human-friendly age formatting — how parents actually talk about little ones.

```java
String age = SayableAge.formatAgeDefault("2025-06-01", "2025-06-15");  // "2 weeks"
String stage = SayableAge.formatStageDefault("2025-01-15", "2025-06-15");  // "Infant"
```

## Installation

Add to your `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.github.dnf:sayable-age:0.1.0")
}
```

Requires JVM 17+. Zero external dependencies.

## Usage

```java
import sayableage.SayableAge;
import sayableage.Locales;

// Static convenience methods — English default
String age = SayableAge.formatAgeDefault("2025-06-15", "2025-06-15");    // "Newborn"
String age2 = SayableAge.formatAgeDefault("2025-06-01", "2025-06-15");   // "2 weeks"
String age3 = SayableAge.formatAgeDefault("2025-01-15", "2025-07-15");   // "6 months"
String age4 = SayableAge.formatAgeDefault("2022-06-15", "2025-12-15");   // "3½ years"

String stage = SayableAge.formatStageDefault("2025-01-15", "2025-06-15");  // "Infant"

// Returns null for empty/future dates or ages exceeding 500 years
String nothing = SayableAge.formatAgeDefault("");  // null

// Instance-based with locale
SayableAge pt = new SayableAge(Locales.EN);
pt.formatAge("2022-06-15", "2025-12-15");   // "3½ years"
pt.formatStage("2022-06-15", "2025-06-15"); // "Child"
```

## Internationalization

```java
import sayableage.SayableAge;
import sayableage.Locales;

SayableAge pt = new SayableAge(Locales.JA);
pt.formatAge("2025-01-01", "2025-07-15");   // "6ヶ月"
pt.formatStage("2025-01-01", "2025-07-15"); // "乳児"
```

110 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```java
import sayableage.Compactness;

SayableAge normal  = new SayableAge(Locales.EN);                       // "3 months"
SayableAge short_  = new SayableAge(Locales.EN, Compactness.SHORT);    // "3 mo"
SayableAge compact = new SayableAge(Locales.EN, Compactness.COMPACT);  // "3m"
```

## API

```java
public final class SayableAge {
    public SayableAge(AgeLocale locale)
    public SayableAge(AgeLocale locale, Compactness compactness)

    public String formatAge(String dateOfBirth, String asOf)
    public String formatAge(String dateOfBirth)
    public String formatStage(String dateOfBirth, String asOf, String gender)
    public String formatStage(String dateOfBirth, String asOf)
    public String formatStage(String dateOfBirth)

    // Static convenience methods using default English locale
    public static String formatAgeDefault(String dateOfBirth, String asOf)
    public static String formatAgeDefault(String dateOfBirth)
    public static String formatStageDefault(String dateOfBirth, String asOf, String gender)
    public static String formatStageDefault(String dateOfBirth, String asOf)
    public static String formatStageDefault(String dateOfBirth)
}
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `null` for empty strings.
- `asOf` — Optional reference date. Defaults to today.

**Returns:** `String` (nullable) — the formatted string, or `null` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
./gradlew test    # Run tests
./gradlew build   # Build
```

## Code quality

- `-Xlint:all -Werror` — all compiler warnings are errors
- Java 17 — sealed interfaces, records, pattern matching
- JUnit 5 for testing
- See [code quality docs](../../docs/code-quality-compiled.md#java) for details

## License

[MIT](../../LICENSE.md)

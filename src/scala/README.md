# parent-time — Scala

A thoughtful time formatting library that reflects how we think about little ones.

```scala
val age = ParentTime.formatAge("2025-06-01", "2025-06-15")  // Some("2 weeks")
val stage = ParentTime.formatStage("2025-01-15", "2025-06-15")  // Some("Infant")
```

## Installation

Add to your `build.gradle.kts`:

```kotlin
dependencies {
    implementation("com.github.dnf:parent-time:0.1.0")
}
```

Requires JVM 17+. Zero external dependencies.

## Usage

```scala
import parenttime.ParentTime
import parenttime.Locales

// Companion object functions — English default
val age = ParentTime.formatAge("2025-06-15", "2025-06-15")    // Some("Newborn")
val age2 = ParentTime.formatAge("2025-06-01", "2025-06-15")   // Some("2 weeks")
val age3 = ParentTime.formatAge("2025-01-15", "2025-07-15")   // Some("6 months")
val age4 = ParentTime.formatAge("2022-06-15", "2025-12-15")   // Some("3½ years")

val stage = ParentTime.formatStage("2025-01-15", "2025-06-15")  // Some("Infant")

// Returns None for empty/future dates or ages exceeding 500 years
val nothing = ParentTime.formatAge("")  // None

// Class-based with locale
val pt = new ParentTime(Locales.EN)
pt.formatAge("2022-06-15", "2025-12-15")   // Some("3½ years")
pt.formatStage("2022-06-15", "2025-06-15") // Some("Child")
```

## Internationalization

```scala
import parenttime.ParentTime
import parenttime.Locales

val pt = new ParentTime(Locales.JA)
pt.formatAge("2025-01-01", "2025-07-15")   // Some("6ヶ月")
pt.formatStage("2025-01-01", "2025-07-15") // Some("乳児")
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```scala
import parenttime.Compactness

val normal  = new ParentTime(Locales.EN)                       // "3 months"
val short   = new ParentTime(Locales.EN, Compactness.SHORT)    // "3 mo"
val compact = new ParentTime(Locales.EN, Compactness.COMPACT)  // "3m"
```

## API

```scala
class ParentTime(locale: AgeLocale, compactness: Compactness = Compactness.NORMAL):
    def formatAge(dateOfBirth: String, asOf: String = null): Option[String]
    def formatStage(dateOfBirth: String, asOf: String = null, gender: String = null): Option[String]

object ParentTime:
    def formatAge(dateOfBirth: String, asOf: String = null): Option[String]
    def formatStage(dateOfBirth: String, asOf: String = null, gender: String = null): Option[String]
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `None` for empty strings.
- `asOf` — Optional reference date. Defaults to today.

**Returns:** `Option[String]` — the formatted string, or `None` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
./gradlew test    # Run tests
./gradlew build   # Build
```

## Code quality

- `-Werror` — zero warnings policy
- Scala 3 with Scala 3 idioms (enums, case classes, sealed traits, match expressions)
- JVM target: 17 (current LTS)

## License

[MIT](../../LICENSE.md)

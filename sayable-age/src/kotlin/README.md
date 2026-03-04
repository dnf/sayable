# sayable-age — Kotlin

A thoughtful time formatting library that reflects how we think about little ones.

```kotlin
val age = SayableAge.formatAge("2025-06-01", "2025-06-15")  // "2 weeks"
val stage = SayableAge.formatStage("2025-01-15", "2025-06-15")  // "Infant"
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

```kotlin
import sayableage.SayableAge
import sayableage.Locales

// Companion object functions — English default
val age = SayableAge.formatAge("2025-06-15", "2025-06-15")    // "Newborn"
val age2 = SayableAge.formatAge("2025-06-01", "2025-06-15")   // "2 weeks"
val age3 = SayableAge.formatAge("2025-01-15", "2025-07-15")   // "6 months"
val age4 = SayableAge.formatAge("2022-06-15", "2025-12-15")   // "3½ years"

val stage = SayableAge.formatStage("2025-01-15", "2025-06-15")  // "Infant"

// Returns null for empty/future dates or ages exceeding 500 years
val nothing = SayableAge.formatAge("")  // null

// Class-based with locale
val pt = SayableAge(Locales.EN)
pt.formatAge("2022-06-15", "2025-12-15")   // "3½ years"
pt.formatStage("2022-06-15", "2025-06-15") // "Child"
```

## Internationalization

```kotlin
import sayableage.SayableAge
import sayableage.Locales

val pt = SayableAge(Locales.JA)
pt.formatAge("2025-01-01", "2025-07-15")   // "6ヶ月"
pt.formatStage("2025-01-01", "2025-07-15") // "乳児"
```

71 built-in locales are available. See the [locale documentation](../../docs/locales.md) for details.

## Compactness

```kotlin
import sayableage.Compactness

val normal  = SayableAge(Locales.EN)                       // "3 months"
val short   = SayableAge(Locales.EN, Compactness.SHORT)    // "3 mo"
val compact = SayableAge(Locales.EN, Compactness.COMPACT)  // "3m"
```

## API

```kotlin
class SayableAge(locale: AgeLocale, compactness: Compactness = Compactness.NORMAL) {
    fun formatAge(dateOfBirth: String, asOf: String? = null): String?
    fun formatStage(dateOfBirth: String, asOf: String? = null): String?

    companion object {
        fun formatAge(dateOfBirth: String, asOf: String? = null): String?
        fun formatStage(dateOfBirth: String, asOf: String? = null): String?
    }
}
```

**Parameters:**

- `dateOfBirth` — `YYYY-MM-DD` string. Returns `null` for empty strings.
- `asOf` — Optional reference date. Defaults to today.

**Returns:** `String?` — the formatted string, or `null` if input is invalid, DOB is in the future, or age exceeds 500 years.

## Development

```bash
./gradlew test    # Run tests
./gradlew build   # Build
```

## Code quality

- `explicitApi()` — all declarations must have explicit visibility
- `allWarningsAsErrors` — zero warnings policy
- `progressiveMode` — opt into stricter future behavior
- `-Xjsr305=strict` — strict Java nullability interop
- JVM target: 17 (current LTS)
- See [code quality docs](../../docs/code-quality-compiled.md#kotlin) for details

## License

[MIT](../../LICENSE.md)

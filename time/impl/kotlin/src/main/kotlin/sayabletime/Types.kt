package sayabletime

/**
 * Natural language clock reading configuration.
 */
public data class ClockConfig(
    val hours: List<String>,
    val midnight: String,
    val noon: String,
    val patterns: Map<Int, String>
)

/**
 * Digital clock display configuration for short/compact modes.
 */
public data class ShortClockConfig(
    val use24h: Boolean,
    val amPm: Pair<String, String>? = null,
    val format: String
)

/**
 * Optional overrides for short/compact display modes.
 */
public data class CompactnessOverride(
    val clock: ShortClockConfig? = null
)

/**
 * Controls the verbosity of formatted output.
 */
public enum class Compactness {
    NORMAL, SHORT, COMPACT
}

/**
 * Locale definition for clock time formatting.
 */
public data class TimeLocale(
    val code: String,
    val clock: ClockConfig,
    val short: CompactnessOverride? = null,
    val compact: CompactnessOverride? = null
)

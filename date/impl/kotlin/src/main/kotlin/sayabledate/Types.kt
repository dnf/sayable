package sayabledate

/**
 * Controls the verbosity of formatted output.
 */
public enum class Compactness {
    NORMAL, SHORT, COMPACT
}

/**
 * Holds optional overrides for short/compact display modes.
 * Null fields mean "use the base locale value."
 */
public data class CompactnessOverride(
    val months: List<String>? = null,
    val monthsInDate: List<String>? = null,
    val weekdays: List<String>? = null,
    val dayFormat: String? = null,
    val dayFormatExceptions: Map<String, String>? = null,
    val datePattern: String? = null,
    val datePatternWithYear: String? = null,
    val today: String? = null,
    val tomorrow: String? = null,
    val yesterday: String? = null
)

/**
 * Defines all locale-specific data for date formatting.
 */
public data class DateLocale(
    val code: String,
    val months: List<String>,
    val weekdays: List<String>,
    val dayFormat: String,
    val dayFormatExceptions: Map<String, String> = emptyMap(),
    val datePattern: String = "{day} {month}",
    val datePatternWithYear: String = "{day} {month} {year}",
    val today: String = "today",
    val tomorrow: String = "tomorrow",
    val yesterday: String = "yesterday",
    val dayAfterTomorrow: String? = null,
    val dayBeforeYesterday: String? = null,
    val thisWeekday: String? = null,
    val nextWeekday: String? = null,
    val lastWeekday: String? = null,
    val monthsInDate: List<String>? = null,
    val short: CompactnessOverride? = null,
    val compact: CompactnessOverride? = null
)

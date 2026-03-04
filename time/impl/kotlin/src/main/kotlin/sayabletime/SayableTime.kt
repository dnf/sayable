package sayabletime

import sayabletime.locales.Locales

public const val VERSION: String = "0.1.0"

/**
 * Locale-aware clock time formatter.
 *
 * Formats clock times as natural-language readings like
 * "a quarter past two", "half past nine", or "midnight".
 *
 * @param locale The locale to use for formatting.
 * @param compactness The compactness level (default: NORMAL).
 */
public class SayableTime(
    private val locale: TimeLocale,
    compactness: Compactness = Compactness.NORMAL
) {
    private val shortClock: ShortClockConfig?

    init {
        val ovr = when (compactness) {
            Compactness.SHORT -> locale.short
            Compactness.COMPACT -> locale.compact
            Compactness.NORMAL -> null
        }
        shortClock = ovr?.clock
    }

    /**
     * Format a time as a natural language clock reading.
     *
     * [input] should be "HH:MM" or an ISO datetime string.
     * Returns null for null, empty, or invalid input.
     */
    public fun formatTime(input: String?): String? {
        if (input.isNullOrEmpty()) return null
        val parsed = parseTime(input) ?: return null
        val (hour, minute) = parsed

        if (shortClock != null) {
            return formatDigital(hour, minute)
        }
        return formatNatural(hour, minute)
    }

    private fun formatNatural(hour: Int, minute: Int): String {
        val clock = locale.clock
        var rounded = roundTo5(minute)
        var h = hour
        if (rounded == 60) {
            rounded = 0
            h = (h + 1) % 24
        }
        if (rounded == 0) {
            if (h == 0) return clock.midnight
            if (h == 12) return clock.noon
        }
        val h12 = h % 12
        val nextH12 = (h + 1) % 12
        val hName = clock.hours[h12]
        val nextHName = clock.hours[nextH12]
        val pattern = clock.patterns[rounded] ?: clock.patterns[0] ?: "{h}"
        return pattern.replace("{h}", hName).replace("{next_h}", nextHName)
    }

    private fun formatDigital(hour: Int, minute: Int): String {
        val sc = shortClock!!
        val fmt = sc.format
        if (sc.use24h) {
            return fmt
                .replace("{h}", hour.toString())
                .replace("{mm}", minute.toString().padStart(2, '0'))
        }
        var h12 = hour % 12
        if (h12 == 0) h12 = 12
        val amPm = sc.amPm ?: Pair("AM", "PM")
        val ampmStr = if (hour < 12) amPm.first else amPm.second
        return fmt
            .replace("{h}", h12.toString())
            .replace("{mm}", minute.toString().padStart(2, '0'))
            .replace("{ampm}", ampmStr)
    }

    public companion object {
        private val defaultSt = SayableTime(Locales.EN)

        /**
         * Format clock time using the default English locale (normal compactness).
         */
        public fun formatTime(input: String?): String? = defaultSt.formatTime(input)
    }
}

/**
 * Parse "HH:MM" or ISO datetime string into (hour, minute).
 * Returns null on failure.
 */
internal fun parseTime(input: String): Pair<Int, Int>? {
    if (input.isEmpty()) return null
    var t = input
    val tIdx = t.indexOf('T')
    if (tIdx >= 0) t = t.substring(tIdx + 1)
    val plusIdx = t.indexOf('+')
    if (plusIdx >= 0) t = t.substring(0, plusIdx)
    val zIdx = t.indexOf('Z')
    if (zIdx >= 0) t = t.substring(0, zIdx)
    val parts = t.split(":")
    if (parts.size < 2) return null
    val hour = parts[0].toIntOrNull() ?: return null
    val minute = parts[1].toIntOrNull() ?: return null
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null
    return Pair(hour, minute)
}

/**
 * Round minute to nearest 5.
 */
internal fun roundTo5(minute: Int): Int {
    return (minute + 2) / 5 * 5
}

package sayabledate

import sayabledate.locales.Locales

/** Library version, matching date/config/version.json. */
public const val VERSION: String = "0.5.0"

/**
 * A locale-aware date formatter.
 *
 * ```kotlin
 * val sd = SayableDate(Locales.EN)
 * sd.formatDate("2025-03-15")                          // "March 15th"
 * sd.formatRelative("2025-03-16", "2025-03-15")        // "tomorrow"
 * ```
 */
public class SayableDate(
    private val locale: DateLocale,
    private val compactness: Compactness = Compactness.NORMAL
) {
    private val months: List<String>
    private val monthsInDate: List<String>?
    private val weekdays: List<String>
    private val dayFormat: String
    private val dayFormatExceptions: Map<String, String>
    private val datePattern: String
    private val datePatternWithYear: String
    private val todayStr: String
    private val tomorrowStr: String
    private val yesterdayStr: String

    init {
        val ovr = when (compactness) {
            Compactness.SHORT -> locale.short
            Compactness.COMPACT -> locale.compact
            Compactness.NORMAL -> null
        }

        months = ovr?.months ?: locale.months
        monthsInDate = ovr?.monthsInDate ?: locale.monthsInDate
        weekdays = ovr?.weekdays ?: locale.weekdays

        // When override provides dayFormat but not dayFormatExceptions, clear exceptions
        if (ovr?.dayFormat != null && ovr.dayFormatExceptions == null) {
            dayFormat = ovr.dayFormat
            dayFormatExceptions = emptyMap()
        } else {
            dayFormat = ovr?.dayFormat ?: locale.dayFormat
            dayFormatExceptions = ovr?.dayFormatExceptions ?: locale.dayFormatExceptions
        }

        datePattern = ovr?.datePattern ?: locale.datePattern
        datePatternWithYear = ovr?.datePatternWithYear ?: locale.datePatternWithYear
        todayStr = ovr?.today ?: locale.today
        tomorrowStr = ovr?.tomorrow ?: locale.tomorrow
        yesterdayStr = ovr?.yesterday ?: locale.yesterday
    }

    /**
     * Formats a calendar date in locale-appropriate form (no year).
     * Returns null if the input is null, empty, or unparseable.
     */
    public fun formatDate(date: String?): String? {
        if (date.isNullOrEmpty()) return null
        val parsed = parseDate(date) ?: return null
        return formatAbsolute(parsed[0], parsed[1], parsed[2], false)
    }

    /**
     * Formats a calendar date with year in locale-appropriate form.
     * Returns null if the input is null, empty, or unparseable.
     */
    public fun formatDateWithYear(date: String?): String? {
        if (date.isNullOrEmpty()) return null
        val parsed = parseDate(date) ?: return null
        return formatAbsolute(parsed[0], parsed[1], parsed[2], true)
    }

    /**
     * Formats a date relative to [asOf], picking the most natural reference.
     * Falls back to absolute date for distant dates.
     * Returns null if either input is null, empty, or unparseable.
     */
    public fun formatRelative(date: String?, asOf: String?): String? {
        if (date.isNullOrEmpty() || asOf.isNullOrEmpty()) return null
        val parsedDate = parseDate(date) ?: return null
        val parsedAsOf = parseDate(asOf) ?: return null

        val dy = parsedDate[0]
        val dm = parsedDate[1]
        val dd = parsedDate[2]
        val ay = parsedAsOf[0]

        val dateJdn = toJdn(dy, dm, dd)
        val asofJdn = toJdn(parsedAsOf[0], parsedAsOf[1], parsedAsOf[2])
        val diff = dateJdn - asofJdn

        // Today
        if (diff == 0) return todayStr

        // Tomorrow
        if (diff == 1) return tomorrowStr

        // Yesterday
        if (diff == -1) return yesterdayStr

        val isCompact = compactness == Compactness.COMPACT

        // Day after tomorrow (optional, skipped in compact mode)
        if (diff == 2 && locale.dayAfterTomorrow != null && !isCompact) {
            return locale.dayAfterTomorrow
        }

        // Day before yesterday (optional, skipped in compact mode)
        if (diff == -2 && locale.dayBeforeYesterday != null && !isCompact) {
            return locale.dayBeforeYesterday
        }

        // Compact mode: skip weekday references, go straight to calendar date
        if (isCompact) {
            return formatAbsolute(dy, dm, dd, dy != ay)
        }

        // This weekday (+2 to +6)
        val thisWd = locale.thisWeekday
        if (diff in 2..6 && thisWd != null) {
            val dow = weekday(dy, dm, dd)
            val wdName = weekdays[dow]
            return thisWd.replace("{weekday}", wdName)
        }

        // Last weekday (-6 to -2)
        val lastWd = locale.lastWeekday
        if (diff in -6..-2 && lastWd != null) {
            val dow = weekday(dy, dm, dd)
            val wdName = weekdays[dow]
            return lastWd.replace("{weekday}", wdName)
        }

        // Next weekday (+7 to +13)
        val nextWd = locale.nextWeekday
        if (diff in 7..13 && nextWd != null) {
            val dow = weekday(dy, dm, dd)
            val wdName = weekdays[dow]
            return nextWd.replace("{weekday}", wdName)
        }

        // Calendar fallback
        return formatAbsolute(dy, dm, dd, dy != ay)
    }

    private fun formatAbsolute(year: Int, month: Int, day: Int, includeYear: Boolean): String {
        val dayStr = day.toString()
        val fmt = dayFormatExceptions[dayStr] ?: dayFormat
        val formattedDay = fmt.replace("{n}", dayStr)

        // Pick month name (genitive form if available)
        val monthName = (monthsInDate ?: months)[month - 1]

        val pattern = if (includeYear) datePatternWithYear else datePattern
        var result = pattern.replace("{month}", monthName)
        result = result.replace("{day}", formattedDay)
        result = result.replace("{d}", day.toString())
        result = result.replace("{m}", month.toString())
        if (includeYear) {
            result = result.replace("{year}", year.toString())
            val yy = year % 100
            result = result.replace("{yy}", yy.toString().padStart(2, '0'))
        }

        return result
    }

    public companion object {
        private val defaultInstance = SayableDate(Locales.EN)

        /** Formats a date using the default English locale. */
        public fun formatDate(date: String?): String? = defaultInstance.formatDate(date)

        /** Formats a relative date using the default English locale. */
        public fun formatRelative(date: String?, asOf: String?): String? =
            defaultInstance.formatRelative(date, asOf)
    }
}

/** Parse "YYYY-MM-DD" or ISO datetime to [year, month, day]. Returns null on failure. */
internal fun parseDate(s: String): IntArray? {
    if (s.isEmpty()) return null
    // Strip time part from ISO datetime
    val datePart = if (s.contains('T')) s.substringBefore('T') else s
    val parts = datePart.split('-')
    if (parts.size != 3) return null
    val year = safeAtoi(parts[0]) ?: return null
    val month = safeAtoi(parts[1]) ?: return null
    val day = safeAtoi(parts[2]) ?: return null
    if (month < 1 || month > 12 || day < 1 || day > 31) return null
    return intArrayOf(year, month, day)
}

/** Converts a string of digits to an int. Returns null if any character is not a digit. */
internal fun safeAtoi(s: String): Int? {
    if (s.isEmpty()) return null
    var n = 0
    for (c in s) {
        if (c < '0' || c > '9') return null
        n = n * 10 + (c - '0')
    }
    return n
}

/** Convert a date to Julian Day Number for day-difference arithmetic. */
internal fun toJdn(year: Int, month: Int, day: Int): Int {
    val a = (14 - month) / 12
    val y = year + 4800 - a
    val m = month + 12 * a - 3
    return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
}

/** Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday. */
internal fun weekday(year: Int, month: Int, day: Int): Int {
    return (toJdn(year, month, day) + 1) % 7
}

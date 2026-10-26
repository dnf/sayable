package sayableduration

import sayableduration.locales.Locales
import kotlin.math.abs
import kotlin.math.roundToLong

public const val VERSION: String = "0.5.0"

/** 500 years, the same ceiling as sayable-age. */
private const val MAX_DURATION_MONTHS = 6000L

/**
 * A locale-aware duration and relative time formatter.
 */
public class SayableDuration(
    private val locale: DurationLocale,
    compactness: Compactness = Compactness.NORMAL
) {
    private val second: UnitForms
    private val minute: UnitForms
    private val hour: UnitForms
    private val day: UnitForms
    private val week: UnitForms
    private val month: UnitForms
    private val year: UnitForms
    private val half: String
    private val delimiter: String
    private val justNow: String
    private val ago: String
    private val inFuture: String

    init {
        var s = locale.units.second
        var min = locale.units.minute
        var h = locale.units.hour
        var d = locale.units.day
        var w = locale.units.week
        var mo = locale.units.month
        var y = locale.units.year
        var hf = locale.half
        var del = locale.delimiter
        val jn = locale.justNow
        var ag = locale.ago
        var inf = locale.inFuture

        val ovr = when (compactness) {
            Compactness.SHORT -> locale.short
            Compactness.COMPACT -> locale.compact
            Compactness.NORMAL -> null
        }

        if (ovr != null) {
            if (ovr.second != null) s = ovr.second
            if (ovr.minute != null) min = ovr.minute
            if (ovr.hour != null) h = ovr.hour
            if (ovr.day != null) d = ovr.day
            if (ovr.week != null) w = ovr.week
            if (ovr.month != null) mo = ovr.month
            if (ovr.year != null) y = ovr.year
            if (ovr.half != null) hf = ovr.half
            if (ovr.delimiter != null) del = ovr.delimiter
            if (ovr.ago != null) ag = ovr.ago
            if (ovr.inFuture != null) inf = ovr.inFuture
        }

        second = s
        minute = min
        hour = h
        day = d
        week = w
        month = mo
        year = y
        half = hf
        delimiter = del
        justNow = jn
        ago = ag
        inFuture = inf
    }

    /**
     * Formats an integer number of seconds as a human-friendly duration string.
     * Returns null for negative values.
     */
    public fun formatDurationSeconds(seconds: Long): String? {
        if (seconds < 0) return null
        return formatDurationSecondsInternal(seconds)
    }

    /**
     * Formats the duration between two ISO datetime strings.
     * Returns null if either string is empty or cannot be parsed.
     */
    public fun formatDurationIso(start: String, end: String): String? {
        if (start.isEmpty() || end.isEmpty()) return null
        val s = parseIsoToSeconds(start) ?: return null
        val e = parseIsoToSeconds(end) ?: return null
        val total = abs(e - s)
        return formatDurationSecondsInternal(total)
    }

    /**
     * Formats elapsed time as "X ago".
     * Returns null if start or asOf are empty, unparseable, or if asOf is before start.
     */
    public fun formatSince(start: String?, asOf: String?): String? {
        if (start.isNullOrEmpty() || asOf.isNullOrEmpty()) return null
        val s = parseIsoToSeconds(start) ?: return null
        val a = parseIsoToSeconds(asOf) ?: return null
        val diff = a - s
        if (diff < 0) return null
        if (diff == 0L) return justNow
        val dur = formatDurationSecondsInternal(diff) ?: return null
        return ago.replace("{0}", dur)
    }

    /**
     * Formats time until a future event as "in X".
     * Returns null if target or asOf are empty, unparseable, or if target is before asOf.
     */
    public fun formatUntil(target: String?, asOf: String?): String? {
        if (target.isNullOrEmpty() || asOf.isNullOrEmpty()) return null
        val t = parseIsoToSeconds(target) ?: return null
        val a = parseIsoToSeconds(asOf) ?: return null
        val diff = t - a
        if (diff < 0) return null
        if (diff == 0L) return justNow
        val dur = formatDurationSecondsInternal(diff) ?: return null
        return inFuture.replace("{0}", dur)
    }

    private fun formatDurationSecondsInternal(total: Long): String? {
        val loc = locale

        // 0 seconds
        if (total == 0L) return justNow

        // 1-59 seconds
        if (total < 60) return resolveUnit(total, second, loc)

        val totalMinutes = total / 60
        val remainderSeconds = total % 60

        // 1-4 minutes: minutes + seconds
        if (totalMinutes < 5) {
            var result = resolveUnit(totalMinutes, minute, loc)
            if (remainderSeconds > 0L) {
                result += delimiter + resolveUnit(remainderSeconds, second, loc)
            }
            return result
        }

        // 5-59 minutes
        if (totalMinutes < 60) return resolveUnit(totalMinutes, minute, loc)

        val totalHours = total / 3600
        val remainderMinutes = (total % 3600) / 60

        // 1-5 hours: hours + minutes (with half marker)
        if (totalHours <= 5) {
            if (remainderMinutes == 30L) {
                return resolveUnit(totalHours, hour, loc, half)
            }
            var result = resolveUnit(totalHours, hour, loc)
            if (remainderMinutes > 0L) {
                result += delimiter + resolveUnit(remainderMinutes, minute, loc)
            }
            return result
        }

        // 6-23 hours
        if (totalHours < 24) return resolveUnit(totalHours, hour, loc)

        val totalDays = total / 86400
        val remainderHours = (total % 86400) / 3600

        // 1-2 days: days + hours (with half marker)
        if (totalDays <= 2) {
            if (remainderHours == 12L) {
                return resolveUnit(totalDays, day, loc, half)
            }
            var result = resolveUnit(totalDays, day, loc)
            if (remainderHours > 0L) {
                result += delimiter + resolveUnit(remainderHours, hour, loc)
            }
            return result
        }

        // 3-6 days
        if (totalDays < 7) return resolveUnit(totalDays, day, loc)

        val totalWeeks = totalDays / 7
        val remainderDays = totalDays % 7

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30) {
            var result = resolveUnit(totalWeeks, week, loc)
            if (remainderDays > 0L) {
                result += delimiter + resolveUnit(remainderDays, day, loc)
            }
            return result
        }

        // Approximate months (30.44 days average)
        var totalMonths = (totalDays.toDouble() / 30.44).roundToLong()
        if (totalMonths > MAX_DURATION_MONTHS) return null

        // 1-11 months
        if (totalMonths < 12) {
            if (totalMonths == 0L) totalMonths = 1
            return resolveUnit(totalMonths, month, loc)
        }

        // 12+ months: years + months
        val totalYears = totalMonths / 12
        val remainderMonths = totalMonths % 12
        var result = resolveUnit(totalYears, year, loc)
        if (remainderMonths > 0L) {
            result += delimiter + resolveUnit(remainderMonths, month, loc)
        }
        return result
    }

    public companion object {
        private val defaultSd = SayableDuration(Locales.EN)

        /**
         * Formats a duration in seconds using the default English locale.
         */
        public fun formatDurationSeconds(seconds: Long): String? =
            defaultSd.formatDurationSeconds(seconds)

        /**
         * Formats the duration between two ISO strings using the default English locale.
         */
        public fun formatDurationIso(start: String, end: String): String? =
            defaultSd.formatDurationIso(start, end)

        /**
         * Formats elapsed time using the default English locale.
         */
        public fun formatSince(start: String?, asOf: String?): String? =
            defaultSd.formatSince(start, asOf)

        /**
         * Formats time until event using the default English locale.
         */
        public fun formatUntil(target: String?, asOf: String?): String? =
            defaultSd.formatUntil(target, asOf)
    }
}

/**
 * Parses an ISO datetime string to epoch-relative seconds for diffing.
 * Returns null if the string is empty or cannot be parsed.
 */
internal fun parseIsoToSeconds(iso: String): Long? {
    val match = TIMESTAMP.matchEntire(iso) ?: return null
    val (year, month, day, hour, minute) = match.destructured.toList().take(5).map { it.toInt() }
    val second = match.groupValues[6].ifEmpty { "0" }.toInt()
    if (month !in 1..12 || day !in 1..daysInMonth(year, month)) return null
    if (hour > 23 || minute > 59 || second > 59) return null
    val days = daysSinceEpoch(year, month, day).toLong()
    return days * 86400 + hour * 3600 + minute * 60 + second
}

/** YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored). */
private val TIMESTAMP = Regex(
    """([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})""" +
        """(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?"""
)

/** Counts are bounded by the 500-year ceiling, so they always fit in an Int. */
private fun resolveUnit(count: Long, uf: UnitForms, locale: DurationLocale, half: String = ""): String =
    resolveUnit(Math.toIntExact(count), uf, locale, half)

/**
 * Returns whether the given year is a leap year.
 */
private fun isLeapYear(year: Int): Boolean =
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)

/**
 * Returns the number of days in the given month/year.
 */
private fun daysInMonth(year: Int, month: Int): Int = when (month) {
    1, 3, 5, 7, 8, 10, 12 -> 31
    4, 6, 9, 11 -> 30
    2 -> if (isLeapYear(year)) 29 else 28
    else -> 30
}

/**
 * Calculates days since a reference epoch (2000-01-01).
 */
private fun daysSinceEpoch(year: Int, month: Int, day: Int): Int {
    var days = 0
    if (year >= 2000) {
        for (y in 2000 until year) {
            days += if (isLeapYear(y)) 366 else 365
        }
    } else {
        for (y in year until 2000) {
            days -= if (isLeapYear(y)) 366 else 365
        }
    }
    for (m in 1 until month) {
        days += daysInMonth(year, m)
    }
    days += day - 1
    return days
}

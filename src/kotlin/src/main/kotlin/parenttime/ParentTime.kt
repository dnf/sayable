package parenttime

import java.time.LocalDate
import java.time.YearMonth
import java.time.temporal.ChronoUnit
import parenttime.locales.Locales

private const val MAX_AGE_MONTHS = 6000

/**
 * Package-level function for getting "today". Can be overridden in tests.
 */
internal var timeNow: () -> LocalDate = { LocalDate.now() }

/**
 * Internal age components from parsing.
 */
internal data class AgeComponents(
    val months: Int,
    val diffDays: Int
)

/**
 * Parses two YYYY-MM-DD strings into calendar months and elapsed days.
 * Returns null if dateOfBirth is empty, unparseable, or in the future relative to asOf.
 */
internal fun parseAge(dateOfBirth: String, asOf: String? = null): AgeComponents? {
    if (dateOfBirth.isEmpty()) return null

    val dobParts = parseDateParts(dateOfBirth) ?: return null
    val (dobY, dobM, dobD) = dobParts

    val refParts: Triple<Int, Int, Int>
    if (asOf != null && asOf.isNotEmpty()) {
        refParts = parseDateParts(asOf) ?: return null
    } else {
        val now = timeNow()
        refParts = Triple(now.year, now.monthValue, now.dayOfMonth)
    }
    val (refY, refM, refD) = refParts

    val dobDate = LocalDate.of(dobY, dobM, dobD)
    val refDate = LocalDate.of(refY, refM, refD)
    val diffDays = ChronoUnit.DAYS.between(dobDate, refDate).toInt()
    if (diffDays < 0) return null

    // Calendar months: clamp birthday to last day of reference month so that
    // e.g. a child born Jan 31 turns 1 month old on Feb 28 (or 29 in a leap year).
    val lastDay = YearMonth.of(refY, refM).lengthOfMonth()
    val clampedBirthday = minOf(dobD, lastDay)
    var months = (refY - dobY) * 12 + (refM - dobM)
    if (refD < clampedBirthday) months--
    if (months > MAX_AGE_MONTHS) return null

    return AgeComponents(months = months, diffDays = diffDays)
}

/**
 * Parses "YYYY-MM-DD" into (year, month, day). Returns null on failure.
 */
internal fun parseDateParts(s: String): Triple<Int, Int, Int>? {
    if (s.length < 10 || s[4] != '-' || s[7] != '-') return null
    val y = safeAtoi(s.substring(0, 4)) ?: return null
    val m = safeAtoi(s.substring(5, 7)) ?: return null
    val d = safeAtoi(s.substring(8, 10)) ?: return null
    if (y == 0 && m == 0 && d == 0) return null
    return Triple(y, m, d)
}

/**
 * Converts a string of digits to an int. Returns null if any character is not a digit.
 */
internal fun safeAtoi(s: String): Int? {
    var n = 0
    for (c in s) {
        if (c < '0' || c > '9') return null
        n = n * 10 + (c - '0')
    }
    return n
}

/**
 * Returns the developmental stage key for the given calendar months.
 */
internal fun stageKey(months: Int): String = when {
    months < 2 -> "newborn"
    months < 12 -> "infant"
    months < 36 -> "toddler"
    months < 156 -> "child"
    months < 216 -> "teenager"
    else -> "adult"
}

/**
 * Formats a count with the given unit forms, locale, and optional half marker.
 *
 * The half template supports two placeholder styles:
 * - `{n}` modifies the formatted number before unit substitution (e.g. "3½" instead of "3")
 * - `{0}` wraps the fully resolved expression after unit substitution (e.g. "3 years and a half")
 */
internal fun resolveUnit(count: Int, uf: UnitForms, loc: AgeLocale, half: String): String {
    val baseN = if (loc.formatNumber != null) {
        loc.formatNumber.invoke(count)
    } else {
        count.toString()
    }

    // Apply {n}-style half marker to the number
    val n = if (half.isNotEmpty() && half.contains("{n}")) {
        half.replace("{n}", baseN)
    } else {
        baseN
    }

    // Select template
    val template = if (uf.simple != null) {
        uf.simple
    } else {
        val cat = loc.plural(count)
        uf.forms?.get(cat) ?: uf.forms?.get(PluralCategory.OTHER) ?: "{n}"
    }

    var result = template.replace("{n}", n)

    if (loc.formatUnit != null) {
        result = loc.formatUnit.invoke(count, result)
    }

    // Apply {0}-style half marker (wraps the whole expression)
    if (half.isNotEmpty() && half.contains("{0}")) {
        result = half.replace("{0}", result)
    }

    return result
}

/**
 * A locale-aware age formatter.
 */
public class ParentTime(
    private val locale: AgeLocale,
    compactness: Compactness = Compactness.NORMAL
) {
    private val day: UnitForms
    private val week: UnitForms
    private val month: UnitForms
    private val year: UnitForms
    private val half: String
    private val delimiter: String
    private val justBorn: String

    init {
        var d = locale.units.day
        var w = locale.units.week
        var m = locale.units.month
        var y = locale.units.year
        var h = locale.half
        var del = locale.delimiter
        var jb = locale.justBorn

        val ovr = when (compactness) {
            Compactness.SHORT -> locale.short
            Compactness.COMPACT -> locale.compact
            Compactness.NORMAL -> null
        }

        if (ovr != null) {
            if (ovr.day != null) d = ovr.day
            if (ovr.week != null) w = ovr.week
            if (ovr.month != null) m = ovr.month
            if (ovr.year != null) y = ovr.year
            if (ovr.half != null) h = ovr.half
            if (ovr.delimiter != null) del = ovr.delimiter
            if (ovr.justBorn != null) jb = ovr.justBorn
        }

        day = d
        week = w
        month = m
        year = y
        half = h
        delimiter = del
        justBorn = jb
    }

    /**
     * Returns a human-friendly age string.
     * [dateOfBirth] and [asOf] must be in YYYY-MM-DD format.
     * Returns null if dateOfBirth is empty or in the future.
     */
    public fun formatAge(dateOfBirth: String, asOf: String? = null): String? {
        val age = parseAge(dateOfBirth, asOf) ?: return null

        val months = age.months
        val diffDays = age.diffDays

        // Tier 1: 0 days
        if (diffDays == 0) return justBorn

        // Tier 1b: 1-6 days
        if (diffDays < 7) return resolveUnit(diffDays, day, locale, "")

        // Tier 2: weeks + days until 3 calendar months
        if (months < 3) {
            val weeks = diffDays / 7
            val days = diffDays % 7
            var result = resolveUnit(weeks, week, locale, "")
            if (days > 0) {
                result += delimiter + resolveUnit(days, day, locale, "")
            }
            return result
        }

        // Tier 3: 3-23 months
        if (months < 24) return resolveUnit(months, month, locale, "")

        // Tier 4: 24-35 months -> years + months
        if (months < 36) {
            val years = months / 12
            val rem = months % 12
            if (rem == 0) return resolveUnit(years, year, locale, "")
            return resolveUnit(years, year, locale, "") + delimiter + resolveUnit(rem, month, locale, "")
        }

        // Tier 5: 3-6 years -> years with half marker
        if (months < 84) {
            val years = months / 12
            val rem = months % 12
            return if (rem >= 6) {
                resolveUnit(years, year, locale, half)
            } else {
                resolveUnit(years, year, locale, "")
            }
        }

        // Tier 6: 7+ years
        val years = months / 12
        return resolveUnit(years, year, locale, "")
    }

    /**
     * Returns the developmental stage label based on age.
     * Returns null if dateOfBirth is empty or in the future.
     * [gender] can be "m" or "f" for gendered locales; null defaults to masculine.
     */
    public fun formatStage(dateOfBirth: String, asOf: String? = null, gender: String? = null): String? {
        val age = parseAge(dateOfBirth, asOf) ?: return null
        val label = when (stageKey(age.months)) {
            "newborn" -> locale.stages.newborn
            "infant" -> locale.stages.infant
            "toddler" -> locale.stages.toddler
            "child" -> locale.stages.child
            "teenager" -> locale.stages.teenager
            "adult" -> locale.stages.adult
            else -> return null
        }
        return label.resolve(gender)
    }

    public companion object {
        private val defaultPt = ParentTime(Locales.EN)

        /**
         * Formats an age using the default English locale (normal compactness).
         */
        public fun formatAge(dateOfBirth: String, asOf: String? = null): String? =
            defaultPt.formatAge(dateOfBirth, asOf)

        /**
         * Returns the developmental stage using the default English locale.
         */
        public fun formatStage(dateOfBirth: String, asOf: String? = null, gender: String? = null): String? =
            defaultPt.formatStage(dateOfBirth, asOf, gender)
    }
}

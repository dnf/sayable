package sayableage

import java.time.LocalDate
import java.time.YearMonth
import java.time.temporal.ChronoUnit
import sayableage.locales.Locales

class SayableAge {

    static final String VERSION = "0.5.0"

    private static final int MAX_AGE_MONTHS = 6000

    // Package-visible for test clock override
    static Closure<LocalDate> timeNow = { -> LocalDate.now() }

    private final AgeLocale locale
    private final UnitForms day
    private final UnitForms week
    private final UnitForms month
    private final UnitForms year
    private final String half
    private final String delimiter
    private final String justBorn

    SayableAge(AgeLocale locale, Compactness compactness = Compactness.NORMAL) {
        this.locale = locale

        UnitForms d = locale.units.day
        UnitForms w = locale.units.week
        UnitForms m = locale.units.month
        UnitForms y = locale.units.year
        String h = locale.half
        String del = locale.delimiter
        String jb = locale.justBorn

        CompactnessOverride ovr = null
        switch (compactness) {
            case Compactness.SHORT:
                ovr = locale.shortOverride
                break
            case Compactness.COMPACT:
                ovr = locale.compactOverride
                break
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

        this.day = d
        this.week = w
        this.month = m
        this.year = y
        this.half = h
        this.delimiter = del
        this.justBorn = jb
    }

    /**
     * Returns a human-friendly age string.
     * dateOfBirth and asOf must be in YYYY-MM-DD format.
     * Returns null if dateOfBirth is empty or in the future.
     */
    String formatAge(String dateOfBirth, String asOf = null) {
        int[] age = parseAge(dateOfBirth, asOf)
        if (age == null) return null

        int months = age[0]
        int diffDays = age[1]

        // Tier 1: 0 days
        if (diffDays == 0) return justBorn

        // Tier 1b: 1-6 days
        if (diffDays < 7) return resolveUnit(diffDays, day, locale, '')

        // Tier 2: weeks + days until 3 calendar months
        if (months < 3) {
            int weeks = (int) (diffDays / 7)
            int days = diffDays % 7
            String result = resolveUnit(weeks, week, locale, '')
            if (days > 0) {
                result += delimiter + resolveUnit(days, day, locale, '')
            }
            return result
        }

        // Tier 3: 3-23 months
        if (months < 24) return resolveUnit(months, month, locale, '')

        // Tier 4: 24-35 months -> years + months
        if (months < 36) {
            int years = (int) (months / 12)
            int rem = months % 12
            if (rem == 0) return resolveUnit(years, year, locale, '')
            return resolveUnit(years, year, locale, '') + delimiter + resolveUnit(rem, month, locale, '')
        }

        // Tier 5: 3-6 years -> years with half marker
        if (months < 84) {
            int years = (int) (months / 12)
            int rem = months % 12
            if (rem >= 6) {
                return resolveUnit(years, year, locale, half)
            }
            return resolveUnit(years, year, locale, '')
        }

        // Tier 6: 7+ years
        int years = (int) (months / 12)
        return resolveUnit(years, year, locale, '')
    }

    /**
     * Returns the developmental stage label based on age.
     * Returns null if dateOfBirth is empty or in the future.
     * gender can be "m" or "f" for gendered locales; null defaults to masculine.
     */
    String formatStage(String dateOfBirth, String asOf = null, String gender = null) {
        int[] age = parseAge(dateOfBirth, asOf)
        if (age == null) return null

        String key = stageKey(age[0])
        StageLabel label
        switch (key) {
            case 'newborn':  label = locale.stages.newborn; break
            case 'infant':   label = locale.stages.infant; break
            case 'toddler':  label = locale.stages.toddler; break
            case 'child':    label = locale.stages.child; break
            case 'teenager': label = locale.stages.teenager; break
            case 'adult':    label = locale.stages.adult; break
            default: return null
        }
        return label.resolve(gender)
    }

    // --- Static convenience methods using English default ---

    private static final SayableAge DEFAULT_PT = new SayableAge(Locales.EN)

    static String formatAgeDefault(String dateOfBirth, String asOf = null) {
        DEFAULT_PT.formatAge(dateOfBirth, asOf)
    }

    static String formatStageDefault(String dateOfBirth, String asOf = null, String gender = null) {
        DEFAULT_PT.formatStage(dateOfBirth, asOf, gender)
    }

    // --- Internal helpers ---

    private static String stageKey(int months) {
        if (months < 2) return 'newborn'
        if (months < 12) return 'infant'
        if (months < 36) return 'toddler'
        if (months < 156) return 'child'
        if (months < 216) return 'teenager'
        return 'adult'
    }

    /**
     * Formats a count with the given unit forms, locale, and optional half marker.
     */
    private static String resolveUnit(int count, UnitForms uf, AgeLocale loc, String half) {
        String baseN = loc.formatNumber != null ? loc.formatNumber.call(count) : Integer.toString(count)

        // Apply {n}-style half marker to the number
        String n = (half != null && !half.isEmpty() && half.contains('{n}'))
            ? half.replace('{n}', baseN)
            : baseN

        // Select template
        String template
        if (uf.simple != null) {
            template = uf.simple
        } else {
            PluralCategory cat = loc.plural.call(count)
            template = uf.forms?.get(cat) ?: uf.forms?.get(PluralCategory.OTHER) ?: '{n}'
        }

        String result = template.replace('{n}', n)

        if (loc.formatUnit != null) {
            result = loc.formatUnit.call(count, result)
        }

        // Apply {0}-style half marker (wraps the whole expression)
        if (half != null && !half.isEmpty() && half.contains('{0}')) {
            result = half.replace('{0}', result)
        }

        return result
    }

    /**
     * Parses two YYYY-MM-DD strings into [calendarMonths, elapsedDays].
     * Returns null if dateOfBirth is empty, unparseable, or in the future.
     */
    private static int[] parseAge(String dateOfBirth, String asOf) {
        if (dateOfBirth == null || dateOfBirth.isEmpty()) return null

        int[] dobParts = parseDateParts(dateOfBirth)
        if (dobParts == null) return null

        int[] refParts
        if (asOf != null && !asOf.isEmpty()) {
            refParts = parseDateParts(asOf)
            if (refParts == null) return null
        } else {
            LocalDate now = timeNow.call()
            refParts = [now.year, now.monthValue, now.dayOfMonth] as int[]
        }

        int dobY = dobParts[0], dobM = dobParts[1], dobD = dobParts[2]
        int refY = refParts[0], refM = refParts[1], refD = refParts[2]

        LocalDate dobDate = LocalDate.of(dobY, dobM, dobD)
        LocalDate refDate = LocalDate.of(refY, refM, refD)
        int diffDays = (int) ChronoUnit.DAYS.between(dobDate, refDate)
        if (diffDays < 0) return null

        int lastDay = YearMonth.of(refY, refM).lengthOfMonth()
        int clampedBirthday = Math.min(dobD, lastDay)
        int months = (refY - dobY) * 12 + (refM - dobM)
        if (refD < clampedBirthday) months--
        if (months > MAX_AGE_MONTHS) return null

        return [months, diffDays] as int[]
    }

    /**
     * Parses "YYYY-MM-DD" into [year, month, day]. Returns null on failure.
     */
    private static int[] parseDateParts(String s) {
        char dash = '-' as char
        if (s.length() < 10 || s.charAt(4) != dash || s.charAt(7) != dash) return null
        Integer y = safeAtoi(s.substring(0, 4))
        Integer m = safeAtoi(s.substring(5, 7))
        Integer d = safeAtoi(s.substring(8, 10))
        if (y == null || m == null || d == null) return null
        if (y == 0 && m == 0 && d == 0) return null
        return [y, m, d] as int[]
    }

    /**
     * Converts a string of digits to an int. Returns null if any character is not a digit.
     */
    private static Integer safeAtoi(String s) {
        int n = 0
        char zero = '0' as char
        char nine = '9' as char
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i)
            if (c < zero || c > nine) return null
            n = n * 10 + (c - zero)
        }
        return n
    }
}

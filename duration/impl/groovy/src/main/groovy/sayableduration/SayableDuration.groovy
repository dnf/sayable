package sayableduration

import java.util.regex.Matcher
import java.util.regex.Pattern

import sayableduration.locales.Locales

class SayableDuration {

    static final String VERSION = '0.5.0'

    /** 500 years, the same ceiling as sayable-age. */
    private static final int MAX_DURATION_MONTHS = 6000

    /** YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored). */
    private static final Pattern TIMESTAMP =
        ~/([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?/

    private final DurationLocale locale
    private final UnitForms second
    private final UnitForms minute
    private final UnitForms hour
    private final UnitForms day
    private final UnitForms week
    private final UnitForms month
    private final UnitForms year
    private final String half
    private final String delimiter
    private final String justNow
    private final String ago
    private final String inFuture

    SayableDuration(DurationLocale locale, Compactness compactness = Compactness.NORMAL) {
        this.locale = locale

        UnitForms s = locale.units.second
        UnitForms min = locale.units.minute
        UnitForms h = locale.units.hour
        UnitForms d = locale.units.day
        UnitForms w = locale.units.week
        UnitForms mo = locale.units.month
        UnitForms y = locale.units.year
        String hf = locale.half
        String del = locale.delimiter
        String jn = locale.justNow
        String ag = locale.ago
        String inf = locale.inFuture

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

        this.second = s
        this.minute = min
        this.hour = h
        this.day = d
        this.week = w
        this.month = mo
        this.year = y
        this.half = hf
        this.delimiter = del
        this.justNow = jn
        this.ago = ag
        this.inFuture = inf
    }

    String formatDurationSeconds(long seconds) {
        if (seconds < 0) return null
        return formatDurationSecondsInternal(seconds)
    }

    String formatDurationIso(String start, String end) {
        if (start == null || start.isEmpty() || end == null || end.isEmpty()) return null
        Long s = parseIsoToSeconds(start)
        if (s == null) return null
        Long e = parseIsoToSeconds(end)
        if (e == null) return null
        long total = Math.abs(e - s)
        return formatDurationSecondsInternal(total)
    }

    String formatSince(String start, String asOf) {
        if (start == null || start.isEmpty() || asOf == null || asOf.isEmpty()) return null
        Integer s = parseIsoToSeconds(start)
        if (s == null) return null
        Long a = parseIsoToSeconds(asOf)
        if (a == null) return null
        long diff = a - s
        if (diff < 0) return null
        if (diff == 0) return justNow
        String dur = formatDurationSecondsInternal(diff)
        return dur == null ? null : ago.replace('{0}', dur)
    }

    String formatUntil(String target, String asOf) {
        if (target == null || target.isEmpty() || asOf == null || asOf.isEmpty()) return null
        Long t = parseIsoToSeconds(target)
        if (t == null) return null
        Integer a = parseIsoToSeconds(asOf)
        if (a == null) return null
        long diff = t - a
        if (diff < 0) return null
        if (diff == 0) return justNow
        String dur = formatDurationSecondsInternal(diff)
        return dur == null ? null : inFuture.replace('{0}', dur)
    }

    private String formatDurationSecondsInternal(long total) {
        // 0 seconds
        if (total == 0) return justNow

        // 1-59 seconds
        if (total < 60) return resolveUnit(total, second, locale, '')

        long totalMinutes = total.intdiv(60)
        long remainderSeconds = total % 60

        // 1-4 minutes: minutes + seconds
        if (totalMinutes < 5) {
            String result = resolveUnit(totalMinutes, minute, locale, '')
            if (remainderSeconds > 0) {
                result += delimiter + resolveUnit(remainderSeconds, second, locale, '')
            }
            return result
        }

        // 5-59 minutes
        if (totalMinutes < 60) return resolveUnit(totalMinutes, minute, locale, '')

        long totalHours = total.intdiv(3600)
        long remainderMinutes = (total % 3600).intdiv(60)

        // 1-5 hours: hours + minutes (with half marker)
        if (totalHours <= 5) {
            if (remainderMinutes == 30) {
                return resolveUnit(totalHours, hour, locale, half)
            }
            String result = resolveUnit(totalHours, hour, locale, '')
            if (remainderMinutes > 0) {
                result += delimiter + resolveUnit(remainderMinutes, minute, locale, '')
            }
            return result
        }

        // 6-23 hours
        if (totalHours < 24) return resolveUnit(totalHours, hour, locale, '')

        long totalDays = total.intdiv(86400)
        long remainderHours = (total % 86400).intdiv(3600)

        // 1-2 days: days + hours (with half marker)
        if (totalDays <= 2) {
            if (remainderHours == 12) {
                return resolveUnit(totalDays, day, locale, half)
            }
            String result = resolveUnit(totalDays, day, locale, '')
            if (remainderHours > 0) {
                result += delimiter + resolveUnit(remainderHours, hour, locale, '')
            }
            return result
        }

        // 3-6 days
        if (totalDays < 7) return resolveUnit(totalDays, day, locale, '')

        long totalWeeks = totalDays.intdiv(7)
        long remainderDays = totalDays % 7

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30) {
            String result = resolveUnit(totalWeeks, week, locale, '')
            if (remainderDays > 0) {
                result += delimiter + resolveUnit(remainderDays, day, locale, '')
            }
            return result
        }

        // Approximate months (30.44 days average)
        long totalMonths = Math.round(totalDays / 30.44d)
        if (totalMonths > MAX_DURATION_MONTHS) return null

        // 1-11 months
        if (totalMonths < 12) {
            if (totalMonths == 0) totalMonths = 1
            return resolveUnit(totalMonths, month, locale, '')
        }

        // 12+ months: years + months
        long totalYears = totalMonths.intdiv(12)
        long remainderMonths = totalMonths % 12
        String result = resolveUnit(totalYears, year, locale, '')
        if (remainderMonths > 0) {
            result += delimiter + resolveUnit(remainderMonths, month, locale, '')
        }
        return result
    }

    /** Counts are bounded by the 500-year ceiling, so they always fit in an int. */
    private static String resolveUnit(long boundedCount, UnitForms uf, DurationLocale loc, String half) {
        int count = Math.toIntExact(boundedCount)
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
            // Half-marked values use OTHER plural (e.g. "1½ hours" not "1½ hour")
            PluralCategory cat = (half != null && !half.isEmpty())
                ? PluralCategory.OTHER
                : loc.plural.call(count)
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

    // --- Static convenience methods using English default ---

    private static final SayableDuration DEFAULT = new SayableDuration(Locales.EN)

    static String formatDurationSecondsDefault(long seconds) {
        DEFAULT.formatDurationSeconds(seconds)
    }

    static String formatDurationIsoDefault(String start, String end) {
        DEFAULT.formatDurationIso(start, end)
    }

    static String formatSinceDefault(String start, String asOf) {
        DEFAULT.formatSince(start, asOf)
    }

    static String formatUntilDefault(String target, String asOf) {
        DEFAULT.formatUntil(target, asOf)
    }

    // --- ISO timestamp parsing ---

    private static Long parseIsoToSeconds(String iso) {
        if (iso == null) return null
        Matcher m = TIMESTAMP.matcher(iso)
        if (!m.matches()) return null
        int yearVal = m.group(1) as int
        int monthVal = m.group(2) as int
        int dayVal = m.group(3) as int
        int hourVal = m.group(4) as int
        int minuteVal = m.group(5) as int
        int secondVal = m.group(6) == null ? 0 : m.group(6) as int
        if (monthVal < 1 || monthVal > 12 || dayVal < 1 || dayVal > daysInMonth(yearVal, monthVal)) return null
        if (hourVal > 23 || minuteVal > 59 || secondVal > 59) return null
        long days = daysSinceEpoch(yearVal, monthVal, dayVal)
        return days * 86400 + hourVal * 3600 + minuteVal * 60 + secondVal
    }

    private static boolean isLeapYear(int year) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

    private static int daysInMonth(int year, int month) {
        switch (month) {
            case 1: case 3: case 5: case 7: case 8: case 10: case 12: return 31
            case 4: case 6: case 9: case 11: return 30
            case 2: return isLeapYear(year) ? 29 : 28
            default: return 30
        }
    }

    private static int daysSinceEpoch(int year, int month, int day) {
        int days = 0
        if (year >= 2000) {
            for (int y = 2000; y < year; y++) {
                days += isLeapYear(y) ? 366 : 365
            }
        } else {
            for (int y = year; y < 2000; y++) {
                days -= isLeapYear(y) ? 366 : 365
            }
        }
        for (int m = 1; m < month; m++) {
            days += daysInMonth(year, m)
        }
        days += day - 1
        return days
    }
}

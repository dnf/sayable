package sayableduration

import sayableduration.locales.Locales

class SayableDuration {

    static final String VERSION = '0.5.0'

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

    String formatDurationSeconds(int seconds) {
        if (seconds < 0) return null
        return formatDurationSecondsInternal(seconds)
    }

    String formatDurationIso(String start, String end) {
        if (start == null || start.isEmpty() || end == null || end.isEmpty()) return null
        Integer s = parseIsoToSeconds(start)
        if (s == null) return null
        Integer e = parseIsoToSeconds(end)
        if (e == null) return null
        int total = Math.abs(e - s)
        return formatDurationSecondsInternal(total)
    }

    String formatSince(String start, String asOf) {
        if (start == null || start.isEmpty() || asOf == null || asOf.isEmpty()) return null
        Integer s = parseIsoToSeconds(start)
        if (s == null) return null
        Integer a = parseIsoToSeconds(asOf)
        if (a == null) return null
        int diff = a - s
        if (diff < 0) return null
        if (diff == 0) return justNow
        String dur = formatDurationSecondsInternal(diff)
        return ago.replace('{0}', dur)
    }

    String formatUntil(String target, String asOf) {
        if (target == null || target.isEmpty() || asOf == null || asOf.isEmpty()) return null
        Integer t = parseIsoToSeconds(target)
        if (t == null) return null
        Integer a = parseIsoToSeconds(asOf)
        if (a == null) return null
        int diff = t - a
        if (diff < 0) return null
        if (diff == 0) return justNow
        String dur = formatDurationSecondsInternal(diff)
        return inFuture.replace('{0}', dur)
    }

    private String formatDurationSecondsInternal(int total) {
        // 0 seconds
        if (total == 0) return justNow

        // 1-59 seconds
        if (total < 60) return resolveUnit(total, second, locale, '')

        int totalMinutes = total.intdiv(60)
        int remainderSeconds = total % 60

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

        int totalHours = total.intdiv(3600)
        int remainderMinutes = (total % 3600).intdiv(60)

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

        int totalDays = total.intdiv(86400)
        int remainderHours = (total % 86400).intdiv(3600)

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

        int totalWeeks = totalDays.intdiv(7)
        int remainderDays = totalDays % 7

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30) {
            String result = resolveUnit(totalWeeks, week, locale, '')
            if (remainderDays > 0) {
                result += delimiter + resolveUnit(remainderDays, day, locale, '')
            }
            return result
        }

        // Approximate months (30.44 days average)
        int totalMonths = Math.round(totalDays / 30.44d) as int

        // 1-11 months
        if (totalMonths < 12) {
            if (totalMonths == 0) totalMonths = 1
            return resolveUnit(totalMonths, month, locale, '')
        }

        // 12+ months: years + months
        int totalYears = totalMonths.intdiv(12)
        int remainderMonths = totalMonths % 12
        String result = resolveUnit(totalYears, year, locale, '')
        if (remainderMonths > 0) {
            result += delimiter + resolveUnit(remainderMonths, month, locale, '')
        }
        return result
    }

    private static String resolveUnit(int count, UnitForms uf, DurationLocale loc, String half) {
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

    static String formatDurationSecondsDefault(int seconds) {
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

    private static Integer parseIsoToSeconds(String iso) {
        if (iso == null || iso.isEmpty()) return null

        int tIdx = iso.indexOf('T')
        if (tIdx < 0) return null

        String datePart = iso.substring(0, tIdx)
        String timePart = iso.substring(tIdx + 1)

        // Parse date: YYYY-MM-DD
        String[] dp = datePart.split('-')
        if (dp.length < 3) return null
        Integer yearVal = safeAtoi(dp[0])
        Integer monthVal = safeAtoi(dp[1])
        Integer dayVal = safeAtoi(dp[2])
        if (yearVal == null || monthVal == null || dayVal == null) return null

        // Strip timezone info
        int plusIdx = timePart.indexOf('+')
        if (plusIdx >= 0) timePart = timePart.substring(0, plusIdx)
        int zIdx = timePart.indexOf('Z')
        if (zIdx >= 0) timePart = timePart.substring(0, zIdx)

        // Parse time: HH:MM:SS
        String[] tp = timePart.split(':')
        Integer hourVal = safeAtoi(tp[0])
        if (hourVal == null) return null
        Integer minuteVal = tp.length > 1 ? safeAtoi(tp[1]) : 0
        if (minuteVal == null) return null
        Integer secondVal
        if (tp.length > 2) {
            String secStr = tp[2].split('\\.')[0]
            secondVal = safeAtoi(secStr)
        } else {
            secondVal = 0
        }
        if (secondVal == null) return null

        int days = daysSinceEpoch(yearVal, monthVal, dayVal)
        return days * 86400 + hourVal * 3600 + minuteVal * 60 + secondVal
    }

    private static Integer safeAtoi(String s) {
        if (s == null || s.isEmpty()) return null
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

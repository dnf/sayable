package sayabletime

import java.time.YearMonth
import java.util.regex.Matcher
import java.util.regex.Pattern

import sayabletime.locales.Locales

class SayableTime {

    static final String VERSION = '0.5.0'

    private final TimeLocale locale
    private final ShortClockConfig shortClock

    SayableTime(TimeLocale locale, Compactness compactness = Compactness.NORMAL) {
        this.locale = locale

        CompactnessOverride ovr = null
        switch (compactness) {
            case Compactness.SHORT:
                ovr = locale.shortOverride
                break
            case Compactness.COMPACT:
                ovr = locale.compactOverride
                break
        }

        this.shortClock = ovr?.clock
    }

    String formatTime(String input) {
        if (input == null || input.isEmpty()) return null
        int[] parsed = parseTime(input)
        if (parsed == null) return null
        int hour = parsed[0]
        int minute = parsed[1]

        if (shortClock != null) {
            return formatDigital(hour, minute)
        }
        return formatNatural(hour, minute)
    }

    private String formatNatural(int hour, int minute) {
        ClockConfig clock = locale.clock
        int rounded = roundTo5(minute)
        int h = hour
        if (rounded == 60) {
            rounded = 0
            h = (h + 1) % 24
        }
        if (rounded == 0) {
            if (h == 0) return clock.midnight
            if (h == 12) return clock.noon
        }
        int h12 = h % 12
        int nextH12 = (h + 1) % 12
        String hName = clock.hours[h12]
        String nextHName = clock.hours[nextH12]
        String pattern = clock.patterns.containsKey(rounded) ? clock.patterns[rounded] : (clock.patterns.containsKey(0) ? clock.patterns[0] : '{h}')
        return pattern.replace('{h}', hName).replace('{next_h}', nextHName)
    }

    private String formatDigital(int hour, int minute) {
        String fmt = shortClock.format
        if (shortClock.use24h) {
            return fmt.replace('{h}', Integer.toString(hour)).replace('{mm}', String.format('%02d', minute))
        }
        int h12 = hour % 12
        if (h12 == 0) h12 = 12
        String[] amPm = shortClock.amPm != null ? shortClock.amPm : (['AM', 'PM'] as String[])
        String ampmStr = hour < 12 ? amPm[0] : amPm[1]
        return fmt.replace('{h}', Integer.toString(h12)).replace('{mm}', String.format('%02d', minute)).replace('{ampm}', ampmStr)
    }

    // --- Static convenience methods using English default ---

    private static final SayableTime DEFAULT = new SayableTime(Locales.EN)

    static String formatTimeDefault(String input) {
        DEFAULT.formatTime(input)
    }

    // --- Internal helpers ---

    /** H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored). */
    private static final Pattern CLOCK = ~/([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?/
    private static final Pattern DATE = ~/([0-9]{4})-([0-9]{2})-([0-9]{2})/

    private static int[] parseTime(String input) {
        if (input == null || input.isEmpty()) return null
        String clock = input
        int tIdx = input.indexOf('T')
        if (tIdx >= 0) {
            if (!isRealDate(input.substring(0, tIdx))) return null
            clock = input.substring(tIdx + 1)
        }
        Matcher m = CLOCK.matcher(clock)
        if (!m.matches()) return null
        int hour = m.group(1) as int
        int minute = m.group(2) as int
        int second = m.group(3) == null ? 0 : m.group(3) as int
        if (hour > 23 || minute > 59 || second > 59) return null
        return [hour, minute] as int[]
    }

    private static boolean isRealDate(String s) {
        Matcher m = DATE.matcher(s)
        if (!m.matches()) return false
        int month = m.group(2) as int
        int day = m.group(3) as int
        return month >= 1 && month <= 12 && day >= 1 &&
            day <= YearMonth.of(m.group(1) as int, month).lengthOfMonth()
    }

    private static int roundTo5(int minute) {
        return ((minute + 2).intdiv(5)) * 5
    }
}

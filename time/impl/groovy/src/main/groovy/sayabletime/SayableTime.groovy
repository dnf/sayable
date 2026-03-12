package sayabletime

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

    private static int[] parseTime(String input) {
        if (input == null || input.isEmpty()) return null
        String t = input
        int tIdx = t.indexOf('T')
        if (tIdx >= 0) t = t.substring(tIdx + 1)
        int plusIdx = t.indexOf('+')
        if (plusIdx >= 0) t = t.substring(0, plusIdx)
        int zIdx = t.indexOf('Z')
        if (zIdx >= 0) t = t.substring(0, zIdx)
        String[] parts = t.split(':')
        if (parts.length < 2) return null
        int hour = safeAtoi(parts[0])
        int minute = safeAtoi(parts[1])
        if (hour < 0 || minute < 0) return null
        if (hour > 23 || minute > 59) return null
        return [hour, minute] as int[]
    }

    private static int roundTo5(int minute) {
        return ((minute + 2).intdiv(5)) * 5
    }

    private static int safeAtoi(String s) {
        if (s == null || s.isEmpty()) return -1
        int n = 0
        char zero = '0' as char
        char nine = '9' as char
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i)
            if (c < zero || c > nine) return -1
            n = n * 10 + (c - zero)
        }
        return n
    }
}

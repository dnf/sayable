package sayabletime;

import sayabletime.locales.Locales;

public final class SayableTime {

    public static final String VERSION = "0.1.0";

    private final TimeLocale locale;
    private final ShortClockConfig shortClock;

    public SayableTime(TimeLocale locale) {
        this(locale, Compactness.NORMAL);
    }

    public SayableTime(TimeLocale locale, Compactness compactness) {
        this.locale = locale;

        CompactnessOverride ovr = switch (compactness) {
            case SHORT -> locale.shortOverride();
            case COMPACT -> locale.compactOverride();
            case NORMAL -> null;
        };

        this.shortClock = ovr != null ? ovr.clock() : null;
    }

    public String formatTime(String input) {
        if (input == null || input.isEmpty()) return null;
        int[] parsed = parseTime(input);
        if (parsed == null) return null;
        int hour = parsed[0];
        int minute = parsed[1];

        if (shortClock != null) {
            return formatDigital(hour, minute);
        }
        return formatNatural(hour, minute);
    }

    private String formatNatural(int hour, int minute) {
        ClockConfig clock = locale.clock();
        int rounded = roundTo5(minute);
        int h = hour;
        if (rounded == 60) {
            rounded = 0;
            h = (h + 1) % 24;
        }
        if (rounded == 0) {
            if (h == 0) return clock.midnight();
            if (h == 12) return clock.noon();
        }
        int h12 = h % 12;
        int nextH12 = (h + 1) % 12;
        String hName = clock.hours().get(h12);
        String nextHName = clock.hours().get(nextH12);
        String pattern = clock.patterns().getOrDefault(rounded, clock.patterns().getOrDefault(0, "{h}"));
        return pattern.replace("{h}", hName).replace("{next_h}", nextHName);
    }

    private String formatDigital(int hour, int minute) {
        String fmt = shortClock.format();
        if (shortClock.use24h()) {
            return fmt
                .replace("{h}", Integer.toString(hour))
                .replace("{mm}", String.format("%02d", minute));
        }
        int h12 = hour % 12;
        if (h12 == 0) h12 = 12;
        String[] amPm = shortClock.amPm();
        if (amPm == null) amPm = new String[]{"AM", "PM"};
        String ampmStr = hour < 12 ? amPm[0] : amPm[1];
        return fmt
            .replace("{h}", Integer.toString(h12))
            .replace("{mm}", String.format("%02d", minute))
            .replace("{ampm}", ampmStr);
    }

    // Static convenience methods using default English locale
    private static final SayableTime DEFAULT = new SayableTime(Locales.EN);

    public static String formatTimeDefault(String input) {
        return DEFAULT.formatTime(input);
    }

    static int[] parseTime(String input) {
        if (input == null || input.isEmpty()) return null;
        String t = input;
        int tIdx = t.indexOf('T');
        if (tIdx >= 0) t = t.substring(tIdx + 1);
        int plusIdx = t.indexOf('+');
        if (plusIdx >= 0) t = t.substring(0, plusIdx);
        int zIdx = t.indexOf('Z');
        if (zIdx >= 0) t = t.substring(0, zIdx);
        String[] parts = t.split(":");
        if (parts.length < 2) return null;
        int hour = safeAtoi(parts[0]);
        int minute = safeAtoi(parts[1]);
        if (hour < 0 || minute < 0) return null;
        if (hour > 23 || minute > 59) return null;
        return new int[]{hour, minute};
    }

    static int roundTo5(int minute) {
        return (minute + 2) / 5 * 5;
    }

    private static int safeAtoi(String s) {
        if (s == null || s.isEmpty()) return -1;
        int n = 0;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c < '0' || c > '9') return -1;
            n = n * 10 + (c - '0');
        }
        return n;
    }
}

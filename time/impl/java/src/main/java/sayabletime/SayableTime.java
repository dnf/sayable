package sayabletime;

import java.time.YearMonth;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import sayabletime.locales.Locales;

public final class SayableTime {

    public static final String VERSION = "0.5.0";

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

    /** H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored). */
    private static final Pattern CLOCK = Pattern.compile(
        "([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?");
    private static final Pattern DATE = Pattern.compile("([0-9]{4})-([0-9]{2})-([0-9]{2})");

    static int[] parseTime(String input) {
        if (input == null || input.isEmpty()) return null;
        String clock = input;
        int tIdx = input.indexOf('T');
        if (tIdx >= 0) {
            if (!isRealDate(input.substring(0, tIdx))) return null;
            clock = input.substring(tIdx + 1);
        }
        Matcher m = CLOCK.matcher(clock);
        if (!m.matches()) return null;
        int hour = Integer.parseInt(m.group(1));
        int minute = Integer.parseInt(m.group(2));
        int second = m.group(3) == null ? 0 : Integer.parseInt(m.group(3));
        if (hour > 23 || minute > 59 || second > 59) return null;
        return new int[]{hour, minute};
    }

    private static boolean isRealDate(String s) {
        Matcher m = DATE.matcher(s);
        if (!m.matches()) return false;
        int month = Integer.parseInt(m.group(2));
        int day = Integer.parseInt(m.group(3));
        return month >= 1 && month <= 12 && day >= 1
            && day <= YearMonth.of(Integer.parseInt(m.group(1)), month).lengthOfMonth();
    }

    static int roundTo5(int minute) {
        return (minute + 2) / 5 * 5;
    }

}

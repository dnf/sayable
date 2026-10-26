package sayabledate;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import sayabledate.locales.Locales;

public final class SayableDate {

    public static final String VERSION = "0.5.0";

    private final Compactness compactness;
    private final DateLocale locale;
    private final List<String> months;
    private final List<String> monthsInDate;
    private final List<String> weekdays;
    private final String dayFormat;
    private final Map<String, String> dayFormatExceptions;
    private final String datePattern;
    private final String datePatternWithYear;
    private final String todayStr;
    private final String tomorrowStr;
    private final String yesterdayStr;

    public SayableDate(DateLocale locale) {
        this(locale, Compactness.NORMAL);
    }

    public SayableDate(DateLocale locale, Compactness compactness) {
        this.locale = locale;
        this.compactness = compactness;

        CompactnessOverride ovr = switch (compactness) {
            case SHORT -> locale.shortOverride();
            case COMPACT -> locale.compactOverride();
            case NORMAL -> null;
        };

        this.months = ovr != null && ovr.months() != null ? ovr.months() : locale.months();
        this.monthsInDate = ovr != null && ovr.monthsInDate() != null ? ovr.monthsInDate() : locale.monthsInDate();
        this.weekdays = ovr != null && ovr.weekdays() != null ? ovr.weekdays() : locale.weekdays();

        // When override provides dayFormat but not dayFormatExceptions, clear exceptions
        if (ovr != null && ovr.dayFormat() != null && ovr.dayFormatExceptions() == null) {
            this.dayFormat = ovr.dayFormat();
            this.dayFormatExceptions = Collections.emptyMap();
        } else {
            this.dayFormat = ovr != null && ovr.dayFormat() != null ? ovr.dayFormat() : locale.dayFormat();
            this.dayFormatExceptions = ovr != null && ovr.dayFormatExceptions() != null
                ? ovr.dayFormatExceptions() : locale.dayFormatExceptions();
        }

        this.datePattern = ovr != null && ovr.datePattern() != null ? ovr.datePattern() : locale.datePattern();
        this.datePatternWithYear = ovr != null && ovr.datePatternWithYear() != null
            ? ovr.datePatternWithYear() : locale.datePatternWithYear();
        this.todayStr = ovr != null && ovr.today() != null ? ovr.today() : locale.today();
        this.tomorrowStr = ovr != null && ovr.tomorrow() != null ? ovr.tomorrow() : locale.tomorrow();
        this.yesterdayStr = ovr != null && ovr.yesterday() != null ? ovr.yesterday() : locale.yesterday();
    }

    public String formatDate(String date) {
        if (date == null || date.isEmpty()) return null;
        int[] parsed = parseDate(date);
        if (parsed == null) return null;
        return formatAbsolute(parsed[0], parsed[1], parsed[2], false);
    }

    public String formatDateWithYear(String date) {
        if (date == null || date.isEmpty()) return null;
        int[] parsed = parseDate(date);
        if (parsed == null) return null;
        return formatAbsolute(parsed[0], parsed[1], parsed[2], true);
    }

    @SuppressWarnings("MethodLength")
    public String formatRelative(String date, String asOf) {
        if (date == null || date.isEmpty() || asOf == null || asOf.isEmpty()) return null;
        int[] parsedDate = parseDate(date);
        int[] parsedAsOf = parseDate(asOf);
        if (parsedDate == null || parsedAsOf == null) return null;

        int dy = parsedDate[0];
        int dm = parsedDate[1];
        int dd = parsedDate[2];
        int ay = parsedAsOf[0];

        int dateJdn = toJdn(dy, dm, dd);
        int asofJdn = toJdn(parsedAsOf[0], parsedAsOf[1], parsedAsOf[2]);
        int diff = dateJdn - asofJdn;

        // Today
        if (diff == 0) return todayStr;

        // Tomorrow
        if (diff == 1) return tomorrowStr;

        // Yesterday
        if (diff == -1) return yesterdayStr;

        boolean isCompact = compactness == Compactness.COMPACT;

        // Day after tomorrow (optional, skipped in compact mode)
        if (diff == 2 && locale.dayAfterTomorrow() != null && !isCompact) {
            return locale.dayAfterTomorrow();
        }

        // Day before yesterday (optional, skipped in compact mode)
        if (diff == -2 && locale.dayBeforeYesterday() != null && !isCompact) {
            return locale.dayBeforeYesterday();
        }

        // Compact mode: skip weekday references, go straight to calendar date
        if (isCompact) {
            return formatAbsolute(dy, dm, dd, dy != ay);
        }

        // This weekday (+2 to +6)
        String thisWd = locale.thisWeekday();
        if (diff >= 2 && diff <= 6 && thisWd != null) {
            int dow = weekday(dy, dm, dd);
            String wdName = weekdays.get(dow);
            return thisWd.replace("{weekday}", wdName);
        }

        // Last weekday (-6 to -2)
        String lastWd = locale.lastWeekday();
        if (diff >= -6 && diff <= -2 && lastWd != null) {
            int dow = weekday(dy, dm, dd);
            String wdName = weekdays.get(dow);
            return lastWd.replace("{weekday}", wdName);
        }

        // Next weekday (+7 to +13)
        String nextWd = locale.nextWeekday();
        if (diff >= 7 && diff <= 13 && nextWd != null) {
            int dow = weekday(dy, dm, dd);
            String wdName = weekdays.get(dow);
            return nextWd.replace("{weekday}", wdName);
        }

        // Calendar fallback
        return formatAbsolute(dy, dm, dd, dy != ay);
    }

    private String formatAbsolute(int year, int month, int day, boolean includeYear) {
        String dayStr = Integer.toString(day);
        String fmt = dayFormatExceptions.getOrDefault(dayStr, dayFormat);
        String formattedDay = fmt.replace("{n}", dayStr);

        // Pick month name (genitive form if available)
        List<String> monthNames = monthsInDate != null ? monthsInDate : months;
        String monthName = monthNames.get(month - 1);

        String pattern = includeYear ? datePatternWithYear : datePattern;
        String result = pattern.replace("{month}", monthName);
        result = result.replace("{day}", formattedDay);
        result = result.replace("{d}", Integer.toString(day));
        result = result.replace("{m}", Integer.toString(month));
        if (includeYear) {
            result = result.replace("{year}", Integer.toString(year));
            int yy = year % 100;
            result = result.replace("{yy}", String.format("%02d", yy));
        }

        return result;
    }

    // Static convenience methods using default English locale
    private static final SayableDate DEFAULT = new SayableDate(Locales.EN);

    public static String formatDateDefault(String date) {
        return DEFAULT.formatDate(date);
    }

    public static String formatRelativeDefault(String date, String asOf) {
        return DEFAULT.formatRelative(date, asOf);
    }

    static int[] parseDate(String s) {
        if (s == null || !hasDateShape(s)) return null;
        int year = safeAtoi(s, 0, 4);
        int month = safeAtoi(s, 5, 7);
        int day = safeAtoi(s, 8, 10);
        if (year < 0 || month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) return null;
        return new int[]{year, month, day};
    }

    /** Exactly YYYY-MM-DD, or that followed by T and anything (an ISO datetime). */
    private static boolean hasDateShape(String s) {
        boolean dateAlone = s.length() == 10;
        boolean datetime = s.length() > 10 && s.charAt(10) == 'T';
        return (dateAlone || datetime) && s.charAt(4) == '-' && s.charAt(7) == '-';
    }

    private static int daysInMonth(int year, int month) {
        if (month == 2) return isLeapYear(year) ? 29 : 28;
        return month == 4 || month == 6 || month == 9 || month == 11 ? 30 : 31;
    }

    private static boolean isLeapYear(int year) {
        return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
    }

    private static int safeAtoi(String s, int from, int to) {
        int n = 0;
        for (int i = from; i < to; i++) {
            char c = s.charAt(i);
            if (c < '0' || c > '9') return -1;
            n = n * 10 + (c - '0');
        }
        return n;
    }

    static int toJdn(int year, int month, int day) {
        int a = (14 - month) / 12;
        int y = year + 4800 - a;
        int m = month + 12 * a - 3;
        return day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045;
    }

    static int weekday(int year, int month, int day) {
        return (toJdn(year, month, day) + 1) % 7;
    }
}

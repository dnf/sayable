package sayableduration;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import sayableduration.locales.Locales;

public final class SayableDuration {

    public static final String VERSION = "0.5.0";

    /** 500 years, the same ceiling as sayable-age. */
    private static final int MAX_DURATION_MONTHS = 6000;

    /** YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored). */
    private static final Pattern TIMESTAMP = Pattern.compile(
        "([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})"
        + "(?::([0-9]{2})(?:\\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?");

    private final DurationLocale locale;
    private final UnitForms second;
    private final UnitForms minute;
    private final UnitForms hour;
    private final UnitForms day;
    private final UnitForms week;
    private final UnitForms month;
    private final UnitForms year;
    private final String half;
    private final String delimiter;
    private final String justNow;
    private final String ago;
    private final String inFuture;

    public SayableDuration(DurationLocale locale) {
        this(locale, Compactness.NORMAL);
    }

    public SayableDuration(DurationLocale locale, Compactness compactness) {
        this.locale = locale;

        UnitForms s = locale.units().second();
        UnitForms min = locale.units().minute();
        UnitForms h = locale.units().hour();
        UnitForms d = locale.units().day();
        UnitForms w = locale.units().week();
        UnitForms mo = locale.units().month();
        UnitForms y = locale.units().year();
        String hf = locale.half();
        String del = locale.delimiter();
        String jn = locale.justNow();
        String ag = locale.ago();
        String inf = locale.inFuture();

        CompactnessOverride ovr = switch (compactness) {
            case SHORT -> locale.shortOverride();
            case COMPACT -> locale.compactOverride();
            case NORMAL -> null;
        };

        if (ovr != null) {
            if (ovr.second() != null) s = ovr.second();
            if (ovr.minute() != null) min = ovr.minute();
            if (ovr.hour() != null) h = ovr.hour();
            if (ovr.day() != null) d = ovr.day();
            if (ovr.week() != null) w = ovr.week();
            if (ovr.month() != null) mo = ovr.month();
            if (ovr.year() != null) y = ovr.year();
            if (ovr.half() != null) hf = ovr.half();
            if (ovr.delimiter() != null) del = ovr.delimiter();
            if (ovr.ago() != null) ag = ovr.ago();
            if (ovr.inFuture() != null) inf = ovr.inFuture();
        }

        this.second = s;
        this.minute = min;
        this.hour = h;
        this.day = d;
        this.week = w;
        this.month = mo;
        this.year = y;
        this.half = hf;
        this.delimiter = del;
        this.justNow = jn;
        this.ago = ag;
        this.inFuture = inf;
    }

    public String formatDurationSeconds(long seconds) {
        if (seconds < 0) return null;
        return formatDurationSecondsInternal(seconds);
    }

    public String formatDurationIso(String start, String end) {
        if (start == null || start.isEmpty() || end == null || end.isEmpty()) return null;
        Long s = parseIsoToSeconds(start);
        if (s == null) return null;
        Long e = parseIsoToSeconds(end);
        if (e == null) return null;
        long total = Math.abs(e - s);
        return formatDurationSecondsInternal(total);
    }

    public String formatSince(String start, String asOf) {
        if (start == null || start.isEmpty() || asOf == null || asOf.isEmpty()) return null;
        Long s = parseIsoToSeconds(start);
        if (s == null) return null;
        Long a = parseIsoToSeconds(asOf);
        if (a == null) return null;
        long diff = a - s;
        if (diff < 0) return null;
        if (diff == 0) return justNow;
        String dur = formatDurationSecondsInternal(diff);
        return dur == null ? null : ago.replace("{0}", dur);
    }

    public String formatUntil(String target, String asOf) {
        if (target == null || target.isEmpty() || asOf == null || asOf.isEmpty()) return null;
        Long t = parseIsoToSeconds(target);
        if (t == null) return null;
        Long a = parseIsoToSeconds(asOf);
        if (a == null) return null;
        long diff = t - a;
        if (diff < 0) return null;
        if (diff == 0) return justNow;
        String dur = formatDurationSecondsInternal(diff);
        return dur == null ? null : inFuture.replace("{0}", dur);
    }

    @SuppressWarnings("MethodLength")
    private String formatDurationSecondsInternal(long total) {
        // 0 seconds
        if (total == 0) return justNow;

        // 1-59 seconds
        if (total < 60) return resolveUnit(total, second, locale, "");

        long totalMinutes = total / 60;
        long remainderSeconds = total % 60;

        // 1-4 minutes: minutes + seconds
        if (totalMinutes < 5) {
            String result = resolveUnit(totalMinutes, minute, locale, "");
            if (remainderSeconds > 0) {
                result += delimiter + resolveUnit(remainderSeconds, second, locale, "");
            }
            return result;
        }

        // 5-59 minutes
        if (totalMinutes < 60) return resolveUnit(totalMinutes, minute, locale, "");

        long totalHours = total / 3600;
        long remainderMinutes = (total % 3600) / 60;

        // 1-5 hours: hours + minutes (with half marker)
        if (totalHours <= 5) {
            if (remainderMinutes == 30) {
                return resolveUnit(totalHours, hour, locale, half);
            }
            String result = resolveUnit(totalHours, hour, locale, "");
            if (remainderMinutes > 0) {
                result += delimiter + resolveUnit(remainderMinutes, minute, locale, "");
            }
            return result;
        }

        // 6-23 hours
        if (totalHours < 24) return resolveUnit(totalHours, hour, locale, "");

        long totalDays = total / 86400;
        long remainderHours = (total % 86400) / 3600;

        // 1-2 days: days + hours (with half marker)
        if (totalDays <= 2) {
            if (remainderHours == 12) {
                return resolveUnit(totalDays, day, locale, half);
            }
            String result = resolveUnit(totalDays, day, locale, "");
            if (remainderHours > 0) {
                result += delimiter + resolveUnit(remainderHours, hour, locale, "");
            }
            return result;
        }

        // 3-6 days
        if (totalDays < 7) return resolveUnit(totalDays, day, locale, "");

        long totalWeeks = totalDays / 7;
        long remainderDays = totalDays % 7;

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30) {
            String result = resolveUnit(totalWeeks, week, locale, "");
            if (remainderDays > 0) {
                result += delimiter + resolveUnit(remainderDays, day, locale, "");
            }
            return result;
        }

        // Approximate months (30.44 days average)
        long totalMonths = Math.round(totalDays / 30.44);
        if (totalMonths > MAX_DURATION_MONTHS) return null;

        // 1-11 months
        if (totalMonths < 12) {
            if (totalMonths == 0) totalMonths = 1;
            return resolveUnit(totalMonths, month, locale, "");
        }

        // 12+ months: years + months
        long totalYears = totalMonths / 12;
        long remainderMonths = totalMonths % 12;
        String result = resolveUnit(totalYears, year, locale, "");
        if (remainderMonths > 0) {
            result += delimiter + resolveUnit(remainderMonths, month, locale, "");
        }
        return result;
    }

    /** Counts are bounded by the 500-year ceiling, so they always fit in an int. */
    static String resolveUnit(long boundedCount, UnitForms uf, DurationLocale loc, String half) {
        int count = Math.toIntExact(boundedCount);
        String baseN;
        if (loc.formatNumber() != null) {
            baseN = loc.formatNumber().apply(count);
        } else {
            baseN = Integer.toString(count);
        }

        String n;
        if (!half.isEmpty() && half.contains("{n}")) {
            n = half.replace("{n}", baseN);
        } else {
            n = baseN;
        }

        String template;
        if (uf.simple() != null) {
            template = uf.simple();
        } else {
            // Half-marked values use OTHER plural (e.g. "1 1/2 hours" not "1 1/2 hour")
            PluralCategory cat = half.isEmpty() ? loc.plural().apply(count) : PluralCategory.OTHER;
            String form = uf.forms().get(cat);
            if (form == null) form = uf.forms().get(PluralCategory.OTHER);
            template = form != null ? form : "{n}";
        }

        String result = template.replace("{n}", n);

        if (loc.formatUnit() != null) {
            result = loc.formatUnit().apply(count, result);
        }

        // Apply {0}-style half marker (wraps the whole expression)
        if (!half.isEmpty() && half.contains("{0}")) {
            result = half.replace("{0}", result);
        }

        return result;
    }

    // Static convenience methods using default English locale
    private static final SayableDuration DEFAULT = new SayableDuration(Locales.EN);

    public static String formatDurationSecondsDefault(long seconds) {
        return DEFAULT.formatDurationSeconds(seconds);
    }

    public static String formatDurationIsoDefault(String start, String end) {
        return DEFAULT.formatDurationIso(start, end);
    }

    public static String formatSinceDefault(String start, String asOf) {
        return DEFAULT.formatSince(start, asOf);
    }

    public static String formatUntilDefault(String target, String asOf) {
        return DEFAULT.formatUntil(target, asOf);
    }

    static Long parseIsoToSeconds(String iso) {
        if (iso == null) return null;
        Matcher m = TIMESTAMP.matcher(iso);
        if (!m.matches()) return null;
        int year = Integer.parseInt(m.group(1));
        int month = Integer.parseInt(m.group(2));
        int day = Integer.parseInt(m.group(3));
        int hour = Integer.parseInt(m.group(4));
        int minute = Integer.parseInt(m.group(5));
        int second = m.group(6) == null ? 0 : Integer.parseInt(m.group(6));
        if (month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) return null;
        if (hour > 23 || minute > 59 || second > 59) return null;
        long days = daysSinceEpoch(year, month, day);
        return days * 86400 + hour * 3600 + minute * 60 + second;
    }

    static boolean isLeapYear(int year) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }

    static int daysInMonth(int year, int month) {
        return switch (month) {
            case 1, 3, 5, 7, 8, 10, 12 -> 31;
            case 4, 6, 9, 11 -> 30;
            case 2 -> isLeapYear(year) ? 29 : 28;
            default -> 30;
        };
    }

    static int daysSinceEpoch(int year, int month, int day) {
        int days = 0;
        if (year >= 2000) {
            for (int y = 2000; y < year; y++) {
                days += isLeapYear(y) ? 366 : 365;
            }
        } else {
            for (int y = year; y < 2000; y++) {
                days -= isLeapYear(y) ? 366 : 365;
            }
        }
        for (int m = 1; m < month; m++) {
            days += daysInMonth(year, m);
        }
        days += day - 1;
        return days;
    }
}

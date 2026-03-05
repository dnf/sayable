package sayableduration;

import sayableduration.locales.Locales;

public final class SayableDuration {

    public static final String VERSION = "0.5.0";

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

    public String formatDurationSeconds(int seconds) {
        if (seconds < 0) return null;
        return formatDurationSecondsInternal(seconds);
    }

    public String formatDurationIso(String start, String end) {
        if (start == null || start.isEmpty() || end == null || end.isEmpty()) return null;
        Integer s = parseIsoToSeconds(start);
        if (s == null) return null;
        Integer e = parseIsoToSeconds(end);
        if (e == null) return null;
        int total = Math.abs(e - s);
        return formatDurationSecondsInternal(total);
    }

    public String formatSince(String start, String asOf) {
        if (start == null || start.isEmpty() || asOf == null || asOf.isEmpty()) return null;
        Integer s = parseIsoToSeconds(start);
        if (s == null) return null;
        Integer a = parseIsoToSeconds(asOf);
        if (a == null) return null;
        int diff = a - s;
        if (diff < 0) return null;
        if (diff == 0) return justNow;
        String dur = formatDurationSecondsInternal(diff);
        return ago.replace("{0}", dur);
    }

    public String formatUntil(String target, String asOf) {
        if (target == null || target.isEmpty() || asOf == null || asOf.isEmpty()) return null;
        Integer t = parseIsoToSeconds(target);
        if (t == null) return null;
        Integer a = parseIsoToSeconds(asOf);
        if (a == null) return null;
        int diff = t - a;
        if (diff < 0) return null;
        if (diff == 0) return justNow;
        String dur = formatDurationSecondsInternal(diff);
        return inFuture.replace("{0}", dur);
    }

    @SuppressWarnings("MethodLength")
    private String formatDurationSecondsInternal(int total) {
        // 0 seconds
        if (total == 0) return justNow;

        // 1-59 seconds
        if (total < 60) return resolveUnit(total, second, locale, "");

        int totalMinutes = total / 60;
        int remainderSeconds = total % 60;

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

        int totalHours = total / 3600;
        int remainderMinutes = (total % 3600) / 60;

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

        int totalDays = total / 86400;
        int remainderHours = (total % 86400) / 3600;

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

        int totalWeeks = totalDays / 7;
        int remainderDays = totalDays % 7;

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30) {
            String result = resolveUnit(totalWeeks, week, locale, "");
            if (remainderDays > 0) {
                result += delimiter + resolveUnit(remainderDays, day, locale, "");
            }
            return result;
        }

        // Approximate months (30.44 days average)
        int totalMonths = (int) Math.round(totalDays / 30.44);

        // 1-11 months
        if (totalMonths < 12) {
            if (totalMonths == 0) totalMonths = 1;
            return resolveUnit(totalMonths, month, locale, "");
        }

        // 12+ months: years + months
        int totalYears = totalMonths / 12;
        int remainderMonths = totalMonths % 12;
        String result = resolveUnit(totalYears, year, locale, "");
        if (remainderMonths > 0) {
            result += delimiter + resolveUnit(remainderMonths, month, locale, "");
        }
        return result;
    }

    static String resolveUnit(int count, UnitForms uf, DurationLocale loc, String half) {
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

    public static String formatDurationSecondsDefault(int seconds) {
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

    static Integer parseIsoToSeconds(String iso) {
        if (iso == null || iso.isEmpty()) return null;

        int tIdx = iso.indexOf('T');
        if (tIdx < 0) return null;

        String datePart = iso.substring(0, tIdx);
        String timePart = iso.substring(tIdx + 1);

        // Parse date: YYYY-MM-DD
        String[] dp = datePart.split("-");
        if (dp.length < 3) return null;
        int year = safeAtoi(dp[0]);
        int month = safeAtoi(dp[1]);
        int day = safeAtoi(dp[2]);
        if (year < 0 || month < 0 || day < 0) return null;

        // Strip timezone info
        int plusIdx = timePart.indexOf('+');
        if (plusIdx >= 0) timePart = timePart.substring(0, plusIdx);
        int zIdx = timePart.indexOf('Z');
        if (zIdx >= 0) timePart = timePart.substring(0, zIdx);

        // Parse time: HH:MM:SS
        String[] tp = timePart.split(":");
        int hour = safeAtoi(tp[0]);
        if (hour < 0) return null;
        int minute = tp.length > 1 ? safeAtoi(tp[1]) : 0;
        if (minute < 0) return null;
        int second;
        if (tp.length > 2) {
            String secStr = tp[2].split("\\.")[0];
            second = safeAtoi(secStr);
        } else {
            second = 0;
        }
        if (second < 0) return null;

        int days = daysSinceEpoch(year, month, day);
        return days * 86400 + hour * 3600 + minute * 60 + second;
    }

    static int safeAtoi(String s) {
        if (s == null || s.isEmpty()) return -1;
        int n = 0;
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c < '0' || c > '9') return -1;
            n = n * 10 + (c - '0');
        }
        return n;
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

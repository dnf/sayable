package sayableage;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.function.Supplier;

import sayableage.locales.Locales;

public final class SayableAge {

    public static final String VERSION = "0.5.0";

    private static final int MAX_AGE_MONTHS = 6000;

    private final AgeLocale locale;
    private final UnitForms day;
    private final UnitForms week;
    private final UnitForms month;
    private final UnitForms year;
    private final String half;
    private final String delimiter;
    private final String justBorn;

    static Supplier<LocalDate> timeNow = LocalDate::now;

    public SayableAge(AgeLocale locale) {
        this(locale, Compactness.NORMAL);
    }

    public SayableAge(AgeLocale locale, Compactness compactness) {
        this.locale = locale;

        UnitForms d = locale.units().day();
        UnitForms w = locale.units().week();
        UnitForms m = locale.units().month();
        UnitForms y = locale.units().year();
        String h = locale.half();
        String del = locale.delimiter();
        String jb = locale.justBorn();

        CompactnessOverride ovr = switch (compactness) {
            case SHORT -> locale.shortOverride();
            case COMPACT -> locale.compactOverride();
            case NORMAL -> null;
        };

        if (ovr != null) {
            if (ovr.day() != null) d = ovr.day();
            if (ovr.week() != null) w = ovr.week();
            if (ovr.month() != null) m = ovr.month();
            if (ovr.year() != null) y = ovr.year();
            if (ovr.half() != null) h = ovr.half();
            if (ovr.delimiter() != null) del = ovr.delimiter();
            if (ovr.justBorn() != null) jb = ovr.justBorn();
        }

        this.day = d;
        this.week = w;
        this.month = m;
        this.year = y;
        this.half = h;
        this.delimiter = del;
        this.justBorn = jb;
    }

    record AgeComponents(int months, int diffDays) {}

    static AgeComponents parseAge(String dateOfBirth, String asOf) {
        if (dateOfBirth == null || dateOfBirth.isEmpty()) return null;

        int[] dobParts = parseDateParts(dateOfBirth);
        if (dobParts == null) return null;
        int dobY = dobParts[0];
        int dobM = dobParts[1];
        int dobD = dobParts[2];

        int refY;
        int refM;
        int refD;
        if (asOf != null && !asOf.isEmpty()) {
            int[] refParts = parseDateParts(asOf);
            if (refParts == null) return null;
            refY = refParts[0];
            refM = refParts[1];
            refD = refParts[2];
        } else {
            LocalDate now = timeNow.get();
            refY = now.getYear();
            refM = now.getMonthValue();
            refD = now.getDayOfMonth();
        }

        LocalDate dobDate = LocalDate.of(dobY, dobM, dobD);
        LocalDate refDate = LocalDate.of(refY, refM, refD);
        int diffDays = (int) ChronoUnit.DAYS.between(dobDate, refDate);
        if (diffDays < 0) return null;

        int lastDay = YearMonth.of(refY, refM).lengthOfMonth();
        int clampedBirthday = Math.min(dobD, lastDay);
        int months = (refY - dobY) * 12 + (refM - dobM);
        if (refD < clampedBirthday) months--;
        if (months > MAX_AGE_MONTHS) return null;

        return new AgeComponents(months, diffDays);
    }

    static int[] parseDateParts(String s) {
        if (s.length() != 10 || s.charAt(4) != '-' || s.charAt(7) != '-') return null;
        int y = safeAtoi(s, 0, 4);
        int m = safeAtoi(s, 5, 7);
        int d = safeAtoi(s, 8, 10);
        if (y < 0 || m < 1 || m > 12 || d < 1 || d > daysInMonth(y, m)) return null;
        return new int[]{y, m, d};
    }

    static int daysInMonth(int year, int month) {
        return YearMonth.of(year, month).lengthOfMonth();
    }

    static int safeAtoi(String s, int from, int to) {
        int n = 0;
        for (int i = from; i < to; i++) {
            char c = s.charAt(i);
            if (c < '0' || c > '9') return -1;
            n = n * 10 + (c - '0');
        }
        return n;
    }

    static String stageKey(int months) {
        if (months < 2) return "newborn";
        if (months < 12) return "infant";
        if (months < 36) return "toddler";
        if (months < 156) return "child";
        if (months < 216) return "teenager";
        return "adult";
    }

    static String resolveUnit(int count, UnitForms uf, AgeLocale loc, String half) {
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
            PluralCategory cat = loc.plural().apply(count);
            String form = uf.forms().get(cat);
            if (form == null) form = uf.forms().get(PluralCategory.OTHER);
            template = form != null ? form : "{n}";
        }

        String result = template.replace("{n}", n);

        if (loc.formatUnit() != null) {
            result = loc.formatUnit().apply(count, result);
        }

        if (!half.isEmpty() && half.contains("{0}")) {
            result = half.replace("{0}", result);
        }

        return result;
    }

    public String formatAge(String dateOfBirth, String asOf) {
        AgeComponents age = parseAge(dateOfBirth, asOf);
        if (age == null) return null;

        int months = age.months();
        int diffDays = age.diffDays();

        // Tier 1: 0 days
        if (diffDays == 0) return justBorn;

        // Tier 1b: 1-6 days
        if (diffDays < 7) return resolveUnit(diffDays, day, locale, "");

        // Tier 2: weeks + days until 3 calendar months
        if (months < 3) {
            int weeks = diffDays / 7;
            int days = diffDays % 7;
            String result = resolveUnit(weeks, week, locale, "");
            if (days > 0) {
                result += delimiter + resolveUnit(days, day, locale, "");
            }
            return result;
        }

        // Tier 3: 3-23 months
        if (months < 24) return resolveUnit(months, month, locale, "");

        // Tier 4: 24-35 months -> years + months
        if (months < 36) {
            int years = months / 12;
            int rem = months % 12;
            if (rem == 0) return resolveUnit(years, year, locale, "");
            return resolveUnit(years, year, locale, "") + delimiter + resolveUnit(rem, month, locale, "");
        }

        // Tier 5: 3-6 years -> years with half marker
        if (months < 84) {
            int years = months / 12;
            int rem = months % 12;
            if (rem >= 6) {
                return resolveUnit(years, year, locale, half);
            } else {
                return resolveUnit(years, year, locale, "");
            }
        }

        // Tier 6: 7+ years
        int years = months / 12;
        return resolveUnit(years, year, locale, "");
    }

    public String formatAge(String dateOfBirth) {
        return formatAge(dateOfBirth, null);
    }

    public String formatStage(String dateOfBirth, String asOf, String gender) {
        AgeComponents age = parseAge(dateOfBirth, asOf);
        if (age == null) return null;
        StageLabel label = switch (stageKey(age.months())) {
            case "newborn" -> locale.stages().newborn();
            case "infant" -> locale.stages().infant();
            case "toddler" -> locale.stages().toddler();
            case "child" -> locale.stages().child();
            case "teenager" -> locale.stages().teenager();
            case "adult" -> locale.stages().adult();
            default -> null;
        };
        if (label == null) return null;
        return label.resolve(gender);
    }

    public String formatStage(String dateOfBirth, String asOf) {
        return formatStage(dateOfBirth, asOf, null);
    }

    public String formatStage(String dateOfBirth) {
        return formatStage(dateOfBirth, null, null);
    }

    // Static convenience methods using default English locale
    private static final SayableAge DEFAULT = new SayableAge(Locales.EN);

    public static String formatAgeDefault(String dateOfBirth, String asOf) {
        return DEFAULT.formatAge(dateOfBirth, asOf);
    }

    public static String formatAgeDefault(String dateOfBirth) {
        return DEFAULT.formatAge(dateOfBirth, null);
    }

    public static String formatStageDefault(String dateOfBirth, String asOf, String gender) {
        return DEFAULT.formatStage(dateOfBirth, asOf, gender);
    }

    public static String formatStageDefault(String dateOfBirth, String asOf) {
        return DEFAULT.formatStage(dateOfBirth, asOf, null);
    }

    public static String formatStageDefault(String dateOfBirth) {
        return DEFAULT.formatStage(dateOfBirth, null, null);
    }
}

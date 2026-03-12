import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import sayableage.SayableAge;
import sayableage.AgeLocale;

import sayabledate.SayableDate;
import sayabledate.DateLocale;

import sayabletime.SayableTime;
import sayabletime.TimeLocale;

import sayableduration.SayableDuration;
import sayableduration.DurationLocale;

public final class Sayable {

    private static final String VERSION = "0.5.0";

    private static final String HELP =
        "Usage: sayable <command> [arguments] [options]\n" +
        "\n" +
        "Commands:\n" +
        "  age <dob>              Format an age\n" +
        "  stage <dob>            Get developmental stage\n" +
        "  date <date>            Format a calendar date\n" +
        "  relative <date>        Format a relative date\n" +
        "  time <time>            Format a clock time\n" +
        "  duration <value> [end] Format a duration\n" +
        "  since <start>          Format elapsed time\n" +
        "  until <target>         Format remaining time\n" +
        "  locales                List available locale codes\n" +
        "  version                Show version\n" +
        "  help                   Show this help\n" +
        "\n" +
        "Options:\n" +
        "  -l, --locale <code>    Locale code (default: en)\n" +
        "  -d, --as-of <value>    Reference date/timestamp\n" +
        "      --short            Short compactness\n" +
        "      --compact          Compact compactness\n" +
        "  -g, --gender <m|f>     Gender for stage labels\n" +
        "      --with-year        Include year (date only)\n" +
        "  -h, --help             Show this help\n" +
        "  -v, --version          Show version";

    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println(HELP);
            System.exit(2);
        }

        String first = args[0];
        if (first.equals("-h") || first.equals("--help") || first.equals("help")) {
            System.out.println(HELP);
            System.exit(0);
        }
        if (first.equals("-v") || first.equals("--version") || first.equals("version")) {
            System.out.println("sayable " + VERSION);
            System.exit(0);
        }

        String command = first;
        List<String> positionals = new ArrayList<>();
        String locale = "en";
        String asOf = null;
        String compactness = "normal";
        String gender = null;
        boolean withYear = false;

        int i = 1;
        boolean stopOpts = false;
        while (i < args.length) {
            String arg = args[i];

            if (arg.equals("--") && !stopOpts) {
                stopOpts = true;
                i++;
                continue;
            }

            if (!stopOpts && arg.startsWith("-")) {
                if (arg.equals("-l") || arg.equals("--locale")) {
                    if (i + 1 >= args.length) {
                        error("'" + arg + "' requires a value");
                    }
                    i++;
                    locale = args[i];
                } else if (arg.equals("-d") || arg.equals("--as-of")) {
                    if (i + 1 >= args.length) {
                        error("'" + arg + "' requires a value");
                    }
                    i++;
                    asOf = args[i];
                } else if (arg.equals("-g") || arg.equals("--gender")) {
                    if (i + 1 >= args.length) {
                        error("'" + arg + "' requires a value");
                    }
                    i++;
                    gender = args[i];
                } else if (arg.equals("--short")) {
                    compactness = "short";
                } else if (arg.equals("--compact")) {
                    compactness = "compact";
                } else if (arg.equals("--with-year")) {
                    withYear = true;
                } else if (arg.equals("-h") || arg.equals("--help")) {
                    System.out.println(HELP);
                    System.exit(0);
                } else if (arg.equals("-v") || arg.equals("--version")) {
                    System.out.println("sayable " + VERSION);
                    System.exit(0);
                } else {
                    error("unknown option '" + arg + "'");
                }
            } else {
                positionals.add(arg);
            }

            i++;
        }

        switch (command) {
            case "age" -> cmdAge(positionals, locale, asOf, compactness);
            case "stage" -> cmdStage(positionals, locale, asOf, compactness, gender);
            case "date" -> cmdDate(positionals, locale, compactness, withYear);
            case "relative" -> cmdRelative(positionals, locale, asOf, compactness);
            case "time" -> cmdTime(positionals, locale, compactness);
            case "duration" -> cmdDuration(positionals, locale, compactness);
            case "since" -> cmdSince(positionals, locale, asOf, compactness);
            case "until" -> cmdUntil(positionals, locale, asOf, compactness);
            case "locales" -> cmdLocales();
            default -> error("unknown command '" + command + "'");
        }
    }

    private static String nullify(String value) {
        return "null".equals(value) ? null : value;
    }

    private static void error(String msg) {
        System.err.println("error: " + msg);
        System.err.println("Run 'sayable help' for usage.");
        System.exit(2);
    }

    private static String getToday() {
        return LocalDate.now().toString();
    }

    private static sayableage.Compactness ageCompactness(String c) {
        return switch (c) {
            case "short" -> sayableage.Compactness.SHORT;
            case "compact" -> sayableage.Compactness.COMPACT;
            default -> sayableage.Compactness.NORMAL;
        };
    }

    private static sayabledate.Compactness dateCompactness(String c) {
        return switch (c) {
            case "short" -> sayabledate.Compactness.SHORT;
            case "compact" -> sayabledate.Compactness.COMPACT;
            default -> sayabledate.Compactness.NORMAL;
        };
    }

    private static sayabletime.Compactness timeCompactness(String c) {
        return switch (c) {
            case "short" -> sayabletime.Compactness.SHORT;
            case "compact" -> sayabletime.Compactness.COMPACT;
            default -> sayabletime.Compactness.NORMAL;
        };
    }

    private static sayableduration.Compactness durationCompactness(String c) {
        return switch (c) {
            case "short" -> sayableduration.Compactness.SHORT;
            case "compact" -> sayableduration.Compactness.COMPACT;
            default -> sayableduration.Compactness.NORMAL;
        };
    }

    private static void cmdAge(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            error("age requires a date-of-birth argument");
        }
        String dob = nullify(positionals.get(0));

        AgeLocale locale = sayableage.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        if (asOf != null) {
            asOf = nullify(asOf);
        } else {
            asOf = getToday();
        }

        SayableAge formatter = new SayableAge(locale, ageCompactness(compactness));
        String result = formatter.formatAge(dob, asOf);

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdStage(List<String> positionals, String localeCode, String asOf, String compactness, String gender) {
        if (positionals.isEmpty()) {
            error("stage requires a date-of-birth argument");
        }
        String dob = nullify(positionals.get(0));

        AgeLocale locale = sayableage.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        if (asOf != null) {
            asOf = nullify(asOf);
        } else {
            asOf = getToday();
        }

        SayableAge formatter = new SayableAge(locale, ageCompactness(compactness));
        String result = formatter.formatStage(dob, asOf, gender);

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdDate(List<String> positionals, String localeCode, String compactness, boolean withYear) {
        if (positionals.isEmpty()) {
            error("date requires a date argument");
        }
        String dateVal = nullify(positionals.get(0));

        DateLocale locale = sayabledate.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        SayableDate formatter = new SayableDate(locale, dateCompactness(compactness));

        String result;
        if (withYear) {
            result = formatter.formatDateWithYear(dateVal);
        } else {
            result = formatter.formatDate(dateVal);
        }

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdRelative(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            error("relative requires a date argument");
        }
        String dateVal = nullify(positionals.get(0));

        if (asOf == null) {
            error("relative requires --as-of / -d option");
        }
        asOf = nullify(asOf);

        DateLocale locale = sayabledate.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        SayableDate formatter = new SayableDate(locale, dateCompactness(compactness));
        String result = formatter.formatRelative(dateVal, asOf);

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdTime(List<String> positionals, String localeCode, String compactness) {
        if (positionals.isEmpty()) {
            error("time requires a time argument");
        }
        String timeVal = nullify(positionals.get(0));

        TimeLocale locale = sayabletime.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        SayableTime formatter = new SayableTime(locale, timeCompactness(compactness));
        String result = formatter.formatTime(timeVal);

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdDuration(List<String> positionals, String localeCode, String compactness) {
        if (positionals.isEmpty()) {
            error("duration requires a value argument");
        }
        String value = nullify(positionals.get(0));

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness));

        String result;
        if (value == null) {
            result = formatter.formatDurationSeconds(-1);
        } else if (isInteger(value)) {
            int seconds = Integer.parseInt(value);
            result = formatter.formatDurationSeconds(seconds);
        } else {
            if (positionals.size() < 2) {
                error("duration with timestamps requires start and end arguments");
            }
            String end = nullify(positionals.get(1));
            result = formatter.formatDurationIso(value, end);
        }

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdSince(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            error("since requires a start timestamp argument");
        }
        String start = nullify(positionals.get(0));

        if (asOf == null) {
            error("since requires --as-of / -d option");
        }
        asOf = nullify(asOf);

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness));
        String result = formatter.formatSince(start, asOf);

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdUntil(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            error("until requires a target timestamp argument");
        }
        String target = nullify(positionals.get(0));

        if (asOf == null) {
            error("until requires --as-of / -d option");
        }
        asOf = nullify(asOf);

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode);
        if (locale == null) {
            error("unknown locale '" + localeCode + "'");
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness));
        String result = formatter.formatUntil(target, asOf);

        if (result == null) {
            System.exit(1);
        }
        System.out.println(result);
    }

    private static void cmdLocales() {
        TreeSet<String> codes = new TreeSet<>(sayableage.locales.Locales.ALL.keySet());
        for (String code : codes) {
            System.out.println(code);
        }
    }

    private static boolean isInteger(String s) {
        if (s == null || s.isEmpty()) return false;
        int start = 0;
        if (s.charAt(0) == '-') {
            if (s.length() == 1) return false;
            start = 1;
        }
        for (int j = start; j < s.length(); j++) {
            char c = s.charAt(j);
            if (c < '0' || c > '9') return false;
        }
        return true;
    }
}

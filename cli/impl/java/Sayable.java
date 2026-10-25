import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
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

    /** What one invocation prints to stdout (null: nothing) and the code it exits with. */
    private record Outcome(int exitCode, String output) {
        static Outcome printing(String output) {
            return new Outcome(0, output);
        }

        static Outcome ofResult(String result) {
            return result == null ? new Outcome(1, null) : printing(result);
        }
    }

    /** A usage error: reported on stderr, exit code 2. */
    private static final class UsageException extends RuntimeException {
        private static final long serialVersionUID = 1L;

        UsageException(String message) {
            super(message);
        }
    }

    public static void main(String[] args) {
        if (args.length == 1 && args[0].equals("--repl")) {
            repl();
            return;
        }

        Outcome outcome = run(args);
        if (outcome.output() != null) {
            System.out.println(outcome.output());
        }
        System.exit(outcome.exitCode());
    }

    /** Answers one tab-separated request per stdin line (see cli/SPEC.md, "REPL Mode"). */
    private static void repl() {
        BufferedReader in = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8));
        try {
            String line;
            while ((line = in.readLine()) != null) {
                Outcome outcome = runCatchingCrashes(line.split("\t", -1));
                String output = outcome.output() == null ? "" : outcome.output().replace('\n', '\t');
                System.out.println(outcome.exitCode() + "\t" + output);
                System.out.flush();
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    /** A crashed one-shot run exits 1, so a crashed request answers 1 and the REPL keeps serving. */
    private static Outcome runCatchingCrashes(String[] args) {
        try {
            return run(args);
        } catch (RuntimeException e) {
            e.printStackTrace();
            return new Outcome(1, null);
        }
    }

    private static Outcome run(String[] args) {
        try {
            return dispatch(args);
        } catch (UsageException e) {
            System.err.println("error: " + e.getMessage());
            System.err.println("Run 'sayable help' for usage.");
            return new Outcome(2, null);
        }
    }

    private static Outcome dispatch(String[] args) {
        if (args.length == 0) {
            return new Outcome(2, HELP);
        }

        String first = args[0];
        if (first.equals("-h") || first.equals("--help") || first.equals("help")) {
            return Outcome.printing(HELP);
        }
        if (first.equals("-v") || first.equals("--version") || first.equals("version")) {
            return Outcome.printing("sayable " + VERSION);
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
                        throw usage("'" + arg + "' requires a value");
                    }
                    i++;
                    locale = args[i];
                } else if (arg.equals("-d") || arg.equals("--as-of")) {
                    if (i + 1 >= args.length) {
                        throw usage("'" + arg + "' requires a value");
                    }
                    i++;
                    asOf = args[i];
                } else if (arg.equals("-g") || arg.equals("--gender")) {
                    if (i + 1 >= args.length) {
                        throw usage("'" + arg + "' requires a value");
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
                    return Outcome.printing(HELP);
                } else if (arg.equals("-v") || arg.equals("--version")) {
                    return Outcome.printing("sayable " + VERSION);
                } else {
                    throw usage("unknown option '" + arg + "'");
                }
            } else {
                positionals.add(arg);
            }

            i++;
        }

        return switch (command) {
            case "age" -> Outcome.ofResult(cmdAge(positionals, locale, asOf, compactness));
            case "stage" -> Outcome.ofResult(cmdStage(positionals, locale, asOf, compactness, gender));
            case "date" -> Outcome.ofResult(cmdDate(positionals, locale, compactness, withYear));
            case "relative" -> Outcome.ofResult(cmdRelative(positionals, locale, asOf, compactness));
            case "time" -> Outcome.ofResult(cmdTime(positionals, locale, compactness));
            case "duration" -> Outcome.ofResult(cmdDuration(positionals, locale, compactness));
            case "since" -> Outcome.ofResult(cmdSince(positionals, locale, asOf, compactness));
            case "until" -> Outcome.ofResult(cmdUntil(positionals, locale, asOf, compactness));
            case "locales" -> Outcome.printing(cmdLocales());
            default -> throw usage("unknown command '" + command + "'");
        };
    }

    private static String nullify(String value) {
        return "null".equals(value) ? null : value;
    }

    private static UsageException usage(String msg) {
        return new UsageException(msg);
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

    private static String cmdAge(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage("age requires a date-of-birth argument");
        }
        String dob = nullify(positionals.get(0));

        AgeLocale locale = sayableage.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        if (asOf != null) {
            asOf = nullify(asOf);
        } else {
            asOf = getToday();
        }

        SayableAge formatter = new SayableAge(locale, ageCompactness(compactness));
        String result = formatter.formatAge(dob, asOf);

        return result;
    }

    private static String cmdStage(List<String> positionals, String localeCode, String asOf, String compactness, String gender) {
        if (positionals.isEmpty()) {
            throw usage("stage requires a date-of-birth argument");
        }
        String dob = nullify(positionals.get(0));

        AgeLocale locale = sayableage.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        if (asOf != null) {
            asOf = nullify(asOf);
        } else {
            asOf = getToday();
        }

        SayableAge formatter = new SayableAge(locale, ageCompactness(compactness));
        String result = formatter.formatStage(dob, asOf, gender);

        return result;
    }

    private static String cmdDate(List<String> positionals, String localeCode, String compactness, boolean withYear) {
        if (positionals.isEmpty()) {
            throw usage("date requires a date argument");
        }
        String dateVal = nullify(positionals.get(0));

        DateLocale locale = sayabledate.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        SayableDate formatter = new SayableDate(locale, dateCompactness(compactness));

        String result;
        if (withYear) {
            result = formatter.formatDateWithYear(dateVal);
        } else {
            result = formatter.formatDate(dateVal);
        }

        return result;
    }

    private static String cmdRelative(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage("relative requires a date argument");
        }
        String dateVal = nullify(positionals.get(0));

        if (asOf == null) {
            throw usage("relative requires --as-of / -d option");
        }
        asOf = nullify(asOf);

        DateLocale locale = sayabledate.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        SayableDate formatter = new SayableDate(locale, dateCompactness(compactness));
        String result = formatter.formatRelative(dateVal, asOf);

        return result;
    }

    private static String cmdTime(List<String> positionals, String localeCode, String compactness) {
        if (positionals.isEmpty()) {
            throw usage("time requires a time argument");
        }
        String timeVal = nullify(positionals.get(0));

        TimeLocale locale = sayabletime.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        SayableTime formatter = new SayableTime(locale, timeCompactness(compactness));
        String result = formatter.formatTime(timeVal);

        return result;
    }

    private static String cmdDuration(List<String> positionals, String localeCode, String compactness) {
        if (positionals.isEmpty()) {
            throw usage("duration requires a value argument");
        }
        String value = nullify(positionals.get(0));

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness));

        String result;
        if (value == null) {
            result = formatter.formatDurationSeconds(-1);
        } else if (isInteger(value)) {
            result = fitsInLong(value) ? formatter.formatDurationSeconds(Long.parseLong(value)) : null;
        } else {
            if (positionals.size() < 2) {
                throw usage("duration with timestamps requires start and end arguments");
            }
            String end = nullify(positionals.get(1));
            result = formatter.formatDurationIso(value, end);
        }

        return result;
    }

    private static String cmdSince(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage("since requires a start timestamp argument");
        }
        String start = nullify(positionals.get(0));

        if (asOf == null) {
            throw usage("since requires --as-of / -d option");
        }
        asOf = nullify(asOf);

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness));
        String result = formatter.formatSince(start, asOf);

        return result;
    }

    private static String cmdUntil(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage("until requires a target timestamp argument");
        }
        String target = nullify(positionals.get(0));

        if (asOf == null) {
            throw usage("until requires --as-of / -d option");
        }
        asOf = nullify(asOf);

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode);
        if (locale == null) {
            throw usage("unknown locale '" + localeCode + "'");
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness));
        String result = formatter.formatUntil(target, asOf);

        return result;
    }

    private static String cmdLocales() {
        return String.join("\n", new TreeSet<>(sayableage.locales.Locales.ALL.keySet()));
    }

    /** A digit string too long for a long is far beyond the 500-year ceiling. */
    private static boolean fitsInLong(String digits) {
        try {
            Long.parseLong(digits);
            return true;
        } catch (NumberFormatException e) {
            return false;
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

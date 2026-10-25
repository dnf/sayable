import java.nio.charset.StandardCharsets
import java.time.LocalDate

import sayableage.SayableAge
import sayableage.AgeLocale

import sayabledate.SayableDate
import sayabledate.DateLocale

import sayabletime.SayableTime
import sayabletime.TimeLocale

import sayableduration.SayableDuration
import sayableduration.DurationLocale

class Sayable {

    static final String VERSION = '0.5.0'

    static final String HELP = '''\
Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version'''

    /** What one invocation prints to stdout (null: nothing) and the code it exits with. */
    private static final class Outcome {
        final int exitCode
        final String output

        Outcome(int exitCode, String output) {
            this.exitCode = exitCode
            this.output = output
        }

        static Outcome printing(String output) {
            return new Outcome(0, output)
        }

        static Outcome ofResult(String result) {
            return result == null ? new Outcome(1, null) : printing(result)
        }
    }

    /** A usage error: reported on stderr, exit code 2. */
    private static final class UsageException extends RuntimeException {
        UsageException(String message) {
            super(message)
        }
    }

    static void main(String[] args) {
        if (args.length == 1 && args[0] == '--repl') {
            repl()
            return
        }

        Outcome outcome = run(args)
        if (outcome.output != null) {
            System.out.println(outcome.output)
        }
        System.exit(outcome.exitCode)
    }

    /** Answers one tab-separated request per stdin line (see cli/SPEC.md, "REPL Mode"). */
    private static void repl() {
        BufferedReader input = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8))
        String line
        while ((line = input.readLine()) != null) {
            Outcome outcome = runCatchingCrashes(line.split('\t', -1))
            String output = outcome.output == null ? '' : outcome.output.replace('\n', '\t')
            System.out.println("${outcome.exitCode}\t${output}")
            System.out.flush()
        }
    }

    /** A crashed one-shot run exits 1, so a crashed request answers 1 and the REPL keeps serving. */
    private static Outcome runCatchingCrashes(String[] args) {
        try {
            return run(args)
        } catch (RuntimeException e) {
            e.printStackTrace()
            return new Outcome(1, null)
        }
    }

    private static Outcome run(String[] args) {
        try {
            return dispatch(args)
        } catch (UsageException e) {
            System.err.println("error: ${e.message}")
            System.err.println("Run 'sayable help' for usage.")
            return new Outcome(2, null)
        }
    }

    private static Outcome dispatch(String[] args) {
        if (args.length == 0) {
            return new Outcome(2, HELP)
        }

        String first = args[0]
        if (first == '-h' || first == '--help' || first == 'help') {
            return Outcome.printing(HELP)
        }
        if (first == '-v' || first == '--version' || first == 'version') {
            return Outcome.printing("sayable ${VERSION}")
        }

        String command = first
        List<String> positionals = []
        String locale = 'en'
        String asOf = null
        String compactness = 'normal'
        String gender = null
        boolean withYear = false

        int i = 1
        boolean stopOpts = false
        while (i < args.length) {
            String arg = args[i]

            if (arg == '--' && !stopOpts) {
                stopOpts = true
                i++
                continue
            }

            if (!stopOpts && arg.startsWith('-')) {
                if (arg == '-l' || arg == '--locale') {
                    if (i + 1 >= args.length) {
                        throw usage("'${arg}' requires a value")
                    }
                    i++
                    locale = args[i]
                } else if (arg == '-d' || arg == '--as-of') {
                    if (i + 1 >= args.length) {
                        throw usage("'${arg}' requires a value")
                    }
                    i++
                    asOf = args[i]
                } else if (arg == '-g' || arg == '--gender') {
                    if (i + 1 >= args.length) {
                        throw usage("'${arg}' requires a value")
                    }
                    i++
                    gender = args[i]
                } else if (arg == '--short') {
                    compactness = 'short'
                } else if (arg == '--compact') {
                    compactness = 'compact'
                } else if (arg == '--with-year') {
                    withYear = true
                } else if (arg == '-h' || arg == '--help') {
                    return Outcome.printing(HELP)
                } else if (arg == '-v' || arg == '--version') {
                    return Outcome.printing("sayable ${VERSION}")
                } else {
                    throw usage("unknown option '${arg}'")
                }
            } else {
                positionals.add(arg)
            }

            i++
        }

        switch (command) {
            case 'age':      return Outcome.ofResult(cmdAge(positionals, locale, asOf, compactness))
            case 'stage':    return Outcome.ofResult(cmdStage(positionals, locale, asOf, compactness, gender))
            case 'date':     return Outcome.ofResult(cmdDate(positionals, locale, compactness, withYear))
            case 'relative': return Outcome.ofResult(cmdRelative(positionals, locale, asOf, compactness))
            case 'time':     return Outcome.ofResult(cmdTime(positionals, locale, compactness))
            case 'duration': return Outcome.ofResult(cmdDuration(positionals, locale, compactness))
            case 'since':    return Outcome.ofResult(cmdSince(positionals, locale, asOf, compactness))
            case 'until':    return Outcome.ofResult(cmdUntil(positionals, locale, asOf, compactness))
            case 'locales':  return Outcome.printing(cmdLocales())
            default:         throw usage("unknown command '${command}'")
        }
    }

    private static String nullify(String value) {
        return value == 'null' ? null : value
    }

    private static UsageException usage(String msg) {
        return new UsageException(msg)
    }

    private static String getToday() {
        return LocalDate.now().toString()
    }

    private static sayableage.Compactness ageCompactness(String c) {
        switch (c) {
            case 'short':   return sayableage.Compactness.SHORT
            case 'compact': return sayableage.Compactness.COMPACT
            default:        return sayableage.Compactness.NORMAL
        }
    }

    private static sayabledate.Compactness dateCompactness(String c) {
        switch (c) {
            case 'short':   return sayabledate.Compactness.SHORT
            case 'compact': return sayabledate.Compactness.COMPACT
            default:        return sayabledate.Compactness.NORMAL
        }
    }

    private static sayabletime.Compactness timeCompactness(String c) {
        switch (c) {
            case 'short':   return sayabletime.Compactness.SHORT
            case 'compact': return sayabletime.Compactness.COMPACT
            default:        return sayabletime.Compactness.NORMAL
        }
    }

    private static sayableduration.Compactness durationCompactness(String c) {
        switch (c) {
            case 'short':   return sayableduration.Compactness.SHORT
            case 'compact': return sayableduration.Compactness.COMPACT
            default:        return sayableduration.Compactness.NORMAL
        }
    }

    private static String cmdAge(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage('age requires a date-of-birth argument')
        }
        String dob = nullify(positionals[0])

        AgeLocale locale = sayableage.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        if (asOf != null) {
            asOf = nullify(asOf)
        } else {
            asOf = getToday()
        }

        SayableAge formatter = new SayableAge(locale, ageCompactness(compactness))
        String result = formatter.formatAge(dob, asOf)

        return result
    }

    private static String cmdStage(List<String> positionals, String localeCode, String asOf, String compactness, String gender) {
        if (positionals.isEmpty()) {
            throw usage('stage requires a date-of-birth argument')
        }
        String dob = nullify(positionals[0])

        AgeLocale locale = sayableage.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        if (asOf != null) {
            asOf = nullify(asOf)
        } else {
            asOf = getToday()
        }

        SayableAge formatter = new SayableAge(locale, ageCompactness(compactness))
        String result = formatter.formatStage(dob, asOf, gender)

        return result
    }

    private static String cmdDate(List<String> positionals, String localeCode, String compactness, boolean withYear) {
        if (positionals.isEmpty()) {
            throw usage('date requires a date argument')
        }
        String dateVal = nullify(positionals[0])

        DateLocale locale = sayabledate.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        SayableDate formatter = new SayableDate(locale, dateCompactness(compactness))

        String result
        if (withYear) {
            result = formatter.formatDateWithYear(dateVal)
        } else {
            result = formatter.formatDate(dateVal)
        }

        return result
    }

    private static String cmdRelative(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage('relative requires a date argument')
        }
        String dateVal = nullify(positionals[0])

        if (asOf == null) {
            throw usage('relative requires --as-of / -d option')
        }
        asOf = nullify(asOf)

        DateLocale locale = sayabledate.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        SayableDate formatter = new SayableDate(locale, dateCompactness(compactness))
        String result = formatter.formatRelative(dateVal, asOf)

        return result
    }

    private static String cmdTime(List<String> positionals, String localeCode, String compactness) {
        if (positionals.isEmpty()) {
            throw usage('time requires a time argument')
        }
        String timeVal = nullify(positionals[0])

        TimeLocale locale = sayabletime.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        SayableTime formatter = new SayableTime(locale, timeCompactness(compactness))
        String result = formatter.formatTime(timeVal)

        return result
    }

    private static String cmdDuration(List<String> positionals, String localeCode, String compactness) {
        if (positionals.isEmpty()) {
            throw usage('duration requires a value argument')
        }
        String value = nullify(positionals[0])

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness))

        String result
        if (value == null) {
            result = formatter.formatDurationSeconds(-1)
        } else if (isInteger(value)) {
            // A digit string too long for a long is far beyond the 500-year ceiling
            result = value.isLong() ? formatter.formatDurationSeconds(value as long) : null
        } else {
            if (positionals.size() < 2) {
                throw usage('duration with timestamps requires start and end arguments')
            }
            String end = nullify(positionals[1])
            result = formatter.formatDurationIso(value, end)
        }

        return result
    }

    private static String cmdSince(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage('since requires a start timestamp argument')
        }
        String start = nullify(positionals[0])

        if (asOf == null) {
            throw usage('since requires --as-of / -d option')
        }
        asOf = nullify(asOf)

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness))
        String result = formatter.formatSince(start, asOf)

        return result
    }

    private static String cmdUntil(List<String> positionals, String localeCode, String asOf, String compactness) {
        if (positionals.isEmpty()) {
            throw usage('until requires a target timestamp argument')
        }
        String target = nullify(positionals[0])

        if (asOf == null) {
            throw usage('until requires --as-of / -d option')
        }
        asOf = nullify(asOf)

        DurationLocale locale = sayableduration.locales.Locales.get(localeCode)
        if (locale == null) {
            throw usage("unknown locale '${localeCode}'")
        }

        SayableDuration formatter = new SayableDuration(locale, durationCompactness(compactness))
        String result = formatter.formatUntil(target, asOf)

        return result
    }

    private static String cmdLocales() {
        return new TreeSet<String>(sayableage.locales.Locales.ALL.keySet()).join('\n')
    }

    private static boolean isInteger(String s) {
        if (s == null || s.isEmpty()) return false
        int start = 0
        if (s.charAt(0) == ('-' as char)) {
            if (s.length() == 1) return false
            start = 1
        }
        char zero = '0' as char
        char nine = '9' as char
        for (int j = start; j < s.length(); j++) {
            char c = s.charAt(j)
            if (c < zero || c > nine) return false
        }
        return true
    }
}

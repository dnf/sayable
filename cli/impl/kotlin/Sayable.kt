import java.time.LocalDate
import kotlin.system.exitProcess

import sayableage.SayableAge
import sayableage.AgeLocale

import sayabledate.SayableDate
import sayabledate.DateLocale

import sayabletime.SayableTime
import sayabletime.TimeLocale

import sayableduration.SayableDuration
import sayableduration.DurationLocale

private const val VERSION = "0.5.0"

private val HELP = """
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
  -v, --version          Show version
""".trimIndent()

/** What one invocation prints to stdout (null: nothing) and the code it exits with. */
private data class Outcome(val exitCode: Int, val output: String?) {
    companion object {
        fun printing(output: String) = Outcome(0, output)
        fun ofResult(result: String?) = if (result == null) Outcome(1, null) else printing(result)
    }
}

/** A usage error: reported on stderr, exit code 2. */
private class UsageException(message: String) : Exception(message)

private fun usage(msg: String): Nothing = throw UsageException(msg)

fun main(args: Array<String>) {
    if (args.size == 1 && args[0] == "--repl") {
        repl()
        return
    }

    val outcome = run(args)
    outcome.output?.let(::println)
    exitProcess(outcome.exitCode)
}

/** Answers one tab-separated request per stdin line (see cli/SPEC.md, "REPL Mode"). */
private fun repl() {
    System.`in`.bufferedReader(Charsets.UTF_8).forEachLine { line ->
        val outcome = runCatchingCrashes(line.split('\t').toTypedArray())
        val output = outcome.output?.replace('\n', '\t') ?: ""
        println("${outcome.exitCode}\t$output")
        System.out.flush()
    }
}

/** A crashed one-shot run exits 1, so a crashed request answers 1 and the REPL keeps serving. */
private fun runCatchingCrashes(args: Array<String>): Outcome =
    try {
        run(args)
    } catch (e: Exception) {
        e.printStackTrace()
        Outcome(1, null)
    }

private fun run(args: Array<String>): Outcome =
    try {
        dispatch(args)
    } catch (e: UsageException) {
        System.err.println("error: ${e.message}")
        System.err.println("Run 'sayable help' for usage.")
        Outcome(2, null)
    }

private fun dispatch(args: Array<String>): Outcome {
    if (args.isEmpty()) return Outcome(2, HELP)

    val first = args[0]
    if (first == "-h" || first == "--help" || first == "help") return Outcome.printing(HELP)
    if (first == "-v" || first == "--version" || first == "version") return Outcome.printing("sayable $VERSION")

    val command = first
    val positionals = mutableListOf<String>()
    var locale = "en"
    var asOf: String? = null
    var compactness = "normal"
    var gender: String? = null
    var withYear = false

    var i = 1
    var stopOpts = false
    while (i < args.size) {
        val arg = args[i]

        if (arg == "--" && !stopOpts) {
            stopOpts = true
            i++
            continue
        }

        if (!stopOpts && arg.startsWith("-")) {
            when (arg) {
                "-l", "--locale" -> {
                    if (i + 1 >= args.size) usage("'$arg' requires a value")
                    i++
                    locale = args[i]
                }
                "-d", "--as-of" -> {
                    if (i + 1 >= args.size) usage("'$arg' requires a value")
                    i++
                    asOf = args[i]
                }
                "-g", "--gender" -> {
                    if (i + 1 >= args.size) usage("'$arg' requires a value")
                    i++
                    gender = args[i]
                }
                "--short" -> compactness = "short"
                "--compact" -> compactness = "compact"
                "--with-year" -> withYear = true
                "-h", "--help" -> return Outcome.printing(HELP)
                "-v", "--version" -> return Outcome.printing("sayable $VERSION")
                else -> usage("unknown option '$arg'")
            }
        } else {
            positionals.add(arg)
        }

        i++
    }

    return when (command) {
        "age" -> Outcome.ofResult(cmdAge(positionals, locale, asOf, compactness))
        "stage" -> Outcome.ofResult(cmdStage(positionals, locale, asOf, compactness, gender))
        "date" -> Outcome.ofResult(cmdDate(positionals, locale, compactness, withYear))
        "relative" -> Outcome.ofResult(cmdRelative(positionals, locale, asOf, compactness))
        "time" -> Outcome.ofResult(cmdTime(positionals, locale, compactness))
        "duration" -> Outcome.ofResult(cmdDuration(positionals, locale, compactness))
        "since" -> Outcome.ofResult(cmdSince(positionals, locale, asOf, compactness))
        "until" -> Outcome.ofResult(cmdUntil(positionals, locale, asOf, compactness))
        "locales" -> Outcome.printing(cmdLocales())
        else -> usage("unknown command '$command'")
    }
}

private fun nullify(value: String): String? =
    if (value == "null") null else value

private fun getToday(): String = LocalDate.now().toString()

private fun ageCompactness(c: String): sayableage.Compactness = when (c) {
    "short" -> sayableage.Compactness.SHORT
    "compact" -> sayableage.Compactness.COMPACT
    else -> sayableage.Compactness.NORMAL
}

private fun dateCompactness(c: String): sayabledate.Compactness = when (c) {
    "short" -> sayabledate.Compactness.SHORT
    "compact" -> sayabledate.Compactness.COMPACT
    else -> sayabledate.Compactness.NORMAL
}

private fun timeCompactness(c: String): sayabletime.Compactness = when (c) {
    "short" -> sayabletime.Compactness.SHORT
    "compact" -> sayabletime.Compactness.COMPACT
    else -> sayabletime.Compactness.NORMAL
}

private fun durationCompactness(c: String): sayableduration.Compactness = when (c) {
    "short" -> sayableduration.Compactness.SHORT
    "compact" -> sayableduration.Compactness.COMPACT
    else -> sayableduration.Compactness.NORMAL
}

private fun cmdAge(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String): String? {
    if (positionals.isEmpty()) usage("age requires a date-of-birth argument")
    val dob = nullify(positionals[0])

    val loc = sayableage.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val asOf = if (asOfArg != null) nullify(asOfArg) else getToday()

    // formatAge takes non-nullable String; null dob means null result
    if (dob == null) return null

    val formatter = SayableAge(loc, ageCompactness(compactness))
    val result = formatter.formatAge(dob, asOf)

    return result
}

private fun cmdStage(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String, gender: String?): String? {
    if (positionals.isEmpty()) usage("stage requires a date-of-birth argument")
    val dob = nullify(positionals[0])

    val loc = sayableage.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val asOf = if (asOfArg != null) nullify(asOfArg) else getToday()

    // formatStage takes non-nullable String; null dob means null result
    if (dob == null) return null

    val formatter = SayableAge(loc, ageCompactness(compactness))
    val result = formatter.formatStage(dob, asOf, gender)

    return result
}

private fun cmdDate(positionals: List<String>, localeCode: String, compactness: String, withYear: Boolean): String? {
    if (positionals.isEmpty()) usage("date requires a date argument")
    val dateVal = nullify(positionals[0])

    val loc = sayabledate.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val formatter = SayableDate(loc, dateCompactness(compactness))

    val result = if (withYear) {
        formatter.formatDateWithYear(dateVal)
    } else {
        formatter.formatDate(dateVal)
    }

    return result
}

private fun cmdRelative(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String): String? {
    if (positionals.isEmpty()) usage("relative requires a date argument")
    val dateVal = nullify(positionals[0])

    if (asOfArg == null) usage("relative requires --as-of / -d option")
    val asOf = nullify(asOfArg)

    val loc = sayabledate.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val formatter = SayableDate(loc, dateCompactness(compactness))
    val result = formatter.formatRelative(dateVal, asOf)

    return result
}

private fun cmdTime(positionals: List<String>, localeCode: String, compactness: String): String? {
    if (positionals.isEmpty()) usage("time requires a time argument")
    val timeVal = nullify(positionals[0])

    val loc = sayabletime.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val formatter = SayableTime(loc, timeCompactness(compactness))
    val result = formatter.formatTime(timeVal)

    return result
}

private fun cmdDuration(positionals: List<String>, localeCode: String, compactness: String): String? {
    if (positionals.isEmpty()) usage("duration requires a value argument")
    val value = nullify(positionals[0])

    val loc = sayableduration.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val formatter = SayableDuration(loc, durationCompactness(compactness))

    val result: String? = if (value == null) {
        // null -> formatDurationSeconds(-1) which returns null
        formatter.formatDurationSeconds(-1)
    } else if (isInteger(value)) {
        formatter.formatDurationSeconds(value.toInt())
    } else {
        // Timestamp mode: need an end argument
        if (positionals.size < 2) usage("duration with timestamps requires start and end arguments")
        val end = nullify(positionals[1])
        if (end == null) {
            null
        } else {
            formatter.formatDurationIso(value, end)
        }
    }

    return result
}

private fun cmdSince(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String): String? {
    if (positionals.isEmpty()) usage("since requires a start timestamp argument")
    val start = nullify(positionals[0])

    if (asOfArg == null) usage("since requires --as-of / -d option")
    val asOf = nullify(asOfArg)

    val loc = sayableduration.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val formatter = SayableDuration(loc, durationCompactness(compactness))
    val result = formatter.formatSince(start, asOf)

    return result
}

private fun cmdUntil(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String): String? {
    if (positionals.isEmpty()) usage("until requires a target timestamp argument")
    val target = nullify(positionals[0])

    if (asOfArg == null) usage("until requires --as-of / -d option")
    val asOf = nullify(asOfArg)

    val loc = sayableduration.locales.Locales.get(localeCode)
    if (loc == null) usage("unknown locale '$localeCode'")

    val formatter = SayableDuration(loc, durationCompactness(compactness))
    val result = formatter.formatUntil(target, asOf)

    return result
}

private fun cmdLocales(): String =
    sayableage.locales.Locales.ALL.keys.sorted().joinToString("\n")

private fun isInteger(s: String): Boolean {
    if (s.isEmpty()) return false
    var start = 0
    if (s[0] == '-') {
        if (s.length == 1) return false
        start = 1
    }
    for (j in start until s.length) {
        val c = s[j]
        if (c < '0' || c > '9') return false
    }
    return true
}

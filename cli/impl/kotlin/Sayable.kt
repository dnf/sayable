import java.time.LocalDate

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

fun main(args: Array<String>) {
    if (args.isEmpty()) {
        println(HELP)
        System.exit(2)
    }

    val first = args[0]
    if (first == "-h" || first == "--help" || first == "help") {
        println(HELP)
        System.exit(0)
    }
    if (first == "-v" || first == "--version" || first == "version") {
        println("sayable $VERSION")
        System.exit(0)
    }

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
                    if (i + 1 >= args.size) error("'$arg' requires a value")
                    i++
                    locale = args[i]
                }
                "-d", "--as-of" -> {
                    if (i + 1 >= args.size) error("'$arg' requires a value")
                    i++
                    asOf = args[i]
                }
                "-g", "--gender" -> {
                    if (i + 1 >= args.size) error("'$arg' requires a value")
                    i++
                    gender = args[i]
                }
                "--short" -> compactness = "short"
                "--compact" -> compactness = "compact"
                "--with-year" -> withYear = true
                "-h", "--help" -> {
                    println(HELP)
                    System.exit(0)
                }
                "-v", "--version" -> {
                    println("sayable $VERSION")
                    System.exit(0)
                }
                else -> error("unknown option '$arg'")
            }
        } else {
            positionals.add(arg)
        }

        i++
    }

    when (command) {
        "age" -> cmdAge(positionals, locale, asOf, compactness)
        "stage" -> cmdStage(positionals, locale, asOf, compactness, gender)
        "date" -> cmdDate(positionals, locale, compactness, withYear)
        "relative" -> cmdRelative(positionals, locale, asOf, compactness)
        "time" -> cmdTime(positionals, locale, compactness)
        "duration" -> cmdDuration(positionals, locale, compactness)
        "since" -> cmdSince(positionals, locale, asOf, compactness)
        "until" -> cmdUntil(positionals, locale, asOf, compactness)
        "locales" -> cmdLocales()
        else -> error("unknown command '$command'")
    }
}

private fun nullify(value: String): String? =
    if (value == "null") null else value

private fun error(msg: String) {
    System.err.println("error: $msg")
    System.err.println("Run 'sayable help' for usage.")
    System.exit(2)
}

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

private fun cmdAge(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String) {
    if (positionals.isEmpty()) error("age requires a date-of-birth argument")
    val dob = nullify(positionals[0])

    val loc = sayableage.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    var asOf = if (asOfArg != null) nullify(asOfArg) else getToday()

    // formatAge takes non-nullable String; null dob means null result
    if (dob == null) System.exit(1)

    val formatter = SayableAge(loc!!, ageCompactness(compactness))
    val result = formatter.formatAge(dob!!, asOf)

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdStage(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String, gender: String?) {
    if (positionals.isEmpty()) error("stage requires a date-of-birth argument")
    val dob = nullify(positionals[0])

    val loc = sayableage.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    var asOf = if (asOfArg != null) nullify(asOfArg) else getToday()

    // formatStage takes non-nullable String; null dob means null result
    if (dob == null) System.exit(1)

    val formatter = SayableAge(loc!!, ageCompactness(compactness))
    val result = formatter.formatStage(dob!!, asOf, gender)

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdDate(positionals: List<String>, localeCode: String, compactness: String, withYear: Boolean) {
    if (positionals.isEmpty()) error("date requires a date argument")
    val dateVal = nullify(positionals[0])

    val loc = sayabledate.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    val formatter = SayableDate(loc!!, dateCompactness(compactness))

    val result = if (withYear) {
        formatter.formatDateWithYear(dateVal)
    } else {
        formatter.formatDate(dateVal)
    }

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdRelative(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String) {
    if (positionals.isEmpty()) error("relative requires a date argument")
    val dateVal = nullify(positionals[0])

    if (asOfArg == null) error("relative requires --as-of / -d option")
    val asOf = nullify(asOfArg!!)

    val loc = sayabledate.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    val formatter = SayableDate(loc!!, dateCompactness(compactness))
    val result = formatter.formatRelative(dateVal, asOf)

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdTime(positionals: List<String>, localeCode: String, compactness: String) {
    if (positionals.isEmpty()) error("time requires a time argument")
    val timeVal = nullify(positionals[0])

    val loc = sayabletime.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    val formatter = SayableTime(loc!!, timeCompactness(compactness))
    val result = formatter.formatTime(timeVal)

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdDuration(positionals: List<String>, localeCode: String, compactness: String) {
    if (positionals.isEmpty()) error("duration requires a value argument")
    val value = nullify(positionals[0])

    val loc = sayableduration.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    val formatter = SayableDuration(loc!!, durationCompactness(compactness))

    val result: String? = if (value == null) {
        // null -> formatDurationSeconds(-1) which returns null
        formatter.formatDurationSeconds(-1)
    } else if (isInteger(value)) {
        formatter.formatDurationSeconds(value.toInt())
    } else {
        // Timestamp mode: need an end argument
        if (positionals.size < 2) error("duration with timestamps requires start and end arguments")
        val end = nullify(positionals[1])
        if (end == null) {
            null
        } else {
            formatter.formatDurationIso(value, end)
        }
    }

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdSince(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String) {
    if (positionals.isEmpty()) error("since requires a start timestamp argument")
    val start = nullify(positionals[0])

    if (asOfArg == null) error("since requires --as-of / -d option")
    val asOf = nullify(asOfArg!!)

    val loc = sayableduration.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    val formatter = SayableDuration(loc!!, durationCompactness(compactness))
    val result = formatter.formatSince(start, asOf)

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdUntil(positionals: List<String>, localeCode: String, asOfArg: String?, compactness: String) {
    if (positionals.isEmpty()) error("until requires a target timestamp argument")
    val target = nullify(positionals[0])

    if (asOfArg == null) error("until requires --as-of / -d option")
    val asOf = nullify(asOfArg!!)

    val loc = sayableduration.locales.Locales.get(localeCode)
    if (loc == null) error("unknown locale '$localeCode'")

    val formatter = SayableDuration(loc!!, durationCompactness(compactness))
    val result = formatter.formatUntil(target, asOf)

    if (result == null) System.exit(1)
    println(result)
}

private fun cmdLocales() {
    sayableage.locales.Locales.ALL.keys.sorted().forEach { println(it) }
}

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

import java.time.LocalDate
import scala.collection.immutable.SortedSet

object Sayable:

    private val VERSION = "0.5.0"

    private val HELP =
        """Usage: sayable <command> [arguments] [options]
          |
          |Commands:
          |  age <dob>              Format an age
          |  stage <dob>            Get developmental stage
          |  date <date>            Format a calendar date
          |  relative <date>        Format a relative date
          |  time <time>            Format a clock time
          |  duration <value> [end] Format a duration
          |  since <start>          Format elapsed time
          |  until <target>         Format remaining time
          |  locales                List available locale codes
          |  version                Show version
          |  help                   Show this help
          |
          |Options:
          |  -l, --locale <code>    Locale code (default: en)
          |  -d, --as-of <value>    Reference date/timestamp
          |      --short            Short compactness
          |      --compact          Compact compactness
          |  -g, --gender <m|f>     Gender for stage labels
          |      --with-year        Include year (date only)
          |  -h, --help             Show this help
          |  -v, --version          Show version""".stripMargin

    def main(args: Array[String]): Unit =
        if args.isEmpty then
            println(HELP)
            sys.exit(2)

        val first = args(0)
        if first == "-h" || first == "--help" || first == "help" then
            println(HELP)
            sys.exit(0)
        if first == "-v" || first == "--version" || first == "version" then
            println(s"sayable $VERSION")
            sys.exit(0)

        val command = first
        var positionals = List.empty[String]
        var locale = "en"
        var asOf: String = null
        var compactness = "normal"
        var gender: String = null
        var withYear = false

        var i = 1
        var stopOpts = false
        while i < args.length do
            val arg = args(i)

            if arg == "--" && !stopOpts then
                stopOpts = true
                i += 1
            else if !stopOpts && arg.startsWith("-") then
                if arg == "-l" || arg == "--locale" then
                    if i + 1 >= args.length then error(s"'$arg' requires a value")
                    i += 1
                    locale = args(i)
                else if arg == "-d" || arg == "--as-of" then
                    if i + 1 >= args.length then error(s"'$arg' requires a value")
                    i += 1
                    asOf = args(i)
                else if arg == "-g" || arg == "--gender" then
                    if i + 1 >= args.length then error(s"'$arg' requires a value")
                    i += 1
                    gender = args(i)
                else if arg == "--short" then
                    compactness = "short"
                else if arg == "--compact" then
                    compactness = "compact"
                else if arg == "--with-year" then
                    withYear = true
                else if arg == "-h" || arg == "--help" then
                    println(HELP)
                    sys.exit(0)
                else if arg == "-v" || arg == "--version" then
                    println(s"sayable $VERSION")
                    sys.exit(0)
                else
                    error(s"unknown option '$arg'")
                i += 1
            else
                positionals = positionals :+ arg
                i += 1

        command match
            case "age"      => cmdAge(positionals, locale, asOf, compactness)
            case "stage"    => cmdStage(positionals, locale, asOf, compactness, gender)
            case "date"     => cmdDate(positionals, locale, compactness, withYear)
            case "relative" => cmdRelative(positionals, locale, asOf, compactness)
            case "time"     => cmdTime(positionals, locale, compactness)
            case "duration" => cmdDuration(positionals, locale, compactness)
            case "since"    => cmdSince(positionals, locale, asOf, compactness)
            case "until"    => cmdUntil(positionals, locale, asOf, compactness)
            case "locales"  => cmdLocales()
            case _          => error(s"unknown command '$command'")

    private def nullify(value: String): String =
        if value == "null" then null else value

    private def error(msg: String): Unit =
        System.err.println(s"error: $msg")
        System.err.println("Run 'sayable help' for usage.")
        sys.exit(2)

    private def getToday(): String =
        LocalDate.now().toString

    private def ageCompactness(c: String): sayableage.Compactness = c match
        case "short"   => sayableage.Compactness.SHORT
        case "compact" => sayableage.Compactness.COMPACT
        case _         => sayableage.Compactness.NORMAL

    private def dateCompactness(c: String): sayabledate.Compactness = c match
        case "short"   => sayabledate.Compactness.SHORT
        case "compact" => sayabledate.Compactness.COMPACT
        case _         => sayabledate.Compactness.NORMAL

    private def timeCompactness(c: String): sayabletime.Compactness = c match
        case "short"   => sayabletime.Compactness.SHORT
        case "compact" => sayabletime.Compactness.COMPACT
        case _         => sayabletime.Compactness.NORMAL

    private def durationCompactness(c: String): sayableduration.Compactness = c match
        case "short"   => sayableduration.Compactness.SHORT
        case "compact" => sayableduration.Compactness.COMPACT
        case _         => sayableduration.Compactness.NORMAL

    private def cmdAge(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Unit =
        if positionals.isEmpty then error("age requires a date-of-birth argument")
        val dob = nullify(positionals.head)

        val locale = sayableage.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        val asOf = if asOfRaw != null then nullify(asOfRaw) else getToday()

        if dob == null then sys.exit(1)

        val formatter = new sayableage.SayableAge(locale, ageCompactness(compactness))
        formatter.formatAge(dob, asOf) match
            case Some(result) => println(result)
            case None         => sys.exit(1)

    private def cmdStage(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String, gender: String): Unit =
        if positionals.isEmpty then error("stage requires a date-of-birth argument")
        val dob = nullify(positionals.head)

        val locale = sayableage.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        val asOf = if asOfRaw != null then nullify(asOfRaw) else getToday()

        if dob == null then sys.exit(1)

        val formatter = new sayableage.SayableAge(locale, ageCompactness(compactness))
        formatter.formatStage(dob, asOf, gender) match
            case Some(result) => println(result)
            case None         => sys.exit(1)

    private def cmdDate(positionals: List[String], localeCode: String, compactness: String, withYear: Boolean): Unit =
        if positionals.isEmpty then error("date requires a date argument")
        val dateVal = nullify(positionals.head)

        val locale = sayabledate.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        if dateVal == null then sys.exit(1)

        val formatter = new sayabledate.SayableDate(locale, dateCompactness(compactness))

        val result = if withYear then formatter.formatDateWithYear(dateVal)
                     else formatter.formatDate(dateVal)

        result match
            case Some(r) => println(r)
            case None    => sys.exit(1)

    private def cmdRelative(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Unit =
        if positionals.isEmpty then error("relative requires a date argument")
        val dateVal = nullify(positionals.head)

        if asOfRaw == null then error("relative requires --as-of / -d option")
        val asOf = nullify(asOfRaw)

        val locale = sayabledate.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        val formatter = new sayabledate.SayableDate(locale, dateCompactness(compactness))
        formatter.formatRelative(dateVal, asOf) match
            case Some(result) => println(result)
            case None         => sys.exit(1)

    private def cmdTime(positionals: List[String], localeCode: String, compactness: String): Unit =
        if positionals.isEmpty then error("time requires a time argument")
        val timeVal = nullify(positionals.head)

        val locale = sayabletime.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        if timeVal == null then sys.exit(1)

        val formatter = new sayabletime.SayableTime(locale, timeCompactness(compactness))
        formatter.formatTime(timeVal) match
            case Some(result) => println(result)
            case None         => sys.exit(1)

    private def cmdDuration(positionals: List[String], localeCode: String, compactness: String): Unit =
        if positionals.isEmpty then error("duration requires a value argument")
        val value = nullify(positionals.head)

        val locale = sayableduration.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        val formatter = new sayableduration.SayableDuration(locale, durationCompactness(compactness))

        val result: Option[String] =
            if value == null then
                formatter.formatDurationSeconds(-1)
            else if isInteger(value) then
                formatter.formatDurationSeconds(value.toInt)
            else
                if positionals.size < 2 then
                    error("duration with timestamps requires start and end arguments")
                    None  // unreachable, error exits
                else
                    val end = nullify(positionals(1))
                    formatter.formatDurationIso(value, end)

        result match
            case Some(r) => println(r)
            case None    => sys.exit(1)

    private def cmdSince(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Unit =
        if positionals.isEmpty then error("since requires a start timestamp argument")
        val start = nullify(positionals.head)

        if asOfRaw == null then error("since requires --as-of / -d option")
        val asOf = nullify(asOfRaw)

        val locale = sayableduration.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        val formatter = new sayableduration.SayableDuration(locale, durationCompactness(compactness))
        formatter.formatSince(start, asOf) match
            case Some(result) => println(result)
            case None         => sys.exit(1)

    private def cmdUntil(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Unit =
        if positionals.isEmpty then error("until requires a target timestamp argument")
        val target = nullify(positionals.head)

        if asOfRaw == null then error("until requires --as-of / -d option")
        val asOf = nullify(asOfRaw)

        val locale = sayableduration.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => error(s"unknown locale '$localeCode'"); return

        val formatter = new sayableduration.SayableDuration(locale, durationCompactness(compactness))
        formatter.formatUntil(target, asOf) match
            case Some(result) => println(result)
            case None         => sys.exit(1)

    private def cmdLocales(): Unit =
        val codes = SortedSet.from(sayableage.locales.Locales.ALL.keys)
        codes.foreach(println)

    private def isInteger(s: String): Boolean =
        if s == null || s.isEmpty then return false
        var start = 0
        if s.charAt(0) == '-' then
            if s.length == 1 then return false
            start = 1
        var j = start
        while j < s.length do
            val c = s.charAt(j)
            if c < '0' || c > '9' then return false
            j += 1
        true

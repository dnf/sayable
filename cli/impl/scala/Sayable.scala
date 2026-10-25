import java.io.{BufferedReader, InputStreamReader}
import java.nio.charset.StandardCharsets
import java.time.LocalDate
import scala.util.control.NonFatal
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

    /** What one invocation prints to stdout and the code it exits with. */
    private final case class Outcome(exitCode: Int, output: Option[String])

    private object Outcome:
        def printing(output: String): Outcome = Outcome(0, Some(output))
        def ofResult(result: Option[String]): Outcome = Outcome(if result.isDefined then 0 else 1, result)

    /** A usage error: reported on stderr, exit code 2. */
    private final class UsageException(message: String) extends Exception(message)

    private def usage(msg: String): Nothing = throw UsageException(msg)

    def main(args: Array[String]): Unit =
        if args.sameElements(Seq("--repl")) then
            repl()
        else
            val outcome = run(args.toList)
            outcome.output.foreach(println)
            sys.exit(outcome.exitCode)

    /** Answers one tab-separated request per stdin line (see cli/SPEC.md, "REPL Mode"). */
    private def repl(): Unit =
        val in = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8))
        Iterator.continually(in.readLine()).takeWhile(_ != null).foreach { line =>
            val outcome = runCatchingCrashes(line.split("\t", -1).toList)
            val output = outcome.output.map(_.replace('\n', '\t')).getOrElse("")
            println(s"${outcome.exitCode}\t$output")
            Console.out.flush()
        }

    /** A crashed one-shot run exits 1, so a crashed request answers 1 and the REPL keeps serving. */
    private def runCatchingCrashes(args: List[String]): Outcome =
        try run(args)
        catch
            case NonFatal(e) =>
                e.printStackTrace()
                Outcome(1, None)

    private def run(args: List[String]): Outcome =
        try dispatch(args)
        catch
            case e: UsageException =>
                System.err.println(s"error: ${e.getMessage}")
                System.err.println("Run 'sayable help' for usage.")
                Outcome(2, None)

    private def dispatch(args: List[String]): Outcome = args match
        case Nil                                   => Outcome(2, Some(HELP))
        case ("-h" | "--help" | "help") :: _       => Outcome.printing(HELP)
        case ("-v" | "--version" | "version") :: _ => Outcome.printing(s"sayable $VERSION")
        case command :: rest                       => dispatchCommand(command, rest.toArray)

    private def dispatchCommand(command: String, args: Array[String]): Outcome =
        var positionals = List.empty[String]
        var locale = "en"
        var asOf: String = null
        var compactness = "normal"
        var gender: String = null
        var withYear = false

        var i = 0
        var stopOpts = false
        var helpOrVersion: Option[Outcome] = None
        while i < args.length && helpOrVersion.isEmpty do
            val arg = args(i)

            if arg == "--" && !stopOpts then
                stopOpts = true
                i += 1
            else if !stopOpts && arg.startsWith("-") then
                if arg == "-l" || arg == "--locale" then
                    if i + 1 >= args.length then usage(s"'$arg' requires a value")
                    i += 1
                    locale = args(i)
                else if arg == "-d" || arg == "--as-of" then
                    if i + 1 >= args.length then usage(s"'$arg' requires a value")
                    i += 1
                    asOf = args(i)
                else if arg == "-g" || arg == "--gender" then
                    if i + 1 >= args.length then usage(s"'$arg' requires a value")
                    i += 1
                    gender = args(i)
                else if arg == "--short" then
                    compactness = "short"
                else if arg == "--compact" then
                    compactness = "compact"
                else if arg == "--with-year" then
                    withYear = true
                else if arg == "-h" || arg == "--help" then
                    helpOrVersion = Some(Outcome.printing(HELP))
                else if arg == "-v" || arg == "--version" then
                    helpOrVersion = Some(Outcome.printing(s"sayable $VERSION"))
                else
                    usage(s"unknown option '$arg'")
                i += 1
            else
                positionals = positionals :+ arg
                i += 1

        helpOrVersion.getOrElse {
            command match
                case "age"      => Outcome.ofResult(cmdAge(positionals, locale, asOf, compactness))
                case "stage"    => Outcome.ofResult(cmdStage(positionals, locale, asOf, compactness, gender))
                case "date"     => Outcome.ofResult(cmdDate(positionals, locale, compactness, withYear))
                case "relative" => Outcome.ofResult(cmdRelative(positionals, locale, asOf, compactness))
                case "time"     => Outcome.ofResult(cmdTime(positionals, locale, compactness))
                case "duration" => Outcome.ofResult(cmdDuration(positionals, locale, compactness))
                case "since"    => Outcome.ofResult(cmdSince(positionals, locale, asOf, compactness))
                case "until"    => Outcome.ofResult(cmdUntil(positionals, locale, asOf, compactness))
                case "locales"  => Outcome.printing(cmdLocales())
                case _          => usage(s"unknown command '$command'")
        }

    private def nullify(value: String): String =
        if value == "null" then null else value

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

    private def cmdAge(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Option[String] =
        if positionals.isEmpty then usage("age requires a date-of-birth argument")
        val dob = nullify(positionals.head)

        val locale = sayableage.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        val asOf = if asOfRaw != null then nullify(asOfRaw) else getToday()

        if dob == null then None
        else
            val formatter = new sayableage.SayableAge(locale, ageCompactness(compactness))
            formatter.formatAge(dob, asOf)

    private def cmdStage(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String, gender: String): Option[String] =
        if positionals.isEmpty then usage("stage requires a date-of-birth argument")
        val dob = nullify(positionals.head)

        val locale = sayableage.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        val asOf = if asOfRaw != null then nullify(asOfRaw) else getToday()

        if dob == null then None
        else
            val formatter = new sayableage.SayableAge(locale, ageCompactness(compactness))
            formatter.formatStage(dob, asOf, gender)

    private def cmdDate(positionals: List[String], localeCode: String, compactness: String, withYear: Boolean): Option[String] =
        if positionals.isEmpty then usage("date requires a date argument")
        val dateVal = nullify(positionals.head)

        val locale = sayabledate.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        if dateVal == null then None
        else
            val formatter = new sayabledate.SayableDate(locale, dateCompactness(compactness))
            if withYear then formatter.formatDateWithYear(dateVal)
            else formatter.formatDate(dateVal)

    private def cmdRelative(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Option[String] =
        if positionals.isEmpty then usage("relative requires a date argument")
        val dateVal = nullify(positionals.head)

        if asOfRaw == null then usage("relative requires --as-of / -d option")
        val asOf = nullify(asOfRaw)

        val locale = sayabledate.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        val formatter = new sayabledate.SayableDate(locale, dateCompactness(compactness))
        formatter.formatRelative(dateVal, asOf)

    private def cmdTime(positionals: List[String], localeCode: String, compactness: String): Option[String] =
        if positionals.isEmpty then usage("time requires a time argument")
        val timeVal = nullify(positionals.head)

        val locale = sayabletime.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        if timeVal == null then None
        else
            val formatter = new sayabletime.SayableTime(locale, timeCompactness(compactness))
            formatter.formatTime(timeVal)

    private def cmdDuration(positionals: List[String], localeCode: String, compactness: String): Option[String] =
        if positionals.isEmpty then usage("duration requires a value argument")
        val value = nullify(positionals.head)

        val locale = sayableduration.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        val formatter = new sayableduration.SayableDuration(locale, durationCompactness(compactness))

        if value == null then
            formatter.formatDurationSeconds(-1)
        else if isInteger(value) then
            formatter.formatDurationSeconds(value.toInt)
        else
            if positionals.size < 2 then
                usage("duration with timestamps requires start and end arguments")
            val end = nullify(positionals(1))
            formatter.formatDurationIso(value, end)

    private def cmdSince(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Option[String] =
        if positionals.isEmpty then usage("since requires a start timestamp argument")
        val start = nullify(positionals.head)

        if asOfRaw == null then usage("since requires --as-of / -d option")
        val asOf = nullify(asOfRaw)

        val locale = sayableduration.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        val formatter = new sayableduration.SayableDuration(locale, durationCompactness(compactness))
        formatter.formatSince(start, asOf)

    private def cmdUntil(positionals: List[String], localeCode: String, asOfRaw: String, compactness: String): Option[String] =
        if positionals.isEmpty then usage("until requires a target timestamp argument")
        val target = nullify(positionals.head)

        if asOfRaw == null then usage("until requires --as-of / -d option")
        val asOf = nullify(asOfRaw)

        val locale = sayableduration.locales.Locales.get(localeCode) match
            case Some(l) => l
            case None    => usage(s"unknown locale '$localeCode'")

        val formatter = new sayableduration.SayableDuration(locale, durationCompactness(compactness))
        formatter.formatUntil(target, asOf)

    private def cmdLocales(): String =
        SortedSet.from(sayableage.locales.Locales.ALL.keys).mkString("\n")

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

package sayabletime

import java.time.YearMonth
import sayabletime.locales.Locales

val Version = "0.5.0"

class SayableTime(locale: TimeLocale, compactness: Compactness = Compactness.NORMAL):
    private val shortClock: Option[ShortClockConfig] =
        val ovr = compactness match
            case Compactness.SHORT => locale.short
            case Compactness.COMPACT => locale.compact
            case Compactness.NORMAL => None
        ovr.flatMap(_.clock)

    /** Format a time as a natural language clock reading. */
    def formatTime(input: String): Option[String] =
        if (input == null || input.isEmpty) None
        else
            parseTime(input).map { case (hour, minute) =>
                shortClock match
                    case Some(_) => formatDigital(hour, minute)
                    case None => formatNatural(hour, minute)
            }

    private def formatNatural(hour: Int, minute: Int): String =
        val clock = locale.clock
        var rounded = roundTo5(minute)
        var h = hour
        if (rounded == 60)
            rounded = 0
            h = (h + 1) % 24
        if (rounded == 0)
            if (h == 0) return clock.midnight
            if (h == 12) return clock.noon
        val h12 = h % 12
        val nextH12 = (h + 1) % 12
        val hName = clock.hours(h12)
        val nextHName = clock.hours(nextH12)
        val pattern = clock.patterns.getOrElse(rounded, clock.patterns.getOrElse(0, "{h}"))
        pattern.replace("{h}", hName).replace("{next_h}", nextHName)

    private def formatDigital(hour: Int, minute: Int): String =
        val sc = shortClock.get
        val fmt = sc.format
        if (sc.use24h)
            fmt
                .replace("{h}", hour.toString)
                .replace("{mm}", "%02d".format(minute))
        else
            var h12 = hour % 12
            if (h12 == 0) h12 = 12
            val amPm = sc.amPm.getOrElse(("AM", "PM"))
            val ampmStr = if (hour < 12) amPm._1 else amPm._2
            fmt
                .replace("{h}", h12.toString)
                .replace("{mm}", "%02d".format(minute))
                .replace("{ampm}", ampmStr)

object SayableTime:
    private lazy val defaultSt: SayableTime = SayableTime(Locales.EN)

    def formatTime(input: String): Option[String] =
        defaultSt.formatTime(input)

/** H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored). */
private val Clock = """([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?""".r

private val DateOnly = """([0-9]{4})-([0-9]{2})-([0-9]{2})""".r

/** Parse a clock time or ISO datetime string into (hour, minute). */
private[sayabletime] def parseTime(input: String): Option[(Int, Int)] =
    val tIdx = input.indexOf('T')
    val datePartIsValid = tIdx < 0 || isRealDate(input.substring(0, tIdx))
    val clock = input.substring(tIdx + 1)
    clock match
        case Clock(h, m, sec) if datePartIsValid =>
            val (hour, minute) = (h.toInt, m.toInt)
            val second = Option(sec).fold(0)(_.toInt)
            if hour <= 23 && minute <= 59 && second <= 59 then Some((hour, minute)) else None
        case _ => None

private def isRealDate(s: String): Boolean =
    s match
        case DateOnly(y, m, d) =>
            val month = m.toInt
            month >= 1 && month <= 12 && d.toInt >= 1 && d.toInt <= YearMonth.of(y.toInt, month).lengthOfMonth()
        case _ => false

/** Round minute to nearest 5. */
private[sayabletime] def roundTo5(minute: Int): Int =
    (minute + 2) / 5 * 5

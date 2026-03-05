package sayabletime

import sayabletime.locales.Locales

val Version = "0.1.0"

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

/** Parse "HH:MM" or ISO datetime string into (hour, minute). */
private[sayabletime] def parseTime(input: String): Option[(Int, Int)] =
    if (input.isEmpty) None
    else
        var t = input
        val tIdx = t.indexOf('T')
        if (tIdx >= 0) t = t.substring(tIdx + 1)
        val plusIdx = t.indexOf('+')
        if (plusIdx >= 0) t = t.substring(0, plusIdx)
        val zIdx = t.indexOf('Z')
        if (zIdx >= 0) t = t.substring(0, zIdx)
        val parts = t.split(":")
        if (parts.length < 2) None
        else
            for
                hour <- safeAtoi(parts(0))
                minute <- safeAtoi(parts(1))
                if hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59
            yield (hour, minute)

/** Round minute to nearest 5. */
private[sayabletime] def roundTo5(minute: Int): Int =
    (minute + 2) / 5 * 5

private def safeAtoi(s: String): Option[Int] =
    if (s.isEmpty) None
    else
        var n = 0
        var i = 0
        while (i < s.length)
            val c = s.charAt(i)
            if (c < '0' || c > '9') return None
            n = n * 10 + (c - '0')
            i += 1
        Some(n)

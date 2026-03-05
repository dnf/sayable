package sayableduration

import sayableduration.locales.Locales

val Version = "0.5.0"

class SayableDuration(locale: DurationLocale, compactness: Compactness = Compactness.NORMAL):
    private val second: UnitForms = _resolve(_.second, _.units.second)
    private val minute: UnitForms = _resolve(_.minute, _.units.minute)
    private val hour: UnitForms = _resolve(_.hour, _.units.hour)
    private val day: UnitForms = _resolve(_.day, _.units.day)
    private val week: UnitForms = _resolve(_.week, _.units.week)
    private val month: UnitForms = _resolve(_.month, _.units.month)
    private val year: UnitForms = _resolve(_.year, _.units.year)
    private val half: String = _resolveStr(_.half, _.half)
    private val delimiter: String = _resolveStr(_.delimiter, _.delimiter)
    private val justNow: String = locale.justNow
    private val ago: String = _resolveStr(_.ago, _.ago)
    private val inFuture: String = _resolveStr(_.inFuture, _.inFuture)

    private def _override: Option[CompactnessOverride] = compactness match
        case Compactness.SHORT => locale.short
        case Compactness.COMPACT => locale.compact
        case Compactness.NORMAL => None

    private def _resolve(ovrField: CompactnessOverride => Option[UnitForms], base: DurationLocale => UnitForms): UnitForms =
        _override.flatMap(ovrField).getOrElse(base(locale))

    private def _resolveStr(ovrField: CompactnessOverride => Option[String], base: DurationLocale => String): String =
        _override.flatMap(ovrField).getOrElse(base(locale))

    /** Formats an integer number of seconds as a human-friendly duration string. */
    def formatDurationSeconds(seconds: Int): Option[String] =
        if (seconds < 0) None
        else Some(formatDurationSecondsInternal(seconds))

    /** Formats the duration between two ISO datetime strings. */
    def formatDurationIso(start: String, end: String): Option[String] =
        if (start.isEmpty || end.isEmpty) None
        else
            for
                s <- parseIsoToSeconds(start)
                e <- parseIsoToSeconds(end)
            yield formatDurationSecondsInternal(math.abs(e - s))

    /** Formats elapsed time as "X ago". */
    def formatSince(start: String, asOf: String): Option[String] =
        if (start == null || start.isEmpty || asOf == null || asOf.isEmpty) None
        else
            for
                s <- parseIsoToSeconds(start)
                a <- parseIsoToSeconds(asOf)
                if a - s >= 0
            yield
                val diff = a - s
                if (diff == 0) justNow
                else ago.replace("{0}", formatDurationSecondsInternal(diff))

    /** Formats time until a future event as "in X". */
    def formatUntil(target: String, asOf: String): Option[String] =
        if (target == null || target.isEmpty || asOf == null || asOf.isEmpty) None
        else
            for
                t <- parseIsoToSeconds(target)
                a <- parseIsoToSeconds(asOf)
                if t - a >= 0
            yield
                val diff = t - a
                if (diff == 0) justNow
                else inFuture.replace("{0}", formatDurationSecondsInternal(diff))

    private def formatDurationSecondsInternal(total: Int): String =
        val loc = locale

        // 0 seconds
        if (total == 0) return justNow

        // 1-59 seconds
        if (total < 60) return resolveUnit(total, second, loc)

        val totalMinutes = total / 60
        val remainderSeconds = total % 60

        // 1-4 minutes: minutes + seconds
        if (totalMinutes < 5)
            var result = resolveUnit(totalMinutes, minute, loc)
            if (remainderSeconds > 0)
                result += delimiter + resolveUnit(remainderSeconds, second, loc)
            return result

        // 5-59 minutes
        if (totalMinutes < 60) return resolveUnit(totalMinutes, minute, loc)

        val totalHours = total / 3600
        val remainderMinutes = (total % 3600) / 60

        // 1-5 hours: hours + minutes (with half marker)
        if (totalHours <= 5)
            if (remainderMinutes == 30)
                return resolveUnit(totalHours, hour, loc, half)
            var result = resolveUnit(totalHours, hour, loc)
            if (remainderMinutes > 0)
                result += delimiter + resolveUnit(remainderMinutes, minute, loc)
            return result

        // 6-23 hours
        if (totalHours < 24) return resolveUnit(totalHours, hour, loc)

        val totalDays = total / 86400
        val remainderHours = (total % 86400) / 3600

        // 1-2 days: days + hours (with half marker)
        if (totalDays <= 2)
            if (remainderHours == 12)
                return resolveUnit(totalDays, day, loc, half)
            var result = resolveUnit(totalDays, day, loc)
            if (remainderHours > 0)
                result += delimiter + resolveUnit(remainderHours, hour, loc)
            return result

        // 3-6 days
        if (totalDays < 7) return resolveUnit(totalDays, day, loc)

        val totalWeeks = totalDays / 7
        val remainderDays = totalDays % 7

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30)
            var result = resolveUnit(totalWeeks, week, loc)
            if (remainderDays > 0)
                result += delimiter + resolveUnit(remainderDays, day, loc)
            return result

        // Approximate months (30.44 days average)
        var totalMonths = math.round(totalDays.toDouble / 30.44).toInt

        // 1-11 months
        if (totalMonths < 12)
            if (totalMonths == 0) totalMonths = 1
            return resolveUnit(totalMonths, month, loc)

        // 12+ months: years + months
        val totalYears = totalMonths / 12
        val remainderMonths = totalMonths % 12
        var result = resolveUnit(totalYears, year, loc)
        if (remainderMonths > 0)
            result += delimiter + resolveUnit(remainderMonths, month, loc)
        result

object SayableDuration:
    private lazy val defaultSd: SayableDuration = SayableDuration(Locales.EN)

    def formatDurationSeconds(seconds: Int): Option[String] =
        defaultSd.formatDurationSeconds(seconds)

    def formatDurationIso(start: String, end: String): Option[String] =
        defaultSd.formatDurationIso(start, end)

    def formatSince(start: String, asOf: String): Option[String] =
        defaultSd.formatSince(start, asOf)

    def formatUntil(target: String, asOf: String): Option[String] =
        defaultSd.formatUntil(target, asOf)

/** Parses an ISO datetime string to epoch-relative seconds for diffing. */
private[sayableduration] def parseIsoToSeconds(iso: String): Option[Int] =
    if (iso.isEmpty) None
    else
        val tIdx = iso.indexOf('T')
        if (tIdx < 0) None
        else
            val datePart = iso.substring(0, tIdx)
            var timePart = iso.substring(tIdx + 1)

            // Parse date: YYYY-MM-DD
            val dp = datePart.split("-")
            if (dp.length < 3) None
            else
                for
                    year <- safeAtoi(dp(0))
                    month <- safeAtoi(dp(1))
                    day <- safeAtoi(dp(2))
                yield
                    // Strip timezone info
                    val plusIdx = timePart.indexOf('+')
                    if (plusIdx >= 0) timePart = timePart.substring(0, plusIdx)
                    val zIdx = timePart.indexOf('Z')
                    if (zIdx >= 0) timePart = timePart.substring(0, zIdx)

                    // Parse time: HH:MM:SS
                    val tp = timePart.split(":")
                    val hour = safeAtoi(tp(0)).getOrElse(0)
                    val minute = if (tp.length > 1) safeAtoi(tp(1)).getOrElse(0) else 0
                    val second = if (tp.length > 2)
                        val secStr = tp(2).split("\\.")(0)
                        safeAtoi(secStr).getOrElse(0)
                    else 0

                    val days = daysSinceEpoch(year, month, day)
                    days * 86400 + hour * 3600 + minute * 60 + second

private[sayableduration] def safeAtoi(s: String): Option[Int] =
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

private def isLeapYear(year: Int): Boolean =
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)

private def daysInMonth(year: Int, month: Int): Int = month match
    case 1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    case 4 | 6 | 9 | 11 => 30
    case 2 => if (isLeapYear(year)) 29 else 28
    case _ => 30

private def daysSinceEpoch(year: Int, month: Int, day: Int): Int =
    var days = 0
    if (year >= 2000)
        for (y <- 2000 until year)
            days += (if (isLeapYear(y)) 366 else 365)
    else
        for (y <- year until 2000)
            days -= (if (isLeapYear(y)) 366 else 365)
    for (m <- 1 until month)
        days += daysInMonth(year, m)
    days += day - 1
    days

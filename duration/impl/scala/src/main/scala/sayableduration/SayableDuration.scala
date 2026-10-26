package sayableduration

import sayableduration.locales.Locales

val Version = "0.5.0"

/** 500 years, the same ceiling as sayable-age. */
private val MaxDurationMonths = 6000L

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
    def formatDurationSeconds(seconds: Long): Option[String] =
        if (seconds < 0) None
        else formatDurationSecondsInternal(seconds)

    /** Formats the duration between two ISO datetime strings. */
    def formatDurationIso(start: String, end: String): Option[String] =
        if (start.isEmpty || end.isEmpty) None
        else
            for
                s <- parseIsoToSeconds(start)
                e <- parseIsoToSeconds(end)
                dur <- formatDurationSecondsInternal(math.abs(e - s))
            yield dur

    /** Formats elapsed time as "X ago". */
    def formatSince(start: String, asOf: String): Option[String] =
        if (start == null || start.isEmpty || asOf == null || asOf.isEmpty) None
        else
            for
                s <- parseIsoToSeconds(start)
                a <- parseIsoToSeconds(asOf)
                if a - s >= 0
                phrase <- relative(a - s, ago)
            yield phrase

    /** Formats time until a future event as "in X". */
    def formatUntil(target: String, asOf: String): Option[String] =
        if (target == null || target.isEmpty || asOf == null || asOf.isEmpty) None
        else
            for
                t <- parseIsoToSeconds(target)
                a <- parseIsoToSeconds(asOf)
                if t - a >= 0
                phrase <- relative(t - a, inFuture)
            yield phrase

    /** "just now" for no difference, else the duration placed in an ago/inFuture template. */
    private def relative(diff: Long, template: String): Option[String] =
        if (diff == 0) Some(justNow)
        else formatDurationSecondsInternal(diff).map(dur => template.replace("{0}", dur))

    /** Counts are bounded by the 500-year ceiling, so they always fit in an Int. */
    private def unit(count: Long, uf: UnitForms, half: String = ""): String =
        resolveUnit(Math.toIntExact(count), uf, locale, half)

    private def formatDurationSecondsInternal(total: Long): Option[String] =
        // 0 seconds
        if (total == 0) return Some(justNow)

        // 1-59 seconds
        if (total < 60) return Some(unit(total, second))

        val totalMinutes = total / 60
        val remainderSeconds = total % 60

        // 1-4 minutes: minutes + seconds
        if (totalMinutes < 5)
            var result = unit(totalMinutes, minute)
            if (remainderSeconds > 0)
                result += delimiter + unit(remainderSeconds, second)
            return Some(result)

        // 5-59 minutes
        if (totalMinutes < 60) return Some(unit(totalMinutes, minute))

        val totalHours = total / 3600
        val remainderMinutes = (total % 3600) / 60

        // 1-5 hours: hours + minutes (with half marker)
        if (totalHours <= 5)
            if (remainderMinutes == 30)
                return Some(unit(totalHours, hour, half))
            var result = unit(totalHours, hour)
            if (remainderMinutes > 0)
                result += delimiter + unit(remainderMinutes, minute)
            return Some(result)

        // 6-23 hours
        if (totalHours < 24) return Some(unit(totalHours, hour))

        val totalDays = total / 86400
        val remainderHours = (total % 86400) / 3600

        // 1-2 days: days + hours (with half marker)
        if (totalDays <= 2)
            if (remainderHours == 12)
                return Some(unit(totalDays, day, half))
            var result = unit(totalDays, day)
            if (remainderHours > 0)
                result += delimiter + unit(remainderHours, hour)
            return Some(result)

        // 3-6 days
        if (totalDays < 7) return Some(unit(totalDays, day))

        val totalWeeks = totalDays / 7
        val remainderDays = totalDays % 7

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if (totalDays < 30)
            var result = unit(totalWeeks, week)
            if (remainderDays > 0)
                result += delimiter + unit(remainderDays, day)
            return Some(result)

        // Approximate months (30.44 days average)
        var totalMonths = math.round(totalDays.toDouble / 30.44)
        if (totalMonths > MaxDurationMonths) return None

        // 1-11 months
        if (totalMonths < 12)
            if (totalMonths == 0) totalMonths = 1
            return Some(unit(totalMonths, month))

        // 12+ months: years + months
        val totalYears = totalMonths / 12
        val remainderMonths = totalMonths % 12
        var result = unit(totalYears, year)
        if (remainderMonths > 0)
            result += delimiter + unit(remainderMonths, month)
        Some(result)

object SayableDuration:
    private lazy val defaultSd: SayableDuration = SayableDuration(Locales.EN)

    def formatDurationSeconds(seconds: Long): Option[String] =
        defaultSd.formatDurationSeconds(seconds)

    def formatDurationIso(start: String, end: String): Option[String] =
        defaultSd.formatDurationIso(start, end)

    def formatSince(start: String, asOf: String): Option[String] =
        defaultSd.formatSince(start, asOf)

    def formatUntil(target: String, asOf: String): Option[String] =
        defaultSd.formatUntil(target, asOf)

/** YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored). */
private val Timestamp =
    ("""([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})""" +
        """(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?""").r

/** Parses an ISO datetime string to epoch-relative seconds for diffing. */
private[sayableduration] def parseIsoToSeconds(iso: String): Option[Long] =
    iso match
        case Timestamp(y, mo, d, h, mi, sec) =>
            val (year, month, day, hour, minute) = (y.toInt, mo.toInt, d.toInt, h.toInt, mi.toInt)
            val second = Option(sec).fold(0)(_.toInt)
            val validDate = month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month)
            val validClock = hour <= 23 && minute <= 59 && second <= 59
            if validDate && validClock then
                Some(daysSinceEpoch(year, month, day).toLong * 86400 + hour * 3600 + minute * 60 + second)
            else None
        case _ => None

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

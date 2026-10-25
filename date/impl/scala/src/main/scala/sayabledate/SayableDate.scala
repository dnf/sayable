package sayabledate

import java.time.YearMonth
import sayabledate.locales.Locales

val Version = "0.5.0"

class SayableDate(locale: DateLocale, compactness: Compactness = Compactness.NORMAL):
    private val months: List[String] = _resolveList(_.months, locale.months)
    private val monthsInDate: Option[List[String]] = _resolveOptList(_.monthsInDate, locale.monthsInDate)
    private val weekdays: List[String] = _resolveList(_.weekdays, locale.weekdays)
    private val dayFormat: String = _dayFormat
    private val dayFormatExceptions: Map[String, String] = _dayFormatExceptions
    private val datePattern: String = _resolveStr(_.datePattern, locale.datePattern)
    private val datePatternWithYear: String = _resolveStr(_.datePatternWithYear, locale.datePatternWithYear)
    private val todayStr: String = _resolveStr(_.today, locale.today)
    private val tomorrowStr: String = _resolveStr(_.tomorrow, locale.tomorrow)
    private val yesterdayStr: String = _resolveStr(_.yesterday, locale.yesterday)

    private def _override: Option[CompactnessOverride] = compactness match
        case Compactness.SHORT => locale.short
        case Compactness.COMPACT => locale.compact
        case Compactness.NORMAL => None

    private def _resolveStr(ovrField: CompactnessOverride => Option[String], base: String): String =
        _override.flatMap(ovrField).getOrElse(base)

    private def _resolveList(ovrField: CompactnessOverride => Option[List[String]], base: List[String]): List[String] =
        _override.flatMap(ovrField).getOrElse(base)

    private def _resolveOptList(ovrField: CompactnessOverride => Option[List[String]], base: Option[List[String]]): Option[List[String]] =
        _override.flatMap(ovrField).orElse(base)

    // When override provides dayFormat but not dayFormatExceptions, clear exceptions
    private def _dayFormat: String =
        _override match
            case Some(ovr) if ovr.dayFormat.isDefined => ovr.dayFormat.get
            case _ => locale.dayFormat

    private def _dayFormatExceptions: Map[String, String] =
        _override match
            case Some(ovr) if ovr.dayFormat.isDefined && ovr.dayFormatExceptions.isEmpty =>
                Map.empty
            case Some(ovr) =>
                ovr.dayFormatExceptions.getOrElse(locale.dayFormatExceptions)
            case None =>
                locale.dayFormatExceptions

    /** Formats a calendar date in locale-appropriate form (no year). */
    def formatDate(date: String): Option[String] =
        if (date == null || date.isEmpty) None
        else
            parseDate(date).map { case (y, m, d) => formatAbsolute(y, m, d, includeYear = false) }

    /** Formats a calendar date with year in locale-appropriate form. */
    def formatDateWithYear(date: String): Option[String] =
        if (date == null || date.isEmpty) None
        else
            parseDate(date).map { case (y, m, d) => formatAbsolute(y, m, d, includeYear = true) }

    /** Formats a date relative to asOf, picking the most natural reference. */
    def formatRelative(date: String, asOf: String): Option[String] =
        if (date == null || date.isEmpty || asOf == null || asOf.isEmpty) None
        else
            for
                pd <- parseDate(date)
                pa <- parseDate(asOf)
            yield
                val (dy, dm, dd) = pd
                val (ay, _, _) = pa

                val dateJdn = toJdn(pd._1, pd._2, pd._3)
                val asofJdn = toJdn(pa._1, pa._2, pa._3)
                val diff = dateJdn - asofJdn

                // Today
                if (diff == 0) todayStr
                // Tomorrow
                else if (diff == 1) tomorrowStr
                // Yesterday
                else if (diff == -1) yesterdayStr
                else
                    val isCompact = compactness == Compactness.COMPACT

                    // Day after tomorrow (optional, skipped in compact mode)
                    if (diff == 2 && locale.dayAfterTomorrow.isDefined && !isCompact)
                        locale.dayAfterTomorrow.get
                    // Day before yesterday (optional, skipped in compact mode)
                    else if (diff == -2 && locale.dayBeforeYesterday.isDefined && !isCompact)
                        locale.dayBeforeYesterday.get
                    // Compact mode: skip weekday references, go straight to calendar date
                    else if (isCompact)
                        formatAbsolute(dy, dm, dd, dy != ay)
                    // This weekday (+2 to +6)
                    else if (diff >= 2 && diff <= 6 && locale.thisWeekday.isDefined)
                        val dow = weekday(dy, dm, dd)
                        val wdName = weekdays(dow)
                        locale.thisWeekday.get.replace("{weekday}", wdName)
                    // Last weekday (-6 to -2)
                    else if (diff >= -6 && diff <= -2 && locale.lastWeekday.isDefined)
                        val dow = weekday(dy, dm, dd)
                        val wdName = weekdays(dow)
                        locale.lastWeekday.get.replace("{weekday}", wdName)
                    // Next weekday (+7 to +13)
                    else if (diff >= 7 && diff <= 13 && locale.nextWeekday.isDefined)
                        val dow = weekday(dy, dm, dd)
                        val wdName = weekdays(dow)
                        locale.nextWeekday.get.replace("{weekday}", wdName)
                    // Calendar fallback
                    else
                        formatAbsolute(dy, dm, dd, dy != ay)

    private def formatAbsolute(year: Int, month: Int, day: Int, includeYear: Boolean): String =
        val dayStr = day.toString
        val fmt = dayFormatExceptions.getOrElse(dayStr, dayFormat)
        val formattedDay = fmt.replace("{n}", dayStr)

        // Pick month name (genitive form if available)
        val monthName = monthsInDate.getOrElse(months)(month - 1)

        val pattern = if (includeYear) datePatternWithYear else datePattern
        var result = pattern.replace("{month}", monthName)
        result = result.replace("{day}", formattedDay)
        result = result.replace("{d}", day.toString)
        result = result.replace("{m}", month.toString)
        if (includeYear)
            result = result.replace("{year}", year.toString)
            val yy = year % 100
            result = result.replace("{yy}", "%02d".format(yy))
        result

object SayableDate:
    private lazy val defaultInstance: SayableDate = SayableDate(Locales.EN)

    def formatDate(date: String): Option[String] = defaultInstance.formatDate(date)

    def formatRelative(date: String, asOf: String): Option[String] =
        defaultInstance.formatRelative(date, asOf)

/** YYYY-MM-DD, alone or followed by T and anything (an ISO datetime). */
private val DatePrefix = """([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T(?s:.*))?""".r

/** Parse "YYYY-MM-DD" or ISO datetime naming a real calendar day to (year, month, day). */
private[sayabledate] def parseDate(s: String): Option[(Int, Int, Int)] =
    s match
        case DatePrefix(y, m, d) =>
            val (year, month, day) = (y.toInt, m.toInt, d.toInt)
            if month >= 1 && month <= 12 && day >= 1 && day <= YearMonth.of(year, month).lengthOfMonth() then
                Some((year, month, day))
            else None
        case _ => None

/** Convert a date to Julian Day Number for day-difference arithmetic. */
private[sayabledate] def toJdn(year: Int, month: Int, day: Int): Int =
    val a = (14 - month) / 12
    val y = year + 4800 - a
    val m = month + 12 * a - 3
    day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045

/** Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday. */
private[sayabledate] def weekday(year: Int, month: Int, day: Int): Int =
    (toJdn(year, month, day) + 1) % 7

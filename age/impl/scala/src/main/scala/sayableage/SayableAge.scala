package sayableage

import java.time.LocalDate
import java.time.YearMonth
import java.time.temporal.ChronoUnit
import sayableage.locales.Locales

val Version = "0.5.0"

private val MaxAgeMonths = 6000

private[sayableage] var timeNow: () => LocalDate = () => LocalDate.now()

private[sayableage] case class AgeComponents(months: Int, diffDays: Int)

private[sayableage] def parseAge(dateOfBirth: String, asOf: Option[String] = None): Option[AgeComponents] =
    if (dateOfBirth == null || dateOfBirth.isEmpty) None
    else
        parseDateParts(dateOfBirth).flatMap { case (dobY, dobM, dobD) =>
            val refParts = asOf.filter(_.nonEmpty) match
                case Some(ref) => parseDateParts(ref)
                case None =>
                    val now = timeNow()
                    Some((now.getYear, now.getMonthValue, now.getDayOfMonth))

            refParts.flatMap { case (refY, refM, refD) =>
                val dobDate = LocalDate.of(dobY, dobM, dobD)
                val refDate = LocalDate.of(refY, refM, refD)
                val diffDays = ChronoUnit.DAYS.between(dobDate, refDate).toInt
                if (diffDays < 0) None
                else
                    val lastDay = YearMonth.of(refY, refM).lengthOfMonth()
                    val clampedBirthday = math.min(dobD, lastDay)
                    var months = (refY - dobY) * 12 + (refM - dobM)
                    if (refD < clampedBirthday) months -= 1
                    if (months > MaxAgeMonths) None
                    else Some(AgeComponents(months = months, diffDays = diffDays))
            }
        }

private[sayableage] def parseDateParts(s: String): Option[(Int, Int, Int)] =
    if (s.length != 10 || s.charAt(4) != '-' || s.charAt(7) != '-') None
    else
        for
            y <- safeAtoi(s.substring(0, 4))
            m <- safeAtoi(s.substring(5, 7))
            d <- safeAtoi(s.substring(8, 10))
            if m >= 1 && m <= 12 && d >= 1 && d <= YearMonth.of(y, m).lengthOfMonth()
        yield (y, m, d)

private[sayableage] def safeAtoi(s: String): Option[Int] =
    var n = 0
    var i = 0
    while (i < s.length)
        val c = s.charAt(i)
        if (c < '0' || c > '9') return None
        n = n * 10 + (c - '0')
        i += 1
    Some(n)

private[sayableage] def stageKey(months: Int): String =
    if (months < 2) "newborn"
    else if (months < 12) "infant"
    else if (months < 36) "toddler"
    else if (months < 156) "child"
    else if (months < 216) "teenager"
    else "adult"

private[sayableage] def resolveUnit(count: Int, uf: UnitForms, loc: AgeLocale, half: String): String =
    val baseN = loc.formatNumber match
        case Some(fn) => fn(count)
        case None => count.toString

    val n = if (half.nonEmpty && half.contains("{n}"))
        half.replace("{n}", baseN)
    else
        baseN

    val template = uf.simple match
        case Some(s) => s
        case None =>
            val cat = loc.plural(count)
            uf.forms.flatMap(_.get(cat)).orElse(uf.forms.flatMap(_.get(PluralCategory.OTHER))).getOrElse("{n}")

    var result = template.replace("{n}", n)

    loc.formatUnit.foreach { fn =>
        result = fn(count, result)
    }

    if (half.nonEmpty && half.contains("{0}"))
        result = half.replace("{0}", result)

    result

class SayableAge(locale: AgeLocale, compactness: Compactness = Compactness.NORMAL):
    private val day: UnitForms = _resolve(_.day, _.units.day)
    private val week: UnitForms = _resolve(_.week, _.units.week)
    private val month: UnitForms = _resolve(_.month, _.units.month)
    private val year: UnitForms = _resolve(_.year, _.units.year)
    private val half: String = _resolveStr(_.half, _.half)
    private val delimiter: String = _resolveStr(_.delimiter, _.delimiter)
    private val justBorn: String = _resolveStr(_.justBorn, _.justBorn)

    private def _override: Option[CompactnessOverride] = compactness match
        case Compactness.SHORT => locale.short
        case Compactness.COMPACT => locale.compact
        case Compactness.NORMAL => None

    private def _resolve(ovrField: CompactnessOverride => Option[UnitForms], base: AgeLocale => UnitForms): UnitForms =
        _override.flatMap(ovrField).getOrElse(base(locale))

    private def _resolveStr(ovrField: CompactnessOverride => Option[String], base: AgeLocale => String): String =
        _override.flatMap(ovrField).getOrElse(base(locale))

    def formatAge(dateOfBirth: String, asOf: String = null): Option[String] =
        val asOfOpt = Option(asOf)
        parseAge(dateOfBirth, asOfOpt).map { age =>
            val months = age.months
            val diffDays = age.diffDays

            if (diffDays == 0) justBorn
            else if (diffDays < 7) resolveUnit(diffDays, day, locale, "")
            else if (months < 3)
                val weeks = diffDays / 7
                val days = diffDays % 7
                val result = resolveUnit(weeks, week, locale, "")
                if (days > 0) result + delimiter + resolveUnit(days, day, locale, "")
                else result
            else if (months < 24) resolveUnit(months, month, locale, "")
            else if (months < 36)
                val years = months / 12
                val rem = months % 12
                if (rem == 0) resolveUnit(years, year, locale, "")
                else resolveUnit(years, year, locale, "") + delimiter + resolveUnit(rem, month, locale, "")
            else if (months < 84)
                val years = months / 12
                val rem = months % 12
                if (rem >= 6) resolveUnit(years, year, locale, half)
                else resolveUnit(years, year, locale, "")
            else
                val years = months / 12
                resolveUnit(years, year, locale, "")
        }

    def formatStage(dateOfBirth: String, asOf: String = null, gender: String = null): Option[String] =
        val asOfOpt = Option(asOf)
        val genderOpt = Option(gender)
        parseAge(dateOfBirth, asOfOpt).map { age =>
            val label = stageKey(age.months) match
                case "newborn" => locale.stages.newborn
                case "infant" => locale.stages.infant
                case "toddler" => locale.stages.toddler
                case "child" => locale.stages.child
                case "teenager" => locale.stages.teenager
                case "adult" => locale.stages.adult
            label.resolve(genderOpt)
        }

object SayableAge:
    private lazy val defaultPt: SayableAge = new SayableAge(Locales.EN)

    def formatAge(dateOfBirth: String, asOf: String = null): Option[String] =
        defaultPt.formatAge(dateOfBirth, asOf)

    def formatStage(dateOfBirth: String, asOf: String = null, gender: String = null): Option[String] =
        defaultPt.formatStage(dateOfBirth, asOf, gender)

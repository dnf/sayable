package sayableduration

enum PluralCategory:
    case ZERO, ONE, TWO, FEW, MANY, OTHER

enum Compactness:
    case NORMAL, SHORT, COMPACT

case class UnitForms(
    simple: Option[String] = None,
    forms: Option[Map[PluralCategory, String]] = None
)

def simpleUnit(template: String): UnitForms = UnitForms(simple = Some(template))

def pluralUnit(forms: Map[PluralCategory, String]): UnitForms = UnitForms(forms = Some(forms))

case class Units(
    second: UnitForms,
    minute: UnitForms,
    hour: UnitForms,
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms
)

case class CompactnessOverride(
    second: Option[UnitForms] = None,
    minute: Option[UnitForms] = None,
    hour: Option[UnitForms] = None,
    day: Option[UnitForms] = None,
    week: Option[UnitForms] = None,
    month: Option[UnitForms] = None,
    year: Option[UnitForms] = None,
    half: Option[String] = None,
    delimiter: Option[String] = None,
    ago: Option[String] = None,
    inFuture: Option[String] = None
)

case class DurationLocale(
    code: String,
    plural: Int => PluralCategory,
    units: Units,
    half: String,
    delimiter: String,
    justNow: String,
    ago: String,
    inFuture: String,
    short: Option[CompactnessOverride] = None,
    compact: Option[CompactnessOverride] = None,
    formatNumber: Option[Int => String] = None,
    formatUnit: Option[(Int, String) => String] = None
)

/**
 * Formats a count with the given unit forms, locale, and optional half marker.
 *
 * The half template supports two placeholder styles:
 * - `{n}` modifies the formatted number before unit substitution (e.g. "1½ hours")
 * - `{0}` wraps the fully resolved expression after unit substitution (e.g. "1時間半")
 *
 * When a half marker is applied, the plural category is forced to
 * PluralCategory.OTHER (e.g. "1½ hours" not "1½ hour").
 */
def resolveUnit(count: Int, uf: UnitForms, locale: DurationLocale, half: String = ""): String =
    val baseN = locale.formatNumber match
        case Some(fn) => fn(count)
        case None => count.toString

    // Apply {n}-style half marker to the number
    val n = if (half.nonEmpty && half.contains("{n}"))
        half.replace("{n}", baseN)
    else
        baseN

    // Select template
    val template = uf.simple match
        case Some(s) => s
        case None =>
            // Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
            val cat = if (half.nonEmpty) PluralCategory.OTHER else locale.plural(count)
            uf.forms.flatMap(_.get(cat)).orElse(uf.forms.flatMap(_.get(PluralCategory.OTHER))).getOrElse("{n}")

    var result = template.replace("{n}", n)

    locale.formatUnit.foreach { fn =>
        result = fn(count, result)
    }

    // Apply {0}-style half marker (wraps the whole expression)
    if (half.nonEmpty && half.contains("{0}"))
        result = half.replace("{0}", result)

    result

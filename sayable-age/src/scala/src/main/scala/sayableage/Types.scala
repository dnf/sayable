package sayableage

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

case class CompactnessOverride(
    day: Option[UnitForms] = None,
    week: Option[UnitForms] = None,
    month: Option[UnitForms] = None,
    year: Option[UnitForms] = None,
    half: Option[String] = None,
    delimiter: Option[String] = None,
    justBorn: Option[String] = None
)

sealed trait StageLabel:
    def resolve(gender: Option[String] = None): String = this match
        case StageLabel.Neutral(label) => label
        case StageLabel.Gendered(m, f) => if (gender.contains("f")) f else m

object StageLabel:
    case class Neutral(label: String) extends StageLabel
    case class Gendered(m: String, f: String) extends StageLabel

def s(label: String): StageLabel.Neutral = StageLabel.Neutral(label)

def g(m: String, f: String): StageLabel.Gendered = StageLabel.Gendered(m, f)

case class Stages(
    newborn: StageLabel,
    infant: StageLabel,
    toddler: StageLabel,
    child: StageLabel,
    teenager: StageLabel,
    adult: StageLabel
)

case class Units(
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms
)

case class AgeLocale(
    code: String,
    plural: Int => PluralCategory,
    units: Units,
    half: String,
    delimiter: String,
    justBorn: String,
    stages: Stages,
    short: Option[CompactnessOverride] = None,
    compact: Option[CompactnessOverride] = None,
    formatNumber: Option[Int => String] = None,
    formatUnit: Option[(Int, String) => String] = None
)

package sayabledate

enum Compactness:
    case NORMAL, SHORT, COMPACT

case class CompactnessOverride(
    months: Option[List[String]] = None,
    monthsInDate: Option[List[String]] = None,
    weekdays: Option[List[String]] = None,
    dayFormat: Option[String] = None,
    dayFormatExceptions: Option[Map[String, String]] = None,
    datePattern: Option[String] = None,
    datePatternWithYear: Option[String] = None,
    today: Option[String] = None,
    tomorrow: Option[String] = None,
    yesterday: Option[String] = None
)

case class DateLocale(
    code: String,
    months: List[String],
    weekdays: List[String],
    dayFormat: String,
    dayFormatExceptions: Map[String, String] = Map.empty,
    datePattern: String = "{day} {month}",
    datePatternWithYear: String = "{day} {month} {year}",
    today: String = "today",
    tomorrow: String = "tomorrow",
    yesterday: String = "yesterday",
    dayAfterTomorrow: Option[String] = None,
    dayBeforeYesterday: Option[String] = None,
    thisWeekday: Option[String] = None,
    nextWeekday: Option[String] = None,
    lastWeekday: Option[String] = None,
    monthsInDate: Option[List[String]] = None,
    short: Option[CompactnessOverride] = None,
    compact: Option[CompactnessOverride] = None
)

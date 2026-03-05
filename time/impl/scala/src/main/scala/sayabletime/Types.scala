package sayabletime

enum Compactness:
    case NORMAL, SHORT, COMPACT

case class ClockConfig(
    hours: List[String],
    midnight: String,
    noon: String,
    patterns: Map[Int, String]
)

case class ShortClockConfig(
    use24h: Boolean,
    amPm: Option[(String, String)] = None,
    format: String
)

case class CompactnessOverride(
    clock: Option[ShortClockConfig] = None
)

case class TimeLocale(
    code: String,
    clock: ClockConfig,
    short: Option[CompactnessOverride] = None,
    compact: Option[CompactnessOverride] = None
)

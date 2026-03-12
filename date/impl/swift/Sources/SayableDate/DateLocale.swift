public enum Compactness: Sendable {
    case normal, short, compact
}

public struct CompactnessOverride: Sendable {
    public let months: [String]?
    public let monthsInDate: [String]?
    public let weekdays: [String]?
    public let dayFormat: String?
    public let dayFormatExceptions: [String: String]?
    public let datePattern: String?
    public let datePatternWithYear: String?
    public let today: String?
    public let tomorrow: String?
    public let yesterday: String?

    public init(months: [String]? = nil, monthsInDate: [String]? = nil,
                weekdays: [String]? = nil, dayFormat: String? = nil,
                dayFormatExceptions: [String: String]? = nil,
                datePattern: String? = nil, datePatternWithYear: String? = nil,
                today: String? = nil, tomorrow: String? = nil,
                yesterday: String? = nil) {
        self.months = months
        self.monthsInDate = monthsInDate
        self.weekdays = weekdays
        self.dayFormat = dayFormat
        self.dayFormatExceptions = dayFormatExceptions
        self.datePattern = datePattern
        self.datePatternWithYear = datePatternWithYear
        self.today = today
        self.tomorrow = tomorrow
        self.yesterday = yesterday
    }
}

public struct DateLocale: Sendable {
    public let code: String
    public let months: [String]
    public let weekdays: [String]
    public let dayFormat: String
    public let dayFormatExceptions: [String: String]
    public let datePattern: String
    public let datePatternWithYear: String
    public let today: String
    public let tomorrow: String
    public let yesterday: String
    public let dayAfterTomorrow: String?
    public let dayBeforeYesterday: String?
    public let thisWeekday: String?
    public let nextWeekday: String?
    public let lastWeekday: String?
    public let monthsInDate: [String]?
    public let short: CompactnessOverride?
    public let compact: CompactnessOverride?

    public init(code: String, months: [String], weekdays: [String],
                dayFormat: String, dayFormatExceptions: [String: String] = [:],
                datePattern: String = "{day} {month}",
                datePatternWithYear: String = "{day} {month} {year}",
                today: String = "today", tomorrow: String = "tomorrow",
                yesterday: String = "yesterday",
                dayAfterTomorrow: String? = nil, dayBeforeYesterday: String? = nil,
                thisWeekday: String? = nil, nextWeekday: String? = nil,
                lastWeekday: String? = nil, monthsInDate: [String]? = nil,
                short: CompactnessOverride? = nil, compact: CompactnessOverride? = nil) {
        self.code = code
        self.months = months
        self.weekdays = weekdays
        self.dayFormat = dayFormat
        self.dayFormatExceptions = dayFormatExceptions
        self.datePattern = datePattern
        self.datePatternWithYear = datePatternWithYear
        self.today = today
        self.tomorrow = tomorrow
        self.yesterday = yesterday
        self.dayAfterTomorrow = dayAfterTomorrow
        self.dayBeforeYesterday = dayBeforeYesterday
        self.thisWeekday = thisWeekday
        self.nextWeekday = nextWeekday
        self.lastWeekday = lastWeekday
        self.monthsInDate = monthsInDate
        self.short = short
        self.compact = compact
    }
}

public enum PluralCategory: Sendable {
    case zero, one, two, few, many, other
}

public enum Compactness: Sendable {
    case normal, short, compact
}

public enum UnitForms: Sendable {
    case simple(String)
    case plural([PluralCategory: String])
}

public struct Units: Sendable {
    public let second: UnitForms
    public let minute: UnitForms
    public let hour: UnitForms
    public let day: UnitForms
    public let week: UnitForms
    public let month: UnitForms
    public let year: UnitForms

    public init(second: UnitForms, minute: UnitForms, hour: UnitForms,
                day: UnitForms, week: UnitForms, month: UnitForms, year: UnitForms) {
        self.second = second
        self.minute = minute
        self.hour = hour
        self.day = day
        self.week = week
        self.month = month
        self.year = year
    }
}

public struct CompactnessOverride: Sendable {
    public let units: [String: UnitForms]?
    public let half: String?
    public let delimiter: String?
    public let ago: String?
    public let inFuture: String?

    public init(units: [String: UnitForms]? = nil, half: String? = nil,
                delimiter: String? = nil, ago: String? = nil, inFuture: String? = nil) {
        self.units = units
        self.half = half
        self.delimiter = delimiter
        self.ago = ago
        self.inFuture = inFuture
    }
}

public struct DurationLocale: Sendable {
    public let code: String
    public let plural: @Sendable (Int) -> PluralCategory
    public let units: Units
    public let half: String
    public let delimiter: String
    public let justNow: String
    public let ago: String
    public let inFuture: String
    public let short: CompactnessOverride?
    public let compact: CompactnessOverride?
    public let formatNumber: (@Sendable (Int) -> String)?
    public let formatUnit: (@Sendable (Int, String) -> String)?

    public init(code: String, plural: @escaping @Sendable (Int) -> PluralCategory,
                units: Units, half: String, delimiter: String, justNow: String,
                ago: String, inFuture: String,
                short: CompactnessOverride? = nil, compact: CompactnessOverride? = nil,
                formatNumber: (@Sendable (Int) -> String)? = nil,
                formatUnit: (@Sendable (Int, String) -> String)? = nil) {
        self.code = code
        self.plural = plural
        self.units = units
        self.half = half
        self.delimiter = delimiter
        self.justNow = justNow
        self.ago = ago
        self.inFuture = inFuture
        self.short = short
        self.compact = compact
        self.formatNumber = formatNumber
        self.formatUnit = formatUnit
    }
}

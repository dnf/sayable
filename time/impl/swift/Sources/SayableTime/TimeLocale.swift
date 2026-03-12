public enum Compactness: Sendable {
    case normal, short, compact
}

public struct ClockConfig: Sendable {
    public let hours: [String]
    public let midnight: String
    public let noon: String
    public let patterns: [Int: String]

    public init(hours: [String], midnight: String, noon: String, patterns: [Int: String]) {
        self.hours = hours
        self.midnight = midnight
        self.noon = noon
        self.patterns = patterns
    }
}

public struct ShortClockConfig: Sendable {
    public let use24h: Bool
    public let format: String
    public let amPm: (String, String)?

    public init(use24h: Bool, amPm: (String, String)? = nil, format: String) {
        self.use24h = use24h
        self.amPm = amPm
        self.format = format
    }
}

public struct CompactnessOverride: Sendable {
    public let clock: ShortClockConfig?

    public init(clock: ShortClockConfig? = nil) {
        self.clock = clock
    }
}

public struct TimeLocale: Sendable {
    public let code: String
    public let clock: ClockConfig
    public let short: CompactnessOverride?
    public let compact: CompactnessOverride?

    public init(code: String, clock: ClockConfig,
                short: CompactnessOverride? = nil, compact: CompactnessOverride? = nil) {
        self.code = code
        self.clock = clock
        self.short = short
        self.compact = compact
    }
}

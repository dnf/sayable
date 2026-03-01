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

public enum StageLabel: Sendable {
    case neutral(String)
    case gendered(m: String, f: String)

    public func resolve(_ gender: String?) -> String {
        switch self {
        case .neutral(let label):
            return label
        case .gendered(let m, let f):
            return gender == "f" ? f : m
        }
    }
}

public struct Units: Sendable {
    public let day: UnitForms
    public let week: UnitForms
    public let month: UnitForms
    public let year: UnitForms

    public init(day: UnitForms, week: UnitForms, month: UnitForms, year: UnitForms) {
        self.day = day
        self.week = week
        self.month = month
        self.year = year
    }
}

public struct Stages: Sendable {
    public let newborn: StageLabel
    public let infant: StageLabel
    public let toddler: StageLabel
    public let child: StageLabel
    public let teenager: StageLabel
    public let adult: StageLabel

    public init(newborn: StageLabel, infant: StageLabel, toddler: StageLabel,
                child: StageLabel, teenager: StageLabel, adult: StageLabel) {
        self.newborn = newborn
        self.infant = infant
        self.toddler = toddler
        self.child = child
        self.teenager = teenager
        self.adult = adult
    }
}

public struct CompactnessOverride: Sendable {
    public let day: UnitForms?
    public let week: UnitForms?
    public let month: UnitForms?
    public let year: UnitForms?
    public let half: String?
    public let delimiter: String?
    public let justBorn: String?

    public init(day: UnitForms? = nil, week: UnitForms? = nil,
                month: UnitForms? = nil, year: UnitForms? = nil,
                half: String? = nil, delimiter: String? = nil,
                justBorn: String? = nil) {
        self.day = day
        self.week = week
        self.month = month
        self.year = year
        self.half = half
        self.delimiter = delimiter
        self.justBorn = justBorn
    }
}

public struct AgeLocale: Sendable {
    public let code: String
    public let plural: @Sendable (Int) -> PluralCategory
    public let units: Units
    public let half: String
    public let delimiter: String
    public let justBorn: String
    public let stages: Stages
    public let shortOverride: CompactnessOverride?
    public let compactOverride: CompactnessOverride?
    public let formatNumber: (@Sendable (Int) -> String)?
    public let formatUnit: (@Sendable (Int, String) -> String)?

    public init(code: String, plural: @escaping @Sendable (Int) -> PluralCategory,
                units: Units, half: String, delimiter: String, justBorn: String,
                stages: Stages, shortOverride: CompactnessOverride? = nil,
                compactOverride: CompactnessOverride? = nil,
                formatNumber: (@Sendable (Int) -> String)? = nil,
                formatUnit: (@Sendable (Int, String) -> String)? = nil) {
        self.code = code
        self.plural = plural
        self.units = units
        self.half = half
        self.delimiter = delimiter
        self.justBorn = justBorn
        self.stages = stages
        self.shortOverride = shortOverride
        self.compactOverride = compactOverride
        self.formatNumber = formatNumber
        self.formatUnit = formatUnit
    }
}

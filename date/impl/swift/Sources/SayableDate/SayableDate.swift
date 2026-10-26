// String helpers (no Foundation dependency)
private func stringReplace(_ s: String, _ target: String, _ replacement: String) -> String {
    let sArr = Array(s.utf8)
    let tArr = Array(target.utf8)
    if tArr.isEmpty { return s }
    if tArr.count > sArr.count { return s }
    var result: [UInt8] = []
    let rArr = Array(replacement.utf8)
    var i = 0
    while i < sArr.count {
        if i + tArr.count <= sArr.count && sArr[i..<(i + tArr.count)].elementsEqual(tArr) {
            result.append(contentsOf: rArr)
            i += tArr.count
        } else {
            result.append(sArr[i])
            i += 1
        }
    }
    return String(decoding: result, as: UTF8.self)
}

public struct SayableDateFormatter: Sendable {

    public static let version = "0.5.0"

    private let locale: DateLocale
    private let compactness: Compactness
    private let months: [String]
    private let monthsInDate: [String]?
    private let weekdays: [String]
    private let dayFormat: String
    private let dayFormatExceptions: [String: String]
    private let datePattern: String
    private let datePatternWithYear: String
    private let todayLabel: String
    private let tomorrowLabel: String
    private let yesterdayLabel: String

    public init(_ locale: DateLocale, compactness: Compactness = .normal) {
        self.locale = locale
        self.compactness = compactness

        let ovr: CompactnessOverride? = {
            switch compactness {
            case .short: return locale.short
            case .compact: return locale.compact
            case .normal: return nil
            }
        }()

        self.months = ovr?.months ?? locale.months
        if ovr != nil && ovr!.dayFormat != nil && ovr!.dayFormatExceptions == nil {
            self.dayFormatExceptions = [:]
        } else {
            self.dayFormatExceptions = ovr?.dayFormatExceptions ?? locale.dayFormatExceptions
        }
        self.monthsInDate = ovr?.monthsInDate ?? locale.monthsInDate
        self.weekdays = ovr?.weekdays ?? locale.weekdays
        self.dayFormat = ovr?.dayFormat ?? locale.dayFormat
        self.datePattern = ovr?.datePattern ?? locale.datePattern
        self.datePatternWithYear = ovr?.datePatternWithYear ?? locale.datePatternWithYear
        self.todayLabel = ovr?.today ?? locale.today
        self.tomorrowLabel = ovr?.tomorrow ?? locale.tomorrow
        self.yesterdayLabel = ovr?.yesterday ?? locale.yesterday
    }

    // MARK: - Public API

    public func formatDate(_ date: String?) -> String? {
        guard let date, !date.isEmpty else { return nil }
        guard let (year, month, day) = Self.parseDateParts(date) else { return nil }
        return formatAbsolute(year: year, month: month, day: day, includeYear: false)
    }

    public func formatDateWithYear(_ date: String?) -> String? {
        guard let date, !date.isEmpty else { return nil }
        guard let (year, month, day) = Self.parseDateParts(date) else { return nil }
        return formatAbsolute(year: year, month: month, day: day, includeYear: true)
    }

    public func formatRelative(_ date: String?, asOf: String?) -> String? {
        guard let date, !date.isEmpty, let asOf, !asOf.isEmpty else { return nil }
        guard let (dy, dm, dd) = Self.parseDateParts(date) else { return nil }
        guard let (ay, am, ad) = Self.parseDateParts(asOf) else { return nil }

        let dateJdn = Self.toJdn(year: dy, month: dm, day: dd)
        let asofJdn = Self.toJdn(year: ay, month: am, day: ad)
        let diff = dateJdn - asofJdn

        // Today
        if diff == 0 { return todayLabel }

        // Tomorrow
        if diff == 1 { return tomorrowLabel }

        // Yesterday
        if diff == -1 { return yesterdayLabel }

        let isCompact = compactness == .compact

        // Day after tomorrow (optional)
        if diff == 2, let dat = locale.dayAfterTomorrow, !isCompact {
            return dat
        }

        // Day before yesterday (optional)
        if diff == -2, let dby = locale.dayBeforeYesterday, !isCompact {
            return dby
        }

        // Compact mode: skip weekday references, go straight to calendar date
        if isCompact {
            let includeYear = dy != ay
            return formatAbsolute(year: dy, month: dm, day: dd, includeYear: includeYear)
        }

        // This weekday (+2 to +6)
        if diff >= 2 && diff <= 6, let pattern = locale.thisWeekday {
            let dow = Self.weekday(year: dy, month: dm, day: dd)
            let weekdayName = weekdays[dow]
            return stringReplace(pattern, "{weekday}", weekdayName)
        }

        // Last weekday (-2 to -6)
        if diff >= -6 && diff <= -2, let pattern = locale.lastWeekday {
            let dow = Self.weekday(year: dy, month: dm, day: dd)
            let weekdayName = weekdays[dow]
            return stringReplace(pattern, "{weekday}", weekdayName)
        }

        // Next weekday (+7 to +13)
        if diff >= 7 && diff <= 13, let pattern = locale.nextWeekday {
            let dow = Self.weekday(year: dy, month: dm, day: dd)
            let weekdayName = weekdays[dow]
            return stringReplace(pattern, "{weekday}", weekdayName)
        }

        // Calendar fallback
        let includeYear = dy != ay
        return formatAbsolute(year: dy, month: dm, day: dd, includeYear: includeYear)
    }

    // MARK: - Private Helpers

    private func formatAbsolute(year: Int, month: Int, day: Int, includeYear: Bool) -> String {
        let dayStr = String(day)
        let fmt = dayFormatExceptions[dayStr] ?? dayFormat
        let formattedDay = stringReplace(fmt, "{n}", dayStr)

        let monthNames = monthsInDate ?? months
        let monthName = monthNames[month - 1]

        let pattern = includeYear ? datePatternWithYear : datePattern
        var result = stringReplace(pattern, "{month}", monthName)
        result = stringReplace(result, "{day}", formattedDay)
        result = stringReplace(result, "{d}", String(day))
        result = stringReplace(result, "{m}", String(month))
        if includeYear {
            result = stringReplace(result, "{year}", String(year))
            let yy = year % 100
            let yyStr = yy < 10 ? "0\(yy)" : String(yy)
            result = stringReplace(result, "{yy}", yyStr)
        }

        return result
    }

    /// YYYY-MM-DD naming a real calendar day, optionally followed by T and
    /// a time (only the date part is read).
    private static func parseDateParts(_ s: String) -> (Int, Int, Int)? {
        let chars = Array(s.utf8)
        let isDateOrDatetime = chars.count == 10 || (chars.count > 10 && chars[10] == 0x54)
        guard isDateOrDatetime, chars[4] == 0x2D, chars[7] == 0x2D else { return nil }
        let y = safeAtoi(chars, 0, 4)
        let m = safeAtoi(chars, 5, 7)
        let d = safeAtoi(chars, 8, 10)
        guard y >= 0, (1...12).contains(m), d >= 1, d <= daysInMonth(year: y, month: m) else { return nil }
        return (y, m, d)
    }

    private static func daysInMonth(year y: Int, month m: Int) -> Int {
        switch m {
        case 4, 6, 9, 11: return 30
        case 2: return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 ? 29 : 28
        default: return 31
        }
    }

    private static func safeAtoi(_ chars: [UInt8], _ from: Int, _ to: Int) -> Int {
        var n = 0
        for i in from..<to {
            let c = chars[i]
            guard c >= 0x30 && c <= 0x39 else { return -1 }
            n = n * 10 + Int(c - 0x30)
        }
        return n
    }

    private static func toJdn(year y: Int, month m: Int, day d: Int) -> Int {
        let a = (14 - m) / 12
        let adjustedY = y + 4800 - a
        let adjustedM = m + 12 * a - 3
        return d + (153 * adjustedM + 2) / 5 + 365 * adjustedY + adjustedY / 4 - adjustedY / 100 + adjustedY / 400 - 32045
    }

    private static func weekday(year: Int, month: Int, day: Int) -> Int {
        let jdn = toJdn(year: year, month: month, day: day)
        return (jdn + 1) % 7
    }

    // MARK: - Static Convenience

    private static let defaultFormatter = SayableDateFormatter(Locales.EN)

    public static func formatDateDefault(_ date: String?) -> String? {
        return defaultFormatter.formatDate(date)
    }

    public static func formatRelativeDefault(_ date: String?, asOf: String?) -> String? {
        return defaultFormatter.formatRelative(date, asOf: asOf)
    }
}

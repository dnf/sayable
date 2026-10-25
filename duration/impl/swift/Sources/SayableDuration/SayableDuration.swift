// String helpers (no Foundation dependency)
private func stringContains(_ haystack: String, _ needle: String) -> Bool {
    let h = Array(haystack.utf8)
    let n = Array(needle.utf8)
    if n.isEmpty { return true }
    if n.count > h.count { return false }
    for i in 0...(h.count - n.count) {
        if h[i..<(i + n.count)].elementsEqual(n) { return true }
    }
    return false
}

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

public struct SayableDurationFormatter: Sendable {

    public static let version = "0.5.0"
    /// 500 years, the same ceiling as sayable-age
    private static let maxDurationMonths = 6000

    private let locale: DurationLocale
    private let second: UnitForms
    private let minute: UnitForms
    private let hour: UnitForms
    private let day: UnitForms
    private let week: UnitForms
    private let month: UnitForms
    private let year: UnitForms
    private let half: String
    private let delimiter: String
    private let justNowLabel: String
    private let agoTemplate: String
    private let inFutureTemplate: String

    public init(_ locale: DurationLocale, compactness: Compactness = .normal) {
        self.locale = locale

        let ovr: CompactnessOverride? = {
            switch compactness {
            case .short: return locale.short
            case .compact: return locale.compact
            case .normal: return nil
            }
        }()

        let ovrUnits = ovr?.units

        self.second = ovrUnits?["second"] ?? locale.units.second
        self.minute = ovrUnits?["minute"] ?? locale.units.minute
        self.hour = ovrUnits?["hour"] ?? locale.units.hour
        self.day = ovrUnits?["day"] ?? locale.units.day
        self.week = ovrUnits?["week"] ?? locale.units.week
        self.month = ovrUnits?["month"] ?? locale.units.month
        self.year = ovrUnits?["year"] ?? locale.units.year
        self.half = ovr?.half ?? locale.half
        self.delimiter = ovr?.delimiter ?? locale.delimiter
        self.justNowLabel = locale.justNow
        self.agoTemplate = ovr?.ago ?? locale.ago
        self.inFutureTemplate = ovr?.inFuture ?? locale.inFuture
    }

    // MARK: - Public API

    public func formatDuration(_ startOrSeconds: Int?) -> String? {
        guard let seconds = startOrSeconds else { return nil }
        if seconds < 0 { return nil }
        return formatDurationSeconds(seconds)
    }

    public func formatDuration(start: String?, end: String?) -> String? {
        guard let start, !start.isEmpty, let end, !end.isEmpty else { return nil }
        guard let s = Self.parseIsoToSeconds(start) else { return nil }
        guard let e = Self.parseIsoToSeconds(end) else { return nil }
        let totalSeconds = abs(e - s)
        return formatDurationSeconds(totalSeconds)
    }

    public func formatSince(start: String?, asOf: String?) -> String? {
        guard let start, !start.isEmpty, let asOf, !asOf.isEmpty else { return nil }
        guard let s = Self.parseIsoToSeconds(start) else { return nil }
        guard let a = Self.parseIsoToSeconds(asOf) else { return nil }
        let diff = a - s
        if diff < 0 { return nil }
        if diff == 0 { return justNowLabel }
        guard let dur = formatDurationSeconds(diff) else { return nil }
        return stringReplace(agoTemplate, "{0}", dur)
    }

    public func formatUntil(target: String?, asOf: String?) -> String? {
        guard let target, !target.isEmpty, let asOf, !asOf.isEmpty else { return nil }
        guard let t = Self.parseIsoToSeconds(target) else { return nil }
        guard let a = Self.parseIsoToSeconds(asOf) else { return nil }
        let diff = t - a
        if diff < 0 { return nil }
        if diff == 0 { return justNowLabel }
        guard let dur = formatDurationSeconds(diff) else { return nil }
        return stringReplace(inFutureTemplate, "{0}", dur)
    }

    // MARK: - Private Helpers

    /// Months of 30.44 days (the average month), rounded.
    private static func approximateMonths(_ days: Int) -> Int {
        return roundToNearest(Double(days) / 30.44)
    }

    private func formatDurationSeconds(_ total: Int) -> String? {
        if Self.approximateMonths(total / 86400) > Self.maxDurationMonths { return nil }

        // 0 seconds
        if total == 0 { return justNowLabel }

        // 1-59 seconds
        if total < 60 {
            return resolveUnit(total, second, "")
        }

        let totalMinutes = total / 60
        let remainderSeconds = total % 60

        // 1-4 minutes: minutes + seconds
        if totalMinutes < 5 {
            var result = resolveUnit(totalMinutes, minute, "")
            if remainderSeconds > 0 {
                result += delimiter + resolveUnit(remainderSeconds, second, "")
            }
            return result
        }

        // 5-59 minutes
        if totalMinutes < 60 {
            return resolveUnit(totalMinutes, minute, "")
        }

        let totalHours = total / 3600
        let remainderMinutes = (total % 3600) / 60

        // 1-5 hours: hours + minutes (with half marker)
        if totalHours <= 5 {
            if remainderMinutes == 30 {
                return resolveUnit(totalHours, hour, half)
            }
            var result = resolveUnit(totalHours, hour, "")
            if remainderMinutes > 0 {
                result += delimiter + resolveUnit(remainderMinutes, minute, "")
            }
            return result
        }

        // 6-23 hours
        if totalHours < 24 {
            return resolveUnit(totalHours, hour, "")
        }

        let totalDays = total / 86400
        let remainderHours = (total % 86400) / 3600

        // 1-2 days: days + hours (with half marker)
        if totalDays <= 2 {
            if remainderHours == 12 {
                return resolveUnit(totalDays, day, half)
            }
            var result = resolveUnit(totalDays, day, "")
            if remainderHours > 0 {
                result += delimiter + resolveUnit(remainderHours, hour, "")
            }
            return result
        }

        // 3-6 days
        if totalDays < 7 {
            return resolveUnit(totalDays, day, "")
        }

        let totalWeeks = totalDays / 7
        let remainderDays = totalDays % 7

        // 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if totalDays < 30 {
            var result = resolveUnit(totalWeeks, week, "")
            if remainderDays > 0 {
                result += delimiter + resolveUnit(remainderDays, day, "")
            }
            return result
        }

        var totalMonths = Self.approximateMonths(totalDays)

        // 1-11 months
        if totalMonths < 12 {
            if totalMonths == 0 { totalMonths = 1 }
            return resolveUnit(totalMonths, month, "")
        }

        // 12+ months: years + months
        let totalYears = totalMonths / 12
        let remainderMonths = totalMonths % 12
        var result = resolveUnit(totalYears, year, "")
        if remainderMonths > 0 {
            result += delimiter + resolveUnit(remainderMonths, month, "")
        }
        return result
    }

    private func resolveUnit(_ count: Int, _ uf: UnitForms, _ halfMarker: String) -> String {
        let baseN: String
        if let fn = locale.formatNumber {
            baseN = fn(count)
        } else {
            baseN = String(count)
        }

        let n: String
        if !halfMarker.isEmpty && stringContains(halfMarker, "{n}") {
            n = stringReplace(halfMarker, "{n}", baseN)
        } else {
            n = baseN
        }

        let template: String
        switch uf {
        case .simple(let t):
            template = t
        case .plural(let forms):
            // Half-marked values use "other" plural (e.g., "1.5 hours" not "1.5 hour")
            let cat = halfMarker.isEmpty ? locale.plural(count) : PluralCategory.other
            template = forms[cat] ?? forms[.other] ?? "{n}"
        }

        var result = stringReplace(template, "{n}", n)

        if let fu = locale.formatUnit {
            result = fu(count, result)
        }

        if !halfMarker.isEmpty && stringContains(halfMarker, "{0}") {
            result = stringReplace(halfMarker, "{0}", result)
        }

        return result
    }

    private static func roundToNearest(_ value: Double) -> Int {
        let floor = Int(value)
        return (value - Double(floor)) >= 0.5 ? floor + 1 : floor
    }

    private static func isDigit(_ c: UInt8) -> Bool {
        return c >= 0x30 && c <= 0x39
    }

    /// The value of the digits in chars[from..<to], or nil if any isn't a digit.
    private static func digitsValue(_ chars: [UInt8], _ from: Int, _ to: Int) -> Int? {
        guard from >= 0, to <= chars.count, from < to else { return nil }
        var n = 0
        for i in from..<to {
            guard isDigit(chars[i]) else { return nil }
            n = n * 10 + Int(chars[i] - 0x30)
        }
        return n
    }

    /// Z or +HH:MM / -HH:MM (validated, never applied).
    private static func isZoneSuffix(_ chars: [UInt8], from f: Int) -> Bool {
        let count = chars.count - f
        if count == 1 { return chars[f] == 0x5A }
        return count == 6 && (chars[f] == 0x2B || chars[f] == 0x2D)
            && digitsValue(chars, f + 1, f + 3) != nil && chars[f + 3] == 0x3A
            && digitsValue(chars, f + 4, f + 6) != nil
    }

    /// YYYY-MM-DDTHH:MM (one- or two-digit hour), then optional :SS with
    /// optional .fraction, then an optional zone suffix that is ignored.
    private static func parseIsoToSeconds(_ isoStr: String) -> Int? {
        let chars = Array(isoStr.utf8)
        guard chars.count >= 15, chars[4] == 0x2D, chars[7] == 0x2D, chars[10] == 0x54,
              let year = digitsValue(chars, 0, 4), let month = digitsValue(chars, 5, 7),
              let day = digitsValue(chars, 8, 10) else { return nil }
        var p = 11
        while p < chars.count, p - 11 < 2, isDigit(chars[p]) { p += 1 }
        guard p > 11, p < chars.count, chars[p] == 0x3A,
              let hour = digitsValue(chars, 11, p),
              let minute = digitsValue(chars, p + 1, p + 3) else { return nil }
        p += 3
        var second = 0
        if p < chars.count, chars[p] == 0x3A, let s = digitsValue(chars, p + 1, p + 3) {
            second = s
            p += 3
            if p + 1 < chars.count, chars[p] == 0x2E, isDigit(chars[p + 1]) {
                p += 1
                while p < chars.count, isDigit(chars[p]) { p += 1 }
            }
        }
        guard p == chars.count || isZoneSuffix(chars, from: p) else { return nil }
        guard (1...12).contains(month), day >= 1, day <= daysInMonth(year: year, month: month) else { return nil }
        guard hour <= 23, minute <= 59, second <= 59 else { return nil }

        let days = daysSinceEpoch(year: year, month: month, day: day)
        return days * 86400 + hour * 3600 + minute * 60 + second
    }

    private static func isLeapYear(_ y: Int) -> Bool {
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }

    private static func daysInMonth(year y: Int, month m: Int) -> Int {
        switch m {
        case 1, 3, 5, 7, 8, 10, 12: return 31
        case 4, 6, 9, 11: return 30
        case 2: return isLeapYear(y) ? 29 : 28
        default: return 30
        }
    }

    private static func daysSinceEpoch(year: Int, month: Int, day: Int) -> Int {
        var days = 0
        if year >= 2000 {
            for y in 2000..<year {
                days += isLeapYear(y) ? 366 : 365
            }
        } else {
            for y in year..<2000 {
                days -= isLeapYear(y) ? 366 : 365
            }
        }
        for m in 1..<month {
            days += daysInMonth(year: year, month: m)
        }
        days += day - 1
        return days
    }

    // MARK: - Static Convenience

    private static let defaultFormatter = SayableDurationFormatter(Locales.EN)

    public static func formatDurationDefault(_ seconds: Int?) -> String? {
        return defaultFormatter.formatDuration(seconds)
    }

    public static func formatSinceDefault(start: String?, asOf: String?) -> String? {
        return defaultFormatter.formatSince(start: start, asOf: asOf)
    }

    public static func formatUntilDefault(target: String?, asOf: String?) -> String? {
        return defaultFormatter.formatUntil(target: target, asOf: asOf)
    }
}

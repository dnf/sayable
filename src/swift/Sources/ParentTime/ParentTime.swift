#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

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

public struct ParentTimeFormatter: Sendable {

    public static let version = "0.5.0"

    private static let maxAgeMonths = 6000

    private let locale: AgeLocale
    private let day: UnitForms
    private let week: UnitForms
    private let month: UnitForms
    private let year: UnitForms
    private let half: String
    private let delimiter: String
    private let justBornLabel: String

    // For testing: override the "now" date
    @usableFromInline
    nonisolated(unsafe) static var _timeNow: () -> (Int, Int, Int) = {
        var rawTime = time(nil)
        var timeInfo = localtime(&rawTime).pointee
        return (Int(timeInfo.tm_year) + 1900, Int(timeInfo.tm_mon) + 1, Int(timeInfo.tm_mday))
    }

    public init(_ locale: AgeLocale, compactness: Compactness = .normal) {
        self.locale = locale

        var d = locale.units.day
        var w = locale.units.week
        var m = locale.units.month
        var y = locale.units.year
        var h = locale.half
        var del = locale.delimiter
        var jb = locale.justBorn

        let ovr: CompactnessOverride? = {
            switch compactness {
            case .short: return locale.shortOverride
            case .compact: return locale.compactOverride
            case .normal: return nil
            }
        }()

        if let ovr = ovr {
            if let v = ovr.day { d = v }
            if let v = ovr.week { w = v }
            if let v = ovr.month { m = v }
            if let v = ovr.year { y = v }
            if let v = ovr.half { h = v }
            if let v = ovr.delimiter { del = v }
            if let v = ovr.justBorn { jb = v }
        }

        self.day = d
        self.week = w
        self.month = m
        self.year = y
        self.half = h
        self.delimiter = del
        self.justBornLabel = jb
    }

    private struct AgeComponents {
        let months: Int
        let diffDays: Int
    }

    private static func parseAge(_ dateOfBirth: String?, _ asOf: String?) -> AgeComponents? {
        guard let dob = dateOfBirth, !dob.isEmpty else { return nil }

        guard let dobParts = parseDateParts(dob) else { return nil }
        let (dobY, dobM, dobD) = dobParts

        let refY: Int, refM: Int, refD: Int
        if let asOf = asOf, !asOf.isEmpty {
            guard let refParts = parseDateParts(asOf) else { return nil }
            (refY, refM, refD) = refParts
        } else {
            (refY, refM, refD) = _timeNow()
        }

        let diffDays = daysBetween(y1: dobY, m1: dobM, d1: dobD, y2: refY, m2: refM, d2: refD)
        if diffDays < 0 { return nil }

        let lastDay = daysInMonth(year: refY, month: refM)
        let clampedBirthday = min(dobD, lastDay)
        var months = (refY - dobY) * 12 + (refM - dobM)
        if refD < clampedBirthday { months -= 1 }
        if months > maxAgeMonths { return nil }

        return AgeComponents(months: months, diffDays: diffDays)
    }

    private static func parseDateParts(_ s: String) -> (Int, Int, Int)? {
        let chars = Array(s.utf8)
        guard chars.count >= 10, chars[4] == 0x2D, chars[7] == 0x2D else { return nil }
        let y = safeAtoi(chars, 0, 4)
        let m = safeAtoi(chars, 5, 7)
        let d = safeAtoi(chars, 8, 10)
        guard y >= 0, m >= 0, d >= 0 else { return nil }
        guard !(y == 0 && m == 0 && d == 0) else { return nil }
        return (y, m, d)
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

    // Julian Day Number for accurate day-count between dates
    private static func julianDay(year y: Int, month m: Int, day d: Int) -> Int {
        let a = (14 - m) / 12
        let adjustedY = y + 4800 - a
        let adjustedM = m + 12 * a - 3
        return d + (153 * adjustedM + 2) / 5 + 365 * adjustedY + adjustedY / 4 - adjustedY / 100 + adjustedY / 400 - 32045
    }

    private static func daysBetween(y1: Int, m1: Int, d1: Int, y2: Int, m2: Int, d2: Int) -> Int {
        return julianDay(year: y2, month: m2, day: d2) - julianDay(year: y1, month: m1, day: d1)
    }

    private static func stageKey(_ months: Int) -> String {
        if months < 2 { return "newborn" }
        if months < 12 { return "infant" }
        if months < 36 { return "toddler" }
        if months < 156 { return "child" }
        if months < 216 { return "teenager" }
        return "adult"
    }

    private func resolveUnit(_ count: Int, _ uf: UnitForms, _ half: String) -> String {
        let baseN: String
        if let fn = locale.formatNumber {
            baseN = fn(count)
        } else {
            baseN = String(count)
        }

        let n: String
        if !half.isEmpty && stringContains(half, "{n}") {
            n = stringReplace(half, "{n}", baseN)
        } else {
            n = baseN
        }

        let template: String
        switch uf {
        case .simple(let t):
            template = t
        case .plural(let forms):
            let cat = locale.plural(count)
            template = forms[cat] ?? forms[.other] ?? "{n}"
        }

        var result = stringReplace(template, "{n}", n)

        if let fu = locale.formatUnit {
            result = fu(count, result)
        }

        if !half.isEmpty && stringContains(half, "{0}") {
            result = stringReplace(half, "{0}", result)
        }

        return result
    }

    public func formatAge(_ dateOfBirth: String?, _ asOf: String? = nil) -> String? {
        guard let age = Self.parseAge(dateOfBirth, asOf) else { return nil }

        let months = age.months
        let diffDays = age.diffDays

        // Tier 1: 0 days
        if diffDays == 0 { return justBornLabel }

        // Tier 1b: 1-6 days
        if diffDays < 7 { return resolveUnit(diffDays, day, "") }

        // Tier 2: weeks + days until 3 calendar months
        if months < 3 {
            let weeks = diffDays / 7
            let days = diffDays % 7
            var result = resolveUnit(weeks, week, "")
            if days > 0 {
                result += delimiter + resolveUnit(days, day, "")
            }
            return result
        }

        // Tier 3: 3-23 months
        if months < 24 { return resolveUnit(months, month, "") }

        // Tier 4: 24-35 months -> years + months
        if months < 36 {
            let years = months / 12
            let rem = months % 12
            if rem == 0 { return resolveUnit(years, year, "") }
            return resolveUnit(years, year, "") + delimiter + resolveUnit(rem, month, "")
        }

        // Tier 5: 3-6 years -> years with half marker
        if months < 84 {
            let years = months / 12
            let rem = months % 12
            if rem >= 6 {
                return resolveUnit(years, year, half)
            } else {
                return resolveUnit(years, year, "")
            }
        }

        // Tier 6: 7+ years
        let years = months / 12
        return resolveUnit(years, year, "")
    }

    public func formatStage(_ dateOfBirth: String?, _ asOf: String? = nil, gender: String? = nil) -> String? {
        guard let age = Self.parseAge(dateOfBirth, asOf) else { return nil }

        let label: StageLabel
        switch Self.stageKey(age.months) {
        case "newborn": label = locale.stages.newborn
        case "infant": label = locale.stages.infant
        case "toddler": label = locale.stages.toddler
        case "child": label = locale.stages.child
        case "teenager": label = locale.stages.teenager
        default: label = locale.stages.adult
        }

        return label.resolve(gender)
    }

    // Static convenience methods using default English locale
    private static let defaultFormatter = ParentTimeFormatter(Locales.EN)

    public static func formatAgeDefault(_ dateOfBirth: String?, _ asOf: String? = nil) -> String? {
        return defaultFormatter.formatAge(dateOfBirth, asOf)
    }

    public static func formatStageDefault(_ dateOfBirth: String?, _ asOf: String? = nil, gender: String? = nil) -> String? {
        return defaultFormatter.formatStage(dateOfBirth, asOf, gender: gender)
    }
}

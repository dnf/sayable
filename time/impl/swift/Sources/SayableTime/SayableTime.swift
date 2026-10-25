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

public struct SayableTimeFormatter: Sendable {

    public static let version = "0.5.0"

    private let locale: TimeLocale
    private let compactness: Compactness
    private let shortClock: ShortClockConfig?

    public init(_ locale: TimeLocale, compactness: Compactness = .normal) {
        self.locale = locale
        self.compactness = compactness

        let ovr: CompactnessOverride? = {
            switch compactness {
            case .short: return locale.short
            case .compact: return locale.compact
            case .normal: return nil
            }
        }()

        self.shortClock = ovr?.clock
    }

    // MARK: - Public API

    public func formatTime(_ inputStr: String?) -> String? {
        guard let inputStr, !inputStr.isEmpty else { return nil }
        guard let (hour, minute) = Self.parseTime(inputStr) else { return nil }

        if compactness != .normal, let sc = shortClock {
            return formatDigital(hour: hour, minute: minute, config: sc)
        }
        return formatNatural(hour: hour, minute: minute)
    }

    // MARK: - Private Helpers

    private func formatNatural(hour: Int, minute: Int) -> String {
        let clock = locale.clock
        var rounded = Self.roundTo5(minute)
        var h = hour
        if rounded == 60 {
            rounded = 0
            h = (h + 1) % 24
        }
        if rounded == 0 {
            if h == 0 { return clock.midnight }
            if h == 12 { return clock.noon }
        }
        let h12 = h % 12
        let nextH12 = (h + 1) % 12
        let hName = clock.hours[h12]
        let nextHName = clock.hours[nextH12]
        let pattern = clock.patterns[rounded] ?? clock.patterns[0] ?? "{h}"
        var result = stringReplace(pattern, "{h}", hName)
        result = stringReplace(result, "{next_h}", nextHName)
        return result
    }

    private func formatDigital(hour: Int, minute: Int, config sc: ShortClockConfig) -> String {
        let fmt = sc.format
        if sc.use24h {
            var result = stringReplace(fmt, "{h}", String(hour))
            let mm = minute < 10 ? "0\(minute)" : String(minute)
            result = stringReplace(result, "{mm}", mm)
            return result
        }
        var h12 = hour % 12
        if h12 == 0 { h12 = 12 }
        let amPm = sc.amPm ?? ("AM", "PM")
        let ampmStr = hour < 12 ? amPm.0 : amPm.1
        var result = stringReplace(fmt, "{h}", String(h12))
        let mm = minute < 10 ? "0\(minute)" : String(minute)
        result = stringReplace(result, "{mm}", mm)
        result = stringReplace(result, "{ampm}", ampmStr)
        return result
    }

    /// A clock time alone, or after the T of an ISO datetime whose date part
    /// is a real calendar day.
    private static func parseTime(_ inputStr: String) -> (Int, Int)? {
        let chars = Array(inputStr.utf8)
        guard let tIdx = chars.firstIndex(of: 0x54) else { return parseClock(chars[...]) }
        guard isRealDate(chars[..<tIdx]) else { return nil }
        return parseClock(chars[(tIdx + 1)...])
    }

    private static func isDigit(_ c: UInt8) -> Bool {
        return c >= 0x30 && c <= 0x39
    }

    /// The value of the digits in chars[from..<to], or nil if any isn't a digit.
    private static func digitsValue(_ chars: ArraySlice<UInt8>, _ from: Int, _ to: Int) -> Int? {
        guard from >= chars.startIndex, to <= chars.endIndex, from < to else { return nil }
        var n = 0
        for i in from..<to {
            guard isDigit(chars[i]) else { return nil }
            n = n * 10 + Int(chars[i] - 0x30)
        }
        return n
    }

    /// YYYY-MM-DD naming a real calendar day.
    private static func isRealDate(_ chars: ArraySlice<UInt8>) -> Bool {
        let f = chars.startIndex
        guard chars.count == 10, chars[f + 4] == 0x2D, chars[f + 7] == 0x2D,
              let y = digitsValue(chars, f, f + 4), let m = digitsValue(chars, f + 5, f + 7),
              let d = digitsValue(chars, f + 8, f + 10) else { return false }
        return (1...12).contains(m) && d >= 1 && d <= daysInMonth(year: y, month: m)
    }

    private static func daysInMonth(year y: Int, month m: Int) -> Int {
        switch m {
        case 4, 6, 9, 11: return 30
        case 2: return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 ? 29 : 28
        default: return 31
        }
    }

    /// Z or +HH:MM / -HH:MM (validated, never applied).
    private static func isZoneSuffix(_ chars: ArraySlice<UInt8>) -> Bool {
        let f = chars.startIndex
        if chars.count == 1 { return chars[f] == 0x5A }
        return chars.count == 6 && (chars[f] == 0x2B || chars[f] == 0x2D)
            && digitsValue(chars, f + 1, f + 3) != nil && chars[f + 3] == 0x3A
            && digitsValue(chars, f + 4, f + 6) != nil
    }

    /// H:MM or HH:MM, then optional :SS with optional .fraction, then an
    /// optional zone suffix.
    private static func parseClock(_ chars: ArraySlice<UInt8>) -> (Int, Int)? {
        var p = chars.startIndex
        while p < chars.endIndex, p - chars.startIndex < 2, isDigit(chars[p]) { p += 1 }
        guard p > chars.startIndex, p < chars.endIndex, chars[p] == 0x3A,
              let hour = digitsValue(chars, chars.startIndex, p),
              let minute = digitsValue(chars, p + 1, p + 3) else { return nil }
        p += 3
        var second = 0
        if p < chars.endIndex, chars[p] == 0x3A, let s = digitsValue(chars, p + 1, p + 3) {
            second = s
            p += 3
            if p + 1 < chars.endIndex, chars[p] == 0x2E, isDigit(chars[p + 1]) {
                p += 1
                while p < chars.endIndex, isDigit(chars[p]) { p += 1 }
            }
        }
        guard p == chars.endIndex || isZoneSuffix(chars[p...]) else { return nil }
        guard hour <= 23, minute <= 59, second <= 59 else { return nil }
        return (hour, minute)
    }

    private static func roundTo5(_ minute: Int) -> Int {
        return ((minute + 2) / 5) * 5
    }

    // MARK: - Static Convenience

    private static let defaultFormatter = SayableTimeFormatter(Locales.EN)

    public static func formatTimeDefault(_ inputStr: String?) -> String? {
        return defaultFormatter.formatTime(inputStr)
    }
}

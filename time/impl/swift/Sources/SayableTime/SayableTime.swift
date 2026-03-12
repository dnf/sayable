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

    private static func parseTime(_ inputStr: String) -> (Int, Int)? {
        var t = inputStr
        // Handle ISO datetime
        if let tIdx = t.firstIndex(of: "T") {
            t = String(t[t.index(after: tIdx)...])
        }
        // Strip timezone
        if let plusIdx = t.firstIndex(of: "+") {
            t = String(t[..<plusIdx])
        }
        if let zIdx = t.firstIndex(of: "Z") {
            t = String(t[..<zIdx])
        }
        let parts = t.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: false).map(String.init)
        guard parts.count >= 2 else { return nil }
        guard let hour = Int(parts[0]), let minute = Int(parts[1].split(separator: ".").first ?? "") else { return nil }
        guard hour >= 0, hour <= 23, minute >= 0, minute <= 59 else { return nil }
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

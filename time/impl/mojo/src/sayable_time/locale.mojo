"""Locale definitions for clock time formatting."""


struct ClockConfig(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Natural language clock reading configuration."""

    var hour0: String
    var hour1: String
    var hour2: String
    var hour3: String
    var hour4: String
    var hour5: String
    var hour6: String
    var hour7: String
    var hour8: String
    var hour9: String
    var hour10: String
    var hour11: String
    var midnight: String
    var noon: String
    var pattern0: String
    var pattern5: String
    var pattern10: String
    var pattern15: String
    var pattern20: String
    var pattern25: String
    var pattern30: String
    var pattern35: String
    var pattern40: String
    var pattern45: String
    var pattern50: String
    var pattern55: String

    fn __init__(
        out self,
        hour0: String = "",
        hour1: String = "",
        hour2: String = "",
        hour3: String = "",
        hour4: String = "",
        hour5: String = "",
        hour6: String = "",
        hour7: String = "",
        hour8: String = "",
        hour9: String = "",
        hour10: String = "",
        hour11: String = "",
        midnight: String = "",
        noon: String = "",
        pattern0: String = "",
        pattern5: String = "",
        pattern10: String = "",
        pattern15: String = "",
        pattern20: String = "",
        pattern25: String = "",
        pattern30: String = "",
        pattern35: String = "",
        pattern40: String = "",
        pattern45: String = "",
        pattern50: String = "",
        pattern55: String = "",
    ):
        self.hour0 = hour0
        self.hour1 = hour1
        self.hour2 = hour2
        self.hour3 = hour3
        self.hour4 = hour4
        self.hour5 = hour5
        self.hour6 = hour6
        self.hour7 = hour7
        self.hour8 = hour8
        self.hour9 = hour9
        self.hour10 = hour10
        self.hour11 = hour11
        self.midnight = midnight
        self.noon = noon
        self.pattern0 = pattern0
        self.pattern5 = pattern5
        self.pattern10 = pattern10
        self.pattern15 = pattern15
        self.pattern20 = pattern20
        self.pattern25 = pattern25
        self.pattern30 = pattern30
        self.pattern35 = pattern35
        self.pattern40 = pattern40
        self.pattern45 = pattern45
        self.pattern50 = pattern50
        self.pattern55 = pattern55

    fn get_hour(self, idx: Int) -> String:
        """Get hour name by index (0-11)."""
        if idx == 0: return self.hour0
        if idx == 1: return self.hour1
        if idx == 2: return self.hour2
        if idx == 3: return self.hour3
        if idx == 4: return self.hour4
        if idx == 5: return self.hour5
        if idx == 6: return self.hour6
        if idx == 7: return self.hour7
        if idx == 8: return self.hour8
        if idx == 9: return self.hour9
        if idx == 10: return self.hour10
        return self.hour11

    fn get_pattern(self, bucket: Int) -> String:
        """Get pattern by five-minute bucket (0, 5, 10, ..., 55)."""
        if bucket == 0: return self.pattern0
        if bucket == 5: return self.pattern5
        if bucket == 10: return self.pattern10
        if bucket == 15: return self.pattern15
        if bucket == 20: return self.pattern20
        if bucket == 25: return self.pattern25
        if bucket == 30: return self.pattern30
        if bucket == 35: return self.pattern35
        if bucket == 40: return self.pattern40
        if bucket == 45: return self.pattern45
        if bucket == 50: return self.pattern50
        return self.pattern55


struct ShortClockConfig(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Digital clock display configuration for short/compact modes."""

    var use24h: Bool
    var format: String
    var has_am_pm: Bool
    var am: String
    var pm: String

    fn __init__(
        out self,
        use24h: Bool = False,
        format: String = "",
        has_am_pm: Bool = False,
        am: String = "",
        pm: String = "",
    ):
        self.use24h = use24h
        self.format = format
        self.has_am_pm = has_am_pm
        self.am = am
        self.pm = pm


struct CompactnessOverride(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Optional overrides for short/compact display modes."""

    var clock: ShortClockConfig
    var has_clock: Bool

    fn __init__(out self):
        self.clock = ShortClockConfig()
        self.has_clock = False


struct TimeLocale(Copyable, Movable, ImplicitlyCopyable, ImplicitlyDestructible):
    """Locale definition for clock time formatting."""

    var code: String
    var clock: ClockConfig
    var short_override: CompactnessOverride
    var has_short: Bool
    var compact_override: CompactnessOverride
    var has_compact: Bool

    fn __init__(
        out self,
        code: String = "",
        clock: ClockConfig = ClockConfig(),
        short_override: CompactnessOverride = CompactnessOverride(),
        has_short: Bool = False,
        compact_override: CompactnessOverride = CompactnessOverride(),
        has_compact: Bool = False,
    ):
        self.code = code
        self.clock = clock
        self.short_override = short_override
        self.has_short = has_short
        self.compact_override = compact_override
        self.has_compact = has_compact


fn _str_replace(s: String, old: String, new: String) -> String:
    """Replace first occurrence of old with new in s."""
    var idx = s.find(old)
    if idx == -1:
        return s
    return s[:idx] + new + s[idx + len(old) :]

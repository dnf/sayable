package sayabletime

/**
 * Defines all locale-specific data for time formatting.
 */
class TimeLocale {
    final String code
    final ClockConfig clock
    final CompactnessOverride shortOverride
    final CompactnessOverride compactOverride

    TimeLocale(
        String code,
        ClockConfig clock,
        CompactnessOverride shortOverride = null,
        CompactnessOverride compactOverride = null
    ) {
        this.code = code
        this.clock = clock
        this.shortOverride = shortOverride
        this.compactOverride = compactOverride
    }
}

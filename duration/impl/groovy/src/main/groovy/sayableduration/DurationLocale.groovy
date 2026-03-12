package sayableduration

/**
 * Defines all locale-specific data for duration formatting.
 */
class DurationLocale {
    final String code
    final Closure<PluralCategory> plural
    final Units units
    final String half
    final String delimiter
    final String justNow
    final String ago
    final String inFuture
    final CompactnessOverride shortOverride
    final CompactnessOverride compactOverride
    final Closure<String> formatNumber
    final Closure<String> formatUnit

    DurationLocale(
        String code,
        Closure<PluralCategory> plural,
        Units units,
        String half,
        String delimiter,
        String justNow,
        String ago,
        String inFuture,
        CompactnessOverride shortOverride = null,
        CompactnessOverride compactOverride = null,
        Closure<String> formatNumber = null,
        Closure<String> formatUnit = null
    ) {
        this.code = code
        this.plural = plural
        this.units = units
        this.half = half
        this.delimiter = delimiter
        this.justNow = justNow
        this.ago = ago
        this.inFuture = inFuture
        this.shortOverride = shortOverride
        this.compactOverride = compactOverride
        this.formatNumber = formatNumber
        this.formatUnit = formatUnit
    }
}

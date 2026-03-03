package parenttime

import groovy.transform.Immutable
import java.util.function.IntFunction
import java.util.function.IntUnaryOperator

/**
 * Defines all locale-specific data for age formatting.
 */
class AgeLocale {
    final String code
    final Closure<PluralCategory> plural
    final Units units
    final String half
    final String delimiter
    final String justBorn
    final Stages stages
    final CompactnessOverride shortOverride
    final CompactnessOverride compactOverride
    final Closure<String> formatNumber
    final Closure<String> formatUnit

    AgeLocale(
        String code,
        Closure<PluralCategory> plural,
        Units units,
        String half,
        String delimiter,
        String justBorn,
        Stages stages,
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
        this.justBorn = justBorn
        this.stages = stages
        this.shortOverride = shortOverride
        this.compactOverride = compactOverride
        this.formatNumber = formatNumber
        this.formatUnit = formatUnit
    }
}

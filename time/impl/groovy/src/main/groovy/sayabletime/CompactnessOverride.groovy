package sayabletime

import groovy.transform.Immutable

/**
 * Holds optional overrides for short/compact display modes.
 */
@Immutable
class CompactnessOverride {
    ShortClockConfig clock
}

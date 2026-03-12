package sayabletime

import groovy.transform.Immutable

/**
 * Digital clock display configuration for short/compact modes.
 */
@Immutable
class ShortClockConfig {
    boolean use24h
    String[] amPm
    String format
}

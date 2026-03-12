package sayabletime

import groovy.transform.Immutable

/**
 * Natural language clock reading configuration.
 */
@Immutable
class ClockConfig {
    List<String> hours
    String midnight
    String noon
    Map<Integer, String> patterns
}

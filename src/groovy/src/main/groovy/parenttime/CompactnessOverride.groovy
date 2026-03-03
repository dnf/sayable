package parenttime

import groovy.transform.Immutable

/**
 * Holds optional overrides for short/compact display modes.
 * Null fields mean "use the base locale value."
 */
@Immutable
class CompactnessOverride {
    UnitForms day
    UnitForms week
    UnitForms month
    UnitForms year
    String half
    String delimiter
    String justBorn
}

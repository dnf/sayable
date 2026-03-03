package parenttime

import groovy.transform.Immutable

/**
 * Unit containers for all four time units.
 */
@Immutable
class Units {
    UnitForms day
    UnitForms week
    UnitForms month
    UnitForms year
}

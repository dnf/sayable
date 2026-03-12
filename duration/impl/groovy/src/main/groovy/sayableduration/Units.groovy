package sayableduration

import groovy.transform.Immutable

/**
 * Unit containers for all seven time units.
 */
@Immutable
class Units {
    UnitForms second
    UnitForms minute
    UnitForms hour
    UnitForms day
    UnitForms week
    UnitForms month
    UnitForms year
}

package sayableage

import groovy.transform.Immutable

/**
 * A stage label that may be gender-neutral or have masculine/feminine variants.
 */
@Immutable
class StageLabel {
    String label
    String m
    String f

    static StageLabel neutral(String label) {
        new StageLabel(label: label)
    }

    static StageLabel gendered(String m, String f) {
        new StageLabel(m: m, f: f)
    }

    boolean isGendered() {
        m != null
    }

    String resolve(String gender = null) {
        if (isGendered()) {
            return gender == 'f' ? f : m
        }
        return label
    }
}

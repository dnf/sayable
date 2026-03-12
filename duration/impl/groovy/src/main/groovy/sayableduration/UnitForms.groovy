package sayableduration

import groovy.transform.Immutable

/**
 * Unit display template(s).
 * Use {@link #simpleUnit} for languages with no plural forms,
 * {@link #pluralUnit} for plural-aware forms.
 */
@Immutable
class UnitForms {
    String simple
    Map<PluralCategory, String> forms

    static UnitForms simpleUnit(String template) {
        new UnitForms(simple: template)
    }

    static UnitForms pluralUnit(Map<PluralCategory, String> forms) {
        new UnitForms(forms: forms)
    }
}

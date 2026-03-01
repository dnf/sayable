package parenttime;

import java.util.Map;

public record UnitForms(String simple, Map<PluralCategory, String> forms) {

    public static UnitForms simpleUnit(String template) {
        return new UnitForms(template, null);
    }

    public static UnitForms pluralUnit(Map<PluralCategory, String> forms) {
        return new UnitForms(null, forms);
    }
}

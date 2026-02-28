package parenttime

/**
 * CLDR-inspired plural categories.
 */
public enum class PluralCategory {
    ZERO, ONE, TWO, FEW, MANY, OTHER
}

/**
 * Controls the verbosity of formatted output.
 */
public enum class Compactness {
    NORMAL, SHORT, COMPACT
}

/**
 * Unit display template(s).
 * Use [simpleUnit] for languages with no plural forms, [pluralUnit] for plural-aware forms.
 */
public data class UnitForms(
    val simple: String? = null,
    val forms: Map<PluralCategory, String>? = null
)

/**
 * Creates a UnitForms with a single template for all counts.
 */
public fun simpleUnit(template: String): UnitForms = UnitForms(simple = template)

/**
 * Creates a UnitForms with per-category templates.
 * The map must include at least the [PluralCategory.OTHER] key.
 */
public fun pluralUnit(forms: Map<PluralCategory, String>): UnitForms = UnitForms(forms = forms)

/**
 * Holds optional overrides for short/compact display modes.
 * Null fields mean "use the base locale value."
 */
public data class CompactnessOverride(
    val day: UnitForms? = null,
    val week: UnitForms? = null,
    val month: UnitForms? = null,
    val year: UnitForms? = null,
    val half: String? = null,
    val delimiter: String? = null,
    val justBorn: String? = null
)

/**
 * Developmental stage labels.
 */
public data class Stages(
    val newborn: String,
    val infant: String,
    val toddler: String,
    val child: String,
    val teenager: String,
    val adult: String
)

/**
 * Unit containers for all four time units.
 */
public data class Units(
    val day: UnitForms,
    val week: UnitForms,
    val month: UnitForms,
    val year: UnitForms
)

/**
 * Defines all locale-specific data for age formatting.
 */
public data class AgeLocale(
    val code: String,
    val plural: (Int) -> PluralCategory,
    val units: Units,
    val half: String,
    val delimiter: String,
    val justBorn: String,
    val stages: Stages,
    val short: CompactnessOverride? = null,
    val compact: CompactnessOverride? = null,
    val formatNumber: ((Int) -> String)? = null,
    val formatUnit: ((Int, String) -> String)? = null
)

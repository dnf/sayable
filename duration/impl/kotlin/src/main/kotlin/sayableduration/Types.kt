package sayableduration

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
 * Unit containers for all seven time units.
 */
public data class Units(
    val second: UnitForms,
    val minute: UnitForms,
    val hour: UnitForms,
    val day: UnitForms,
    val week: UnitForms,
    val month: UnitForms,
    val year: UnitForms
)

/**
 * Holds optional overrides for short/compact display modes.
 * Null fields mean "use the base locale value."
 */
public data class CompactnessOverride(
    val second: UnitForms? = null,
    val minute: UnitForms? = null,
    val hour: UnitForms? = null,
    val day: UnitForms? = null,
    val week: UnitForms? = null,
    val month: UnitForms? = null,
    val year: UnitForms? = null,
    val half: String? = null,
    val delimiter: String? = null,
    val ago: String? = null,
    val inFuture: String? = null
)

/**
 * Defines all locale-specific data for duration formatting.
 */
public data class DurationLocale(
    val code: String,
    val plural: (Int) -> PluralCategory,
    val units: Units,
    val half: String,
    val delimiter: String,
    val justNow: String,
    val ago: String,
    val inFuture: String,
    val short: CompactnessOverride? = null,
    val compact: CompactnessOverride? = null,
    val formatNumber: ((Int) -> String)? = null,
    val formatUnit: ((Int, String) -> String)? = null
)

/**
 * Formats a count with the given unit forms, locale, and optional half marker.
 *
 * The half template supports two placeholder styles:
 * - `{n}` modifies the formatted number before unit substitution (e.g. "1½ hours")
 * - `{0}` wraps the fully resolved expression after unit substitution (e.g. "1時間半")
 *
 * When a half marker is applied, the plural category is forced to
 * [PluralCategory.OTHER] (e.g. "1½ hours" not "1½ hour").
 */
public fun resolveUnit(count: Int, uf: UnitForms, locale: DurationLocale, half: String = ""): String {
    val baseN = if (locale.formatNumber != null) {
        locale.formatNumber.invoke(count)
    } else {
        count.toString()
    }

    // Apply {n}-style half marker to the number
    val n = if (half.isNotEmpty() && half.contains("{n}")) {
        half.replace("{n}", baseN)
    } else {
        baseN
    }

    // Select template
    val template = if (uf.simple != null) {
        uf.simple
    } else {
        // Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
        val cat = if (half.isNotEmpty()) PluralCategory.OTHER else locale.plural(count)
        uf.forms?.get(cat) ?: uf.forms?.get(PluralCategory.OTHER) ?: "{n}"
    }

    var result = template.replace("{n}", n)

    if (locale.formatUnit != null) {
        result = locale.formatUnit.invoke(count, result)
    }

    // Apply {0}-style half marker (wraps the whole expression)
    if (half.isNotEmpty() && half.contains("{0}")) {
        result = half.replace("{0}", result)
    }

    return result
}

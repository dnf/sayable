"""Kotlin locale emitter for sayable-duration — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.kotlin.plural_rules import get_kt_plural

HEADER = make_header("codegen/targets/kotlin/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory.ZERO", "one": "PluralCategory.ONE",
    "two": "PluralCategory.TWO", "few": "PluralCategory.FEW",
    "many": "PluralCategory.MANY", "other": "PluralCategory.OTHER",
}

# Duration has 7 unit names
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]} to {_quote(unit[cat])}")
    return "pluralUnit(mapOf(" + ", ".join(pairs) + "))"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.kt file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayableduration.locales\n"]
    lines.append("import sayableduration.*\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-duration.")
    lines.append(" */")
    lines.append("public object Locales {\n")

    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        # One builder function per locale keeps Locales.<clinit> under the
        # JVM's 64KB method size limit.
        builder = f"build{code.capitalize()}"
        lines.append(f"    public val {uc}: DurationLocale = {builder}()")
        lines.append("")
        lines.append(f"    private fun {builder}(): DurationLocale = DurationLocale(")
        lines.append(f"        code = {_quote(code)},")

        # Plural
        plural = get_kt_plural(rule)
        lines.append(f"        plural = {plural},")

        # Units
        lines.append("        units = Units(")
        for unit_name in _UNIT_NAMES:
            val = _unit_forms(data["units"][unit_name])
            lines.append(f"            {unit_name} = {val},")
        lines.append("        ),")

        # Simple fields
        lines.append(f"        half = {_quote(data['half'])},")
        lines.append(f"        delimiter = {_quote(data['delimiter'])},")
        lines.append(f"        justNow = {_quote(data['justNow'])},")
        lines.append(f"        ago = {_quote(data['ago'])},")
        lines.append(f"        inFuture = {_quote(data['inFuture'])},")

        # Short/compact
        for mode in ("short", "compact"):
            if mode in data:
                ovr = data[mode]
                lines.append(f"        {mode} = CompactnessOverride(")
                if "units" in ovr:
                    for unit_name in _UNIT_NAMES:
                        if unit_name in ovr["units"]:
                            val = ovr["units"][unit_name]
                            if isinstance(val, str):
                                lines.append(f"            {unit_name} = simpleUnit({_quote(val)}),")
                            else:
                                lines.append(f"            {unit_name} = {_unit_forms(val)},")
                if "delimiter" in ovr:
                    lines.append(f"            delimiter = {_quote(ovr['delimiter'])},")
                if "half" in ovr:
                    lines.append(f"            half = {_quote(ovr['half'])},")
                if "ago" in ovr:
                    lines.append(f"            ago = {_quote(ovr['ago'])},")
                if "inFuture" in ovr:
                    lines.append(f"            inFuture = {_quote(ovr['inFuture'])},")
                lines.append("        ),")

        lines.append("    )")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # ALL map
    lines.append("")
    lines.append("    public val ALL: Map<String, DurationLocale> = mapOf(")
    # Format in rows of 5
    entries = [f'"{loc["code"]}" to {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 5):
        chunk = ", ".join(entries[i : i + 5])
        comma = "," if i + 5 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    )")

    # get() method
    lines.append("")
    lines.append("    public fun get(code: String): DurationLocale? = ALL[code]")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "kotlin", "src", "main", "kotlin", "sayableduration", "locales", "Locales.kt")

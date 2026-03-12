"""Groovy locale emitter — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.groovy.plural_rules import get_groovy_plural

HEADER = make_header("codegen/targets/groovy/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory.ZERO", "one": "PluralCategory.ONE",
    "two": "PluralCategory.TWO", "few": "PluralCategory.FEW",
    "many": "PluralCategory.MANY", "other": "PluralCategory.OTHER",
}


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms.simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"({_CAT_MAP[cat]}): {_quote(unit[cat])}")
    return "UnitForms.pluralUnit([" + ", ".join(pairs) + "])"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"StageLabel.neutral({_quote(stage)})"
    return f"StageLabel.gendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.groovy file with all locales.

    Each locale is initialized in its own private static factory method
    to avoid the JVM 64KB method size limit on the static initializer
    (<clinit>). The ALL map is likewise built via per-letter helper
    methods. With 168+ locales, Groovy closures generate enough bytecode
    to exceed the limit if everything is inlined into <clinit>.
    """
    from collections import OrderedDict

    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayableage.locales\n"]
    lines.append("import sayableage.*\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-age.")
    lines.append(" */")
    lines.append("class Locales {\n")

    # Emit public static fields — each delegates to a factory method
    # so <clinit> contains only simple method calls.
    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        uc = code.upper()

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")
        lines.append(f"    static final AgeLocale {uc} = _{uc.lower()}()")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # Emit private factory methods — one per locale
    for data in sorted_locs:
        code = data["code"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append("")
        lines.append(f"    private static AgeLocale _{uc.lower()}() {{")
        lines.append(f"        new AgeLocale(")
        lines.append(f"            {_quote(code)},")

        # Plural
        plural = get_groovy_plural(rule)
        lines.append(f"            {plural},")

        # Units
        lines.append("            new Units(")
        for unit_name in ("day", "week", "month", "year"):
            val = _unit_forms(data["units"][unit_name])
            lines.append(f"                {val},")
        lines.append("            ),")

        # Simple fields
        lines.append(f"            {_quote(data['half'])},")
        lines.append(f"            {_quote(data['delimiter'])},")
        lines.append(f"            {_quote(data['justBorn'])},")

        # Stages
        lines.append("            new Stages(")
        for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
            val = _stage_label(data["stages"][stage])
            lines.append(f"                {val},")
        lines.append("            ),")

        # Short/compact
        if "short" in data:
            _emit_compactness_override(lines, data["short"], indent=12)
        else:
            lines.append("            null,")

        if "compact" in data:
            _emit_compactness_override(lines, data["compact"], indent=12)
        else:
            lines.append("            null,")

        # formatNumber, formatUnit
        lines.append("            null,")
        lines.append("            null")

        lines.append("        )")
        lines.append("    }")

    # Group locales by first letter for separate ALL-map builder methods
    # to avoid the 64KB method limit on <clinit>.
    groups: OrderedDict[str, list[dict]] = OrderedDict()
    for loc in sorted_locs:
        letter = loc["code"][0].upper()
        groups.setdefault(letter, []).append(loc)

    for letter, locs in groups.items():
        lines.append("")
        lines.append(f"    private static Map<String, AgeLocale> _locales{letter}() {{")
        lines.append("        [")
        entries = [f"({_quote(loc['code'])}): {loc['code'].upper()}" for loc in locs]
        for i in range(0, len(entries), 3):
            chunk = ", ".join(entries[i : i + 3])
            comma = "," if i + 3 < len(entries) else ""
            lines.append(f"            {chunk}{comma}")
        lines.append("        ]")
        lines.append("    }")

    # ALL map — combine all groups
    lines.append("")
    group_calls = " + ".join(f"_locales{letter}()" for letter in groups)
    lines.append(f"    static final Map<String, AgeLocale> ALL = Collections.unmodifiableMap({group_calls})")

    # get() method
    lines.append("")
    lines.append("    static AgeLocale get(String code) { ALL[code] }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def _emit_compactness_override(lines: list[str], ovr: dict, indent: int = 8) -> None:
    pad = " " * indent
    inner = " " * (indent + 4)
    lines.append(f"{pad}new CompactnessOverride(")
    # Build all 7 fields: day, week, month, year, half, delimiter, justBorn
    fields: list[str] = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            if isinstance(val, str):
                fields.append(f"UnitForms.simpleUnit({_quote(val)})")
            else:
                fields.append(_unit_forms(val))
        else:
            fields.append("null")
    for key in ("half", "delimiter", "justBorn"):
        if key in ovr:
            fields.append(_quote(ovr[key]))
        else:
            fields.append("null")
    for j, field in enumerate(fields):
        comma = "," if j < len(fields) - 1 else ""
        lines.append(f"{inner}{field}{comma}")
    lines.append(f"{pad}),")


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "groovy", "src", "main", "groovy", "sayableage", "locales", "Locales.groovy")

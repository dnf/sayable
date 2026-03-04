"""Java locale emitter — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.java.plural_rules import (
    get_java_named_methods,
    get_java_plural,
    is_simple_plural,
)

HEADER = make_header("codegen/targets/java/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory.ZERO", "one": "PluralCategory.ONE",
    "two": "PluralCategory.TWO", "few": "PluralCategory.FEW",
    "many": "PluralCategory.MANY", "other": "PluralCategory.OTHER",
}


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms.simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]}, {_quote(unit[cat])}")
    # Use Map.of() for up to 10 entries (all our cases are ≤ 6)
    return "UnitForms.pluralUnit(Map.of(" + ", ".join(pairs) + "))"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"StageLabel.neutral({_quote(stage)})"
    return f"StageLabel.gendered({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.java file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    # Collect which named methods we need
    needed_methods: dict[str, str] = {}
    all_named = get_java_named_methods()
    for data in sorted_locs:
        rule = data["pluralRule"]
        if not is_simple_plural(rule) and rule in all_named:
            needed_methods[rule] = all_named[rule]

    lines = [HEADER, "package sayableage.locales;\n"]
    lines.append("import java.util.Map;")
    lines.append("import java.util.LinkedHashMap;")
    lines.append("import java.util.Collections;\n")
    lines.append("import sayableage.*;\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-age.")
    lines.append(" */")
    lines.append("@SuppressWarnings({\"LineLength\", \"MethodLength\"})")
    lines.append("public final class Locales {\n")
    lines.append("    private Locales() {}")

    # Emit named plural methods
    for rule in sorted(needed_methods.keys()):
        lines.append("")
        lines.append(needed_methods[rule])

    # Emit locale constants
    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append("")
        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        lines.append(f"    public static final AgeLocale {uc} = new AgeLocale(")
        lines.append(f"        {_quote(code)},")

        # Plural
        plural = get_java_plural(rule)
        lines.append(f"        {plural},")

        # Units
        unit_names = ("day", "week", "month", "year")
        lines.append("        new Units(")
        for j, unit_name in enumerate(unit_names):
            val = _unit_forms(data["units"][unit_name])
            comma = "," if j < len(unit_names) - 1 else ""
            lines.append(f"            {val}{comma}")
        lines.append("        ),")

        # Simple fields
        lines.append(f"        {_quote(data['half'])},")
        lines.append(f"        {_quote(data['delimiter'])},")
        lines.append(f"        {_quote(data['justBorn'])},")

        # Stages
        stage_names = ("newborn", "infant", "toddler", "child", "teenager", "adult")
        lines.append("        new Stages(")
        for j, stage in enumerate(stage_names):
            val = _stage_label(data["stages"][stage])
            comma = "," if j < len(stage_names) - 1 else ""
            lines.append(f"            {val}{comma}")
        lines.append("        ),")

        # Short/compact
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            _emit_compactness_override(lines, data["short"], trailing_comma=True)
        else:
            lines.append("        null,")

        if has_compact:
            _emit_compactness_override(lines, data["compact"], trailing_comma=True)
        else:
            lines.append("        null,")

        # formatNumber, formatUnit
        lines.append("        null,")
        lines.append("        null")

        lines.append("    );")

    # ALL map
    lines.append("")
    lines.append("    public static final Map<String, AgeLocale> ALL;")
    lines.append("    static {")
    lines.append(f"        Map<String, AgeLocale> map = new LinkedHashMap<>({len(sorted_locs)});")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'        map.put("{code}", {uc});')
    lines.append("        ALL = Collections.unmodifiableMap(map);")
    lines.append("    }")

    # get() method
    lines.append("")
    lines.append("    public static AgeLocale get(String code) {")
    lines.append("        return ALL.get(code);")
    lines.append("    }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def _emit_compactness_override(lines: list[str], ovr: dict, trailing_comma: bool = True) -> None:
    lines.append("        new CompactnessOverride(")
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
        lines.append(f"            {field}{comma}")
    tc = "," if trailing_comma else ""
    lines.append(f"        ){tc}")


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "java", "src", "main", "java", "sayableage", "locales", "Locales.java")

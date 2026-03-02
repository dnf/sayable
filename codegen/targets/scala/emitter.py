"""Scala locale emitter — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.scala.plural_rules import get_scala_plural

HEADER = make_header("codegen/targets/scala/emitter.py")

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
        return f"simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]} -> {_quote(unit[cat])}")
    return "pluralUnit(Map(" + ", ".join(pairs) + "))"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"s({_quote(stage)})"
    return f"g({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.scala file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package parenttime\n"]
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for parent-time.")
    lines.append(" */")
    lines.append("object Locales {\n")

    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        lines.append(f"    val {uc}: AgeLocale = AgeLocale(")
        lines.append(f"        code = {_quote(code)},")

        # Plural
        plural = get_scala_plural(rule)
        lines.append(f"        plural = {plural},")

        # Units
        lines.append("        units = Units(")
        for unit_name in ("day", "week", "month", "year"):
            val = _unit_forms(data["units"][unit_name])
            lines.append(f"            {unit_name} = {val},")
        lines.append("        ),")

        # Simple fields
        lines.append(f"        half = {_quote(data['half'])},")
        lines.append(f"        delimiter = {_quote(data['delimiter'])},")
        lines.append(f"        justBorn = {_quote(data['justBorn'])},")

        # Stages
        lines.append("        stages = Stages(")
        for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
            val = _stage_label(data["stages"][stage])
            lines.append(f"            {stage} = {val},")
        lines.append("        ),")

        # Short/compact
        for mode in ("short", "compact"):
            if mode in data:
                ovr = data[mode]
                lines.append(f"        {mode} = Some(CompactnessOverride(")
                if "units" in ovr:
                    for unit_name in ("day", "week", "month", "year"):
                        if unit_name in ovr["units"]:
                            val = ovr["units"][unit_name]
                            if isinstance(val, str):
                                lines.append(f"            {unit_name} = Some(simpleUnit({_quote(val)})),")
                            else:
                                lines.append(f"            {unit_name} = Some({_unit_forms(val)}),")
                if "delimiter" in ovr:
                    lines.append(f"            delimiter = Some({_quote(ovr['delimiter'])}),")
                if "half" in ovr:
                    lines.append(f"            half = Some({_quote(ovr['half'])}),")
                if "justBorn" in ovr:
                    lines.append(f"            justBorn = Some({_quote(ovr['justBorn'])}),")
                lines.append("        )),")

        lines.append("    )")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # ALL map
    lines.append("")
    lines.append("    val ALL: Map[String, AgeLocale] = Map(")
    # Format in rows of 5
    entries = [f'"{loc["code"]}" -> {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 5):
        chunk = ", ".join(entries[i : i + 5])
        comma = "," if i + 5 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    )")

    # get() method
    lines.append("")
    lines.append("    def get(code: String): Option[AgeLocale] = ALL.get(code)")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "scala", "src", "main", "scala", "parenttime", "Locales.scala")

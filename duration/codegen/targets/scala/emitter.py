"""Scala locale emitter for sayable-duration — single file with all locales.

Splits locales into private batch objects to avoid the JVM 64KB method limit,
then delegates from the public Locales object.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.scala.plural_rules import get_scala_plural

HEADER = make_header("codegen/targets/scala/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory.ZERO", "one": "PluralCategory.ONE",
    "two": "PluralCategory.TWO", "few": "PluralCategory.FEW",
    "many": "PluralCategory.MANY", "other": "PluralCategory.OTHER",
}

# Duration has 7 unit names
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")

# Split locales into batches to keep each <clinit> under the 64KB JVM limit
_BATCH_SIZE = 18


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


def _emit_locale(data: dict, indent: str) -> list[str]:
    """Emit a single locale val declaration."""
    lines = []
    code = data["code"]
    name = data["name"]
    rule = data["pluralRule"]
    uc = code.upper()

    lines.append(f"{indent}{locale_source_comment(code).rstrip()}")
    lines.append(f"{indent}// ================================================================")
    lines.append(f"{indent}// {uc} — {name}")
    lines.append(f"{indent}// ================================================================")

    lines.append(f"{indent}val {uc}: DurationLocale = DurationLocale(")
    lines.append(f"{indent}    code = {_quote(code)},")

    # Plural
    plural = get_scala_plural(rule)
    lines.append(f"{indent}    plural = {plural},")

    # Units
    lines.append(f"{indent}    units = Units(")
    for unit_name in _UNIT_NAMES:
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"{indent}        {unit_name} = {val},")
    lines.append(f"{indent}    ),")

    # Simple fields
    lines.append(f"{indent}    half = {_quote(data['half'])},")
    lines.append(f"{indent}    delimiter = {_quote(data['delimiter'])},")
    lines.append(f"{indent}    justNow = {_quote(data['justNow'])},")
    lines.append(f"{indent}    ago = {_quote(data['ago'])},")
    lines.append(f"{indent}    inFuture = {_quote(data['inFuture'])},")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"{indent}    {mode} = Some(CompactnessOverride(")
            if "units" in ovr:
                for unit_name in _UNIT_NAMES:
                    if unit_name in ovr["units"]:
                        val = ovr["units"][unit_name]
                        if isinstance(val, str):
                            lines.append(f"{indent}        {unit_name} = Some(simpleUnit({_quote(val)})),")
                        else:
                            lines.append(f"{indent}        {unit_name} = Some({_unit_forms(val)}),")
            if "delimiter" in ovr:
                lines.append(f"{indent}        delimiter = Some({_quote(ovr['delimiter'])}),")
            if "half" in ovr:
                lines.append(f"{indent}        half = Some({_quote(ovr['half'])}),")
            if "ago" in ovr:
                lines.append(f"{indent}        ago = Some({_quote(ovr['ago'])}),")
            if "inFuture" in ovr:
                lines.append(f"{indent}        inFuture = Some({_quote(ovr['inFuture'])}),")
            lines.append(f"{indent}    )),")

    lines.append(f"{indent})")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.scala file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayableduration.locales\n"]
    lines.append("import sayableduration._\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-duration.")
    lines.append(" */")

    # Split into batches
    batches: list[list[dict]] = []
    for i in range(0, len(sorted_locs), _BATCH_SIZE):
        batches.append(sorted_locs[i : i + _BATCH_SIZE])

    # Emit private batch objects
    for bi, batch in enumerate(batches):
        lines.append(f"private object Batch{bi} {{")
        for j, data in enumerate(batch):
            lines.extend(_emit_locale(data, "    "))
            if j < len(batch) - 1:
                lines.append("")
        lines.append("}")
        lines.append("")

    # Emit public Locales object with delegating vals
    lines.append("object Locales {\n")
    for bi, batch in enumerate(batches):
        for data in batch:
            uc = data["code"].upper()
            lines.append(f"    val {uc}: DurationLocale = Batch{bi}.{uc}")
    lines.append("")

    # ALL map
    lines.append("    val ALL: Map[String, DurationLocale] = Map(")
    entries = [f'"{loc["code"]}" -> {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 5):
        chunk = ", ".join(entries[i : i + 5])
        comma = "," if i + 5 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    )")

    # get() method
    lines.append("")
    lines.append("    def get(code: String): Option[DurationLocale] = ALL.get(code)")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "scala", "src", "main", "scala", "sayableduration", "locales", "Locales.scala")

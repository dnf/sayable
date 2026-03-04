"""Swift locale emitter — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.swift.plural_rules import (
    get_swift_named_methods,
    get_swift_plural,
    is_simple_plural,
)

HEADER = make_header("codegen/targets/swift/emitter.py")

_CAT_MAP = {
    "zero": ".zero", "one": ".one",
    "two": ".two", "few": ".few",
    "many": ".many", "other": ".other",
}


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f".simple({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]}: {_quote(unit[cat])}")
    return ".plural([" + ", ".join(pairs) + "])"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f".neutral({_quote(stage)})"
    return f".gendered(m: {_quote(stage['m'])}, f: {_quote(stage['f'])})"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.swift file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    # Collect which named methods we need
    needed_methods: dict[str, str] = {}
    all_named = get_swift_named_methods()
    for data in sorted_locs:
        rule = data["pluralRule"]
        if not is_simple_plural(rule) and rule in all_named:
            needed_methods[rule] = all_named[rule]

    lines = [HEADER]
    lines.append("// swiftlint:disable file_length")
    lines.append("")
    lines.append("/// All %d locale definitions for sayable-age." % len(all_locales))
    lines.append("public enum Locales {")

    # Emit named plural functions
    for rule in sorted(needed_methods.keys()):
        lines.append("")
        lines.append(needed_methods[rule])

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append("")
        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        lines.append(f"    public static let {uc} = AgeLocale(")
        lines.append(f"        code: {_quote(code)},")

        # Plural
        plural = get_swift_plural(rule)
        lines.append(f"        plural: {plural},")

        # Units
        unit_names = ("day", "week", "month", "year")
        lines.append("        units: Units(")
        for j, unit_name in enumerate(unit_names):
            val = _unit_forms(data["units"][unit_name])
            comma = "," if j < len(unit_names) - 1 else ""
            lines.append(f"            {unit_name}: {val}{comma}")
        lines.append("        ),")

        # Simple fields
        lines.append(f"        half: {_quote(data['half'])},")
        lines.append(f"        delimiter: {_quote(data['delimiter'])},")
        lines.append(f"        justBorn: {_quote(data['justBorn'])},")

        # Stages
        stage_names = ("newborn", "infant", "toddler", "child", "teenager", "adult")
        lines.append("        stages: Stages(")
        for j, stage in enumerate(stage_names):
            val = _stage_label(data["stages"][stage])
            comma = "," if j < len(stage_names) - 1 else ""
            lines.append(f"            {stage}: {val}{comma}")
        lines.append("        ),")

        # Short/compact
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            _emit_compactness_override(lines, "shortOverride", data["short"], trailing_comma=True)
        else:
            lines.append("        shortOverride: nil,")

        if has_compact:
            _emit_compactness_override(lines, "compactOverride", data["compact"], trailing_comma=False)
        else:
            lines.append("        compactOverride: nil")

        lines.append("    )")

    # all dictionary
    lines.append("")
    lines.append("    public static let all: [String: AgeLocale] = [")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'        "{code}": {uc},')
    lines.append("    ]")

    # get() method
    lines.append("")
    lines.append("    public static func get(_ code: String) -> AgeLocale? {")
    lines.append("        return all[code]")
    lines.append("    }")

    lines.append("}")
    lines.append("")
    lines.append("// swiftlint:enable file_length")
    lines.append("")

    return "\n".join(lines)


def _emit_compactness_override(lines: list[str], label: str, ovr: dict, trailing_comma: bool = True) -> None:
    lines.append(f"        {label}: CompactnessOverride(")
    # Build all 7 fields: day, week, month, year, half, delimiter, justBorn
    fields: list[tuple[str, str]] = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            if isinstance(val, str):
                fields.append((unit_name, f".simple({_quote(val)})"))
            else:
                fields.append((unit_name, _unit_forms(val)))
        else:
            fields.append((unit_name, "nil"))
    for key in ("half", "delimiter", "justBorn"):
        if key in ovr:
            fields.append((key, _quote(ovr[key])))
        else:
            fields.append((key, "nil"))
    for j, (name, field) in enumerate(fields):
        comma = "," if j < len(fields) - 1 else ""
        lines.append(f"            {name}: {field}{comma}")
    tc = "," if trailing_comma else ""
    lines.append(f"        ){tc}")


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "swift", "Sources", "SayableAge", "Locales", "Locales.swift")

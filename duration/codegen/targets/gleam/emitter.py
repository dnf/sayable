"""Gleam locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.gleam.plural_rules import get_gleam_plural

HEADER = make_header("codegen/targets/gleam/emitter.py")


def _module_name(code: str) -> str:
    """Convert locale code to Gleam module name (lowercase, hyphens to underscores)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"types.SimpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            gleam_cat = f"types.{cat.capitalize()}"
            pairs.append(f"#({gleam_cat}, {_quote(unit[cat])})")
    return "types.PluralUnit([" + ", ".join(pairs) + "])"


def _build_compactness(ovr: dict, indent: str) -> str:
    inner = indent + "  "
    parts = []
    if "units" in ovr:
        parts.append(f"{inner}units: Ok([")
        for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
            if unit_name in ovr["units"]:
                val = _unit_forms(ovr["units"][unit_name])
                parts.append(f"{inner}  #({_quote(unit_name)}, {val}),")
        parts.append(f"{inner}]),")
    else:
        parts.append(f"{inner}units: Error(Nil),")
    for field in ("half", "delimiter", "ago", "in_future"):
        json_key = {"half": "half", "delimiter": "delimiter", "ago": "ago", "in_future": "inFuture"}[field]
        if json_key in ovr:
            parts.append(f"{inner}{field}: Ok({_quote(ovr[json_key])}),")
        else:
            parts.append(f"{inner}{field}: Error(Nil),")
    return "\n".join(parts)


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    mod = _module_name(code)

    lines = [HEADER + locale_source_comment(code)]
    lines.append("import sayableduration/types")
    lines.append("")
    lines.append("pub fn locale() -> types.DurationLocale {")
    lines.append("  types.DurationLocale(")

    # Code
    lines.append(f"    code: {_quote(code)},")

    # Plural
    plural = get_gleam_plural(rule)
    lines.append(f"    plural: {plural},")

    # Units
    lines.append("    units: [")
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"      #({_quote(unit_name)}, {val}),")
    lines.append("    ],")

    # Simple fields
    lines.append(f"    half: {_quote(data['half'])},")
    lines.append(f"    delimiter: {_quote(data['delimiter'])},")
    lines.append(f"    just_now: {_quote(data['justNow'])},")
    lines.append(f"    ago: {_quote(data['ago'])},")
    lines.append(f"    in_future: {_quote(data['inFuture'])},")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            lines.append(f"    {mode}: Ok(types.CompactnessOverride(")
            lines.append(_build_compactness(data[mode], "    "))
            lines.append("    )),")
        else:
            lines.append(f"    {mode}: Error(Nil),")

    lines.append("  )")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the locales module with get(code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("import sayableduration/types")

    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"import sayableduration/locales/{mod} as locale_{mod}")
    lines.append("")

    lines.append("pub fn get(code: String) -> Result(types.DurationLocale, Nil) {")
    lines.append("  case code {")
    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f"    {_quote(code)} -> Ok(locale_{mod}.locale())")
    lines.append("    _ -> Error(Nil)")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = code.replace("-", "_")
    return os.path.join(root, "impl", "gleam", "src", "sayableduration", "locales", f"{mod}.gleam")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "gleam", "src", "sayableduration", "locales", "locales.gleam")

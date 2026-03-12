"""V locale emitter for sayable-duration.

V requires module names to match directory names and doesn't support
importing parent modules from subdirectories. Generated locale files
live in a `locales/` subdirectory with `module locales`. Type definitions
are duplicated in `locales/types.v` to avoid circular imports.

The main formatter in the parent directory provides the public API
and formatter logic.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.v.plural_rules import get_v_plural

HEADER = make_header("codegen/targets/v/emitter.py", line_prefix="// ")


def _quote(s: str) -> str:
    """Quote a string for V."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    """Emit a UnitForms value."""
    if isinstance(unit, str):
        return f"simple_unit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"PluralCategory.{cat}: {_quote(unit[cat])}")
    return "plural_unit({" + ", ".join(pairs) + "})"


def emit_locale(data: dict) -> str:
    """Generate a V locale file from canonical JSON."""
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    safe_code = code.replace("-", "_")

    lines = [HEADER + locale_source_comment(code, line_prefix="// ")]
    lines.append(f"// {name} locale.")
    lines.append("module locales\n")

    # Plural function
    plural_body = get_v_plural(rule)
    lines.append(f"fn plural_{safe_code}(n int) PluralCategory {{")
    for pline in plural_body.split("\n"):
        if pline.startswith("fn "):
            continue
        if pline == "}":
            continue
        lines.append(pline)
    lines.append("}\n")

    # Locale constant
    lines.append(f"pub const locale_{safe_code} = DurationLocale{{")
    lines.append(f"\tcode: {_quote(code)}")
    lines.append(f"\tplural: plural_{safe_code}")

    # Units (7 time units)
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        lines.append(f"\t{unit_name}: {_unit_forms(data['units'][unit_name])}")

    # Simple fields
    lines.append(f"\thalf: {_quote(data['half'])}")
    lines.append(f"\tdelimiter: {_quote(data['delimiter'])}")
    lines.append(f"\tjust_now: {_quote(data['justNow'])}")
    lines.append(f"\tago: {_quote(data['ago'])}")
    lines.append(f"\tin_future: {_quote(data['inFuture'])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            field = "short_override" if mode == "short" else "compact_override"
            has_field = "has_short" if mode == "short" else "has_compact"
            lines.append(f"\t{has_field}: true")
            parts = []
            if "units" in ovr:
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        parts.append(f"\t\t{unit_name}: {val}")
                        parts.append(f"\t\thas_{unit_name}: true")
            if "half" in ovr:
                parts.append(f"\t\thalf: {_quote(ovr['half'])}")
                parts.append("\t\thas_half: true")
            if "delimiter" in ovr:
                parts.append(f"\t\tdelimiter: {_quote(ovr['delimiter'])}")
                parts.append("\t\thas_delimiter: true")
            if "ago" in ovr:
                parts.append(f"\t\tago: {_quote(ovr['ago'])}")
                parts.append("\t\thas_ago: true")
            if "inFuture" in ovr:
                parts.append(f"\t\tin_future: {_quote(ovr['inFuture'])}")
                parts.append("\t\thas_in_future: true")
            lines.append(f"\t{field}: DurationCompactnessOverride{{")
            lines.extend(parts)
            lines.append("\t}")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate registry.v with get_duration_locale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("// Locale registry for all supported languages.")
    lines.append("module locales\n")

    lines.append("pub fn get_duration_locale(code string) ?DurationLocale {")
    lines.append("\treturn match code {")
    for loc in sorted_locs:
        code = loc["code"]
        safe_code = code.replace("-", "_")
        lines.append(f"\t\t{_quote(code)} {{ locale_{safe_code} }}")
    lines.append("\t\telse { none }")
    lines.append("\t}")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", f"locale_{code.replace('-', '_')}.v")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "v", "locales", "registry.v")

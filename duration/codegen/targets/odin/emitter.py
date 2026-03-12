"""Odin locale emitter for sayable-duration — single file with all locales.

Odin's package system equates directories with packages. The generated locale
file lives in the main package directory as the language-idiomatic equivalent.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.odin.plural_rules import get_odin_plural

HEADER = make_header("codegen/targets/odin/emitter.py")

_ODIN_KEYWORDS = frozenset([
    "auto_cast", "bit_set", "break", "case", "cast", "context", "continue",
    "defer", "distinct", "do", "dynamic", "else", "enum", "fallthrough",
    "for", "foreign", "if", "import", "in", "map", "matrix", "not_in",
    "or_else", "or_return", "package", "proc", "return", "struct", "switch",
    "transmute", "typeid", "union", "using", "when", "where",
])


def _ident(name: str) -> str:
    if name in _ODIN_KEYWORDS or (name and name[0].isdigit()):
        return f'`{name}`'
    return name


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f'Duration_Unit_Forms{{simple = {_quote(unit)}, forms = nil}}'
    cats = ["zero", "one", "two", "few", "many", "other"]
    parts = []
    for cat in cats:
        if cat in unit:
            parts.append(f"{cat} = {_quote(unit[cat])}")
        else:
            parts.append(f"{cat} = nil")
    return "Duration_Unit_Forms{simple = nil, forms = Duration_Plural_Forms{" + ", ".join(parts) + "}}"


def _compactness_override(ovr: dict) -> str:
    parts = []
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            parts.append(f"        {unit_name} = {_unit_forms(val)},")
        else:
            parts.append(f"        {unit_name} = nil,")
    if "half" in ovr:
        parts.append(f"        half = {_quote(ovr['half'])},")
    else:
        parts.append("        half = nil,")
    if "delimiter" in ovr:
        parts.append(f"        delimiter = {_quote(ovr['delimiter'])},")
    else:
        parts.append("        delimiter = nil,")
    if "ago" in ovr:
        parts.append(f"        ago = {_quote(ovr['ago'])},")
    else:
        parts.append("        ago = nil,")
    if "inFuture" in ovr:
        parts.append(f"        in_future = {_quote(ovr['inFuture'])},")
    else:
        parts.append("        in_future = nil,")
    return "Duration_Compactness_Override{\n" + "\n".join(parts) + "\n    }"


def emit_all(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("package sayableduration")
    lines.append("")

    # Collect unique plural rules
    rules_used: dict[str, str] = {}
    for data in sorted_locs:
        rule = data["pluralRule"]
        if rule not in rules_used:
            rules_used[rule] = get_odin_plural(rule)

    # Emit plural rule functions
    for rule_name, body in sorted(rules_used.items()):
        fn_name = f"plural_{rule_name}"
        lines.append(f"{fn_name} :: proc(n: int) -> Duration_Plural_Category {{")
        for line in body.split("\n"):
            stripped = line.strip()
            if stripped:
                lines.append(f"    {stripped}")
        lines.append("}")
        lines.append("")

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        rule = data["pluralRule"]
        fn_name = f"plural_{rule}"
        var_name = "locale_" + code.replace("-", "_")

        lines.append(locale_source_comment(code).rstrip())
        lines.append(f"{_ident(var_name)} : Duration_Locale = {{")
        lines.append(f"    code = {_quote(code)},")
        lines.append(f"    plural = {fn_name},")

        # Units
        lines.append("    units = {")
        for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
            val = _unit_forms(data["units"][unit_name])
            lines.append(f"        {unit_name} = {val},")
        lines.append("    },")

        # Simple fields
        lines.append(f"    half = {_quote(data['half'])},")
        lines.append(f"    delimiter = {_quote(data['delimiter'])},")
        lines.append(f"    just_now = {_quote(data['justNow'])},")
        lines.append(f"    ago = {_quote(data['ago'])},")
        lines.append(f"    in_future = {_quote(data['inFuture'])},")

        # Short/compact overrides
        if "short" in data:
            val = _compactness_override(data["short"])
            lines.append(f"    short_override = {val},")
        else:
            lines.append("    short_override = nil,")

        if "compact" in data:
            val = _compactness_override(data["compact"])
            lines.append(f"    compact_override = {val},")
        else:
            lines.append("    compact_override = nil,")

        lines.append("}")
        lines.append("")

    # get_locale function
    lines.append("get_locale :: proc(code: string) -> ^Duration_Locale {")
    lines.append("    switch code {")
    for data in sorted_locs:
        c = data["code"]
        var_name = "locale_" + c.replace("-", "_")
        lines.append(f'    case {_quote(c)}: return &{_ident(var_name)}')
    lines.append("    case: return nil")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "odin", "locales.odin")

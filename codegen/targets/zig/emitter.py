"""Zig locale emitter — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.zig.plural_rules import get_zig_plural

HEADER = make_header("codegen/targets/zig/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f'.{{ .simple = {_quote(unit)} }}'
    cats = ["zero", "one", "two", "few", "many", "other"]
    parts = []
    for cat in cats:
        if cat in unit:
            parts.append(f".{cat} = {_quote(unit[cat])}")
        else:
            parts.append(f".{cat} = null")
    return ".{ .forms = .{ " + ", ".join(parts) + " } }"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f'.{{ .label = {_quote(stage)}, .f = "" }}'
    return f'.{{ .label = {_quote(stage["m"])}, .f = {_quote(stage["f"])} }}'


def _compactness_override(ovr: dict) -> str:
    parts = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            parts.append(f".{unit_name} = {_unit_forms(val)}")
        else:
            parts.append(f".{unit_name} = null")
    if "half" in ovr:
        parts.append(f".half = {_quote(ovr['half'])}")
    else:
        parts.append(".half = null")
    if "delimiter" in ovr:
        parts.append(f".delimiter = {_quote(ovr['delimiter'])}")
    else:
        parts.append(".delimiter = null")
    if "justBorn" in ovr:
        parts.append(f".just_born = {_quote(ovr['justBorn'])}")
    else:
        parts.append(".just_born = null")
    return ".{ " + ", ".join(parts) + " }"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single locales.zig file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('const parenttime = @import("../parenttime.zig");')
    lines.append("")

    # Collect unique plural rules
    rules_used: dict[str, str] = {}
    for data in sorted_locs:
        rule = data["pluralRule"]
        if rule not in rules_used:
            rules_used[rule] = get_zig_plural(rule)

    # Emit plural rule functions
    for rule_name, body in sorted(rules_used.items()):
        fn_name = f"plural_{rule_name}"
        lines.append(f"fn {fn_name}(n: i32) parenttime.PluralCategory {{")
        for line in body.split("\n"):
            lines.append(f"    {line.strip()}")
        lines.append("}")
        lines.append("")

    # Emit locale constants
    for data in sorted_locs:
        code = data["code"]
        rule = data["pluralRule"]
        fn_name = f"plural_{rule}"

        lines.append(locale_source_comment(code).rstrip())
        lines.append(f"pub const {code}: parenttime.Locale = .{{")
        lines.append(f"    .code = {_quote(code)},")
        lines.append(f"    .plural = {fn_name},")

        # Units
        lines.append("    .units = .{")
        for unit_name in ("day", "week", "month", "year"):
            val = _unit_forms(data["units"][unit_name])
            lines.append(f"        .{unit_name} = {val},")
        lines.append("    },")

        # Simple fields
        lines.append(f"    .half = {_quote(data['half'])},")
        lines.append(f"    .delimiter = {_quote(data['delimiter'])},")
        lines.append(f"    .just_born = {_quote(data['justBorn'])},")

        # Stages
        lines.append("    .stages = .{")
        for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
            val = _stage_label(data["stages"][stage])
            lines.append(f"        .{stage} = {val},")
        lines.append("    },")

        # Short/compact overrides
        if "short" in data:
            val = _compactness_override(data["short"])
            lines.append(f"    .short_override = {val},")
        else:
            lines.append("    .short_override = null,")

        if "compact" in data:
            val = _compactness_override(data["compact"])
            lines.append(f"    .compact_override = {val},")
        else:
            lines.append("    .compact_override = null,")

        lines.append("};")
        lines.append("")

    # get() function
    lines.append("pub fn get(code: []const u8) ?*const parenttime.Locale {")
    lines.append("    return locale_map.get(code);")
    lines.append("}")
    lines.append("")

    # Static map using a StaticStringMap-style lookup (simple if-chain for portability)
    lines.append("const locale_map = struct {")
    lines.append("    fn get(code: []const u8) ?*const parenttime.Locale {")
    # Generate an if-chain for locale lookup
    for data in sorted_locs:
        c = data["code"]
        lines.append(f'        if (eql(code, "{c}")) return &{c};')
    lines.append("        return null;")
    lines.append("    }")
    lines.append("")
    lines.append("    fn eql(a: []const u8, b: []const u8) bool {")
    lines.append("        if (a.len != b.len) return false;")
    lines.append("        for (a, b) |x, y| {")
    lines.append("            if (x != y) return false;")
    lines.append("        }")
    lines.append("        return true;")
    lines.append("    }")
    lines.append("};")
    lines.append("")

    # all array for enumeration
    lines.append("pub const all = [_]struct { code: []const u8, locale: *const parenttime.Locale }{")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f'    .{{ .code = "{c}", .locale = &{c} }},')
    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "zig", "src", "locales", "locales.zig")

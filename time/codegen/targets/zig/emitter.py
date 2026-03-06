"""Zig locale emitter for sayable-time — single file with all locales."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/zig/emitter.py")


_ZIG_KEYWORDS = frozenset([
    "addrspace", "align", "allowzero", "and", "anyframe", "anytype", "asm",
    "async", "await", "break", "callconv", "catch", "comptime", "const",
    "continue", "defer", "else", "enum", "errdefer", "error", "export",
    "extern", "false", "fn", "for", "if", "inline", "noalias", "nosuspend",
    "null", "opaque", "or", "orelse", "packed", "pub", "resume", "return",
    "linksection", "struct", "suspend", "switch", "test", "threadlocal",
    "true", "try", "undefined", "union", "unreachable", "var", "volatile",
    "while",
])


def _ident(name: str) -> str:
    if name in _ZIG_KEYWORDS:
        return f'@"{name}"'
    return name


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _hours_array(hours: list[str]) -> str:
    return ".{ " + ", ".join(_quote(h) for h in hours) + " }"


def _patterns_array(patterns: dict[str, str]) -> str:
    """Emit a Zig [12][]const u8 array for minute patterns at 0,5,10,...,55."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    return ".{ " + ", ".join(_quote(patterns.get(str(k), "")) for k in keys) + " }"


def _short_clock(clock: dict) -> str:
    """Emit a ShortClockConfig struct literal."""
    use_24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        return f'.{{ .use_24h = {use_24h}, .am_pm = .{{ {_quote(am_pm[0])}, {_quote(am_pm[1])} }}, .format = {_quote(fmt)} }}'
    else:
        return f'.{{ .use_24h = {use_24h}, .format = {_quote(fmt)} }}'


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single locales.zig file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('const sayabletime = @import("../sayabletime.zig");')
    lines.append("")

    for data in sorted_locs:
        code = data["code"]
        clock = data["clock"]

        lines.append(locale_source_comment(code).rstrip())
        lines.append(f"pub const {_ident(code)}: sayabletime.TimeLocale = .{{")
        lines.append(f"    .code = {_quote(code)},")
        lines.append("    .clock = .{")
        lines.append(f"        .hours = {_hours_array(clock['hours'])},")
        lines.append(f"        .midnight = {_quote(clock['midnight'])},")
        lines.append(f"        .noon = {_quote(clock['noon'])},")
        lines.append(f"        .patterns = {_patterns_array(clock['patterns'])},")
        lines.append("    },")

        if "short" in data and "clock" in data["short"]:
            lines.append(f"    .short_override = .{{ .clock = {_short_clock(data['short']['clock'])} }},")
        else:
            lines.append("    .short_override = null,")

        if "compact" in data and "clock" in data["compact"]:
            lines.append(f"    .compact_override = .{{ .clock = {_short_clock(data['compact']['clock'])} }},")
        else:
            lines.append("    .compact_override = null,")

        lines.append("};")
        lines.append("")

    # get() function
    lines.append("pub fn get(code: []const u8) ?*const sayabletime.TimeLocale {")
    lines.append("    return locale_map.get(code);")
    lines.append("}")
    lines.append("")

    # Static map
    lines.append("const locale_map = struct {")
    lines.append("    fn get(code: []const u8) ?*const sayabletime.TimeLocale {")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f'        if (eql(code, "{c}")) return &{_ident(c)};')
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

    # all array
    lines.append("pub const all = [_]struct { code: []const u8, locale: *const sayabletime.TimeLocale }{")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f'    .{{ .code = "{c}", .locale = &{_ident(c)} }},')
    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "zig", "src", "locales", "locales.zig")

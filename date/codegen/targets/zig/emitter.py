"""Zig locale emitter for sayable-date — single file with all locales."""

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


def _str_array(items: list[str], size: int) -> str:
    return ".{ " + ", ".join(_quote(s) for s in items) + " }"


def _day_format_exceptions(exceptions: dict[str, str]) -> str:
    """Emit a slice literal of DayFormatException structs."""
    if not exceptions:
        return "&.{}"
    entries = []
    for day, fmt in sorted(exceptions.items(), key=lambda x: int(x[0])):
        entries.append(f'.{{ .day = {_quote(day)}, .format = {_quote(fmt)} }}')
    return "&.{ " + ", ".join(entries) + " }"


def _compactness_override(ovr: dict) -> list[str]:
    """Emit a CompactnessOverride struct literal."""
    parts = []
    if "months" in ovr:
        parts.append(f"    .months = &{_str_array(ovr['months'], 12)}")
    if "monthsInDate" in ovr:
        parts.append(f"    .months_in_date = &{_str_array(ovr['monthsInDate'], 12)}")
    if "weekdays" in ovr:
        parts.append(f"    .weekdays = &{_str_array(ovr['weekdays'], 7)}")
    if "dayFormat" in ovr:
        parts.append(f"    .day_format = {_quote(ovr['dayFormat'])}")
        # When dayFormat is overridden without exceptions, set clear_exceptions
        if "dayFormatExceptions" not in ovr:
            parts.append("    .clear_exceptions = true")
    if "dayFormatExceptions" in ovr:
        parts.append(f"    .day_format_exceptions = {_day_format_exceptions(ovr['dayFormatExceptions'])}")
    if "datePattern" in ovr:
        parts.append(f"    .date_pattern = {_quote(ovr['datePattern'])}")
    if "datePatternWithYear" in ovr:
        parts.append(f"    .date_pattern_with_year = {_quote(ovr['datePatternWithYear'])}")
    if "today" in ovr:
        parts.append(f"    .today = {_quote(ovr['today'])}")
    if "tomorrow" in ovr:
        parts.append(f"    .tomorrow = {_quote(ovr['tomorrow'])}")
    if "yesterday" in ovr:
        parts.append(f"    .yesterday = {_quote(ovr['yesterday'])}")
    return parts


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single locales.zig file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('const sayabledate = @import("../sayabledate.zig");')
    lines.append("")

    for data in sorted_locs:
        code = data["code"]

        lines.append(locale_source_comment(code).rstrip())
        lines.append(f"pub const {_ident(code)}: sayabledate.DateLocale = .{{")
        lines.append(f"    .code = {_quote(code)},")
        lines.append(f"    .months = {_str_array(data['months'], 12)},")
        lines.append(f"    .weekdays = {_str_array(data['weekdays'], 7)},")
        lines.append(f"    .day_format = {_quote(data['dayFormat'])},")
        if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
            lines.append(f"    .day_format_exceptions = {_day_format_exceptions(data['dayFormatExceptions'])},")
        lines.append(f"    .date_pattern = {_quote(data['datePattern'])},")
        lines.append(f"    .date_pattern_with_year = {_quote(data['datePatternWithYear'])},")
        lines.append(f"    .today = {_quote(data['today'])},")
        lines.append(f"    .tomorrow = {_quote(data['tomorrow'])},")
        lines.append(f"    .yesterday = {_quote(data['yesterday'])},")

        if "dayAfterTomorrow" in data:
            lines.append(f"    .day_after_tomorrow = {_quote(data['dayAfterTomorrow'])},")
        if "dayBeforeYesterday" in data:
            lines.append(f"    .day_before_yesterday = {_quote(data['dayBeforeYesterday'])},")
        if "thisWeekday" in data:
            lines.append(f"    .this_weekday = {_quote(data['thisWeekday'])},")
        if "nextWeekday" in data:
            lines.append(f"    .next_weekday = {_quote(data['nextWeekday'])},")
        if "lastWeekday" in data:
            lines.append(f"    .last_weekday = {_quote(data['lastWeekday'])},")
        if "monthsInDate" in data:
            lines.append(f"    .months_in_date = &{_str_array(data['monthsInDate'], 12)},")

        if "short" in data:
            parts = _compactness_override(data["short"])
            lines.append("    .short_override = .{")
            lines.extend(f"    {p}," for p in parts)
            lines.append("    },")

        if "compact" in data:
            parts = _compactness_override(data["compact"])
            lines.append("    .compact_override = .{")
            lines.extend(f"    {p}," for p in parts)
            lines.append("    },")

        lines.append("};")
        lines.append("")

    # get() function
    lines.append("pub fn get(code: []const u8) ?*const sayabledate.DateLocale {")
    lines.append("    return locale_map.get(code);")
    lines.append("}")
    lines.append("")

    # Static map
    lines.append("const locale_map = struct {")
    lines.append("    fn get(code: []const u8) ?*const sayabledate.DateLocale {")
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
    lines.append("pub const all = [_]struct { code: []const u8, locale: *const sayabledate.DateLocale }{")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f'    .{{ .code = "{c}", .locale = &{_ident(c)} }},')
    lines.append("};")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "zig", "src", "locales", "locales.zig")

"""Swift locale emitter — single file with all locales for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/swift/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Swift array literal on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _str_dict(d: dict[str, str]) -> str:
    """Emit a Swift dictionary literal on one line."""
    if not d:
        return "[:]"
    pairs = [f"{_quote(k)}: {_quote(v)}" for k, v in d.items()]
    return "[" + ", ".join(pairs) + "]"


def _emit_compactness_override(lines: list[str], label: str, ovr: dict, trailing_comma: bool = True) -> None:
    """Emit a CompactnessOverride constructor call."""
    lines.append(f"        {label}: CompactnessOverride(")
    fields: list[tuple[str, str]] = []
    if "months" in ovr:
        fields.append(("months", _str_list(ovr["months"])))
    else:
        fields.append(("months", "nil"))
    if "monthsInDate" in ovr:
        fields.append(("monthsInDate", _str_list(ovr["monthsInDate"])))
    else:
        fields.append(("monthsInDate", "nil"))
    if "weekdays" in ovr:
        fields.append(("weekdays", _str_list(ovr["weekdays"])))
    else:
        fields.append(("weekdays", "nil"))
    if "dayFormat" in ovr:
        fields.append(("dayFormat", _quote(ovr["dayFormat"])))
    else:
        fields.append(("dayFormat", "nil"))
    if "dayFormatExceptions" in ovr:
        fields.append(("dayFormatExceptions", _str_dict(ovr["dayFormatExceptions"])))
    else:
        fields.append(("dayFormatExceptions", "nil"))
    if "datePattern" in ovr:
        fields.append(("datePattern", _quote(ovr["datePattern"])))
    else:
        fields.append(("datePattern", "nil"))
    if "datePatternWithYear" in ovr:
        fields.append(("datePatternWithYear", _quote(ovr["datePatternWithYear"])))
    else:
        fields.append(("datePatternWithYear", "nil"))
    if "today" in ovr:
        fields.append(("today", _quote(ovr["today"])))
    else:
        fields.append(("today", "nil"))
    if "tomorrow" in ovr:
        fields.append(("tomorrow", _quote(ovr["tomorrow"])))
    else:
        fields.append(("tomorrow", "nil"))
    if "yesterday" in ovr:
        fields.append(("yesterday", _quote(ovr["yesterday"])))
    else:
        fields.append(("yesterday", "nil"))
    for j, (name, field) in enumerate(fields):
        comma = "," if j < len(fields) - 1 else ""
        lines.append(f"            {name}: {field}{comma}")
    tc = "," if trailing_comma else ""
    lines.append(f"        ){tc}")


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.swift file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("// swiftlint:disable file_length")
    lines.append("")
    lines.append("/// All %d locale definitions for sayable-date." % len(all_locales))
    lines.append("public enum Locales {")

    for data in sorted_locs:
        code = data["code"]
        name = data["name"]
        uc = code.upper()

        lines.append("")
        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append("    // ================================================================")
        lines.append(f"    // {uc} — {name}")
        lines.append("    // ================================================================")

        lines.append(f"    public static let {uc} = DateLocale(")
        lines.append(f"        code: {_quote(code)},")
        lines.append(f"        months: {_str_list(data['months'])},")
        lines.append(f"        weekdays: {_str_list(data['weekdays'])},")
        lines.append(f"        dayFormat: {_quote(data['dayFormat'])},")

        exceptions = data.get("dayFormatExceptions", {})
        lines.append(f"        dayFormatExceptions: {_str_dict(exceptions)},")

        lines.append(f"        datePattern: {_quote(data['datePattern'])},")
        lines.append(f"        datePatternWithYear: {_quote(data['datePatternWithYear'])},")
        lines.append(f"        today: {_quote(data['today'])},")
        lines.append(f"        tomorrow: {_quote(data['tomorrow'])},")
        lines.append(f"        yesterday: {_quote(data['yesterday'])},")

        # Optional proximity strings
        if "dayAfterTomorrow" in data:
            lines.append(f"        dayAfterTomorrow: {_quote(data['dayAfterTomorrow'])},")
        if "dayBeforeYesterday" in data:
            lines.append(f"        dayBeforeYesterday: {_quote(data['dayBeforeYesterday'])},")
        if "thisWeekday" in data:
            lines.append(f"        thisWeekday: {_quote(data['thisWeekday'])},")
        if "nextWeekday" in data:
            lines.append(f"        nextWeekday: {_quote(data['nextWeekday'])},")
        if "lastWeekday" in data:
            lines.append(f"        lastWeekday: {_quote(data['lastWeekday'])},")
        if "monthsInDate" in data:
            lines.append(f"        monthsInDate: {_str_list(data['monthsInDate'])},")

        # Short override
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            _emit_compactness_override(lines, "short", data["short"], trailing_comma=True)
        else:
            lines.append("        short: nil,")

        if has_compact:
            _emit_compactness_override(lines, "compact", data["compact"], trailing_comma=False)
        else:
            lines.append("        compact: nil")

        lines.append("    )")

    # all dictionary
    lines.append("")
    lines.append("    public static let all: [String: DateLocale] = [")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'        "{code}": {uc},')
    lines.append("    ]")

    # get() method
    lines.append("")
    lines.append("    public static func get(_ code: String) -> DateLocale? {")
    lines.append("        return all[code]")
    lines.append("    }")

    lines.append("}")
    lines.append("")
    lines.append("// swiftlint:enable file_length")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "swift", "Sources", "SayableDate", "Locales", "Locales.swift")

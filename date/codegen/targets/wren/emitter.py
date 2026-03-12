"""Wren locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/wren/emitter.py", line_prefix="// ")


def _quote(s: str) -> str:
    """Quote a string for Wren."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Wren list of strings on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _dict_str(d: dict[str, str]) -> str:
    """Emit a Wren map of str→str on one line."""
    pairs = [f"{_quote(k)}: {_quote(v)}" for k, v in d.items()]
    return "{" + ", ".join(pairs) + "}"


def emit_locale(data: dict) -> str:
    """Generate a Wren locale file from canonical JSON."""
    code = data["code"]

    lines = [HEADER + locale_source_comment(code, line_prefix="// ")]

    class_name = code.upper().replace("-", "_") + "Locale"
    lines.append(f"class {class_name} {{")
    lines.append(f"  static code {{ {_quote(code)} }}")

    # Months
    lines.append("  static months {")
    lines.append(f"    return {_str_list(data['months'])}")
    lines.append("  }")

    # Weekdays
    lines.append("  static weekdays {")
    lines.append(f"    return {_str_list(data['weekdays'])}")
    lines.append("  }")

    # Day format
    lines.append(f"  static dayFormat {{ {_quote(data['dayFormat'])} }}")

    # Day format exceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append("  static dayFormatExceptions {")
        lines.append(f"    return {_dict_str(data['dayFormatExceptions'])}")
        lines.append("  }")
    else:
        lines.append("  static dayFormatExceptions {")
        lines.append("    return {}")
        lines.append("  }")

    # Date patterns
    lines.append(f"  static datePattern {{ {_quote(data['datePattern'])} }}")
    lines.append(f"  static datePatternWithYear {{ {_quote(data['datePatternWithYear'])} }}")

    # Proximity strings
    lines.append(f"  static today {{ {_quote(data['today'])} }}")
    lines.append(f"  static tomorrow {{ {_quote(data['tomorrow'])} }}")
    lines.append(f"  static yesterday {{ {_quote(data['yesterday'])} }}")

    # Optional proximity strings
    if "dayAfterTomorrow" in data:
        lines.append(f"  static dayAfterTomorrow {{ {_quote(data['dayAfterTomorrow'])} }}")
    else:
        lines.append("  static dayAfterTomorrow { null }")

    if "dayBeforeYesterday" in data:
        lines.append(f"  static dayBeforeYesterday {{ {_quote(data['dayBeforeYesterday'])} }}")
    else:
        lines.append("  static dayBeforeYesterday { null }")

    if "thisWeekday" in data:
        lines.append(f"  static thisWeekday {{ {_quote(data['thisWeekday'])} }}")
    else:
        lines.append("  static thisWeekday { null }")

    if "nextWeekday" in data:
        lines.append(f"  static nextWeekday {{ {_quote(data['nextWeekday'])} }}")
    else:
        lines.append("  static nextWeekday { null }")

    if "lastWeekday" in data:
        lines.append(f"  static lastWeekday {{ {_quote(data['lastWeekday'])} }}")
    else:
        lines.append("  static lastWeekday { null }")

    # monthsInDate (optional genitive months)
    if "monthsInDate" in data:
        lines.append("  static monthsInDate {")
        lines.append(f"    return {_str_list(data['monthsInDate'])}")
        lines.append("  }")
    else:
        lines.append("  static monthsInDate { null }")

    # Short override
    if "short" in data:
        ovr = data["short"]
        lines.append("  static short {")
        lines.append("    return {")
        if "months" in ovr:
            lines.append(f'      "months": {_str_list(ovr["months"])},')
        if "weekdays" in ovr:
            lines.append(f'      "weekdays": {_str_list(ovr["weekdays"])},')
        if "dayFormat" in ovr:
            lines.append(f'      "dayFormat": {_quote(ovr["dayFormat"])},')
        if "dayFormatExceptions" in ovr:
            lines.append(f'      "dayFormatExceptions": {_dict_str(ovr["dayFormatExceptions"])},')
        if "datePattern" in ovr:
            lines.append(f'      "datePattern": {_quote(ovr["datePattern"])},')
        if "datePatternWithYear" in ovr:
            lines.append(f'      "datePatternWithYear": {_quote(ovr["datePatternWithYear"])},')
        lines.append("    }")
        lines.append("  }")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        lines.append("  static compact {")
        lines.append("    return {")
        if "datePattern" in ovr:
            lines.append(f'      "datePattern": {_quote(ovr["datePattern"])},')
        if "datePatternWithYear" in ovr:
            lines.append(f'      "datePatternWithYear": {_quote(ovr["datePatternWithYear"])},')
        lines.append("    }")
        lines.append("  }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to locale classes."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    for loc in sorted_locs:
        code = loc["code"]
        class_name = code.upper().replace("-", "_") + "Locale"
        lines.append(f'import "./{code}" for {class_name}')

    lines.append("")
    lines.append("class LocaleRegistry {")
    lines.append("  static getLocale(code) {")

    for loc in sorted_locs:
        code = loc["code"]
        class_name = code.upper().replace("-", "_") + "Locale"
        lines.append(f'    if (code == {_quote(code)}) return {class_name}')

    lines.append("    return null")
    lines.append("  }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "wren", "locales", f"{code}.wren")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "wren", "locales", "registry.wren")

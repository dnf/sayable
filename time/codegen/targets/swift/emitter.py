"""Swift locale emitter — single file with all locales for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/swift/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list_12(items: list[str]) -> str:
    """Emit a Swift array literal with 12 hour-name strings."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _patterns_dict(patterns: dict[str, str]) -> str:
    """Emit a Swift dictionary literal for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key}: {_quote(patterns[skey])}")
    return "[" + ", ".join(pairs) + "]"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}clock: ShortClockConfig(use24h: {use24h}, amPm: ({_quote(am_pm[0])}, {_quote(am_pm[1])}), format: {_quote(fmt)})")
    else:
        lines.append(f"{indent}clock: ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)})")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.swift file with all time locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = [HEADER]
    lines.append("// swiftlint:disable file_length")
    lines.append("")
    lines.append("/// All %d locale definitions for sayable-time." % len(all_locales))
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

        clock = data["clock"]
        lines.append(f"    public static let {uc} = TimeLocale(")
        lines.append(f"        code: {_quote(code)},")

        # Clock config
        lines.append("        clock: ClockConfig(")
        lines.append(f"            hours: {_str_list_12(clock['hours'])},")
        lines.append(f"            midnight: {_quote(clock['midnight'])},")
        lines.append(f"            noon: {_quote(clock['noon'])},")
        lines.append(f"            patterns: {_patterns_dict(clock['patterns'])}")
        lines.append("        ),")

        # Short override
        has_short = "short" in data
        has_compact = "compact" in data

        if has_short:
            lines.append("        short: CompactnessOverride(")
            lines.extend(_clock_override(data["short"]["clock"], "            "))
            lines.append("        ),")
        else:
            lines.append("        short: nil,")

        if has_compact:
            lines.append("        compact: CompactnessOverride(")
            lines.extend(_clock_override(data["compact"]["clock"], "            "))
            lines.append("        )")
        else:
            lines.append("        compact: nil")

        lines.append("    )")

    # all dictionary
    lines.append("")
    lines.append("    public static let all: [String: TimeLocale] = [")
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        lines.append(f'        "{code}": {uc},')
    lines.append("    ]")

    # get() method
    lines.append("")
    lines.append("    public static func get(_ code: String) -> TimeLocale? {")
    lines.append("        return all[code]")
    lines.append("    }")

    lines.append("}")
    lines.append("")
    lines.append("// swiftlint:enable file_length")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "swift", "Sources", "SayableTime", "Locales", "Locales.swift")

"""Go locale emitter for sayable-time."""

from __future__ import annotations

import unicodedata

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/go/emitter.py")


def _escape_format_char(char: str) -> str:
    """Escape invisible format characters (ZWNJ, ZWJ...) so they stay visible in source (staticcheck ST1018)."""
    if unicodedata.category(char) != "Cf":
        return char
    return f"\\u{ord(char):04x}"


def _quote(s: str) -> str:
    """Quote a string for Go."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    escaped = "".join(_escape_format_char(c) for c in escaped)
    return f'"{escaped}"'


def _str_array_12(items: list[str]) -> str:
    """Emit a Go [12]string literal on one line."""
    return "[12]string{" + ", ".join(_quote(s) for s in items) + "}"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit a Go map[int]string literal for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key}: {_quote(patterns[skey])}")
    return "map[int]string{" + ", ".join(pairs) + "}"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig struct for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}Clock: &st.ShortClockConfig{{Use24h: {use24h}, AmPm: &[2]string{{{_quote(am_pm[0])}, {_quote(am_pm[1])}}}, Format: {_quote(fmt)}}},")
    else:
        lines.append(f"{indent}Clock: &st.ShortClockConfig{{Use24h: {use24h}, Format: {_quote(fmt)}}},")

    return lines


def emit_locale(data: dict) -> str:
    """Generate a Go locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]
    uc = code.upper()

    lines = [HEADER + locale_source_comment(code), "package locales\n"]
    lines.append('import st "github.com/dnf/sayable/time/impl/go"\n')
    lines.append(f"// {uc} is the {name} locale.")
    lines.append(f"var {uc} = st.TimeLocale{{")

    # Code
    lines.append(f"\tCode: {_quote(code)},")

    # Clock config
    lines.append("\tClock: st.ClockConfig{")
    lines.append(f"\t\tHours:    {_str_array_12(clock['hours'])},")
    lines.append(f"\t\tMidnight: {_quote(clock['midnight'])},")
    lines.append(f"\t\tNoon:     {_quote(clock['noon'])},")
    lines.append(f"\t\tPatterns: {_patterns_map(clock['patterns'])},")
    lines.append("\t},")

    # Short override
    if "short" in data:
        lines.append("\tShort: &st.CompactnessOverride{")
        lines.extend(_clock_override(data["short"]["clock"], "\t\t"))
        lines.append("\t},")

    # Compact override
    if "compact" in data:
        lines.append("\tCompact: &st.CompactnessOverride{")
        lines.extend(_clock_override(data["compact"]["clock"], "\t\t"))
        lines.append("\t},")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    """Go doesn't use barrel files."""
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locale_registry.go with GetLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package locales\n"]
    lines.append('import st "github.com/dnf/sayable/time/impl/go"\n')
    lines.append("// GetLocale returns the locale for the given code, or nil if not found.")
    lines.append("func GetLocale(code string) *st.TimeLocale {")
    lines.append("\tswitch code {")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'\tcase {_quote(code)}:')
        lines.append(f"\t\treturn &{code.upper()}")
    lines.append("\tdefault:")
    lines.append("\t\treturn nil")
    lines.append("\t}")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", f"locale_{code}.go")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", "locale_registry.go")


def barrel_path(root: str) -> str | None:
    return None

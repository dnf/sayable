"""PHP locale emitter for sayable-time — single Locales.php file."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/php/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_array_12(items: list[str]) -> str:
    """Emit a PHP array with 12 hour-name strings."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _patterns_array(patterns: dict[str, str]) -> str:
    """Emit a PHP associative array for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key} => {_quote(patterns[skey])}")
    return "[" + ", ".join(pairs) + "]"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}clock: new ShortClockConfig(use24h: {use24h}, amPm: [{_quote(am_pm[0])}, {_quote(am_pm[1])}], format: {_quote(fmt)}),")
    else:
        lines.append(f"{indent}clock: new ShortClockConfig(use24h: {use24h}, format: {_quote(fmt)}),")

    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.php file with all time locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = ["<?php", "", "declare(strict_types=1);", ""]
    lines.append("namespace SayableTime\\Locales;")
    lines.append("")
    lines.append("use SayableTime\\ClockConfig;")
    lines.append("use SayableTime\\CompactnessOverride;")
    lines.append("use SayableTime\\ShortClockConfig;")
    lines.append("use SayableTime\\TimeLocale;")
    lines.append("")
    lines.append(HEADER.rstrip())
    lines.append("")
    lines.append("/** Built-in locale definitions. */")
    lines.append("final class Locales")
    lines.append("{")

    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        uc = code.upper()
        clock = data["clock"]

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append(f"    // ── {name} " + "─" * max(1, 60 - len(name)) + "\n")

        # Locale method
        lines.append(f"    public static function {uc}(): TimeLocale")
        lines.append("    {")
        lines.append("        static $locale = null;\n")
        lines.append("        return $locale ??= new TimeLocale(")
        lines.append(f"            code: {_quote(code)},")

        # Clock config
        lines.append("            clock: new ClockConfig(")
        lines.append(f"                hours: {_str_array_12(clock['hours'])},")
        lines.append(f"                midnight: {_quote(clock['midnight'])},")
        lines.append(f"                noon: {_quote(clock['noon'])},")
        lines.append(f"                patterns: {_patterns_array(clock['patterns'])},")
        lines.append("            ),")

        # Short override
        if "short" in data:
            lines.append("            short: new CompactnessOverride(")
            lines.extend(_clock_override(data["short"]["clock"], "                "))
            lines.append("            ),")

        # Compact override
        if "compact" in data:
            lines.append("            compact: new CompactnessOverride(")
            lines.extend(_clock_override(data["compact"]["clock"], "                "))
            lines.append("            ),")

        lines.append("        );")
        lines.append("    }")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # get() method
    lines.append("")
    lines.append("    public static function get(string $code): ?TimeLocale")
    lines.append("    {")
    lines.append("        return match ($code) {")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"            {_quote(code)} => self::{code.upper()}(),")
    lines.append("            default => null,")
    lines.append("        };")
    lines.append("    }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "php", "src", "Locales", "Locales.php")

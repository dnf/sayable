"""PHP locale emitter for sayable-date — single Locales.php file."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/php/emitter.py")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_array(items: list[str]) -> str:
    """Emit a PHP array literal on one line."""
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _str_assoc(d: dict[str, str]) -> str:
    """Emit a PHP associative array literal on one line."""
    if not d:
        return "[]"
    pairs = [f"{_quote(k)} => {_quote(v)}" for k, v in d.items()]
    return "[" + ", ".join(pairs) + "]"


def _emit_compactness_override(ovr: dict, indent: str) -> list[str]:
    """Emit fields for a CompactnessOverride constructor call."""
    lines = []
    if "months" in ovr:
        lines.append(f"{indent}months: {_str_array(ovr['months'])},")
    if "monthsInDate" in ovr:
        lines.append(f"{indent}monthsInDate: {_str_array(ovr['monthsInDate'])},")
    if "weekdays" in ovr:
        lines.append(f"{indent}weekdays: {_str_array(ovr['weekdays'])},")
    if "dayFormat" in ovr:
        lines.append(f"{indent}dayFormat: {_quote(ovr['dayFormat'])},")
    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}dayFormatExceptions: {_str_assoc(ovr['dayFormatExceptions'])},")
    if "datePattern" in ovr:
        lines.append(f"{indent}datePattern: {_quote(ovr['datePattern'])},")
    if "datePatternWithYear" in ovr:
        lines.append(f"{indent}datePatternWithYear: {_quote(ovr['datePatternWithYear'])},")
    if "today" in ovr:
        lines.append(f"{indent}today: {_quote(ovr['today'])},")
    if "tomorrow" in ovr:
        lines.append(f"{indent}tomorrow: {_quote(ovr['tomorrow'])},")
    if "yesterday" in ovr:
        lines.append(f"{indent}yesterday: {_quote(ovr['yesterday'])},")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.php file with all date locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = ["<?php", "", "declare(strict_types=1);", ""]
    lines.append("namespace SayableDate\\Locales;")
    lines.append("")
    lines.append("use SayableDate\\CompactnessOverride;")
    lines.append("use SayableDate\\DateLocale;")
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

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append(f"    // ── {name} " + "─" * max(1, 60 - len(name)) + "\n")

        # Locale method
        lines.append(f"    public static function {uc}(): DateLocale")
        lines.append("    {")
        lines.append("        static $locale = null;\n")
        lines.append("        return $locale ??= new DateLocale(")
        lines.append(f"            code: {_quote(code)},")
        lines.append(f"            months: {_str_array(data['months'])},")
        lines.append(f"            weekdays: {_str_array(data['weekdays'])},")
        lines.append(f"            dayFormat: {_quote(data['dayFormat'])},")

        # dayFormatExceptions
        exceptions = data.get("dayFormatExceptions", {})
        lines.append(f"            dayFormatExceptions: {_str_assoc(exceptions)},")

        # Date patterns
        lines.append(f"            datePattern: {_quote(data['datePattern'])},")
        lines.append(f"            datePatternWithYear: {_quote(data['datePatternWithYear'])},")

        # Required strings
        lines.append(f"            today: {_quote(data['today'])},")
        lines.append(f"            tomorrow: {_quote(data['tomorrow'])},")
        lines.append(f"            yesterday: {_quote(data['yesterday'])},")

        # Optional strings
        if "dayAfterTomorrow" in data:
            lines.append(f"            dayAfterTomorrow: {_quote(data['dayAfterTomorrow'])},")
        if "dayBeforeYesterday" in data:
            lines.append(f"            dayBeforeYesterday: {_quote(data['dayBeforeYesterday'])},")
        if "thisWeekday" in data:
            lines.append(f"            thisWeekday: {_quote(data['thisWeekday'])},")
        if "nextWeekday" in data:
            lines.append(f"            nextWeekday: {_quote(data['nextWeekday'])},")
        if "lastWeekday" in data:
            lines.append(f"            lastWeekday: {_quote(data['lastWeekday'])},")
        if "monthsInDate" in data:
            lines.append(f"            monthsInDate: {_str_array(data['monthsInDate'])},")

        # Short override
        if "short" in data:
            lines.append("            short: new CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["short"], "                "))
            lines.append("            ),")

        # Compact override
        if "compact" in data:
            lines.append("            compact: new CompactnessOverride(")
            lines.extend(_emit_compactness_override(data["compact"], "                "))
            lines.append("            ),")

        lines.append("        );")
        lines.append("    }")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # get() method
    lines.append("")
    lines.append("    public static function get(string $code): ?DateLocale")
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

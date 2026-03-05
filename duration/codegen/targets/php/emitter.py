"""PHP locale emitter for sayable-duration — single Locales.php file."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.php.plural_rules import get_php_inline_plural, get_php_named_function, is_simple_plural

HEADER = make_header("codegen/targets/php/emitter.py")

# Duration has 7 unit names
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"'{cat}' => {_quote(unit[cat])}")
    return "[" + ", ".join(pairs) + "]"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.php file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines = ["<?php", "", "declare(strict_types=1);", ""]
    lines.append("namespace SayableDuration\\Locales;")
    lines.append("")
    lines.append("use SayableDuration\\CompactnessOverride;")
    lines.append("use SayableDuration\\DurationLocale;")
    lines.append("use SayableDuration\\PluralCategory;")
    lines.append("use SayableDuration\\Units;")
    lines.append("")
    lines.append(HEADER.rstrip())
    lines.append("")
    lines.append("/** Built-in locale definitions. */")
    lines.append("final class Locales")
    lines.append("{")

    for i, data in enumerate(sorted_locs):
        code = data["code"]
        name = data["name"]
        rule = data["pluralRule"]
        uc = code.upper()

        lines.append(f"    {locale_source_comment(code).rstrip()}")
        lines.append(f"    // ── {name} " + "─" * max(1, 60 - len(name)) + "\n")

        # Named plural function for complex rules
        named_fn = get_php_named_function(rule, code)
        if named_fn:
            lines.append(named_fn)
            lines.append("")

        # Locale method
        lines.append(f"    public static function {uc}(): DurationLocale")
        lines.append("    {")
        lines.append("        static $locale = null;\n")
        lines.append("        return $locale ??= new DurationLocale(")
        lines.append(f"            code: {_quote(code)},")

        # Plural
        inline = get_php_inline_plural(rule)
        if inline:
            lines.append(f"            plural: {inline},")
        else:
            lines.append(f"            plural: static fn(int $n): PluralCategory => self::plural{uc}($n),")

        # Units
        lines.append("            units: new Units(")
        for unit_name in _UNIT_NAMES:
            val = _unit_forms(data["units"][unit_name])
            lines.append(f"                {unit_name}: {val},")
        lines.append("            ),")

        # Simple fields
        lines.append(f"            half: {_quote(data['half'])},")
        lines.append(f"            delimiter: {_quote(data['delimiter'])},")
        lines.append(f"            justNow: {_quote(data['justNow'])},")
        lines.append(f"            ago: {_quote(data['ago'])},")
        lines.append(f"            inFuture: {_quote(data['inFuture'])},")

        # Short/compact
        for mode in ("short", "compact"):
            if mode in data:
                ovr = data[mode]
                parts = []
                if "units" in ovr:
                    for unit_name in _UNIT_NAMES:
                        if unit_name in ovr["units"]:
                            val = _unit_forms(ovr["units"][unit_name])
                            parts.append(f"                {unit_name}: {val},")
                if "half" in ovr:
                    parts.append(f"                half: {_quote(ovr['half'])},")
                if "delimiter" in ovr:
                    parts.append(f"                delimiter: {_quote(ovr['delimiter'])},")
                if "ago" in ovr:
                    parts.append(f"                ago: {_quote(ovr['ago'])},")
                if "inFuture" in ovr:
                    parts.append(f"                inFuture: {_quote(ovr['inFuture'])},")
                lines.append(f"            {mode}: new CompactnessOverride(")
                lines.extend(parts)
                lines.append("            ),")

        lines.append("        );")
        lines.append("    }")

        if i < len(sorted_locs) - 1:
            lines.append("")

    # get() method
    lines.append("")
    lines.append("    public static function get(string $code): ?DurationLocale")
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

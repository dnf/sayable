"""Go locale emitter for sayable-duration."""

from __future__ import annotations

import unicodedata

from codegen.banner import locale_source_comment, make_header
from codegen.targets.go.plural_rules import get_go_plural

HEADER = make_header("codegen/targets/go/emitter.py")

# Plural category name mapping (qualified with sd. for locales subpackage)
_CAT_MAP = {
    "zero": "sd.Zero", "one": "sd.One", "two": "sd.Two",
    "few": "sd.Few", "many": "sd.Many", "other": "sd.Other",
}

# Duration has 7 unit names
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")

# Max unit name length for alignment padding
_MAX_UNIT_LEN = max(len(u) for u in _UNIT_NAMES)


def _escape_format_char(char: str) -> str:
    """Escape invisible format characters (ZWNJ, ZWJ...) so they stay visible in source (staticcheck ST1018)."""
    if unicodedata.category(char) != "Cf":
        return char
    return f"\\u{ord(char):04x}"


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    escaped = "".join(_escape_format_char(c) for c in escaped)
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"sd.SimpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]}: {_quote(unit[cat])}")
    return "sd.PluralUnit(map[sd.PluralCategory]string{" + ", ".join(pairs) + "})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    uc = code.upper()

    lines = [HEADER + locale_source_comment(code), "package locales\n"]
    lines.append('import sd "github.com/dnf/sayable/duration/impl/go"\n')
    lines.append(f"// {uc} is the {name} locale.")
    lines.append(f"var {uc} = sd.DurationLocale{{")

    # Code
    lines.append(f"\tCode: {_quote(code)},")

    # Plural
    plural = get_go_plural(rule)
    lines.append(f"\tPlural: {plural.lstrip()},")

    # Units
    lines.append(f"\tUnits: struct{{ Second, Minute, Hour, Day, Week, Month, Year sd.UnitForms }}{{")
    for unit_name in _UNIT_NAMES:
        cap = unit_name.capitalize()
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"\t\t{cap}:{' ' * (_MAX_UNIT_LEN + 1 - len(cap))}{val},")
    lines.append("\t},")

    # Simple fields
    lines.append(f"\tHalf:      {_quote(data['half'])},")
    lines.append(f"\tDelimiter: {_quote(data['delimiter'])},")
    lines.append(f"\tJustNow:   {_quote(data['justNow'])},")
    lines.append(f"\tAgo:       {_quote(data['ago'])},")
    lines.append(f"\tInFuture:  {_quote(data['inFuture'])},")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            cap = mode.capitalize()
            lines.append(f"\t{cap}: &sd.CompactnessOverride{{")
            # Collect all field names to compute uniform padding
            field_names = []
            if "units" in ovr:
                for unit_name in _UNIT_NAMES:
                    if unit_name in ovr["units"]:
                        field_names.append(unit_name.capitalize())
            for key, go_name in (("delimiter", "Delimiter"), ("half", "Half"), ("ago", "Ago"), ("inFuture", "InFuture")):
                if key in ovr:
                    field_names.append(go_name)
            max_field_len = max(len(f) for f in field_names) if field_names else 0
            if "units" in ovr:
                for unit_name in _UNIT_NAMES:
                    if unit_name in ovr["units"]:
                        ucap = unit_name.capitalize()
                        pad = " " * (max_field_len - len(ucap) + 1)
                        val = ovr["units"][unit_name]
                        if isinstance(val, str):
                            lines.append(f"\t\t{ucap}:{pad}&sd.UnitForms{{Simple: {_quote(val)}}},")
                        else:
                            # Plural override — use unitPtr helper (can't take address of function return)
                            lines.append(f"\t\t{ucap}:{pad}unitPtr({_unit_forms(val)}),")
            if "delimiter" in ovr:
                pad = " " * (max_field_len - len("Delimiter") + 1)
                lines.append(f'\t\tDelimiter:{pad}strPtr({_quote(ovr["delimiter"])}),')
            if "half" in ovr:
                pad = " " * (max_field_len - len("Half") + 1)
                lines.append(f'\t\tHalf:{pad}strPtr({_quote(ovr["half"])}),')
            if "ago" in ovr:
                pad = " " * (max_field_len - len("Ago") + 1)
                lines.append(f'\t\tAgo:{pad}strPtr({_quote(ovr["ago"])}),')
            if "inFuture" in ovr:
                pad = " " * (max_field_len - len("InFuture") + 1)
                lines.append(f'\t\tInFuture:{pad}strPtr({_quote(ovr["inFuture"])}),')
            lines.append("\t},")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None  # Go doesn't have barrel files


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locale_registry.go with GetLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package locales\n"]
    lines.append('import sd "github.com/dnf/sayable/duration/impl/go"\n')
    lines.append("// GetLocale returns the locale for the given code, or nil if not found.")
    lines.append("func GetLocale(code string) *sd.DurationLocale {")
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


def emit_helpers() -> str:
    """Generate helpers.go with strPtr and unitPtr for the locales subpackage."""
    lines = [HEADER, "package locales\n"]
    lines.append('import sd "github.com/dnf/sayable/duration/impl/go"\n')
    lines.append("func strPtr(s string) *string { return &s }")
    lines.append("")
    lines.append("func unitPtr(u sd.UnitForms) *sd.UnitForms { return &u }")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", f"locale_{code}.go")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", "locale_registry.go")


def helpers_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", "helpers.go")


def barrel_path(root: str) -> str | None:
    return None

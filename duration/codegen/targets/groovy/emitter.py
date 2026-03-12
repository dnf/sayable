"""Groovy locale emitter for sayable-duration — range-split to avoid JVM method size limits."""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.groovy.plural_rules import get_groovy_plural

HEADER = make_header("codegen/targets/groovy/emitter.py")

_CAT_MAP = {
    "zero": "PluralCategory.ZERO", "one": "PluralCategory.ONE",
    "two": "PluralCategory.TWO", "few": "PluralCategory.FEW",
    "many": "PluralCategory.MANY", "other": "PluralCategory.OTHER",
}

# Duration has 7 unit names
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")

# Split ranges to keep each class under JVM's 64KB method limit
_RANGES = [
    ("AD", "a", "d"),
    ("EK", "e", "k"),
    ("LP", "l", "p"),
    ("QZ", "q", "z"),
]


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms.simpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"({_CAT_MAP[cat]}): {_quote(unit[cat])}")
    return "UnitForms.pluralUnit([" + ", ".join(pairs) + "])"


def _emit_locale_block(lines: list[str], data: dict) -> None:
    """Emit a single locale constant definition."""
    code = data["code"]
    name = data["name"]
    rule = data["pluralRule"]
    uc = code.upper()

    lines.append(f"    {locale_source_comment(code).rstrip()}")
    lines.append("    // ================================================================")
    lines.append(f"    // {uc} — {name}")
    lines.append("    // ================================================================")

    lines.append(f"    static final DurationLocale {uc} = new DurationLocale(")
    lines.append(f"        {_quote(code)},")

    # Plural
    plural = get_groovy_plural(rule)
    lines.append(f"        {plural},")

    # Units
    lines.append("        new Units(")
    for j, unit_name in enumerate(_UNIT_NAMES):
        val = _unit_forms(data["units"][unit_name])
        comma = "," if j < len(_UNIT_NAMES) - 1 else ""
        lines.append(f"            {val}{comma}")
    lines.append("        ),")

    # Simple fields
    lines.append(f"        {_quote(data['half'])},")
    lines.append(f"        {_quote(data['delimiter'])},")
    lines.append(f"        {_quote(data['justNow'])},")
    lines.append(f"        {_quote(data['ago'])},")
    lines.append(f"        {_quote(data['inFuture'])},")

    # Short/compact
    has_short = "short" in data
    has_compact = "compact" in data

    if has_short:
        _emit_compactness_override(lines, data["short"])
    else:
        lines.append("        null,")

    if has_compact:
        _emit_compactness_override(lines, data["compact"])
    else:
        lines.append("        null,")

    # formatNumber, formatUnit
    lines.append("        null,")
    lines.append("        null")

    lines.append("    )")


def _emit_range_file(range_suffix: str, range_locales: list[dict], total_count: int) -> str:
    """Generate a single range file (e.g. LocalesAD.groovy)."""
    lines = [HEADER, "package sayableduration.locales\n"]
    lines.append("import sayableduration.*\n")
    lines.append("/**")
    lines.append(f" * Locale definitions ({range_suffix} range) for sayable-duration.")
    lines.append(" */")
    lines.append(f"class Locales{range_suffix} {{\n")

    for i, data in enumerate(range_locales):
        _emit_locale_block(lines, data)
        if i < len(range_locales) - 1:
            lines.append("")

    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def _emit_main_file(all_locales: list[dict]) -> str:
    """Generate the main Locales.groovy that re-exports from range files."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayableduration.locales\n"]
    lines.append("import sayableduration.*\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-duration.")
    lines.append(f" * Locales are split across range files to stay within JVM method size limits.")
    lines.append(" */")
    lines.append("class Locales {\n")

    # Delegate fields from range classes
    for data in sorted_locs:
        code = data["code"]
        uc = code.upper()
        first = code[0].lower()
        range_suffix = _range_for_code(first)
        lines.append(f"    static final DurationLocale {uc} = Locales{range_suffix}.{uc}")

    # ALL map
    lines.append("")
    lines.append("    static final Map<String, DurationLocale> ALL = Collections.unmodifiableMap([")
    entries = [f"({_quote(loc['code'])}): {loc['code'].upper()}" for loc in sorted_locs]
    for i in range(0, len(entries), 3):
        chunk = ", ".join(entries[i : i + 3])
        comma = "," if i + 3 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    ])")

    # get() method
    lines.append("")
    lines.append("    static DurationLocale get(String code) { ALL[code] }")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def _range_for_code(first_char: str) -> str:
    """Determine which range suffix a locale code belongs to."""
    for suffix, lo, hi in _RANGES:
        if lo <= first_char <= hi:
            return suffix
    return _RANGES[-1][0]  # fallback to last range


def _split_locales(all_locales: list[dict]) -> dict[str, list[dict]]:
    """Split locales into range buckets."""
    buckets: dict[str, list[dict]] = {suffix: [] for suffix, _, _ in _RANGES}
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    for data in sorted_locs:
        first = data["code"][0].lower()
        suffix = _range_for_code(first)
        buckets[suffix].append(data)
    return buckets


def emit_all(all_locales: list[dict]) -> dict[str, str]:
    """Generate all Groovy locale files.

    Returns a dict mapping file path suffix to content.
    This is used by the generate.py orchestrator.
    """
    # For backward compat with the single-file signature,
    # we now return just the main file content.
    # The range files are written separately via emit_range_files().
    return _emit_main_file(all_locales)


def emit_range_files(all_locales: list[dict]) -> dict[str, str]:
    """Generate range files. Returns dict of {suffix: content}."""
    buckets = _split_locales(all_locales)
    result = {}
    for suffix, locs in buckets.items():
        if locs:
            result[suffix] = _emit_range_file(suffix, locs, len(all_locales))
    return result


def _emit_compactness_override(lines: list[str], ovr: dict) -> None:
    lines.append("        new CompactnessOverride(")
    # Build all 11 fields: second, minute, hour, day, week, month, year, half, delimiter, ago, inFuture
    fields: list[str] = []
    for unit_name in _UNIT_NAMES:
        if "units" in ovr and unit_name in ovr["units"]:
            val = ovr["units"][unit_name]
            if isinstance(val, str):
                fields.append(f"UnitForms.simpleUnit({_quote(val)})")
            else:
                fields.append(_unit_forms(val))
        else:
            fields.append("null")
    for key in ("half", "delimiter", "ago", "inFuture"):
        if key in ovr:
            fields.append(_quote(ovr[key]))
        else:
            fields.append("null")
    for j, field in enumerate(fields):
        comma = "," if j < len(fields) - 1 else ""
        lines.append(f"            {field}{comma}")
    lines.append("        ),")


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "groovy", "src", "main", "groovy", "sayableduration", "locales", "Locales.groovy")


def range_path(suffix: str, root: str) -> str:
    return os.path.join(root, "impl", "groovy", "src", "main", "groovy", "sayableduration", "locales", f"Locales{suffix}.groovy")

"""Scala locale emitter for sayable-time — single file with all locales.

Splits locales into private batch objects to avoid the JVM 64KB method limit,
then delegates from the public Locales object.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/scala/emitter.py")

# Split locales into batches to keep each <clinit> under the 64KB JVM limit
_BATCH_SIZE = 18


def _quote(s: str) -> str:
    """Quote a string for Scala using double quotes."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list_12(items: list[str]) -> str:
    """Emit a Scala List() with 12 hour-name strings."""
    return "List(" + ", ".join(_quote(s) for s in items) + ")"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit a Scala Map() for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key} -> {_quote(patterns[skey])}")
    return "Map(" + ", ".join(pairs) + ")"


def _clock_override(clock: dict, indent: str) -> list[str]:
    """Emit a ShortClockConfig for short/compact overrides."""
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}clock = Some(ShortClockConfig(use24h = {use24h}, amPm = Some(({_quote(am_pm[0])}, {_quote(am_pm[1])})), format = {_quote(fmt)})),")
    else:
        lines.append(f"{indent}clock = Some(ShortClockConfig(use24h = {use24h}, format = {_quote(fmt)})),")

    return lines


def _emit_locale(data: dict, indent: str) -> list[str]:
    """Emit a single locale val declaration."""
    lines = []
    code = data["code"]
    name = data["name"]
    uc = code.upper()

    lines.append(f"{indent}{locale_source_comment(code).rstrip()}")
    lines.append(f"{indent}// ================================================================")
    lines.append(f"{indent}// {uc} — {name}")
    lines.append(f"{indent}// ================================================================")

    clock = data["clock"]
    lines.append(f"{indent}val {uc}: TimeLocale = TimeLocale(")
    lines.append(f"{indent}    code = {_quote(code)},")

    # Clock config
    lines.append(f"{indent}    clock = ClockConfig(")
    lines.append(f"{indent}        hours = {_str_list_12(clock['hours'])},")
    lines.append(f"{indent}        midnight = {_quote(clock['midnight'])},")
    lines.append(f"{indent}        noon = {_quote(clock['noon'])},")
    lines.append(f"{indent}        patterns = {_patterns_map(clock['patterns'])},")
    lines.append(f"{indent}    ),")

    # Short override
    if "short" in data:
        lines.append(f"{indent}    short = Some(CompactnessOverride(")
        lines.extend(_clock_override(data["short"]["clock"], indent + "        "))
        lines.append(f"{indent}    )),")

    # Compact override
    if "compact" in data:
        lines.append(f"{indent}    compact = Some(CompactnessOverride(")
        lines.extend(_clock_override(data["compact"]["clock"], indent + "        "))
        lines.append(f"{indent}    )),")

    lines.append(f"{indent})")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.scala file with all time locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package sayabletime.locales\n"]
    lines.append("import sayabletime._\n")
    lines.append("/**")
    lines.append(f" * All {len(all_locales)} locale definitions for sayable-time.")
    lines.append(" */")

    # Split into batches
    batches: list[list[dict]] = []
    for i in range(0, len(sorted_locs), _BATCH_SIZE):
        batches.append(sorted_locs[i : i + _BATCH_SIZE])

    # Emit private batch objects
    for bi, batch in enumerate(batches):
        lines.append(f"private object Batch{bi} {{")
        for j, data in enumerate(batch):
            lines.extend(_emit_locale(data, "    "))
            if j < len(batch) - 1:
                lines.append("")
        lines.append("}")
        lines.append("")

    # Emit public Locales object with delegating vals
    lines.append("object Locales {\n")
    for bi, batch in enumerate(batches):
        for data in batch:
            uc = data["code"].upper()
            lines.append(f"    val {uc}: TimeLocale = Batch{bi}.{uc}")
    lines.append("")

    # ALL map
    lines.append("    val ALL: Map[String, TimeLocale] = Map(")
    entries = [f'{_quote(loc["code"])} -> {loc["code"].upper()}' for loc in sorted_locs]
    for i in range(0, len(entries), 5):
        chunk = ", ".join(entries[i : i + 5])
        comma = "," if i + 5 < len(entries) else ""
        lines.append(f"        {chunk}{comma}")
    lines.append("    )")

    # get() method
    lines.append("")
    lines.append("    def get(code: String): Option[TimeLocale] = ALL.get(code)")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "scala", "src", "main", "scala", "sayabletime", "locales", "Locales.scala")

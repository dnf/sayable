"""Janet locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/janet/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Janet."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Janet tuple of strings."""
    return "@[" + " ".join(_quote(s) for s in items) + "]"


def _str_dict(d: dict[str, str]) -> str:
    """Emit a Janet struct of string->string."""
    if not d:
        return "{}"
    pairs = [f"{_quote(k)} {_quote(v)}" for k, v in d.items()]
    return "{" + " ".join(pairs) + "}"


def emit_locale(data: dict) -> str:
    """Generate a Janet locale file from canonical JSON."""
    code = data["code"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    lines.append("(def locale")
    lines.append(f"  {{:code {_quote(code)}")
    lines.append(f"   :months {_str_list(data['months'])}")
    lines.append(f"   :weekdays {_str_list(data['weekdays'])}")
    lines.append(f"   :day-format {_quote(data['dayFormat'])}")

    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"   :day-format-exceptions {_str_dict(data['dayFormatExceptions'])}")
    else:
        lines.append("   :day-format-exceptions {}")

    lines.append(f"   :date-pattern {_quote(data['datePattern'])}")
    lines.append(f"   :date-pattern-with-year {_quote(data['datePatternWithYear'])}")
    lines.append(f"   :today {_quote(data['today'])}")
    lines.append(f"   :tomorrow {_quote(data['tomorrow'])}")
    lines.append(f"   :yesterday {_quote(data['yesterday'])}")

    if "dayAfterTomorrow" in data:
        lines.append(f"   :day-after-tomorrow {_quote(data['dayAfterTomorrow'])}")
    if "dayBeforeYesterday" in data:
        lines.append(f"   :day-before-yesterday {_quote(data['dayBeforeYesterday'])}")
    if "thisWeekday" in data:
        lines.append(f"   :this-weekday {_quote(data['thisWeekday'])}")
    if "nextWeekday" in data:
        lines.append(f"   :next-weekday {_quote(data['nextWeekday'])}")
    if "lastWeekday" in data:
        lines.append(f"   :last-weekday {_quote(data['lastWeekday'])}")
    if "monthsInDate" in data:
        lines.append(f"   :months-in-date {_str_list(data['monthsInDate'])}")

    # Short override
    if "short" in data:
        ovr = data["short"]
        parts = []
        if "months" in ovr:
            parts.append(f":months {_str_list(ovr['months'])}")
        if "weekdays" in ovr:
            parts.append(f":weekdays {_str_list(ovr['weekdays'])}")
        if "dayFormat" in ovr:
            parts.append(f":day-format {_quote(ovr['dayFormat'])}")
        if "datePattern" in ovr:
            parts.append(f":date-pattern {_quote(ovr['datePattern'])}")
        if "datePatternWithYear" in ovr:
            parts.append(f":date-pattern-with-year {_quote(ovr['datePatternWithYear'])}")
        lines.append(f"   :short {{{' '.join(parts)}}}")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        parts = []
        if "datePattern" in ovr:
            parts.append(f":date-pattern {_quote(ovr['datePattern'])}")
        if "datePatternWithYear" in ovr:
            parts.append(f":date-pattern-with-year {_quote(ovr['datePatternWithYear'])}")
        lines.append(f"   :compact {{{' '.join(parts)}}}")

    lines.append("})")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to locale tables."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("(def- locale-cache @{})")
    lines.append("")
    lines.append("(defn get-locale [code]")
    lines.append("  (if-let [cached (in locale-cache code)]")
    lines.append("    cached")
    lines.append("    (if-let [env")
    lines.append("             (case code")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'               "{code}" (require "./locales/{code}")')

    lines.append("               nil)]")
    lines.append("      (let [loc ((in env 'locale) :value)]")
    lines.append("        (put locale-cache code loc)")
    lines.append("        loc)")
    lines.append("      nil)))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "janet", "locales", f"{code}.janet")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "janet", "locales", "registry.janet")

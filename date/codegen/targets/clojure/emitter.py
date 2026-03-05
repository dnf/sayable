"""Clojure locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/clojure/emitter.py", line_prefix=";; ")


def _ns_name(code: str) -> str:
    """Convert locale code to Clojure namespace suffix (lowercase, underscores for hyphens)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_vec(items: list[str]) -> str:
    """Emit a Clojure vector of quoted strings."""
    return "[" + " ".join(_quote(s) for s in items) + "]"


def _str_map(d: dict[str, str]) -> str:
    """Emit a Clojure map literal from a string->string dict."""
    if not d:
        return "{}"
    pairs = [f"{_quote(k)} {_quote(v)}" for k, v in d.items()]
    return "{" + " ".join(pairs) + "}"


def _compactness_override(ovr: dict) -> str:
    """Emit a Clojure map for a date compactness override."""
    parts = []
    if "months" in ovr:
        parts.append(f":months {_str_vec(ovr['months'])}")
    else:
        parts.append(":months nil")
    if "monthsInDate" in ovr:
        parts.append(f":months-in-date {_str_vec(ovr['monthsInDate'])}")
    else:
        parts.append(":months-in-date nil")
    if "weekdays" in ovr:
        parts.append(f":weekdays {_str_vec(ovr['weekdays'])}")
    else:
        parts.append(":weekdays nil")
    if "dayFormat" in ovr:
        parts.append(f":day-format {_quote(ovr['dayFormat'])}")
    else:
        parts.append(":day-format nil")
    if "dayFormatExceptions" in ovr:
        parts.append(f":day-format-exceptions {_str_map(ovr['dayFormatExceptions'])}")
    else:
        parts.append(":day-format-exceptions nil")
    if "datePattern" in ovr:
        parts.append(f":date-pattern {_quote(ovr['datePattern'])}")
    else:
        parts.append(":date-pattern nil")
    if "datePatternWithYear" in ovr:
        parts.append(f":date-pattern-with-year {_quote(ovr['datePatternWithYear'])}")
    else:
        parts.append(":date-pattern-with-year nil")
    if "today" in ovr:
        parts.append(f":today {_quote(ovr['today'])}")
    else:
        parts.append(":today nil")
    if "tomorrow" in ovr:
        parts.append(f":tomorrow {_quote(ovr['tomorrow'])}")
    else:
        parts.append(":tomorrow nil")
    if "yesterday" in ovr:
        parts.append(f":yesterday {_quote(ovr['yesterday'])}")
    else:
        parts.append(":yesterday nil")
    return "{" + " ".join(parts) + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    ns = _ns_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix=";; ")]
    lines.append(f"(ns sayabledate.locales.{ns})")
    lines.append("")
    lines.append("(def locale")

    parts = []
    parts.append(f"  {{:code {_quote(code)}")
    parts.append(f"   :months {_str_vec(data['months'])}")
    parts.append(f"   :weekdays {_str_vec(data['weekdays'])}")
    parts.append(f"   :day-format {_quote(data['dayFormat'])}")

    exceptions = data.get("dayFormatExceptions", {})
    parts.append(f"   :day-format-exceptions {_str_map(exceptions)}")

    parts.append(f"   :date-pattern {_quote(data['datePattern'])}")
    parts.append(f"   :date-pattern-with-year {_quote(data['datePatternWithYear'])}")
    parts.append(f"   :today {_quote(data['today'])}")
    parts.append(f"   :tomorrow {_quote(data['tomorrow'])}")
    parts.append(f"   :yesterday {_quote(data['yesterday'])}")

    if "dayAfterTomorrow" in data:
        parts.append(f"   :day-after-tomorrow {_quote(data['dayAfterTomorrow'])}")
    else:
        parts.append("   :day-after-tomorrow nil")
    if "dayBeforeYesterday" in data:
        parts.append(f"   :day-before-yesterday {_quote(data['dayBeforeYesterday'])}")
    else:
        parts.append("   :day-before-yesterday nil")
    if "thisWeekday" in data:
        parts.append(f"   :this-weekday {_quote(data['thisWeekday'])}")
    else:
        parts.append("   :this-weekday nil")
    if "nextWeekday" in data:
        parts.append(f"   :next-weekday {_quote(data['nextWeekday'])}")
    else:
        parts.append("   :next-weekday nil")
    if "lastWeekday" in data:
        parts.append(f"   :last-weekday {_quote(data['lastWeekday'])}")
    else:
        parts.append("   :last-weekday nil")
    if "monthsInDate" in data:
        parts.append(f"   :months-in-date {_str_vec(data['monthsInDate'])}")
    else:
        parts.append("   :months-in-date nil")

    for mode in ("short", "compact"):
        if mode in data:
            parts.append(f"   :{mode} {_compactness_override(data[mode])}")
        else:
            parts.append(f"   :{mode} nil")

    lines.append("\n".join(parts) + "})")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the sayabledate.locales barrel namespace."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("(ns sayabledate.locales")
    lines.append("  (:require")
    for loc in sorted_locs:
        ns = _ns_name(loc["code"])
        lines.append(f"    [sayabledate.locales.{ns} :as {ns}]")
    lines.append("    ))")
    lines.append("")
    lines.append("(defn get-locale [code]")
    lines.append("  (case code")
    for loc in sorted_locs:
        code = loc["code"]
        ns = _ns_name(code)
        lines.append(f'    "{code}" {ns}/locale')
    lines.append("    nil))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    ns = _ns_name(code)
    return os.path.join(root, "impl", "clojure", "src", "sayabledate", "locales", f"{ns}.clj")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "clojure", "src", "sayabledate", "locales.clj")

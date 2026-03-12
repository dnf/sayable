"""Common Lisp locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/lisp/emitter.py", line_prefix=";; ")


def _quote(s: str) -> str:
    """Quote a string for Common Lisp."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Lisp list of strings."""
    return "(list " + " ".join(_quote(s) for s in items) + ")"


def _alist(d: dict[str, str]) -> str:
    """Emit a Lisp alist from a string->string dict."""
    if not d:
        return "nil"
    pairs = [f'(cons {_quote(k)} {_quote(v)})' for k, v in d.items()]
    return "(list " + " ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    """Generate a Common Lisp locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    lines = [HEADER + locale_source_comment(code, line_prefix=";; "), f";;; {name} locale.", ""]
    lines.append("(in-package :sayable-date)")
    lines.append("")

    lines.append(f"(defparameter *locale-{code}*")
    lines.append("  (make-date-locale")
    lines.append(f"   :code {_quote(code)}")
    lines.append(f"   :months {_str_list(data['months'])}")
    lines.append(f"   :weekdays {_str_list(data['weekdays'])}")
    lines.append(f"   :day-format {_quote(data['dayFormat'])}")

    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"   :day-format-exceptions {_alist(data['dayFormatExceptions'])}")
    else:
        lines.append("   :day-format-exceptions nil")

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
        if "months" in ovr:
            lines.append(f"   :short-months {_str_list(ovr['months'])}")
        if "weekdays" in ovr:
            lines.append(f"   :short-weekdays {_str_list(ovr['weekdays'])}")
        if "dayFormat" in ovr:
            lines.append(f"   :short-day-format {_quote(ovr['dayFormat'])}")
        if "dayFormatExceptions" in ovr:
            lines.append(f"   :short-day-format-exceptions {_alist(ovr['dayFormatExceptions'])}")
        if "datePattern" in ovr:
            lines.append(f"   :short-date-pattern {_quote(ovr['datePattern'])}")
        if "datePatternWithYear" in ovr:
            lines.append(f"   :short-date-pattern-with-year {_quote(ovr['datePatternWithYear'])}")

    # Compact override
    if "compact" in data:
        ovr = data["compact"]
        if "datePattern" in ovr:
            lines.append(f"   :compact-date-pattern {_quote(ovr['datePattern'])}")
        if "datePatternWithYear" in ovr:
            lines.append(f"   :compact-date-pattern-with-year {_quote(ovr['datePatternWithYear'])}")

    lines.append("))")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locale registry file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, ";;; Locale registry — maps code strings to locale objects.", ""]
    lines.append("(in-package :sayable-date)")
    lines.append("")

    lines.append(";; All locale files are loaded via load-locales.lisp.")
    lines.append("")

    lines.append("(defparameter *all-locales*")
    lines.append("  (list")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'   (cons "{code}" *locale-{code}*)')
    lines.append("))")
    lines.append("")

    lines.append("(defun get-locale (code)")
    lines.append('  "Look up a locale by its code string. Returns NIL if not found."')
    lines.append("  (cdr (assoc code *all-locales* :test #'string=)))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "lisp", "locales", f"{code}.lisp")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "lisp", "locales", "registry.lisp")

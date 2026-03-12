"""Common Lisp locale emitter for sayable-time."""

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


def emit_locale(data: dict) -> str:
    """Generate a Common Lisp locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]
    lines = [HEADER + locale_source_comment(code, line_prefix=";; "), f";;; {name} locale.", ""]
    lines.append("(in-package :sayable-time)")
    lines.append("")

    lines.append(f"(defparameter *locale-{code}*")
    lines.append("  (make-time-locale")
    lines.append(f"   :code {_quote(code)}")

    # Clock config
    lines.append("   :clock (make-clock-config")
    lines.append(f"    :hours {_str_list(clock['hours'])}")
    lines.append(f"    :midnight {_quote(clock['midnight'])}")
    lines.append(f"    :noon {_quote(clock['noon'])}")

    # Patterns as alist
    pattern_keys = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    pattern_parts = []
    for key in pattern_keys:
        if key in clock["patterns"]:
            pattern_parts.append(f"(cons {key} {_quote(clock['patterns'][key])})")
    lines.append("    :patterns (list " + " ".join(pattern_parts) + "))")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "t" if sc.get("use24h", True) else "nil"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append(f"   :short-clock (make-short-clock-config :use24h {use24h} :format {_quote(fmt)} :am-pm (cons {_quote(am_pm[0])} {_quote(am_pm[1])}))")
        else:
            lines.append(f"   :short-clock (make-short-clock-config :use24h {use24h} :format {_quote(fmt)})")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "t" if sc.get("use24h", True) else "nil"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append(f"   :compact-clock (make-short-clock-config :use24h {use24h} :format {_quote(fmt)} :am-pm (cons {_quote(am_pm[0])} {_quote(am_pm[1])}))")
        else:
            lines.append(f"   :compact-clock (make-short-clock-config :use24h {use24h} :format {_quote(fmt)})")

    lines.append("))")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locale registry file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, ";;; Locale registry — maps code strings to locale objects.", ""]
    lines.append("(in-package :sayable-time)")
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

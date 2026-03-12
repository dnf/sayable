"""Common Lisp locale emitter for sayable-duration."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.lisp.plural_rules import get_lisp_named_function, get_lisp_plural, is_simple_plural

HEADER = make_header("codegen/targets/lisp/emitter.py", line_prefix=";; ")


def _quote(s: str) -> str:
    """Quote a string for Common Lisp."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    """Emit a unit-forms value as a Lisp expression."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"(:{cat} . {_quote(unit[cat])})")
    return "'(" + " ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    """Generate a Common Lisp locale file from canonical JSON."""
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    lines = [HEADER + locale_source_comment(code, line_prefix=";; "), f";;; {name} locale.", ""]
    lines.append("(in-package :sayable-duration)")
    lines.append("")

    # Named plural function (if needed) — guarded to avoid redefinition warnings
    named_fn = get_lisp_named_function(rule)
    if named_fn:
        fn_name = f"plural-{rule.replace('_', '-')}"
        lines.append(f"(unless (fboundp '{fn_name})")
        lines.append(named_fn)
        lines.append(")")
        lines.append("")

    # Locale definition
    plural_expr = get_lisp_plural(rule)
    lines.append(f"(defparameter *locale-{code}*")
    lines.append("  (make-duration-locale")
    lines.append(f"   :code {_quote(code)}")
    lines.append(f"   :plural {plural_expr}")

    # Units (7 time units)
    lines.append(f"   :units (list (cons :second {_unit_forms(data['units']['second'])})")
    lines.append(f"               (cons :minute {_unit_forms(data['units']['minute'])})")
    lines.append(f"               (cons :hour {_unit_forms(data['units']['hour'])})")
    lines.append(f"               (cons :day {_unit_forms(data['units']['day'])})")
    lines.append(f"               (cons :week {_unit_forms(data['units']['week'])})")
    lines.append(f"               (cons :month {_unit_forms(data['units']['month'])})")
    lines.append(f"               (cons :year {_unit_forms(data['units']['year'])}))")

    # Simple fields
    lines.append(f"   :half {_quote(data['half'])}")
    lines.append(f"   :delimiter {_quote(data['delimiter'])}")
    lines.append(f"   :just-now {_quote(data['justNow'])}")
    lines.append(f"   :ago {_quote(data['ago'])}")
    lines.append(f"   :in-future {_quote(data['inFuture'])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "units" in ovr:
                unit_parts = []
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        unit_parts.append(f"(cons :{unit_name} {_unit_forms(ovr['units'][unit_name])})")
                lines.append(f"   :{mode}-units (list " + "\n                       ".join(unit_parts) + ")")
            if "half" in ovr:
                lines.append(f"   :{mode}-half {_quote(ovr['half'])}")
            if "delimiter" in ovr:
                lines.append(f"   :{mode}-delimiter {_quote(ovr['delimiter'])}")
            if "ago" in ovr:
                lines.append(f"   :{mode}-ago {_quote(ovr['ago'])}")
            if "inFuture" in ovr:
                lines.append(f"   :{mode}-in-future {_quote(ovr['inFuture'])}")

    lines.append("))")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locale registry file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, ";;; Locale registry — maps code strings to locale objects.", ""]
    lines.append("(in-package :sayable-duration)")
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

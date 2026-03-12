"""Racket locale emitter for sayable-date."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/racket/emitter.py", line_prefix="; ")


def _quote(s: str) -> str:
    """Quote a string for Racket."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _module_name(code: str) -> str:
    """Convert locale code to Racket module name."""
    return code.replace("-", "_")


def _str_list(items: list[str]) -> str:
    """Emit a Racket list of strings."""
    return "(list " + " ".join(_quote(s) for s in items) + ")"


def _dict_str(d: dict[str, str]) -> str:
    """Emit a Racket hash of string->string."""
    pairs = []
    for k, v in d.items():
        pairs.append(f'{_quote(k)} {_quote(v)}')
    return "(hash " + " ".join(pairs) + ")"


def emit_locale(data: dict) -> str:
    code = data["code"]
    name = data["name"]
    mod = _module_name(code)

    # #lang must be first line in Racket files
    lines = ["#lang racket\n"]
    lines.append(HEADER + locale_source_comment(code, line_prefix="; "))
    lines.append(f"; {name} locale.\n")
    lines.append('(require "../locale.rkt")\n')
    lines.append(f"(provide {mod})\n")

    lines.append(f"(define {mod}")
    lines.append("  (date-locale")
    lines.append(f"   {_quote(code)}")

    # months
    lines.append(f"   {_str_list(data['months'])}")

    # weekdays
    lines.append(f"   {_str_list(data['weekdays'])}")

    # dayFormat
    lines.append(f"   {_quote(data['dayFormat'])}")

    # dayFormatExceptions
    if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
        lines.append(f"   {_dict_str(data['dayFormatExceptions'])}")
    else:
        lines.append("   (hash)")

    # datePattern
    lines.append(f"   {_quote(data['datePattern'])}")

    # datePatternWithYear
    lines.append(f"   {_quote(data['datePatternWithYear'])}")

    # today, tomorrow, yesterday
    lines.append(f"   {_quote(data['today'])}")
    lines.append(f"   {_quote(data['tomorrow'])}")
    lines.append(f"   {_quote(data['yesterday'])}")

    # Optional proximity fields
    if "dayAfterTomorrow" in data:
        lines.append(f"   {_quote(data['dayAfterTomorrow'])}")
    else:
        lines.append("   #f")

    if "dayBeforeYesterday" in data:
        lines.append(f"   {_quote(data['dayBeforeYesterday'])}")
    else:
        lines.append("   #f")

    if "thisWeekday" in data:
        lines.append(f"   {_quote(data['thisWeekday'])}")
    else:
        lines.append("   #f")

    if "nextWeekday" in data:
        lines.append(f"   {_quote(data['nextWeekday'])}")
    else:
        lines.append("   #f")

    if "lastWeekday" in data:
        lines.append(f"   {_quote(data['lastWeekday'])}")
    else:
        lines.append("   #f")

    # monthsInDate (optional genitive months)
    if "monthsInDate" in data:
        lines.append(f"   {_str_list(data['monthsInDate'])}")
    else:
        lines.append("   #f")

    # Short override
    if "short" in data:
        lines.append(f"   {_compactness_override(data['short'])}")
    else:
        lines.append("   #f")

    # Compact override
    if "compact" in data:
        lines.append(f"   {_compactness_override(data['compact'])}")
    else:
        lines.append("   #f")

    lines.append("  ))")
    lines.append("")

    return "\n".join(lines)


def _compactness_override(ovr: dict) -> str:
    parts = []

    # months
    if "months" in ovr:
        parts.append(_str_list(ovr["months"]))
    else:
        parts.append("#f")

    # monthsInDate
    if "monthsInDate" in ovr:
        parts.append(_str_list(ovr["monthsInDate"]))
    else:
        parts.append("#f")

    # weekdays
    if "weekdays" in ovr:
        parts.append(_str_list(ovr["weekdays"]))
    else:
        parts.append("#f")

    # dayFormat
    if "dayFormat" in ovr:
        parts.append(_quote(ovr["dayFormat"]))
    else:
        parts.append("#f")

    # dayFormatExceptions
    if "dayFormatExceptions" in ovr:
        parts.append(_dict_str(ovr["dayFormatExceptions"]))
    else:
        parts.append("#f")

    # datePattern
    if "datePattern" in ovr:
        parts.append(_quote(ovr["datePattern"]))
    else:
        parts.append("#f")

    # datePatternWithYear
    if "datePatternWithYear" in ovr:
        parts.append(_quote(ovr["datePatternWithYear"]))
    else:
        parts.append("#f")

    # today
    if "today" in ovr:
        parts.append(_quote(ovr["today"]))
    else:
        parts.append("#f")

    # tomorrow
    if "tomorrow" in ovr:
        parts.append(_quote(ovr["tomorrow"]))
    else:
        parts.append("#f")

    # yesterday
    if "yesterday" in ovr:
        parts.append(_quote(ovr["yesterday"]))
    else:
        parts.append("#f")

    return "(date-compactness-override " + " ".join(parts) + ")"


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the registry.rkt barrel module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    # #lang must be first line
    lines = ["#lang racket\n"]
    lines.append(HEADER)

    # Require all locale modules
    lines.append("(require")
    for loc in sorted_locs:
        mod = _module_name(loc["code"])
        lines.append(f'  "{mod}.rkt"')
    lines.append(")\n")

    lines.append("(provide get-locale)\n")

    # Build lookup hash
    lines.append("(define all-locales")
    lines.append("  (hash")
    for loc in sorted_locs:
        code = loc["code"]
        mod = _module_name(code)
        lines.append(f'   "{code}" {mod}')
    lines.append("  ))\n")

    lines.append("(define (get-locale code)")
    lines.append("  (hash-ref all-locales code #f))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    mod = _module_name(code)
    return os.path.join(root, "impl", "racket", "locales", f"{mod}.rkt")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "racket", "locales", "registry.rkt")

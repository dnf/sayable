"""Racket locale emitter for sayable-time."""

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


def emit_locale(data: dict) -> str:
    """Generate a Racket locale file from canonical JSON."""
    code = data["code"]
    name = data["name"]
    clock = data["clock"]
    mod = _module_name(code)

    # #lang must be first line in Racket files
    lines = ["#lang racket\n"]
    lines.append(HEADER + locale_source_comment(code, line_prefix="; "))
    lines.append(f"; {name} locale.\n")
    lines.append('(require "../locale.rkt")\n')
    lines.append(f"(provide {mod})\n")

    lines.append(f"(define {mod}")
    lines.append("  (time-locale")
    lines.append(f"   {_quote(code)}")

    # Clock config
    lines.append("   (clock-config")
    lines.append(f"    {_str_list(clock['hours'])}")
    lines.append(f"    {_quote(clock['midnight'])}")
    lines.append(f"    {_quote(clock['noon'])}")

    # Patterns hash
    pattern_keys = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
    pattern_pairs = []
    for key in pattern_keys:
        if key in clock["patterns"]:
            pattern_pairs.append(f'{int(key)} {_quote(clock["patterns"][key])}')
    lines.append("    (hash " + " ".join(pattern_pairs) + "))")

    # Short override
    if "short" in data:
        lines.append(f"   {_short_clock_override(data['short'])}")
    else:
        lines.append("   #f")

    # Compact override
    if "compact" in data:
        lines.append(f"   {_short_clock_override(data['compact'])}")
    else:
        lines.append("   #f")

    lines.append("  ))")
    lines.append("")

    return "\n".join(lines)


def _short_clock_override(ovr: dict) -> str:
    """Emit a time-compactness-override."""
    sc = ovr.get("clock", {})
    use24h = "#t" if sc.get("use24h", True) else "#f"
    fmt = _quote(sc.get("format", "{h}:{mm}"))
    am_pm = sc.get("amPm")
    if am_pm:
        am_pm_expr = f"(cons {_quote(am_pm[0])} {_quote(am_pm[1])})"
    else:
        am_pm_expr = "#f"
    return f"(time-compactness-override (short-clock-config {use24h} {fmt} {am_pm_expr}))"


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

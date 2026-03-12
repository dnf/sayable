"""Prolog locale emitter for sayable-duration."""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.prolog.plural_rules import get_pl_plural

HEADER = make_header("codegen/targets/prolog/emitter.py", line_prefix="% ")


def _quote(s: str) -> str:
    """Quote a string as a Prolog atom using single quotes."""
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_clauses(code: str, unit_name: str, unit: object, prefix: str = "") -> list[str]:
    """Emit unit clauses for a locale."""
    pred = f"{prefix}sd_unit" if prefix else "sd_unit"
    lines = []
    if isinstance(unit, str):
        lines.append(f"{pred}({_quote(code)}, {unit_name}, _, {_quote(unit)}).")
    else:
        cats = ["zero", "one", "two", "few", "many", "other"]
        for cat in cats:
            if cat in unit:
                lines.append(f"{pred}({_quote(code)}, {unit_name}, {cat}, {_quote(unit[cat])}).")
    return lines


def _plural_clauses(code: str, rule: str) -> str:
    """Emit plural clauses prefixed with the locale code."""
    raw = get_pl_plural(rule)
    lines = []
    for line in raw.split("\n"):
        line = line.strip()
        if not line:
            continue
        line = line.replace("plural(", f"sd_plural({_quote(code)}, ", 1)
        lines.append(line)
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    """Generate a Prolog locale file from canonical JSON."""
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="% ")]
    lines.append(f"% {name} locale.\n")

    # Plural rules
    lines.append(_plural_clauses(code, rule))
    lines.append("")

    # Units
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        unit_lines = _unit_clauses(code, unit_name, data["units"][unit_name])
        lines.extend(unit_lines)
    lines.append("")

    # Simple fields
    lines.append(f"sd_half({_quote(code)}, {_quote(data['half'])}).")
    lines.append(f"sd_delimiter({_quote(code)}, {_quote(data['delimiter'])}).")
    lines.append(f"sd_just_now({_quote(code)}, {_quote(data['justNow'])}).")
    lines.append(f"sd_ago({_quote(code)}, {_quote(data['ago'])}).")
    lines.append(f"sd_in_future({_quote(code)}, {_quote(data['inFuture'])}).")
    lines.append("")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "units" in ovr:
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        unit_lines = _unit_clauses(
                            code, unit_name, ovr["units"][unit_name],
                            prefix=f"{mode}_",
                        )
                        lines.extend(unit_lines)
            if "half" in ovr:
                lines.append(f"{mode}_sd_half({_quote(code)}, {_quote(ovr['half'])}).")
            if "delimiter" in ovr:
                lines.append(f"{mode}_sd_delimiter({_quote(code)}, {_quote(ovr['delimiter'])}).")
            if "ago" in ovr:
                lines.append(f"{mode}_sd_ago({_quote(code)}, {_quote(ovr['ago'])}).")
            if "inFuture" in ovr:
                lines.append(f"{mode}_sd_in_future({_quote(code)}, {_quote(ovr['inFuture'])}).")
            lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the locales/registry.pl barrel file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "% Locale registry — loads all locale files.\n"]

    # Discontiguous declarations
    lines.append(":- discontiguous sd_plural/3.")
    lines.append(":- discontiguous sd_unit/4.")
    lines.append(":- discontiguous sd_half/2.")
    lines.append(":- discontiguous sd_delimiter/2.")
    lines.append(":- discontiguous sd_just_now/2.")
    lines.append(":- discontiguous sd_ago/2.")
    lines.append(":- discontiguous sd_in_future/2.")
    lines.append(":- discontiguous short_sd_unit/4.")
    lines.append(":- discontiguous short_sd_half/2.")
    lines.append(":- discontiguous short_sd_delimiter/2.")
    lines.append(":- discontiguous short_sd_ago/2.")
    lines.append(":- discontiguous short_sd_in_future/2.")
    lines.append(":- discontiguous compact_sd_unit/4.")
    lines.append(":- discontiguous compact_sd_half/2.")
    lines.append(":- discontiguous compact_sd_delimiter/2.")
    lines.append(":- discontiguous compact_sd_ago/2.")
    lines.append(":- discontiguous compact_sd_in_future/2.")
    lines.append("")

    # Include all locale files
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f":- include('{code}').")

    lines.append("")

    # sd_locale/1: succeeds if code is known
    lines.append("% sd_locale(+Code) - succeeds if Code is a known locale.")
    for loc in sorted_locs:
        lines.append(f"sd_locale({_quote(loc['code'])}).")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", f"{code}.pl")


def barrel_path(root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", "registry.pl")

"""Prolog locale emitter."""

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
    pred = f"{prefix}sa_unit" if prefix else "sa_unit"
    lines = []
    if isinstance(unit, str):
        lines.append(f"{pred}({_quote(code)}, {unit_name}, _, {_quote(unit)}).")
    else:
        cats = ["zero", "one", "two", "few", "many", "other"]
        for cat in cats:
            if cat in unit:
                lines.append(f"{pred}({_quote(code)}, {unit_name}, {cat}, {_quote(unit[cat])}).")
    return lines


def _stage_clauses(code: str, stage_name: str, stage: object) -> list[str]:
    """Emit stage clauses for a locale."""
    if isinstance(stage, str):
        return [f"sa_stage({_quote(code)}, {stage_name}, _, {_quote(stage)})."]
    return [
        f"sa_stage({_quote(code)}, {stage_name}, m, {_quote(stage['m'])}).",
        f"sa_stage({_quote(code)}, {stage_name}, f, {_quote(stage['f'])}).",
        f"sa_stage({_quote(code)}, {stage_name}, _, {_quote(stage['m'])}).",
    ]


def _plural_clauses(code: str, rule: str) -> str:
    """Emit plural clauses prefixed with the locale code."""
    raw = get_pl_plural(rule)
    lines = []
    for line in raw.split("\n"):
        line = line.strip()
        if not line:
            continue
        # Replace plural(... with sa_plural(Code, ...
        line = line.replace("plural(", f"sa_plural({_quote(code)}, ", 1)
        lines.append(line)
    return "\n".join(lines)


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]

    lines = [HEADER + locale_source_comment(code, line_prefix="% ")]
    lines.append(f"% {name} locale.\n")

    # Plural rules
    lines.append(_plural_clauses(code, rule))
    lines.append("")

    # Units
    for unit_name in ("day", "week", "month", "year"):
        unit_lines = _unit_clauses(code, unit_name, data["units"][unit_name])
        lines.extend(unit_lines)
    lines.append("")

    # Simple fields
    lines.append(f"sa_half({_quote(code)}, {_quote(data['half'])}).")
    lines.append(f"sa_delimiter({_quote(code)}, {_quote(data['delimiter'])}).")
    lines.append(f"sa_just_born({_quote(code)}, {_quote(data['justBorn'])}).")
    lines.append("")

    # Stages
    for stage_name in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        stage_lines = _stage_clauses(code, stage_name, data["stages"][stage_name])
        lines.extend(stage_lines)
    lines.append("")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "units" in ovr:
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        unit_lines = _unit_clauses(
                            code, unit_name, ovr["units"][unit_name],
                            prefix=f"{mode}_",
                        )
                        lines.extend(unit_lines)
            if "half" in ovr:
                lines.append(f"{mode}_sa_half({_quote(code)}, {_quote(ovr['half'])}).")
            if "delimiter" in ovr:
                lines.append(f"{mode}_sa_delimiter({_quote(code)}, {_quote(ovr['delimiter'])}).")
            if "justBorn" in ovr:
                lines.append(f"{mode}_sa_just_born({_quote(code)}, {_quote(ovr['justBorn'])}).")
            lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "% Locale registry — loads all locale files.\n"]

    # Multifile declarations so locale files can add clauses
    lines.append(":- discontiguous sa_plural/3.")
    lines.append(":- discontiguous sa_unit/4.")
    lines.append(":- discontiguous sa_half/2.")
    lines.append(":- discontiguous sa_delimiter/2.")
    lines.append(":- discontiguous sa_just_born/2.")
    lines.append(":- discontiguous sa_stage/4.")
    lines.append(":- discontiguous short_sa_unit/4.")
    lines.append(":- discontiguous short_sa_half/2.")
    lines.append(":- discontiguous short_sa_delimiter/2.")
    lines.append(":- discontiguous short_sa_just_born/2.")
    lines.append(":- discontiguous compact_sa_unit/4.")
    lines.append(":- discontiguous compact_sa_half/2.")
    lines.append(":- discontiguous compact_sa_delimiter/2.")
    lines.append(":- discontiguous compact_sa_just_born/2.")
    lines.append("")

    # Include all locale files
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f":- include('{code}').")

    lines.append("")

    # get_locale/1: succeeds if code is known
    lines.append("% get_locale(+Code) - succeeds if Code is a known locale.")
    for loc in sorted_locs:
        lines.append(f"sa_locale({_quote(loc['code'])}).")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", f"{code}.pl")


def barrel_path(root: str) -> str:
    return os.path.join(root, "impl", "prolog", "locales", "registry.pl")

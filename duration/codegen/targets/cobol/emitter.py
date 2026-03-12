"""COBOL locale emitter for sayable-duration -- active-locale pattern.

Generates a single Locales.cbl COBOL copybook containing:
  - One INIT-LOCALE-XX paragraph per locale (populates WS-ACT-* fields)
  - A GET-LOCALE paragraph that dispatches by WS-LOOKUP-CODE
  - Deduplicated APPLY-PLURAL-RULE + PLURAL-RULE-* paragraphs
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.cobol.plural_rules import get_cobol_plural

HEADER = make_header("codegen/targets/cobol/emitter.py", line_prefix="*> ", line_suffix="")

_CAT_LIST = ["zero", "one", "two", "few", "many", "other"]
_CAT_IDX = {"zero": 1, "one": 2, "two": 3, "few": 4, "many": 5, "other": 6}

_MAX_STR_LEN = 256

_UNIT_NAMES = ("SECOND", "MINUTE", "HOUR", "DAY", "WEEK", "MONTH", "YEAR")
_UNIT_JSON = ("second", "minute", "hour", "day", "week", "month", "year")


def _quote(s: str) -> str:
    """Escape a string for COBOL literal. Empty strings become SPACES."""
    if not s:
        return "SPACES"
    escaped = s.replace('"', '""')
    return f'"{escaped}"'


def _para_name(code: str) -> str:
    """Return a COBOL paragraph name for a locale code."""
    return f"INIT-LOCALE-{code.upper().replace('-', '-')}"


def _unit_forms_lines(unit: object, var: str, indent: str = "           ") -> list[str]:
    """Emit MOVE statements to initialize active unit-forms fields."""
    lines = []
    if isinstance(unit, str):
        lines.append(f"{indent}MOVE 1 TO {var}-HAS-SIMPLE")
        lines.append(f"{indent}MOVE {_quote(unit)} TO {var}-SIMPLE")
        for idx in range(1, 7):
            lines.append(f"{indent}MOVE 0 TO {var}-HAS-FORM({idx})")
    else:
        lines.append(f"{indent}MOVE 0 TO {var}-HAS-SIMPLE")
        lines.append(f'{indent}MOVE SPACES TO {var}-SIMPLE')
        for cat in _CAT_LIST:
            idx = _CAT_IDX[cat]
            if cat in unit:
                lines.append(f"{indent}MOVE 1 TO {var}-HAS-FORM({idx})")
                lines.append(f"{indent}MOVE {_quote(unit[cat])}")
                lines.append(f"{indent}    TO {var}-FORM({idx})")
            else:
                lines.append(f"{indent}MOVE 0 TO {var}-HAS-FORM({idx})")
                lines.append(f'{indent}MOVE SPACES TO {var}-FORM({idx})')
    return lines


def _compactness_lines(ovr: dict, var: str, indent: str = "           ") -> list[str]:
    """Emit MOVE statements for a compactness override block."""
    lines = []
    for unit_cobol, json_key in zip(_UNIT_NAMES, _UNIT_JSON):
        if "units" in ovr and json_key in ovr["units"]:
            lines.append(f"{indent}MOVE 1 TO {var}-HAS-{unit_cobol}")
            for sl in _unit_forms_lines(ovr["units"][json_key], f"{var}-{unit_cobol}", indent):
                lines.append(sl)
        else:
            lines.append(f"{indent}MOVE 0 TO {var}-HAS-{unit_cobol}")
    if "half" in ovr:
        lines.append(f"{indent}MOVE 1 TO {var}-HAS-HALF")
        lines.append(f"{indent}MOVE {_quote(ovr['half'])} TO {var}-HALF")
    else:
        lines.append(f"{indent}MOVE 0 TO {var}-HAS-HALF")
    if "delimiter" in ovr:
        lines.append(f"{indent}MOVE 1 TO {var}-HAS-DELIM")
        lines.append(f"{indent}MOVE {_quote(ovr['delimiter'])} TO {var}-DELIM")
        lines.append(f"{indent}MOVE {len(ovr['delimiter'].encode('utf-8'))} TO {var}-DELIM-LEN")
    else:
        lines.append(f"{indent}MOVE 0 TO {var}-HAS-DELIM")
    if "ago" in ovr:
        lines.append(f"{indent}MOVE 1 TO {var}-HAS-AGO")
        lines.append(f"{indent}MOVE {_quote(ovr['ago'])}")
        lines.append(f"{indent}    TO {var}-AGO")
    else:
        lines.append(f"{indent}MOVE 0 TO {var}-HAS-AGO")
    if "inFuture" in ovr:
        lines.append(f"{indent}MOVE 1 TO {var}-HAS-IN-FUTURE")
        lines.append(f"{indent}MOVE {_quote(ovr['inFuture'])}")
        lines.append(f"{indent}    TO {var}-IN-FUTURE")
    else:
        lines.append(f"{indent}MOVE 0 TO {var}-HAS-IN-FUTURE")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single Locales.cbl copybook."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())

    # Collect plural rules used (deduplicated)
    rules_used: dict[str, str] = {}
    for data in sorted_locs:
        rule = data["pluralRule"]
        if rule not in rules_used:
            rules_used[rule] = get_cobol_plural(rule)

    # GET-LOCALE dispatcher paragraph
    lines.append("       GET-LOCALE.")
    lines.append("           MOVE 0 TO WS-LOOKUP-FOUND")
    lines.append("           EVALUATE WS-LOOKUP-CODE")
    for data in sorted_locs:
        code = data["code"]
        lines.append(f'               WHEN "{code}"')
        lines.append(f"                   PERFORM {_para_name(code)}")
        lines.append("                   MOVE 1 TO WS-LOOKUP-FOUND")
    lines.append("           END-EVALUATE")
    lines.append("           .")
    lines.append("")

    # APPLY-PLURAL-RULE dispatcher paragraph
    lines.append("       APPLY-PLURAL-RULE.")
    lines.append("           EVALUATE WS-ACT-PLURAL-RULE")
    for rule_name in sorted(rules_used.keys()):
        cobol_rule = rule_name.upper().replace("_", "-")
        lines.append(f'               WHEN "{rule_name}"')
        lines.append(f"                   PERFORM PLURAL-RULE-{cobol_rule}")
    lines.append("           END-EVALUATE")
    lines.append("           .")
    lines.append("")

    # Plural rule paragraphs (deduplicated)
    for rule_name, body in sorted(rules_used.items()):
        cobol_rule = rule_name.upper().replace("_", "-")
        fn_name = f"PLURAL-RULE-{cobol_rule}"
        lines.append(f"       {fn_name}.")
        for line in body.split("\n"):
            lines.append(line)
        lines.append("           .")
        lines.append("")

    # INIT-LOCALE-XX paragraphs
    for data in sorted_locs:
        code = data["code"]
        rule = data["pluralRule"]

        lines.append(locale_source_comment(code, line_prefix="*> ", line_suffix="").rstrip())
        lines.append(f"       {_para_name(code)}.")
        lines.append(f'           MOVE "{code}" TO WS-ACT-CODE')
        lines.append(f'           MOVE "{rule}" TO WS-ACT-PLURAL-RULE')

        # Units
        for unit_cobol, json_key in zip(_UNIT_NAMES, _UNIT_JSON):
            unit_val = data["units"][json_key]
            for sl in _unit_forms_lines(unit_val, f"WS-ACT-{unit_cobol}"):
                lines.append(sl)

        # Scalars: half, delimiter, justNow, ago, inFuture
        lines.append(f'           MOVE {_quote(data["half"])}')
        lines.append(f'               TO WS-ACT-HALF')
        lines.append(f'           MOVE {_quote(data["delimiter"])}')
        lines.append(f'               TO WS-ACT-DELIMITER')
        lines.append(f'           MOVE {len(data["delimiter"].encode("utf-8"))} TO WS-ACT-DELIM-LEN')
        lines.append(f'           MOVE {_quote(data["justNow"])}')
        lines.append(f'               TO WS-ACT-JUST-NOW')
        lines.append(f'           MOVE {_quote(data["ago"])}')
        lines.append(f'               TO WS-ACT-AGO')
        lines.append(f'           MOVE {_quote(data["inFuture"])}')
        lines.append(f'               TO WS-ACT-IN-FUTURE')

        # Short override
        if "short" in data:
            lines.append("           MOVE 1 TO WS-ACT-HAS-SHORT")
            for sl in _compactness_lines(data["short"], "WS-ACT-SHORT"):
                lines.append(sl)
        else:
            lines.append("           MOVE 0 TO WS-ACT-HAS-SHORT")

        # Compact override
        if "compact" in data:
            lines.append("           MOVE 1 TO WS-ACT-HAS-COMPACT")
            for sl in _compactness_lines(data["compact"], "WS-ACT-COMPACT"):
                lines.append(sl)
        else:
            lines.append("           MOVE 0 TO WS-ACT-HAS-COMPACT")

        lines.append("           .")
        lines.append("")

    lines.append("")
    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "cobol", "src", "locales", "Locales.cbl")

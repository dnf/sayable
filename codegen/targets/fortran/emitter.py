"""Fortran locale emitter — single file with all locales.

Generates a single parenttime_locales.f90 module containing all locale
definitions, plural rule functions, and a locale lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.fortran.plural_rules import get_fortran_plural

HEADER = make_header("codegen/targets/fortran/emitter.py", line_prefix="! ", line_suffix="")

_CAT_LIST = ["zero", "one", "two", "few", "many", "other"]

# Maximum string length for locale data (UTF-8 strings can be long)
_MAX_STR_LEN = 256


def _quote(s: str) -> str:
    """Escape a string for Fortran character literal."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _var_name(code: str) -> str:
    """Return a Fortran-safe variable name for a locale code."""
    return f"locale_{code}"


def _unit_forms_init(unit: object, indent: str = "    ") -> list[str]:
    """Emit lines that initialize a pt_unit_forms variable."""
    lines = []
    if isinstance(unit, str):
        lines.append(f"{indent}uf%simple = {_quote(unit)}")
        lines.append(f"{indent}uf%has_simple = .true.")
    else:
        lines.append(f"{indent}uf%has_simple = .false.")
        lines.append(f"{indent}uf%simple = ''")
        for cat in _CAT_LIST:
            idx = _CAT_LIST.index(cat) + 1
            if cat in unit:
                lines.append(f"{indent}uf%forms({idx}) = {_quote(unit[cat])}")
                lines.append(f"{indent}uf%has_form({idx}) = .true.")
            else:
                lines.append(f"{indent}uf%forms({idx}) = ''")
                lines.append(f"{indent}uf%has_form({idx}) = .false.")
    return lines


def _stage_label_init(stage: object, var: str, indent: str = "    ") -> list[str]:
    """Emit lines that set a stage label."""
    if isinstance(stage, str):
        return [
            f"{indent}{var}%label = {_quote(stage)}",
            f"{indent}{var}%f_label = ''",
        ]
    return [
        f"{indent}{var}%label = {_quote(stage['m'])}",
        f"{indent}{var}%f_label = {_quote(stage['f'])}",
    ]


def _compactness_init(ovr: dict, var: str, indent: str = "    ") -> list[str]:
    """Emit lines that initialize a compactness override."""
    lines = []
    for unit_name in ("day", "week", "month", "year"):
        if "units" in ovr and unit_name in ovr["units"]:
            lines.append(f"{indent}{var}%has_{unit_name} = .true.")
            unit_val = ovr["units"][unit_name]
            if isinstance(unit_val, str):
                lines.append(f"{indent}{var}%{unit_name}%simple = {_quote(unit_val)}")
                lines.append(f"{indent}{var}%{unit_name}%has_simple = .true.")
            else:
                lines.append(f"{indent}{var}%{unit_name}%has_simple = .false.")
                lines.append(f"{indent}{var}%{unit_name}%simple = ''")
                for cat in _CAT_LIST:
                    idx = _CAT_LIST.index(cat) + 1
                    if cat in unit_val:
                        lines.append(f"{indent}{var}%{unit_name}%forms({idx}) = {_quote(unit_val[cat])}")
                        lines.append(f"{indent}{var}%{unit_name}%has_form({idx}) = .true.")
                    else:
                        lines.append(f"{indent}{var}%{unit_name}%forms({idx}) = ''")
                        lines.append(f"{indent}{var}%{unit_name}%has_form({idx}) = .false.")
        else:
            lines.append(f"{indent}{var}%has_{unit_name} = .false.")
    if "half" in ovr:
        lines.append(f"{indent}{var}%has_half = .true.")
        lines.append(f"{indent}{var}%half = {_quote(ovr['half'])}")
    else:
        lines.append(f"{indent}{var}%has_half = .false.")
        lines.append(f"{indent}{var}%half = ''")
    if "delimiter" in ovr:
        lines.append(f"{indent}{var}%has_delimiter = .true.")
        lines.append(f"{indent}{var}%delimiter = {_quote(ovr['delimiter'])}")
        lines.append(f"{indent}{var}%delimiter_len = {len(ovr['delimiter'].encode('utf-8'))}")
    else:
        lines.append(f"{indent}{var}%has_delimiter = .false.")
        lines.append(f"{indent}{var}%delimiter = ''")
        lines.append(f"{indent}{var}%delimiter_len = 0")
    if "justBorn" in ovr:
        lines.append(f"{indent}{var}%has_just_born = .true.")
        lines.append(f"{indent}{var}%just_born = {_quote(ovr['justBorn'])}")
    else:
        lines.append(f"{indent}{var}%has_just_born = .false.")
        lines.append(f"{indent}{var}%just_born = ''")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single parenttime_locales.f90 module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("module parenttime_locales")
    lines.append("  use parenttime_types")
    lines.append("  implicit none")
    lines.append("  private")
    lines.append("")
    lines.append("  public :: pt_get_locale")
    lines.append("")
    # Declare module-level locale variables
    for data in sorted_locs:
        code = data["code"]
        lines.append(f"  type(pt_locale), target, save :: {_var_name(code)}")
    lines.append("")
    lines.append("  logical, save :: locales_initialized = .false.")
    lines.append("")
    lines.append("contains")
    lines.append("")

    # Plural rule functions (deduplicated)
    rules_used: dict[str, str] = {}
    for data in sorted_locs:
        rule = data["pluralRule"]
        if rule not in rules_used:
            rules_used[rule] = get_fortran_plural(rule)

    for rule_name, body in sorted(rules_used.items()):
        fn_name = f"plural_{rule_name}"
        lines.append(f"  function {fn_name}(n) result(pt_cat)")
        lines.append("    integer, intent(in) :: n")
        lines.append("    integer :: pt_cat")
        # Check for mod10 as a standalone variable (not as part of mod100)
        import re
        needs_mod10 = bool(re.search(r'\bmod10\b', body))
        needs_mod100 = bool(re.search(r'\bmod100\b', body))
        if needs_mod10 and needs_mod100:
            lines.append("    integer :: mod10, mod100")
        elif needs_mod10:
            lines.append("    integer :: mod10")
        elif needs_mod100:
            lines.append("    integer :: mod100")
        for line in body.split("\n"):
            lines.append(f"    {line}")
        lines.append(f"  end function {fn_name}")
        lines.append("")
    lines.append("")

    # Init functions per locale
    for data in sorted_locs:
        code = data["code"]
        rule = data["pluralRule"]
        var = _var_name(code)

        lines.append(locale_source_comment(code, line_prefix="  ! ", line_suffix="").rstrip())
        lines.append(f"  subroutine init_{code}()")
        lines.append(f"    {var}%code = {_quote(code)}")
        lines.append(f"    {var}%plural => plural_{rule}")
        lines.append("")

        # Units
        for unit_name in ("day", "week", "month", "year"):
            unit_val = data["units"][unit_name]
            if isinstance(unit_val, str):
                lines.append(f"    {var}%units%{unit_name}%has_simple = .true.")
                lines.append(f"    {var}%units%{unit_name}%simple = {_quote(unit_val)}")
                lines.append(f"    {var}%units%{unit_name}%has_form = .false.")
                lines.append(f"    {var}%units%{unit_name}%forms = ''")
            else:
                lines.append(f"    {var}%units%{unit_name}%has_simple = .false.")
                lines.append(f"    {var}%units%{unit_name}%simple = ''")
                for cat in _CAT_LIST:
                    idx = _CAT_LIST.index(cat) + 1
                    if cat in unit_val:
                        lines.append(f"    {var}%units%{unit_name}%forms({idx}) = {_quote(unit_val[cat])}")
                        lines.append(f"    {var}%units%{unit_name}%has_form({idx}) = .true.")
                    else:
                        lines.append(f"    {var}%units%{unit_name}%forms({idx}) = ''")
                        lines.append(f"    {var}%units%{unit_name}%has_form({idx}) = .false.")
        lines.append("")

        # Half, delimiter, justBorn
        lines.append(f"    {var}%half = {_quote(data['half'])}")
        lines.append(f"    {var}%delimiter = {_quote(data['delimiter'])}")
        lines.append(f"    {var}%delimiter_len = {len(data['delimiter'].encode('utf-8'))}")
        lines.append(f"    {var}%just_born = {_quote(data['justBorn'])}")
        lines.append("")

        # Stages
        for stage_name in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
            stage_val = data["stages"][stage_name]
            for sl in _stage_label_init(stage_val, f"{var}%stages%{stage_name}", "    "):
                lines.append(sl)
        lines.append("")

        # Short override
        if "short" in data:
            lines.append(f"    {var}%has_short = .true.")
            for sl in _compactness_init(data["short"], f"{var}%short_override", "    "):
                lines.append(sl)
        else:
            lines.append(f"    {var}%has_short = .false.")
        lines.append("")

        # Compact override
        if "compact" in data:
            lines.append(f"    {var}%has_compact = .true.")
            for sl in _compactness_init(data["compact"], f"{var}%compact_override", "    "):
                lines.append(sl)
        else:
            lines.append(f"    {var}%has_compact = .false.")
        lines.append("")

        lines.append(f"  end subroutine init_{code}")
        lines.append("")

    # Master init
    lines.append("  subroutine init_all_locales()")
    lines.append("    if (locales_initialized) return")
    for data in sorted_locs:
        lines.append(f"    call init_{data['code']}()")
    lines.append("    locales_initialized = .true.")
    lines.append("  end subroutine init_all_locales")
    lines.append("")

    # Locale lookup
    lines.append("  function pt_get_locale(code) result(loc)")
    lines.append("    character(len=*), intent(in) :: code")
    lines.append("    type(pt_locale), pointer :: loc")
    lines.append("    call init_all_locales()")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if (code == {_quote(c)}) then")
        lines.append(f"      loc => {_var_name(c)}")
        lines.append("      return")
        lines.append("    end if")
    lines.append("    nullify(loc)")
    lines.append("  end function pt_get_locale")
    lines.append("")

    lines.append("end module parenttime_locales")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "src", "fortran", "src", "locales", "parenttime_locales.f90")

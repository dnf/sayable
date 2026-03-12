"""Fortran locale emitter for sayable-duration — single file with all locales.

Generates a single sayableduration_locales.f90 module containing all locale
definitions, plural rule functions, and a locale lookup function.
"""

from __future__ import annotations

import os
import re

from codegen.banner import locale_source_comment, make_header
from codegen.targets.fortran.plural_rules import get_fortran_plural

HEADER = make_header("codegen/targets/fortran/emitter.py", line_prefix="! ", line_suffix="")

_CAT_LIST = ["zero", "one", "two", "few", "many", "other"]
_UNIT_NAMES = ("second", "minute", "hour", "day", "week", "month", "year")
_MAX_STR_LEN = 256


def _quote(s: str) -> str:
    """Escape a string for Fortran character literal."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _var_name(code: str) -> str:
    """Return a Fortran-safe variable name for a locale code."""
    return f"locale_{code}"


def _unit_forms_init(unit: object, var: str, indent: str = "    ") -> list[str]:
    """Emit lines that initialize a dur_unit_forms variable."""
    lines = []
    if isinstance(unit, str):
        lines.append(f"{indent}{var}%simple = {_quote(unit)}")
        lines.append(f"{indent}{var}%has_simple = .true.")
    else:
        lines.append(f"{indent}{var}%has_simple = .false.")
        lines.append(f"{indent}{var}%simple = ''")
        for cat in _CAT_LIST:
            idx = _CAT_LIST.index(cat) + 1
            if cat in unit:
                lines.append(f"{indent}{var}%forms({idx}) = {_quote(unit[cat])}")
                lines.append(f"{indent}{var}%has_form({idx}) = .true.")
            else:
                lines.append(f"{indent}{var}%forms({idx}) = ''")
                lines.append(f"{indent}{var}%has_form({idx}) = .false.")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single sayableduration_locales.f90 module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("module sayableduration_locales")
    lines.append("  use sayableduration_types")
    lines.append("  implicit none")
    lines.append("  private")
    lines.append("")
    lines.append("  public :: dur_get_locale")
    lines.append("")
    for data in sorted_locs:
        code = data["code"]
        lines.append(f"  type(dur_locale), target, save :: {_var_name(code)}")
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

    # Init subroutines per locale
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
        for unit_name in _UNIT_NAMES:
            unit_val = data["units"][unit_name]
            for sl in _unit_forms_init(unit_val, f"{var}%units%{unit_name}", "    "):
                lines.append(sl)
        lines.append("")

        # Half, delimiter, just_now, ago, in_future
        lines.append(f"    {var}%half = {_quote(data['half'])}")
        lines.append(f"    {var}%delimiter = {_quote(data['delimiter'])}")
        lines.append(f"    {var}%delimiter_len = {len(data['delimiter'].encode('utf-8'))}")
        lines.append(f"    {var}%just_now = {_quote(data['justNow'])}")
        lines.append(f"    {var}%ago = {_quote(data['ago'])}")
        lines.append(f"    {var}%in_future = {_quote(data['inFuture'])}")
        lines.append("")

        # Short override
        if "short" in data:
            lines.append(f"    {var}%has_short = .true.")
            short = data["short"]
            if "units" in short:
                for unit_name in _UNIT_NAMES:
                    if unit_name in short["units"]:
                        lines.append(f"    {var}%short_override%has_{unit_name} = .true.")
                        for sl in _unit_forms_init(short["units"][unit_name],
                                                    f"{var}%short_override%{unit_name}", "    "):
                            lines.append(sl)
                    else:
                        lines.append(f"    {var}%short_override%has_{unit_name} = .false.")
            else:
                for unit_name in _UNIT_NAMES:
                    lines.append(f"    {var}%short_override%has_{unit_name} = .false.")
            if "half" in short:
                lines.append(f"    {var}%short_override%has_half = .true.")
                lines.append(f"    {var}%short_override%half = {_quote(short['half'])}")
            else:
                lines.append(f"    {var}%short_override%has_half = .false.")
                lines.append(f"    {var}%short_override%half = ''")
            if "delimiter" in short:
                lines.append(f"    {var}%short_override%has_delimiter = .true.")
                lines.append(f"    {var}%short_override%delimiter = {_quote(short['delimiter'])}")
                lines.append(f"    {var}%short_override%delimiter_len = {len(short['delimiter'].encode('utf-8'))}")
            else:
                lines.append(f"    {var}%short_override%has_delimiter = .false.")
                lines.append(f"    {var}%short_override%delimiter = ''")
                lines.append(f"    {var}%short_override%delimiter_len = 0")
            if "ago" in short:
                lines.append(f"    {var}%short_override%has_ago = .true.")
                lines.append(f"    {var}%short_override%ago = {_quote(short['ago'])}")
            else:
                lines.append(f"    {var}%short_override%has_ago = .false.")
                lines.append(f"    {var}%short_override%ago = ''")
            if "inFuture" in short:
                lines.append(f"    {var}%short_override%has_in_future = .true.")
                lines.append(f"    {var}%short_override%in_future = {_quote(short['inFuture'])}")
            else:
                lines.append(f"    {var}%short_override%has_in_future = .false.")
                lines.append(f"    {var}%short_override%in_future = ''")
        else:
            lines.append(f"    {var}%has_short = .false.")
        lines.append("")

        # Compact override
        if "compact" in data:
            lines.append(f"    {var}%has_compact = .true.")
            compact = data["compact"]
            if "units" in compact:
                for unit_name in _UNIT_NAMES:
                    if unit_name in compact["units"]:
                        lines.append(f"    {var}%compact_override%has_{unit_name} = .true.")
                        for sl in _unit_forms_init(compact["units"][unit_name],
                                                    f"{var}%compact_override%{unit_name}", "    "):
                            lines.append(sl)
                    else:
                        lines.append(f"    {var}%compact_override%has_{unit_name} = .false.")
            else:
                for unit_name in _UNIT_NAMES:
                    lines.append(f"    {var}%compact_override%has_{unit_name} = .false.")
            if "half" in compact:
                lines.append(f"    {var}%compact_override%has_half = .true.")
                lines.append(f"    {var}%compact_override%half = {_quote(compact['half'])}")
            else:
                lines.append(f"    {var}%compact_override%has_half = .false.")
                lines.append(f"    {var}%compact_override%half = ''")
            if "delimiter" in compact:
                lines.append(f"    {var}%compact_override%has_delimiter = .true.")
                lines.append(f"    {var}%compact_override%delimiter = {_quote(compact['delimiter'])}")
                lines.append(f"    {var}%compact_override%delimiter_len = {len(compact['delimiter'].encode('utf-8'))}")
            else:
                lines.append(f"    {var}%compact_override%has_delimiter = .false.")
                lines.append(f"    {var}%compact_override%delimiter = ''")
                lines.append(f"    {var}%compact_override%delimiter_len = 0")
            if "ago" in compact:
                lines.append(f"    {var}%compact_override%has_ago = .true.")
                lines.append(f"    {var}%compact_override%ago = {_quote(compact['ago'])}")
            else:
                lines.append(f"    {var}%compact_override%has_ago = .false.")
                lines.append(f"    {var}%compact_override%ago = ''")
            if "inFuture" in compact:
                lines.append(f"    {var}%compact_override%has_in_future = .true.")
                lines.append(f"    {var}%compact_override%in_future = {_quote(compact['inFuture'])}")
            else:
                lines.append(f"    {var}%compact_override%has_in_future = .false.")
                lines.append(f"    {var}%compact_override%in_future = ''")
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
    lines.append("  function dur_get_locale(code) result(loc)")
    lines.append("    character(len=*), intent(in) :: code")
    lines.append("    type(dur_locale), pointer :: loc")
    lines.append("    call init_all_locales()")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if (code == {_quote(c)}) then")
        lines.append(f"      loc => {_var_name(c)}")
        lines.append("      return")
        lines.append("    end if")
    lines.append("    nullify(loc)")
    lines.append("  end function dur_get_locale")
    lines.append("")

    lines.append("end module sayableduration_locales")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "fortran", "src", "locales", "sayableduration_locales.f90")

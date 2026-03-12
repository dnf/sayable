"""Fortran locale emitter for sayable-time — single file with all locales.

Generates a single sayabletime_locales.f90 module containing all locale
definitions and a locale lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/fortran/emitter.py", line_prefix="! ", line_suffix="")

_MAX_STR_LEN = 256
_PATTERN_KEYS = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]


def _quote(s: str) -> str:
    """Escape a string for Fortran character literal."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _var_name(code: str) -> str:
    """Return a Fortran-safe variable name for a locale code."""
    return f"locale_{code}"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single sayabletime_locales.f90 module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("module sayabletime_locales")
    lines.append("  use sayabletime_types")
    lines.append("  implicit none")
    lines.append("  private")
    lines.append("")
    lines.append("  public :: st_get_locale")
    lines.append("")
    for data in sorted_locs:
        code = data["code"]
        lines.append(f"  type(st_locale), target, save :: {_var_name(code)}")
    lines.append("")
    lines.append("  logical, save :: locales_initialized = .false.")
    lines.append("")
    lines.append("contains")
    lines.append("")

    # Init subroutines per locale
    for data in sorted_locs:
        code = data["code"]
        var = _var_name(code)
        clock = data["clock"]

        lines.append(locale_source_comment(code, line_prefix="  ! ", line_suffix="").rstrip())
        lines.append(f"  subroutine init_{code}()")
        lines.append(f"    {var}%code = {_quote(code)}")
        lines.append("")

        # Clock hours (12)
        for i, h in enumerate(clock["hours"]):
            lines.append(f"    {var}%clock%hours({i + 1}) = {_quote(h)}")
        lines.append("")

        # Midnight and noon
        lines.append(f"    {var}%clock%midnight = {_quote(clock['midnight'])}")
        lines.append(f"    {var}%clock%noon = {_quote(clock['noon'])}")
        lines.append("")

        # Patterns (keyed by 5-minute buckets 0,5,10,...,55)
        patterns = clock["patterns"]
        for key in _PATTERN_KEYS:
            str_key = str(key)
            if str_key in patterns:
                lines.append(f"    {var}%clock%has_pattern({key // 5 + 1}) = .true.")
                lines.append(f"    {var}%clock%patterns({key // 5 + 1}) = {_quote(patterns[str_key])}")
            else:
                lines.append(f"    {var}%clock%has_pattern({key // 5 + 1}) = .false.")
                lines.append(f"    {var}%clock%patterns({key // 5 + 1}) = ''")
        lines.append("")

        # Short override
        if "short" in data and "clock" in data["short"]:
            lines.append(f"    {var}%has_short = .true.")
            sc = data["short"]["clock"]
            lines.append(f"    {var}%short_clock%use24h = {'    .true.' if sc['use24h'] else '.false.'}")
            lines.append(f"    {var}%short_clock%format = {_quote(sc['format'])}")
            if "amPm" in sc and sc["amPm"]:
                lines.append(f"    {var}%short_clock%has_am_pm = .true.")
                lines.append(f"    {var}%short_clock%am = {_quote(sc['amPm'][0])}")
                lines.append(f"    {var}%short_clock%pm = {_quote(sc['amPm'][1])}")
            else:
                lines.append(f"    {var}%short_clock%has_am_pm = .false.")
        else:
            lines.append(f"    {var}%has_short = .false.")
        lines.append("")

        # Compact override
        if "compact" in data and "clock" in data["compact"]:
            lines.append(f"    {var}%has_compact = .true.")
            sc = data["compact"]["clock"]
            lines.append(f"    {var}%compact_clock%use24h = {'    .true.' if sc['use24h'] else '.false.'}")
            lines.append(f"    {var}%compact_clock%format = {_quote(sc['format'])}")
            if "amPm" in sc and sc["amPm"]:
                lines.append(f"    {var}%compact_clock%has_am_pm = .true.")
                lines.append(f"    {var}%compact_clock%am = {_quote(sc['amPm'][0])}")
                lines.append(f"    {var}%compact_clock%pm = {_quote(sc['amPm'][1])}")
            else:
                lines.append(f"    {var}%compact_clock%has_am_pm = .false.")
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
    lines.append("  function st_get_locale(code) result(loc)")
    lines.append("    character(len=*), intent(in) :: code")
    lines.append("    type(st_locale), pointer :: loc")
    lines.append("    call init_all_locales()")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if (code == {_quote(c)}) then")
        lines.append(f"      loc => {_var_name(c)}")
        lines.append("      return")
        lines.append("    end if")
    lines.append("    nullify(loc)")
    lines.append("  end function st_get_locale")
    lines.append("")

    lines.append("end module sayabletime_locales")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "fortran", "src", "locales", "sayabletime_locales.f90")

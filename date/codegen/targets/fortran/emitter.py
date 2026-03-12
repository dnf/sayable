"""Fortran locale emitter for sayable-date — single file with all locales.

Generates a single sayabledate_locales.f90 module containing all locale
definitions and a locale lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/fortran/emitter.py", line_prefix="! ", line_suffix="")

_MAX_STR_LEN = 256
_MAX_EXCEPTIONS = 32


def _quote(s: str) -> str:
    """Escape a string for Fortran character literal."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _var_name(code: str) -> str:
    """Return a Fortran-safe variable name for a locale code."""
    return f"locale_{code}"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single sayabledate_locales.f90 module."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("module sayabledate_locales")
    lines.append("  use sayabledate_types")
    lines.append("  implicit none")
    lines.append("  private")
    lines.append("")
    lines.append("  public :: sd_get_locale")
    lines.append("")
    for data in sorted_locs:
        code = data["code"]
        lines.append(f"  type(sd_locale), target, save :: {_var_name(code)}")
    lines.append("")
    lines.append("  logical, save :: locales_initialized = .false.")
    lines.append("")
    lines.append("contains")
    lines.append("")

    # Init subroutines per locale
    for data in sorted_locs:
        code = data["code"]
        var = _var_name(code)

        lines.append(locale_source_comment(code, line_prefix="  ! ", line_suffix="").rstrip())
        lines.append(f"  subroutine init_{code}()")
        lines.append(f"    {var}%code = {_quote(code)}")
        lines.append("")

        # Months (12)
        for i, m in enumerate(data["months"]):
            lines.append(f"    {var}%months({i + 1}) = {_quote(m)}")
        lines.append("")

        # Weekdays (7) — 0=Sunday..6=Saturday in JSON, but Fortran 1-indexed
        for i, w in enumerate(data["weekdays"]):
            lines.append(f"    {var}%weekdays({i + 1}) = {_quote(w)}")
        lines.append("")

        # dayFormat
        lines.append(f"    {var}%day_format = {_quote(data['dayFormat'])}")
        lines.append("")

        # dayFormatExceptions
        exceptions = data.get("dayFormatExceptions", {})
        lines.append(f"    {var}%num_exceptions = {len(exceptions)}")
        for idx, (key, val) in enumerate(sorted(exceptions.items(), key=lambda x: int(x[0]))):
            lines.append(f"    {var}%exception_keys({idx + 1}) = {_quote(key)}")
            lines.append(f"    {var}%exception_vals({idx + 1}) = {_quote(val)}")
        lines.append("")

        # Date patterns
        lines.append(f"    {var}%date_pattern = {_quote(data['datePattern'])}")
        lines.append(f"    {var}%date_pattern_with_year = {_quote(data['datePatternWithYear'])}")
        lines.append("")

        # Proximity terms
        lines.append(f"    {var}%today = {_quote(data['today'])}")
        lines.append(f"    {var}%tomorrow = {_quote(data['tomorrow'])}")
        lines.append(f"    {var}%yesterday = {_quote(data['yesterday'])}")
        lines.append("")

        # Optional proximity
        if "dayAfterTomorrow" in data:
            lines.append(f"    {var}%day_after_tomorrow = {_quote(data['dayAfterTomorrow'])}")
        else:
            lines.append(f"    {var}%day_after_tomorrow = ''")
        if "dayBeforeYesterday" in data:
            lines.append(f"    {var}%day_before_yesterday = {_quote(data['dayBeforeYesterday'])}")
        else:
            lines.append(f"    {var}%day_before_yesterday = ''")
        if "thisWeekday" in data:
            lines.append(f"    {var}%this_weekday = {_quote(data['thisWeekday'])}")
        else:
            lines.append(f"    {var}%this_weekday = ''")
        if "nextWeekday" in data:
            lines.append(f"    {var}%next_weekday = {_quote(data['nextWeekday'])}")
        else:
            lines.append(f"    {var}%next_weekday = ''")
        if "lastWeekday" in data:
            lines.append(f"    {var}%last_weekday = {_quote(data['lastWeekday'])}")
        else:
            lines.append(f"    {var}%last_weekday = ''")
        lines.append("")

        # monthsInDate (genitive forms)
        if "monthsInDate" in data:
            lines.append(f"    {var}%has_months_in_date = .true.")
            for i, m in enumerate(data["monthsInDate"]):
                lines.append(f"    {var}%months_in_date({i + 1}) = {_quote(m)}")
        else:
            lines.append(f"    {var}%has_months_in_date = .false.")
        lines.append("")

        # Short override
        if "short" in data:
            lines.append(f"    {var}%has_short = .true.")
            short = data["short"]
            if "months" in short:
                lines.append(f"    {var}%short_override%has_months = .true.")
                for i, m in enumerate(short["months"]):
                    lines.append(f"    {var}%short_override%months({i + 1}) = {_quote(m)}")
            else:
                lines.append(f"    {var}%short_override%has_months = .false.")
            if "monthsInDate" in short:
                lines.append(f"    {var}%short_override%has_months_in_date = .true.")
                for i, m in enumerate(short["monthsInDate"]):
                    lines.append(f"    {var}%short_override%months_in_date({i + 1}) = {_quote(m)}")
            else:
                lines.append(f"    {var}%short_override%has_months_in_date = .false.")
            if "weekdays" in short:
                lines.append(f"    {var}%short_override%has_weekdays = .true.")
                for i, w in enumerate(short["weekdays"]):
                    lines.append(f"    {var}%short_override%weekdays({i + 1}) = {_quote(w)}")
            else:
                lines.append(f"    {var}%short_override%has_weekdays = .false.")
            if "dayFormat" in short:
                lines.append(f"    {var}%short_override%has_day_format = .true.")
                lines.append(f"    {var}%short_override%day_format = {_quote(short['dayFormat'])}")
            else:
                lines.append(f"    {var}%short_override%has_day_format = .false.")
            if "dayFormatExceptions" in short:
                lines.append(f"    {var}%short_override%has_day_format_exceptions = .true.")
                exc = short["dayFormatExceptions"]
                lines.append(f"    {var}%short_override%num_exceptions = {len(exc)}")
                for idx, (key, val) in enumerate(sorted(exc.items(), key=lambda x: int(x[0]))):
                    lines.append(f"    {var}%short_override%exception_keys({idx + 1}) = {_quote(key)}")
                    lines.append(f"    {var}%short_override%exception_vals({idx + 1}) = {_quote(val)}")
            else:
                lines.append(f"    {var}%short_override%has_day_format_exceptions = .false.")
            if "datePattern" in short:
                lines.append(f"    {var}%short_override%has_date_pattern = .true.")
                lines.append(f"    {var}%short_override%date_pattern = {_quote(short['datePattern'])}")
            else:
                lines.append(f"    {var}%short_override%has_date_pattern = .false.")
            if "datePatternWithYear" in short:
                lines.append(f"    {var}%short_override%has_date_pattern_with_year = .true.")
                lines.append(f"    {var}%short_override%date_pattern_with_year = {_quote(short['datePatternWithYear'])}")
            else:
                lines.append(f"    {var}%short_override%has_date_pattern_with_year = .false.")
            if "today" in short:
                lines.append(f"    {var}%short_override%has_today = .true.")
                lines.append(f"    {var}%short_override%today = {_quote(short['today'])}")
            else:
                lines.append(f"    {var}%short_override%has_today = .false.")
            if "tomorrow" in short:
                lines.append(f"    {var}%short_override%has_tomorrow = .true.")
                lines.append(f"    {var}%short_override%tomorrow = {_quote(short['tomorrow'])}")
            else:
                lines.append(f"    {var}%short_override%has_tomorrow = .false.")
            if "yesterday" in short:
                lines.append(f"    {var}%short_override%has_yesterday = .true.")
                lines.append(f"    {var}%short_override%yesterday = {_quote(short['yesterday'])}")
            else:
                lines.append(f"    {var}%short_override%has_yesterday = .false.")
        else:
            lines.append(f"    {var}%has_short = .false.")
        lines.append("")

        # Compact override
        if "compact" in data:
            lines.append(f"    {var}%has_compact = .true.")
            compact = data["compact"]
            if "months" in compact:
                lines.append(f"    {var}%compact_override%has_months = .true.")
                for i, m in enumerate(compact["months"]):
                    lines.append(f"    {var}%compact_override%months({i + 1}) = {_quote(m)}")
            else:
                lines.append(f"    {var}%compact_override%has_months = .false.")
            if "monthsInDate" in compact:
                lines.append(f"    {var}%compact_override%has_months_in_date = .true.")
                for i, m in enumerate(compact["monthsInDate"]):
                    lines.append(f"    {var}%compact_override%months_in_date({i + 1}) = {_quote(m)}")
            else:
                lines.append(f"    {var}%compact_override%has_months_in_date = .false.")
            if "weekdays" in compact:
                lines.append(f"    {var}%compact_override%has_weekdays = .true.")
                for i, w in enumerate(compact["weekdays"]):
                    lines.append(f"    {var}%compact_override%weekdays({i + 1}) = {_quote(w)}")
            else:
                lines.append(f"    {var}%compact_override%has_weekdays = .false.")
            if "dayFormat" in compact:
                lines.append(f"    {var}%compact_override%has_day_format = .true.")
                lines.append(f"    {var}%compact_override%day_format = {_quote(compact['dayFormat'])}")
            else:
                lines.append(f"    {var}%compact_override%has_day_format = .false.")
            if "dayFormatExceptions" in compact:
                lines.append(f"    {var}%compact_override%has_day_format_exceptions = .true.")
                exc = compact["dayFormatExceptions"]
                lines.append(f"    {var}%compact_override%num_exceptions = {len(exc)}")
                for idx, (key, val) in enumerate(sorted(exc.items(), key=lambda x: int(x[0]))):
                    lines.append(f"    {var}%compact_override%exception_keys({idx + 1}) = {_quote(key)}")
                    lines.append(f"    {var}%compact_override%exception_vals({idx + 1}) = {_quote(val)}")
            else:
                lines.append(f"    {var}%compact_override%has_day_format_exceptions = .false.")
            if "datePattern" in compact:
                lines.append(f"    {var}%compact_override%has_date_pattern = .true.")
                lines.append(f"    {var}%compact_override%date_pattern = {_quote(compact['datePattern'])}")
            else:
                lines.append(f"    {var}%compact_override%has_date_pattern = .false.")
            if "datePatternWithYear" in compact:
                lines.append(f"    {var}%compact_override%has_date_pattern_with_year = .true.")
                lines.append(f"    {var}%compact_override%date_pattern_with_year = {_quote(compact['datePatternWithYear'])}")
            else:
                lines.append(f"    {var}%compact_override%has_date_pattern_with_year = .false.")
            if "today" in compact:
                lines.append(f"    {var}%compact_override%has_today = .true.")
                lines.append(f"    {var}%compact_override%today = {_quote(compact['today'])}")
            else:
                lines.append(f"    {var}%compact_override%has_today = .false.")
            if "tomorrow" in compact:
                lines.append(f"    {var}%compact_override%has_tomorrow = .true.")
                lines.append(f"    {var}%compact_override%tomorrow = {_quote(compact['tomorrow'])}")
            else:
                lines.append(f"    {var}%compact_override%has_tomorrow = .false.")
            if "yesterday" in compact:
                lines.append(f"    {var}%compact_override%has_yesterday = .true.")
                lines.append(f"    {var}%compact_override%yesterday = {_quote(compact['yesterday'])}")
            else:
                lines.append(f"    {var}%compact_override%has_yesterday = .false.")
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
    lines.append("  function sd_get_locale(code) result(loc)")
    lines.append("    character(len=*), intent(in) :: code")
    lines.append("    type(sd_locale), pointer :: loc")
    lines.append("    call init_all_locales()")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"    if (code == {_quote(c)}) then")
        lines.append(f"      loc => {_var_name(c)}")
        lines.append("      return")
        lines.append("    end if")
    lines.append("    nullify(loc)")
    lines.append("  end function sd_get_locale")
    lines.append("")

    lines.append("end module sayabledate_locales")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "fortran", "src", "locales", "sayabledate_locales.f90")

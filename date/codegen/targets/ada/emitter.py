"""Ada locale emitter for sayable-date.

Generates a single sayabledate_locales.ads/.adb pair containing all locale
definitions and a locale lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/ada/emitter.py", line_prefix="--  ", line_suffix="")

_MAX_MONTHS = 12
_MAX_WEEKDAYS = 7


def _quote(s: str) -> str:
    """Escape a string for Ada string literal."""
    escaped = s.replace('"', '""')
    return f'"{escaped}"'


def _var_name(code: str) -> str:
    """Return an Ada-safe variable name for a locale code."""
    return f"Locale_{code.replace('-', '_').capitalize()}"


def _fn_name(code: str) -> str:
    """Return a function name for a locale init procedure."""
    return f"Init_{code.replace('-', '_')}"


def _string_array_lines(items: list[str], var: str, indent: str = "      ") -> list[str]:
    """Emit lines that set a String_Array_12 or String_Array_7."""
    lines = []
    for i, item in enumerate(items):
        lines.append(f"{indent}{var} ({i + 1}) := To_Unbounded_String ({_quote(item)});")
    return lines


def _compactness_lines(ovr: dict, var: str, indent: str = "      ") -> list[str]:
    """Emit lines that initialize a compactness override."""
    lines = []
    if "months" in ovr:
        lines.append(f"{indent}{var}.Has_Months := True;")
        for sl in _string_array_lines(ovr["months"], f"{var}.Months", indent):
            lines.append(sl)
    else:
        lines.append(f"{indent}{var}.Has_Months := False;")
    if "monthsInDate" in ovr:
        lines.append(f"{indent}{var}.Has_Months_In_Date := True;")
        for sl in _string_array_lines(ovr["monthsInDate"], f"{var}.Months_In_Date", indent):
            lines.append(sl)
    else:
        lines.append(f"{indent}{var}.Has_Months_In_Date := False;")
    if "weekdays" in ovr:
        lines.append(f"{indent}{var}.Has_Weekdays := True;")
        for sl in _string_array_lines(ovr["weekdays"], f"{var}.Weekdays", indent):
            lines.append(sl)
    else:
        lines.append(f"{indent}{var}.Has_Weekdays := False;")
    if "dayFormat" in ovr:
        lines.append(f"{indent}{var}.Has_Day_Format := True;")
        lines.append(f"{indent}{var}.Day_Format := To_Unbounded_String ({_quote(ovr['dayFormat'])});")
    else:
        lines.append(f"{indent}{var}.Has_Day_Format := False;")
    if "dayFormatExceptions" in ovr:
        lines.append(f"{indent}{var}.Has_Day_Format_Exceptions := True;")
        lines.append(f"{indent}{var}.Day_Format_Exception_Count := {len(ovr['dayFormatExceptions'])};")
        for idx, (k, v) in enumerate(ovr["dayFormatExceptions"].items()):
            lines.append(f"{indent}{var}.Day_Format_Exception_Keys ({idx + 1}) := To_Unbounded_String ({_quote(k)});")
            lines.append(f"{indent}{var}.Day_Format_Exception_Vals ({idx + 1}) := To_Unbounded_String ({_quote(v)});")
    else:
        lines.append(f"{indent}{var}.Has_Day_Format_Exceptions := False;")
    if "datePattern" in ovr:
        lines.append(f"{indent}{var}.Has_Date_Pattern := True;")
        lines.append(f"{indent}{var}.Date_Pattern := To_Unbounded_String ({_quote(ovr['datePattern'])});")
    else:
        lines.append(f"{indent}{var}.Has_Date_Pattern := False;")
    if "datePatternWithYear" in ovr:
        lines.append(f"{indent}{var}.Has_Date_Pattern_With_Year := True;")
        lines.append(f"{indent}{var}.Date_Pattern_With_Year := To_Unbounded_String ({_quote(ovr['datePatternWithYear'])});")
    else:
        lines.append(f"{indent}{var}.Has_Date_Pattern_With_Year := False;")
    if "today" in ovr:
        lines.append(f"{indent}{var}.Has_Today := True;")
        lines.append(f"{indent}{var}.Today := To_Unbounded_String ({_quote(ovr['today'])});")
    else:
        lines.append(f"{indent}{var}.Has_Today := False;")
    if "tomorrow" in ovr:
        lines.append(f"{indent}{var}.Has_Tomorrow := True;")
        lines.append(f"{indent}{var}.Tomorrow := To_Unbounded_String ({_quote(ovr['tomorrow'])});")
    else:
        lines.append(f"{indent}{var}.Has_Tomorrow := False;")
    if "yesterday" in ovr:
        lines.append(f"{indent}{var}.Has_Yesterday := True;")
        lines.append(f"{indent}{var}.Yesterday := To_Unbounded_String ({_quote(ovr['yesterday'])});")
    else:
        lines.append(f"{indent}{var}.Has_Yesterday := False;")
    return lines


def emit_spec(all_locales: list[dict]) -> str:
    """Generate the sayabledate_locales.ads spec file."""
    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("with Sayabledate_Types; use Sayabledate_Types;")
    lines.append("")
    lines.append("package Sayabledate_Locales is")
    lines.append("")
    lines.append("   function Get_Locale (Code : String) return Locale_Access;")
    lines.append("")
    lines.append("end Sayabledate_Locales;")
    lines.append("")
    return "\n".join(lines)


def emit_body(all_locales: list[dict]) -> str:
    """Generate the sayabledate_locales.adb body file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;")
    lines.append("")
    lines.append("package body Sayabledate_Locales is")
    lines.append("")

    # Locale variables
    for data in sorted_locs:
        code = data["code"]
        var = _var_name(code)
        lines.append(f"   {var} : aliased Date_Locale;")
    lines.append("")
    lines.append("   Initialized : Boolean := False;")
    lines.append("")

    # Init procedures per locale
    for data in sorted_locs:
        code = data["code"]
        var = _var_name(code)

        lines.append(locale_source_comment(code, line_prefix="   --  ", line_suffix="").rstrip())
        lines.append(f"   procedure {_fn_name(code)} is")
        lines.append("   begin")
        lines.append(f"      {var}.Code := To_Unbounded_String ({_quote(code)});")
        lines.append("")

        # Months
        for sl in _string_array_lines(data["months"], f"{var}.Months", "      "):
            lines.append(sl)
        lines.append("")

        # Weekdays
        for sl in _string_array_lines(data["weekdays"], f"{var}.Weekdays", "      "):
            lines.append(sl)
        lines.append("")

        # Day format
        lines.append(f"      {var}.Day_Format := To_Unbounded_String ({_quote(data['dayFormat'])});")

        # Day format exceptions
        if "dayFormatExceptions" in data and data["dayFormatExceptions"]:
            exc = data["dayFormatExceptions"]
            lines.append(f"      {var}.Day_Format_Exception_Count := {len(exc)};")
            for idx, (k, v) in enumerate(exc.items()):
                lines.append(f"      {var}.Day_Format_Exception_Keys ({idx + 1}) := To_Unbounded_String ({_quote(k)});")
                lines.append(f"      {var}.Day_Format_Exception_Vals ({idx + 1}) := To_Unbounded_String ({_quote(v)});")
        else:
            lines.append(f"      {var}.Day_Format_Exception_Count := 0;")
        lines.append("")

        # Patterns
        lines.append(f"      {var}.Date_Pattern := To_Unbounded_String ({_quote(data['datePattern'])});")
        lines.append(f"      {var}.Date_Pattern_With_Year := To_Unbounded_String ({_quote(data['datePatternWithYear'])});")
        lines.append("")

        # Proximity strings
        lines.append(f"      {var}.Today := To_Unbounded_String ({_quote(data['today'])});")
        lines.append(f"      {var}.Tomorrow := To_Unbounded_String ({_quote(data['tomorrow'])});")
        lines.append(f"      {var}.Yesterday := To_Unbounded_String ({_quote(data['yesterday'])});")

        if "dayAfterTomorrow" in data:
            lines.append(f"      {var}.Has_Day_After_Tomorrow := True;")
            lines.append(f"      {var}.Day_After_Tomorrow := To_Unbounded_String ({_quote(data['dayAfterTomorrow'])});")
        else:
            lines.append(f"      {var}.Has_Day_After_Tomorrow := False;")

        if "dayBeforeYesterday" in data:
            lines.append(f"      {var}.Has_Day_Before_Yesterday := True;")
            lines.append(f"      {var}.Day_Before_Yesterday := To_Unbounded_String ({_quote(data['dayBeforeYesterday'])});")
        else:
            lines.append(f"      {var}.Has_Day_Before_Yesterday := False;")

        if "thisWeekday" in data:
            lines.append(f"      {var}.Has_This_Weekday := True;")
            lines.append(f"      {var}.This_Weekday := To_Unbounded_String ({_quote(data['thisWeekday'])});")
        else:
            lines.append(f"      {var}.Has_This_Weekday := False;")

        if "nextWeekday" in data:
            lines.append(f"      {var}.Has_Next_Weekday := True;")
            lines.append(f"      {var}.Next_Weekday := To_Unbounded_String ({_quote(data['nextWeekday'])});")
        else:
            lines.append(f"      {var}.Has_Next_Weekday := False;")

        if "lastWeekday" in data:
            lines.append(f"      {var}.Has_Last_Weekday := True;")
            lines.append(f"      {var}.Last_Weekday := To_Unbounded_String ({_quote(data['lastWeekday'])});")
        else:
            lines.append(f"      {var}.Has_Last_Weekday := False;")

        if "monthsInDate" in data:
            lines.append(f"      {var}.Has_Months_In_Date := True;")
            for sl in _string_array_lines(data["monthsInDate"], f"{var}.Months_In_Date", "      "):
                lines.append(sl)
        else:
            lines.append(f"      {var}.Has_Months_In_Date := False;")
        lines.append("")

        # Short override
        if "short" in data:
            lines.append(f"      {var}.Has_Short := True;")
            for sl in _compactness_lines(data["short"], f"{var}.Short_Override", "      "):
                lines.append(sl)
        else:
            lines.append(f"      {var}.Has_Short := False;")
        lines.append("")

        # Compact override
        if "compact" in data:
            lines.append(f"      {var}.Has_Compact := True;")
            for sl in _compactness_lines(data["compact"], f"{var}.Compact_Override", "      "):
                lines.append(sl)
        else:
            lines.append(f"      {var}.Has_Compact := False;")
        lines.append("")

        lines.append(f"   end {_fn_name(code)};")
        lines.append("")

    # Master init
    lines.append("   procedure Init_All is")
    lines.append("   begin")
    lines.append("      if Initialized then")
    lines.append("         return;")
    lines.append("      end if;")
    for data in sorted_locs:
        lines.append(f"      {_fn_name(data['code'])};")
    lines.append("      Initialized := True;")
    lines.append("   end Init_All;")
    lines.append("")

    # Locale lookup
    lines.append("   function Get_Locale (Code : String) return Locale_Access is")
    lines.append("   begin")
    lines.append("      Init_All;")
    for data in sorted_locs:
        c = data["code"]
        lines.append(f"      if Code = {_quote(c)} then")
        lines.append(f"         return {_var_name(c)}'Access;")
        lines.append("      end if;")
    lines.append("      return null;")
    lines.append("   end Get_Locale;")
    lines.append("")

    lines.append("end Sayabledate_Locales;")
    lines.append("")

    return "\n".join(lines)


def spec_path(root: str) -> str:
    return os.path.join(root, "impl", "ada", "src", "locales", "sayabledate_locales.ads")


def body_path(root: str) -> str:
    return os.path.join(root, "impl", "ada", "src", "locales", "sayabledate_locales.adb")

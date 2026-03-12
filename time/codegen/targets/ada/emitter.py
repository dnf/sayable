"""Ada locale emitter for sayable-time.

Generates a single sayabletime_locales.ads/.adb pair containing all locale
definitions and a locale lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/ada/emitter.py", line_prefix="--  ", line_suffix="")


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


def _clock_lines(clock: dict, var: str, indent: str = "      ") -> list[str]:
    """Emit lines that initialize a Clock_Config."""
    lines = []
    # Hours (12 entries, index 0..11)
    for i, h in enumerate(clock["hours"]):
        lines.append(f"{indent}{var}.Hours ({i}) := To_Unbounded_String ({_quote(h)});")

    lines.append(f"{indent}{var}.Midnight := To_Unbounded_String ({_quote(clock['midnight'])});")
    lines.append(f"{indent}{var}.Noon := To_Unbounded_String ({_quote(clock['noon'])});")

    # Patterns (keyed by minute bucket)
    patterns = clock["patterns"]
    lines.append(f"{indent}{var}.Pattern_Count := {len(patterns)};")
    for idx, (k, v) in enumerate(patterns.items()):
        lines.append(f"{indent}{var}.Pattern_Keys ({idx + 1}) := {int(k)};")
        lines.append(f"{indent}{var}.Pattern_Vals ({idx + 1}) := To_Unbounded_String ({_quote(v)});")

    return lines


def _short_clock_lines(sc: dict, var: str, indent: str = "      ") -> list[str]:
    """Emit lines that initialize a Short_Clock_Config."""
    lines = []
    use24h = sc.get("use24h", False)
    lines.append(f"{indent}{var}.Use_24h := {'True' if use24h else 'False'};")
    lines.append(f"{indent}{var}.Format := To_Unbounded_String ({_quote(sc['format'])});")
    if "amPm" in sc:
        lines.append(f"{indent}{var}.Has_Am_Pm := True;")
        lines.append(f"{indent}{var}.Am_Str := To_Unbounded_String ({_quote(sc['amPm'][0])});")
        lines.append(f"{indent}{var}.Pm_Str := To_Unbounded_String ({_quote(sc['amPm'][1])});")
    else:
        lines.append(f"{indent}{var}.Has_Am_Pm := False;")
    return lines


def emit_spec(all_locales: list[dict]) -> str:
    """Generate the sayabletime_locales.ads spec file."""
    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("with Sayabletime_Types; use Sayabletime_Types;")
    lines.append("")
    lines.append("package Sayabletime_Locales is")
    lines.append("")
    lines.append("   function Get_Locale (Code : String) return Locale_Access;")
    lines.append("")
    lines.append("end Sayabletime_Locales;")
    lines.append("")
    return "\n".join(lines)


def emit_body(all_locales: list[dict]) -> str:
    """Generate the sayabletime_locales.adb body file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;")
    lines.append("")
    lines.append("package body Sayabletime_Locales is")
    lines.append("")

    # Locale variables
    for data in sorted_locs:
        code = data["code"]
        var = _var_name(code)
        lines.append(f"   {var} : aliased Time_Locale;")
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

        # Clock config
        for sl in _clock_lines(data["clock"], f"{var}.Clock", "      "):
            lines.append(sl)
        lines.append("")

        # Short override
        if "short" in data and "clock" in data["short"]:
            lines.append(f"      {var}.Has_Short := True;")
            for sl in _short_clock_lines(data["short"]["clock"], f"{var}.Short_Clock", "      "):
                lines.append(sl)
        else:
            lines.append(f"      {var}.Has_Short := False;")
        lines.append("")

        # Compact override
        if "compact" in data and "clock" in data["compact"]:
            lines.append(f"      {var}.Has_Compact := True;")
            for sl in _short_clock_lines(data["compact"]["clock"], f"{var}.Compact_Clock", "      "):
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

    lines.append("end Sayabletime_Locales;")
    lines.append("")

    return "\n".join(lines)


def spec_path(root: str) -> str:
    return os.path.join(root, "impl", "ada", "src", "locales", "sayabletime_locales.ads")


def body_path(root: str) -> str:
    return os.path.join(root, "impl", "ada", "src", "locales", "sayabletime_locales.adb")

"""Pascal locale emitter — single file with all locales.

Generates a Pascal unit `SayableDateLocales` containing all locale
definitions as getter procedures and a registry lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/pascal/emitter.py", line_prefix="{ ", line_suffix=" }")


def _quote(s: str) -> str:
    """Quote a string for Pascal using single quotes."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _str_array(items: list[str], const_name: str) -> list[str]:
    """Emit a Pascal array constant assignment for a list of strings."""
    lines = []
    parts = ", ".join(_quote(s) for s in items)
    lines.append(f"  {const_name} := ({parts});")
    return lines


def _dict_entries(d: dict[str, str]) -> list[str]:
    """Emit field-by-field assignment for a day format exceptions array."""
    lines = []
    for key, val in d.items():
        lines.append(f"  ALoc.DayFormatExceptions[{key}] := {_quote(val)};")
    return lines


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single SayableDateLocales.pas file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = []
    lines.append("{$mode objfpc}{$H+}")
    lines.append("{$codepage utf8}")
    lines.append(HEADER.rstrip())
    lines.append("unit SayableDateLocales;")
    lines.append("")
    lines.append("interface")
    lines.append("")
    lines.append("uses SayableDateTypes;")
    lines.append("")

    # Declare all locale getter procedures
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"procedure GetLocale_{code.replace('-', '_')}(out ALoc: TDateLocale);")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TDateLocalePtr;")
    lines.append("")
    lines.append("implementation")
    lines.append("")

    # Locale getter procedures
    for loc in sorted_locs:
        code = loc["code"]
        name = loc["name"]
        getter = f"GetLocale_{code.replace('-', '_')}"

        lines.append(locale_source_comment(code, line_prefix="{ ", line_suffix=" }").rstrip())
        lines.append(f"{{ {name} locale. }}")
        lines.append(f"procedure {getter}(out ALoc: TDateLocale);")
        lines.append("var")
        lines.append("  I: Integer;")
        lines.append("begin")
        lines.append(f"  ALoc.Code := {_quote(code)};")

        # Months
        for i, m in enumerate(loc["months"]):
            lines.append(f"  ALoc.Months[{i}] := {_quote(m)};")

        # Weekdays
        for i, w in enumerate(loc["weekdays"]):
            lines.append(f"  ALoc.Weekdays[{i}] := {_quote(w)};")

        # Day format
        lines.append(f"  ALoc.DayFormat := {_quote(loc['dayFormat'])};")

        # Day format exceptions — clear all first, then set
        lines.append("  for I := 0 to 31 do")
        lines.append("    ALoc.DayFormatExceptions[I] := '';")
        if "dayFormatExceptions" in loc:
            for key, val in loc["dayFormatExceptions"].items():
                lines.append(f"  ALoc.DayFormatExceptions[{key}] := {_quote(val)};")

        # Patterns
        lines.append(f"  ALoc.DatePattern := {_quote(loc['datePattern'])};")
        lines.append(f"  ALoc.DatePatternWithYear := {_quote(loc['datePatternWithYear'])};")

        # Proximity strings
        lines.append(f"  ALoc.Today := {_quote(loc['today'])};")
        lines.append(f"  ALoc.Tomorrow := {_quote(loc['tomorrow'])};")
        lines.append(f"  ALoc.Yesterday := {_quote(loc['yesterday'])};")

        # Optional proximity strings
        if "dayAfterTomorrow" in loc:
            lines.append(f"  ALoc.DayAfterTomorrow := {_quote(loc['dayAfterTomorrow'])};")
        else:
            lines.append("  ALoc.DayAfterTomorrow := '';")

        if "dayBeforeYesterday" in loc:
            lines.append(f"  ALoc.DayBeforeYesterday := {_quote(loc['dayBeforeYesterday'])};")
        else:
            lines.append("  ALoc.DayBeforeYesterday := '';")

        if "thisWeekday" in loc:
            lines.append(f"  ALoc.ThisWeekday := {_quote(loc['thisWeekday'])};")
        else:
            lines.append("  ALoc.ThisWeekday := '';")

        if "nextWeekday" in loc:
            lines.append(f"  ALoc.NextWeekday := {_quote(loc['nextWeekday'])};")
        else:
            lines.append("  ALoc.NextWeekday := '';")

        if "lastWeekday" in loc:
            lines.append(f"  ALoc.LastWeekday := {_quote(loc['lastWeekday'])};")
        else:
            lines.append("  ALoc.LastWeekday := '';")

        # Months in date (genitive forms)
        if "monthsInDate" in loc:
            lines.append("  ALoc.HasMonthsInDate := True;")
            for i, m in enumerate(loc["monthsInDate"]):
                lines.append(f"  ALoc.MonthsInDate[{i}] := {_quote(m)};")
        else:
            lines.append("  ALoc.HasMonthsInDate := False;")
            lines.append("  for I := 0 to 11 do")
            lines.append("    ALoc.MonthsInDate[I] := '';")

        # Short override
        if "short" in loc:
            ovr = loc["short"]
            lines.append("  ALoc.HasShort := True;")
            if "months" in ovr:
                lines.append("  ALoc.ShortOverride.HasMonths := True;")
                for i, m in enumerate(ovr["months"]):
                    lines.append(f"  ALoc.ShortOverride.Months[{i}] := {_quote(m)};")
            else:
                lines.append("  ALoc.ShortOverride.HasMonths := False;")
                lines.append("  for I := 0 to 11 do")
                lines.append("    ALoc.ShortOverride.Months[I] := '';")

            if "weekdays" in ovr:
                lines.append("  ALoc.ShortOverride.HasWeekdays := True;")
                for i, w in enumerate(ovr["weekdays"]):
                    lines.append(f"  ALoc.ShortOverride.Weekdays[{i}] := {_quote(w)};")
            else:
                lines.append("  ALoc.ShortOverride.HasWeekdays := False;")
                lines.append("  for I := 0 to 6 do")
                lines.append("    ALoc.ShortOverride.Weekdays[I] := '';")

            if "monthsInDate" in ovr:
                lines.append("  ALoc.ShortOverride.HasMonthsInDate := True;")
                for i, m in enumerate(ovr["monthsInDate"]):
                    lines.append(f"  ALoc.ShortOverride.MonthsInDate[{i}] := {_quote(m)};")
            else:
                lines.append("  ALoc.ShortOverride.HasMonthsInDate := False;")
                lines.append("  for I := 0 to 11 do")
                lines.append("    ALoc.ShortOverride.MonthsInDate[I] := '';")

            if "dayFormat" in ovr:
                lines.append("  ALoc.ShortOverride.HasDayFormat := True;")
                lines.append(f"  ALoc.ShortOverride.DayFormat := {_quote(ovr['dayFormat'])};")
                # When dayFormat is overridden, clear exceptions unless also overridden
                if "dayFormatExceptions" in ovr:
                    lines.append("  ALoc.ShortOverride.HasDayFormatExceptions := True;")
                    lines.append("  for I := 0 to 31 do")
                    lines.append("    ALoc.ShortOverride.DayFormatExceptions[I] := '';")
                    for key, val in ovr["dayFormatExceptions"].items():
                        lines.append(f"  ALoc.ShortOverride.DayFormatExceptions[{key}] := {_quote(val)};")
                else:
                    lines.append("  ALoc.ShortOverride.HasDayFormatExceptions := False;")
                    lines.append("  for I := 0 to 31 do")
                    lines.append("    ALoc.ShortOverride.DayFormatExceptions[I] := '';")
            else:
                lines.append("  ALoc.ShortOverride.HasDayFormat := False;")
                lines.append("  ALoc.ShortOverride.DayFormat := '';")
                if "dayFormatExceptions" in ovr:
                    lines.append("  ALoc.ShortOverride.HasDayFormatExceptions := True;")
                    lines.append("  for I := 0 to 31 do")
                    lines.append("    ALoc.ShortOverride.DayFormatExceptions[I] := '';")
                    for key, val in ovr["dayFormatExceptions"].items():
                        lines.append(f"  ALoc.ShortOverride.DayFormatExceptions[{key}] := {_quote(val)};")
                else:
                    lines.append("  ALoc.ShortOverride.HasDayFormatExceptions := False;")
                    lines.append("  for I := 0 to 31 do")
                    lines.append("    ALoc.ShortOverride.DayFormatExceptions[I] := '';")

            if "datePattern" in ovr:
                lines.append("  ALoc.ShortOverride.HasDatePattern := True;")
                lines.append(f"  ALoc.ShortOverride.DatePattern := {_quote(ovr['datePattern'])};")
            else:
                lines.append("  ALoc.ShortOverride.HasDatePattern := False;")
                lines.append("  ALoc.ShortOverride.DatePattern := '';")

            if "datePatternWithYear" in ovr:
                lines.append("  ALoc.ShortOverride.HasDatePatternWithYear := True;")
                lines.append(f"  ALoc.ShortOverride.DatePatternWithYear := {_quote(ovr['datePatternWithYear'])};")
            else:
                lines.append("  ALoc.ShortOverride.HasDatePatternWithYear := False;")
                lines.append("  ALoc.ShortOverride.DatePatternWithYear := '';")

            if "today" in ovr:
                lines.append("  ALoc.ShortOverride.HasToday := True;")
                lines.append(f"  ALoc.ShortOverride.Today := {_quote(ovr['today'])};")
            else:
                lines.append("  ALoc.ShortOverride.HasToday := False;")
                lines.append("  ALoc.ShortOverride.Today := '';")

            if "tomorrow" in ovr:
                lines.append("  ALoc.ShortOverride.HasTomorrow := True;")
                lines.append(f"  ALoc.ShortOverride.Tomorrow := {_quote(ovr['tomorrow'])};")
            else:
                lines.append("  ALoc.ShortOverride.HasTomorrow := False;")
                lines.append("  ALoc.ShortOverride.Tomorrow := '';")

            if "yesterday" in ovr:
                lines.append("  ALoc.ShortOverride.HasYesterday := True;")
                lines.append(f"  ALoc.ShortOverride.Yesterday := {_quote(ovr['yesterday'])};")
            else:
                lines.append("  ALoc.ShortOverride.HasYesterday := False;")
                lines.append("  ALoc.ShortOverride.Yesterday := '';")
        else:
            lines.append("  ALoc.HasShort := False;")

        # Compact override
        if "compact" in loc:
            ovr = loc["compact"]
            lines.append("  ALoc.HasCompact := True;")
            # Compact typically only has datePattern and datePatternWithYear
            lines.append("  ALoc.CompactOverride.HasMonths := False;")
            lines.append("  for I := 0 to 11 do")
            lines.append("    ALoc.CompactOverride.Months[I] := '';")
            lines.append("  ALoc.CompactOverride.HasWeekdays := False;")
            lines.append("  for I := 0 to 6 do")
            lines.append("    ALoc.CompactOverride.Weekdays[I] := '';")
            lines.append("  ALoc.CompactOverride.HasMonthsInDate := False;")
            lines.append("  for I := 0 to 11 do")
            lines.append("    ALoc.CompactOverride.MonthsInDate[I] := '';")
            lines.append("  ALoc.CompactOverride.HasDayFormat := False;")
            lines.append("  ALoc.CompactOverride.DayFormat := '';")
            lines.append("  ALoc.CompactOverride.HasDayFormatExceptions := False;")
            lines.append("  for I := 0 to 31 do")
            lines.append("    ALoc.CompactOverride.DayFormatExceptions[I] := '';")

            if "datePattern" in ovr:
                lines.append("  ALoc.CompactOverride.HasDatePattern := True;")
                lines.append(f"  ALoc.CompactOverride.DatePattern := {_quote(ovr['datePattern'])};")
            else:
                lines.append("  ALoc.CompactOverride.HasDatePattern := False;")
                lines.append("  ALoc.CompactOverride.DatePattern := '';")

            if "datePatternWithYear" in ovr:
                lines.append("  ALoc.CompactOverride.HasDatePatternWithYear := True;")
                lines.append(f"  ALoc.CompactOverride.DatePatternWithYear := {_quote(ovr['datePatternWithYear'])};")
            else:
                lines.append("  ALoc.CompactOverride.HasDatePatternWithYear := False;")
                lines.append("  ALoc.CompactOverride.DatePatternWithYear := '';")

            lines.append("  ALoc.CompactOverride.HasToday := False;")
            lines.append("  ALoc.CompactOverride.Today := '';")
            lines.append("  ALoc.CompactOverride.HasTomorrow := False;")
            lines.append("  ALoc.CompactOverride.Tomorrow := '';")
            lines.append("  ALoc.CompactOverride.HasYesterday := False;")
            lines.append("  ALoc.CompactOverride.Yesterday := '';")
        else:
            lines.append("  ALoc.HasCompact := False;")

        lines.append("end;")
        lines.append("")

    # Registry lookup
    lines.append("var")
    lines.append("  _LocCache: TDateLocale;")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TDateLocalePtr;")
    lines.append("begin")
    lines.append("  Result := nil;")
    for loc in sorted_locs:
        code = loc["code"]
        getter = f"GetLocale_{code.replace('-', '_')}"
        lines.append(f"  if ACode = {_quote(code)} then begin {getter}(_LocCache); Result := @_LocCache; exit; end;")
    lines.append("end;")
    lines.append("")
    lines.append("end.")
    lines.append("")

    return "\n".join(lines)


def output_path(root: str) -> str:
    return os.path.join(root, "impl", "pascal", "locales", "SayableDateLocales.pas")

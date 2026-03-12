"""Pascal locale emitter — single file with all locales.

Generates a Pascal unit `SayableTimeLocales` containing all locale
definitions as getter procedures and a registry lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/pascal/emitter.py", line_prefix="{ ", line_suffix=" }")

_PATTERN_KEYS = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]


def _quote(s: str) -> str:
    """Quote a string for Pascal using single quotes."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single SayableTimeLocales.pas file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = []
    lines.append("{$mode objfpc}{$H+}")
    lines.append("{$codepage utf8}")
    lines.append(HEADER.rstrip())
    lines.append("unit SayableTimeLocales;")
    lines.append("")
    lines.append("interface")
    lines.append("")
    lines.append("uses SayableTimeTypes;")
    lines.append("")

    # Declare all locale getter procedures
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"procedure GetLocale_{code.replace('-', '_')}(out ALoc: TTimeLocale);")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TTimeLocalePtr;")
    lines.append("")
    lines.append("implementation")
    lines.append("")

    # Locale getter procedures
    for loc in sorted_locs:
        code = loc["code"]
        name = loc["name"]
        clock = loc["clock"]
        getter = f"GetLocale_{code.replace('-', '_')}"

        lines.append(locale_source_comment(code, line_prefix="{ ", line_suffix=" }").rstrip())
        lines.append(f"{{ {name} locale. }}")
        lines.append(f"procedure {getter}(out ALoc: TTimeLocale);")
        lines.append("begin")
        lines.append(f"  ALoc.Code := {_quote(code)};")

        # Clock hours
        for i, h in enumerate(clock["hours"]):
            lines.append(f"  ALoc.Clock.Hours[{i}] := {_quote(h)};")

        lines.append(f"  ALoc.Clock.Midnight := {_quote(clock['midnight'])};")
        lines.append(f"  ALoc.Clock.Noon := {_quote(clock['noon'])};")

        # Patterns
        for key in _PATTERN_KEYS:
            if key in clock["patterns"]:
                lines.append(f"  ALoc.Clock.Patterns[{key}] := {_quote(clock['patterns'][key])};")
            else:
                lines.append(f"  ALoc.Clock.Patterns[{key}] := '';")

        # Short override
        if "short" in loc:
            sc = loc["short"].get("clock", {})
            lines.append("  ALoc.HasShort := True;")
            use24h = sc.get("use24h", True)
            lines.append(f"  ALoc.ShortOverride.Clock.Use24h := {str(use24h).upper()};")
            fmt = sc.get("format", "{h}:{mm}")
            lines.append(f"  ALoc.ShortOverride.Clock.Format := {_quote(fmt)};")
            am_pm = sc.get("amPm")
            if am_pm:
                lines.append("  ALoc.ShortOverride.Clock.HasAmPm := True;")
                lines.append(f"  ALoc.ShortOverride.Clock.AmStr := {_quote(am_pm[0])};")
                lines.append(f"  ALoc.ShortOverride.Clock.PmStr := {_quote(am_pm[1])};")
            else:
                lines.append("  ALoc.ShortOverride.Clock.HasAmPm := False;")
                lines.append("  ALoc.ShortOverride.Clock.AmStr := '';")
                lines.append("  ALoc.ShortOverride.Clock.PmStr := '';")
        else:
            lines.append("  ALoc.HasShort := False;")

        # Compact override
        if "compact" in loc:
            sc = loc["compact"].get("clock", {})
            lines.append("  ALoc.HasCompact := True;")
            use24h = sc.get("use24h", True)
            lines.append(f"  ALoc.CompactOverride.Clock.Use24h := {str(use24h).upper()};")
            fmt = sc.get("format", "{h}:{mm}")
            lines.append(f"  ALoc.CompactOverride.Clock.Format := {_quote(fmt)};")
            am_pm = sc.get("amPm")
            if am_pm:
                lines.append("  ALoc.CompactOverride.Clock.HasAmPm := True;")
                lines.append(f"  ALoc.CompactOverride.Clock.AmStr := {_quote(am_pm[0])};")
                lines.append(f"  ALoc.CompactOverride.Clock.PmStr := {_quote(am_pm[1])};")
            else:
                lines.append("  ALoc.CompactOverride.Clock.HasAmPm := False;")
                lines.append("  ALoc.CompactOverride.Clock.AmStr := '';")
                lines.append("  ALoc.CompactOverride.Clock.PmStr := '';")
        else:
            lines.append("  ALoc.HasCompact := False;")

        lines.append("end;")
        lines.append("")

    # Registry lookup
    lines.append("var")
    lines.append("  _LocCache: TTimeLocale;")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TTimeLocalePtr;")
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
    return os.path.join(root, "impl", "pascal", "locales", "SayableTimeLocales.pas")

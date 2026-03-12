"""Pascal locale emitter — single file with all locales.

Generates a Pascal unit `SayableDurationLocales` containing all locale
definitions as getter procedures with field-by-field assignment,
plural rule functions, and a registry lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.pascal.plural_rules import get_pas_plural

HEADER = make_header("codegen/targets/pascal/emitter.py", line_prefix="{ ", line_suffix=" }")

_CAT_LIST = ["zero", "one", "two", "few", "many", "other"]


def _quote(s: str) -> str:
    """Quote a string for Pascal using single quotes."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _emit_unit_forms(lines: list[str], prefix: str, unit: object) -> None:
    """Emit field-by-field assignment for a TUnitForms value."""
    if isinstance(unit, str):
        lines.append(f"  {prefix}.Simple := {_quote(unit)};")
        lines.append(f"  {prefix}.HasSimple := True;")
        for i in range(6):
            lines.append(f"  {prefix}.Forms[{i}] := '';")
    else:
        lines.append(f"  {prefix}.Simple := '';")
        lines.append(f"  {prefix}.HasSimple := False;")
        for i, cat in enumerate(_CAT_LIST):
            if cat in unit:
                lines.append(f"  {prefix}.Forms[{i}] := {_quote(unit[cat])};")
            else:
                lines.append(f"  {prefix}.Forms[{i}] := '';")


def _fn_name(code: str) -> str:
    """Generate a valid Pascal identifier for a plural function."""
    return "Plural_" + code.replace("-", "_")


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single SayableDurationLocales.pas file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = []
    lines.append("{$mode objfpc}{$H+}")
    lines.append("{$codepage utf8}")
    lines.append(HEADER.rstrip())
    lines.append("unit SayableDurationLocales;")
    lines.append("")
    lines.append("interface")
    lines.append("")
    lines.append("uses SayableDurationTypes;")
    lines.append("")

    # Declare all locale getter procedures
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"procedure GetLocale_{code.replace('-', '_')}(out ALoc: TDurationLocale);")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TDurationLocalePtr;")
    lines.append("")
    lines.append("implementation")
    lines.append("")

    # Plural functions
    for loc in sorted_locs:
        code = loc["code"]
        rule = loc["pluralRule"]
        fn = _fn_name(code)
        lines.append(locale_source_comment(code, line_prefix="{ ", line_suffix=" }").rstrip())
        lines.append(f"function {fn}(n: Integer): TPluralCategory;")
        lines.append(get_pas_plural(rule))
        lines.append("")

    # Locale getter procedures
    for loc in sorted_locs:
        code = loc["code"]
        name = loc["name"]
        fn = _fn_name(code)
        getter = f"GetLocale_{code.replace('-', '_')}"

        lines.append(locale_source_comment(code, line_prefix="{ ", line_suffix=" }").rstrip())
        lines.append(f"{{ {name} locale. }}")
        lines.append(f"procedure {getter}(out ALoc: TDurationLocale);")
        lines.append("begin")
        lines.append(f"  ALoc.Code := {_quote(code)};")
        lines.append(f"  ALoc.Plural := @{fn};")

        # Units
        for unit_name in ("Second", "Minute", "Hour", "Day", "Week", "Month", "Year"):
            key = unit_name.lower()
            _emit_unit_forms(lines, f"ALoc.Units.{unit_name}", loc["units"][key])

        # Simple fields
        lines.append(f"  ALoc.Half := {_quote(loc['half'])};")
        lines.append(f"  ALoc.Delimiter := {_quote(loc['delimiter'])};")
        lines.append(f"  ALoc.JustNow := {_quote(loc['justNow'])};")
        lines.append(f"  ALoc.Ago := {_quote(loc['ago'])};")
        lines.append(f"  ALoc.InFuture := {_quote(loc['inFuture'])};")

        # Short override
        if "short" in loc:
            ovr = loc["short"]
            lines.append("  ALoc.HasShort := TRUE;")
            # Units
            for unit_name in ("Second", "Minute", "Hour", "Day", "Week", "Month", "Year"):
                key = unit_name.lower()
                has_it = "units" in ovr and key in ovr["units"]
                lines.append(f"  ALoc.ShortOverride.Has{unit_name} := {str(has_it).upper()};")
                if has_it:
                    _emit_unit_forms(lines, f"ALoc.ShortOverride.{unit_name}", ovr["units"][key])
                else:
                    lines.append(f"  ALoc.ShortOverride.{unit_name}.Simple := '';")
                    lines.append(f"  ALoc.ShortOverride.{unit_name}.HasSimple := False;")
                    for i in range(6):
                        lines.append(f"  ALoc.ShortOverride.{unit_name}.Forms[{i}] := '';")

            has_half = "half" in ovr
            lines.append(f"  ALoc.ShortOverride.HasHalf := {str(has_half).upper()};")
            half_val = _quote(ovr["half"]) if has_half else "''"
            lines.append(f"  ALoc.ShortOverride.Half := {half_val};")

            has_delim = "delimiter" in ovr
            lines.append(f"  ALoc.ShortOverride.HasDelimiter := {str(has_delim).upper()};")
            delim_val = _quote(ovr["delimiter"]) if has_delim else "''"
            lines.append(f"  ALoc.ShortOverride.Delimiter := {delim_val};")

            has_ago = "ago" in ovr
            lines.append(f"  ALoc.ShortOverride.HasAgo := {str(has_ago).upper()};")
            ago_val = _quote(ovr["ago"]) if has_ago else "''"
            lines.append(f"  ALoc.ShortOverride.Ago := {ago_val};")

            has_in_future = "inFuture" in ovr
            lines.append(f"  ALoc.ShortOverride.HasInFuture := {str(has_in_future).upper()};")
            in_future_val = _quote(ovr["inFuture"]) if has_in_future else "''"
            lines.append(f"  ALoc.ShortOverride.InFuture := {in_future_val};")
        else:
            lines.append("  ALoc.HasShort := FALSE;")

        # Compact override
        if "compact" in loc:
            ovr = loc["compact"]
            lines.append("  ALoc.HasCompact := TRUE;")
            for unit_name in ("Second", "Minute", "Hour", "Day", "Week", "Month", "Year"):
                key = unit_name.lower()
                has_it = "units" in ovr and key in ovr["units"]
                lines.append(f"  ALoc.CompactOverride.Has{unit_name} := {str(has_it).upper()};")
                if has_it:
                    _emit_unit_forms(lines, f"ALoc.CompactOverride.{unit_name}", ovr["units"][key])
                else:
                    lines.append(f"  ALoc.CompactOverride.{unit_name}.Simple := '';")
                    lines.append(f"  ALoc.CompactOverride.{unit_name}.HasSimple := False;")
                    for i in range(6):
                        lines.append(f"  ALoc.CompactOverride.{unit_name}.Forms[{i}] := '';")

            has_half = "half" in ovr
            lines.append(f"  ALoc.CompactOverride.HasHalf := {str(has_half).upper()};")
            half_val = _quote(ovr["half"]) if has_half else "''"
            lines.append(f"  ALoc.CompactOverride.Half := {half_val};")

            has_delim = "delimiter" in ovr
            lines.append(f"  ALoc.CompactOverride.HasDelimiter := {str(has_delim).upper()};")
            delim_val = _quote(ovr["delimiter"]) if has_delim else "''"
            lines.append(f"  ALoc.CompactOverride.Delimiter := {delim_val};")

            has_ago = "ago" in ovr
            lines.append(f"  ALoc.CompactOverride.HasAgo := {str(has_ago).upper()};")
            ago_val = _quote(ovr["ago"]) if has_ago else "''"
            lines.append(f"  ALoc.CompactOverride.Ago := {ago_val};")

            has_in_future = "inFuture" in ovr
            lines.append(f"  ALoc.CompactOverride.HasInFuture := {str(has_in_future).upper()};")
            in_future_val = _quote(ovr["inFuture"]) if has_in_future else "''"
            lines.append(f"  ALoc.CompactOverride.InFuture := {in_future_val};")
        else:
            lines.append("  ALoc.HasCompact := FALSE;")

        lines.append("end;")
        lines.append("")

    # Registry lookup
    lines.append("var")
    lines.append("  _LocCache: TDurationLocale;")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TDurationLocalePtr;")
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
    return os.path.join(root, "impl", "pascal", "locales", "SayableDurationLocales.pas")

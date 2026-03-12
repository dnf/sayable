"""Pascal locale emitter — single file with all locales.

Generates a Pascal unit `SayableAgeLocales` containing all locale
definitions as getter functions with field-by-field assignment,
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


def _emit_stage_label(lines: list[str], prefix: str, stage: object) -> None:
    """Emit field-by-field assignment for a TStageLabel value."""
    if isinstance(stage, str):
        lines.append(f"  {prefix}.LabelText := {_quote(stage)};")
        lines.append(f"  {prefix}.M := '';")
        lines.append(f"  {prefix}.F := '';")
    else:
        lines.append(f"  {prefix}.LabelText := '';")
        lines.append(f"  {prefix}.M := {_quote(stage['m'])};")
        lines.append(f"  {prefix}.F := {_quote(stage['f'])};")


def _emit_override(lines: list[str], prefix: str, ovr: dict | None) -> None:
    """Emit field-by-field assignment for a TCompactnessOverride value."""
    for unit_name in ("Day", "Week", "Month", "Year"):
        key = unit_name.lower()
        has_it = ovr is not None and "units" in ovr and key in ovr["units"]
        lines.append(f"  {prefix}.Has{unit_name} := {str(has_it).upper()};")
        if has_it:
            _emit_unit_forms(lines, f"{prefix}.{unit_name}", ovr["units"][key])
        else:
            lines.append(f"  {prefix}.{unit_name}.Simple := '';")
            lines.append(f"  {prefix}.{unit_name}.HasSimple := False;")
            for i in range(6):
                lines.append(f"  {prefix}.{unit_name}.Forms[{i}] := '';")

    has_half = ovr is not None and "half" in ovr
    lines.append(f"  {prefix}.HasHalf := {str(has_half).upper()};")
    half_val = _quote(ovr["half"]) if has_half else "''"
    lines.append(f"  {prefix}.Half := {half_val};")

    has_delim = ovr is not None and "delimiter" in ovr
    lines.append(f"  {prefix}.HasDelimiter := {str(has_delim).upper()};")
    delim_val = _quote(ovr["delimiter"]) if has_delim else "''"
    lines.append(f"  {prefix}.Delimiter := {delim_val};")

    has_jb = ovr is not None and "justBorn" in ovr
    lines.append(f"  {prefix}.HasJustBorn := {str(has_jb).upper()};")
    jb_val = _quote(ovr["justBorn"]) if has_jb else "''"
    lines.append(f"  {prefix}.JustBorn := {jb_val};")


def _fn_name(code: str) -> str:
    """Generate a valid Pascal identifier for a plural function."""
    return "Plural_" + code.replace("-", "_")


def emit_all(all_locales: list[dict]) -> str:
    """Generate the single SayableAgeLocales.pas file with all locales."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = []
    lines.append("{$mode objfpc}{$H+}")
    lines.append("{$codepage utf8}")
    lines.append(HEADER.rstrip())
    lines.append("unit SayableAgeLocales;")
    lines.append("")
    lines.append("interface")
    lines.append("")
    lines.append("uses SayableAgeTypes;")
    lines.append("")

    # Declare all locale getter functions
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"procedure GetLocale_{code.replace('-', '_')}(out ALoc: TAgeLocale);")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TAgeLocalePtr;")
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
        lines.append(f"procedure {getter}(out ALoc: TAgeLocale);")
        lines.append("begin")
        lines.append(f"  ALoc.Code := {_quote(code)};")
        lines.append(f"  ALoc.Plural := @{fn};")

        # Units
        for unit_name in ("Day", "Week", "Month", "Year"):
            key = unit_name.lower()
            _emit_unit_forms(lines, f"ALoc.Units.{unit_name}", loc["units"][key])

        # Simple fields
        lines.append(f"  ALoc.Half := {_quote(loc['half'])};")
        lines.append(f"  ALoc.Delimiter := {_quote(loc['delimiter'])};")
        lines.append(f"  ALoc.JustBorn := {_quote(loc['justBorn'])};")

        # Stages
        for stage in ("Newborn", "Infant", "Toddler", "Child", "Teenager", "Adult"):
            _emit_stage_label(lines, f"ALoc.Stages.{stage}", loc["stages"][stage.lower()])

        # Short override
        if "short" in loc:
            lines.append("  ALoc.HasShort := TRUE;")
            _emit_override(lines, "ALoc.ShortOverride", loc["short"])
        else:
            lines.append("  ALoc.HasShort := FALSE;")
            _emit_override(lines, "ALoc.ShortOverride", None)

        # Compact override
        if "compact" in loc:
            lines.append("  ALoc.HasCompact := TRUE;")
            _emit_override(lines, "ALoc.CompactOverride", loc["compact"])
        else:
            lines.append("  ALoc.HasCompact := FALSE;")
            _emit_override(lines, "ALoc.CompactOverride", None)

        lines.append("end;")
        lines.append("")

    # Registry lookup
    lines.append("var")
    lines.append("  _LocCache: TAgeLocale;")
    lines.append("")
    lines.append("function GetLocaleByCode(const ACode: string): TAgeLocalePtr;")
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
    return os.path.join(root, "impl", "pascal", "locales", "SayableAgeLocales.pas")

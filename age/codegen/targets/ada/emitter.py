"""Ada locale emitter — single file with all locales.

Generates a single sayableage_locales.ads/.adb pair containing all locale
definitions, plural rule functions, and a locale lookup function.
"""

from __future__ import annotations

import os

from codegen.banner import locale_source_comment, make_header
from codegen.targets.ada.plural_rules import get_ada_plural

HEADER = make_header("codegen/targets/ada/emitter.py", line_prefix="--  ", line_suffix="")

_CAT_LIST = ["zero", "one", "two", "few", "many", "other"]
_CAT_ADA = {"zero": "Zero", "one": "One", "two": "Two", "few": "Few", "many": "Many", "other": "Other"}


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


def _unit_forms_lines(unit: object, var: str, indent: str = "      ") -> list[str]:
    """Emit lines that initialize a Unit_Forms record."""
    lines = []
    if isinstance(unit, str):
        lines.append(f"{indent}{var}.Has_Simple := True;")
        lines.append(f"{indent}{var}.Simple := To_Unbounded_String ({_quote(unit)});")
    else:
        lines.append(f"{indent}{var}.Has_Simple := False;")
        for cat in _CAT_LIST:
            if cat in unit:
                lines.append(f"{indent}{var}.Has_Form ({_CAT_ADA[cat]}) := True;")
                lines.append(f"{indent}{var}.Forms ({_CAT_ADA[cat]}) := To_Unbounded_String ({_quote(unit[cat])});")
            else:
                lines.append(f"{indent}{var}.Has_Form ({_CAT_ADA[cat]}) := False;")
    return lines


def _stage_label_lines(stage: object, var: str, indent: str = "      ") -> list[str]:
    """Emit lines that set a stage label."""
    if isinstance(stage, str):
        return [
            f"{indent}{var}.Label := To_Unbounded_String ({_quote(stage)});",
            f"{indent}{var}.F_Label := Null_Unbounded_String;",
        ]
    return [
        f"{indent}{var}.Label := To_Unbounded_String ({_quote(stage['m'])});",
        f"{indent}{var}.F_Label := To_Unbounded_String ({_quote(stage['f'])});",
    ]


def _compactness_lines(ovr: dict, var: str, indent: str = "      ") -> list[str]:
    """Emit lines that initialize a compactness override."""
    lines = []
    for unit_name in ("day", "week", "month", "year"):
        field = unit_name.capitalize()
        if "units" in ovr and unit_name in ovr["units"]:
            lines.append(f"{indent}{var}.Has_{field} := True;")
            for sl in _unit_forms_lines(ovr["units"][unit_name], f"{var}.{field}", indent):
                lines.append(sl)
        else:
            lines.append(f"{indent}{var}.Has_{field} := False;")
    if "half" in ovr:
        lines.append(f"{indent}{var}.Has_Half := True;")
        lines.append(f"{indent}{var}.Half := To_Unbounded_String ({_quote(ovr['half'])});")
    else:
        lines.append(f"{indent}{var}.Has_Half := False;")
    if "delimiter" in ovr:
        lines.append(f"{indent}{var}.Has_Delimiter := True;")
        lines.append(f"{indent}{var}.Delimiter := To_Unbounded_String ({_quote(ovr['delimiter'])});")
    else:
        lines.append(f"{indent}{var}.Has_Delimiter := False;")
    if "justBorn" in ovr:
        lines.append(f"{indent}{var}.Has_Just_Born := True;")
        lines.append(f"{indent}{var}.Just_Born := To_Unbounded_String ({_quote(ovr['justBorn'])});")
    else:
        lines.append(f"{indent}{var}.Has_Just_Born := False;")
    return lines


def emit_spec(all_locales: list[dict]) -> str:
    """Generate the sayableage_locales.ads spec file."""
    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("with Sayableage_Types; use Sayableage_Types;")
    lines.append("")
    lines.append("package Sayableage_Locales is")
    lines.append("")
    lines.append("   function Get_Locale (Code : String) return Locale_Access;")
    lines.append("")
    lines.append("end Sayableage_Locales;")
    lines.append("")
    return "\n".join(lines)


def emit_body(all_locales: list[dict]) -> str:
    """Generate the sayableage_locales.adb body file."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])

    lines: list[str] = []
    lines.append(HEADER.rstrip())
    lines.append("with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;")
    lines.append("")
    lines.append("package body Sayableage_Locales is")
    lines.append("")

    # Locale variables
    for data in sorted_locs:
        code = data["code"]
        var = _var_name(code)
        lines.append(f"   {var} : aliased Locale;")
    lines.append("")
    lines.append("   Initialized : Boolean := False;")
    lines.append("")

    # Plural rule functions (deduplicated)
    rules_used: dict[str, str] = {}
    for data in sorted_locs:
        rule = data["pluralRule"]
        if rule not in rules_used:
            rules_used[rule] = get_ada_plural(rule)

    for rule_name, body in sorted(rules_used.items()):
        fn = f"Plural_{rule_name}"
        lines.append(f"   function {fn} (N : Natural) return Plural_Category is")
        lines.append("   begin")
        for line in body.split("\n"):
            lines.append(f"   {line}")
        lines.append(f"   end {fn};")
        lines.append("")

    # Init procedures per locale
    for data in sorted_locs:
        code = data["code"]
        rule = data["pluralRule"]
        var = _var_name(code)

        lines.append(locale_source_comment(code, line_prefix="   --  ", line_suffix="").rstrip())
        lines.append(f"   procedure {_fn_name(code)} is")
        lines.append("   begin")
        lines.append(f"      {var}.Code := To_Unbounded_String ({_quote(code)});")
        lines.append(f"      {var}.Plural := Plural_{rule}'Access;")
        lines.append("")

        # Units
        for unit_name in ("day", "week", "month", "year"):
            unit_val = data["units"][unit_name]
            field = unit_name.capitalize()
            for sl in _unit_forms_lines(unit_val, f"{var}.Units.{field}", "      "):
                lines.append(sl)
        lines.append("")

        # Half, delimiter, justBorn
        lines.append(f"      {var}.Half := To_Unbounded_String ({_quote(data['half'])});")
        lines.append(f"      {var}.Delimiter := To_Unbounded_String ({_quote(data['delimiter'])});")
        lines.append(f"      {var}.Just_Born := To_Unbounded_String ({_quote(data['justBorn'])});")
        lines.append("")

        # Stages
        for stage_name in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
            stage_val = data["stages"][stage_name]
            field = stage_name.capitalize()
            for sl in _stage_label_lines(stage_val, f"{var}.Stage_Labels.{field}", "      "):
                lines.append(sl)
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

    lines.append("end Sayableage_Locales;")
    lines.append("")

    return "\n".join(lines)


def spec_path(root: str) -> str:
    return os.path.join(root, "impl", "ada", "src", "locales", "sayableage_locales.ads")


def body_path(root: str) -> str:
    return os.path.join(root, "impl", "ada", "src", "locales", "sayableage_locales.adb")

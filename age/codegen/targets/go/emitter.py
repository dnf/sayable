"""Go locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.go.plural_rules import get_go_plural

HEADER = make_header("codegen/targets/go/emitter.py")

# Plural category name mapping (qualified with pt. for locales subpackage)
_CAT_MAP = {
    "zero": "sa.Zero", "one": "sa.One", "two": "sa.Two",
    "few": "sa.Few", "many": "sa.Many", "other": "sa.Other",
}


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"sa.SimpleUnit({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{_CAT_MAP[cat]}: {_quote(unit[cat])}")
    return "sa.PluralUnit(map[sa.PluralCategory]string{" + ", ".join(pairs) + "})"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"sa.S({_quote(stage)})"
    return f"sa.G({_quote(stage['m'])}, {_quote(stage['f'])})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    name = data["name"]
    uc = code.upper()

    lines = [HEADER + locale_source_comment(code), "package locales\n"]
    lines.append('import sa "github.com/dnf/sayable/age/impl/go"\n')
    lines.append(f"// {uc} is the {name} locale.")
    lines.append(f"var {uc} = sa.AgeLocale{{")

    # Code
    lines.append(f"\tCode: {_quote(code)},")

    # Plural
    plural = get_go_plural(rule)
    lines.append(f"\tPlural: {plural.lstrip()},")

    # Units
    lines.append("\tUnits: struct{ Day, Week, Month, Year sa.UnitForms }{")
    for unit_name in ("day", "week", "month", "year"):
        cap = unit_name.capitalize()
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"\t\t{cap}:{' ' * (6 - len(cap))}{val},")
    lines.append("\t},")

    # Simple fields
    lines.append(f"\tHalf:      {_quote(data['half'])},")
    lines.append(f"\tDelimiter: {_quote(data['delimiter'])},")
    lines.append(f"\tJustBorn:  {_quote(data['justBorn'])},")

    # Stages
    lines.append("\tStages: struct{ Newborn, Infant, Toddler, Child, Teenager, Adult sa.StageLabel }{")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        cap = stage.capitalize()
        val = _stage_label(data["stages"][stage])
        lines.append(f"\t\t{cap}:{' ' * (9 - len(cap))}{val},")
    lines.append("\t},")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            cap = mode.capitalize()
            lines.append(f"\t{cap}: &sa.CompactnessOverride{{")
            # Collect all field names to compute uniform padding
            field_names = []
            if "units" in ovr:
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        field_names.append(unit_name.capitalize())
            for key, go_name in (("delimiter", "Delimiter"), ("half", "Half"), ("justBorn", "JustBorn")):
                if key in ovr:
                    field_names.append(go_name)
            max_field_len = max(len(f) for f in field_names) if field_names else 0
            if "units" in ovr:
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        ucap = unit_name.capitalize()
                        pad = " " * (max_field_len - len(ucap) + 1)
                        val = ovr["units"][unit_name]
                        if isinstance(val, str):
                            lines.append(f"\t\t{ucap}:{pad}&sa.UnitForms{{Simple: {_quote(val)}}},")
                        else:
                            # Plural override — unusual but support it
                            cats = ["zero", "one", "two", "few", "many", "other"]
                            pairs = []
                            for cat in cats:
                                if cat in val:
                                    pairs.append(f"{_CAT_MAP[cat]}: {_quote(val[cat])}")
                            map_lit = "map[sa.PluralCategory]string{" + ", ".join(pairs) + "}"
                            lines.append(f"\t\t{ucap}:{pad}unitFormsPtr({map_lit}),")
            if "delimiter" in ovr:
                pad = " " * (max_field_len - len("Delimiter") + 1)
                lines.append(f'\t\tDelimiter:{pad}strPtr({_quote(ovr["delimiter"])}),')
            if "half" in ovr:
                pad = " " * (max_field_len - len("Half") + 1)
                lines.append(f'\t\tHalf:{pad}strPtr({_quote(ovr["half"])}),')
            if "justBorn" in ovr:
                pad = " " * (max_field_len - len("JustBorn") + 1)
                lines.append(f'\t\tJustBorn:{pad}strPtr({_quote(ovr["justBorn"])}),')
            lines.append("\t},")

    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None  # Go doesn't have barrel files


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locale_registry.go with GetLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER, "package locales\n"]
    lines.append('import sa "github.com/dnf/sayable/age/impl/go"\n')
    lines.append("// GetLocale returns the locale for the given code, or nil if not found.")
    lines.append("func GetLocale(code string) *sa.AgeLocale {")
    lines.append("\tswitch code {")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'\tcase {_quote(code)}:')
        lines.append(f"\t\treturn &{code.upper()}")
    lines.append("\tdefault:")
    lines.append("\t\treturn nil")
    lines.append("\t}")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def emit_helpers() -> str:
    """Generate helpers.go with strPtr and unitFormsPtr for the locales subpackage."""
    lines = [HEADER, "package locales\n"]
    lines.append('import sa "github.com/dnf/sayable/age/impl/go"\n')
    lines.append("func strPtr(s string) *string { return &s }")
    lines.append("")
    lines.append("func unitFormsPtr(m map[sa.PluralCategory]string) *sa.UnitForms {")
    lines.append("\tu := sa.PluralUnit(m)")
    lines.append("\treturn &u")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", f"locale_{code}.go")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", "locale_registry.go")


def helpers_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "go", "locales", "helpers.go")


def barrel_path(root: str) -> str | None:
    return None

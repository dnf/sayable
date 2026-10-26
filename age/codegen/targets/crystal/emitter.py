"""Crystal locale emitter for sayable-age."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.crystal.plural_rules import get_cr_plural

HEADER = make_header("codegen/targets/crystal/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _hash_entries(indent: str, entries: list[tuple[str, str]]) -> list[str]:
    """One line per entry, `=>` aligned the way `crystal tool format` aligns it."""
    width = max(len(_quote(key)) for key, _ in entries)
    return [f"{indent}{_quote(key).ljust(width)} => {value}," for key, value in entries]


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return f"UnitForms.new({_quote(unit)})"
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{cat}: {_quote(unit[cat])}")
    return "UnitForms.new(" + ", ".join(pairs) + ")"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return f"StageLabel.new({_quote(stage)})"
    return f"StageLabel.new(m: {_quote(stage['m'])}, f: {_quote(stage['f'])})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    uc = code.upper()

    lines = [(HEADER + locale_source_comment(code, line_prefix="# ")).rstrip()]
    lines.append("module SayableAge")
    lines.append("  module Locales")
    lines.append(f"    {uc} = AgeLocale.new(")

    # Code
    lines.append(f"      code: {_quote(code)},")

    # Plural
    plural = get_cr_plural(rule)
    lines.append(f"      plural: {plural},")

    # Units
    lines.append("      units: {")
    lines += _hash_entries("        ", [(unit, _unit_forms(data["units"][unit]))
                                      for unit in ("day", "week", "month", "year")])
    lines.append("      },")

    # Simple fields
    lines.append(f"      half: {_quote(data['half'])},")
    lines.append(f"      delimiter: {_quote(data['delimiter'])},")
    lines.append(f"      just_born: {_quote(data['justBorn'])},")

    # Stages
    lines.append("      stages: {")
    lines += _hash_entries("        ", [(stage, _stage_label(data["stages"][stage]))
                                      for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult")])
    lines.append("      },")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"      {mode}: CompactnessOverride.new(")
            if "units" in ovr:
                lines.append("        units: {")
                lines += _hash_entries("          ", [(unit, _unit_forms(ovr["units"][unit]))
                                                    for unit in ("day", "week", "month", "year")
                                                    if unit in ovr["units"]])
                lines.append("        },")
            if "delimiter" in ovr:
                lines.append(f"        delimiter: {_quote(ovr['delimiter'])},")
            if "half" in ovr:
                lines.append(f"        half: {_quote(ovr['half'])},")
            if "justBorn" in ovr:
                lines.append(f"        just_born: {_quote(ovr['justBorn'])},")
            lines.append("      ),")

    lines.append("    )")
    lines.append("  end")
    lines.append("end")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locales/registry.cr with self.get(code) method."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER.rstrip()]
    lines.append("module SayableAge")
    lines.append("  module Locales")
    lines.append("    def self.get(code : String) : AgeLocale?")
    lines.append("      case code")
    code_width = max(len(_quote(loc["code"])) for loc in sorted_locs)
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"      when {_quote(code).ljust(code_width)} then {code.upper()}")
    # `crystal tool format` aligns every branch's result, `else` included.
    lines.append(f"      {'else'.ljust(len('when ') + code_width + len(' then '))}nil")
    lines.append("      end")
    lines.append("    end")
    lines.append("  end")
    lines.append("end")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "crystal", "src", "sayable_age", "locales", f"{code}.cr")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "crystal", "src", "sayable_age", "locales", "registry.cr")


def barrel_path(root: str) -> str | None:
    return None

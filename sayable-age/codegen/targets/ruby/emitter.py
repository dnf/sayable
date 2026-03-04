"""Ruby locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.ruby.plural_rules import get_rb_plural

HEADER = make_header("codegen/targets/ruby/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{cat}: {_quote(unit[cat])}")
    return "{ " + ", ".join(pairs) + " }"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return "{ m: " + _quote(stage["m"]) + ", f: " + _quote(stage["f"]) + " }"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]
    uc = code.upper()

    lines = ["# frozen_string_literal: true", "", (HEADER + locale_source_comment(code, line_prefix="# ")).rstrip()]
    lines.append("module SayableAge")
    lines.append("  module Locales")
    lines.append(f"    {uc} = AgeLocale.new(")

    # Code
    lines.append(f"      code: {_quote(code)},")

    # Plural
    plural = get_rb_plural(rule)
    lines.append(f"      plural: {plural},")

    # Units
    lines.append("      units: {")
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"        {_quote(unit_name)} => {val},")
    lines.append("      },")

    # Simple fields
    lines.append(f"      half: {_quote(data['half'])},")
    lines.append(f"      delimiter: {_quote(data['delimiter'])},")
    lines.append(f"      just_born: {_quote(data['justBorn'])},")

    # Stages
    lines.append("      stages: {")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"        {stage}: {val},")
    lines.append("      },")

    # Short/compact
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"      {mode}: CompactnessOverride.new(")
            if "units" in ovr:
                lines.append("        units: {")
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"          {_quote(unit_name)} => {val},")
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
    return None  # Ruby auto-loads via require


def emit_registry(all_locales: list[dict]) -> str:
    """Generate locales/registry.rb with self.get(code) method."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = ["# frozen_string_literal: true", "", HEADER.rstrip()]
    lines.append("module SayableAge")
    lines.append("  module Locales")
    lines.append("    def self.get(code)")
    lines.append("      case code")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"      when {_quote(code)} then {code.upper()}")
    lines.append("      end")
    lines.append("    end")
    lines.append("  end")
    lines.append("end")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "src", "ruby", "lib", "sayable_age", "locales", f"{code}.rb")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "src", "ruby", "lib", "sayable_age", "locales", "registry.rb")


def barrel_path(root: str) -> str | None:
    return None

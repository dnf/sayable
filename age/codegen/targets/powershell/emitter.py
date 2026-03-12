"""PowerShell locale emitter."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header
from codegen.targets.powershell.plural_rules import get_ps_plural

HEADER = make_header("codegen/targets/powershell/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for PowerShell using single quotes."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _unit_forms(unit: object) -> str:
    """Emit a unit forms value as a PowerShell hashtable or string."""
    if isinstance(unit, str):
        return _quote(unit)
    cats = ["zero", "one", "two", "few", "many", "other"]
    pairs = []
    for cat in cats:
        if cat in unit:
            pairs.append(f"{cat} = {_quote(unit[cat])}")
    return "@{ " + "; ".join(pairs) + " }"


def _stage_label(stage: object) -> str:
    if isinstance(stage, str):
        return _quote(stage)
    return "@{ m = " + _quote(stage["m"]) + "; f = " + _quote(stage["f"]) + " }"


def emit_locale(data: dict) -> str:
    code = data["code"]
    rule = data["pluralRule"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Plural rule function
    plural_body = get_ps_plural(rule).replace("$CODE", code)
    lines.append(plural_body)
    lines.append("")

    # Locale function that returns a hashtable
    lines.append(f"function locale_{code} {{")

    # Units
    lines.append("    $units = @{")
    for unit_name in ("day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"        {unit_name} = {val}")
    lines.append("    }")

    # Simple fields
    lines.append(f"    $half = {_quote(data['half'])}")
    lines.append(f"    $delimiter = {_quote(data['delimiter'])}")
    lines.append(f"    $justBorn = {_quote(data['justBorn'])}")

    # Stages
    lines.append("    $stages = @{")
    for stage in ("newborn", "infant", "toddler", "child", "teenager", "adult"):
        val = _stage_label(data["stages"][stage])
        lines.append(f"        {stage} = {val}")
    lines.append("    }")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"    ${mode} = @{{")
            if "units" in ovr:
                lines.append("        units = @{")
                for unit_name in ("day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"            {unit_name} = {val}")
                lines.append("        }")
            if "half" in ovr:
                lines.append(f"        half = {_quote(ovr['half'])}")
            if "delimiter" in ovr:
                lines.append(f"        delimiter = {_quote(ovr['delimiter'])}")
            if "justBorn" in ovr:
                lines.append(f"        justBorn = {_quote(ovr['justBorn'])}")
            lines.append("    }")
        else:
            lines.append(f"    ${mode} = $null")

    # Return the locale hashtable
    lines.append("    return @{")
    lines.append(f"        code = {_quote(code)}")
    lines.append(f"        plural = 'plural_{code}'")
    lines.append("        units = $units")
    lines.append("        half = $half")
    lines.append("        delimiter = $delimiter")
    lines.append("        justBorn = $justBorn")
    lines.append("        stages = $stages")
    lines.append(f"        short = ${mode if 'short' in data else 'null'}")
    # Fix: always reference the right variable
    lines.pop()  # remove last line
    short_val = "$short" if "short" in data else "$null"
    compact_val = "$compact" if "compact" in data else "$null"
    lines.append(f"        short = {short_val}")
    lines.append(f"        compact = {compact_val}")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.ps1 with Get-SayableAgeLocale function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    # Source all locale files
    lines.append("# Source all locale files relative to this script's directory")
    lines.append("$PSScriptRoot_ = $PSScriptRoot")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'. "$PSScriptRoot_/{code}.ps1"')
    lines.append("")

    # Build registry (case-sensitive hashtable — locale codes are lowercase)
    lines.append("$script:_sayableageRegistry = [hashtable]::new([System.StringComparer]::Ordinal)")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"$script:_sayableageRegistry[{_quote(code)}] = locale_{code}")
    lines.append("")

    # Get-locale function
    lines.append("function Get-SayableAgeLocale {")
    lines.append("    param([string]$Code)")
    lines.append("    if ($script:_sayableageRegistry.ContainsKey($Code)) {")
    lines.append("        return $script:_sayableageRegistry[$Code]")
    lines.append("    }")
    lines.append("    return $null")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "powershell", "locales", f"{code}.ps1")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "powershell", "locales", "registry.ps1")

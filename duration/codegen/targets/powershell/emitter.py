"""PowerShell locale emitter for sayable-duration."""

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
    for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
        val = _unit_forms(data["units"][unit_name])
        lines.append(f"        {unit_name} = {val}")
    lines.append("    }")

    # Simple fields
    lines.append(f"    $half = {_quote(data['half'])}")
    lines.append(f"    $delimiter = {_quote(data['delimiter'])}")
    lines.append(f"    $justNow = {_quote(data['justNow'])}")
    lines.append(f"    $ago = {_quote(data['ago'])}")
    lines.append(f"    $inFuture = {_quote(data['inFuture'])}")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            lines.append(f"    ${mode} = @{{")
            if "units" in ovr:
                lines.append("        units = @{")
                for unit_name in ("second", "minute", "hour", "day", "week", "month", "year"):
                    if unit_name in ovr["units"]:
                        val = _unit_forms(ovr["units"][unit_name])
                        lines.append(f"            {unit_name} = {val}")
                lines.append("        }")
            if "half" in ovr:
                lines.append(f"        half = {_quote(ovr['half'])}")
            if "delimiter" in ovr:
                lines.append(f"        delimiter = {_quote(ovr['delimiter'])}")
            if "ago" in ovr:
                lines.append(f"        ago = {_quote(ovr['ago'])}")
            if "inFuture" in ovr:
                lines.append(f"        inFuture = {_quote(ovr['inFuture'])}")
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
    lines.append("        justNow = $justNow")
    lines.append("        ago = $ago")
    lines.append("        inFuture = $inFuture")
    short_val = "$short" if "short" in data else "$null"
    compact_val = "$compact" if "compact" in data else "$null"
    lines.append(f"        short = {short_val}")
    lines.append(f"        compact = {compact_val}")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.ps1 with Get-SayableDurationLocale function."""
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

    # Build registry
    lines.append("$script:_sayabledurationRegistry = [hashtable]::new([System.StringComparer]::Ordinal)")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"$script:_sayabledurationRegistry[{_quote(code)}] = locale_{code}")
    lines.append("")

    # Get-locale function
    lines.append("function Get-SayableDurationLocale {")
    lines.append("    param([string]$Code)")
    lines.append("    if ($script:_sayabledurationRegistry.ContainsKey($Code)) {")
    lines.append("        return $script:_sayabledurationRegistry[$Code]")
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

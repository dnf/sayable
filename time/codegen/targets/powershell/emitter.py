"""PowerShell locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/powershell/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for PowerShell using single quotes."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _str_list(items: list[str]) -> str:
    """Emit a PowerShell array of strings."""
    return "@(" + ", ".join(_quote(s) for s in items) + ")"


def emit_locale(data: dict) -> str:
    """Generate a PowerShell locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    # Locale function that returns a hashtable
    lines.append(f"function locale_{code} {{")

    # Clock config
    lines.append(f"    $hours = {_str_list(clock['hours'])}")
    lines.append(f"    $midnight = {_quote(clock['midnight'])}")
    lines.append(f"    $noon = {_quote(clock['noon'])}")

    # Patterns hashtable (int keys)
    lines.append("    $patterns = @{}")
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            lines.append(f"    $patterns[{key}] = {_quote(clock['patterns'][key])}")

    lines.append("    $clock = @{")
    lines.append("        hours = $hours")
    lines.append("        midnight = $midnight")
    lines.append("        noon = $noon")
    lines.append("        patterns = $patterns")
    lines.append("    }")

    # Short override
    has_short = "short" in data
    if has_short:
        sc = data["short"].get("clock", {})
        use24h = "$true" if sc.get("use24h", True) else "$false"
        fmt = _quote(sc.get("format", "{h}:{mm}"))
        am_pm = sc.get("amPm")
        lines.append("    $short = @{")
        lines.append("        clock = @{")
        lines.append(f"            use24h = {use24h}")
        lines.append(f"            format = {fmt}")
        if am_pm:
            lines.append(f"            amPm = @({_quote(am_pm[0])}, {_quote(am_pm[1])})")
        else:
            lines.append("            amPm = $null")
        lines.append("        }")
        lines.append("    }")
    else:
        lines.append("    $short = $null")

    # Compact override
    has_compact = "compact" in data
    if has_compact:
        sc = data["compact"].get("clock", {})
        use24h = "$true" if sc.get("use24h", True) else "$false"
        fmt = _quote(sc.get("format", "{h}:{mm}"))
        am_pm = sc.get("amPm")
        lines.append("    $compact = @{")
        lines.append("        clock = @{")
        lines.append(f"            use24h = {use24h}")
        lines.append(f"            format = {fmt}")
        if am_pm:
            lines.append(f"            amPm = @({_quote(am_pm[0])}, {_quote(am_pm[1])})")
        else:
            lines.append("            amPm = $null")
        lines.append("        }")
        lines.append("    }")
    else:
        lines.append("    $compact = $null")

    # Return the locale hashtable
    lines.append("    return @{")
    lines.append(f"        code = {_quote(code)}")
    lines.append("        clock = $clock")
    lines.append("        short = $short")
    lines.append("        compact = $compact")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.ps1 with Get-SayableTimeLocale function."""
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
    lines.append("$script:_sayabletimeRegistry = [hashtable]::new([System.StringComparer]::Ordinal)")
    lines.append("")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"$script:_sayabletimeRegistry[{_quote(code)}] = locale_{code}")
    lines.append("")

    # Get-locale function
    lines.append("function Get-SayableTimeLocale {")
    lines.append("    param([string]$Code)")
    lines.append("    if ($script:_sayabletimeRegistry.ContainsKey($Code)) {")
    lines.append("        return $script:_sayabletimeRegistry[$Code]")
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

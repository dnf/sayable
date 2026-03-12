"""Crystal locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/crystal/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_array_12(items: list[str]) -> str:
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _patterns_hash(patterns: dict[str, str]) -> str:
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key} => {_quote(patterns[skey])}")
    return "{\n" + "".join(f"          {p},\n" for p in pairs) + "        }"


def _clock_override(clock: dict, indent: str) -> list[str]:
    lines = []
    use24h = "true" if clock.get("use24h", True) else "false"
    am_pm = clock.get("amPm")
    fmt = clock.get("format", "{h}:{mm}")

    if am_pm:
        lines.append(f"{indent}clock: ShortClockConfig.new(use24h: {use24h}, am_pm: [{_quote(am_pm[0])}, {_quote(am_pm[1])}], format: {_quote(fmt)})")
    else:
        lines.append(f"{indent}clock: ShortClockConfig.new(use24h: {use24h}, format: {_quote(fmt)})")

    return lines


def emit_locale(data: dict) -> str:
    code = data["code"]
    clock = data["clock"]
    uc = code.upper()

    lines = [(HEADER + locale_source_comment(code, line_prefix="# ")).rstrip()]
    lines.append("module SayableTime")
    lines.append("  module Locales")
    lines.append(f"    {uc} = TimeLocale.new(")

    # Code
    lines.append(f"      code: {_quote(code)},")

    # Clock config
    lines.append("      clock: ClockConfig.new(")
    lines.append(f"        hours: {_str_array_12(clock['hours'])},")
    lines.append(f"        midnight: {_quote(clock['midnight'])},")
    lines.append(f"        noon: {_quote(clock['noon'])},")
    lines.append(f"        patterns: {_patterns_hash(clock['patterns'])}")
    lines.append("      ),")

    # Short override
    if "short" in data:
        lines.append("      short: CompactnessOverride.new(")
        lines.extend(_clock_override(data["short"]["clock"], "        "))
        lines.append("      ),")

    # Compact override
    if "compact" in data:
        lines.append("      compact: CompactnessOverride.new(")
        lines.extend(_clock_override(data["compact"]["clock"], "        "))
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
    lines.append("module SayableTime")
    lines.append("  module Locales")
    lines.append("    def self.get(code : String) : TimeLocale?")
    lines.append("      case code")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"      when {_quote(code)} then {code.upper()}")
    lines.append("      else nil")
    lines.append("      end")
    lines.append("    end")
    lines.append("  end")
    lines.append("end")
    lines.append("")
    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "crystal", "src", "sayable_time", "locales", f"{code}.cr")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "crystal", "src", "sayable_time", "locales", "registry.cr")


def barrel_path(root: str) -> str | None:
    return None

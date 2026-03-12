"""Perl locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/perl/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace("'", "\\'")
    return f"'{escaped}'"


def _str_array_12(items: list[str]) -> str:
    return "[" + ", ".join(_quote(s) for s in items) + "]"


def _patterns_hash(patterns: dict[str, str]) -> str:
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key} => {_quote(patterns[skey])}")
    return "{ " + ", ".join(pairs) + " }"


def emit_locale(data: dict) -> str:
    code = data["code"]
    clock = data["clock"]
    uc = code.upper()

    lines = []
    lines.append("use strict;")
    lines.append("use warnings;")
    lines.append("use utf8;")
    lines.append("")
    lines.append((HEADER + locale_source_comment(code, line_prefix="# ")).rstrip())
    lines.append(f"package SayableTime::Locales::{uc};")
    lines.append("")
    lines.append("sub locale {{")

    # Code
    lines.append(f"  code => {_quote(code)},")

    # Clock config
    lines.append("  clock => {")
    lines.append(f"    hours => {_str_array_12(clock['hours'])},")
    lines.append(f"    midnight => {_quote(clock['midnight'])},")
    lines.append(f"    noon => {_quote(clock['noon'])},")
    lines.append(f"    patterns => {_patterns_hash(clock['patterns'])},")
    lines.append("  },")

    # Short override
    if "short" in data:
        sc = data["short"]["clock"]
        use24h = "1" if sc.get("use24h", True) else "0"
        am_pm = sc.get("amPm")
        fmt = sc.get("format", "{h}:{mm}")
        lines.append("  short => {")
        lines.append("    clock => {")
        lines.append(f"      use24h => {use24h},")
        if am_pm:
            lines.append(f"      am_pm => [{_quote(am_pm[0])}, {_quote(am_pm[1])}],")
        lines.append(f"      format => {_quote(fmt)},")
        lines.append("    },")
        lines.append("  },")

    # Compact override
    if "compact" in data:
        sc = data["compact"]["clock"]
        use24h = "1" if sc.get("use24h", True) else "0"
        am_pm = sc.get("amPm")
        fmt = sc.get("format", "{h}:{mm}")
        lines.append("  compact => {")
        lines.append("    clock => {")
        lines.append(f"      use24h => {use24h},")
        if am_pm:
            lines.append(f"      am_pm => [{_quote(am_pm[0])}, {_quote(am_pm[1])}],")
        lines.append(f"      format => {_quote(fmt)},")
        lines.append("    },")
        lines.append("  },")

    lines.append("}}")
    lines.append("")
    lines.append("1;")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str | None:
    return None


def emit_registry(all_locales: list[dict]) -> str:
    """Generate Locales.pm with get($code) function."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = ["use strict;", "use warnings;", "", HEADER.rstrip()]
    lines.append("package SayableTime::Locales;")
    lines.append("")

    for loc in sorted_locs:
        uc = loc["code"].upper()
        lines.append(f"use SayableTime::Locales::{uc};")
    lines.append("")

    lines.append("my %_LOCALES = (")
    for loc in sorted_locs:
        code = loc["code"]
        uc = code.upper()
        lines.append(f"  {_quote(code)} => SayableTime::Locales::{uc}::locale(),")
    lines.append(");")
    lines.append("")

    lines.append("sub get {")
    lines.append("  my ($class, $code) = @_;")
    lines.append("  return $_LOCALES{$code};")
    lines.append("}")
    lines.append("")
    lines.append("1;")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "perl", "lib", "SayableTime", "Locales", f"{code.upper()}.pm")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "perl", "lib", "SayableTime", "Locales.pm")


def barrel_path(root: str) -> str | None:
    return None

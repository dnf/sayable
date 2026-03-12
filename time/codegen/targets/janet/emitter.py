"""Janet locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/janet/emitter.py", line_prefix="# ")


def _quote(s: str) -> str:
    """Quote a string for Janet."""
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_list(items: list[str]) -> str:
    """Emit a Janet array of strings."""
    return "@[" + " ".join(_quote(s) for s in items) + "]"


def emit_locale(data: dict) -> str:
    """Generate a Janet locale file from canonical JSON."""
    code = data["code"]
    clock = data["clock"]
    lines = [HEADER + locale_source_comment(code, line_prefix="# ")]

    lines.append("(def locale")
    lines.append(f"  {{:code {_quote(code)}")

    # Clock config
    lines.append(f"   :clock {{:hours {_str_list(clock['hours'])}")
    lines.append(f"           :midnight {_quote(clock['midnight'])}")
    lines.append(f"           :noon {_quote(clock['noon'])}")

    # Patterns — keys are minute buckets (0, 5, 10, ..., 55)
    pattern_parts = []
    for key in ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]:
        if key in clock["patterns"]:
            pattern_parts.append(f"{key} {_quote(clock['patterns'][key])}")
    lines.append("           :patterns {" + " ".join(pattern_parts) + "}}")

    # Short override
    if "short" in data:
        sc = data["short"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append(f"   :short {{:clock {{:use24h {use24h} :format {_quote(fmt)} :am-pm [{_quote(am_pm[0])} {_quote(am_pm[1])}]}}}}")
        else:
            lines.append(f"   :short {{:clock {{:use24h {use24h} :format {_quote(fmt)}}}}}")

    # Compact override
    if "compact" in data:
        sc = data["compact"].get("clock", {})
        use24h = "true" if sc.get("use24h", True) else "false"
        fmt = sc.get("format", "{h}:{mm}")
        am_pm = sc.get("amPm")
        if am_pm:
            lines.append(f"   :compact {{:clock {{:use24h {use24h} :format {_quote(fmt)} :am-pm [{_quote(am_pm[0])} {_quote(am_pm[1])}]}}}}")
        else:
            lines.append(f"   :compact {{:clock {{:use24h {use24h} :format {_quote(fmt)}}}}}")

    lines.append("})")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate the registry module that maps locale codes to locale tables."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]

    lines.append("(def- locale-cache @{})")
    lines.append("")
    lines.append("(defn get-locale [code]")
    lines.append("  (if-let [cached (in locale-cache code)]")
    lines.append("    cached")
    lines.append("    (if-let [env")
    lines.append("             (case code")

    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f'               "{code}" (require "./locales/{code}")')

    lines.append("               nil)]")
    lines.append("      (let [loc ((in env 'locale) :value)]")
    lines.append("        (put locale-cache code loc)")
    lines.append("        loc)")
    lines.append("      nil)))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "janet", "locales", f"{code}.janet")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "janet", "locales", "registry.janet")

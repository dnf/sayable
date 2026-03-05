"""Clojure locale emitter for sayable-time."""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/clojure/emitter.py", line_prefix=";; ")


def _ns_name(code: str) -> str:
    """Convert locale code to Clojure namespace suffix (lowercase, underscores for hyphens)."""
    return code.replace("-", "_")


def _quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def _str_vec(items: list[str]) -> str:
    """Emit a Clojure vector of quoted strings."""
    return "[" + " ".join(_quote(s) for s in items) + "]"


def _patterns_map(patterns: dict[str, str]) -> str:
    """Emit a Clojure map for minute patterns."""
    keys = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
    pairs = []
    for key in keys:
        skey = str(key)
        if skey in patterns:
            pairs.append(f"{key} {_quote(patterns[skey])}")
    return "{" + " ".join(pairs) + "}"


def _clock_override(clock: dict) -> str:
    """Emit a Clojure map for short/compact clock override."""
    parts = []
    use24h = "true" if clock.get("use24h", True) else "false"
    parts.append(f":use-24h {use24h}")

    am_pm = clock.get("amPm")
    if am_pm:
        parts.append(f":am-pm [{_quote(am_pm[0])} {_quote(am_pm[1])}]")
    else:
        parts.append(":am-pm nil")

    fmt = clock.get("format", "{h}:{mm}")
    parts.append(f":format {_quote(fmt)}")

    return "{" + " ".join(parts) + "}"


def emit_locale(data: dict) -> str:
    code = data["code"]
    ns = _ns_name(code)

    lines = [HEADER + locale_source_comment(code, line_prefix=";; ")]
    lines.append(f"(ns sayabletime.locales.{ns})")
    lines.append("")
    lines.append("(def locale")

    clock = data["clock"]
    parts = []
    parts.append(f"  {{:code {_quote(code)}")
    parts.append(f"   :clock {{:hours {_str_vec(clock['hours'])}")
    parts.append(f"           :midnight {_quote(clock['midnight'])}")
    parts.append(f"           :noon {_quote(clock['noon'])}")
    parts.append(f"           :patterns {_patterns_map(clock['patterns'])}}}")

    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "clock" in ovr:
                parts.append(f"   :{mode} {{:clock {_clock_override(ovr['clock'])}}}")
            else:
                parts.append(f"   :{mode} nil")
        else:
            parts.append(f"   :{mode} nil")

    lines.append("\n".join(parts) + "})")
    lines.append("")

    return "\n".join(lines)


def emit_barrel(all_locales: list[dict]) -> str:
    """Generate the sayabletime.locales barrel namespace."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append("(ns sayabletime.locales")
    lines.append("  (:require")
    for loc in sorted_locs:
        ns = _ns_name(loc["code"])
        lines.append(f"    [sayabletime.locales.{ns} :as {ns}]")
    lines.append("    ))")
    lines.append("")
    lines.append("(defn get-locale [code]")
    lines.append("  (case code")
    for loc in sorted_locs:
        code = loc["code"]
        ns = _ns_name(code)
        lines.append(f'    "{code}" {ns}/locale')
    lines.append("    nil))")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    ns = _ns_name(code)
    return os.path.join(root, "impl", "clojure", "src", "sayabletime", "locales", f"{ns}.clj")


def barrel_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "clojure", "src", "sayabletime", "locales.clj")

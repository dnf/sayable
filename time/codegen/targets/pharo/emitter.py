"""Pharo Smalltalk locale emitter for sayable-time.

Generates Pharo chunk-format (.st) files loadable via FileStream fileIn:.
"""

from __future__ import annotations

from codegen.banner import locale_source_comment, make_header

HEADER = make_header("codegen/targets/pharo/emitter.py", line_prefix='" ', line_suffix=' "')


def _quote(s: str) -> str:
    """Quote a string for Smalltalk — single quotes with doubling."""
    escaped = s.replace("'", "''")
    return f"'{escaped}'"


def _str_list(items: list[str]) -> str:
    """Emit a Smalltalk ordered collection literal from a list of strings."""
    elems = ". ".join(_quote(item) for item in items)
    return f"(OrderedCollection withAll: {{ {elems} }})"


def emit_locale(data: dict) -> str:
    code = data["code"]
    clock = data["clock"]

    lines = [HEADER + locale_source_comment(code, line_prefix='" ', line_suffix=' "')]
    lines.append(f'"Locale: {code}"')
    lines.append("")

    lines.append(f"!SayableTimeLocales class methodsFor: 'locales'!")
    lines.append(f"{code}")
    lines.append(f"\t| locale clock |")
    lines.append(f"\tlocale := SayableTimeLocale new.")
    lines.append(f"\tlocale code: {_quote(code)}.")

    # Clock config
    lines.append(f"\tclock := Dictionary new.")
    lines.append(f"\tclock at: #hours put: {_str_list(clock['hours'])}.")
    lines.append(f"\tclock at: #midnight put: {_quote(clock['midnight'])}.")
    lines.append(f"\tclock at: #noon put: {_quote(clock['noon'])}.")

    # Patterns dict — keys are integers
    lines.append(f"\tclock at: #patterns put: (Dictionary newFromPairs: {{")
    for key in sorted(clock["patterns"].keys(), key=lambda x: int(x)):
        lines.append(f"\t\t{key}. {_quote(clock['patterns'][key])}.")
    lines.append(f"\t}}).")

    lines.append(f"\tlocale clock: clock.")

    # Short/compact overrides
    for mode in ("short", "compact"):
        if mode in data:
            ovr = data[mode]
            if "clock" in ovr:
                sc = ovr["clock"]
                lines.append(f"\tlocale {mode}: (Dictionary newFromPairs: {{")
                lines.append(f"\t\t#clock. (Dictionary newFromPairs: {{")
                lines.append(f"\t\t\t#use24h. {str(sc['use24h']).lower()}.")
                lines.append(f"\t\t\t#format. {_quote(sc['format'])}.")
                if "amPm" in sc:
                    lines.append(f"\t\t\t#amPm. (OrderedCollection withAll: {{ {_quote(sc['amPm'][0])}. {_quote(sc['amPm'][1])} }}).")
                lines.append(f"\t\t}}).")
                lines.append(f"\t}}).")

    lines.append(f"\t^ locale")
    lines.append("! !")
    lines.append("")

    return "\n".join(lines)


def emit_registry(all_locales: list[dict]) -> str:
    """Generate registry.st with lookup methods in chunk format."""
    sorted_locs = sorted(all_locales, key=lambda d: d["code"])
    lines = [HEADER]
    lines.append('"Locale registry — maps code strings to locale objects."')
    lines.append("")

    lines.append("!SayableTimeLocales class methodsFor: 'registry'!")
    lines.append("buildRegistry")
    lines.append("\t| registry |")
    lines.append("\tregistry := Dictionary new.")
    for loc in sorted_locs:
        code = loc["code"]
        lines.append(f"\tregistry at: {_quote(code)} put: self {code}.")
    lines.append("\t^ registry")
    lines.append("!")
    lines.append("")
    lines.append("get: aCode")
    lines.append("\t^ self registry at: aCode ifAbsent: [ nil ]")
    lines.append("!")
    lines.append("")
    lines.append("registry")
    lines.append("\tRegistry ifNil: [ Registry := self buildRegistry ].")
    lines.append("\t^ Registry")
    lines.append("! !")
    lines.append("")

    return "\n".join(lines)


def output_path(code: str, root: str) -> str:
    import os
    return os.path.join(root, "impl", "pharo", "locales", f"{code}.st")


def registry_path(root: str) -> str:
    import os
    return os.path.join(root, "impl", "pharo", "locales", "registry.st")

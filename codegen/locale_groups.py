"""Named locale groups for subsetting codegen output.

Groups let you generate only the locales you need:

    python -m codegen.generate --locales core         # top 10 by internet users
    python -m codegen.generate --locales cjk,romance  # combine groups
    python -m codegen.generate --locales fr            # just en + fr
"""

from __future__ import annotations

GROUPS: dict[str, list[str]] = {
    "core": ["en", "es", "zh", "fr", "de", "pt", "ar", "ja", "ru", "hi"],
    "european": [
        "bg", "br", "bs", "ca", "cs", "cy", "da", "de", "el", "en", "es",
        "et", "eu", "fi", "fr", "ga", "gd", "gv", "hr", "hu", "it", "kw",
        "lt", "lv", "mk", "mt", "nb", "nl", "pl", "pt", "ro", "ru", "sk",
        "sl", "sq", "sr", "sv", "uk",
    ],
    "cjk": ["zh", "ja", "ko"],
    "south-asian": ["bn", "gu", "hi", "mr", "ne", "pa", "si", "ta", "te", "ur"],
    "middle-eastern": ["ar", "fa", "he", "tr"],
    "nordic": ["da", "fi", "nb", "sv"],
    "slavic": ["bg", "bs", "cs", "hr", "mk", "pl", "ru", "sk", "sl", "sr", "uk"],
    "romance": ["ca", "es", "fr", "it", "pt", "ro"],
    "germanic": ["da", "de", "en", "nb", "nl", "sv"],
    "southeast-asian": ["fil", "id", "jv", "km", "ms", "my", "th", "vi"],
}

REQUIRED_LOCALES = {"en"}


def resolve_locales(specifier: str, available_codes: set[str]) -> list[str]:
    """Parse a comma-separated specifier into a sorted list of locale codes.

    Each token is either a group name (expanded to its members) or a bare
    locale code.  The union of all tokens is returned, plus REQUIRED_LOCALES.
    Raises ValueError for unknown tokens.
    """
    codes: set[str] = set()
    for token in specifier.split(","):
        token = token.strip()
        if not token:
            continue
        if token in GROUPS:
            codes.update(GROUPS[token])
        elif token in available_codes:
            codes.add(token)
        else:
            raise ValueError(
                f"Unknown locale or group: '{token}'. "
                f"Use --list-groups to see available groups."
            )
    codes.update(REQUIRED_LOCALES)
    return sorted(codes)


def list_groups() -> str:
    """Return a formatted listing of all named groups."""
    lines: list[str] = ["Available locale groups:", ""]
    for name, members in GROUPS.items():
        lines.append(f"  {name:20s} ({len(members):2d}) {', '.join(sorted(members))}")
    lines.append("")
    lines.append(f"Required (always included): {', '.join(sorted(REQUIRED_LOCALES))}")
    return "\n".join(lines)

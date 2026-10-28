"""Lay out generated Python the way ``ruff format`` does.

The generated locale files must pass ``ruff format --check`` (hecatron's lint
checks formatting), and the generator stays pure Python, so it can't run Ruff.
This reproduces the part of Ruff's layout the emitters need: a bracketed
group (a call, list, dict or tuple) stays on one line when the whole line fits
in the line length, and otherwise puts each item on its own line, indented,
with a trailing comma after each when there is more than one. A group with a
magic trailing comma always gets one item per line. Text that can't be split
(a long string) is left as it is, as Ruff leaves it.
"""

from __future__ import annotations

import unicodedata
from dataclasses import dataclass, field
from typing import Union

# [tool.ruff] line-length in impl/python/pyproject.toml.
LINE_LENGTH = 120
INDENT = "    "


@dataclass
class Group:
    """A bracketed group: ``opener`` (``[``, ``{``, ``(`` or ``Name(``), items, ``closer``.

    Each item is ``(head, value)``: the head is what precedes the value on its
    line (``"day": ``, ``code=``, or nothing for a list element).
    """

    opener: str
    closer: str
    items: list[tuple[str, Value]] = field(default_factory=list)
    magic_trailing_comma: bool = False


# Python source that stays on one line (a string literal, a name), or a group.
Value = Union[str, Group]


def call(name: str, arguments: list[tuple[str, Value]], *, magic_trailing_comma: bool = False) -> Group:
    """``name(...)``; each argument's head is ``keyword=``."""
    return Group(f"{name}(", ")", arguments, magic_trailing_comma)


def list_of(items: list[Value], *, magic_trailing_comma: bool = False) -> Group:
    return Group("[", "]", [("", item) for item in items], magic_trailing_comma)


def tuple_of(items: list[Value]) -> Group:
    """A tuple of two or more items (a one-item tuple needs a comma this doesn't give it)."""
    return Group("(", ")", [("", item) for item in items])


def dict_of(entries: list[tuple[str, Value]], *, magic_trailing_comma: bool = False) -> Group:
    """``{key: value, ...}`` from (key code, value) pairs."""
    return Group("{", "}", [(f"{key}: ", value) for key, value in entries], magic_trailing_comma)


# (first, last, width) for the code points whose width in Ruff (which measures
# with the unicode-width crate) isn't _char_width's general rule: mostly
# spacing vowel signs that extend a grapheme (Bengali, Odia, Tamil, Kannada,
# Malayalam, Sinhala), Hangul jamo and prepended concatenation marks. Found by
# having Ruff format a line of each assigned code point at exactly the line
# length and one column over.
_WIDTH_EXCEPTIONS = (
    (0x0600, 0x0604, 1), (0x06DD, 0x06DD, 1), (0x09BE, 0x09BE, 0), (0x09D7, 0x09D7, 0), (0x0B3E, 0x0B3E, 0),
    (0x0B57, 0x0B57, 0), (0x0BBE, 0x0BBE, 0), (0x0BD7, 0x0BD7, 0), (0x0CC0, 0x0CC0, 0), (0x0CC2, 0x0CC2, 0),
    (0x0CC7, 0x0CC8, 0), (0x0CCA, 0x0CCB, 0), (0x0CD5, 0x0CD6, 0), (0x0D3E, 0x0D3E, 0), (0x0D4E, 0x0D4E, 0),
    (0x0D57, 0x0D57, 0), (0x0DCF, 0x0DCF, 0), (0x0DDF, 0x0DDF, 0), (0x1160, 0x11FF, 0), (0x1715, 0x1715, 0),
    (0x1734, 0x1734, 0), (0x17A4, 0x17A4, 2), (0x17D8, 0x17D8, 3), (0x1B35, 0x1B35, 0), (0x1B3B, 0x1B3B, 0),
    (0x1B3D, 0x1B3D, 0), (0x1B43, 0x1B44, 0), (0x1BAA, 0x1BAA, 0), (0x1BF2, 0x1BF3, 0), (0x2D7F, 0x2D7F, 1),
    (0x302A, 0x302F, 0), (0x3099, 0x309A, 0), (0x3164, 0x3164, 0), (0xA8FA, 0xA8FA, 0), (0xA953, 0xA953, 0),
    (0xA9C0, 0xA9C0, 0), (0xD7B0, 0xD7C6, 0), (0xD7CB, 0xD7FB, 0), (0xFF9E, 0xFFA0, 0), (0xFFF9, 0xFFFB, 1),
    (0x110BD, 0x110BD, 1), (0x110CD, 0x110CD, 1), (0x111C0, 0x111C0, 0), (0x111C2, 0x111C3, 0),
    (0x11235, 0x11235, 0), (0x1133E, 0x1133E, 0), (0x1134D, 0x1134D, 0), (0x11357, 0x11357, 0),
    (0x113B8, 0x113B8, 0), (0x113C2, 0x113C2, 0), (0x113C5, 0x113C5, 0), (0x113C7, 0x113C9, 0),
    (0x113CF, 0x113CF, 0), (0x113D1, 0x113D1, 0), (0x114B0, 0x114B0, 0), (0x114BD, 0x114BD, 0),
    (0x115AF, 0x115AF, 0), (0x116B6, 0x116B6, 0), (0x11930, 0x11930, 0), (0x1193D, 0x1193D, 0),
    (0x1193F, 0x1193F, 0), (0x11941, 0x11941, 0), (0x11A84, 0x11A89, 0), (0x11D46, 0x11D46, 0),
    (0x11F02, 0x11F02, 0), (0x11F41, 0x11F41, 0), (0x13430, 0x1343F, 1), (0x16FE4, 0x16FE4, 0),
    (0x16FF0, 0x16FF1, 0), (0x1D165, 0x1D166, 0), (0x1D16D, 0x1D172, 0),
)


def _char_width(ch: str) -> int:
    """A character's width as Ruff measures it: 2 for wide, 0 for marks and format characters, else 1."""
    code_point = ord(ch)
    for first, last, char_width in _WIDTH_EXCEPTIONS:
        if first <= code_point <= last:
            return char_width
    if unicodedata.east_asian_width(ch) in ("W", "F"):
        return 2
    if unicodedata.category(ch) in ("Mn", "Me", "Cf"):
        return 0
    return 1


def width(text: str) -> int:
    return sum(_char_width(ch) for ch in text)


def flat(value: Value) -> str:
    """The value on one line."""
    if isinstance(value, str):
        return value
    return value.opener + ", ".join(head + flat(item) for head, item in value.items) + value.closer


def layout(value: Value, indent: str = "", head: str = "", tail: str = "") -> list[str]:
    """The lines ``ruff format`` gives ``head`` + ``value`` + ``tail`` at ``indent``."""
    one_line = indent + head + flat(value) + tail
    if isinstance(value, str):
        return [one_line]
    always_split = value.magic_trailing_comma and value.items
    if not always_split and width(one_line) <= LINE_LENGTH:
        return [one_line]
    comma = "," if value.magic_trailing_comma or len(value.items) > 1 else ""
    lines = [indent + head + value.opener]
    for item_head, item in value.items:
        lines.extend(layout(item, indent + INDENT, item_head, comma))
    lines.append(indent + value.closer + tail)
    return lines

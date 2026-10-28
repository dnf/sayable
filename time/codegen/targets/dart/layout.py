"""Lay out Dart expressions the way `dart format` (tall style) does.

The generated locale files must already be formatted, because the lint
fails on any file `dart format` would change and CI checks generated code
without a Dart SDK. This covers the only shapes the emitter produces:
calls, list and map literals, and atoms (literals, identifiers, and the
pre-formatted plural function).

The rules, matching dart_style for these shapes:

- An expression that fits in the page width stays on one line, with no
  trailing comma.
- Otherwise, an argument list or literal whose only element is a list or
  map literal hugs it: ``f({`` ... ``})``.
- Otherwise, every element goes on its own line, indented two more,
  followed by a comma, and the closing bracket gets a line of its own.
"""

from __future__ import annotations

from dataclasses import dataclass, field

PAGE_WIDTH = 80


@dataclass
class Atom:
    """Text that never splits. It may span lines (the plural function)."""

    text: str


@dataclass
class Group:
    """A call (``callee(``...``)``) or a list or map literal.

    Each item is ``(label, node)``: the label is a named argument's
    ``name: `` or a map entry's ``key: ``, or empty for a positional
    argument or list element.
    """

    opener: str
    closer: str
    items: list[tuple[str, Node]] = field(default_factory=list)


Node = Atom | Group


def call(callee: str, *args: Node, **named: Node) -> Group:
    """A call with positional then named arguments, in order."""
    items = [("", arg) for arg in args]
    items += [(f"{name}: ", value) for name, value in named.items()]
    return Group(f"{callee}(", ")", items)


def list_literal(values: list[Node]) -> Group:
    return Group("[", "]", [("", value) for value in values])


def map_literal(entries: list[tuple[str, Node]]) -> Group:
    """A map literal; each key is already Dart source."""
    return Group("{", "}", [(f"{key}: ", value) for key, value in entries])


def _width(text: str) -> int:
    """Line width as dart_style counts it: UTF-16 code units."""
    return len(text.encode("utf-16-le")) // 2


def _is_literal(node: Node) -> bool:
    return isinstance(node, Group) and node.opener in ("[", "{")


def _flat(node: Node) -> str | None:
    """The node on one line, or None when it can't be (a multi-line atom)."""
    if isinstance(node, Atom):
        return None if "\n" in node.text else node.text
    parts = []
    for label, value in node.items:
        text = _flat(value)
        if text is None:
            return None
        parts.append(label + text)
    return node.opener + ", ".join(parts) + node.closer


def _layout(node: Node, indent: int, lead: str, trail: str) -> list[str]:
    """Lines for ``node`` at ``indent``, after ``lead`` and before ``trail``."""
    flat = _flat(node)
    if flat is not None and _width(lead + flat + trail) <= PAGE_WIDTH:
        return [lead + flat + trail]
    if isinstance(node, Atom):
        return (lead + node.text + trail).split("\n")
    if len(node.items) == 1 and _is_literal(node.items[0][1]):
        label, only = node.items[0]
        return _layout(only, indent, lead + node.opener + label, node.closer + trail)
    inner = " " * (indent + 2)
    lines = [lead + node.opener]
    for label, value in node.items:
        lines += _layout(value, indent + 2, inner + label, ",")
    lines.append(" " * indent + node.closer + trail)
    return lines


def render(node: Node, lead: str = "", trail: str = "", indent: int = 0) -> str:
    """Format ``node`` as a statement starting at column ``indent``.

    ``lead`` is the text before it on its first line (including the
    indentation), such as ``final en = ``, and ``trail`` the text after it,
    such as ``;``.
    """
    return "\n".join(_layout(node, indent, lead, trail))

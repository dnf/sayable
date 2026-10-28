"""Lay out generated Rust the way rustfmt's default style does.

The generated locale files must pass `cargo fmt --check`, but codegen is pure
Python and CI checks it without a Rust toolchain, so this module reproduces the
rustfmt (default style, `max_width = 100`) decisions the locale files depend on:

- a call, tuple or array stays on one line when it fits and its items are no
  wider than `fn_call_width` / `array_width` (60); a lone argument that fits on
  the line stays inline whatever its width;
- otherwise a lone call, struct, array or tuple argument overflows (`Some(Foo {`
  ... `})`), with a nested call's budget capped at 60 columns; anything else
  goes one item per line;
- a struct field's value moves to the next line only when it can't be laid
  out on the field's own line;
- a `"...".to_string()` that doesn't fit breaks before `.to_string()`;
- a long `use` list wraps, filling lines.

Struct literals are always vertical: every struct the emitters build is wider
than rustfmt's 18-column `struct_lit_width`. Widths are measured like the
unicode-width crate rustfmt uses. If a value can't be laid out within the
width at all, rustfmt leaves that statement as written, so the layout is
retried without a width limit.

Build an expression from `lit`, `to_string`, `call`, `tup`, `arr`, `ref`,
`struct` and `raw`, then render it with `render_expr`. Identical copies live
in each library's `codegen/targets/rust/`.
"""

from __future__ import annotations

import unicodedata
from dataclasses import dataclass

MAX_WIDTH = 100
FN_CALL_WIDTH = 60
ARRAY_WIDTH = 60
TAB = 4

_UNLIMITED = 1 << 30

_LAM = frozenset("لڵڶڷڸݪࢦࣇ")
_ALEF = frozenset("آأإاٱٲٳٵݳݴ")
_SOFT_HYPHEN = "­"


def _is_zero_width(ch: str) -> bool:
    if ch == _SOFT_HYPHEN:
        return False
    return unicodedata.category(ch) in ("Mn", "Me", "Cf") or "ᅠ" <= ch <= "ᇿ"


def display_width(s: str) -> int:
    """Columns `s` occupies, as the unicode-width crate measures them.

    Wide and fullwidth characters take two columns, combining marks and format
    characters none, and an Arabic lam-alef pair one (it renders as a ligature).
    """
    total = 0
    after_lam = False
    for ch in s:
        if _is_zero_width(ch):
            continue
        if after_lam and ch in _ALEF:
            after_lam = False
            continue
        after_lam = ch in _LAM
        total += 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
    return total


def quote(s: str) -> str:
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


@dataclass(frozen=True)
class Lit:
    """An atom that never breaks: a literal, a path or `None`."""
    text: str


@dataclass(frozen=True)
class ToString:
    """`"...".to_string()`, a one-link method chain."""
    receiver: str


@dataclass(frozen=True)
class Call:
    callee: str
    args: tuple


@dataclass(frozen=True)
class Tup:
    items: tuple


@dataclass(frozen=True)
class Arr:
    items: tuple


@dataclass(frozen=True)
class Ref:
    inner: object


@dataclass(frozen=True)
class Struct:
    name: str
    fields: tuple


@dataclass(frozen=True)
class Raw:
    """Text that is already laid out for the indentation it appears at."""
    text: str


def lit(text: str) -> Lit:
    return Lit(text)


def to_string(s: str) -> ToString:
    return ToString(quote(s))


def call(callee: str, *args: object) -> Call:
    return Call(callee, tuple(args))


def tup(*items: object) -> Tup:
    return Tup(tuple(items))


def arr(items: list) -> Arr:
    return Arr(tuple(items))


def ref(inner: object) -> Ref:
    return Ref(inner)


def struct(name: str, fields: list[tuple[str, object]]) -> Struct:
    return Struct(name, tuple(fields))


def raw(text: str) -> Raw:
    return Raw(text)


def _is_one_line(text: str | None) -> bool:
    return text is not None and "\n" not in text


def _can_overflow(expr: object) -> bool:
    """rustfmt lets a lone argument of these kinds continue onto later lines."""
    if isinstance(expr, Ref):
        return _can_overflow(expr.inner)
    return isinstance(expr, (Call, ToString, Tup, Arr, Struct))


def _is_nested_call(expr: object) -> bool:
    if isinstance(expr, Ref):
        return _is_nested_call(expr.inner)
    return isinstance(expr, Call)


class _Layout:
    def __init__(self, max_width: int) -> None:
        self.max_width = max_width

    def rewrite(self, expr: object, indent: int, width: int, one_line_chain: bool = False) -> str | None:
        """Lay out `expr` starting `indent` columns in, with `width` columns left on its first line."""
        if isinstance(expr, Lit):
            return expr.text if display_width(expr.text) <= width else None
        if isinstance(expr, Raw):
            return expr.text
        if isinstance(expr, ToString):
            return self._rewrite_to_string(expr, indent, width, one_line_chain)
        if isinstance(expr, Ref):
            inner = self.rewrite(expr.inner, indent, width - 1, one_line_chain)
            return None if inner is None else "&" + inner
        if isinstance(expr, Call):
            return self._rewrite_list(f"{expr.callee}(", expr.args, ")", indent, width, FN_CALL_WIDTH)
        if isinstance(expr, Tup):
            return self._rewrite_list("(", expr.items, ")", indent, width, FN_CALL_WIDTH)
        if isinstance(expr, Arr):
            return self._rewrite_list("[", expr.items, "]", indent, width, ARRAY_WIDTH)
        if isinstance(expr, Struct):
            return self._rewrite_struct(expr, indent, width)
        raise TypeError(f"cannot lay out {expr!r}")

    def _rewrite_to_string(self, expr: ToString, indent: int, width: int, one_line_chain: bool) -> str | None:
        text = f"{expr.receiver}.to_string()"
        if display_width(text) <= width:
            return text
        if one_line_chain or display_width(expr.receiver) > width:
            return None
        return f"{expr.receiver}\n{' ' * (indent + TAB)}.to_string()"

    def _rewrite_list(self, open_: str, items: tuple, close: str, indent: int, width: int,
                      item_max_width: int) -> str | None:
        one_line_width = width - display_width(open_) - display_width(close)
        if one_line_width < 0:
            return None
        if not items:
            return open_ + close
        if len(items) == 1:
            only = items[0]
            if _can_overflow(only):
                budget = min(item_max_width, one_line_width) if _is_nested_call(only) else one_line_width
                overflowed = self.rewrite(only, indent, budget, one_line_chain=isinstance(only, ToString))
                if overflowed is not None:
                    return open_ + overflowed + close
            else:
                single = self.rewrite(only, indent, one_line_width)
                if _is_one_line(single):
                    return open_ + single + close
        else:
            singles = [self.rewrite(item, indent, one_line_width) for item in items]
            if all(_is_one_line(s) for s in singles):
                total = sum(display_width(s) for s in singles) + 2 * (len(singles) - 1)
                if total <= min(item_max_width, one_line_width):
                    return open_ + ", ".join(singles) + close
        return self._vertical(open_, items, close, indent)

    def _vertical(self, open_: str, items: tuple, close: str, indent: int) -> str | None:
        inner = indent + TAB
        lines = [open_]
        for item in items:
            text = self.rewrite(item, inner, self.max_width - inner - 1)
            if text is None:
                return None
            lines.append(" " * inner + text + ",")
        lines.append(" " * indent + close)
        return "\n".join(lines)

    def _rewrite_struct(self, expr: Struct, indent: int, width: int) -> str | None:
        head = f"{expr.name} {{"
        if display_width(head) > width:
            return None
        lines = [head]
        for name, value in expr.fields:
            field = self._rewrite_field(name, value, indent + TAB)
            if field is None:
                return None
            lines.append(field)
        lines.append(" " * indent + "}")
        return "\n".join(lines)

    def _rewrite_field(self, name: str, value: object, indent: int) -> str | None:
        """`name: value,`: on the field's line if it can start there, else on the next line."""
        lhs = f"{' ' * indent}{name}:"
        same_line = self.rewrite(value, indent, self.max_width - display_width(lhs) - 2)
        if same_line is not None:
            return f"{lhs} {same_line},"
        next_indent = indent + TAB
        next_line = self.rewrite(value, next_indent, self.max_width - next_indent)
        if next_line is not None:
            return f"{lhs}\n{' ' * next_indent}{next_line},"
        return None


def render_expr(expr: object, indent: int, prefix_width: int) -> str:
    """Lay out `expr` after `prefix_width` columns on a line indented `indent`."""
    text = _Layout(MAX_WIDTH).rewrite(expr, indent, MAX_WIDTH - prefix_width)
    if text is None:
        text = _Layout(_UNLIMITED).rewrite(expr, indent, _UNLIMITED)
    return text


def use_line(path: str, names: list[str]) -> str:
    """A `use path::{...};` item with its names sorted and wrapped like rustfmt."""
    ordered = sorted(names)
    one_line = f"use {path}::{{{', '.join(ordered)}}};"
    if display_width(one_line) <= MAX_WIDTH:
        return one_line
    budget = MAX_WIDTH - TAB
    rows: list[str] = []
    row = ""
    for name in ordered:
        candidate = f"{row} {name}," if row else f"{name},"
        if row and display_width(candidate) > budget:
            rows.append(row)
            row = f"{name},"
        else:
            row = candidate
    rows.append(row)
    body = "\n".join(" " * TAB + r for r in rows)
    return f"use {path}::{{\n{body}\n}};"

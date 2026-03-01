"""Plural rule definitions for all 12 patterns.

Each rule is a dict mapping language keys to code-emission functions.
The emitter for each target language calls get_plural_code(rule_name, lang)
to get the code string for the plural function body.
"""

from __future__ import annotations


def get_plural_code(rule: str, lang: str) -> str:
    """Return the plural function body for the given rule and target language."""
    emitter = _RULES[rule][lang]
    return emitter


# ── TypeScript ────────────────────────────────────────────────────────────

_TS = {
    "other_only": "() => 'other'",
    "one_other": "(n) => (n === 1 ? 'one' : 'other')",
    "one_other_zero_one": "(n) => (n === 0 || n === 1 ? 'one' : 'other')",
    "cs_sk": """\
(n) => {
    if (n === 1) return 'one';
    if (n >= 2 && n <= 4) return 'few';
    return 'other';
  }""",
    "lt": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return 'one';
    if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return 'few';
    return 'other';
  }""",
    "ro": """\
(n) => {
    if (n === 1) return 'one';
    if (n === 0 || (n % 100 >= 1 && n % 100 <= 19)) return 'few';
    return 'other';
  }""",
    "slavic_bcs": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return 'one';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
    return 'other';
  }""",
    "pl": """\
(n) => {
    if (n === 1) return 'one';
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
    return 'many';
  }""",
    "ru_uk": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return 'one';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
    return 'many';
  }""",
    "sl": """\
(n) => {
    const mod100 = n % 100;
    if (mod100 === 1) return 'one';
    if (mod100 === 2) return 'two';
    if (mod100 === 3 || mod100 === 4) return 'few';
    return 'other';
  }""",
    "ar": """\
(n) => {
    if (n === 0) return 'zero';
    if (n === 1) return 'one';
    if (n === 2) return 'two';
    const mod100 = n % 100;
    if (mod100 >= 3 && mod100 <= 10) return 'few';
    if (mod100 >= 11 && mod100 <= 99) return 'many';
    return 'other';
  }""",
    "lv": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 0 || (mod100 >= 11 && mod100 <= 19)) return 'zero';
    if (mod10 === 1 && mod100 !== 11) return 'one';
    return 'other';
  }""",
}

# ── Python ────────────────────────────────────────────────────────────────

_PY = {
    "other_only": 'lambda _n: "other"',
    "one_other": 'lambda n: "one" if n == 1 else "other"',
    "one_other_zero_one": 'lambda n: "one" if n in (0, 1) else "other"',
}

# Complex rules need named functions
_PY_NAMED = {
    "cs_sk": '''\
def _plural(n: int) -> str:
    if n == 1:
        return "one"
    if 2 <= n <= 4:
        return "few"
    return "other"''',
    "lt": '''\
def _plural(n: int) -> str:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 9 and (mod100 < 12 or mod100 > 19):
        return "few"
    return "other"''',
    "ro": '''\
def _plural(n: int) -> str:
    if n == 1:
        return "one"
    if n == 0 or 1 <= n % 100 <= 19:
        return "few"
    return "other"''',
    "slavic_bcs": '''\
def _plural(n: int) -> str:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "other"''',
    "pl": '''\
def _plural(n: int) -> str:
    if n == 1:
        return "one"
    mod10 = n % 10
    mod100 = n % 100
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "many"''',
    "ru_uk": '''\
def _plural(n: int) -> str:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "many"''',
    "sl": '''\
def _plural(n: int) -> str:
    mod100 = n % 100
    if mod100 == 1:
        return "one"
    if mod100 == 2:
        return "two"
    if mod100 in (3, 4):
        return "few"
    return "other"''',
    "ar": '''\
def _plural(n: int) -> str:
    if n == 0:
        return "zero"
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    mod100 = n % 100
    if 3 <= mod100 <= 10:
        return "few"
    if 11 <= mod100 <= 99:
        return "many"
    return "other"''',
    "lv": '''\
def _plural(n: int) -> str:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 0 or 11 <= mod100 <= 19:
        return "zero"
    if mod10 == 1 and mod100 != 11:
        return "one"
    return "other"''',
}

# ── Go ────────────────────────────────────────────────────────────────────

_GO = {
    "other_only": """\
\tfunc(_ int) PluralCategory {
\t\treturn Other
\t}""",
    "one_other": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\treturn Other
\t}""",
    "one_other_zero_one": """\
\tfunc(n int) PluralCategory {
\t\tif n == 0 || n == 1 {
\t\t\treturn One
\t\t}
\t\treturn Other
\t}""",
    "cs_sk": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tif n >= 2 && n <= 4 {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "lt": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "ro": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tif n == 0 || (n%100 >= 1 && n%100 <= 19) {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "slavic_bcs": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "pl": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn Few
\t\t}
\t\treturn Many
\t}""",
    "ru_uk": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn Few
\t\t}
\t\treturn Many
\t}""",
    "sl": """\
\tfunc(n int) PluralCategory {
\t\tmod100 := n % 100
\t\tif mod100 == 1 {
\t\t\treturn One
\t\t}
\t\tif mod100 == 2 {
\t\t\treturn Two
\t\t}
\t\tif mod100 == 3 || mod100 == 4 {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "ar": """\
\tfunc(n int) PluralCategory {
\t\tif n == 0 {
\t\t\treturn Zero
\t\t}
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tif n == 2 {
\t\t\treturn Two
\t\t}
\t\tmod100 := n % 100
\t\tif mod100 >= 3 && mod100 <= 10 {
\t\t\treturn Few
\t\t}
\t\tif mod100 >= 11 && mod100 <= 99 {
\t\t\treturn Many
\t\t}
\t\treturn Other
\t}""",
    "lv": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 0 || (mod100 >= 11 && mod100 <= 19) {
\t\t\treturn Zero
\t\t}
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\treturn Other
\t}""",
}

# ── Ruby ──────────────────────────────────────────────────────────────────

_RB = {
    "other_only": "->(n) { :other }",
    "one_other": "->(n) { n == 1 ? :one : :other }",
    "one_other_zero_one": "->(n) { [0, 1].include?(n) ? :one : :other }",
    "cs_sk": """\
lambda { |n|
        if n == 1 then :one
        elsif n >= 2 && n <= 4 then :few
        else :other
        end
      }""",
    "lt": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) then :few
        else :other
        end
      }""",
    "ro": """\
lambda { |n|
        if n == 1 then :one
        elsif n == 0 || (n % 100 >= 1 && n % 100 <= 19) then :few
        else :other
        end
      }""",
    "slavic_bcs": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then :few
        else :other
        end
      }""",
    "pl": """\
lambda { |n|
        if n == 1 then :one
        else
          mod10 = n % 10
          mod100 = n % 100
          if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then :few
          else :many
          end
        end
      }""",
    "ru_uk": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then :few
        else :many
        end
      }""",
    "sl": """\
lambda { |n|
        mod100 = n % 100
        if mod100 == 1 then :one
        elsif mod100 == 2 then :two
        elsif mod100 == 3 || mod100 == 4 then :few
        else :other
        end
      }""",
    "ar": """\
lambda { |n|
        if n == 0 then :zero
        elsif n == 1 then :one
        elsif n == 2 then :two
        else
          mod100 = n % 100
          if mod100 >= 3 && mod100 <= 10 then :few
          elsif mod100 >= 11 && mod100 <= 99 then :many
          else :other
          end
        end
      }""",
    "lv": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 0 || (mod100 >= 11 && mod100 <= 19) then :zero
        elsif mod10 == 1 && mod100 != 11 then :one
        else :other
        end
      }""",
}

# ── Rust ──────────────────────────────────────────────────────────────────

_RS = {
    "other_only": "|_n| PluralCategory::Other",
    "one_other": """\
|n| {
            if n == 1 {
                PluralCategory::One
            } else {
                PluralCategory::Other
            }
        }""",
    "one_other_zero_one": """\
|n| {
            if n == 0 || n == 1 { PluralCategory::One } else { PluralCategory::Other }
        }""",
    "cs_sk": """\
|n| {
            if n == 1 { PluralCategory::One }
            else if n >= 2 && n <= 4 { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "lt": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else if mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "ro": """\
|n| {
            if n == 1 { PluralCategory::One }
            else if n == 0 || (n % 100 >= 1 && n % 100 <= 19) { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "slavic_bcs": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "pl": """\
|n| {
            if n == 1 { return PluralCategory::One; }
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { PluralCategory::Few }
            else { PluralCategory::Many }
        }""",
    "ru_uk": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { PluralCategory::Few }
            else { PluralCategory::Many }
        }""",
    "sl": """\
|n| {
            let mod100 = n % 100;
            if mod100 == 1 { PluralCategory::One }
            else if mod100 == 2 { PluralCategory::Two }
            else if mod100 == 3 || mod100 == 4 { PluralCategory::Few }
            else { PluralCategory::Other }
        }""",
    "ar": """\
|n| {
            if n == 0 { return PluralCategory::Zero; }
            if n == 1 { return PluralCategory::One; }
            if n == 2 { return PluralCategory::Two; }
            let mod100 = n % 100;
            if mod100 >= 3 && mod100 <= 10 { PluralCategory::Few }
            else if mod100 >= 11 && mod100 <= 99 { PluralCategory::Many }
            else { PluralCategory::Other }
        }""",
    "lv": """\
|n| {
            let mod10 = n % 10;
            let mod100 = n % 100;
            if mod10 == 0 || (mod100 >= 11 && mod100 <= 19) { PluralCategory::Zero }
            else if mod10 == 1 && mod100 != 11 { PluralCategory::One }
            else { PluralCategory::Other }
        }""",
}

# ── Kotlin ────────────────────────────────────────────────────────────────

_KT = {
    "other_only": "{ _ -> PluralCategory.OTHER }",
    "one_other": "{ n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER }",
    "one_other_zero_one": "{ n -> if (n == 0 || n == 1) PluralCategory.ONE else PluralCategory.OTHER }",
    "cs_sk": """\
{ n ->
            when {
                n == 1 -> PluralCategory.ONE
                n in 2..4 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "lt": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..9 && (mod100 < 12 || mod100 > 19) -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "ro": """\
{ n ->
            when {
                n == 1 -> PluralCategory.ONE
                n == 0 || n % 100 in 1..19 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "slavic_bcs": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "pl": """\
{ n ->
            if (n == 1) PluralCategory.ONE
            else {
                val mod10 = n % 10
                val mod100 = n % 100
                if (mod10 in 2..4 && (mod100 < 12 || mod100 > 14)) PluralCategory.FEW
                else PluralCategory.MANY
            }
        }""",
    "ru_uk": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                mod10 in 2..4 && (mod100 < 12 || mod100 > 14) -> PluralCategory.FEW
                else -> PluralCategory.MANY
            }
        }""",
    "sl": """\
{ n ->
            val mod100 = n % 100
            when {
                mod100 == 1 -> PluralCategory.ONE
                mod100 == 2 -> PluralCategory.TWO
                mod100 in 3..4 -> PluralCategory.FEW
                else -> PluralCategory.OTHER
            }
        }""",
    "ar": """\
{ n ->
            when {
                n == 0 -> PluralCategory.ZERO
                n == 1 -> PluralCategory.ONE
                n == 2 -> PluralCategory.TWO
                n % 100 in 3..10 -> PluralCategory.FEW
                n % 100 in 11..99 -> PluralCategory.MANY
                else -> PluralCategory.OTHER
            }
        }""",
    "lv": """\
{ n ->
            val mod10 = n % 10
            val mod100 = n % 100
            when {
                mod10 == 0 || mod100 in 11..19 -> PluralCategory.ZERO
                mod10 == 1 && mod100 != 11 -> PluralCategory.ONE
                else -> PluralCategory.OTHER
            }
        }""",
}

# ── C++ ───────────────────────────────────────────────────────────────────

_CPP = {
    "other_only": """\
[](int) -> PluralCategory {
            return PluralCategory::Other;
        }""",
    "one_other": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
    "one_other_zero_one": """\
[](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
    "cs_sk": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n >= 2 && n <= 4) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "lt": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "ro": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "slavic_bcs": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "pl": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        }""",
    "ru_uk": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        }""",
    "sl": """\
[](int n) -> PluralCategory {
            int mod100 = n % 100;
            if (mod100 == 1) return PluralCategory::One;
            if (mod100 == 2) return PluralCategory::Two;
            if (mod100 == 3 || mod100 == 4) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "ar": """\
[](int n) -> PluralCategory {
            if (n == 0) return PluralCategory::Zero;
            if (n == 1) return PluralCategory::One;
            if (n == 2) return PluralCategory::Two;
            int mod100 = n % 100;
            if (mod100 >= 3 && mod100 <= 10) return PluralCategory::Few;
            if (mod100 >= 11 && mod100 <= 99) return PluralCategory::Many;
            return PluralCategory::Other;
        }""",
    "lv": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PluralCategory::Zero;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
}

# ── PHP ───────────────────────────────────────────────────────────────────

_PHP_INLINE = {
    "other_only": "static fn(int $n): PluralCategory => PluralCategory::Other",
    "one_other": "static fn(int $n): PluralCategory => $n === 1 ? PluralCategory::One : PluralCategory::Other",
    "one_other_zero_one": "static fn(int $n): PluralCategory => $n === 0 || $n === 1 ? PluralCategory::One : PluralCategory::Other",
}

_PHP_NAMED = {
    "cs_sk": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        if ($n >= 2 && $n <= 4) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "lt": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}
        if ($mod10 >= 2 && $mod10 <= 9 && ($mod100 < 12 || $mod100 > 19)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "ro": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        if ($n === 0 || ($n % 100 >= 1 && $n % 100 <= 19)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "slavic_bcs": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}
        if ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "pl": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Many;
    }}""",
    "ru_uk": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}
        if ($mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Many;
    }}""",
    "sl": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod100 = $n % 100;
        if ($mod100 === 1) {{
            return PluralCategory::One;
        }}
        if ($mod100 === 2) {{
            return PluralCategory::Two;
        }}
        if ($mod100 === 3 || $mod100 === 4) {{
            return PluralCategory::Few;
        }}

        return PluralCategory::Other;
    }}""",
    "ar": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        if ($n === 0) {{
            return PluralCategory::Zero;
        }}
        if ($n === 1) {{
            return PluralCategory::One;
        }}
        if ($n === 2) {{
            return PluralCategory::Two;
        }}
        $mod100 = $n % 100;
        if ($mod100 >= 3 && $mod100 <= 10) {{
            return PluralCategory::Few;
        }}
        if ($mod100 >= 11 && $mod100 <= 99) {{
            return PluralCategory::Many;
        }}

        return PluralCategory::Other;
    }}""",
    "lv": """\
    private static function plural{CODE}(int $n): PluralCategory
    {{
        $mod10 = $n % 10;
        $mod100 = $n % 100;
        if ($mod10 === 0 || ($mod100 >= 11 && $mod100 <= 19)) {{
            return PluralCategory::Zero;
        }}
        if ($mod10 === 1 && $mod100 !== 11) {{
            return PluralCategory::One;
        }}

        return PluralCategory::Other;
    }}""",
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda/closure."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def needs_named_function(rule: str, lang: str) -> bool:
    """True if this rule needs a named function (not inline) in the given language."""
    if lang == "typescript":
        return not is_simple_plural(rule)
    if lang == "python":
        return rule in _PY_NAMED
    if lang == "php":
        return rule in _PHP_NAMED
    return False


_TS_NAMED = {
    "cs_sk": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  if (n >= 2 && n <= 4) return 'few';
  return 'other';
}""",
    "lt": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return 'few';
  return 'other';
}""",
    "ro": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  if (n === 0 || (n % 100 >= 1 && n % 100 <= 19)) return 'few';
  return 'other';
}""",
    "slavic_bcs": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'other';
}""",
    "pl": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'many';
}""",
    "ru_uk": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'many';
}""",
    "sl": """\
function plural(n: number): PluralCategory {
  const mod100 = n % 100;
  if (mod100 === 1) return 'one';
  if (mod100 === 2) return 'two';
  if (mod100 === 3 || mod100 === 4) return 'few';
  return 'other';
}""",
    "ar": """\
function plural(n: number): PluralCategory {
  if (n === 0) return 'zero';
  if (n === 1) return 'one';
  if (n === 2) return 'two';
  const mod100 = n % 100;
  if (mod100 >= 3 && mod100 <= 10) return 'few';
  if (mod100 >= 11 && mod100 <= 99) return 'many';
  return 'other';
}""",
    "lv": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 0 || (mod100 >= 11 && mod100 <= 19)) return 'zero';
  if (mod10 === 1 && mod100 !== 11) return 'one';
  return 'other';
}""",
}


def get_ts_plural(rule: str) -> str:
    """Get TypeScript plural inline expression for simple rules."""
    return _TS[rule]


def get_ts_named_function(rule: str) -> str | None:
    """Get the named function declaration for complex TS rules."""
    return _TS_NAMED.get(rule)


def get_py_plural(rule: str) -> str:
    """Get Python plural expression (lambda or function reference)."""
    if rule in _PY:
        return _PY[rule]
    return "_plural"


def get_py_named_function(rule: str) -> str | None:
    """Get Python named function for complex rules."""
    return _PY_NAMED.get(rule)


def get_go_plural(rule: str) -> str:
    return _GO[rule]


def get_rb_plural(rule: str) -> str:
    return _RB[rule]


def get_rs_plural(rule: str) -> str:
    return _RS[rule]


def get_kt_plural(rule: str) -> str:
    return _KT[rule]


def get_cpp_plural(rule: str) -> str:
    return _CPP[rule]


def get_php_inline_plural(rule: str) -> str | None:
    """Get PHP inline plural for simple rules."""
    return _PHP_INLINE.get(rule)


def get_php_named_function(rule: str, code: str) -> str | None:
    """Get PHP named static method for complex rules."""
    template = _PHP_NAMED.get(rule)
    if template is None:
        return None
    return template.format(CODE=code.upper())


# Master lookup used by emitters
_RULES: dict[str, dict[str, str]] = {}
for rule_name in (
    "other_only", "one_other", "one_other_zero_one",
    "cs_sk", "lt", "ro", "slavic_bcs", "pl", "ru_uk", "sl", "ar", "lv",
):
    _RULES[rule_name] = {
        "typescript": _TS[rule_name],
        "python": _PY.get(rule_name, "_plural"),
        "go": _GO[rule_name],
        "ruby": _RB[rule_name],
        "rust": _RS[rule_name],
        "kotlin": _KT[rule_name],
        "cpp": _CPP[rule_name],
        "php": _PHP_INLINE.get(rule_name, "NAMED"),
    }

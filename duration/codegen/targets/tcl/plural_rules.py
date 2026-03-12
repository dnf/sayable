"""Tcl plural rule definitions for all 23 patterns."""

from __future__ import annotations

_TCL = {
    "other_only": """proc plural_$CODE {n} {
    return "other"
}""",
    "one_other": """proc plural_$CODE {n} {
    if {$n == 1} { return "one" }
    return "other"
}""",
    "one_other_zero_one": """proc plural_$CODE {n} {
    if {$n == 0 || $n == 1} { return "one" }
    return "other"
}""",
    "cs_sk": """proc plural_$CODE {n} {
    if {$n == 1} { return "one" }
    if {$n >= 2 && $n <= 4} { return "few" }
    return "other"
}""",
    "lt": """proc plural_$CODE {n} {
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 == 1 && $mod100 != 11} { return "one" }
    if {$mod10 >= 2 && $mod10 <= 9 && ($mod100 < 12 || $mod100 > 19)} { return "few" }
    return "other"
}""",
    "ro": """proc plural_$CODE {n} {
    if {$n == 1} { return "one" }
    set mod100 [expr {$n % 100}]
    if {$n == 0 || ($mod100 >= 1 && $mod100 <= 19)} { return "few" }
    return "other"
}""",
    "slavic_bcs": """proc plural_$CODE {n} {
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 == 1 && $mod100 != 11} { return "one" }
    if {$mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)} { return "few" }
    return "other"
}""",
    "pl": """proc plural_$CODE {n} {
    if {$n == 1} { return "one" }
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)} { return "few" }
    return "many"
}""",
    "ru_uk": """proc plural_$CODE {n} {
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 == 1 && $mod100 != 11} { return "one" }
    if {$mod10 >= 2 && $mod10 <= 4 && ($mod100 < 12 || $mod100 > 14)} { return "few" }
    return "many"
}""",
    "sl": """proc plural_$CODE {n} {
    set mod100 [expr {$n % 100}]
    if {$mod100 == 1} { return "one" }
    if {$mod100 == 2} { return "two" }
    if {$mod100 == 3 || $mod100 == 4} { return "few" }
    return "other"
}""",
    "ar": """proc plural_$CODE {n} {
    if {$n == 0} { return "zero" }
    if {$n == 1} { return "one" }
    if {$n == 2} { return "two" }
    set mod100 [expr {$n % 100}]
    if {$mod100 >= 3 && $mod100 <= 10} { return "few" }
    if {$mod100 >= 11 && $mod100 <= 99} { return "many" }
    return "other"
}""",
    "lv": """proc plural_$CODE {n} {
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 == 0 || ($mod100 >= 11 && $mod100 <= 19)} { return "zero" }
    if {$mod10 == 1 && $mod100 != 11} { return "one" }
    return "other"
}""",
    "he": """proc plural_$CODE {n} {
    if {$n == 1} { return "one" }
    if {$n == 2} { return "two" }
    return "other"
}""",
    "mk": """proc plural_$CODE {n} {
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 == 1 && $mod100 != 11} { return "one" }
    return "other"
}""",
    "cy": """proc plural_$CODE {n} {
    if {$n == 0} { return "zero" }
    if {$n == 1} { return "one" }
    if {$n == 2} { return "two" }
    if {$n == 3} { return "few" }
    if {$n == 6} { return "many" }
    return "other"
}""",
    "gv": """proc plural_$CODE {n} {
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 == 1} { return "one" }
    if {$mod10 == 2} { return "two" }
    if {$mod100 == 0 || $mod100 == 20 || $mod100 == 40 || $mod100 == 60 || $mod100 == 80} { return "few" }
    return "other"
}""",
    "gd": """proc plural_$CODE {n} {
    if {$n == 1 || $n == 11} { return "one" }
    if {$n == 2 || $n == 12} { return "two" }
    if {($n >= 3 && $n <= 10) || ($n >= 13 && $n <= 19)} { return "few" }
    return "other"
}""",
    "ga": """proc plural_$CODE {n} {
    if {$n == 1} { return "one" }
    if {$n == 2} { return "two" }
    if {$n >= 3 && $n <= 6} { return "few" }
    if {$n >= 7 && $n <= 10} { return "many" }
    return "other"
}""",
    "mt": """proc plural_$CODE {n} {
    if {$n == 1} { return "one" }
    if {$n == 2} { return "two" }
    set mod100 [expr {$n % 100}]
    if {$n == 0 || ($mod100 >= 3 && $mod100 <= 10)} { return "few" }
    if {$mod100 >= 11 && $mod100 <= 19} { return "many" }
    return "other"
}""",
    "br": """proc plural_$CODE {n} {
    set mod10 [expr {$n % 10}]
    set mod100 [expr {$n % 100}]
    if {$mod10 == 1 && $mod100 != 11 && $mod100 != 71 && $mod100 != 91} { return "one" }
    if {$mod10 == 2 && $mod100 != 12 && $mod100 != 72 && $mod100 != 92} { return "two" }
    if {($mod10 == 3 || $mod10 == 4 || $mod10 == 9) && !($mod100 >= 10 && $mod100 <= 19) && !($mod100 >= 70 && $mod100 <= 79) && !($mod100 >= 90 && $mod100 <= 99)} { return "few" }
    if {$n != 0 && $n % 1000000 == 0} { return "many" }
    return "other"
}""",
    "kw": """proc plural_$CODE {n} {
    if {$n == 0} { return "zero" }
    if {$n == 1} { return "one" }
    set mod100 [expr {$n % 100}]
    if {$mod100 == 2 || $mod100 == 22 || $mod100 == 42 || $mod100 == 62 || $mod100 == 82} { return "two" }
    if {$mod100 == 3 || $mod100 == 23 || $mod100 == 43 || $mod100 == 63 || $mod100 == 83} { return "few" }
    if {$n != 1 && ($mod100 == 1 || $mod100 == 21 || $mod100 == 41 || $mod100 == 61 || $mod100 == 81)} { return "many" }
    return "other"
}""",
    "shi": """proc plural_$CODE {n} {
    if {$n == 0 || $n == 1} { return "one" }
    if {$n >= 2 && $n <= 10} { return "few" }
    return "other"
}""",
    "tzm": """proc plural_$CODE {n} {
    if {$n == 0 || $n == 1 || ($n >= 11 && $n <= 99)} { return "one" }
    return "other"
}""",
}


def get_tcl_plural(rule: str) -> str:
    """Get Tcl plural proc body for a given rule."""
    return _TCL[rule]

"""PowerShell plural rule definitions for all 23 patterns."""

from __future__ import annotations

_PS = {
    "other_only": """function plural_$CODE([int]$n) {
    return 'other'
}""",
    "one_other": """function plural_$CODE([int]$n) {
    if ($n -eq 1) { return 'one' }
    return 'other'
}""",
    "one_other_zero_one": """function plural_$CODE([int]$n) {
    if ($n -eq 0 -or $n -eq 1) { return 'one' }
    return 'other'
}""",
    "cs_sk": """function plural_$CODE([int]$n) {
    if ($n -eq 1) { return 'one' }
    if ($n -ge 2 -and $n -le 4) { return 'few' }
    return 'other'
}""",
    "lt": """function plural_$CODE([int]$n) {
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -eq 1 -and $mod100 -ne 11) { return 'one' }
    if ($mod10 -ge 2 -and $mod10 -le 9 -and ($mod100 -lt 12 -or $mod100 -gt 19)) { return 'few' }
    return 'other'
}""",
    "ro": """function plural_$CODE([int]$n) {
    if ($n -eq 1) { return 'one' }
    if ($n -eq 0 -or ($n % 100 -ge 1 -and $n % 100 -le 19)) { return 'few' }
    return 'other'
}""",
    "slavic_bcs": """function plural_$CODE([int]$n) {
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -eq 1 -and $mod100 -ne 11) { return 'one' }
    if ($mod10 -ge 2 -and $mod10 -le 4 -and ($mod100 -lt 12 -or $mod100 -gt 14)) { return 'few' }
    return 'other'
}""",
    "pl": """function plural_$CODE([int]$n) {
    if ($n -eq 1) { return 'one' }
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -ge 2 -and $mod10 -le 4 -and ($mod100 -lt 12 -or $mod100 -gt 14)) { return 'few' }
    return 'many'
}""",
    "ru_uk": """function plural_$CODE([int]$n) {
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -eq 1 -and $mod100 -ne 11) { return 'one' }
    if ($mod10 -ge 2 -and $mod10 -le 4 -and ($mod100 -lt 12 -or $mod100 -gt 14)) { return 'few' }
    return 'many'
}""",
    "sl": """function plural_$CODE([int]$n) {
    $mod100 = $n % 100
    if ($mod100 -eq 1) { return 'one' }
    if ($mod100 -eq 2) { return 'two' }
    if ($mod100 -eq 3 -or $mod100 -eq 4) { return 'few' }
    return 'other'
}""",
    "ar": """function plural_$CODE([int]$n) {
    if ($n -eq 0) { return 'zero' }
    if ($n -eq 1) { return 'one' }
    if ($n -eq 2) { return 'two' }
    $mod100 = $n % 100
    if ($mod100 -ge 3 -and $mod100 -le 10) { return 'few' }
    if ($mod100 -ge 11 -and $mod100 -le 99) { return 'many' }
    return 'other'
}""",
    "lv": """function plural_$CODE([int]$n) {
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -eq 0 -or ($mod100 -ge 11 -and $mod100 -le 19)) { return 'zero' }
    if ($mod10 -eq 1 -and $mod100 -ne 11) { return 'one' }
    return 'other'
}""",
    "he": """function plural_$CODE([int]$n) {
    if ($n -eq 1) { return 'one' }
    if ($n -eq 2) { return 'two' }
    return 'other'
}""",
    "mk": """function plural_$CODE([int]$n) {
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -eq 1 -and $mod100 -ne 11) { return 'one' }
    return 'other'
}""",
    "cy": """function plural_$CODE([int]$n) {
    if ($n -eq 0) { return 'zero' }
    if ($n -eq 1) { return 'one' }
    if ($n -eq 2) { return 'two' }
    if ($n -eq 3) { return 'few' }
    if ($n -eq 6) { return 'many' }
    return 'other'
}""",
    "gv": """function plural_$CODE([int]$n) {
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -eq 1) { return 'one' }
    if ($mod10 -eq 2) { return 'two' }
    if ($mod100 -in @(0, 20, 40, 60, 80)) { return 'few' }
    return 'other'
}""",
    "gd": """function plural_$CODE([int]$n) {
    if ($n -in @(1, 11)) { return 'one' }
    if ($n -in @(2, 12)) { return 'two' }
    if (($n -ge 3 -and $n -le 10) -or ($n -ge 13 -and $n -le 19)) { return 'few' }
    return 'other'
}""",
    "ga": """function plural_$CODE([int]$n) {
    if ($n -eq 1) { return 'one' }
    if ($n -eq 2) { return 'two' }
    if ($n -ge 3 -and $n -le 6) { return 'few' }
    if ($n -ge 7 -and $n -le 10) { return 'many' }
    return 'other'
}""",
    "mt": """function plural_$CODE([int]$n) {
    if ($n -eq 1) { return 'one' }
    if ($n -eq 2) { return 'two' }
    $mod100 = $n % 100
    if ($n -eq 0 -or ($mod100 -ge 3 -and $mod100 -le 10)) { return 'few' }
    if ($mod100 -ge 11 -and $mod100 -le 19) { return 'many' }
    return 'other'
}""",
    "br": """function plural_$CODE([int]$n) {
    $mod10 = $n % 10
    $mod100 = $n % 100
    if ($mod10 -eq 1 -and $mod100 -ne 11 -and $mod100 -ne 71 -and $mod100 -ne 91) { return 'one' }
    if ($mod10 -eq 2 -and $mod100 -ne 12 -and $mod100 -ne 72 -and $mod100 -ne 92) { return 'two' }
    if ($mod10 -in @(3, 4, 9) -and -not ($mod100 -ge 10 -and $mod100 -le 19) -and -not ($mod100 -ge 70 -and $mod100 -le 79) -and -not ($mod100 -ge 90 -and $mod100 -le 99)) { return 'few' }
    if ($n -ne 0 -and $n % 1000000 -eq 0) { return 'many' }
    return 'other'
}""",
    "kw": """function plural_$CODE([int]$n) {
    if ($n -eq 0) { return 'zero' }
    if ($n -eq 1) { return 'one' }
    $mod100 = $n % 100
    if ($mod100 -in @(2, 22, 42, 62, 82)) { return 'two' }
    if ($mod100 -in @(3, 23, 43, 63, 83)) { return 'few' }
    if ($n -ne 1 -and $mod100 -in @(1, 21, 41, 61, 81)) { return 'many' }
    return 'other'
}""",
    "shi": """function plural_$CODE([int]$n) {
    if ($n -eq 0 -or $n -eq 1) { return 'one' }
    if ($n -ge 2 -and $n -le 10) { return 'few' }
    return 'other'
}""",
    "tzm": """function plural_$CODE([int]$n) {
    if ($n -eq 0 -or $n -eq 1 -or ($n -ge 11 -and $n -le 99)) { return 'one' }
    return 'other'
}""",
}


def get_ps_plural(rule: str) -> str:
    return _PS[rule]

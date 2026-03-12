"""Bash plural rule definitions for all 23 patterns."""

from __future__ import annotations

_BASH = {
    "other_only": """_plural_$CODE() {
    echo "other"
}""",
    "one_other": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    echo "other"
}""",
    "one_other_zero_one": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 0 ] || [ "${n}" -eq 1 ]; then echo "one"; return; fi
    echo "other"
}""",
    "cs_sk": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    if [ "${n}" -ge 2 ] && [ "${n}" -le 4 ]; then echo "few"; return; fi
    echo "other"
}""",
    "lt": """_plural_$CODE() {
    local n=$1
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -eq 1 ] && [ "${mod100}" -ne 11 ]; then echo "one"; return; fi
    if [ "${mod10}" -ge 2 ] && [ "${mod10}" -le 9 ] && { [ "${mod100}" -lt 12 ] || [ "${mod100}" -gt 19 ]; }; then echo "few"; return; fi
    echo "other"
}""",
    "ro": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    local mod100=$(( n % 100 ))
    if [ "${n}" -eq 0 ] || { [ "${mod100}" -ge 1 ] && [ "${mod100}" -le 19 ]; }; then echo "few"; return; fi
    echo "other"
}""",
    "slavic_bcs": """_plural_$CODE() {
    local n=$1
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -eq 1 ] && [ "${mod100}" -ne 11 ]; then echo "one"; return; fi
    if [ "${mod10}" -ge 2 ] && [ "${mod10}" -le 4 ] && { [ "${mod100}" -lt 12 ] || [ "${mod100}" -gt 14 ]; }; then echo "few"; return; fi
    echo "other"
}""",
    "pl": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -ge 2 ] && [ "${mod10}" -le 4 ] && { [ "${mod100}" -lt 12 ] || [ "${mod100}" -gt 14 ]; }; then echo "few"; return; fi
    echo "many"
}""",
    "ru_uk": """_plural_$CODE() {
    local n=$1
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -eq 1 ] && [ "${mod100}" -ne 11 ]; then echo "one"; return; fi
    if [ "${mod10}" -ge 2 ] && [ "${mod10}" -le 4 ] && { [ "${mod100}" -lt 12 ] || [ "${mod100}" -gt 14 ]; }; then echo "few"; return; fi
    echo "many"
}""",
    "sl": """_plural_$CODE() {
    local n=$1
    local mod100=$(( n % 100 ))
    if [ "${mod100}" -eq 1 ]; then echo "one"; return; fi
    if [ "${mod100}" -eq 2 ]; then echo "two"; return; fi
    if [ "${mod100}" -eq 3 ] || [ "${mod100}" -eq 4 ]; then echo "few"; return; fi
    echo "other"
}""",
    "ar": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 0 ]; then echo "zero"; return; fi
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    if [ "${n}" -eq 2 ]; then echo "two"; return; fi
    local mod100=$(( n % 100 ))
    if [ "${mod100}" -ge 3 ] && [ "${mod100}" -le 10 ]; then echo "few"; return; fi
    if [ "${mod100}" -ge 11 ] && [ "${mod100}" -le 99 ]; then echo "many"; return; fi
    echo "other"
}""",
    "lv": """_plural_$CODE() {
    local n=$1
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -eq 0 ] || { [ "${mod100}" -ge 11 ] && [ "${mod100}" -le 19 ]; }; then echo "zero"; return; fi
    if [ "${mod10}" -eq 1 ] && [ "${mod100}" -ne 11 ]; then echo "one"; return; fi
    echo "other"
}""",
    "he": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    if [ "${n}" -eq 2 ]; then echo "two"; return; fi
    echo "other"
}""",
    "mk": """_plural_$CODE() {
    local n=$1
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -eq 1 ] && [ "${mod100}" -ne 11 ]; then echo "one"; return; fi
    echo "other"
}""",
    "cy": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 0 ]; then echo "zero"; return; fi
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    if [ "${n}" -eq 2 ]; then echo "two"; return; fi
    if [ "${n}" -eq 3 ]; then echo "few"; return; fi
    if [ "${n}" -eq 6 ]; then echo "many"; return; fi
    echo "other"
}""",
    "gv": """_plural_$CODE() {
    local n=$1
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -eq 1 ]; then echo "one"; return; fi
    if [ "${mod10}" -eq 2 ]; then echo "two"; return; fi
    if [ "${mod100}" -eq 0 ] || [ "${mod100}" -eq 20 ] || [ "${mod100}" -eq 40 ] || [ "${mod100}" -eq 60 ] || [ "${mod100}" -eq 80 ]; then echo "few"; return; fi
    echo "other"
}""",
    "gd": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ] || [ "${n}" -eq 11 ]; then echo "one"; return; fi
    if [ "${n}" -eq 2 ] || [ "${n}" -eq 12 ]; then echo "two"; return; fi
    if { [ "${n}" -ge 3 ] && [ "${n}" -le 10 ]; } || { [ "${n}" -ge 13 ] && [ "${n}" -le 19 ]; }; then echo "few"; return; fi
    echo "other"
}""",
    "ga": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    if [ "${n}" -eq 2 ]; then echo "two"; return; fi
    if [ "${n}" -ge 3 ] && [ "${n}" -le 6 ]; then echo "few"; return; fi
    if [ "${n}" -ge 7 ] && [ "${n}" -le 10 ]; then echo "many"; return; fi
    echo "other"
}""",
    "mt": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    if [ "${n}" -eq 2 ]; then echo "two"; return; fi
    local mod100=$(( n % 100 ))
    if [ "${n}" -eq 0 ] || { [ "${mod100}" -ge 3 ] && [ "${mod100}" -le 10 ]; }; then echo "few"; return; fi
    if [ "${mod100}" -ge 11 ] && [ "${mod100}" -le 19 ]; then echo "many"; return; fi
    echo "other"
}""",
    "br": """_plural_$CODE() {
    local n=$1
    local mod10=$(( n % 10 ))
    local mod100=$(( n % 100 ))
    if [ "${mod10}" -eq 1 ] && [ "${mod100}" -ne 11 ] && [ "${mod100}" -ne 71 ] && [ "${mod100}" -ne 91 ]; then echo "one"; return; fi
    if [ "${mod10}" -eq 2 ] && [ "${mod100}" -ne 12 ] && [ "${mod100}" -ne 72 ] && [ "${mod100}" -ne 92 ]; then echo "two"; return; fi
    if { [ "${mod10}" -eq 3 ] || [ "${mod10}" -eq 4 ] || [ "${mod10}" -eq 9 ]; } && ! { [ "${mod100}" -ge 10 ] && [ "${mod100}" -le 19 ]; } && ! { [ "${mod100}" -ge 70 ] && [ "${mod100}" -le 79 ]; } && ! { [ "${mod100}" -ge 90 ] && [ "${mod100}" -le 99 ]; }; then echo "few"; return; fi
    if [ "${n}" -ne 0 ] && [ $(( n % 1000000 )) -eq 0 ]; then echo "many"; return; fi
    echo "other"
}""",
    "kw": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 0 ]; then echo "zero"; return; fi
    if [ "${n}" -eq 1 ]; then echo "one"; return; fi
    local mod100=$(( n % 100 ))
    if [ "${mod100}" -eq 2 ] || [ "${mod100}" -eq 22 ] || [ "${mod100}" -eq 42 ] || [ "${mod100}" -eq 62 ] || [ "${mod100}" -eq 82 ]; then echo "two"; return; fi
    if [ "${mod100}" -eq 3 ] || [ "${mod100}" -eq 23 ] || [ "${mod100}" -eq 43 ] || [ "${mod100}" -eq 63 ] || [ "${mod100}" -eq 83 ]; then echo "few"; return; fi
    if [ "${n}" -ne 1 ] && { [ "${mod100}" -eq 1 ] || [ "${mod100}" -eq 21 ] || [ "${mod100}" -eq 41 ] || [ "${mod100}" -eq 61 ] || [ "${mod100}" -eq 81 ]; }; then echo "many"; return; fi
    echo "other"
}""",
    "shi": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 0 ] || [ "${n}" -eq 1 ]; then echo "one"; return; fi
    if [ "${n}" -ge 2 ] && [ "${n}" -le 10 ]; then echo "few"; return; fi
    echo "other"
}""",
    "tzm": """_plural_$CODE() {
    local n=$1
    if [ "${n}" -eq 0 ] || [ "${n}" -eq 1 ] || { [ "${n}" -ge 11 ] && [ "${n}" -le 99 ]; }; then echo "one"; return; fi
    echo "other"
}""",
}


def get_bash_plural(rule: str) -> str:
    """Get Bash plural function body for a given rule."""
    return _BASH[rule]

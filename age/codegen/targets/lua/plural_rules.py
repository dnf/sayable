"""Lua plural rule definitions for all 23 patterns."""

from __future__ import annotations

_LUA = {
    "other_only": 'function(_n) return "other" end',
    "one_other": 'function(n) return n == 1 and "one" or "other" end',
    "one_other_zero_one": 'function(n) return (n == 0 or n == 1) and "one" or "other" end',
}

_LUA_NAMED = {
    "cs_sk": '''\
local function plural(n)
    if n == 1 then return "one" end
    if n >= 2 and n <= 4 then return "few" end
    return "other"
end''',
    "lt": '''\
local function plural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 and mod100 ~= 11 then return "one" end
    if mod10 >= 2 and mod10 <= 9 and (mod100 < 12 or mod100 > 19) then return "few" end
    return "other"
end''',
    "ro": '''\
local function plural(n)
    if n == 1 then return "one" end
    if n == 0 or (n % 100 >= 1 and n % 100 <= 19) then return "few" end
    return "other"
end''',
    "slavic_bcs": '''\
local function plural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 and mod100 ~= 11 then return "one" end
    if mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then return "few" end
    return "other"
end''',
    "pl": '''\
local function plural(n)
    if n == 1 then return "one" end
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then return "few" end
    return "many"
end''',
    "ru_uk": '''\
local function plural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 and mod100 ~= 11 then return "one" end
    if mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14) then return "few" end
    return "many"
end''',
    "sl": '''\
local function plural(n)
    local mod100 = n % 100
    if mod100 == 1 then return "one" end
    if mod100 == 2 then return "two" end
    if mod100 == 3 or mod100 == 4 then return "few" end
    return "other"
end''',
    "ar": '''\
local function plural(n)
    if n == 0 then return "zero" end
    if n == 1 then return "one" end
    if n == 2 then return "two" end
    local mod100 = n % 100
    if mod100 >= 3 and mod100 <= 10 then return "few" end
    if mod100 >= 11 and mod100 <= 99 then return "many" end
    return "other"
end''',
    "lv": '''\
local function plural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 0 or (mod100 >= 11 and mod100 <= 19) then return "zero" end
    if mod10 == 1 and mod100 ~= 11 then return "one" end
    return "other"
end''',
    "he": '''\
local function plural(n)
    if n == 1 then return "one" end
    if n == 2 then return "two" end
    return "other"
end''',
    "mk": '''\
local function plural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 and mod100 ~= 11 then return "one" end
    return "other"
end''',
    "cy": '''\
local function plural(n)
    if n == 0 then return "zero" end
    if n == 1 then return "one" end
    if n == 2 then return "two" end
    if n == 3 then return "few" end
    if n == 6 then return "many" end
    return "other"
end''',
    "gv": '''\
local function plural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 then return "one" end
    if mod10 == 2 then return "two" end
    if mod100 == 0 or mod100 == 20 or mod100 == 40 or mod100 == 60 or mod100 == 80 then return "few" end
    return "other"
end''',
    "gd": '''\
local function plural(n)
    if n == 1 or n == 11 then return "one" end
    if n == 2 or n == 12 then return "two" end
    if (n >= 3 and n <= 10) or (n >= 13 and n <= 19) then return "few" end
    return "other"
end''',
    "ga": '''\
local function plural(n)
    if n == 1 then return "one" end
    if n == 2 then return "two" end
    if n >= 3 and n <= 6 then return "few" end
    if n >= 7 and n <= 10 then return "many" end
    return "other"
end''',
    "mt": '''\
local function plural(n)
    if n == 1 then return "one" end
    if n == 2 then return "two" end
    local mod100 = n % 100
    if n == 0 or (mod100 >= 3 and mod100 <= 10) then return "few" end
    if mod100 >= 11 and mod100 <= 19 then return "many" end
    return "other"
end''',
    "br": '''\
local function plural(n)
    local mod10 = n % 10
    local mod100 = n % 100
    if mod10 == 1 and mod100 ~= 11 and mod100 ~= 71 and mod100 ~= 91 then return "one" end
    if mod10 == 2 and mod100 ~= 12 and mod100 ~= 72 and mod100 ~= 92 then return "two" end
    if (mod10 == 3 or mod10 == 4 or mod10 == 9) and not (mod100 >= 10 and mod100 <= 19) and not (mod100 >= 70 and mod100 <= 79) and not (mod100 >= 90 and mod100 <= 99) then return "few" end
    if n ~= 0 and n % 1000000 == 0 then return "many" end
    return "other"
end''',
    "kw": '''\
local function plural(n)
    if n == 0 then return "zero" end
    if n == 1 then return "one" end
    local mod100 = n % 100
    if mod100 == 2 or mod100 == 22 or mod100 == 42 or mod100 == 62 or mod100 == 82 then return "two" end
    if mod100 == 3 or mod100 == 23 or mod100 == 43 or mod100 == 63 or mod100 == 83 then return "few" end
    if n ~= 1 and (mod100 == 1 or mod100 == 21 or mod100 == 41 or mod100 == 61 or mod100 == 81) then return "many" end
    return "other"
end''',
    "shi": '''\
local function plural(n)
    if n == 0 or n == 1 then return "one" end
    if n >= 2 and n <= 10 then return "few" end
    return "other"
end''',
    "tzm": '''\
local function plural(n)
    if n == 0 or n == 1 or (n >= 11 and n <= 99) then return "one" end
    return "other"
end''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline function."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_lua_plural(rule: str) -> str:
    """Get Lua plural expression (inline function or function reference)."""
    if rule in _LUA:
        return _LUA[rule]
    return "plural"


def get_lua_named_function(rule: str) -> str | None:
    """Get Lua named function for complex rules."""
    return _LUA_NAMED.get(rule)

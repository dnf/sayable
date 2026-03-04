-- luacheck configuration for sayable-age Lua implementation

std = "lua54"

-- Exclude test files (busted globals) and generated locale files
files["test_sayableage.lua"] = {
    std = "+busted",
}

-- Generated locale files have long lines — expected for locale data
files["locales/*.lua"] = {
    max_line_length = false,
}

-- Allow unused self in methods
self = false

-- Max line length for hand-written code
max_line_length = 120

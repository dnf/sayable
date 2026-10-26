# Tests for sayabletime — mirrors the canonical test specification.
# All test IDs reference config/tests.json.

# Load English locale
en_path <- file.path(.pkg_root, "locales", "en.R")
en_env <- new.env(parent = baseenv())
source(en_path, local = en_env)
en <- en_env$locale_en
st <- sayable_time_new(en)

# Helper to load locale by code
load_locale <- function(code) {
  locale_path <- file.path(.pkg_root, "locales", paste0(code, ".R"))
  env <- new.env(parent = baseenv())
  source(locale_path, local = env)
  var_name <- paste0("locale_", gsub("-", "_", code))
  env[[var_name]]
}

# ================================================================
# 1. Null / edge cases
# ================================================================
test_that("1.1 - returns NULL for NULL", {
  expect_null(st$format_time(NULL))
})

test_that("1.2 - returns NULL for empty string", {
  expect_null(st$format_time(""))
})

test_that("1.3 - returns NULL for invalid", {
  expect_null(st$format_time("invalid"))
})

test_that("1.4 - returns NULL for hour out of range", {
  expect_null(st$format_time("25:00"))
})

# ================================================================
# 2. Clock time (normal compactness)
# ================================================================
test_that("2.1 - midnight", {
  expect_equal(st$format_time("00:00"), "midnight")
})

test_that("2.2 - noon", {
  expect_equal(st$format_time("12:00"), "noon")
})

test_that("2.3 - three o'clock", {
  expect_equal(st$format_time("15:00"), "three o'clock")
})

test_that("2.4 - a quarter past two", {
  expect_equal(st$format_time("14:15"), "a quarter past two")
})

test_that("2.5 - half past nine", {
  expect_equal(st$format_time("09:30"), "half past nine")
})

test_that("2.6 - a quarter to eleven", {
  expect_equal(st$format_time("10:45"), "a quarter to eleven")
})

test_that("2.7 - five past eight", {
  expect_equal(st$format_time("08:05"), "five past eight")
})

test_that("2.8 - five to five", {
  expect_equal(st$format_time("16:55"), "five to five")
})

test_that("2.9 - 23:58 rounds to midnight", {
  expect_equal(st$format_time("23:58"), "midnight")
})

test_that("2.10 - 07:22 rounds to twenty past seven", {
  expect_equal(st$format_time("07:22"), "twenty past seven")
})

test_that("2.11 - ISO datetime input", {
  expect_equal(st$format_time("2025-01-15T14:15:00"), "a quarter past two")
})

# ================================================================
# 3. Clock time (short compactness)
# ================================================================
test_that("3.1-3.4 - short compactness", {
  st_short <- sayable_time_new(en, "short")

  # 3.1
  expect_equal(st_short$format_time("14:15"), "2:15 PM")
  # 3.2
  expect_equal(st_short$format_time("09:30"), "9:30 AM")
  # 3.3
  expect_equal(st_short$format_time("00:00"), "12:00 AM")
  # 3.4
  expect_equal(st_short$format_time("12:00"), "12:00 PM")
})

# ================================================================
# 4. Clock time (compact)
# ================================================================
test_that("4.1-4.2 - compact compactness", {
  st_compact <- sayable_time_new(en, "compact")

  # 4.1
  expect_equal(st_compact$format_time("14:15"), "2:15p")
  # 4.2
  expect_equal(st_compact$format_time("09:30"), "9:30a")
})

# ================================================================
# 5. Locale — German
# ================================================================
test_that("5.1 - German locale", {
  de <- load_locale("de")
  st_de <- sayable_time_new(de)

  expect_equal(st_de$format_time("15:30"), "halb vier")
})

# ================================================================
# 6. Locale — French
# ================================================================
test_that("6.1 - French locale", {
  fr <- load_locale("fr")
  st_fr <- sayable_time_new(fr)

  expect_equal(st_fr$format_time("15:15"), "trois heures et quart")
})

# ================================================================
# 7. Locale — Japanese
# ================================================================
test_that("7.1 - Japanese locale", {
  ja <- load_locale("ja")
  st_ja <- sayable_time_new(ja)

  expect_equal(st_ja$format_time("15:30"), "\u4e09\u6642\u534a")
})

# ================================================================
# 8. Locale — Finnish (dot separator, short)
# ================================================================
test_that("8.1-8.2 - Finnish dot separator", {
  fi <- load_locale("fi")
  st_fi <- sayable_time_new(fi, "short")

  # 8.1
  expect_equal(st_fi$format_time("14:15"), "14.15")
  # 8.2
  expect_equal(st_fi$format_time("00:00"), "0.00")
})

# ================================================================
# Sections 9-10: minutes in short/compact, input validation
# ================================================================

test_that("9.1 - digital modes keep the exact minute", {
  expect_equal(sayable_time_new(en, "short")$format_time("18:01"), "6:01 PM")
})

test_that("9.2 - digital modes keep the exact minute", {
  expect_equal(sayable_time_new(en, "compact")$format_time("19:05"), "7:05p")
})

test_that("10.1 - one-digit hour", {
  expect_equal(sayable_time_new(en)$format_time("9:30"), "half past nine")
})

test_that("10.2 - two-digit hour", {
  expect_equal(sayable_time_new(en)$format_time("09:30"), "half past nine")
})

test_that("10.3 - leading whitespace", {
  expect_null(sayable_time_new(en)$format_time(" 9:30"))
})

test_that("10.4 - trailing whitespace", {
  expect_null(sayable_time_new(en)$format_time("9:30 "))
})

test_that("10.5 - minutes need two digits", {
  expect_null(sayable_time_new(en)$format_time("9:5"))
})

test_that("10.6 - hour out of range", {
  expect_null(sayable_time_new(en)$format_time("24:00"))
})

test_that("10.7 - seconds are allowed and ignored", {
  expect_equal(sayable_time_new(en)$format_time("14:15:30"), "a quarter past two")
})

test_that("10.8 - ISO datetime with zone suffix (ignored)", {
  expect_equal(sayable_time_new(en)$format_time("2025-01-15T14:15:00Z"), "a quarter past two")
})

test_that("10.9 - ISO datetime with an impossible date", {
  expect_null(sayable_time_new(en)$format_time("2025-02-30T14:15:00"))
})

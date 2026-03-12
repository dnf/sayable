# Tests for sayabledate — mirrors the canonical test specification.
# All test IDs reference config/tests.json.

# Load English locale
en_path <- file.path(.pkg_root, "locales", "en.R")
en_env <- new.env(parent = baseenv())
source(en_path, local = en_env)
en <- en_env$locale_en
sd <- sayable_date_new(en)

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
test_that("1.1 - format_date returns NULL for NULL", {
  expect_null(sd$format_date(NULL))
})

test_that("1.2 - format_date returns NULL for empty string", {
  expect_null(sd$format_date(""))
})

test_that("1.3 - format_date returns NULL for invalid", {
  expect_null(sd$format_date("invalid"))
})

test_that("1.4 - format_relative returns NULL when asOf is NULL", {
  expect_null(sd$format_relative("2025-03-15", NULL))
})

test_that("1.5 - format_relative returns NULL when date is NULL", {
  expect_null(sd$format_relative(NULL, "2025-03-15"))
})

# ================================================================
# 2. format_date — normal compactness (English)
# ================================================================
test_that("2.1 - March 15th", {
  expect_equal(sd$format_date("2025-03-15"), "March 15th")
})

test_that("2.2 - January 1st", {
  expect_equal(sd$format_date("2025-01-01"), "January 1st")
})

test_that("2.3 - May 22nd", {
  expect_equal(sd$format_date("2025-05-22"), "May 22nd")
})

test_that("2.4 - July 3rd", {
  expect_equal(sd$format_date("2025-07-03"), "July 3rd")
})

test_that("2.5 - December 31st", {
  expect_equal(sd$format_date("2025-12-31"), "December 31st")
})

test_that("2.6 - June 11th (no exception for 11)", {
  expect_equal(sd$format_date("2025-06-11"), "June 11th")
})

test_that("2.7 - ISO datetime input", {
  expect_equal(sd$format_date("2025-03-15T14:30:00"), "March 15th")
})

# ================================================================
# 3. format_date — short compactness (English)
# ================================================================
test_that("3.1-3.3 - short compactness", {
  sd_short <- sayable_date_new(en, "short")

  # 3.1
  expect_equal(sd_short$format_date("2025-03-15"), "Mar 15")
  # 3.2
  expect_equal(sd_short$format_date("2025-01-01"), "Jan 1")
  # 3.3
  expect_equal(sd_short$format_date("2025-12-25"), "Dec 25")
})

# ================================================================
# 4. format_date — compact (English)
# ================================================================
test_that("4.1-4.2 - compact compactness", {
  sd_compact <- sayable_date_new(en, "compact")

  # 4.1
  expect_equal(sd_compact$format_date("2025-03-15"), "3/15")
  # 4.2
  expect_equal(sd_compact$format_date("2025-01-01"), "1/1")
})

# ================================================================
# 5. format_relative — proximity tiers (English)
# ================================================================
test_that("5.1 - today", {
  expect_equal(sd$format_relative("2025-03-15", "2025-03-15"), "today")
})

test_that("5.2 - tomorrow", {
  expect_equal(sd$format_relative("2025-03-16", "2025-03-15"), "tomorrow")
})

test_that("5.3 - yesterday", {
  expect_equal(sd$format_relative("2025-03-14", "2025-03-15"), "yesterday")
})

test_that("5.4 - day after tomorrow", {
  expect_equal(sd$format_relative("2025-03-17", "2025-03-15"), "the day after tomorrow")
})

test_that("5.5 - day before yesterday", {
  expect_equal(sd$format_relative("2025-03-13", "2025-03-15"), "the day before yesterday")
})

test_that("5.6 - this Wednesday (+4 days)", {
  expect_equal(sd$format_relative("2025-03-19", "2025-03-15"), "this Wednesday")
})

test_that("5.7 - this Thursday (+5 days)", {
  expect_equal(sd$format_relative("2025-03-20", "2025-03-15"), "this Thursday")
})

test_that("5.8 - last Tuesday (-4 days)", {
  expect_equal(sd$format_relative("2025-03-11", "2025-03-15"), "last Tuesday")
})

test_that("5.9 - next Saturday (+7 days)", {
  expect_equal(sd$format_relative("2025-03-22", "2025-03-15"), "next Saturday")
})

test_that("5.10 - next Thursday (+12 days)", {
  expect_equal(sd$format_relative("2025-03-27", "2025-03-15"), "next Thursday")
})

test_that("5.11 - calendar fallback same year (-14 days)", {
  expect_equal(sd$format_relative("2025-03-01", "2025-03-15"), "March 1st")
})

test_that("5.12 - calendar fallback same year (+26 days)", {
  expect_equal(sd$format_relative("2025-04-10", "2025-03-15"), "April 10th")
})

test_that("5.13 - different year includes year", {
  expect_equal(sd$format_relative("2026-01-05", "2025-03-15"), "January 5th, 2026")
})

test_that("5.14 - past year includes year", {
  expect_equal(sd$format_relative("2024-12-25", "2025-03-15"), "December 25th, 2024")
})

# ================================================================
# 6. format_relative — compact skips weekday tiers
# ================================================================
test_that("6.1-6.4 - compact skips weekday references", {
  sd_compact <- sayable_date_new(en, "compact")

  # 6.1
  expect_equal(sd_compact$format_relative("2025-03-15", "2025-03-15"), "today")
  # 6.2
  expect_equal(sd_compact$format_relative("2025-03-16", "2025-03-15"), "tomorrow")
  # 6.3
  expect_equal(sd_compact$format_relative("2025-03-19", "2025-03-15"), "3/19")
  # 6.4
  expect_equal(sd_compact$format_relative("2026-01-05", "2025-03-15"), "1/5/26")
})

# ================================================================
# 7. Locale — German
# ================================================================
test_that("7.1-7.4 - German locale", {
  de <- load_locale("de")
  sd_de <- sayable_date_new(de)

  # 7.1
  expect_equal(sd_de$format_date("2025-03-15"), "15. M\u00e4rz")
  # 7.2
  expect_equal(sd_de$format_relative("2025-03-16", "2025-03-15"), "morgen")
  # 7.3
  expect_equal(sd_de$format_relative("2025-03-17", "2025-03-15"), "\u00fcbermorgen")
  # 7.4
  expect_equal(sd_de$format_relative("2025-03-19", "2025-03-15"), "diesen Mittwoch")
})

# ================================================================
# 8. Locale — French
# ================================================================
test_that("8.1-8.3 - French locale", {
  fr <- load_locale("fr")
  sd_fr <- sayable_date_new(fr)

  # 8.1
  expect_equal(sd_fr$format_date("2025-03-01"), "1er mars")
  # 8.2
  expect_equal(sd_fr$format_date("2025-03-15"), "15 mars")
  # 8.3
  expect_equal(sd_fr$format_relative("2025-03-16", "2025-03-15"), "demain")
})

# ================================================================
# 9. Locale — Japanese
# ================================================================
test_that("9.1-9.3 - Japanese locale", {
  ja <- load_locale("ja")
  sd_ja <- sayable_date_new(ja)

  # 9.1
  expect_equal(sd_ja$format_date("2025-03-15"), "3\u670815\u65e5")
  # 9.2
  expect_equal(sd_ja$format_relative("2025-03-16", "2025-03-15"), "\u660e\u65e5")
  # 9.3
  expect_equal(sd_ja$format_relative("2025-03-19", "2025-03-15"), "\u4eca\u5ea6\u306e\u6c34\u66dc\u65e5")
})

# ================================================================
# 10. Locale — Russian (genitive months)
# ================================================================
test_that("10.1-10.2 - Russian locale", {
  ru <- load_locale("ru")
  sd_ru <- sayable_date_new(ru)

  # 10.1
  expect_equal(sd_ru$format_date("2025-03-15"), "15 \u043c\u0430\u0440\u0442\u0430")
  # 10.2
  expect_equal(sd_ru$format_relative("2025-03-16", "2025-03-15"), "\u0437\u0430\u0432\u0442\u0440\u0430")
})

# ================================================================
# 11. Locale — Arabic
# ================================================================
test_that("11.1-11.2 - Arabic locale", {
  ar <- load_locale("ar")
  sd_ar <- sayable_date_new(ar)

  # 11.1
  expect_equal(sd_ar$format_date("2025-03-15"), "15 \u0645\u0627\u0631\u0633")
  # 11.2
  expect_equal(sd_ar$format_relative("2025-03-16", "2025-03-15"), "\u063a\u062f\u0627\u064b")
})

# ================================================================
# 12. Locale — Spanish
# ================================================================
test_that("12.1-12.2 - Spanish locale", {
  es <- load_locale("es")
  sd_es <- sayable_date_new(es)

  # 12.1
  expect_equal(sd_es$format_date("2025-03-15"), "15 de marzo")
  # 12.2
  expect_equal(sd_es$format_relative("2025-03-17", "2025-03-15"), "pasado ma\u00f1ana")
})

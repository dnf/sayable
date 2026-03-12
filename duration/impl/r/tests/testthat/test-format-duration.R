# Tests for sayableduration — mirrors the canonical test specification.
# All test IDs reference config/tests.json.

# Load English locale
en_path <- file.path(.pkg_root, "locales", "en.R")
en_env <- new.env(parent = baseenv())
source(en_path, local = en_env)
en <- en_env$locale_en
sd <- sayable_duration_new(en)

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
test_that("1.1 - format_duration returns NULL for NULL", {
  expect_null(sd$format_duration(NULL))
})

test_that("1.2 - format_duration returns NULL for negative", {
  expect_null(sd$format_duration(-1))
})

test_that("1.3 - format_since returns NULL when start is NULL", {
  expect_null(sd$format_since(NULL, "2025-01-15T10:00:00"))
})

test_that("1.4 - format_until returns NULL when target is NULL", {
  expect_null(sd$format_until(NULL, "2025-01-15T10:00:00"))
})

test_that("1.5 - format_since returns NULL when asOf before start", {
  expect_null(sd$format_since("2025-01-15T10:00:00", "2025-01-15T09:00:00"))
})

test_that("1.6 - format_until returns NULL when target in the past", {
  expect_null(sd$format_until("2025-01-15T09:00:00", "2025-01-15T10:00:00"))
})

# ================================================================
# 2. Duration — seconds tier (0-59s)
# ================================================================
test_that("2.1 - 0 seconds is just now", {
  expect_equal(sd$format_duration(0), "just now")
})

test_that("2.2 - 1 second", {
  expect_equal(sd$format_duration(1), "1 second")
})

test_that("2.3 - 45 seconds", {
  expect_equal(sd$format_duration(45), "45 seconds")
})

test_that("2.4 - 59 seconds", {
  expect_equal(sd$format_duration(59), "59 seconds")
})

# ================================================================
# 3. Duration — minutes + seconds tier (1-4 min)
# ================================================================
test_that("3.1 - 60 seconds is 1 minute", {
  expect_equal(sd$format_duration(60), "1 minute")
})

test_that("3.2 - 90 seconds", {
  expect_equal(sd$format_duration(90), "1 minute, 30 seconds")
})

test_that("3.3 - 240 seconds", {
  expect_equal(sd$format_duration(240), "4 minutes")
})

test_that("3.4 - 270 seconds", {
  expect_equal(sd$format_duration(270), "4 minutes, 30 seconds")
})

# ================================================================
# 4. Duration — minutes tier (5-59 min)
# ================================================================
test_that("4.1 - 300 seconds is 5 minutes", {
  expect_equal(sd$format_duration(300), "5 minutes")
})

test_that("4.2 - 1500 seconds is 25 minutes", {
  expect_equal(sd$format_duration(1500), "25 minutes")
})

test_that("4.3 - 3540 seconds is 59 minutes", {
  expect_equal(sd$format_duration(3540), "59 minutes")
})

# ================================================================
# 5. Duration — hours + minutes tier (1-5 hr)
# ================================================================
test_that("5.1 - 3600 seconds is 1 hour", {
  expect_equal(sd$format_duration(3600), "1 hour")
})

test_that("5.2 - 5400 seconds is 1.5 hours (half marker)", {
  expect_equal(sd$format_duration(5400), "1\u00bd hours")
})

test_that("5.3 - 8100 seconds is 2 hours 15 minutes", {
  expect_equal(sd$format_duration(8100), "2 hours, 15 minutes")
})

test_that("5.4 - 18000 seconds is 5 hours", {
  expect_equal(sd$format_duration(18000), "5 hours")
})

# ================================================================
# 6. Duration — hours tier (6-23 hr)
# ================================================================
test_that("6.1 - 28800 seconds is 8 hours", {
  expect_equal(sd$format_duration(28800), "8 hours")
})

test_that("6.2 - 82800 seconds is 23 hours", {
  expect_equal(sd$format_duration(82800), "23 hours")
})

# ================================================================
# 7. Duration — days tier
# ================================================================
test_that("7.1 - 86400 seconds is 1 day", {
  expect_equal(sd$format_duration(86400), "1 day")
})

test_that("7.2 - 97200 seconds is 1 day 3 hours", {
  expect_equal(sd$format_duration(97200), "1 day, 3 hours")
})

test_that("7.3 - 129600 seconds is 1.5 days (half marker)", {
  expect_equal(sd$format_duration(129600), "1\u00bd days")
})

test_that("7.4 - 432000 seconds is 5 days", {
  expect_equal(sd$format_duration(432000), "5 days")
})

test_that("7.5 - 172800 seconds is 2 days", {
  expect_equal(sd$format_duration(172800), "2 days")
})

# ================================================================
# 8. Duration — weeks tier
# ================================================================
test_that("8.1 - 604800 seconds is 1 week", {
  expect_equal(sd$format_duration(604800), "1 week")
})

test_that("8.2 - 1296000 seconds is 2 weeks 1 day", {
  expect_equal(sd$format_duration(1296000), "2 weeks, 1 day")
})

test_that("8.3 - 2419200 seconds is 4 weeks", {
  expect_equal(sd$format_duration(2419200), "4 weeks")
})

# ================================================================
# 9. Duration — months and years tier
# ================================================================
test_that("9.1 - ~31 days is 1 month", {
  expect_equal(sd$format_duration(2678400), "1 month")
})

test_that("9.2 - ~91 days is 3 months", {
  expect_equal(sd$format_duration(7884000), "3 months")
})

test_that("9.3 - 365 days is 1 year", {
  expect_equal(sd$format_duration(31536000), "1 year")
})

test_that("9.4 - ~456 days is 1 year 3 months", {
  expect_equal(sd$format_duration(39420000), "1 year, 3 months")
})

# ================================================================
# 10. Duration from ISO timestamps
# ================================================================
test_that("10.1 - ISO timestamps 1.5 hours", {
  expect_equal(sd$format_duration_iso("2025-01-15T10:00:00", "2025-01-15T11:30:00"),
               "1\u00bd hours")
})

test_that("10.2 - ISO timestamps 45 minutes", {
  expect_equal(sd$format_duration_iso("2025-01-15T10:00:00", "2025-01-15T10:45:00"),
               "45 minutes")
})

# ================================================================
# 11. Relative time — since
# ================================================================
test_that("11.1 - format_since same time is just now", {
  expect_equal(sd$format_since("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now")
})

test_that("11.2 - 30 seconds ago", {
  expect_equal(sd$format_since("2025-01-15T10:00:00", "2025-01-15T10:00:30"),
               "30 seconds ago")
})

test_that("11.3 - 45 minutes ago", {
  expect_equal(sd$format_since("2025-01-15T10:00:00", "2025-01-15T10:45:00"),
               "45 minutes ago")
})

test_that("11.4 - 3 hours ago", {
  expect_equal(sd$format_since("2025-01-15T10:00:00", "2025-01-15T13:00:00"),
               "3 hours ago")
})

# ================================================================
# 12. Relative time — until
# ================================================================
test_that("12.1 - format_until same time is just now", {
  expect_equal(sd$format_until("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now")
})

test_that("12.2 - in 20 minutes", {
  expect_equal(sd$format_until("2025-01-15T10:20:00", "2025-01-15T10:00:00"),
               "in 20 minutes")
})

test_that("12.3 - in 3 hours", {
  expect_equal(sd$format_until("2025-01-15T13:00:00", "2025-01-15T10:00:00"),
               "in 3 hours")
})

# ================================================================
# 13. Locale — German
# ================================================================
test_that("13.1-13.2 - German locale", {
  de <- load_locale("de")
  sd_de <- sayable_duration_new(de)

  # 13.1
  expect_equal(sd_de$format_duration(3600), "1 Stunde")
  # 13.2
  expect_equal(sd_de$format_since("2025-01-15T10:00:00", "2025-01-15T10:05:00"),
               "vor 5 Minuten")
})

# ================================================================
# 14. Locale — French
# ================================================================
test_that("14.1 - French locale", {
  fr <- load_locale("fr")
  sd_fr <- sayable_duration_new(fr)

  expect_equal(sd_fr$format_duration(7200), "2 heures")
})

# ================================================================
# 15. Locale — Japanese
# ================================================================
test_that("15.1-15.2 - Japanese locale", {
  ja <- load_locale("ja")
  sd_ja <- sayable_duration_new(ja)

  # 15.1
  expect_equal(sd_ja$format_duration(120), "2\u5206")
  # 15.2
  expect_equal(sd_ja$format_since("2025-01-15T10:00:00", "2025-01-15T11:00:00"),
               "1\u6642\u9593\u524d")
})

# ================================================================
# 16. Short compactness — duration
# ================================================================
test_that("16.1-16.2 - short compactness", {
  sd_short <- sayable_duration_new(en, "short")

  # 16.1
  expect_equal(sd_short$format_duration(3600), "1h")
  # 16.2
  expect_equal(sd_short$format_duration(90), "1m, 30s")
})

# ================================================================
# 17. Compact compactness — duration
# ================================================================
test_that("17.1-17.2 - compact compactness", {
  sd_compact <- sayable_duration_new(en, "compact")

  # 17.1
  expect_equal(sd_compact$format_duration(3600), "1h")
  # 17.2
  expect_equal(sd_compact$format_duration(90), "1m30s")
})

# Tests for sayableage — mirrors the canonical test specification.
# All test IDs reference config/tests.json.

# Load English locale for default tests
en_path <- file.path(.pkg_root, "locales", "en.R")
en_env <- new.env(parent = baseenv())
source(en_path, local = en_env)
en <- en_env$locale_en
sa <- sayable_age_new(en)

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
test_that("1.1 - returns NULL for NULL input", {
  expect_null(sa$format_age(NULL, "2025-06-15"))
})

test_that("1.3 - returns NULL for empty string", {
  expect_null(sa$format_age("", "2025-06-15"))
})

test_that("1.4 - returns NULL for future date of birth", {
  expect_null(sa$format_age("2025-07-01", "2025-06-15"))
})

test_that("1.5 - exactly 500 years is allowed", {
  expect_equal(sa$format_age("1525-06-15", "2025-06-15"), "500 years")
})

test_that("1.6 - 501 years exceeds max age", {
  expect_null(sa$format_age("1524-06-15", "2025-06-15"))
})

test_that("1.7 - 1000 years exceeds max age", {
  expect_null(sa$format_age("1025-06-15", "2025-06-15"))
})

# ================================================================
# 2. Days tier (0-6 days)
# ================================================================
test_that("2.1 - born today", {
  expect_equal(sa$format_age("2025-06-15", "2025-06-15"), "Newborn")
})

test_that("2.2 - 1 day ago singular", {
  expect_equal(sa$format_age("2025-06-14", "2025-06-15"), "1 day")
})

test_that("2.3 - 3 days ago", {
  expect_equal(sa$format_age("2025-06-12", "2025-06-15"), "3 days")
})

test_that("2.4 - 6 days ago", {
  expect_equal(sa$format_age("2025-06-09", "2025-06-15"), "6 days")
})

test_that("2.5 - 7 days transitions to weeks", {
  expect_equal(sa$format_age("2025-06-08", "2025-06-15"), "1 week")
})

# ================================================================
# 3. Weeks+days tier (7 days to <3 calendar months)
# ================================================================
test_that("3.1 - exactly 7 days", {
  expect_equal(sa$format_age("2025-06-08", "2025-06-15"), "1 week")
})

test_that("3.2 - 8 days", {
  expect_equal(sa$format_age("2025-06-07", "2025-06-15"), "1 week, 1 day")
})

test_that("3.3 - 9 days", {
  expect_equal(sa$format_age("2025-06-06", "2025-06-15"), "1 week, 2 days")
})

test_that("3.4 - 13 days", {
  expect_equal(sa$format_age("2025-06-02", "2025-06-15"), "1 week, 6 days")
})

test_that("3.5 - 14 days", {
  expect_equal(sa$format_age("2025-06-01", "2025-06-15"), "2 weeks")
})

test_that("3.6 - 15 days", {
  expect_equal(sa$format_age("2025-05-31", "2025-06-15"), "2 weeks, 1 day")
})

test_that("3.7 - 20 days", {
  expect_equal(sa$format_age("2025-05-26", "2025-06-15"), "2 weeks, 6 days")
})

test_that("3.8 - 21 days", {
  expect_equal(sa$format_age("2025-05-25", "2025-06-15"), "3 weeks")
})

test_that("3.9 - 1 calendar month still shows weeks+days", {
  expect_equal(sa$format_age("2025-05-15", "2025-06-15"), "4 weeks, 3 days")
})

test_that("3.10 - 2 calendar months still shows weeks+days", {
  expect_equal(sa$format_age("2025-04-15", "2025-06-15"), "8 weeks, 5 days")
})

test_that("3.11 - day before 3-month birthday", {
  expect_equal(sa$format_age("2025-03-15", "2025-06-14"), "13 weeks")
})

test_that("3.12 - on 3-month birthday switches to months", {
  expect_equal(sa$format_age("2025-03-15", "2025-06-15"), "3 months")
})

# ================================================================
# 4. Month boundaries — standard months
# ================================================================
test_that("4.1 - born Jan 1 check Apr 1", {
  expect_equal(sa$format_age("2025-01-01", "2025-04-01"), "3 months")
})

test_that("4.2 - born Jan 1 check Mar 31 still weeks", {
  result <- sa$format_age("2025-01-01", "2025-03-31")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

test_that("4.3 - born Jun 15 check Sep 15", {
  expect_equal(sa$format_age("2025-06-15", "2025-09-15"), "3 months")
})

test_that("4.4 - born Jun 15 check Sep 14 still weeks", {
  result <- sa$format_age("2025-06-15", "2025-09-14")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

test_that("4.5 - born Jun 15 check Dec 15", {
  expect_equal(sa$format_age("2025-06-15", "2025-12-15"), "6 months")
})

# ================================================================
# 5. Month boundaries — February non-leap year
# ================================================================
test_that("5.1 - born Jan 31 check Feb 28 non-leap", {
  expect_equal(sa$format_age("2025-01-31", "2025-02-28"), "4 weeks")
})

test_that("5.2 - born Jan 31 check Apr 30", {
  expect_equal(sa$format_age("2025-01-31", "2025-04-30"), "3 months")
})

test_that("5.3 - born Jan 31 check Apr 29 still weeks", {
  result <- sa$format_age("2025-01-31", "2025-04-29")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

test_that("5.4 - born Feb 1 check May 1", {
  expect_equal(sa$format_age("2025-02-01", "2025-05-01"), "3 months")
})

test_that("5.5 - born Feb 1 check Apr 30 still weeks", {
  result <- sa$format_age("2025-02-01", "2025-04-30")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

# ================================================================
# 6. Month boundaries — February leap year
# ================================================================
test_that("6.1 - born Jan 31 check Feb 29 leap", {
  expect_equal(sa$format_age("2024-01-31", "2024-02-29"), "4 weeks, 1 day")
})

test_that("6.2 - born Jan 31 check Feb 28 leap", {
  expect_equal(sa$format_age("2024-01-31", "2024-02-28"), "4 weeks")
})

test_that("6.3 - born Jan 31 check Apr 30 leap", {
  expect_equal(sa$format_age("2024-01-31", "2024-04-30"), "3 months")
})

test_that("6.4 - born Jan 30 check Feb 29 leap still weeks", {
  result <- sa$format_age("2024-01-30", "2024-02-29")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

test_that("6.5 - born Jan 30 check Feb 28 leap still weeks", {
  result <- sa$format_age("2024-01-30", "2024-02-28")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

# ================================================================
# 7. Month boundaries — 30-day months
# ================================================================
test_that("7.1 - born Mar 31 check Jun 30", {
  expect_equal(sa$format_age("2025-03-31", "2025-06-30"), "3 months")
})

test_that("7.2 - born Mar 31 check Jun 29 still weeks", {
  result <- sa$format_age("2025-03-31", "2025-06-29")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

test_that("7.3 - born Aug 31 check Nov 30", {
  expect_equal(sa$format_age("2025-08-31", "2025-11-30"), "3 months")
})

test_that("7.4 - born Aug 31 check Nov 29 still weeks", {
  result <- sa$format_age("2025-08-31", "2025-11-29")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

# ================================================================
# 8. Month boundaries — leap year baby (born Feb 29)
# ================================================================
test_that("8.1 - born Feb 29 check May 29", {
  expect_equal(sa$format_age("2024-02-29", "2024-05-29"), "3 months")
})

test_that("8.2 - born Feb 29 check May 28 still weeks", {
  result <- sa$format_age("2024-02-29", "2024-05-28")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

test_that("8.3 - born Feb 29 check Feb 28 non-leap", {
  expect_equal(sa$format_age("2024-02-29", "2025-02-28"), "12 months")
})

test_that("8.4 - born Feb 29 check Mar 1 next year", {
  expect_equal(sa$format_age("2024-02-29", "2025-03-01"), "12 months")
})

# ================================================================
# 9. Months tier (3-23 months)
# ================================================================
test_that("9.1 - 3 months at transition", {
  expect_equal(sa$format_age("2025-01-15", "2025-04-15"), "3 months")
})

test_that("9.2 - 6 months", {
  expect_equal(sa$format_age("2025-01-15", "2025-07-15"), "6 months")
})

test_that("9.3 - 12 months not 1 year", {
  expect_equal(sa$format_age("2024-06-15", "2025-06-15"), "12 months")
})

test_that("9.4 - 23 months upper boundary", {
  expect_equal(sa$format_age("2024-01-15", "2025-12-15"), "23 months")
})

test_that("9.5 - one day before month boundary", {
  expect_equal(sa$format_age("2025-01-15", "2025-07-14"), "5 months")
})

test_that("9.6 - crossing year boundary", {
  expect_equal(sa$format_age("2024-11-10", "2025-04-10"), "5 months")
})

# ================================================================
# 10. Years+months tier (24-35 months)
# ================================================================
test_that("10.1 - 2 years at 24 months", {
  expect_equal(sa$format_age("2023-06-15", "2025-06-15"), "2 years")
})

test_that("10.2 - 2 years 1 month singular", {
  expect_equal(sa$format_age("2023-06-15", "2025-07-15"), "2 years, 1 month")
})

test_that("10.3 - 2 years 6 months", {
  expect_equal(sa$format_age("2023-06-15", "2025-12-15"), "2 years, 6 months")
})

test_that("10.4 - 2 years 11 months upper boundary", {
  expect_equal(sa$format_age("2023-06-15", "2026-05-15"), "2 years, 11 months")
})

test_that("10.5 - one day before 24 months stays in months", {
  expect_equal(sa$format_age("2023-06-15", "2025-06-14"), "23 months")
})

# ================================================================
# 11. Half-year tier (3-6 years)
# ================================================================
test_that("11.1 - 3 years exact", {
  expect_equal(sa$format_age("2022-06-15", "2025-06-15"), "3 years")
})

test_that("11.2 - 3 years 5 months", {
  expect_equal(sa$format_age("2022-06-15", "2025-11-15"), "3 years")
})

test_that("11.3 - 3 and half years", {
  expect_equal(sa$format_age("2022-06-15", "2025-12-15"), "3\u00bd years")
})

test_that("11.4 - 3 years 11 months", {
  expect_equal(sa$format_age("2022-06-15", "2026-05-15"), "3\u00bd years")
})

test_that("11.5 - 4 years exact", {
  expect_equal(sa$format_age("2021-06-15", "2025-06-15"), "4 years")
})

test_that("11.6 - 4 and half years", {
  expect_equal(sa$format_age("2021-06-15", "2025-12-15"), "4\u00bd years")
})

test_that("11.7 - 5 years exact", {
  expect_equal(sa$format_age("2020-06-15", "2025-06-15"), "5 years")
})

test_that("11.8 - 5 and half years", {
  expect_equal(sa$format_age("2020-06-15", "2026-02-15"), "5\u00bd years")
})

test_that("11.9 - 6 years exact", {
  expect_equal(sa$format_age("2019-06-15", "2025-06-15"), "6 years")
})

test_that("11.10 - 6 and half years", {
  expect_equal(sa$format_age("2019-06-15", "2025-12-15"), "6\u00bd years")
})

test_that("11.11 - 6 years 11 months", {
  expect_equal(sa$format_age("2019-06-15", "2026-05-15"), "6\u00bd years")
})

test_that("11.12 - one day before 3rd birthday", {
  expect_equal(sa$format_age("2022-06-15", "2025-06-14"), "2 years, 11 months")
})

# ================================================================
# 12. Integer tier (7+ years)
# ================================================================
test_that("12.1 - 7 years exact", {
  expect_equal(sa$format_age("2018-06-15", "2025-06-15"), "7 years")
})

test_that("12.2 - 7 years 6 months no half", {
  expect_equal(sa$format_age("2018-03-20", "2025-06-15"), "7 years")
})

test_that("12.3 - 45 years adult", {
  expect_equal(sa$format_age("1980-01-01", "2025-06-15"), "45 years")
})

# ================================================================
# 13. Cross-year transitions with February
# ================================================================
test_that("13.1 - born Dec 31 check Mar 31", {
  expect_equal(sa$format_age("2024-12-31", "2025-03-31"), "3 months")
})

test_that("13.2 - born Dec 31 check Mar 30 still weeks", {
  result <- sa$format_age("2024-12-31", "2025-03-30")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

test_that("13.3 - born Nov 30 check Feb 28", {
  expect_equal(sa$format_age("2024-11-30", "2025-02-28"), "3 months")
})

test_that("13.4 - born Nov 30 check Feb 27 still weeks", {
  result <- sa$format_age("2024-11-30", "2025-02-27")
  expect_false(is.null(result))
  expect_true(grepl("week", result))
})

# ================================================================
# 14. Born-on-31st progression
# ================================================================
test_that("14.1 - Jan 31 to Apr 30", {
  expect_equal(sa$format_age("2025-01-31", "2025-04-30"), "3 months")
})

test_that("14.2 - Jan 31 to May 31", {
  expect_equal(sa$format_age("2025-01-31", "2025-05-31"), "4 months")
})

test_that("14.3 - Jan 31 to Jun 30 clamped", {
  expect_equal(sa$format_age("2025-01-31", "2025-06-30"), "5 months")
})

test_that("14.4 - Jan 31 to Jul 1 before birthday", {
  expect_equal(sa$format_age("2025-01-31", "2025-07-01"), "5 months")
})

test_that("14.5 - Jan 31 to Jul 31", {
  expect_equal(sa$format_age("2025-01-31", "2025-07-31"), "6 months")
})

# ================================================================
# 15. Default asOf (current date)
# ================================================================
test_that("15.1, 15.2 - returns correct age with explicit as_of", {
  expect_equal(sa$format_age("2020-01-01", "2025-06-15"), "5 years")
  expect_equal(sa$format_age("2025-06-10", "2025-06-15"), "5 days")
})

# ================================================================
# 16. formatStage null/edge cases
# ================================================================
test_that("16.1 - returns NULL for NULL", {
  expect_null(sa$format_stage(NULL, "2025-06-15"))
})

test_that("16.3 - returns NULL for empty string", {
  expect_null(sa$format_stage("", "2025-06-15"))
})

test_that("16.4 - returns NULL for future dob", {
  expect_null(sa$format_stage("2025-07-01", "2025-06-15"))
})

test_that("16.5 - exactly 500 years returns Adult", {
  expect_equal(sa$format_stage("1525-06-15", "2025-06-15"), "Adult")
})

test_that("16.6 - 501 years exceeds max age", {
  expect_null(sa$format_stage("1524-06-15", "2025-06-15"))
})

# ================================================================
# 17. formatStage — Newborn (0-1 months)
# ================================================================
test_that("17.1 - born today", {
  expect_equal(sa$format_stage("2025-06-15", "2025-06-15"), "Newborn")
})

test_that("17.2 - 1 day old", {
  expect_equal(sa$format_stage("2025-06-14", "2025-06-15"), "Newborn")
})

test_that("17.3 - 3 weeks old", {
  expect_equal(sa$format_stage("2025-05-25", "2025-06-15"), "Newborn")
})

test_that("17.4 - 1 month old", {
  expect_equal(sa$format_stage("2025-05-15", "2025-06-15"), "Newborn")
})

test_that("17.5 - 1 month 29 days still newborn", {
  expect_equal(sa$format_stage("2025-04-16", "2025-06-15"), "Newborn")
})

test_that("17.6 - exactly 2 months becomes infant", {
  expect_equal(sa$format_stage("2025-04-15", "2025-06-15"), "Infant")
})

# ================================================================
# 18. formatStage — Infant (2-11 months)
# ================================================================
test_that("18.1 - 2 months", {
  expect_equal(sa$format_stage("2025-04-15", "2025-06-15"), "Infant")
})

test_that("18.2 - 6 months", {
  expect_equal(sa$format_stage("2024-12-15", "2025-06-15"), "Infant")
})

test_that("18.3 - 11 months", {
  expect_equal(sa$format_stage("2024-07-15", "2025-06-15"), "Infant")
})

test_that("18.4 - exactly 12 months becomes toddler", {
  expect_equal(sa$format_stage("2024-06-15", "2025-06-15"), "Toddler")
})

# ================================================================
# 19. formatStage — Toddler (12-35 months)
# ================================================================
test_that("19.1 - 12 months", {
  expect_equal(sa$format_stage("2024-06-15", "2025-06-15"), "Toddler")
})

test_that("19.2 - 18 months", {
  expect_equal(sa$format_stage("2024-01-15", "2025-07-15"), "Toddler")
})

test_that("19.3 - 24 months", {
  expect_equal(sa$format_stage("2023-06-15", "2025-06-15"), "Toddler")
})

test_that("19.4 - 35 months still toddler", {
  expect_equal(sa$format_stage("2023-06-15", "2026-05-15"), "Toddler")
})

test_that("19.5 - exactly 36 months becomes child", {
  expect_equal(sa$format_stage("2022-06-15", "2025-06-15"), "Child")
})

# ================================================================
# 20. formatStage — Child (36-155 months)
# ================================================================
test_that("20.1 - 3 years", {
  expect_equal(sa$format_stage("2022-06-15", "2025-06-15"), "Child")
})

test_that("20.2 - 4 years", {
  expect_equal(sa$format_stage("2021-06-15", "2025-06-15"), "Child")
})

test_that("20.3 - 6 years", {
  expect_equal(sa$format_stage("2019-06-15", "2025-06-15"), "Child")
})

test_that("20.4 - 9 years", {
  expect_equal(sa$format_stage("2016-06-15", "2025-06-15"), "Child")
})

test_that("20.5 - 12 years 11 months still child", {
  expect_equal(sa$format_stage("2013-06-15", "2026-05-15"), "Child")
})

test_that("20.6 - exactly 13 years becomes teenager", {
  expect_equal(sa$format_stage("2012-06-15", "2025-06-15"), "Teenager")
})

# ================================================================
# 21. formatStage — Teenager (156-215 months)
# ================================================================
test_that("21.1 - 13 years", {
  expect_equal(sa$format_stage("2012-06-15", "2025-06-15"), "Teenager")
})

test_that("21.2 - 15 years", {
  expect_equal(sa$format_stage("2010-06-15", "2025-06-15"), "Teenager")
})

test_that("21.3 - 17 years 11 months still teenager", {
  expect_equal(sa$format_stage("2008-06-15", "2026-05-15"), "Teenager")
})

test_that("21.4 - exactly 18 years becomes adult", {
  expect_equal(sa$format_stage("2007-06-15", "2025-06-15"), "Adult")
})

# ================================================================
# 22. formatStage — Adult (216+ months)
# ================================================================
test_that("22.1 - 18 years", {
  expect_equal(sa$format_stage("2007-06-15", "2025-06-15"), "Adult")
})

test_that("22.2 - 25 years", {
  expect_equal(sa$format_stage("2000-06-15", "2025-06-15"), "Adult")
})

test_that("22.3 - 45 years", {
  expect_equal(sa$format_stage("1980-01-01", "2025-06-15"), "Adult")
})

# ================================================================
# 23. formatStage — default asOf
# ================================================================
test_that("23.1, 23.2, 23.3 - returns correct stage with explicit as_of", {
  expect_equal(sa$format_stage("2025-06-15", "2025-06-15"), "Newborn")
  expect_equal(sa$format_stage("2020-01-01", "2025-06-15"), "Child")
  expect_equal(sa$format_stage("1980-01-01", "2025-06-15"), "Adult")
})

# ================================================================
# 24. SayableAge class — English locale delegation
# ================================================================
test_that("24.1-24.7 - format_age delegates", {
  expect_equal(sa$format_age("2025-06-15", "2025-06-15"), "Newborn")
  expect_equal(sa$format_age("2025-06-12", "2025-06-15"), "3 days")
  expect_equal(sa$format_age("2025-06-07", "2025-06-15"), "1 week, 1 day")
  expect_equal(sa$format_age("2025-01-15", "2025-07-15"), "6 months")
  expect_equal(sa$format_age("2023-06-15", "2025-07-15"), "2 years, 1 month")
  expect_equal(sa$format_age("2022-06-15", "2025-12-15"), "3\u00bd years")
  expect_equal(sa$format_age("2018-06-15", "2025-06-15"), "7 years")
})

test_that("24.8-24.13 - format_stage delegates", {
  expect_equal(sa$format_stage("2025-06-15", "2025-06-15"), "Newborn")
  expect_equal(sa$format_stage("2025-01-15", "2025-06-15"), "Infant")
  expect_equal(sa$format_stage("2024-06-15", "2025-06-15"), "Toddler")
  expect_equal(sa$format_stage("2022-06-15", "2025-06-15"), "Child")
  expect_equal(sa$format_stage("2012-06-15", "2025-06-15"), "Teenager")
  expect_equal(sa$format_stage("2007-06-15", "2025-06-15"), "Adult")
})

test_that("24.14, 24.15 - returns NULL for invalid", {
  expect_null(sa$format_age(NULL, "2025-06-15"))
  expect_null(sa$format_stage(NULL, "2025-06-15"))
})

# ================================================================
# 25. i18n — Spanish locale
# ================================================================
test_that("25.1-25.12 - Spanish locale format_age", {
  es <- load_locale("es")
  pt <- sayable_age_new(es)

  # 25.1
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "Reci\u00e9n nacido")
  # 25.2
  expect_equal(pt$format_age("2025-06-14", "2025-06-15"), "1 d\u00eda")
  # 25.3
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "3 d\u00edas")
  # 25.4
  expect_equal(pt$format_age("2025-06-08", "2025-06-15"), "1 semana")
  # 25.5
  expect_equal(pt$format_age("2025-06-07", "2025-06-15"), "1 semana, 1 d\u00eda")
  # 25.6
  expect_equal(pt$format_age("2025-05-26", "2025-06-15"), "2 semanas, 6 d\u00edas")
  # 25.7
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "6 meses")
  # 25.8
  expect_equal(pt$format_age("2023-06-15", "2025-07-15"), "2 a\u00f1os, 1 mes")
  # 25.9
  expect_equal(pt$format_age("2023-06-15", "2025-12-15"), "2 a\u00f1os, 6 meses")
  # 25.10
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "3 y medio a\u00f1os")
  # 25.11
  expect_equal(pt$format_age("2022-06-15", "2025-06-15"), "3 a\u00f1os")
  # 25.12
  expect_equal(pt$format_age("2018-06-15", "2025-06-15"), "7 a\u00f1os")
})

test_that("25.13-25.18 - Spanish locale stage labels", {
  es <- load_locale("es")
  pt <- sayable_age_new(es)

  expect_equal(pt$format_stage("2025-06-15", "2025-06-15"), "Reci\u00e9n nacido")
  expect_equal(pt$format_stage("2025-01-15", "2025-06-15"), "Beb\u00e9")
  expect_equal(pt$format_stage("2024-06-15", "2025-06-15"), "Ni\u00f1o peque\u00f1o")
  expect_equal(pt$format_stage("2022-06-15", "2025-06-15"), "Ni\u00f1o")
  expect_equal(pt$format_stage("2012-06-15", "2025-06-15"), "Adolescente")
  expect_equal(pt$format_stage("2007-06-15", "2025-06-15"), "Adulto")
})

test_that("25.19, 25.20 - Spanish locale null handling", {
  es <- load_locale("es")
  pt <- sayable_age_new(es)

  expect_null(pt$format_age(NULL, "2025-06-15"))
  expect_null(pt$format_stage(NULL, "2025-06-15"))
})

# ================================================================
# 26. Compactness — short
# ================================================================
test_that("26.1-26.9 - short compactness", {
  pt <- sayable_age_new(en, "short")

  # 26.1
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "3 d")
  # 26.2
  expect_equal(pt$format_age("2025-06-08", "2025-06-15"), "1 wk")
  # 26.3
  expect_equal(pt$format_age("2025-06-07", "2025-06-15"), "1 wk, 1 d")
  # 26.4
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "6 mo")
  # 26.5
  expect_equal(pt$format_age("2023-06-15", "2025-07-15"), "2 yr, 1 mo")
  # 26.6
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "3\u00bd yr")
  # 26.7
  expect_equal(pt$format_age("2018-06-15", "2025-06-15"), "7 yr")
  # 26.8
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "Newborn")
  # 26.9
  expect_equal(pt$format_stage("2025-01-15", "2025-06-15"), "Infant")
})

# ================================================================
# 27. Compactness — compact
# ================================================================
test_that("27.1-27.8 - compact compactness", {
  pt <- sayable_age_new(en, "compact")

  # 27.1
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "3d")
  # 27.2
  expect_equal(pt$format_age("2025-06-08", "2025-06-15"), "1w")
  # 27.3
  expect_equal(pt$format_age("2025-06-07", "2025-06-15"), "1w1d")
  # 27.4
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "6m")
  # 27.5
  expect_equal(pt$format_age("2023-06-15", "2025-07-15"), "2y1m")
  # 27.6
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "3\u00bdy")
  # 27.7
  expect_equal(pt$format_age("2018-06-15", "2025-06-15"), "7y")
  # 27.8
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "Newborn")
})

# ================================================================
# 29. Locale-specific edge cases — plural rules
# ================================================================

# 29.1 — Hebrew (he) — dual forms
test_that("29.1-29.14 - Hebrew locale", {
  he <- load_locale("he")
  pt <- sayable_age_new(he)

  # 29.1
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "\u05e8\u05e7 \u05e0\u05d5\u05dc\u05d3")
  # 29.2
  expect_equal(pt$format_age("2025-06-14", "2025-06-15"), "\u05d9\u05d5\u05dd 1")
  # 29.3
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "3 \u05d9\u05de\u05d9\u05dd")
  # 29.4
  expect_equal(pt$format_age("2025-06-01", "2025-06-15"), "\u05e9\u05d1\u05d5\u05e2\u05d9\u05d9\u05dd")
  # 29.5
  expect_equal(pt$format_age("2025-05-25", "2025-06-15"), "3 \u05e9\u05d1\u05d5\u05e2\u05d5\u05ea")
  # 29.6
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "6 \u05d7\u05d5\u05d3\u05e9\u05d9\u05dd")
  # 29.7
  expect_equal(pt$format_age("2025-03-15", "2025-06-15"), "3 \u05d7\u05d5\u05d3\u05e9\u05d9\u05dd")
  # 29.8
  expect_equal(pt$format_age("2023-06-15", "2025-07-15"), "\u05e9\u05e0\u05ea\u05d9\u05d9\u05dd, \u05d7\u05d5\u05d3\u05e9 1")
  # 29.9
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "3 \u05e9\u05e0\u05d9\u05dd \u05d5\u05d7\u05e6\u05d9")
  # 29.10
  expect_equal(pt$format_age("2018-06-15", "2025-06-15"), "7 \u05e9\u05e0\u05d9\u05dd")
  # 29.11
  expect_equal(pt$format_stage("2025-06-15", "2025-06-15", "m"), "\u05e8\u05e7 \u05e0\u05d5\u05dc\u05d3")
  # 29.12
  expect_equal(pt$format_stage("2025-06-15", "2025-06-15", "f"), "\u05e8\u05e7 \u05e0\u05d5\u05dc\u05d3\u05d4")
  # 29.13
  expect_equal(pt$format_stage("2007-06-15", "2025-06-15", "m"), "\u05de\u05d1\u05d5\u05d2\u05e8")
  # 29.14
  expect_equal(pt$format_stage("2007-06-15", "2025-06-15", "f"), "\u05de\u05d1\u05d5\u05d2\u05e8\u05ea")
})

# 29.2 — Macedonian (mk) — mod10/mod100 rule
test_that("29.15-29.21 - Macedonian locale", {
  mk <- load_locale("mk")
  pt <- sayable_age_new(mk)

  # 29.15
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "\u041d\u043e\u0432\u043e\u0440\u043e\u0434\u0435\u043d\u0447\u0435")
  # 29.16
  expect_equal(pt$format_age("2025-06-14", "2025-06-15"), "1 \u0434\u0435\u043d")
  # 29.17
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "3 \u0434\u0435\u043d\u0430")
  # 29.18
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "6 \u043c\u0435\u0441\u0435\u0446\u0438")
  # 29.19
  expect_equal(pt$format_age("2023-06-15", "2025-07-15"), "2 \u0433\u043e\u0434\u0438\u043d\u0438, 1 \u043c\u0435\u0441\u0435\u0446")
  # 29.20
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "3 \u0433\u043e\u0434\u0438\u043d\u0438 \u0438 \u043f\u043e\u043b")
  # 29.21
  expect_equal(pt$format_age("2018-06-15", "2025-06-15"), "7 \u0433\u043e\u0434\u0438\u043d\u0438")
})

# 29.3 — Swahili (sw) — noun class changes
test_that("29.22-29.27 - Swahili locale", {
  sw <- load_locale("sw")
  pt <- sayable_age_new(sw)

  # 29.22
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "Mzaliwa mpya")
  # 29.23
  expect_equal(pt$format_age("2025-06-14", "2025-06-15"), "siku 1")
  # 29.24
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "siku 3")
  # 29.25
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "miezi 6")
  # 29.26
  expect_equal(pt$format_age("2023-06-15", "2025-07-15"), "miaka 2, mwezi 1")
  # 29.27
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "miaka 3 na nusu")
})

# 29.4 — Indonesian (id) — other_only
test_that("29.28-29.33 - Indonesian locale", {
  id_locale <- load_locale("id")
  pt <- sayable_age_new(id_locale)

  # 29.28
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "Baru lahir")
  # 29.29
  expect_equal(pt$format_age("2025-06-14", "2025-06-15"), "1 hari")
  # 29.30
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "3 hari")
  # 29.31
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "6 bulan")
  # 29.32
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "3 tahun setengah")
  # 29.33
  expect_equal(pt$format_age("2018-06-15", "2025-06-15"), "7 tahun")
})

# 29.5 — Amharic (am) — Ethiopic delimiter
test_that("29.34-29.39 - Amharic locale", {
  am <- load_locale("am")
  pt <- sayable_age_new(am)

  # 29.34
  expect_equal(pt$format_age("2025-06-15", "2025-06-15"), "\u12a0\u12f2\u1235 \u12e8\u1270\u12c8\u1208\u12f0")
  # 29.35
  expect_equal(pt$format_age("2025-06-14", "2025-06-15"), "1 \u1240\u1295")
  # 29.36
  expect_equal(pt$format_age("2025-06-12", "2025-06-15"), "3 \u1240\u1293\u1275")
  # 29.37
  expect_equal(pt$format_age("2025-06-07", "2025-06-15"), "1 \u1233\u121d\u1295\u1275\u1363 1 \u1240\u1295")
  # 29.38
  expect_equal(pt$format_age("2025-01-15", "2025-07-15"), "6 \u12c8\u122b\u1275")
  # 29.39
  expect_equal(pt$format_age("2022-06-15", "2025-12-15"), "3 \u12d3\u1218\u1273\u1275 \u1270\u12a9\u120d")
})

# ================================================================
# 30. Locale lookup by code string
# ================================================================
test_that("30.1 - known locale en", {
  loc <- load_locale("en")
  expect_false(is.null(loc))
  expect_equal(loc$code, "en")
})

test_that("30.2 - known locale fr", {
  loc <- load_locale("fr")
  expect_false(is.null(loc))
  expect_equal(loc$code, "fr")
})

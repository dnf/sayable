# Test suite for sayable-age Janet implementation.
# Implements all canonical test cases from age/config/tests.json.
# Sections 15 and 23 are skipped (require system date mocking).

(import ./sayableage :as sa)

(var pass-count 0)
(var fail-count 0)

(defn assert-eq [test-id actual expected]
  (if (= actual expected)
    (++ pass-count)
    (do
      (++ fail-count)
      (eprintf "FAIL %s: expected %q, got %q" test-id expected actual))))

(defn assert-nil [test-id actual]
  (if (nil? actual)
    (++ pass-count)
    (do
      (++ fail-count)
      (eprintf "FAIL %s: expected nil, got %q" test-id actual))))

(defn assert-not-nil [test-id actual]
  (if (not (nil? actual))
    (++ pass-count)
    (do
      (++ fail-count)
      (eprintf "FAIL %s: expected non-nil, got nil" test-id))))

# Helper to check weeks_pattern: the result should contain "week"
(defn assert-weeks-pattern [test-id actual]
  (if (and (string? actual) (string/find "week" actual))
    (++ pass-count)
    (do
      (++ fail-count)
      (eprintf "FAIL %s: expected weeks pattern, got %q" test-id actual))))

# =============================================================================
# Section 1: Null / edge cases
# =============================================================================

# 1.1
(assert-nil "1.1" (sa/format-age nil))

# 1.2 — "undefined" treated as invalid string
(assert-nil "1.2" (sa/format-age "undefined"))

# 1.3
(assert-nil "1.3" (sa/format-age ""))

# 1.4
(assert-nil "1.4" (sa/format-age "2025-07-01" "2025-06-15"))

# 1.5
(assert-eq "1.5" (sa/format-age "1525-06-15" "2025-06-15") "500 years")

# 1.6
(assert-nil "1.6" (sa/format-age "1524-06-15" "2025-06-15"))

# 1.7
(assert-nil "1.7" (sa/format-age "1025-06-15" "2025-06-15"))

# =============================================================================
# Section 2: Days tier (0-6 days)
# =============================================================================

# 2.1
(assert-eq "2.1" (sa/format-age "2025-06-15" "2025-06-15") "Newborn")

# 2.2
(assert-eq "2.2" (sa/format-age "2025-06-14" "2025-06-15") "1 day")

# 2.3
(assert-eq "2.3" (sa/format-age "2025-06-12" "2025-06-15") "3 days")

# 2.4
(assert-eq "2.4" (sa/format-age "2025-06-09" "2025-06-15") "6 days")

# 2.5
(assert-eq "2.5" (sa/format-age "2025-06-08" "2025-06-15") "1 week")

# =============================================================================
# Section 3: Weeks+days tier (7 days to <3 calendar months)
# =============================================================================

# 3.1
(assert-eq "3.1" (sa/format-age "2025-06-08" "2025-06-15") "1 week")

# 3.2
(assert-eq "3.2" (sa/format-age "2025-06-07" "2025-06-15") "1 week, 1 day")

# 3.3
(assert-eq "3.3" (sa/format-age "2025-06-06" "2025-06-15") "1 week, 2 days")

# 3.4
(assert-eq "3.4" (sa/format-age "2025-06-02" "2025-06-15") "1 week, 6 days")

# 3.5
(assert-eq "3.5" (sa/format-age "2025-06-01" "2025-06-15") "2 weeks")

# 3.6
(assert-eq "3.6" (sa/format-age "2025-05-31" "2025-06-15") "2 weeks, 1 day")

# 3.7
(assert-eq "3.7" (sa/format-age "2025-05-26" "2025-06-15") "2 weeks, 6 days")

# 3.8
(assert-eq "3.8" (sa/format-age "2025-05-25" "2025-06-15") "3 weeks")

# 3.9
(assert-eq "3.9" (sa/format-age "2025-05-15" "2025-06-15") "4 weeks, 3 days")

# 3.10
(assert-eq "3.10" (sa/format-age "2025-04-15" "2025-06-15") "8 weeks, 5 days")

# 3.11
(assert-eq "3.11" (sa/format-age "2025-03-15" "2025-06-14") "13 weeks")

# 3.12
(assert-eq "3.12" (sa/format-age "2025-03-15" "2025-06-15") "3 months")

# =============================================================================
# Section 4: Month boundaries - standard months
# =============================================================================

# 4.1
(assert-eq "4.1" (sa/format-age "2025-01-01" "2025-04-01") "3 months")

# 4.2
(assert-weeks-pattern "4.2" (sa/format-age "2025-01-01" "2025-03-31"))

# 4.3
(assert-eq "4.3" (sa/format-age "2025-06-15" "2025-09-15") "3 months")

# 4.4
(assert-weeks-pattern "4.4" (sa/format-age "2025-06-15" "2025-09-14"))

# 4.5
(assert-eq "4.5" (sa/format-age "2025-06-15" "2025-12-15") "6 months")

# =============================================================================
# Section 5: Month boundaries - February non-leap year
# =============================================================================

# 5.1
(assert-eq "5.1" (sa/format-age "2025-01-31" "2025-02-28") "4 weeks")

# 5.2
(assert-eq "5.2" (sa/format-age "2025-01-31" "2025-04-30") "3 months")

# 5.3
(assert-weeks-pattern "5.3" (sa/format-age "2025-01-31" "2025-04-29"))

# 5.4
(assert-eq "5.4" (sa/format-age "2025-02-01" "2025-05-01") "3 months")

# 5.5
(assert-weeks-pattern "5.5" (sa/format-age "2025-02-01" "2025-04-30"))

# =============================================================================
# Section 6: Month boundaries - February leap year
# =============================================================================

# 6.1
(assert-eq "6.1" (sa/format-age "2024-01-31" "2024-02-29") "4 weeks, 1 day")

# 6.2
(assert-eq "6.2" (sa/format-age "2024-01-31" "2024-02-28") "4 weeks")

# 6.3
(assert-eq "6.3" (sa/format-age "2024-01-31" "2024-04-30") "3 months")

# 6.4
(assert-weeks-pattern "6.4" (sa/format-age "2024-01-30" "2024-02-29"))

# 6.5
(assert-weeks-pattern "6.5" (sa/format-age "2024-01-30" "2024-02-28"))

# =============================================================================
# Section 7: Month boundaries - 30-day months
# =============================================================================

# 7.1
(assert-eq "7.1" (sa/format-age "2025-03-31" "2025-06-30") "3 months")

# 7.2
(assert-weeks-pattern "7.2" (sa/format-age "2025-03-31" "2025-06-29"))

# 7.3
(assert-eq "7.3" (sa/format-age "2025-08-31" "2025-11-30") "3 months")

# 7.4
(assert-weeks-pattern "7.4" (sa/format-age "2025-08-31" "2025-11-29"))

# =============================================================================
# Section 8: Month boundaries - leap year baby (born Feb 29)
# =============================================================================

# 8.1
(assert-eq "8.1" (sa/format-age "2024-02-29" "2024-05-29") "3 months")

# 8.2
(assert-weeks-pattern "8.2" (sa/format-age "2024-02-29" "2024-05-28"))

# 8.3
(assert-eq "8.3" (sa/format-age "2024-02-29" "2025-02-28") "12 months")

# 8.4
(assert-eq "8.4" (sa/format-age "2024-02-29" "2025-03-01") "12 months")

# =============================================================================
# Section 9: Months tier (3-23 months)
# =============================================================================

# 9.1
(assert-eq "9.1" (sa/format-age "2025-01-15" "2025-04-15") "3 months")

# 9.2
(assert-eq "9.2" (sa/format-age "2025-01-15" "2025-07-15") "6 months")

# 9.3
(assert-eq "9.3" (sa/format-age "2024-06-15" "2025-06-15") "12 months")

# 9.4
(assert-eq "9.4" (sa/format-age "2024-01-15" "2025-12-15") "23 months")

# 9.5
(assert-eq "9.5" (sa/format-age "2025-01-15" "2025-07-14") "5 months")

# 9.6
(assert-eq "9.6" (sa/format-age "2024-11-10" "2025-04-10") "5 months")

# =============================================================================
# Section 10: Years+months tier (24-35 months)
# =============================================================================

# 10.1
(assert-eq "10.1" (sa/format-age "2023-06-15" "2025-06-15") "2 years")

# 10.2
(assert-eq "10.2" (sa/format-age "2023-06-15" "2025-07-15") "2 years, 1 month")

# 10.3
(assert-eq "10.3" (sa/format-age "2023-06-15" "2025-12-15") "2 years, 6 months")

# 10.4
(assert-eq "10.4" (sa/format-age "2023-06-15" "2026-05-15") "2 years, 11 months")

# 10.5
(assert-eq "10.5" (sa/format-age "2023-06-15" "2025-06-14") "23 months")

# =============================================================================
# Section 11: Half-year tier (3-6 years)
# =============================================================================

# 11.1
(assert-eq "11.1" (sa/format-age "2022-06-15" "2025-06-15") "3 years")

# 11.2
(assert-eq "11.2" (sa/format-age "2022-06-15" "2025-11-15") "3 years")

# 11.3
(assert-eq "11.3" (sa/format-age "2022-06-15" "2025-12-15") "3½ years")

# 11.4
(assert-eq "11.4" (sa/format-age "2022-06-15" "2026-05-15") "3½ years")

# 11.5
(assert-eq "11.5" (sa/format-age "2021-06-15" "2025-06-15") "4 years")

# 11.6
(assert-eq "11.6" (sa/format-age "2021-06-15" "2025-12-15") "4½ years")

# 11.7
(assert-eq "11.7" (sa/format-age "2020-06-15" "2025-06-15") "5 years")

# 11.8
(assert-eq "11.8" (sa/format-age "2020-06-15" "2026-02-15") "5½ years")

# 11.9
(assert-eq "11.9" (sa/format-age "2019-06-15" "2025-06-15") "6 years")

# 11.10
(assert-eq "11.10" (sa/format-age "2019-06-15" "2025-12-15") "6½ years")

# 11.11
(assert-eq "11.11" (sa/format-age "2019-06-15" "2026-05-15") "6½ years")

# 11.12
(assert-eq "11.12" (sa/format-age "2022-06-15" "2025-06-14") "2 years, 11 months")

# =============================================================================
# Section 12: Integer tier (7+ years)
# =============================================================================

# 12.1
(assert-eq "12.1" (sa/format-age "2018-06-15" "2025-06-15") "7 years")

# 12.2
(assert-eq "12.2" (sa/format-age "2018-03-20" "2025-06-15") "7 years")

# 12.3
(assert-eq "12.3" (sa/format-age "1980-01-01" "2025-06-15") "45 years")

# =============================================================================
# Section 13: Cross-year transitions with February
# =============================================================================

# 13.1
(assert-eq "13.1" (sa/format-age "2024-12-31" "2025-03-31") "3 months")

# 13.2
(assert-weeks-pattern "13.2" (sa/format-age "2024-12-31" "2025-03-30"))

# 13.3
(assert-eq "13.3" (sa/format-age "2024-11-30" "2025-02-28") "3 months")

# 13.4
(assert-weeks-pattern "13.4" (sa/format-age "2024-11-30" "2025-02-27"))

# =============================================================================
# Section 14: Born-on-31st progression
# =============================================================================

# 14.1
(assert-eq "14.1" (sa/format-age "2025-01-31" "2025-04-30") "3 months")

# 14.2
(assert-eq "14.2" (sa/format-age "2025-01-31" "2025-05-31") "4 months")

# 14.3
(assert-eq "14.3" (sa/format-age "2025-01-31" "2025-06-30") "5 months")

# 14.4
(assert-eq "14.4" (sa/format-age "2025-01-31" "2025-07-01") "5 months")

# 14.5
(assert-eq "14.5" (sa/format-age "2025-01-31" "2025-07-31") "6 months")

# =============================================================================
# Section 15: Default asOf — SKIPPED (requires system date mocking)
# =============================================================================

# =============================================================================
# Section 16: formatStage - null / edge cases
# =============================================================================

# 16.1
(assert-nil "16.1" (sa/format-stage nil))

# 16.2
(assert-nil "16.2" (sa/format-stage "undefined"))

# 16.3
(assert-nil "16.3" (sa/format-stage ""))

# 16.4
(assert-nil "16.4" (sa/format-stage "2025-07-01" "2025-06-15"))

# 16.5
(assert-eq "16.5" (sa/format-stage "1525-06-15" "2025-06-15") "Adult")

# 16.6
(assert-nil "16.6" (sa/format-stage "1524-06-15" "2025-06-15"))

# =============================================================================
# Section 17: formatStage - Newborn (0-1 months, <2 calendar months)
# =============================================================================

# 17.1
(assert-eq "17.1" (sa/format-stage "2025-06-15" "2025-06-15") "Newborn")

# 17.2
(assert-eq "17.2" (sa/format-stage "2025-06-14" "2025-06-15") "Newborn")

# 17.3
(assert-eq "17.3" (sa/format-stage "2025-05-25" "2025-06-15") "Newborn")

# 17.4
(assert-eq "17.4" (sa/format-stage "2025-05-15" "2025-06-15") "Newborn")

# 17.5
(assert-eq "17.5" (sa/format-stage "2025-04-16" "2025-06-15") "Newborn")

# 17.6
(assert-eq "17.6" (sa/format-stage "2025-04-15" "2025-06-15") "Infant")

# =============================================================================
# Section 18: formatStage - Infant (2-11 months)
# =============================================================================

# 18.1
(assert-eq "18.1" (sa/format-stage "2025-04-15" "2025-06-15") "Infant")

# 18.2
(assert-eq "18.2" (sa/format-stage "2024-12-15" "2025-06-15") "Infant")

# 18.3
(assert-eq "18.3" (sa/format-stage "2024-07-15" "2025-06-15") "Infant")

# 18.4
(assert-eq "18.4" (sa/format-stage "2024-06-15" "2025-06-15") "Toddler")

# =============================================================================
# Section 19: formatStage - Toddler (12-35 months)
# =============================================================================

# 19.1
(assert-eq "19.1" (sa/format-stage "2024-06-15" "2025-06-15") "Toddler")

# 19.2
(assert-eq "19.2" (sa/format-stage "2024-01-15" "2025-07-15") "Toddler")

# 19.3
(assert-eq "19.3" (sa/format-stage "2023-06-15" "2025-06-15") "Toddler")

# 19.4
(assert-eq "19.4" (sa/format-stage "2023-06-15" "2026-05-15") "Toddler")

# 19.5
(assert-eq "19.5" (sa/format-stage "2022-06-15" "2025-06-15") "Child")

# =============================================================================
# Section 20: formatStage - Child (36-155 months, 3-12 years)
# =============================================================================

# 20.1
(assert-eq "20.1" (sa/format-stage "2022-06-15" "2025-06-15") "Child")

# 20.2
(assert-eq "20.2" (sa/format-stage "2021-06-15" "2025-06-15") "Child")

# 20.3
(assert-eq "20.3" (sa/format-stage "2019-06-15" "2025-06-15") "Child")

# 20.4
(assert-eq "20.4" (sa/format-stage "2016-06-15" "2025-06-15") "Child")

# 20.5
(assert-eq "20.5" (sa/format-stage "2013-06-15" "2026-05-15") "Child")

# 20.6
(assert-eq "20.6" (sa/format-stage "2012-06-15" "2025-06-15") "Teenager")

# =============================================================================
# Section 21: formatStage - Teenager (156-215 months, 13-17 years)
# =============================================================================

# 21.1
(assert-eq "21.1" (sa/format-stage "2012-06-15" "2025-06-15") "Teenager")

# 21.2
(assert-eq "21.2" (sa/format-stage "2010-06-15" "2025-06-15") "Teenager")

# 21.3
(assert-eq "21.3" (sa/format-stage "2008-06-15" "2026-05-15") "Teenager")

# 21.4
(assert-eq "21.4" (sa/format-stage "2007-06-15" "2025-06-15") "Adult")

# =============================================================================
# Section 22: formatStage - Adult (216+ months, 18+ years)
# =============================================================================

# 22.1
(assert-eq "22.1" (sa/format-stage "2007-06-15" "2025-06-15") "Adult")

# 22.2
(assert-eq "22.2" (sa/format-stage "2000-06-15" "2025-06-15") "Adult")

# 22.3
(assert-eq "22.3" (sa/format-stage "1980-01-01" "2025-06-15") "Adult")

# =============================================================================
# Section 23: formatStage - default asOf — SKIPPED (requires system date mocking)
# =============================================================================

# =============================================================================
# Section 24: SayableAge class - English locale delegation
# =============================================================================

(def en-locale (sa/get-locale "en"))
(def pt-en (sa/make-formatter en-locale))

# 24.1
(assert-eq "24.1" ((pt-en :format-age) "2025-06-15" "2025-06-15") "Newborn")

# 24.2
(assert-eq "24.2" ((pt-en :format-age) "2025-06-12" "2025-06-15") "3 days")

# 24.3
(assert-eq "24.3" ((pt-en :format-age) "2025-06-07" "2025-06-15") "1 week, 1 day")

# 24.4
(assert-eq "24.4" ((pt-en :format-age) "2025-01-15" "2025-07-15") "6 months")

# 24.5
(assert-eq "24.5" ((pt-en :format-age) "2023-06-15" "2025-07-15") "2 years, 1 month")

# 24.6
(assert-eq "24.6" ((pt-en :format-age) "2022-06-15" "2025-12-15") "3½ years")

# 24.7
(assert-eq "24.7" ((pt-en :format-age) "2018-06-15" "2025-06-15") "7 years")

# 24.8
(assert-eq "24.8" ((pt-en :format-stage) "2025-06-15" "2025-06-15") "Newborn")

# 24.9
(assert-eq "24.9" ((pt-en :format-stage) "2025-01-15" "2025-06-15") "Infant")

# 24.10
(assert-eq "24.10" ((pt-en :format-stage) "2024-06-15" "2025-06-15") "Toddler")

# 24.11
(assert-eq "24.11" ((pt-en :format-stage) "2022-06-15" "2025-06-15") "Child")

# 24.12
(assert-eq "24.12" ((pt-en :format-stage) "2012-06-15" "2025-06-15") "Teenager")

# 24.13
(assert-eq "24.13" ((pt-en :format-stage) "2007-06-15" "2025-06-15") "Adult")

# 24.14
(assert-nil "24.14" ((pt-en :format-age) nil "2025-06-15"))

# 24.15
(assert-nil "24.15" ((pt-en :format-stage) nil "2025-06-15"))

# =============================================================================
# Section 25: i18n - locale with all plural features (Spanish)
# =============================================================================

(def es-locale (sa/get-locale "es"))
(def pt-es (sa/make-formatter es-locale))

# 25.1
(assert-eq "25.1" ((pt-es :format-age) "2025-06-15" "2025-06-15") "Recién nacido")

# 25.2
(assert-eq "25.2" ((pt-es :format-age) "2025-06-14" "2025-06-15") "1 día")

# 25.3
(assert-eq "25.3" ((pt-es :format-age) "2025-06-12" "2025-06-15") "3 días")

# 25.4
(assert-eq "25.4" ((pt-es :format-age) "2025-06-08" "2025-06-15") "1 semana")

# 25.5
(assert-eq "25.5" ((pt-es :format-age) "2025-06-07" "2025-06-15") "1 semana, 1 día")

# 25.6
(assert-eq "25.6" ((pt-es :format-age) "2025-05-26" "2025-06-15") "2 semanas, 6 días")

# 25.7
(assert-eq "25.7" ((pt-es :format-age) "2025-01-15" "2025-07-15") "6 meses")

# 25.8
(assert-eq "25.8" ((pt-es :format-age) "2023-06-15" "2025-07-15") "2 años, 1 mes")

# 25.9
(assert-eq "25.9" ((pt-es :format-age) "2023-06-15" "2025-12-15") "2 años, 6 meses")

# 25.10
(assert-eq "25.10" ((pt-es :format-age) "2022-06-15" "2025-12-15") "3 y medio años")

# 25.11
(assert-eq "25.11" ((pt-es :format-age) "2022-06-15" "2025-06-15") "3 años")

# 25.12
(assert-eq "25.12" ((pt-es :format-age) "2018-06-15" "2025-06-15") "7 años")

# 25.13
(assert-eq "25.13" ((pt-es :format-stage) "2025-06-15" "2025-06-15") "Recién nacido")

# 25.14
(assert-eq "25.14" ((pt-es :format-stage) "2025-01-15" "2025-06-15") "Bebé")

# 25.15
(assert-eq "25.15" ((pt-es :format-stage) "2024-06-15" "2025-06-15") "Niño pequeño")

# 25.16
(assert-eq "25.16" ((pt-es :format-stage) "2022-06-15" "2025-06-15") "Niño")

# 25.17
(assert-eq "25.17" ((pt-es :format-stage) "2012-06-15" "2025-06-15") "Adolescente")

# 25.18
(assert-eq "25.18" ((pt-es :format-stage) "2007-06-15" "2025-06-15") "Adulto")

# 25.19
(assert-nil "25.19" ((pt-es :format-age) nil "2025-06-15"))

# 25.20
(assert-nil "25.20" ((pt-es :format-stage) nil "2025-06-15"))

# =============================================================================
# Section 26: Compactness - short
# =============================================================================

(def pt-short (sa/make-formatter en-locale "short"))

# 26.1
(assert-eq "26.1" ((pt-short :format-age) "2025-06-12" "2025-06-15") "3 d")

# 26.2
(assert-eq "26.2" ((pt-short :format-age) "2025-06-08" "2025-06-15") "1 wk")

# 26.3
(assert-eq "26.3" ((pt-short :format-age) "2025-06-07" "2025-06-15") "1 wk, 1 d")

# 26.4
(assert-eq "26.4" ((pt-short :format-age) "2025-01-15" "2025-07-15") "6 mo")

# 26.5
(assert-eq "26.5" ((pt-short :format-age) "2023-06-15" "2025-07-15") "2 yr, 1 mo")

# 26.6
(assert-eq "26.6" ((pt-short :format-age) "2022-06-15" "2025-12-15") "3½ yr")

# 26.7
(assert-eq "26.7" ((pt-short :format-age) "2018-06-15" "2025-06-15") "7 yr")

# 26.8
(assert-eq "26.8" ((pt-short :format-age) "2025-06-15" "2025-06-15") "Newborn")

# 26.9
(assert-eq "26.9" ((pt-short :format-stage) "2025-01-15" "2025-06-15") "Infant")

# =============================================================================
# Section 27: Compactness - compact
# =============================================================================

(def pt-compact (sa/make-formatter en-locale "compact"))

# 27.1
(assert-eq "27.1" ((pt-compact :format-age) "2025-06-12" "2025-06-15") "3d")

# 27.2
(assert-eq "27.2" ((pt-compact :format-age) "2025-06-08" "2025-06-15") "1w")

# 27.3
(assert-eq "27.3" ((pt-compact :format-age) "2025-06-07" "2025-06-15") "1w1d")

# 27.4
(assert-eq "27.4" ((pt-compact :format-age) "2025-01-15" "2025-07-15") "6m")

# 27.5
(assert-eq "27.5" ((pt-compact :format-age) "2023-06-15" "2025-07-15") "2y1m")

# 27.6
(assert-eq "27.6" ((pt-compact :format-age) "2022-06-15" "2025-12-15") "3½y")

# 27.7
(assert-eq "27.7" ((pt-compact :format-age) "2018-06-15" "2025-06-15") "7y")

# 27.8
(assert-eq "27.8" ((pt-compact :format-age) "2025-06-15" "2025-06-15") "Newborn")

# =============================================================================
# Section 29: Locale-specific edge cases - plural rules
# =============================================================================

# --- Hebrew ---
(def he-locale (sa/get-locale "he"))
(def pt-he (sa/make-formatter he-locale))

# 29.1
(assert-eq "29.1" ((pt-he :format-age) "2025-06-15" "2025-06-15") "רק נולד")

# 29.2
(assert-eq "29.2" ((pt-he :format-age) "2025-06-14" "2025-06-15") "יום 1")

# 29.3
(assert-eq "29.3" ((pt-he :format-age) "2025-06-12" "2025-06-15") "3 ימים")

# 29.4
(assert-eq "29.4" ((pt-he :format-age) "2025-06-01" "2025-06-15") "שבועיים")

# 29.5
(assert-eq "29.5" ((pt-he :format-age) "2025-05-25" "2025-06-15") "3 שבועות")

# 29.6
(assert-eq "29.6" ((pt-he :format-age) "2025-01-15" "2025-07-15") "6 חודשים")

# 29.7
(assert-eq "29.7" ((pt-he :format-age) "2025-03-15" "2025-06-15") "3 חודשים")

# 29.8
(assert-eq "29.8" ((pt-he :format-age) "2023-06-15" "2025-07-15") "שנתיים, חודש 1")

# 29.9
(assert-eq "29.9" ((pt-he :format-age) "2022-06-15" "2025-12-15") "3 שנים וחצי")

# 29.10
(assert-eq "29.10" ((pt-he :format-age) "2018-06-15" "2025-06-15") "7 שנים")

# 29.11
(assert-eq "29.11" ((pt-he :format-stage) "2025-06-15" "2025-06-15" "m") "רק נולד")

# 29.12
(assert-eq "29.12" ((pt-he :format-stage) "2025-06-15" "2025-06-15" "f") "רק נולדה")

# 29.13
(assert-eq "29.13" ((pt-he :format-stage) "2007-06-15" "2025-06-15" "m") "מבוגר")

# 29.14
(assert-eq "29.14" ((pt-he :format-stage) "2007-06-15" "2025-06-15" "f") "מבוגרת")

# --- Macedonian ---
(def mk-locale (sa/get-locale "mk"))
(def pt-mk (sa/make-formatter mk-locale))

# 29.15
(assert-eq "29.15" ((pt-mk :format-age) "2025-06-15" "2025-06-15") "Новороденче")

# 29.16
(assert-eq "29.16" ((pt-mk :format-age) "2025-06-14" "2025-06-15") "1 ден")

# 29.17
(assert-eq "29.17" ((pt-mk :format-age) "2025-06-12" "2025-06-15") "3 дена")

# 29.18
(assert-eq "29.18" ((pt-mk :format-age) "2025-01-15" "2025-07-15") "6 месеци")

# 29.19
(assert-eq "29.19" ((pt-mk :format-age) "2023-06-15" "2025-07-15") "2 години, 1 месец")

# 29.20
(assert-eq "29.20" ((pt-mk :format-age) "2022-06-15" "2025-12-15") "3 години и пол")

# 29.21
(assert-eq "29.21" ((pt-mk :format-age) "2018-06-15" "2025-06-15") "7 години")

# --- Swahili ---
(def sw-locale (sa/get-locale "sw"))
(def pt-sw (sa/make-formatter sw-locale))

# 29.22
(assert-eq "29.22" ((pt-sw :format-age) "2025-06-15" "2025-06-15") "Mzaliwa mpya")

# 29.23
(assert-eq "29.23" ((pt-sw :format-age) "2025-06-14" "2025-06-15") "siku 1")

# 29.24
(assert-eq "29.24" ((pt-sw :format-age) "2025-06-12" "2025-06-15") "siku 3")

# 29.25
(assert-eq "29.25" ((pt-sw :format-age) "2025-01-15" "2025-07-15") "miezi 6")

# 29.26
(assert-eq "29.26" ((pt-sw :format-age) "2023-06-15" "2025-07-15") "miaka 2, mwezi 1")

# 29.27
(assert-eq "29.27" ((pt-sw :format-age) "2022-06-15" "2025-12-15") "miaka 3 na nusu")

# --- Indonesian ---
(def id-locale (sa/get-locale "id"))
(def pt-id (sa/make-formatter id-locale))

# 29.28
(assert-eq "29.28" ((pt-id :format-age) "2025-06-15" "2025-06-15") "Baru lahir")

# 29.29
(assert-eq "29.29" ((pt-id :format-age) "2025-06-14" "2025-06-15") "1 hari")

# 29.30
(assert-eq "29.30" ((pt-id :format-age) "2025-06-12" "2025-06-15") "3 hari")

# 29.31
(assert-eq "29.31" ((pt-id :format-age) "2025-01-15" "2025-07-15") "6 bulan")

# 29.32
(assert-eq "29.32" ((pt-id :format-age) "2022-06-15" "2025-12-15") "3 tahun setengah")

# 29.33
(assert-eq "29.33" ((pt-id :format-age) "2018-06-15" "2025-06-15") "7 tahun")

# --- Amharic ---
(def am-locale (sa/get-locale "am"))
(def pt-am (sa/make-formatter am-locale))

# 29.34
(assert-eq "29.34" ((pt-am :format-age) "2025-06-15" "2025-06-15") "አዲስ የተወለደ")

# 29.35
(assert-eq "29.35" ((pt-am :format-age) "2025-06-14" "2025-06-15") "1 ቀን")

# 29.36
(assert-eq "29.36" ((pt-am :format-age) "2025-06-12" "2025-06-15") "3 ቀናት")

# 29.37
(assert-eq "29.37" ((pt-am :format-age) "2025-06-07" "2025-06-15") "1 ሳምንት፣ 1 ቀን")

# 29.38
(assert-eq "29.38" ((pt-am :format-age) "2025-01-15" "2025-07-15") "6 ወራት")

# 29.39
(assert-eq "29.39" ((pt-am :format-age) "2022-06-15" "2025-12-15") "3 ዓመታት ተኩል")

# =============================================================================
# Section 30: Locale lookup by code string
# =============================================================================

# 30.1
(let [loc (sa/get-locale "en")]
  (assert-not-nil "30.1" loc)
  (when loc (assert-eq "30.1-code" (loc :code) "en")))

# 30.2
(let [loc (sa/get-locale "fr")]
  (assert-not-nil "30.2" loc)
  (when loc (assert-eq "30.2-code" (loc :code) "fr")))

# 30.3
(assert-nil "30.3" (sa/get-locale "xx"))

# 30.4
(assert-nil "30.4" (sa/get-locale ""))

# 30.5
(assert-nil "30.5" (sa/get-locale "EN"))

# =============================================================================
# Section 31: Weeks and days across month ends
# =============================================================================

# 31.1
(assert-eq "31.1" (sa/format-age "2016-12-31" "2017-03-29") "12 weeks, 4 days")

# 31.2
(assert-eq "31.2" (sa/format-age "1991-11-27" "1992-02-25") "12 weeks, 6 days")

# 31.3
(assert-eq "31.3" (sa/format-age "2020-11-30" "2021-01-02") "4 weeks, 5 days")

# 31.4
(def pt-compact-31 (sa/make-formatter (sa/get-locale "en") "compact"))
(assert-eq "31.4" ((pt-compact-31 :format-age) "2016-12-31" "2017-03-29") "12w4d")

# =============================================================================
# Section 32: Half years take their plural form from whole years
# =============================================================================

# 32.1
(def pt-pl-32 (sa/make-formatter (sa/get-locale "pl")))
(assert-eq "32.1" ((pt-pl-32 :format-age) "2021-06-15" "2025-01-15") "3 i pół lata")

# 32.2
(def pt-pl-short-32 (sa/make-formatter (sa/get-locale "pl") "short"))
(assert-eq "32.2" ((pt-pl-short-32 :format-age) "2020-06-15" "2025-12-15") "5 i pół lat")

# 32.3
(def pt-shi-32 (sa/make-formatter (sa/get-locale "shi")))
(assert-eq "32.3" ((pt-shi-32 :format-age) "2005-06-08" "2012-06-07") "6 iseggasen d uzgen")

# =============================================================================
# Section 33: Input validation
# =============================================================================

# 33.1
(assert-nil "33.1" (sa/format-age "2025-02-30" "2032-06-25"))

# 33.2
(assert-nil "33.2" (sa/format-age "2025-13-01" "2027-01-31"))

# 33.3
(assert-nil "33.3" (sa/format-age "2023-02-29" "2025-03-01"))

# 33.4
(assert-nil "33.4" (sa/format-age "2025-06-00" "2027-02-25"))

# 33.5
(assert-nil "33.5" (sa/format-age "2025-6-1" "2027-02-25"))

# 33.6
(assert-nil "33.6" (sa/format-age " 2025-06-01" "2027-02-25"))

# 33.7
(assert-nil "33.7" (sa/format-age "2025-06-15T10:00:00" "2027-02-25"))

# 33.8
(assert-nil "33.8" (sa/format-age "2020-01-01" "2025-04-31"))

# 33.9
(assert-nil "33.9" (sa/format-stage "2025-02-30" "2027-09-05"))

# 33.10
(assert-eq "33.10" (sa/format-age "2024-02-29" "2026-03-01") "2 years")

# =============================================================================
# Results
# =============================================================================

(printf "\n%d passed, %d failed, %d total" pass-count fail-count (+ pass-count fail-count))
(when (> fail-count 0)
  (os/exit 1))

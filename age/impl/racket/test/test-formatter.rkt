#lang racket

(require rackunit
         "../format-age.rkt"
         "../locale.rkt"
         "../locales/registry.rkt")

;; Section 1: Null / edge cases
;; 1.1
(check-false (format-age (get-locale "en") #f #f))
;; 1.2 — skipped (undefined not applicable)
;; 1.3
(check-false (format-age (get-locale "en") "" #f))
;; 1.4
(check-false (format-age (get-locale "en") "2025-07-01" "2025-06-15"))
;; 1.5
(check-equal? (format-age (get-locale "en") "1525-06-15" "2025-06-15") "500 years")
;; 1.6
(check-false (format-age (get-locale "en") "1524-06-15" "2025-06-15"))
;; 1.7
(check-false (format-age (get-locale "en") "1025-06-15" "2025-06-15"))
;; Section 2: Days tier (0–6 days)
;; 2.1
(check-equal? (format-age (get-locale "en") "2025-06-15" "2025-06-15") "Newborn")
;; 2.2
(check-equal? (format-age (get-locale "en") "2025-06-14" "2025-06-15") "1 day")
;; 2.3
(check-equal? (format-age (get-locale "en") "2025-06-12" "2025-06-15") "3 days")
;; 2.4
(check-equal? (format-age (get-locale "en") "2025-06-09" "2025-06-15") "6 days")
;; 2.5
(check-equal? (format-age (get-locale "en") "2025-06-08" "2025-06-15") "1 week")
;; Section 3: Weeks+days tier (7 days to <3 calendar months)
;; 3.1
(check-equal? (format-age (get-locale "en") "2025-06-08" "2025-06-15") "1 week")
;; 3.2
(check-equal? (format-age (get-locale "en") "2025-06-07" "2025-06-15") "1 week, 1 day")
;; 3.3
(check-equal? (format-age (get-locale "en") "2025-06-06" "2025-06-15") "1 week, 2 days")
;; 3.4
(check-equal? (format-age (get-locale "en") "2025-06-02" "2025-06-15") "1 week, 6 days")
;; 3.5
(check-equal? (format-age (get-locale "en") "2025-06-01" "2025-06-15") "2 weeks")
;; 3.6
(check-equal? (format-age (get-locale "en") "2025-05-31" "2025-06-15") "2 weeks, 1 day")
;; 3.7
(check-equal? (format-age (get-locale "en") "2025-05-26" "2025-06-15") "2 weeks, 6 days")
;; 3.8
(check-equal? (format-age (get-locale "en") "2025-05-25" "2025-06-15") "3 weeks")
;; 3.9
(check-equal? (format-age (get-locale "en") "2025-05-15" "2025-06-15") "4 weeks, 3 days")
;; 3.10
(check-equal? (format-age (get-locale "en") "2025-04-15" "2025-06-15") "8 weeks, 5 days")
;; 3.11
(check-equal? (format-age (get-locale "en") "2025-03-15" "2025-06-14") "13 weeks")
;; 3.12
(check-equal? (format-age (get-locale "en") "2025-03-15" "2025-06-15") "3 months")
;; Section 4: Month boundaries — standard months
;; 4.1
(check-equal? (format-age (get-locale "en") "2025-01-01" "2025-04-01") "3 months")
;; 4.2
(let ([result (format-age (get-locale "en") "2025-01-01" "2025-03-31")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; 4.3
(check-equal? (format-age (get-locale "en") "2025-06-15" "2025-09-15") "3 months")
;; 4.4
(let ([result (format-age (get-locale "en") "2025-06-15" "2025-09-14")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; 4.5
(check-equal? (format-age (get-locale "en") "2025-06-15" "2025-12-15") "6 months")
;; Section 5: Month boundaries — February non-leap year
;; 5.1
(check-equal? (format-age (get-locale "en") "2025-01-31" "2025-02-28") "4 weeks")
;; 5.2
(check-equal? (format-age (get-locale "en") "2025-01-31" "2025-04-30") "3 months")
;; 5.3
(let ([result (format-age (get-locale "en") "2025-01-31" "2025-04-29")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; 5.4
(check-equal? (format-age (get-locale "en") "2025-02-01" "2025-05-01") "3 months")
;; 5.5
(let ([result (format-age (get-locale "en") "2025-02-01" "2025-04-30")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; Section 6: Month boundaries — February leap year
;; 6.1
(check-equal? (format-age (get-locale "en") "2024-01-31" "2024-02-29") "4 weeks, 1 day")
;; 6.2
(check-equal? (format-age (get-locale "en") "2024-01-31" "2024-02-28") "4 weeks")
;; 6.3
(check-equal? (format-age (get-locale "en") "2024-01-31" "2024-04-30") "3 months")
;; 6.4
(let ([result (format-age (get-locale "en") "2024-01-30" "2024-02-29")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; 6.5
(let ([result (format-age (get-locale "en") "2024-01-30" "2024-02-28")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; Section 7: Month boundaries — 30-day months
;; 7.1
(check-equal? (format-age (get-locale "en") "2025-03-31" "2025-06-30") "3 months")
;; 7.2
(let ([result (format-age (get-locale "en") "2025-03-31" "2025-06-29")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; 7.3
(check-equal? (format-age (get-locale "en") "2025-08-31" "2025-11-30") "3 months")
;; 7.4
(let ([result (format-age (get-locale "en") "2025-08-31" "2025-11-29")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; Section 8: Month boundaries — leap year baby (born Feb 29)
;; 8.1
(check-equal? (format-age (get-locale "en") "2024-02-29" "2024-05-29") "3 months")
;; 8.2
(let ([result (format-age (get-locale "en") "2024-02-29" "2024-05-28")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; 8.3
(check-equal? (format-age (get-locale "en") "2024-02-29" "2025-02-28") "12 months")
;; 8.4
(check-equal? (format-age (get-locale "en") "2024-02-29" "2025-03-01") "12 months")
;; Section 9: Months tier (3–23 months)
;; 9.1
(check-equal? (format-age (get-locale "en") "2025-01-15" "2025-04-15") "3 months")
;; 9.2
(check-equal? (format-age (get-locale "en") "2025-01-15" "2025-07-15") "6 months")
;; 9.3
(check-equal? (format-age (get-locale "en") "2024-06-15" "2025-06-15") "12 months")
;; 9.4
(check-equal? (format-age (get-locale "en") "2024-01-15" "2025-12-15") "23 months")
;; 9.5
(check-equal? (format-age (get-locale "en") "2025-01-15" "2025-07-14") "5 months")
;; 9.6
(check-equal? (format-age (get-locale "en") "2024-11-10" "2025-04-10") "5 months")
;; Section 10: Years+months tier (24–35 months)
;; 10.1
(check-equal? (format-age (get-locale "en") "2023-06-15" "2025-06-15") "2 years")
;; 10.2
(check-equal? (format-age (get-locale "en") "2023-06-15" "2025-07-15") "2 years, 1 month")
;; 10.3
(check-equal? (format-age (get-locale "en") "2023-06-15" "2025-12-15") "2 years, 6 months")
;; 10.4
(check-equal? (format-age (get-locale "en") "2023-06-15" "2026-05-15") "2 years, 11 months")
;; 10.5
(check-equal? (format-age (get-locale "en") "2023-06-15" "2025-06-14") "23 months")
;; Section 11: Half-year tier (3–6 years)
;; 11.1
(check-equal? (format-age (get-locale "en") "2022-06-15" "2025-06-15") "3 years")
;; 11.2
(check-equal? (format-age (get-locale "en") "2022-06-15" "2025-11-15") "3 years")
;; 11.3
(check-equal? (format-age (get-locale "en") "2022-06-15" "2025-12-15") "3½ years")
;; 11.4
(check-equal? (format-age (get-locale "en") "2022-06-15" "2026-05-15") "3½ years")
;; 11.5
(check-equal? (format-age (get-locale "en") "2021-06-15" "2025-06-15") "4 years")
;; 11.6
(check-equal? (format-age (get-locale "en") "2021-06-15" "2025-12-15") "4½ years")
;; 11.7
(check-equal? (format-age (get-locale "en") "2020-06-15" "2025-06-15") "5 years")
;; 11.8
(check-equal? (format-age (get-locale "en") "2020-06-15" "2026-02-15") "5½ years")
;; 11.9
(check-equal? (format-age (get-locale "en") "2019-06-15" "2025-06-15") "6 years")
;; 11.10
(check-equal? (format-age (get-locale "en") "2019-06-15" "2025-12-15") "6½ years")
;; 11.11
(check-equal? (format-age (get-locale "en") "2019-06-15" "2026-05-15") "6½ years")
;; 11.12
(check-equal? (format-age (get-locale "en") "2022-06-15" "2025-06-14") "2 years, 11 months")
;; Section 12: Integer tier (7+ years)
;; 12.1
(check-equal? (format-age (get-locale "en") "2018-06-15" "2025-06-15") "7 years")
;; 12.2
(check-equal? (format-age (get-locale "en") "2018-03-20" "2025-06-15") "7 years")
;; 12.3
(check-equal? (format-age (get-locale "en") "1980-01-01" "2025-06-15") "45 years")
;; Section 13: Cross-year transitions with February
;; 13.1
(check-equal? (format-age (get-locale "en") "2024-12-31" "2025-03-31") "3 months")
;; 13.2
(let ([result (format-age (get-locale "en") "2024-12-31" "2025-03-30")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; 13.3
(check-equal? (format-age (get-locale "en") "2024-11-30" "2025-02-28") "3 months")
;; 13.4
(let ([result (format-age (get-locale "en") "2024-11-30" "2025-02-27")])
  (check-not-false result)
  (check-true (string-contains? result "week") (format "Expected weeks pattern, got: ~a" result)))
;; Section 14: Born-on-31st progression
;; 14.1
(check-equal? (format-age (get-locale "en") "2025-01-31" "2025-04-30") "3 months")
;; 14.2
(check-equal? (format-age (get-locale "en") "2025-01-31" "2025-05-31") "4 months")
;; 14.3
(check-equal? (format-age (get-locale "en") "2025-01-31" "2025-06-30") "5 months")
;; 14.4
(check-equal? (format-age (get-locale "en") "2025-01-31" "2025-07-01") "5 months")
;; 14.5
(check-equal? (format-age (get-locale "en") "2025-01-31" "2025-07-31") "6 months")
;; Section 15: Default asOf (current date)
;; 15.1
(check-equal? (format-age (get-locale "en") "2020-01-01" "2025-06-15") "5 years")
;; 15.2
(check-equal? (format-age (get-locale "en") "2025-06-10" "2025-06-15") "5 days")
;; Section 16: formatStage — null / edge cases
;; 16.1
(check-false (format-stage (get-locale "en") #f #f #:gender ""))
;; 16.2 — skipped (undefined not applicable)
;; 16.3
(check-false (format-stage (get-locale "en") "" #f #:gender ""))
;; 16.4
(check-false (format-stage (get-locale "en") "2025-07-01" "2025-06-15" #:gender ""))
;; 16.5
(check-equal? (format-stage (get-locale "en") "1525-06-15" "2025-06-15" #:gender "") "Adult")
;; 16.6
(check-false (format-stage (get-locale "en") "1524-06-15" "2025-06-15" #:gender ""))
;; Section 17: formatStage — Newborn (0–1 months, <2 calendar months)
;; 17.1
(check-equal? (format-stage (get-locale "en") "2025-06-15" "2025-06-15" #:gender "") "Newborn")
;; 17.2
(check-equal? (format-stage (get-locale "en") "2025-06-14" "2025-06-15" #:gender "") "Newborn")
;; 17.3
(check-equal? (format-stage (get-locale "en") "2025-05-25" "2025-06-15" #:gender "") "Newborn")
;; 17.4
(check-equal? (format-stage (get-locale "en") "2025-05-15" "2025-06-15" #:gender "") "Newborn")
;; 17.5
(check-equal? (format-stage (get-locale "en") "2025-04-16" "2025-06-15" #:gender "") "Newborn")
;; 17.6
(check-equal? (format-stage (get-locale "en") "2025-04-15" "2025-06-15" #:gender "") "Infant")
;; Section 18: formatStage — Infant (2–11 months)
;; 18.1
(check-equal? (format-stage (get-locale "en") "2025-04-15" "2025-06-15" #:gender "") "Infant")
;; 18.2
(check-equal? (format-stage (get-locale "en") "2024-12-15" "2025-06-15" #:gender "") "Infant")
;; 18.3
(check-equal? (format-stage (get-locale "en") "2024-07-15" "2025-06-15" #:gender "") "Infant")
;; 18.4
(check-equal? (format-stage (get-locale "en") "2024-06-15" "2025-06-15" #:gender "") "Toddler")
;; Section 19: formatStage — Toddler (12–35 months)
;; 19.1
(check-equal? (format-stage (get-locale "en") "2024-06-15" "2025-06-15" #:gender "") "Toddler")
;; 19.2
(check-equal? (format-stage (get-locale "en") "2024-01-15" "2025-07-15" #:gender "") "Toddler")
;; 19.3
(check-equal? (format-stage (get-locale "en") "2023-06-15" "2025-06-15" #:gender "") "Toddler")
;; 19.4
(check-equal? (format-stage (get-locale "en") "2023-06-15" "2026-05-15" #:gender "") "Toddler")
;; 19.5
(check-equal? (format-stage (get-locale "en") "2022-06-15" "2025-06-15" #:gender "") "Child")
;; Section 20: formatStage — Child (36–155 months, 3–12 years)
;; 20.1
(check-equal? (format-stage (get-locale "en") "2022-06-15" "2025-06-15" #:gender "") "Child")
;; 20.2
(check-equal? (format-stage (get-locale "en") "2021-06-15" "2025-06-15" #:gender "") "Child")
;; 20.3
(check-equal? (format-stage (get-locale "en") "2019-06-15" "2025-06-15" #:gender "") "Child")
;; 20.4
(check-equal? (format-stage (get-locale "en") "2016-06-15" "2025-06-15" #:gender "") "Child")
;; 20.5
(check-equal? (format-stage (get-locale "en") "2013-06-15" "2026-05-15" #:gender "") "Child")
;; 20.6
(check-equal? (format-stage (get-locale "en") "2012-06-15" "2025-06-15" #:gender "") "Teenager")
;; Section 21: formatStage — Teenager (156–215 months, 13–17 years)
;; 21.1
(check-equal? (format-stage (get-locale "en") "2012-06-15" "2025-06-15" #:gender "") "Teenager")
;; 21.2
(check-equal? (format-stage (get-locale "en") "2010-06-15" "2025-06-15" #:gender "") "Teenager")
;; 21.3
(check-equal? (format-stage (get-locale "en") "2008-06-15" "2026-05-15" #:gender "") "Teenager")
;; 21.4
(check-equal? (format-stage (get-locale "en") "2007-06-15" "2025-06-15" #:gender "") "Adult")
;; Section 22: formatStage — Adult (216+ months, 18+ years)
;; 22.1
(check-equal? (format-stage (get-locale "en") "2007-06-15" "2025-06-15" #:gender "") "Adult")
;; 22.2
(check-equal? (format-stage (get-locale "en") "2000-06-15" "2025-06-15" #:gender "") "Adult")
;; 22.3
(check-equal? (format-stage (get-locale "en") "1980-01-01" "2025-06-15" #:gender "") "Adult")
;; Section 23: formatStage — default asOf
;; 23.1
(check-equal? (format-stage (get-locale "en") "2025-06-15" "2025-06-15" #:gender "") "Newborn")
;; 23.2
(check-equal? (format-stage (get-locale "en") "2020-01-01" "2025-06-15" #:gender "") "Child")
;; 23.3
(check-equal? (format-stage (get-locale "en") "1980-01-01" "2025-06-15" #:gender "") "Adult")
;; Section 24: SayableAge class — English locale delegation
;; 24.1
(check-equal? (format-age (get-locale "en") "2025-06-15" "2025-06-15") "Newborn")
;; 24.2
(check-equal? (format-age (get-locale "en") "2025-06-12" "2025-06-15") "3 days")
;; 24.3
(check-equal? (format-age (get-locale "en") "2025-06-07" "2025-06-15") "1 week, 1 day")
;; 24.4
(check-equal? (format-age (get-locale "en") "2025-01-15" "2025-07-15") "6 months")
;; 24.5
(check-equal? (format-age (get-locale "en") "2023-06-15" "2025-07-15") "2 years, 1 month")
;; 24.6
(check-equal? (format-age (get-locale "en") "2022-06-15" "2025-12-15") "3½ years")
;; 24.7
(check-equal? (format-age (get-locale "en") "2018-06-15" "2025-06-15") "7 years")
;; 24.8
(check-equal? (format-stage (get-locale "en") "2025-06-15" "2025-06-15" #:gender "") "Newborn")
;; 24.9
(check-equal? (format-stage (get-locale "en") "2025-01-15" "2025-06-15" #:gender "") "Infant")
;; 24.10
(check-equal? (format-stage (get-locale "en") "2024-06-15" "2025-06-15" #:gender "") "Toddler")
;; 24.11
(check-equal? (format-stage (get-locale "en") "2022-06-15" "2025-06-15" #:gender "") "Child")
;; 24.12
(check-equal? (format-stage (get-locale "en") "2012-06-15" "2025-06-15" #:gender "") "Teenager")
;; 24.13
(check-equal? (format-stage (get-locale "en") "2007-06-15" "2025-06-15" #:gender "") "Adult")
;; 24.14
(check-false (format-age (get-locale "en") #f "2025-06-15"))
;; 24.15
(check-false (format-stage (get-locale "en") #f "2025-06-15" #:gender ""))
;; Section 25: i18n — locale with all plural features
;; 25.1
(check-equal? (format-age (get-locale "es") "2025-06-15" "2025-06-15") "Recién nacido")
;; 25.2
(check-equal? (format-age (get-locale "es") "2025-06-14" "2025-06-15") "1 día")
;; 25.3
(check-equal? (format-age (get-locale "es") "2025-06-12" "2025-06-15") "3 días")
;; 25.4
(check-equal? (format-age (get-locale "es") "2025-06-08" "2025-06-15") "1 semana")
;; 25.5
(check-equal? (format-age (get-locale "es") "2025-06-07" "2025-06-15") "1 semana, 1 día")
;; 25.6
(check-equal? (format-age (get-locale "es") "2025-05-26" "2025-06-15") "2 semanas, 6 días")
;; 25.7
(check-equal? (format-age (get-locale "es") "2025-01-15" "2025-07-15") "6 meses")
;; 25.8
(check-equal? (format-age (get-locale "es") "2023-06-15" "2025-07-15") "2 años, 1 mes")
;; 25.9
(check-equal? (format-age (get-locale "es") "2023-06-15" "2025-12-15") "2 años, 6 meses")
;; 25.10
(check-equal? (format-age (get-locale "es") "2022-06-15" "2025-12-15") "3 años y medio")
;; 25.11
(check-equal? (format-age (get-locale "es") "2022-06-15" "2025-06-15") "3 años")
;; 25.12
(check-equal? (format-age (get-locale "es") "2018-06-15" "2025-06-15") "7 años")
;; 25.13
(check-equal? (format-stage (get-locale "es") "2025-06-15" "2025-06-15" #:gender "") "Recién nacido")
;; 25.14
(check-equal? (format-stage (get-locale "es") "2025-01-15" "2025-06-15" #:gender "") "Bebé")
;; 25.15
(check-equal? (format-stage (get-locale "es") "2024-06-15" "2025-06-15" #:gender "") "Niño pequeño")
;; 25.16
(check-equal? (format-stage (get-locale "es") "2022-06-15" "2025-06-15" #:gender "") "Niño")
;; 25.17
(check-equal? (format-stage (get-locale "es") "2012-06-15" "2025-06-15" #:gender "") "Adolescente")
;; 25.18
(check-equal? (format-stage (get-locale "es") "2007-06-15" "2025-06-15" #:gender "") "Adulto")
;; 25.19
(check-false (format-age (get-locale "es") #f "2025-06-15"))
;; 25.20
(check-false (format-stage (get-locale "es") #f "2025-06-15" #:gender ""))
;; Section 26: Compactness — short
;; 26.1
(check-equal? (format-age (get-locale "en") "2025-06-12" "2025-06-15" #:compactness 'short) "3 d")
;; 26.2
(check-equal? (format-age (get-locale "en") "2025-06-08" "2025-06-15" #:compactness 'short) "1 wk")
;; 26.3
(check-equal? (format-age (get-locale "en") "2025-06-07" "2025-06-15" #:compactness 'short) "1 wk, 1 d")
;; 26.4
(check-equal? (format-age (get-locale "en") "2025-01-15" "2025-07-15" #:compactness 'short) "6 mo")
;; 26.5
(check-equal? (format-age (get-locale "en") "2023-06-15" "2025-07-15" #:compactness 'short) "2 yr, 1 mo")
;; 26.6
(check-equal? (format-age (get-locale "en") "2022-06-15" "2025-12-15" #:compactness 'short) "3½ yr")
;; 26.7
(check-equal? (format-age (get-locale "en") "2018-06-15" "2025-06-15" #:compactness 'short) "7 yr")
;; 26.8
(check-equal? (format-age (get-locale "en") "2025-06-15" "2025-06-15" #:compactness 'short) "Newborn")
;; 26.9
(check-equal? (format-stage (get-locale "en") "2025-01-15" "2025-06-15" #:gender "" #:compactness 'short) "Infant")
;; Section 27: Compactness — compact
;; 27.1
(check-equal? (format-age (get-locale "en") "2025-06-12" "2025-06-15" #:compactness 'compact) "3d")
;; 27.2
(check-equal? (format-age (get-locale "en") "2025-06-08" "2025-06-15" #:compactness 'compact) "1w")
;; 27.3
(check-equal? (format-age (get-locale "en") "2025-06-07" "2025-06-15" #:compactness 'compact) "1w1d")
;; 27.4
(check-equal? (format-age (get-locale "en") "2025-01-15" "2025-07-15" #:compactness 'compact) "6m")
;; 27.5
(check-equal? (format-age (get-locale "en") "2023-06-15" "2025-07-15" #:compactness 'compact) "2y1m")
;; 27.6
(check-equal? (format-age (get-locale "en") "2022-06-15" "2025-12-15" #:compactness 'compact) "3½y")
;; 27.7
(check-equal? (format-age (get-locale "en") "2018-06-15" "2025-06-15" #:compactness 'compact) "7y")
;; 27.8
(check-equal? (format-age (get-locale "en") "2025-06-15" "2025-06-15" #:compactness 'compact) "Newborn")
;; Section 29: Locale-specific edge cases — plural rules
;; 29.1
(check-equal? (format-age (get-locale "he") "2025-06-15" "2025-06-15") "רק נולד")
;; 29.2
(check-equal? (format-age (get-locale "he") "2025-06-14" "2025-06-15") "יום")
;; 29.3
(check-equal? (format-age (get-locale "he") "2025-06-12" "2025-06-15") "3 ימים")
;; 29.4
(check-equal? (format-age (get-locale "he") "2025-06-01" "2025-06-15") "שבועיים")
;; 29.5
(check-equal? (format-age (get-locale "he") "2025-05-25" "2025-06-15") "3 שבועות")
;; 29.6
(check-equal? (format-age (get-locale "he") "2025-01-15" "2025-07-15") "6 חודשים")
;; 29.7
(check-equal? (format-age (get-locale "he") "2025-03-15" "2025-06-15") "3 חודשים")
;; 29.8
(check-equal? (format-age (get-locale "he") "2023-06-15" "2025-07-15") "שנתיים, חודש")
;; 29.9
(check-equal? (format-age (get-locale "he") "2022-06-15" "2025-12-15") "3 שנים וחצי")
;; 29.10
(check-equal? (format-age (get-locale "he") "2018-06-15" "2025-06-15") "7 שנים")
;; 29.11
(check-equal? (format-stage (get-locale "he") "2025-06-15" "2025-06-15" #:gender "m") "רק נולד")
;; 29.12
(check-equal? (format-stage (get-locale "he") "2025-06-15" "2025-06-15" #:gender "f") "רק נולדה")
;; 29.13
(check-equal? (format-stage (get-locale "he") "2007-06-15" "2025-06-15" #:gender "m") "מבוגר")
;; 29.14
(check-equal? (format-stage (get-locale "he") "2007-06-15" "2025-06-15" #:gender "f") "מבוגרת")
;; 29.15
(check-equal? (format-age (get-locale "mk") "2025-06-15" "2025-06-15") "Новороденче")
;; 29.16
(check-equal? (format-age (get-locale "mk") "2025-06-14" "2025-06-15") "1 ден")
;; 29.17
(check-equal? (format-age (get-locale "mk") "2025-06-12" "2025-06-15") "3 дена")
;; 29.18
(check-equal? (format-age (get-locale "mk") "2025-01-15" "2025-07-15") "6 месеци")
;; 29.19
(check-equal? (format-age (get-locale "mk") "2023-06-15" "2025-07-15") "2 години, 1 месец")
;; 29.20
(check-equal? (format-age (get-locale "mk") "2022-06-15" "2025-12-15") "3 години и пол")
;; 29.21
(check-equal? (format-age (get-locale "mk") "2018-06-15" "2025-06-15") "7 години")
;; 29.22
(check-equal? (format-age (get-locale "sw") "2025-06-15" "2025-06-15") "Mzaliwa mpya")
;; 29.23
(check-equal? (format-age (get-locale "sw") "2025-06-14" "2025-06-15") "siku 1")
;; 29.24
(check-equal? (format-age (get-locale "sw") "2025-06-12" "2025-06-15") "siku 3")
;; 29.25
(check-equal? (format-age (get-locale "sw") "2025-01-15" "2025-07-15") "miezi 6")
;; 29.26
(check-equal? (format-age (get-locale "sw") "2023-06-15" "2025-07-15") "miaka 2, mwezi 1")
;; 29.27
(check-equal? (format-age (get-locale "sw") "2022-06-15" "2025-12-15") "miaka 3 na nusu")
;; 29.28
(check-equal? (format-age (get-locale "id") "2025-06-15" "2025-06-15") "Baru lahir")
;; 29.29
(check-equal? (format-age (get-locale "id") "2025-06-14" "2025-06-15") "1 hari")
;; 29.30
(check-equal? (format-age (get-locale "id") "2025-06-12" "2025-06-15") "3 hari")
;; 29.31
(check-equal? (format-age (get-locale "id") "2025-01-15" "2025-07-15") "6 bulan")
;; 29.32
(check-equal? (format-age (get-locale "id") "2022-06-15" "2025-12-15") "3 setengah tahun")
;; 29.33
(check-equal? (format-age (get-locale "id") "2018-06-15" "2025-06-15") "7 tahun")
;; 29.34
(check-equal? (format-age (get-locale "am") "2025-06-15" "2025-06-15") "አዲስ የተወለደ")
;; 29.35
(check-equal? (format-age (get-locale "am") "2025-06-14" "2025-06-15") "1 ቀን")
;; 29.36
(check-equal? (format-age (get-locale "am") "2025-06-12" "2025-06-15") "3 ቀናት")
;; 29.37
(check-equal? (format-age (get-locale "am") "2025-06-07" "2025-06-15") "1 ሳምንት፣ 1 ቀን")
;; 29.38
(check-equal? (format-age (get-locale "am") "2025-01-15" "2025-07-15") "6 ወራት")
;; 29.39
(check-equal? (format-age (get-locale "am") "2022-06-15" "2025-12-15") "3 ዓመታት ተኩል")
;; Section 30: Locale lookup by code string
;; 30.1
(let ([loc (get-locale "en")])
  (check-not-false loc)
  (check-equal? (age-locale-code loc) "en"))
;; 30.2
(let ([loc (get-locale "fr")])
  (check-not-false loc)
  (check-equal? (age-locale-code loc) "fr"))
;; 30.3
(check-false (get-locale "xx"))
;; 30.4
(check-false (get-locale ""))
;; 30.5
(check-false (get-locale "EN"))

;; Section 31: Weeks and days across month ends
;; 31.1
(check-equal? (format-age (get-locale "en") "2016-12-31" "2017-03-29") "12 weeks, 4 days")
;; 31.2
(check-equal? (format-age (get-locale "en") "1991-11-27" "1992-02-25") "12 weeks, 6 days")
;; 31.3
(check-equal? (format-age (get-locale "en") "2020-11-30" "2021-01-02") "4 weeks, 5 days")
;; 31.4
(check-equal? (format-age (get-locale "en") "2016-12-31" "2017-03-29" #:compactness 'compact) "12w4d")
;; Section 32: Half years take their plural form from whole years
;; 32.1
(check-equal? (format-age (get-locale "pl") "2021-06-15" "2025-01-15") "3 i pół lata")
;; 32.2
(check-equal? (format-age (get-locale "pl") "2020-06-15" "2025-12-15" #:compactness 'short) "5 i pół lat")
;; 32.3
(check-equal? (format-age (get-locale "shi") "2005-06-08" "2012-06-07") "6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ")
;; Section 33: Input validation
;; 33.1
(check-false (format-age (get-locale "en") "2025-02-30" "2032-06-25"))
;; 33.2
(check-false (format-age (get-locale "en") "2025-13-01" "2027-01-31"))
;; 33.3
(check-false (format-age (get-locale "en") "2023-02-29" "2025-03-01"))
;; 33.4
(check-false (format-age (get-locale "en") "2025-06-00" "2027-02-25"))
;; 33.5
(check-false (format-age (get-locale "en") "2025-6-1" "2027-02-25"))
;; 33.6
(check-false (format-age (get-locale "en") " 2025-06-01" "2027-02-25"))
;; 33.7
(check-false (format-age (get-locale "en") "2025-06-15T10:00:00" "2027-02-25"))
;; 33.8
(check-false (format-age (get-locale "en") "2020-01-01" "2025-04-31"))
;; 33.9
(check-false (format-stage (get-locale "en") "2025-02-30" "2027-09-05"))
;; 33.10
(check-equal? (format-age (get-locale "en") "2024-02-29" "2026-03-01") "2 years")

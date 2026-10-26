(ns sayableage.core-test
  (:require [clojure.test :refer [deftest is testing]]
            [sayableage.core :as pt]
            [sayableage.locales.en :as en]
            [sayableage.locales.es :as es]
            [sayableage.locales.he :as he]
            [sayableage.locales.mk :as mk]
            [sayableage.locales.sw :as sw]
            [sayableage.locales.id :as id]
            [sayableage.locales.am :as am]))

;; Helpers
(defn- age [dob as-of] (pt/format-age-pure en/locale :normal dob as-of))
(defn- age-short [dob as-of] (pt/format-age-pure en/locale :short dob as-of))
(defn- age-compact [dob as-of] (pt/format-age-pure en/locale :compact dob as-of))
(defn- age-locale [locale dob as-of] (pt/format-age-pure locale :normal dob as-of))
(defn- stage [dob as-of] (pt/format-stage-pure en/locale dob as-of nil))
(defn- stage-locale [locale dob as-of gender] (pt/format-stage-pure locale dob as-of gender))

(defn- contains-week? [result]
  (and (some? result) (clojure.string/includes? result "week")))

;; 1. Null / edge cases
(deftest null-edge-cases
  (testing "1.1/1.3 empty dateOfBirth"
    (is (nil? (age "" "2025-06-15"))))
  (testing "1.2 nil dateOfBirth"
    (is (nil? (age "" "2025-06-15"))))
  (testing "1.4 future dateOfBirth"
    (is (nil? (age "2025-07-01" "2025-06-15"))))
  (testing "1.5 500 years"
    (is (= "500 years" (age "1525-06-15" "2025-06-15"))))
  (testing "1.6 501 years"
    (is (nil? (age "1524-06-15" "2025-06-15"))))
  (testing "1.7 1000 years"
    (is (nil? (age "1025-06-15" "2025-06-15")))))

;; 2. Days tier (0-6 days)
(deftest days-tier
  (testing "2.1 newborn"
    (is (= "Newborn" (age "2025-06-15" "2025-06-15"))))
  (testing "2.2 1 day"
    (is (= "1 day" (age "2025-06-14" "2025-06-15"))))
  (testing "2.3 3 days"
    (is (= "3 days" (age "2025-06-12" "2025-06-15"))))
  (testing "2.4 6 days"
    (is (= "6 days" (age "2025-06-09" "2025-06-15"))))
  (testing "2.5 7 days -> 1 week"
    (is (= "1 week" (age "2025-06-08" "2025-06-15")))))

;; 3. Weeks+days tier
(deftest weeks-days-tier
  (testing "3.1 1 week"
    (is (= "1 week" (age "2025-06-08" "2025-06-15"))))
  (testing "3.2 1 week, 1 day"
    (is (= "1 week, 1 day" (age "2025-06-07" "2025-06-15"))))
  (testing "3.3 1 week, 2 days"
    (is (= "1 week, 2 days" (age "2025-06-06" "2025-06-15"))))
  (testing "3.4 1 week, 6 days"
    (is (= "1 week, 6 days" (age "2025-06-02" "2025-06-15"))))
  (testing "3.5 2 weeks"
    (is (= "2 weeks" (age "2025-06-01" "2025-06-15"))))
  (testing "3.6 2 weeks, 1 day"
    (is (= "2 weeks, 1 day" (age "2025-05-31" "2025-06-15"))))
  (testing "3.7 2 weeks, 6 days"
    (is (= "2 weeks, 6 days" (age "2025-05-26" "2025-06-15"))))
  (testing "3.8 3 weeks"
    (is (= "3 weeks" (age "2025-05-25" "2025-06-15"))))
  (testing "3.9 4 weeks, 3 days"
    (is (= "4 weeks, 3 days" (age "2025-05-15" "2025-06-15"))))
  (testing "3.10 8 weeks, 5 days"
    (is (= "8 weeks, 5 days" (age "2025-04-15" "2025-06-15"))))
  (testing "3.11 13 weeks"
    (is (= "13 weeks" (age "2025-03-15" "2025-06-14"))))
  (testing "3.12 exactly 3 months"
    (is (= "3 months" (age "2025-03-15" "2025-06-15")))))

;; 4. Month boundaries - standard months
(deftest month-boundaries-standard
  (testing "4.1 exactly 3 months"
    (is (= "3 months" (age "2025-01-01" "2025-04-01"))))
  (testing "4.2 one day short of 3 months"
    (is (contains-week? (age "2025-01-01" "2025-03-31"))))
  (testing "4.3 exactly 3 months mid-month"
    (is (= "3 months" (age "2025-06-15" "2025-09-15"))))
  (testing "4.4 one day short"
    (is (contains-week? (age "2025-06-15" "2025-09-14"))))
  (testing "4.5 6 months"
    (is (= "6 months" (age "2025-06-15" "2025-12-15")))))

;; 5. Month boundaries - Feb non-leap
(deftest month-boundaries-feb-nonleap
  (testing "5.1 Jan 31 -> Feb 28"
    (is (= "4 weeks" (age "2025-01-31" "2025-02-28"))))
  (testing "5.2 Jan 31 -> Apr 30"
    (is (= "3 months" (age "2025-01-31" "2025-04-30"))))
  (testing "5.3 Jan 31 -> Apr 29"
    (is (contains-week? (age "2025-01-31" "2025-04-29"))))
  (testing "5.4 Feb 1 -> May 1"
    (is (= "3 months" (age "2025-02-01" "2025-05-01"))))
  (testing "5.5 Feb 1 -> Apr 30"
    (is (contains-week? (age "2025-02-01" "2025-04-30")))))

;; 6. Month boundaries - Feb leap year
(deftest month-boundaries-feb-leap
  (testing "6.1 Jan 31 -> Feb 29"
    (is (= "4 weeks, 1 day" (age "2024-01-31" "2024-02-29"))))
  (testing "6.2 Jan 31 -> Feb 28"
    (is (= "4 weeks" (age "2024-01-31" "2024-02-28"))))
  (testing "6.3 Jan 31 -> Apr 30"
    (is (= "3 months" (age "2024-01-31" "2024-04-30"))))
  (testing "6.4 Jan 30 -> Feb 29"
    (is (contains-week? (age "2024-01-30" "2024-02-29"))))
  (testing "6.5 Jan 30 -> Feb 28"
    (is (contains-week? (age "2024-01-30" "2024-02-28")))))

;; 7. Month boundaries - 30-day months
(deftest month-boundaries-30day
  (testing "7.1 Mar 31 -> Jun 30"
    (is (= "3 months" (age "2025-03-31" "2025-06-30"))))
  (testing "7.2 Mar 31 -> Jun 29"
    (is (contains-week? (age "2025-03-31" "2025-06-29"))))
  (testing "7.3 Aug 31 -> Nov 30"
    (is (= "3 months" (age "2025-08-31" "2025-11-30"))))
  (testing "7.4 Aug 31 -> Nov 29"
    (is (contains-week? (age "2025-08-31" "2025-11-29")))))

;; 8. Leap year baby
(deftest leap-year-baby
  (testing "8.1 Feb 29 -> May 29"
    (is (= "3 months" (age "2024-02-29" "2024-05-29"))))
  (testing "8.2 Feb 29 -> May 28"
    (is (contains-week? (age "2024-02-29" "2024-05-28"))))
  (testing "8.3 Feb 29 -> Feb 28 next year"
    (is (= "12 months" (age "2024-02-29" "2025-02-28"))))
  (testing "8.4 Feb 29 -> Mar 1 next year"
    (is (= "12 months" (age "2024-02-29" "2025-03-01")))))

;; 9. Months tier (3-23 months)
(deftest months-tier
  (testing "9.1 3 months"
    (is (= "3 months" (age "2025-01-15" "2025-04-15"))))
  (testing "9.2 6 months"
    (is (= "6 months" (age "2025-01-15" "2025-07-15"))))
  (testing "9.3 12 months"
    (is (= "12 months" (age "2024-06-15" "2025-06-15"))))
  (testing "9.4 23 months"
    (is (= "23 months" (age "2024-01-15" "2025-12-15"))))
  (testing "9.5 5 months (one day short of 6)"
    (is (= "5 months" (age "2025-01-15" "2025-07-14"))))
  (testing "9.6 5 months exact"
    (is (= "5 months" (age "2024-11-10" "2025-04-10")))))

;; 10. Years+months tier (24-35 months)
(deftest years-months-tier
  (testing "10.1 exactly 2 years"
    (is (= "2 years" (age "2023-06-15" "2025-06-15"))))
  (testing "10.2 2 years, 1 month"
    (is (= "2 years, 1 month" (age "2023-06-15" "2025-07-15"))))
  (testing "10.3 2 years, 6 months"
    (is (= "2 years, 6 months" (age "2023-06-15" "2025-12-15"))))
  (testing "10.4 2 years, 11 months"
    (is (= "2 years, 11 months" (age "2023-06-15" "2026-05-15"))))
  (testing "10.5 one day short of 2 years"
    (is (= "23 months" (age "2023-06-15" "2025-06-14")))))

;; 11. Half-year tier (3-6 years)
(deftest half-year-tier
  (testing "11.1 exactly 3 years"
    (is (= "3 years" (age "2022-06-15" "2025-06-15"))))
  (testing "11.2 3 years, 5 months"
    (is (= "3 years" (age "2022-06-15" "2025-11-15"))))
  (testing "11.3 3.5 years"
    (is (= "3½ years" (age "2022-06-15" "2025-12-15"))))
  (testing "11.4 3.5 years (11 months)"
    (is (= "3½ years" (age "2022-06-15" "2026-05-15"))))
  (testing "11.5 4 years"
    (is (= "4 years" (age "2021-06-15" "2025-06-15"))))
  (testing "11.6 4.5 years"
    (is (= "4½ years" (age "2021-06-15" "2025-12-15"))))
  (testing "11.7 5 years"
    (is (= "5 years" (age "2020-06-15" "2025-06-15"))))
  (testing "11.8 5.5 years"
    (is (= "5½ years" (age "2020-06-15" "2026-02-15"))))
  (testing "11.9 6 years"
    (is (= "6 years" (age "2019-06-15" "2025-06-15"))))
  (testing "11.10 6.5 years"
    (is (= "6½ years" (age "2019-06-15" "2025-12-15"))))
  (testing "11.11 6 years, 11 months"
    (is (= "6½ years" (age "2019-06-15" "2026-05-15"))))
  (testing "11.12 one day short of 3 years"
    (is (= "2 years, 11 months" (age "2022-06-15" "2025-06-14")))))

;; 12. Integer tier (7+ years)
(deftest integer-tier
  (testing "12.1 exactly 7 years"
    (is (= "7 years" (age "2018-06-15" "2025-06-15"))))
  (testing "12.2 7 years (mid-year)"
    (is (= "7 years" (age "2018-03-20" "2025-06-15"))))
  (testing "12.3 45 years"
    (is (= "45 years" (age "1980-01-01" "2025-06-15")))))

;; 13. Cross-year transitions with February
(deftest cross-year-feb
  (testing "13.1 Dec 31 -> Mar 31"
    (is (= "3 months" (age "2024-12-31" "2025-03-31"))))
  (testing "13.2 Dec 31 -> Mar 30"
    (is (contains-week? (age "2024-12-31" "2025-03-30"))))
  (testing "13.3 Nov 30 -> Feb 28"
    (is (= "3 months" (age "2024-11-30" "2025-02-28"))))
  (testing "13.4 Nov 30 -> Feb 27"
    (is (contains-week? (age "2024-11-30" "2025-02-27")))))

;; 14. Born-on-31st progression
(deftest born-on-31st
  (testing "14.1 Jan 31 -> Apr 30"
    (is (= "3 months" (age "2025-01-31" "2025-04-30"))))
  (testing "14.2 Jan 31 -> May 31"
    (is (= "4 months" (age "2025-01-31" "2025-05-31"))))
  (testing "14.3 Jan 31 -> Jun 30"
    (is (= "5 months" (age "2025-01-31" "2025-06-30"))))
  (testing "14.4 Jan 31 -> Jul 1"
    (is (= "5 months" (age "2025-01-31" "2025-07-01"))))
  (testing "14.5 Jan 31 -> Jul 31"
    (is (= "6 months" (age "2025-01-31" "2025-07-31")))))

;; 15. Default asOf — skipped (test only pure variants)

;; 16. formatStage - null / edge cases
(deftest stage-null-edge
  (testing "16.1/16.2/16.3 empty dob"
    (is (nil? (stage "" "2025-06-15"))))
  (testing "16.4 future dob"
    (is (nil? (stage "2025-07-01" "2025-06-15"))))
  (testing "16.5 500 years"
    (is (= "Adult" (stage "1525-06-15" "2025-06-15"))))
  (testing "16.6 501 years"
    (is (nil? (stage "1524-06-15" "2025-06-15")))))

;; 17. formatStage - Newborn
(deftest stage-newborn
  (testing "17.1 same day"
    (is (= "Newborn" (stage "2025-06-15" "2025-06-15"))))
  (testing "17.2 1 day"
    (is (= "Newborn" (stage "2025-06-14" "2025-06-15"))))
  (testing "17.3 3 weeks"
    (is (= "Newborn" (stage "2025-05-25" "2025-06-15"))))
  (testing "17.4 1 month"
    (is (= "Newborn" (stage "2025-05-15" "2025-06-15"))))
  (testing "17.5 almost 2 months"
    (is (= "Newborn" (stage "2025-04-16" "2025-06-15"))))
  (testing "17.6 exactly 2 months"
    (is (= "Infant" (stage "2025-04-15" "2025-06-15")))))

;; 18. formatStage - Infant
(deftest stage-infant
  (testing "18.1 2 months"
    (is (= "Infant" (stage "2025-04-15" "2025-06-15"))))
  (testing "18.2 6 months"
    (is (= "Infant" (stage "2024-12-15" "2025-06-15"))))
  (testing "18.3 11 months"
    (is (= "Infant" (stage "2024-07-15" "2025-06-15"))))
  (testing "18.4 12 months"
    (is (= "Toddler" (stage "2024-06-15" "2025-06-15")))))

;; 19. formatStage - Toddler
(deftest stage-toddler
  (testing "19.1 12 months"
    (is (= "Toddler" (stage "2024-06-15" "2025-06-15"))))
  (testing "19.2 18 months"
    (is (= "Toddler" (stage "2024-01-15" "2025-07-15"))))
  (testing "19.3 24 months"
    (is (= "Toddler" (stage "2023-06-15" "2025-06-15"))))
  (testing "19.4 35 months"
    (is (= "Toddler" (stage "2023-06-15" "2026-05-15"))))
  (testing "19.5 36 months"
    (is (= "Child" (stage "2022-06-15" "2025-06-15")))))

;; 20. formatStage - Child
(deftest stage-child
  (testing "20.1 3 years"
    (is (= "Child" (stage "2022-06-15" "2025-06-15"))))
  (testing "20.2 4 years"
    (is (= "Child" (stage "2021-06-15" "2025-06-15"))))
  (testing "20.3 6 years"
    (is (= "Child" (stage "2019-06-15" "2025-06-15"))))
  (testing "20.4 9 years"
    (is (= "Child" (stage "2016-06-15" "2025-06-15"))))
  (testing "20.5 12 years, 11 months"
    (is (= "Child" (stage "2013-06-15" "2026-05-15"))))
  (testing "20.6 13 years"
    (is (= "Teenager" (stage "2012-06-15" "2025-06-15")))))

;; 21. formatStage - Teenager
(deftest stage-teenager
  (testing "21.1 13 years"
    (is (= "Teenager" (stage "2012-06-15" "2025-06-15"))))
  (testing "21.2 15 years"
    (is (= "Teenager" (stage "2010-06-15" "2025-06-15"))))
  (testing "21.3 17 years, 11 months"
    (is (= "Teenager" (stage "2008-06-15" "2026-05-15"))))
  (testing "21.4 18 years"
    (is (= "Adult" (stage "2007-06-15" "2025-06-15")))))

;; 22. formatStage - Adult
(deftest stage-adult
  (testing "22.1 18 years"
    (is (= "Adult" (stage "2007-06-15" "2025-06-15"))))
  (testing "22.2 25 years"
    (is (= "Adult" (stage "2000-06-15" "2025-06-15"))))
  (testing "22.3 45 years"
    (is (= "Adult" (stage "1980-01-01" "2025-06-15")))))

;; 23. formatStage — default asOf — skipped (test only pure variants)

;; 24. Class delegation — English locale
(deftest class-delegation
  (testing "24.1 Newborn"
    (is (= "Newborn" (pt/format-age-pure en/locale :normal "2025-06-15" "2025-06-15"))))
  (testing "24.2 3 days"
    (is (= "3 days" (pt/format-age-pure en/locale :normal "2025-06-12" "2025-06-15"))))
  (testing "24.3 1 week, 1 day"
    (is (= "1 week, 1 day" (pt/format-age-pure en/locale :normal "2025-06-07" "2025-06-15"))))
  (testing "24.4 6 months"
    (is (= "6 months" (pt/format-age-pure en/locale :normal "2025-01-15" "2025-07-15"))))
  (testing "24.5 2 years, 1 month"
    (is (= "2 years, 1 month" (pt/format-age-pure en/locale :normal "2023-06-15" "2025-07-15"))))
  (testing "24.6 3.5 years"
    (is (= "3½ years" (pt/format-age-pure en/locale :normal "2022-06-15" "2025-12-15"))))
  (testing "24.7 7 years"
    (is (= "7 years" (pt/format-age-pure en/locale :normal "2018-06-15" "2025-06-15"))))
  (testing "24.8 stage Newborn"
    (is (= "Newborn" (pt/format-stage-pure en/locale "2025-06-15" "2025-06-15" nil))))
  (testing "24.9 stage Infant"
    (is (= "Infant" (pt/format-stage-pure en/locale "2025-01-15" "2025-06-15" nil))))
  (testing "24.10 stage Toddler"
    (is (= "Toddler" (pt/format-stage-pure en/locale "2024-06-15" "2025-06-15" nil))))
  (testing "24.11 stage Child"
    (is (= "Child" (pt/format-stage-pure en/locale "2022-06-15" "2025-06-15" nil))))
  (testing "24.12 stage Teenager"
    (is (= "Teenager" (pt/format-stage-pure en/locale "2012-06-15" "2025-06-15" nil))))
  (testing "24.13 stage Adult"
    (is (= "Adult" (pt/format-stage-pure en/locale "2007-06-15" "2025-06-15" nil))))
  (testing "24.14 format-age nil on empty"
    (is (nil? (pt/format-age-pure en/locale :normal "" "2025-06-15"))))
  (testing "24.15 format-stage nil on empty"
    (is (nil? (pt/format-stage-pure en/locale "" "2025-06-15" nil)))))

;; 25. i18n — Spanish locale
(deftest i18n-spanish
  (testing "25.1 Newborn"
    (is (= "Recién nacido" (age-locale es/locale "2025-06-15" "2025-06-15"))))
  (testing "25.2 1 day"
    (is (= "1 día" (age-locale es/locale "2025-06-14" "2025-06-15"))))
  (testing "25.3 3 days"
    (is (= "3 días" (age-locale es/locale "2025-06-12" "2025-06-15"))))
  (testing "25.4 1 week"
    (is (= "1 semana" (age-locale es/locale "2025-06-08" "2025-06-15"))))
  (testing "25.5 1 week, 1 day"
    (is (= "1 semana, 1 día" (age-locale es/locale "2025-06-07" "2025-06-15"))))
  (testing "25.6 2 weeks, 6 days"
    (is (= "2 semanas, 6 días" (age-locale es/locale "2025-05-26" "2025-06-15"))))
  (testing "25.7 6 months"
    (is (= "6 meses" (age-locale es/locale "2025-01-15" "2025-07-15"))))
  (testing "25.8 2 years, 1 month"
    (is (= "2 años, 1 mes" (age-locale es/locale "2023-06-15" "2025-07-15"))))
  (testing "25.9 2 years, 6 months"
    (is (= "2 años, 6 meses" (age-locale es/locale "2023-06-15" "2025-12-15"))))
  (testing "25.10 3.5 years"
    (is (= "3 y medio años" (age-locale es/locale "2022-06-15" "2025-12-15"))))
  (testing "25.11 3 years"
    (is (= "3 años" (age-locale es/locale "2022-06-15" "2025-06-15"))))
  (testing "25.12 7 years"
    (is (= "7 años" (age-locale es/locale "2018-06-15" "2025-06-15"))))
  (testing "25.13 stage Newborn"
    (is (= "Recién nacido" (stage-locale es/locale "2025-06-15" "2025-06-15" nil))))
  (testing "25.14 stage Infant"
    (is (= "Bebé" (stage-locale es/locale "2025-01-15" "2025-06-15" nil))))
  (testing "25.15 stage Toddler"
    (is (= "Niño pequeño" (stage-locale es/locale "2024-06-15" "2025-06-15" nil))))
  (testing "25.16 stage Child"
    (is (= "Niño" (stage-locale es/locale "2022-06-15" "2025-06-15" nil))))
  (testing "25.17 stage Teenager"
    (is (= "Adolescente" (stage-locale es/locale "2012-06-15" "2025-06-15" nil))))
  (testing "25.18 stage Adult"
    (is (= "Adulto" (stage-locale es/locale "2007-06-15" "2025-06-15" nil))))
  (testing "25.19 error on empty"
    (is (nil? (age-locale es/locale "" "2025-06-15"))))
  (testing "25.20 stage error on empty"
    (is (nil? (stage-locale es/locale "" "2025-06-15" nil)))))

;; 26. Compactness - short
(deftest compactness-short
  (testing "26.1 3 d"
    (is (= "3 d" (age-short "2025-06-12" "2025-06-15"))))
  (testing "26.2 1 wk"
    (is (= "1 wk" (age-short "2025-06-08" "2025-06-15"))))
  (testing "26.3 1 wk, 1 d"
    (is (= "1 wk, 1 d" (age-short "2025-06-07" "2025-06-15"))))
  (testing "26.4 6 mo"
    (is (= "6 mo" (age-short "2025-01-15" "2025-07-15"))))
  (testing "26.5 2 yr, 1 mo"
    (is (= "2 yr, 1 mo" (age-short "2023-06-15" "2025-07-15"))))
  (testing "26.6 3.5 yr"
    (is (= "3½ yr" (age-short "2022-06-15" "2025-12-15"))))
  (testing "26.7 7 yr"
    (is (= "7 yr" (age-short "2018-06-15" "2025-06-15"))))
  (testing "26.8 Newborn"
    (is (= "Newborn" (age-short "2025-06-15" "2025-06-15"))))
  (testing "26.9 stage unaffected"
    (is (= "Infant" (stage "2025-01-15" "2025-06-15")))))

;; 27. Compactness - compact
(deftest compactness-compact
  (testing "27.1 3d"
    (is (= "3d" (age-compact "2025-06-12" "2025-06-15"))))
  (testing "27.2 1w"
    (is (= "1w" (age-compact "2025-06-08" "2025-06-15"))))
  (testing "27.3 1w1d"
    (is (= "1w1d" (age-compact "2025-06-07" "2025-06-15"))))
  (testing "27.4 6m"
    (is (= "6m" (age-compact "2025-01-15" "2025-07-15"))))
  (testing "27.5 2y1m"
    (is (= "2y1m" (age-compact "2023-06-15" "2025-07-15"))))
  (testing "27.6 3.5y"
    (is (= "3½y" (age-compact "2022-06-15" "2025-12-15"))))
  (testing "27.7 7y"
    (is (= "7y" (age-compact "2018-06-15" "2025-06-15"))))
  (testing "27.8 Newborn"
    (is (= "Newborn" (age-compact "2025-06-15" "2025-06-15")))))

;; 29. Locale-specific edge cases

;; 29.1 — Hebrew (he)
(deftest hebrew
  (testing "29.1 Newborn"
    (is (= "רק נולד" (age-locale he/locale "2025-06-15" "2025-06-15"))))
  (testing "29.2 1 day"
    (is (= "יום 1" (age-locale he/locale "2025-06-14" "2025-06-15"))))
  (testing "29.3 3 days"
    (is (= "3 ימים" (age-locale he/locale "2025-06-12" "2025-06-15"))))
  (testing "29.4 2 weeks"
    (is (= "שבועיים" (age-locale he/locale "2025-06-01" "2025-06-15"))))
  (testing "29.5 3 weeks"
    (is (= "3 שבועות" (age-locale he/locale "2025-05-25" "2025-06-15"))))
  (testing "29.6 6 months"
    (is (= "6 חודשים" (age-locale he/locale "2025-01-15" "2025-07-15"))))
  (testing "29.7 3 months"
    (is (= "3 חודשים" (age-locale he/locale "2025-03-15" "2025-06-15"))))
  (testing "29.8 2 years, 1 month"
    (is (= "שנתיים, חודש 1" (age-locale he/locale "2023-06-15" "2025-07-15"))))
  (testing "29.9 3.5 years"
    (is (= "3 שנים וחצי" (age-locale he/locale "2022-06-15" "2025-12-15"))))
  (testing "29.10 7 years"
    (is (= "7 שנים" (age-locale he/locale "2018-06-15" "2025-06-15"))))
  (testing "29.11 stage male"
    (is (= "רק נולד" (stage-locale he/locale "2025-06-15" "2025-06-15" :male))))
  (testing "29.12 stage female"
    (is (= "רק נולדה" (stage-locale he/locale "2025-06-15" "2025-06-15" :female))))
  (testing "29.13 adult male"
    (is (= "מבוגר" (stage-locale he/locale "2007-06-15" "2025-06-15" :male))))
  (testing "29.14 adult female"
    (is (= "מבוגרת" (stage-locale he/locale "2007-06-15" "2025-06-15" :female)))))

;; 29.2 — Macedonian (mk)
(deftest macedonian
  (testing "29.15 Newborn"
    (is (= "Новороденче" (age-locale mk/locale "2025-06-15" "2025-06-15"))))
  (testing "29.16 1 day"
    (is (= "1 ден" (age-locale mk/locale "2025-06-14" "2025-06-15"))))
  (testing "29.17 3 days"
    (is (= "3 дена" (age-locale mk/locale "2025-06-12" "2025-06-15"))))
  (testing "29.18 6 months"
    (is (= "6 месеци" (age-locale mk/locale "2025-01-15" "2025-07-15"))))
  (testing "29.19 2 years, 1 month"
    (is (= "2 години, 1 месец" (age-locale mk/locale "2023-06-15" "2025-07-15"))))
  (testing "29.20 3.5 years"
    (is (= "3 години и пол" (age-locale mk/locale "2022-06-15" "2025-12-15"))))
  (testing "29.21 7 years"
    (is (= "7 години" (age-locale mk/locale "2018-06-15" "2025-06-15")))))

;; 29.3 — Swahili (sw)
(deftest swahili
  (testing "29.22 Newborn"
    (is (= "Mzaliwa mpya" (age-locale sw/locale "2025-06-15" "2025-06-15"))))
  (testing "29.23 1 day"
    (is (= "siku 1" (age-locale sw/locale "2025-06-14" "2025-06-15"))))
  (testing "29.24 3 days"
    (is (= "siku 3" (age-locale sw/locale "2025-06-12" "2025-06-15"))))
  (testing "29.25 6 months"
    (is (= "miezi 6" (age-locale sw/locale "2025-01-15" "2025-07-15"))))
  (testing "29.26 2 years, 1 month"
    (is (= "miaka 2, mwezi 1" (age-locale sw/locale "2023-06-15" "2025-07-15"))))
  (testing "29.27 3.5 years"
    (is (= "miaka 3 na nusu" (age-locale sw/locale "2022-06-15" "2025-12-15")))))

;; 29.4 — Indonesian (id)
(deftest indonesian
  (testing "29.28 Newborn"
    (is (= "Baru lahir" (age-locale id/locale "2025-06-15" "2025-06-15"))))
  (testing "29.29 1 day"
    (is (= "1 hari" (age-locale id/locale "2025-06-14" "2025-06-15"))))
  (testing "29.30 3 days"
    (is (= "3 hari" (age-locale id/locale "2025-06-12" "2025-06-15"))))
  (testing "29.31 6 months"
    (is (= "6 bulan" (age-locale id/locale "2025-01-15" "2025-07-15"))))
  (testing "29.32 3.5 years"
    (is (= "3 tahun setengah" (age-locale id/locale "2022-06-15" "2025-12-15"))))
  (testing "29.33 7 years"
    (is (= "7 tahun" (age-locale id/locale "2018-06-15" "2025-06-15")))))

;; 29.5 — Amharic (am)
(deftest amharic
  (testing "29.34 Newborn"
    (is (= "አዲስ የተወለደ" (age-locale am/locale "2025-06-15" "2025-06-15"))))
  (testing "29.35 1 day"
    (is (= "1 ቀን" (age-locale am/locale "2025-06-14" "2025-06-15"))))
  (testing "29.36 3 days"
    (is (= "3 ቀናት" (age-locale am/locale "2025-06-12" "2025-06-15"))))
  (testing "29.37 1 week, 1 day"
    (is (= "1 ሳምንት፣ 1 ቀን" (age-locale am/locale "2025-06-07" "2025-06-15"))))
  (testing "29.38 6 months"
    (is (= "6 ወራት" (age-locale am/locale "2025-01-15" "2025-07-15"))))
  (testing "29.39 3.5 years"
    (is (= "3 ዓመታት ተኩል" (age-locale am/locale "2022-06-15" "2025-12-15")))))

;; 30. Locale lookup by code string
(deftest locale-lookup
  (testing "30.1 English"
    (is (= "en" (:code (pt/get-locale "en")))))
  (testing "30.2 French"
    (is (= "fr" (:code (pt/get-locale "fr")))))
  (testing "30.3 unknown code"
    (is (nil? (pt/get-locale "xx"))))
  (testing "30.4 empty string"
    (is (nil? (pt/get-locale ""))))
  (testing "30.5 uppercase"
    (is (nil? (pt/get-locale "EN")))))

;; 31. Weeks and days across month ends
(deftest weeks-and-days-across-month-ends
  (testing "31.1 88 days across a 28 day february"
    (is (= "12 weeks, 4 days" (pt/format-age-pure (pt/get-locale "en") :normal "2016-12-31" "2017-03-29"))))
  (testing "31.2 90 days across a year end into"
    (is (= "12 weeks, 6 days" (pt/format-age-pure (pt/get-locale "en") :normal "1991-11-27" "1992-02-25"))))
  (testing "31.3 33 days across a year end"
    (is (= "4 weeks, 5 days" (pt/format-age-pure (pt/get-locale "en") :normal "2020-11-30" "2021-01-02"))))
  (testing "31.4 compact form of 31 1"
    (is (= "12w4d" (pt/format-age-pure (pt/get-locale "en") :compact "2016-12-31" "2017-03-29")))))

;; 32. Half years take their plural form from whole years
(deftest half-years-take-their-plural-form-from-whole-years
  (testing "32.1 polish 3 is few"
    (is (= "3 i p\u00F3\u0142 lata" (pt/format-age-pure (pt/get-locale "pl") :normal "2021-06-15" "2025-01-15"))))
  (testing "32.2 polish 5 is many"
    (is (= "5 i p\u00F3\u0142 lat" (pt/format-age-pure (pt/get-locale "pl") :short "2020-06-15" "2025-12-15"))))
  (testing "32.3 tachelhit 6 is few"
    (is (= "6 iseggasen d uzgen" (pt/format-age-pure (pt/get-locale "shi") :normal "2005-06-08" "2012-06-07")))))

;; 33. Input validation
(deftest input-validation
  (testing "33.1 february 30 doesnt exist"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal "2025-02-30" "2032-06-25"))))
  (testing "33.2 month 13"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal "2025-13-01" "2027-01-31"))))
  (testing "33.3 february 29 in a non leap year"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal "2023-02-29" "2025-03-01"))))
  (testing "33.4 day 00"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal "2025-06-00" "2027-02-25"))))
  (testing "33.5 unpadded month and day"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal "2025-6-1" "2027-02-25"))))
  (testing "33.6 surrounding whitespace"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal " 2025-06-01" "2027-02-25"))))
  (testing "33.7 a datetime is not a date"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal "2025-06-15T10:00:00" "2027-02-25"))))
  (testing "33.8 invalid asof"
    (is (nil? (pt/format-age-pure (pt/get-locale "en") :normal "2020-01-01" "2025-04-31"))))
  (testing "33.9 formatstage validates too"
    (is (nil? (pt/format-stage-pure (pt/get-locale "en") "2025-02-30" "2027-09-05" nil))))
  (testing "33.10 february 29 in a leap year is"
    (is (= "2 years" (pt/format-age-pure (pt/get-locale "en") :normal "2024-02-29" "2026-03-01")))))

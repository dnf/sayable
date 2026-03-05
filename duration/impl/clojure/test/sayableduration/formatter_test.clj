(ns sayableduration.formatter-test
  (:require [clojure.test :refer [deftest is testing]]
            [sayableduration.core :as sd]
            [sayableduration.locales :as locales]))

;; Helpers
(defn- dur [seconds] (sd/format-duration-seconds seconds))
(defn- dur-iso [start end] (sd/format-duration-iso start end))
(defn- since [start as-of] (sd/format-since start as-of))
(defn- until' [target as-of] (sd/format-until target as-of))
(defn- dur-locale [locale seconds] (sd/format-duration-seconds locale :normal seconds))
(defn- since-locale [locale start as-of] (sd/format-since locale :normal start as-of))
(defn- dur-short [seconds] (sd/format-duration-seconds (locales/get-locale "en") :short seconds))
(defn- dur-compact [seconds] (sd/format-duration-seconds (locales/get-locale "en") :compact seconds))

;; ================================================================
;; Section 1: Null / edge cases
;; ================================================================

;; 1.1
(deftest null-returns-null
  (testing "1.1 format_duration null returns null"
    (is (nil? (sd/format-duration-seconds -1)))))

;; 1.2
(deftest negative-returns-null
  (testing "1.2 format_duration negative returns null"
    (is (nil? (sd/format-duration-seconds -1)))))

;; 1.3
(deftest since-null-start-returns-null
  (testing "1.3 format_since null start returns null"
    (is (nil? (sd/format-since nil "2025-01-15T10:00:00")))))

;; 1.4
(deftest until-null-target-returns-null
  (testing "1.4 format_until null target returns null"
    (is (nil? (sd/format-until nil "2025-01-15T10:00:00")))))

;; 1.5
(deftest since-asof-before-start-returns-null
  (testing "1.5 format_since asOf before start returns null"
    (is (nil? (since "2025-01-15T10:00:00" "2025-01-15T09:00:00")))))

;; 1.6
(deftest until-target-in-past-returns-null
  (testing "1.6 format_until target in the past returns null"
    (is (nil? (until' "2025-01-15T09:00:00" "2025-01-15T10:00:00")))))

;; ================================================================
;; Section 2: Duration -- seconds tier (0-59s)
;; ================================================================

;; 2.1
(deftest zero-seconds-is-just-now
  (testing "2.1 0 seconds is just now"
    (is (= "just now" (dur 0)))))

;; 2.2
(deftest one-second
  (testing "2.2 1 second"
    (is (= "1 second" (dur 1)))))

;; 2.3
(deftest forty-five-seconds
  (testing "2.3 45 seconds"
    (is (= "45 seconds" (dur 45)))))

;; 2.4
(deftest fifty-nine-seconds
  (testing "2.4 59 seconds"
    (is (= "59 seconds" (dur 59)))))

;; ================================================================
;; Section 3: Duration -- minutes + seconds tier (1-4 min)
;; ================================================================

;; 3.1
(deftest one-minute
  (testing "3.1 1 minute"
    (is (= "1 minute" (dur 60)))))

;; 3.2
(deftest one-minute-thirty-seconds
  (testing "3.2 1 minute 30 seconds"
    (is (= "1 minute, 30 seconds" (dur 90)))))

;; 3.3
(deftest four-minutes
  (testing "3.3 4 minutes"
    (is (= "4 minutes" (dur 240)))))

;; 3.4
(deftest four-minutes-thirty-seconds
  (testing "3.4 4 minutes 30 seconds"
    (is (= "4 minutes, 30 seconds" (dur 270)))))

;; ================================================================
;; Section 4: Duration -- minutes tier (5-59 min)
;; ================================================================

;; 4.1
(deftest five-minutes
  (testing "4.1 5 minutes"
    (is (= "5 minutes" (dur 300)))))

;; 4.2
(deftest twenty-five-minutes
  (testing "4.2 25 minutes"
    (is (= "25 minutes" (dur 1500)))))

;; 4.3
(deftest fifty-nine-minutes
  (testing "4.3 59 minutes"
    (is (= "59 minutes" (dur 3540)))))

;; ================================================================
;; Section 5: Duration -- hours + minutes tier (1-5 hr)
;; ================================================================

;; 5.1
(deftest one-hour
  (testing "5.1 1 hour"
    (is (= "1 hour" (dur 3600)))))

;; 5.2
(deftest one-and-half-hours
  (testing "5.2 1 and half hours"
    (is (= "1\u00BD hours" (dur 5400)))))

;; 5.3
(deftest two-hours-fifteen-minutes
  (testing "5.3 2 hours 15 minutes"
    (is (= "2 hours, 15 minutes" (dur 8100)))))

;; 5.4
(deftest five-hours
  (testing "5.4 5 hours"
    (is (= "5 hours" (dur 18000)))))

;; ================================================================
;; Section 6: Duration -- hours tier (6-23 hr)
;; ================================================================

;; 6.1
(deftest eight-hours
  (testing "6.1 8 hours"
    (is (= "8 hours" (dur 28800)))))

;; 6.2
(deftest twenty-three-hours
  (testing "6.2 23 hours"
    (is (= "23 hours" (dur 82800)))))

;; ================================================================
;; Section 7: Duration -- days tier
;; ================================================================

;; 7.1
(deftest one-day
  (testing "7.1 1 day"
    (is (= "1 day" (dur 86400)))))

;; 7.2
(deftest one-day-three-hours
  (testing "7.2 1 day 3 hours"
    (is (= "1 day, 3 hours" (dur 97200)))))

;; 7.3
(deftest one-and-half-days
  (testing "7.3 1 and half days"
    (is (= "1\u00BD days" (dur 129600)))))

;; 7.4
(deftest five-days
  (testing "7.4 5 days"
    (is (= "5 days" (dur 432000)))))

;; 7.5
(deftest two-days
  (testing "7.5 2 days"
    (is (= "2 days" (dur 172800)))))

;; ================================================================
;; Section 8: Duration -- weeks tier
;; ================================================================

;; 8.1
(deftest one-week
  (testing "8.1 1 week"
    (is (= "1 week" (dur 604800)))))

;; 8.2
(deftest two-weeks-one-day
  (testing "8.2 2 weeks 1 day"
    (is (= "2 weeks, 1 day" (dur 1296000)))))

;; 8.3
(deftest four-weeks
  (testing "8.3 4 weeks"
    (is (= "4 weeks" (dur 2419200)))))

;; ================================================================
;; Section 9: Duration -- months and years tier
;; ================================================================

;; 9.1
(deftest one-month
  (testing "9.1 1 month"
    (is (= "1 month" (dur 2678400)))))

;; 9.2
(deftest three-months
  (testing "9.2 3 months"
    (is (= "3 months" (dur 7884000)))))

;; 9.3
(deftest one-year
  (testing "9.3 1 year"
    (is (= "1 year" (dur 31536000)))))

;; 9.4
(deftest one-year-three-months
  (testing "9.4 1 year 3 months"
    (is (= "1 year, 3 months" (dur 39420000)))))

;; ================================================================
;; Section 10: Duration from ISO timestamps
;; ================================================================

;; 10.1
(deftest iso-one-and-half-hours
  (testing "10.1 ISO 1 and half hours"
    (is (= "1\u00BD hours" (dur-iso "2025-01-15T10:00:00" "2025-01-15T11:30:00")))))

;; 10.2
(deftest iso-forty-five-minutes
  (testing "10.2 ISO 45 minutes"
    (is (= "45 minutes" (dur-iso "2025-01-15T10:00:00" "2025-01-15T10:45:00")))))

;; ================================================================
;; Section 11: Relative time -- since
;; ================================================================

;; 11.1
(deftest since-just-now
  (testing "11.1 since just now"
    (is (= "just now" (since "2025-01-15T10:00:00" "2025-01-15T10:00:00")))))

;; 11.2
(deftest since-thirty-seconds-ago
  (testing "11.2 since 30 seconds ago"
    (is (= "30 seconds ago" (since "2025-01-15T10:00:00" "2025-01-15T10:00:30")))))

;; 11.3
(deftest since-forty-five-minutes-ago
  (testing "11.3 since 45 minutes ago"
    (is (= "45 minutes ago" (since "2025-01-15T10:00:00" "2025-01-15T10:45:00")))))

;; 11.4
(deftest since-three-hours-ago
  (testing "11.4 since 3 hours ago"
    (is (= "3 hours ago" (since "2025-01-15T10:00:00" "2025-01-15T13:00:00")))))

;; ================================================================
;; Section 12: Relative time -- until
;; ================================================================

;; 12.1
(deftest until-just-now
  (testing "12.1 until just now"
    (is (= "just now" (until' "2025-01-15T10:00:00" "2025-01-15T10:00:00")))))

;; 12.2
(deftest until-in-twenty-minutes
  (testing "12.2 until in 20 minutes"
    (is (= "in 20 minutes" (until' "2025-01-15T10:20:00" "2025-01-15T10:00:00")))))

;; 12.3
(deftest until-in-three-hours
  (testing "12.3 until in 3 hours"
    (is (= "in 3 hours" (until' "2025-01-15T13:00:00" "2025-01-15T10:00:00")))))

;; ================================================================
;; Section 13: Locale -- German
;; ================================================================

;; 13.1
(deftest german-one-hour
  (testing "13.1 German 1 hour"
    (is (= "1 Stunde" (dur-locale (locales/get-locale "de") 3600)))))

;; 13.2
(deftest german-since-five-minutes
  (testing "13.2 German since 5 minutes"
    (is (= "vor 5 Minuten"
           (since-locale (locales/get-locale "de") "2025-01-15T10:00:00" "2025-01-15T10:05:00")))))

;; ================================================================
;; Section 14: Locale -- French
;; ================================================================

;; 14.1
(deftest french-two-hours
  (testing "14.1 French 2 hours"
    (is (= "2 heures" (dur-locale (locales/get-locale "fr") 7200)))))

;; ================================================================
;; Section 15: Locale -- Japanese
;; ================================================================

;; 15.1
(deftest japanese-two-minutes
  (testing "15.1 Japanese 2 minutes"
    (is (= "2\u5206" (dur-locale (locales/get-locale "ja") 120)))))

;; 15.2
(deftest japanese-since-one-hour
  (testing "15.2 Japanese since 1 hour"
    (is (= "1\u6642\u9593\u524D"
           (since-locale (locales/get-locale "ja") "2025-01-15T10:00:00" "2025-01-15T11:00:00")))))

;; ================================================================
;; Section 16: Short compactness -- duration
;; ================================================================

;; 16.1
(deftest short-one-hour
  (testing "16.1 short 1 hour"
    (is (= "1h" (dur-short 3600)))))

;; 16.2
(deftest short-one-minute-thirty-seconds
  (testing "16.2 short 1 minute 30 seconds"
    (is (= "1m, 30s" (dur-short 90)))))

;; ================================================================
;; Section 17: Compact compactness -- duration
;; ================================================================

;; 17.1
(deftest compact-one-hour
  (testing "17.1 compact 1 hour"
    (is (= "1h" (dur-compact 3600)))))

;; 17.2
(deftest compact-one-minute-thirty-seconds
  (testing "17.2 compact 1 minute 30 seconds"
    (is (= "1m30s" (dur-compact 90)))))

;; Version
(deftest version-matches-config
  (testing "version matches config"
    (is (= "0.5.0" sayableduration.formatter/version))))

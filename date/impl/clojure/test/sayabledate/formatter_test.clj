(ns sayabledate.formatter-test
  (:require [clojure.test :refer [deftest is testing]]
            [sayabledate.core :as sd]
            [sayabledate.locales :as locales]))

;; Helpers
(defn- fdate [date] (sd/format-date date))
(defn- fdate-locale [locale date] (sd/format-date locale :normal date))
(defn- fdate-short [date] (sd/format-date (locales/get-locale "en") :short date))
(defn- fdate-compact [date] (sd/format-date (locales/get-locale "en") :compact date))
(defn- frel [date as-of] (sd/format-relative date as-of))
(defn- frel-locale [locale date as-of] (sd/format-relative locale :normal date as-of))
(defn- frel-compact [date as-of] (sd/format-relative (locales/get-locale "en") :compact date as-of))

;; ── Section 1: Null / edge cases ──────────────────────────────────

;; 1.1
(deftest format-date-null-returns-null
  (testing "1.1 format_date null returns null"
    (is (nil? (sd/format-date nil)))))

;; 1.2
(deftest format-date-empty-returns-null
  (testing "1.2 format_date empty returns null"
    (is (nil? (fdate "")))))

;; 1.3
(deftest format-date-invalid-returns-null
  (testing "1.3 format_date invalid returns null"
    (is (nil? (fdate "invalid")))))

;; 1.4
(deftest format-relative-null-asof-returns-null
  (testing "1.4 format_relative null asOf returns null"
    (is (nil? (sd/format-relative "2025-03-15" nil)))))

;; 1.5
(deftest format-relative-null-date-returns-null
  (testing "1.5 format_relative null date returns null"
    (is (nil? (sd/format-relative nil "2025-03-15")))))

;; ── Section 2: format_date -- normal compactness (English) ─────────

;; 2.1
(deftest format-date-march-15th
  (testing "2.1 format_date March 15th"
    (is (= "March 15th" (fdate "2025-03-15")))))

;; 2.2
(deftest format-date-january-1st
  (testing "2.2 format_date January 1st"
    (is (= "January 1st" (fdate "2025-01-01")))))

;; 2.3
(deftest format-date-may-22nd
  (testing "2.3 format_date May 22nd"
    (is (= "May 22nd" (fdate "2025-05-22")))))

;; 2.4
(deftest format-date-july-3rd
  (testing "2.4 format_date July 3rd"
    (is (= "July 3rd" (fdate "2025-07-03")))))

;; 2.5
(deftest format-date-december-31st
  (testing "2.5 format_date December 31st"
    (is (= "December 31st" (fdate "2025-12-31")))))

;; 2.6
(deftest format-date-june-11th
  (testing "2.6 format_date June 11th -- no exception for 11"
    (is (= "June 11th" (fdate "2025-06-11")))))

;; 2.7
(deftest format-date-iso-datetime-input
  (testing "2.7 format_date ISO datetime input"
    (is (= "March 15th" (fdate "2025-03-15T14:30:00")))))

;; ── Section 3: format_date -- short compactness (English) ──────────

;; 3.1
(deftest format-date-short-mar-15
  (testing "3.1 format_date short Mar 15"
    (is (= "Mar 15" (fdate-short "2025-03-15")))))

;; 3.2
(deftest format-date-short-jan-1
  (testing "3.2 format_date short Jan 1"
    (is (= "Jan 1" (fdate-short "2025-01-01")))))

;; 3.3
(deftest format-date-short-dec-25
  (testing "3.3 format_date short Dec 25"
    (is (= "Dec 25" (fdate-short "2025-12-25")))))

;; ── Section 4: format_date -- compact (English) ────────────────────

;; 4.1
(deftest format-date-compact-3-15
  (testing "4.1 format_date compact 3/15"
    (is (= "3/15" (fdate-compact "2025-03-15")))))

;; 4.2
(deftest format-date-compact-1-1
  (testing "4.2 format_date compact 1/1"
    (is (= "1/1" (fdate-compact "2025-01-01")))))

;; ── Section 5: format_relative -- proximity tiers (English) ────────

;; 5.1
(deftest format-relative-today
  (testing "5.1 format_relative today"
    (is (= "today" (frel "2025-03-15" "2025-03-15")))))

;; 5.2
(deftest format-relative-tomorrow
  (testing "5.2 format_relative tomorrow"
    (is (= "tomorrow" (frel "2025-03-16" "2025-03-15")))))

;; 5.3
(deftest format-relative-yesterday
  (testing "5.3 format_relative yesterday"
    (is (= "yesterday" (frel "2025-03-14" "2025-03-15")))))

;; 5.4
(deftest format-relative-day-after-tomorrow
  (testing "5.4 format_relative day after tomorrow"
    (is (= "the day after tomorrow" (frel "2025-03-17" "2025-03-15")))))

;; 5.5
(deftest format-relative-day-before-yesterday
  (testing "5.5 format_relative day before yesterday"
    (is (= "the day before yesterday" (frel "2025-03-13" "2025-03-15")))))

;; 5.6
(deftest format-relative-this-wednesday
  (testing "5.6 format_relative this Wednesday -- plus 4 days"
    (is (= "this Wednesday" (frel "2025-03-19" "2025-03-15")))))

;; 5.7
(deftest format-relative-this-thursday
  (testing "5.7 format_relative this Thursday -- plus 5 days"
    (is (= "this Thursday" (frel "2025-03-20" "2025-03-15")))))

;; 5.8
(deftest format-relative-last-tuesday
  (testing "5.8 format_relative last Tuesday -- minus 4 days"
    (is (= "last Tuesday" (frel "2025-03-11" "2025-03-15")))))

;; 5.9
(deftest format-relative-next-saturday
  (testing "5.9 format_relative next Saturday -- plus 7 days"
    (is (= "next Saturday" (frel "2025-03-22" "2025-03-15")))))

;; 5.10
(deftest format-relative-next-thursday
  (testing "5.10 format_relative next Thursday -- plus 12 days"
    (is (= "next Thursday" (frel "2025-03-27" "2025-03-15")))))

;; 5.11
(deftest format-relative-calendar-same-year-past
  (testing "5.11 format_relative calendar same year past -- minus 14 days"
    (is (= "March 1st" (frel "2025-03-01" "2025-03-15")))))

;; 5.12
(deftest format-relative-calendar-same-year-future
  (testing "5.12 format_relative calendar same year future -- plus 26 days"
    (is (= "April 10th" (frel "2025-04-10" "2025-03-15")))))

;; 5.13
(deftest format-relative-different-year-future
  (testing "5.13 format_relative different year future includes year"
    (is (= "January 5th, 2026" (frel "2026-01-05" "2025-03-15")))))

;; 5.14
(deftest format-relative-past-year
  (testing "5.14 format_relative past year includes year"
    (is (= "December 25th, 2024" (frel "2024-12-25" "2025-03-15")))))

;; ── Section 6: format_relative -- compact skips weekday tiers ──────

;; 6.1
(deftest format-relative-compact-today
  (testing "6.1 format_relative compact today"
    (is (= "today" (frel-compact "2025-03-15" "2025-03-15")))))

;; 6.2
(deftest format-relative-compact-tomorrow
  (testing "6.2 format_relative compact tomorrow"
    (is (= "tomorrow" (frel-compact "2025-03-16" "2025-03-15")))))

;; 6.3
(deftest format-relative-compact-goes-straight-to-numeric
  (testing "6.3 format_relative compact goes straight to numeric"
    (is (= "3/19" (frel-compact "2025-03-19" "2025-03-15")))))

;; 6.4
(deftest format-relative-compact-different-year
  (testing "6.4 format_relative compact different year"
    (is (= "1/5/26" (frel-compact "2026-01-05" "2025-03-15")))))

;; ── Section 7: Locale -- German ──────────────────────────────────

;; 7.1
(deftest format-date-german
  (testing "7.1 format_date German"
    (is (= "15. M\u00E4rz" (fdate-locale (locales/get-locale "de") "2025-03-15")))))

;; 7.2
(deftest format-relative-german-tomorrow
  (testing "7.2 format_relative German tomorrow"
    (is (= "morgen" (frel-locale (locales/get-locale "de") "2025-03-16" "2025-03-15")))))

;; 7.3
(deftest format-relative-german-day-after-tomorrow
  (testing "7.3 format_relative German day after tomorrow"
    (is (= "\u00FCbermorgen" (frel-locale (locales/get-locale "de") "2025-03-17" "2025-03-15")))))

;; 7.4
(deftest format-relative-german-this-wednesday
  (testing "7.4 format_relative German this Wednesday"
    (is (= "diesen Mittwoch" (frel-locale (locales/get-locale "de") "2025-03-19" "2025-03-15")))))

;; ── Section 8: Locale -- French ──────────────────────────────────

;; 8.1
(deftest format-date-french-1er-mars
  (testing "8.1 format_date French 1er mars"
    (is (= "1er mars" (fdate-locale (locales/get-locale "fr") "2025-03-01")))))

;; 8.2
(deftest format-date-french-15-mars
  (testing "8.2 format_date French 15 mars"
    (is (= "15 mars" (fdate-locale (locales/get-locale "fr") "2025-03-15")))))

;; 8.3
(deftest format-relative-french-tomorrow
  (testing "8.3 format_relative French tomorrow"
    (is (= "demain" (frel-locale (locales/get-locale "fr") "2025-03-16" "2025-03-15")))))

;; ── Section 9: Locale -- Japanese ────────────────────────────────

;; 9.1
(deftest format-date-japanese
  (testing "9.1 format_date Japanese"
    (is (= "3\u670815\u65E5" (fdate-locale (locales/get-locale "ja") "2025-03-15")))))

;; 9.2
(deftest format-relative-japanese-tomorrow
  (testing "9.2 format_relative Japanese tomorrow"
    (is (= "\u660E\u65E5" (frel-locale (locales/get-locale "ja") "2025-03-16" "2025-03-15")))))

;; 9.3
(deftest format-relative-japanese-this-wednesday
  (testing "9.3 format_relative Japanese this Wednesday"
    (is (= "\u4ECA\u5EA6\u306E\u6C34\u66DC\u65E5" (frel-locale (locales/get-locale "ja") "2025-03-19" "2025-03-15")))))

;; ── Section 10: Locale -- Russian (genitive months) ────────────

;; 10.1
(deftest format-date-russian-genitive-months
  (testing "10.1 format_date Russian genitive months"
    (is (= "15 \u043C\u0430\u0440\u0442\u0430" (fdate-locale (locales/get-locale "ru") "2025-03-15")))))

;; 10.2
(deftest format-relative-russian-tomorrow
  (testing "10.2 format_relative Russian tomorrow"
    (is (= "\u0437\u0430\u0432\u0442\u0440\u0430" (frel-locale (locales/get-locale "ru") "2025-03-16" "2025-03-15")))))

;; ── Section 11: Locale -- Arabic ─────────────────────────────────

;; 11.1
(deftest format-date-arabic
  (testing "11.1 format_date Arabic"
    (is (= "15 \u0645\u0627\u0631\u0633" (fdate-locale (locales/get-locale "ar") "2025-03-15")))))

;; 11.2
(deftest format-relative-arabic-tomorrow
  (testing "11.2 format_relative Arabic tomorrow"
    (is (= "\u063A\u062F\u0627\u064B" (frel-locale (locales/get-locale "ar") "2025-03-16" "2025-03-15")))))

;; ── Section 12: Locale -- Spanish ────────────────────────────────

;; 12.1
(deftest format-date-spanish
  (testing "12.1 format_date Spanish"
    (is (= "15 de marzo" (fdate-locale (locales/get-locale "es") "2025-03-15")))))

;; 12.2
(deftest format-relative-spanish-day-after-tomorrow
  (testing "12.2 format_relative Spanish day after tomorrow"
    (is (= "pasado ma\u00F1ana" (frel-locale (locales/get-locale "es") "2025-03-17" "2025-03-15")))))

;; Version
(deftest version-matches-config
  (testing "version matches config"
    (is (= "0.5.0" sayabledate.formatter/version))))

;; ================================================================
;; format_date_with_year
;; ================================================================

;; 13.1
(deftest case-13-1-format-date-with-year-en-normal-2018-02-04
  (testing "13.1 format date with year en normal 2018-02-04"
    (is (= "February 4th, 2018" (sd/format-date-with-year (sd/get-locale "en") :normal "2018-02-04")))))

;; 13.2
(deftest case-13-2-format-date-with-year-en-short-2025-03-15
  (testing "13.2 format date with year en short 2025-03-15"
    (is (= "Mar 15, 2025" (sd/format-date-with-year (sd/get-locale "en") :short "2025-03-15")))))

;; 13.3
(deftest case-13-3-format-date-with-year-en-compact-1997-01-21
  (testing "13.3 format date with year en compact 1997-01-21"
    (is (= "1/21/97" (sd/format-date-with-year (sd/get-locale "en") :compact "1997-01-21")))))

;; 13.4
(deftest case-13-4-two-digit-year-keeps-its-leading-zero
  (testing "13.4 two digit year keeps its leading zero"
    (is (= "20/5/07" (sd/format-date-with-year (sd/get-locale "tg") :compact "2007-05-20")))))

;; 13.5
(deftest case-13-5-format-date-with-year-fi-short-1996-06-21
  (testing "13.5 format date with year fi short 1996-06-21"
    (is (= "21. kes\u00E4kuuta 1996" (sd/format-date-with-year (sd/get-locale "fi") :short "1996-06-21")))))

;; ================================================================
;; Short month names (locales that keep the full genitive)
;; ================================================================

;; 14.1
(deftest case-14-1-short-month-names-locales-that-keep-the-sk-short-2031-02-15
  (testing "14.1 short month names locales that keep the sk short 2031-02-15"
    (is (= "15. febru\u00E1ra" (sd/format-date (sd/get-locale "sk") :short "2031-02-15")))))

;; 14.2
(deftest case-14-2-short-month-names-locales-that-keep-the-cs-short-2025-12-10
  (testing "14.2 short month names locales that keep the cs short 2025-12-10"
    (is (= "10. prosince" (sd/format-date (sd/get-locale "cs") :short "2025-12-10")))))

;; 14.3
(deftest case-14-3-short-month-names-locales-that-keep-the-uk-short-2025-11-05
  (testing "14.3 short month names locales that keep the uk short 2025-11-05"
    (is (= "5 \u043B\u0438\u0441\u0442\u043E\u043F\u0430\u0434\u0430" (sd/format-date (sd/get-locale "uk") :short "2025-11-05")))))

;; 14.4
(deftest case-14-4-short-month-names-locales-that-keep-the-fi-short-1998-08-08
  (testing "14.4 short month names locales that keep the fi short 1998-08-08"
    (is (= "8. elokuuta" (sd/format-relative (sd/get-locale "fi") :short "1998-08-08" "1998-08-15")))))

;; ================================================================
;; format_relative — short phrases
;; ================================================================

;; 15.1
(deftest case-15-1-day-after-tomorrow-kw-short-2035-12-04
  (testing "15.1 day after tomorrow kw short 2035-12-04"
    (is (= "an Mth ma" (sd/format-relative (sd/get-locale "kw") :short "2035-12-04" "2035-12-02")))))

;; 15.2
(deftest case-15-2-day-before-yesterday
  (testing "15.2 day before yesterday"
    (is (= "Dom nchi'j" (sd/format-relative (sd/get-locale "mam") :short "2000-01-23" "2000-01-25")))))

;; 15.3
(deftest case-15-3-day-after-tomorrow-kek-short-2014-10-24
  (testing "15.3 day after tomorrow kek short 2014-10-24"
    (is (= "a'in Vie" (sd/format-relative (sd/get-locale "kek") :short "2014-10-24" "2014-10-22")))))

;; ================================================================
;; Input validation
;; ================================================================

;; 16.1
(deftest case-16-1-february-30-doesnt-exist
  (testing "16.1 february 30 doesnt exist"
    (is (nil? (sd/format-date (sd/get-locale "en") :normal "2025-02-30")))))

;; 16.2
(deftest case-16-2-month-13
  (testing "16.2 month 13"
    (is (nil? (sd/format-date (sd/get-locale "en") :normal "2025-13-01")))))

;; 16.3
(deftest case-16-3-unpadded-month-and-day
  (testing "16.3 unpadded month and day"
    (is (nil? (sd/format-date (sd/get-locale "en") :normal "2025-6-1")))))

;; 16.4
(deftest case-16-4-surrounding-whitespace
  (testing "16.4 surrounding whitespace"
    (is (nil? (sd/format-date (sd/get-locale "en") :normal " 2025-06-01")))))

;; 16.5
(deftest case-16-5-an-iso-datetime-only-the-date-part
  (testing "16.5 an iso datetime only the date part"
    (is (= "June 1st" (sd/format-date (sd/get-locale "en") :normal "2025-06-01T10:00:00")))))

;; 16.6
(deftest case-16-6-february-29-in-a-non-leap-year
  (testing "16.6 february 29 in a non leap year"
    (is (nil? (sd/format-date-with-year (sd/get-locale "en") :normal "2023-02-29")))))

;; 16.7
(deftest case-16-7-invalid-asof
  (testing "16.7 invalid asof"
    (is (nil? (sd/format-relative (sd/get-locale "en") :normal "2025-03-16" "2025-04-31")))))

(ns sayabletime.formatter-test
  (:require [clojure.test :refer [deftest is testing]]
            [sayabletime.core :as st]
            [sayabletime.locales :as locales]))

;; Helpers
(defn- time' [input] (st/format-time input))
(defn- time-locale [locale input] (st/format-time locale :normal input))
(defn- time-short [input] (st/format-time (locales/get-locale "en") :short input))
(defn- time-compact [input] (st/format-time (locales/get-locale "en") :compact input))

;; ================================================================
;; Section 1: Null / edge cases
;; ================================================================

;; 1.1
(deftest null-input-returns-null
  (testing "1.1 null input returns null"
    (is (nil? (st/format-time nil)))))

;; 1.2
(deftest empty-string-returns-null
  (testing "1.2 empty string returns null"
    (is (nil? (time' "")))))

;; 1.3
(deftest invalid-string-returns-null
  (testing "1.3 invalid string returns null"
    (is (nil? (time' "invalid")))))

;; 1.4
(deftest out-of-range-returns-null
  (testing "1.4 out of range returns null"
    (is (nil? (time' "25:00")))))

;; ================================================================
;; Section 2: Clock time (normal compactness)
;; ================================================================

;; 2.1
(deftest midnight
  (testing "2.1 midnight"
    (is (= "midnight" (time' "00:00")))))

;; 2.2
(deftest noon
  (testing "2.2 noon"
    (is (= "noon" (time' "12:00")))))

;; 2.3
(deftest oclock
  (testing "2.3 o'clock"
    (is (= "three o'clock" (time' "15:00")))))

;; 2.4
(deftest quarter-past
  (testing "2.4 quarter past"
    (is (= "a quarter past two" (time' "14:15")))))

;; 2.5
(deftest half-past
  (testing "2.5 half past"
    (is (= "half past nine" (time' "09:30")))))

;; 2.6
(deftest quarter-to
  (testing "2.6 quarter to"
    (is (= "a quarter to eleven" (time' "10:45")))))

;; 2.7
(deftest five-past
  (testing "2.7 five past"
    (is (= "five past eight" (time' "08:05")))))

;; 2.8
(deftest five-to
  (testing "2.8 five to"
    (is (= "five to five" (time' "16:55")))))

;; 2.9
(deftest rounds-to-midnight
  (testing "2.9 rounds to midnight"
    (is (= "midnight" (time' "23:58")))))

;; 2.10
(deftest rounds-to-twenty
  (testing "2.10 rounds to twenty"
    (is (= "twenty past seven" (time' "07:22")))))

;; 2.11
(deftest iso-datetime-input
  (testing "2.11 ISO datetime input"
    (is (= "a quarter past two" (time' "2025-01-15T14:15:00")))))

;; ================================================================
;; Section 3: Clock time (short compactness)
;; ================================================================

;; 3.1
(deftest short-pm
  (testing "3.1 short PM"
    (is (= "2:15 PM" (time-short "14:15")))))

;; 3.2
(deftest short-am
  (testing "3.2 short AM"
    (is (= "9:30 AM" (time-short "09:30")))))

;; 3.3
(deftest short-midnight
  (testing "3.3 short midnight"
    (is (= "12:00 AM" (time-short "00:00")))))

;; 3.4
(deftest short-noon
  (testing "3.4 short noon"
    (is (= "12:00 PM" (time-short "12:00")))))

;; ================================================================
;; Section 4: Clock time (compact)
;; ================================================================

;; 4.1
(deftest compact-pm
  (testing "4.1 compact PM"
    (is (= "2:15p" (time-compact "14:15")))))

;; 4.2
(deftest compact-am
  (testing "4.2 compact AM"
    (is (= "9:30a" (time-compact "09:30")))))

;; ================================================================
;; Section 5: Locale -- German
;; ================================================================

;; 5.1
(deftest german-half-to-pattern
  (testing "5.1 German half-to pattern"
    (is (= "halb vier" (time-locale (locales/get-locale "de") "15:30")))))

;; ================================================================
;; Section 6: Locale -- French
;; ================================================================

;; 6.1
(deftest french-quarter-past
  (testing "6.1 French quarter past"
    (is (= "trois heures et quart" (time-locale (locales/get-locale "fr") "15:15")))))

;; ================================================================
;; Section 7: Locale -- Japanese
;; ================================================================

;; 7.1
(deftest japanese-half-past
  (testing "7.1 Japanese half past"
    (is (= "\u4E09\u6642\u534A" (time-locale (locales/get-locale "ja") "15:30")))))

;; ================================================================
;; Section 8: Locale -- Finnish (dot separator, short)
;; ================================================================

;; 8.1
(deftest finnish-dot-separator
  (testing "8.1 Finnish dot separator"
    (is (= "14.15" (st/format-time (locales/get-locale "fi") :short "14:15")))))

;; 8.2
(deftest finnish-midnight-dot
  (testing "8.2 Finnish midnight dot"
    (is (= "0.00" (st/format-time (locales/get-locale "fi") :short "00:00")))))

;; Version
(deftest version-matches-config
  (testing "version matches config"
    (is (= "0.5.0" sayabletime.formatter/version))))

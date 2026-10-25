# Test suite for sayable-date Janet implementation.
# Implements all canonical test cases from date/config/tests.json.

(import ./format_date :as sd)

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

# =============================================================================
# Section 1: Null / edge cases
# =============================================================================

# 1.1
(assert-nil "1.1" (sd/format-date nil))

# 1.2
(assert-nil "1.2" (sd/format-date ""))

# 1.3
(assert-nil "1.3" (sd/format-date "invalid"))

# 1.4
(assert-nil "1.4" (sd/format-relative "2025-03-15" nil))

# 1.5
(assert-nil "1.5" (sd/format-relative nil "2025-03-15"))

# =============================================================================
# Section 2: format_date - normal compactness (English)
# =============================================================================

# 2.1
(assert-eq "2.1" (sd/format-date "2025-03-15") "March 15th")

# 2.2
(assert-eq "2.2" (sd/format-date "2025-01-01") "January 1st")

# 2.3
(assert-eq "2.3" (sd/format-date "2025-05-22") "May 22nd")

# 2.4
(assert-eq "2.4" (sd/format-date "2025-07-03") "July 3rd")

# 2.5
(assert-eq "2.5" (sd/format-date "2025-12-31") "December 31st")

# 2.6
(assert-eq "2.6" (sd/format-date "2025-06-11") "June 11th")

# 2.7
(assert-eq "2.7" (sd/format-date "2025-03-15T14:30:00") "March 15th")

# =============================================================================
# Section 3: format_date - short compactness (English)
# =============================================================================

(def en-locale (sd/get-locale "en"))
(def pt-short (sd/make-formatter en-locale "short"))

# 3.1
(assert-eq "3.1" ((pt-short :format-date) "2025-03-15") "Mar 15")

# 3.2
(assert-eq "3.2" ((pt-short :format-date) "2025-01-01") "Jan 1")

# 3.3
(assert-eq "3.3" ((pt-short :format-date) "2025-12-25") "Dec 25")

# =============================================================================
# Section 4: format_date - compact (English)
# =============================================================================

(def pt-compact (sd/make-formatter en-locale "compact"))

# 4.1
(assert-eq "4.1" ((pt-compact :format-date) "2025-03-15") "3/15")

# 4.2
(assert-eq "4.2" ((pt-compact :format-date) "2025-01-01") "1/1")

# =============================================================================
# Section 5: format_relative - proximity tiers (English)
# =============================================================================

(def pt-en (sd/make-formatter en-locale))

# 5.1
(assert-eq "5.1" ((pt-en :format-relative) "2025-03-15" "2025-03-15") "today")

# 5.2
(assert-eq "5.2" ((pt-en :format-relative) "2025-03-16" "2025-03-15") "tomorrow")

# 5.3
(assert-eq "5.3" ((pt-en :format-relative) "2025-03-14" "2025-03-15") "yesterday")

# 5.4
(assert-eq "5.4" ((pt-en :format-relative) "2025-03-17" "2025-03-15") "the day after tomorrow")

# 5.5
(assert-eq "5.5" ((pt-en :format-relative) "2025-03-13" "2025-03-15") "the day before yesterday")

# 5.6
(assert-eq "5.6" ((pt-en :format-relative) "2025-03-19" "2025-03-15") "this Wednesday")

# 5.7
(assert-eq "5.7" ((pt-en :format-relative) "2025-03-20" "2025-03-15") "this Thursday")

# 5.8
(assert-eq "5.8" ((pt-en :format-relative) "2025-03-11" "2025-03-15") "last Tuesday")

# 5.9
(assert-eq "5.9" ((pt-en :format-relative) "2025-03-22" "2025-03-15") "next Saturday")

# 5.10
(assert-eq "5.10" ((pt-en :format-relative) "2025-03-27" "2025-03-15") "next Thursday")

# 5.11
(assert-eq "5.11" ((pt-en :format-relative) "2025-03-01" "2025-03-15") "March 1st")

# 5.12
(assert-eq "5.12" ((pt-en :format-relative) "2025-04-10" "2025-03-15") "April 10th")

# 5.13
(assert-eq "5.13" ((pt-en :format-relative) "2026-01-05" "2025-03-15") "January 5th, 2026")

# 5.14
(assert-eq "5.14" ((pt-en :format-relative) "2024-12-25" "2025-03-15") "December 25th, 2024")

# =============================================================================
# Section 6: format_relative - compact skips weekday tiers
# =============================================================================

# 6.1
(assert-eq "6.1" ((pt-compact :format-relative) "2025-03-15" "2025-03-15") "today")

# 6.2
(assert-eq "6.2" ((pt-compact :format-relative) "2025-03-16" "2025-03-15") "tomorrow")

# 6.3
(assert-eq "6.3" ((pt-compact :format-relative) "2025-03-19" "2025-03-15") "3/19")

# 6.4
(assert-eq "6.4" ((pt-compact :format-relative) "2026-01-05" "2025-03-15") "1/5/26")

# =============================================================================
# Section 7: Locale - German
# =============================================================================

(def de-locale (sd/get-locale "de"))
(def pt-de (sd/make-formatter de-locale))

# 7.1
(assert-eq "7.1" ((pt-de :format-date) "2025-03-15") "15. März")

# 7.2
(assert-eq "7.2" ((pt-de :format-relative) "2025-03-16" "2025-03-15") "morgen")

# 7.3
(assert-eq "7.3" ((pt-de :format-relative) "2025-03-17" "2025-03-15") "übermorgen")

# 7.4
(assert-eq "7.4" ((pt-de :format-relative) "2025-03-19" "2025-03-15") "diesen Mittwoch")

# =============================================================================
# Section 8: Locale - French
# =============================================================================

(def fr-locale (sd/get-locale "fr"))
(def pt-fr (sd/make-formatter fr-locale))

# 8.1
(assert-eq "8.1" ((pt-fr :format-date) "2025-03-01") "1er mars")

# 8.2
(assert-eq "8.2" ((pt-fr :format-date) "2025-03-15") "15 mars")

# 8.3
(assert-eq "8.3" ((pt-fr :format-relative) "2025-03-16" "2025-03-15") "demain")

# =============================================================================
# Section 9: Locale - Japanese
# =============================================================================

(def ja-locale (sd/get-locale "ja"))
(def pt-ja (sd/make-formatter ja-locale))

# 9.1
(assert-eq "9.1" ((pt-ja :format-date) "2025-03-15") "3月15日")

# 9.2
(assert-eq "9.2" ((pt-ja :format-relative) "2025-03-16" "2025-03-15") "明日")

# 9.3
(assert-eq "9.3" ((pt-ja :format-relative) "2025-03-19" "2025-03-15") "今度の水曜日")

# =============================================================================
# Section 10: Locale - Russian (genitive months)
# =============================================================================

(def ru-locale (sd/get-locale "ru"))
(def pt-ru (sd/make-formatter ru-locale))

# 10.1
(assert-eq "10.1" ((pt-ru :format-date) "2025-03-15") "15 марта")

# 10.2
(assert-eq "10.2" ((pt-ru :format-relative) "2025-03-16" "2025-03-15") "завтра")

# =============================================================================
# Section 11: Locale - Arabic
# =============================================================================

(def ar-locale (sd/get-locale "ar"))
(def pt-ar (sd/make-formatter ar-locale))

# 11.1
(assert-eq "11.1" ((pt-ar :format-date) "2025-03-15") "15 مارس")

# 11.2
(assert-eq "11.2" ((pt-ar :format-relative) "2025-03-16" "2025-03-15") "غداً")

# =============================================================================
# Section 12: Locale - Spanish
# =============================================================================

(def es-locale (sd/get-locale "es"))
(def pt-es (sd/make-formatter es-locale))

# 12.1
(assert-eq "12.1" ((pt-es :format-date) "2025-03-15") "15 de marzo")

# 12.2
(assert-eq "12.2" ((pt-es :format-relative) "2025-03-17" "2025-03-15") "pasado mañana")

# =============================================================================
# Section 13: format_date_with_year
# =============================================================================

# 13.1
(assert-eq "13.1" (((sd/make-formatter (sd/get-locale "en")) :format-date-with-year) "2018-02-04") "February 4th, 2018")

# 13.2
(assert-eq "13.2" (((sd/make-formatter (sd/get-locale "en") "short") :format-date-with-year) "2025-03-15") "Mar 15, 2025")

# 13.3
(assert-eq "13.3" (((sd/make-formatter (sd/get-locale "en") "compact") :format-date-with-year) "1997-01-21") "1/21/97")

# 13.4
(assert-eq "13.4" (((sd/make-formatter (sd/get-locale "tg") "compact") :format-date-with-year) "2007-05-20") "20/5/07")

# 13.5
(assert-eq "13.5" (((sd/make-formatter (sd/get-locale "fi") "short") :format-date-with-year) "1996-06-21") "21. kesäkuuta 1996")

# =============================================================================
# Section 14: Short month names (locales that keep the full genitive)
# =============================================================================

# 14.1
(assert-eq "14.1" (((sd/make-formatter (sd/get-locale "sk") "short") :format-date) "2031-02-15") "15. februára")

# 14.2
(assert-eq "14.2" (((sd/make-formatter (sd/get-locale "cs") "short") :format-date) "2025-12-10") "10. prosince")

# 14.3
(assert-eq "14.3" (((sd/make-formatter (sd/get-locale "uk") "short") :format-date) "2025-11-05") "5 листопада")

# 14.4
(assert-eq "14.4" (((sd/make-formatter (sd/get-locale "fi") "short") :format-relative) "1998-08-08" "1998-08-15") "8. elokuuta")

# =============================================================================
# Section 15: format_relative — short phrases
# =============================================================================

# 15.1
(assert-eq "15.1" (((sd/make-formatter (sd/get-locale "kw") "short") :format-relative) "2035-12-04" "2035-12-02") "an Mth ma")

# 15.2
(assert-eq "15.2" (((sd/make-formatter (sd/get-locale "mam") "short") :format-relative) "2000-01-23" "2000-01-25") "Dom nchi'j")

# 15.3
(assert-eq "15.3" (((sd/make-formatter (sd/get-locale "kek") "short") :format-relative) "2014-10-24" "2014-10-22") "a'in Vie")

# =============================================================================
# Section 16: Input validation
# =============================================================================

# 16.1
(assert-nil "16.1" (((sd/make-formatter (sd/get-locale "en")) :format-date) "2025-02-30"))

# 16.2
(assert-nil "16.2" (((sd/make-formatter (sd/get-locale "en")) :format-date) "2025-13-01"))

# 16.3
(assert-nil "16.3" (((sd/make-formatter (sd/get-locale "en")) :format-date) "2025-6-1"))

# 16.4
(assert-nil "16.4" (((sd/make-formatter (sd/get-locale "en")) :format-date) " 2025-06-01"))

# 16.5
(assert-eq "16.5" (((sd/make-formatter (sd/get-locale "en")) :format-date) "2025-06-01T10:00:00") "June 1st")

# 16.6
(assert-nil "16.6" (((sd/make-formatter (sd/get-locale "en")) :format-date-with-year) "2023-02-29"))

# 16.7
(assert-nil "16.7" (((sd/make-formatter (sd/get-locale "en")) :format-relative) "2025-03-16" "2025-04-31"))

# =============================================================================
# Results
# =============================================================================

(printf "\n%d passed, %d failed, %d total" pass-count fail-count (+ pass-count fail-count))
(when (> fail-count 0)
  (os/exit 1))

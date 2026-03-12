# Test suite for sayable-time Janet implementation.
# Implements all canonical test cases from time/config/tests.json.

(import ./format_time :as st)

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

# =============================================================================
# Section 1: Null / edge cases
# =============================================================================

# 1.1
(assert-nil "1.1" (st/format-time nil))

# 1.2
(assert-nil "1.2" (st/format-time ""))

# 1.3
(assert-nil "1.3" (st/format-time "invalid"))

# 1.4
(assert-nil "1.4" (st/format-time "25:00"))

# =============================================================================
# Section 2: Clock time (normal compactness)
# =============================================================================

# 2.1
(assert-eq "2.1" (st/format-time "00:00") "midnight")

# 2.2
(assert-eq "2.2" (st/format-time "12:00") "noon")

# 2.3
(assert-eq "2.3" (st/format-time "15:00") "three o'clock")

# 2.4
(assert-eq "2.4" (st/format-time "14:15") "a quarter past two")

# 2.5
(assert-eq "2.5" (st/format-time "09:30") "half past nine")

# 2.6
(assert-eq "2.6" (st/format-time "10:45") "a quarter to eleven")

# 2.7
(assert-eq "2.7" (st/format-time "08:05") "five past eight")

# 2.8
(assert-eq "2.8" (st/format-time "16:55") "five to five")

# 2.9
(assert-eq "2.9" (st/format-time "23:58") "midnight")

# 2.10
(assert-eq "2.10" (st/format-time "07:22") "twenty past seven")

# 2.11
(assert-eq "2.11" (st/format-time "2025-01-15T14:15:00") "a quarter past two")

# =============================================================================
# Section 3: Clock time (short compactness)
# =============================================================================

(def en-locale (st/get-locale "en"))
(def pt-short (st/make-formatter en-locale "short"))

# 3.1
(assert-eq "3.1" ((pt-short :format-time) "14:15") "2:15 PM")

# 3.2
(assert-eq "3.2" ((pt-short :format-time) "09:30") "9:30 AM")

# 3.3
(assert-eq "3.3" ((pt-short :format-time) "00:00") "12:00 AM")

# 3.4
(assert-eq "3.4" ((pt-short :format-time) "12:00") "12:00 PM")

# =============================================================================
# Section 4: Clock time (compact)
# =============================================================================

(def pt-compact (st/make-formatter en-locale "compact"))

# 4.1
(assert-eq "4.1" ((pt-compact :format-time) "14:15") "2:15p")

# 4.2
(assert-eq "4.2" ((pt-compact :format-time) "09:30") "9:30a")

# =============================================================================
# Section 5: Locale - German
# =============================================================================

(def de-locale (st/get-locale "de"))
(def pt-de (st/make-formatter de-locale))

# 5.1
(assert-eq "5.1" ((pt-de :format-time) "15:30") "halb vier")

# =============================================================================
# Section 6: Locale - French
# =============================================================================

(def fr-locale (st/get-locale "fr"))
(def pt-fr (st/make-formatter fr-locale))

# 6.1
(assert-eq "6.1" ((pt-fr :format-time) "15:15") "trois heures et quart")

# =============================================================================
# Section 7: Locale - Japanese
# =============================================================================

(def ja-locale (st/get-locale "ja"))
(def pt-ja (st/make-formatter ja-locale))

# 7.1
(assert-eq "7.1" ((pt-ja :format-time) "15:30") "三時半")

# =============================================================================
# Section 8: Locale - Finnish (dot separator, short)
# =============================================================================

(def fi-locale (st/get-locale "fi"))
(def pt-fi-short (st/make-formatter fi-locale "short"))

# 8.1
(assert-eq "8.1" ((pt-fi-short :format-time) "14:15") "14.15")

# 8.2
(assert-eq "8.2" ((pt-fi-short :format-time) "00:00") "0.00")

# =============================================================================
# Results
# =============================================================================

(printf "\n%d passed, %d failed, %d total" pass-count fail-count (+ pass-count fail-count))
(when (> fail-count 0)
  (os/exit 1))

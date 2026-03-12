# Test suite for sayable-duration Janet implementation.
# Implements all canonical test cases from duration/config/tests.json.

(import ./format_duration :as sd)

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
(assert-nil "1.1" (sd/format-duration nil))

# 1.2
(assert-nil "1.2" (sd/format-duration -1))

# 1.3
(assert-nil "1.3" (sd/format-since nil "2025-01-15T10:00:00"))

# 1.4
(assert-nil "1.4" (sd/format-until nil "2025-01-15T10:00:00"))

# 1.5
(assert-nil "1.5" (sd/format-since "2025-01-15T10:00:00" "2025-01-15T09:00:00"))

# 1.6
(assert-nil "1.6" (sd/format-until "2025-01-15T09:00:00" "2025-01-15T10:00:00"))

# =============================================================================
# Section 2: Duration - seconds tier (0-59s)
# =============================================================================

# 2.1
(assert-eq "2.1" (sd/format-duration 0) "just now")

# 2.2
(assert-eq "2.2" (sd/format-duration 1) "1 second")

# 2.3
(assert-eq "2.3" (sd/format-duration 45) "45 seconds")

# 2.4
(assert-eq "2.4" (sd/format-duration 59) "59 seconds")

# =============================================================================
# Section 3: Duration - minutes + seconds tier (1-4 min)
# =============================================================================

# 3.1
(assert-eq "3.1" (sd/format-duration 60) "1 minute")

# 3.2
(assert-eq "3.2" (sd/format-duration 90) "1 minute, 30 seconds")

# 3.3
(assert-eq "3.3" (sd/format-duration 240) "4 minutes")

# 3.4
(assert-eq "3.4" (sd/format-duration 270) "4 minutes, 30 seconds")

# =============================================================================
# Section 4: Duration - minutes tier (5-59 min)
# =============================================================================

# 4.1
(assert-eq "4.1" (sd/format-duration 300) "5 minutes")

# 4.2
(assert-eq "4.2" (sd/format-duration 1500) "25 minutes")

# 4.3
(assert-eq "4.3" (sd/format-duration 3540) "59 minutes")

# =============================================================================
# Section 5: Duration - hours + minutes tier (1-5 hr)
# =============================================================================

# 5.1
(assert-eq "5.1" (sd/format-duration 3600) "1 hour")

# 5.2
(assert-eq "5.2" (sd/format-duration 5400) "1½ hours")

# 5.3
(assert-eq "5.3" (sd/format-duration 8100) "2 hours, 15 minutes")

# 5.4
(assert-eq "5.4" (sd/format-duration 18000) "5 hours")

# =============================================================================
# Section 6: Duration - hours tier (6-23 hr)
# =============================================================================

# 6.1
(assert-eq "6.1" (sd/format-duration 28800) "8 hours")

# 6.2
(assert-eq "6.2" (sd/format-duration 82800) "23 hours")

# =============================================================================
# Section 7: Duration - days tier
# =============================================================================

# 7.1
(assert-eq "7.1" (sd/format-duration 86400) "1 day")

# 7.2
(assert-eq "7.2" (sd/format-duration 97200) "1 day, 3 hours")

# 7.3
(assert-eq "7.3" (sd/format-duration 129600) "1½ days")

# 7.4
(assert-eq "7.4" (sd/format-duration 432000) "5 days")

# 7.5
(assert-eq "7.5" (sd/format-duration 172800) "2 days")

# =============================================================================
# Section 8: Duration - weeks tier
# =============================================================================

# 8.1
(assert-eq "8.1" (sd/format-duration 604800) "1 week")

# 8.2
(assert-eq "8.2" (sd/format-duration 1296000) "2 weeks, 1 day")

# 8.3
(assert-eq "8.3" (sd/format-duration 2419200) "4 weeks")

# =============================================================================
# Section 9: Duration - months and years tier
# =============================================================================

# 9.1
(assert-eq "9.1" (sd/format-duration 2678400) "1 month")

# 9.2
(assert-eq "9.2" (sd/format-duration 7884000) "3 months")

# 9.3
(assert-eq "9.3" (sd/format-duration 31536000) "1 year")

# 9.4
(assert-eq "9.4" (sd/format-duration 39420000) "1 year, 3 months")

# =============================================================================
# Section 10: Duration from ISO timestamps
# =============================================================================

# 10.1
(assert-eq "10.1" (sd/format-duration "2025-01-15T10:00:00" "2025-01-15T11:30:00") "1½ hours")

# 10.2
(assert-eq "10.2" (sd/format-duration "2025-01-15T10:00:00" "2025-01-15T10:45:00") "45 minutes")

# =============================================================================
# Section 11: Relative time - since
# =============================================================================

# 11.1
(assert-eq "11.1" (sd/format-since "2025-01-15T10:00:00" "2025-01-15T10:00:00") "just now")

# 11.2
(assert-eq "11.2" (sd/format-since "2025-01-15T10:00:00" "2025-01-15T10:00:30") "30 seconds ago")

# 11.3
(assert-eq "11.3" (sd/format-since "2025-01-15T10:00:00" "2025-01-15T10:45:00") "45 minutes ago")

# 11.4
(assert-eq "11.4" (sd/format-since "2025-01-15T10:00:00" "2025-01-15T13:00:00") "3 hours ago")

# =============================================================================
# Section 12: Relative time - until
# =============================================================================

# 12.1
(assert-eq "12.1" (sd/format-until "2025-01-15T10:00:00" "2025-01-15T10:00:00") "just now")

# 12.2
(assert-eq "12.2" (sd/format-until "2025-01-15T10:20:00" "2025-01-15T10:00:00") "in 20 minutes")

# 12.3
(assert-eq "12.3" (sd/format-until "2025-01-15T13:00:00" "2025-01-15T10:00:00") "in 3 hours")

# =============================================================================
# Section 13: Locale - German
# =============================================================================

(def de-locale (sd/get-locale "de"))
(def pt-de (sd/make-formatter de-locale))

# 13.1
(assert-eq "13.1" ((pt-de :format-duration) 3600) "1 Stunde")

# 13.2
(assert-eq "13.2" ((pt-de :format-since) "2025-01-15T10:00:00" "2025-01-15T10:05:00") "vor 5 Minuten")

# =============================================================================
# Section 14: Locale - French
# =============================================================================

(def fr-locale (sd/get-locale "fr"))
(def pt-fr (sd/make-formatter fr-locale))

# 14.1
(assert-eq "14.1" ((pt-fr :format-duration) 7200) "2 heures")

# =============================================================================
# Section 15: Locale - Japanese
# =============================================================================

(def ja-locale (sd/get-locale "ja"))
(def pt-ja (sd/make-formatter ja-locale))

# 15.1
(assert-eq "15.1" ((pt-ja :format-duration) 120) "2分")

# 15.2
(assert-eq "15.2" ((pt-ja :format-since) "2025-01-15T10:00:00" "2025-01-15T11:00:00") "1時間前")

# =============================================================================
# Section 16: Short compactness - duration
# =============================================================================

(def en-locale (sd/get-locale "en"))
(def pt-short (sd/make-formatter en-locale "short"))

# 16.1
(assert-eq "16.1" ((pt-short :format-duration) 3600) "1h")

# 16.2
(assert-eq "16.2" ((pt-short :format-duration) 90) "1m, 30s")

# =============================================================================
# Section 17: Compact compactness - duration
# =============================================================================

(def pt-compact (sd/make-formatter en-locale "compact"))

# 17.1
(assert-eq "17.1" ((pt-compact :format-duration) 3600) "1h")

# 17.2
(assert-eq "17.2" ((pt-compact :format-duration) 90) "1m30s")

# =============================================================================
# Results
# =============================================================================

(printf "\n%d passed, %d failed, %d total" pass-count fail-count (+ pass-count fail-count))
(when (> fail-count 0)
  (os/exit 1))

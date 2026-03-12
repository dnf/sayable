#lang racket

(require rackunit
         "format-duration.rkt"
         "locale.rkt"
         "locales/registry.rkt")

;; Section 1: Null / edge cases
;; 1.1
(check-false (format-duration (get-locale "en") #f))
;; 1.2
(check-false (format-duration (get-locale "en") -1))
;; 1.3
(check-false (format-since (get-locale "en") #f "2025-01-15T10:00:00"))
;; 1.4
(check-false (format-until (get-locale "en") #f "2025-01-15T10:00:00"))
;; 1.5 — asOf before start
(check-false (format-since (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T09:00:00"))
;; 1.6 — target in the past
(check-false (format-until (get-locale "en") "2025-01-15T09:00:00" "2025-01-15T10:00:00"))

;; Section 2: Duration -- seconds tier (0-59s)
;; 2.1
(check-equal? (format-duration (get-locale "en") 0) "just now")
;; 2.2
(check-equal? (format-duration (get-locale "en") 1) "1 second")
;; 2.3
(check-equal? (format-duration (get-locale "en") 45) "45 seconds")
;; 2.4
(check-equal? (format-duration (get-locale "en") 59) "59 seconds")

;; Section 3: Duration -- minutes + seconds tier (1-4 min)
;; 3.1
(check-equal? (format-duration (get-locale "en") 60) "1 minute")
;; 3.2
(check-equal? (format-duration (get-locale "en") 90) "1 minute, 30 seconds")
;; 3.3
(check-equal? (format-duration (get-locale "en") 240) "4 minutes")
;; 3.4
(check-equal? (format-duration (get-locale "en") 270) "4 minutes, 30 seconds")

;; Section 4: Duration -- minutes tier (5-59 min)
;; 4.1
(check-equal? (format-duration (get-locale "en") 300) "5 minutes")
;; 4.2
(check-equal? (format-duration (get-locale "en") 1500) "25 minutes")
;; 4.3
(check-equal? (format-duration (get-locale "en") 3540) "59 minutes")

;; Section 5: Duration -- hours + minutes tier (1-5 hr)
;; 5.1
(check-equal? (format-duration (get-locale "en") 3600) "1 hour")
;; 5.2
(check-equal? (format-duration (get-locale "en") 5400) "1\u00bd hours")
;; 5.3
(check-equal? (format-duration (get-locale "en") 8100) "2 hours, 15 minutes")
;; 5.4
(check-equal? (format-duration (get-locale "en") 18000) "5 hours")

;; Section 6: Duration -- hours tier (6-23 hr)
;; 6.1
(check-equal? (format-duration (get-locale "en") 28800) "8 hours")
;; 6.2
(check-equal? (format-duration (get-locale "en") 82800) "23 hours")

;; Section 7: Duration -- days tier
;; 7.1
(check-equal? (format-duration (get-locale "en") 86400) "1 day")
;; 7.2
(check-equal? (format-duration (get-locale "en") 97200) "1 day, 3 hours")
;; 7.3
(check-equal? (format-duration (get-locale "en") 129600) "1\u00bd days")
;; 7.4
(check-equal? (format-duration (get-locale "en") 432000) "5 days")
;; 7.5
(check-equal? (format-duration (get-locale "en") 172800) "2 days")

;; Section 8: Duration -- weeks tier
;; 8.1
(check-equal? (format-duration (get-locale "en") 604800) "1 week")
;; 8.2
(check-equal? (format-duration (get-locale "en") 1296000) "2 weeks, 1 day")
;; 8.3
(check-equal? (format-duration (get-locale "en") 2419200) "4 weeks")

;; Section 9: Duration -- months and years tier
;; 9.1
(check-equal? (format-duration (get-locale "en") 2678400) "1 month")
;; 9.2
(check-equal? (format-duration (get-locale "en") 7884000) "3 months")
;; 9.3
(check-equal? (format-duration (get-locale "en") 31536000) "1 year")
;; 9.4
(check-equal? (format-duration (get-locale "en") 39420000) "1 year, 3 months")

;; Section 10: Duration from ISO timestamps
;; 10.1
(check-equal? (format-duration (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T11:30:00") "1\u00bd hours")
;; 10.2
(check-equal? (format-duration (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T10:45:00") "45 minutes")

;; Section 11: Relative time -- since
;; 11.1
(check-equal? (format-since (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T10:00:00") "just now")
;; 11.2
(check-equal? (format-since (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T10:00:30") "30 seconds ago")
;; 11.3
(check-equal? (format-since (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T10:45:00") "45 minutes ago")
;; 11.4
(check-equal? (format-since (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T13:00:00") "3 hours ago")

;; Section 12: Relative time -- until
;; 12.1
(check-equal? (format-until (get-locale "en") "2025-01-15T10:00:00" "2025-01-15T10:00:00") "just now")
;; 12.2
(check-equal? (format-until (get-locale "en") "2025-01-15T10:20:00" "2025-01-15T10:00:00") "in 20 minutes")
;; 12.3
(check-equal? (format-until (get-locale "en") "2025-01-15T13:00:00" "2025-01-15T10:00:00") "in 3 hours")

;; Section 13: Locale -- German
;; 13.1
(check-equal? (format-duration (get-locale "de") 3600) "1 Stunde")
;; 13.2
(check-equal? (format-since (get-locale "de") "2025-01-15T10:00:00" "2025-01-15T10:05:00") "vor 5 Minuten")

;; Section 14: Locale -- French
;; 14.1
(check-equal? (format-duration (get-locale "fr") 7200) "2 heures")

;; Section 15: Locale -- Japanese
;; 15.1
(check-equal? (format-duration (get-locale "ja") 120) "2\u5206")
;; 15.2
(check-equal? (format-since (get-locale "ja") "2025-01-15T10:00:00" "2025-01-15T11:00:00") "1\u6642\u9593\u524d")

;; Section 16: Short compactness -- duration
;; 16.1
(check-equal? (format-duration (get-locale "en") 3600 #f #:compactness 'short) "1h")
;; 16.2
(check-equal? (format-duration (get-locale "en") 90 #f #:compactness 'short) "1m, 30s")

;; Section 17: Compact compactness -- duration
;; 17.1
(check-equal? (format-duration (get-locale "en") 3600 #f #:compactness 'compact) "1h")
;; 17.2
(check-equal? (format-duration (get-locale "en") 90 #f #:compactness 'compact) "1m30s")

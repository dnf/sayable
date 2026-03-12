#lang racket

(require rackunit
         "format-time.rkt"
         "locale.rkt"
         "locales/registry.rkt")

;; Section 1: Null / edge cases
;; 1.1
(check-false (format-time (get-locale "en") #f))
;; 1.2
(check-false (format-time (get-locale "en") ""))
;; 1.3
(check-false (format-time (get-locale "en") "invalid"))
;; 1.4
(check-false (format-time (get-locale "en") "25:00"))

;; Section 2: Clock time (normal compactness)
;; 2.1
(check-equal? (format-time (get-locale "en") "00:00") "midnight")
;; 2.2
(check-equal? (format-time (get-locale "en") "12:00") "noon")
;; 2.3
(check-equal? (format-time (get-locale "en") "15:00") "three o'clock")
;; 2.4
(check-equal? (format-time (get-locale "en") "14:15") "a quarter past two")
;; 2.5
(check-equal? (format-time (get-locale "en") "09:30") "half past nine")
;; 2.6
(check-equal? (format-time (get-locale "en") "10:45") "a quarter to eleven")
;; 2.7
(check-equal? (format-time (get-locale "en") "08:05") "five past eight")
;; 2.8
(check-equal? (format-time (get-locale "en") "16:55") "five to five")
;; 2.9 — 23:58 rounds to 0:00 of next day
(check-equal? (format-time (get-locale "en") "23:58") "midnight")
;; 2.10 — 22 rounds to 20
(check-equal? (format-time (get-locale "en") "07:22") "twenty past seven")
;; 2.11 — ISO datetime input
(check-equal? (format-time (get-locale "en") "2025-01-15T14:15:00") "a quarter past two")

;; Section 3: Clock time (short compactness)
;; 3.1
(check-equal? (format-time (get-locale "en") "14:15" 'short) "2:15 PM")
;; 3.2
(check-equal? (format-time (get-locale "en") "09:30" 'short) "9:30 AM")
;; 3.3
(check-equal? (format-time (get-locale "en") "00:00" 'short) "12:00 AM")
;; 3.4
(check-equal? (format-time (get-locale "en") "12:00" 'short) "12:00 PM")

;; Section 4: Clock time (compact)
;; 4.1
(check-equal? (format-time (get-locale "en") "14:15" 'compact) "2:15p")
;; 4.2
(check-equal? (format-time (get-locale "en") "09:30" 'compact) "9:30a")

;; Section 5: Locale -- German
;; 5.1
(check-equal? (format-time (get-locale "de") "15:30") "halb vier")

;; Section 6: Locale -- French
;; 6.1
(check-equal? (format-time (get-locale "fr") "15:15") "trois heures et quart")

;; Section 7: Locale -- Japanese
;; 7.1
(check-equal? (format-time (get-locale "ja") "15:30") "\u4e09\u6642\u534a")

;; Section 8: Locale -- Finnish (dot separator, short)
;; 8.1
(check-equal? (format-time (get-locale "fi") "14:15" 'short) "14.15")
;; 8.2
(check-equal? (format-time (get-locale "fi") "00:00" 'short) "0.00")

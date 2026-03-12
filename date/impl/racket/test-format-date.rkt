#lang racket

(require rackunit
         "format-date.rkt"
         "locale.rkt"
         "locales/registry.rkt")

;; Section 1: Null / edge cases
;; 1.1
(check-false (format-date (get-locale "en") #f))
;; 1.2
(check-false (format-date (get-locale "en") ""))
;; 1.3
(check-false (format-date (get-locale "en") "invalid"))
;; 1.4
(check-false (format-relative (get-locale "en") "2025-03-15" #f))
;; 1.5
(check-false (format-relative (get-locale "en") #f "2025-03-15"))

;; Section 2: format_date -- normal compactness (English)
;; 2.1
(check-equal? (format-date (get-locale "en") "2025-03-15") "March 15th")
;; 2.2
(check-equal? (format-date (get-locale "en") "2025-01-01") "January 1st")
;; 2.3
(check-equal? (format-date (get-locale "en") "2025-05-22") "May 22nd")
;; 2.4
(check-equal? (format-date (get-locale "en") "2025-07-03") "July 3rd")
;; 2.5
(check-equal? (format-date (get-locale "en") "2025-12-31") "December 31st")
;; 2.6
(check-equal? (format-date (get-locale "en") "2025-06-11") "June 11th")
;; 2.7
(check-equal? (format-date (get-locale "en") "2025-03-15T14:30:00") "March 15th")

;; Section 3: format_date -- short compactness (English)
;; 3.1
(check-equal? (format-date (get-locale "en") "2025-03-15" 'short) "Mar 15")
;; 3.2
(check-equal? (format-date (get-locale "en") "2025-01-01" 'short) "Jan 1")
;; 3.3
(check-equal? (format-date (get-locale "en") "2025-12-25" 'short) "Dec 25")

;; Section 4: format_date -- compact (English)
;; 4.1
(check-equal? (format-date (get-locale "en") "2025-03-15" 'compact) "3/15")
;; 4.2
(check-equal? (format-date (get-locale "en") "2025-01-01" 'compact) "1/1")

;; Section 5: format_relative -- proximity tiers (English)
;; 5.1
(check-equal? (format-relative (get-locale "en") "2025-03-15" "2025-03-15") "today")
;; 5.2
(check-equal? (format-relative (get-locale "en") "2025-03-16" "2025-03-15") "tomorrow")
;; 5.3
(check-equal? (format-relative (get-locale "en") "2025-03-14" "2025-03-15") "yesterday")
;; 5.4
(check-equal? (format-relative (get-locale "en") "2025-03-17" "2025-03-15") "the day after tomorrow")
;; 5.5
(check-equal? (format-relative (get-locale "en") "2025-03-13" "2025-03-15") "the day before yesterday")
;; 5.6
(check-equal? (format-relative (get-locale "en") "2025-03-19" "2025-03-15") "this Wednesday")
;; 5.7
(check-equal? (format-relative (get-locale "en") "2025-03-20" "2025-03-15") "this Thursday")
;; 5.8
(check-equal? (format-relative (get-locale "en") "2025-03-11" "2025-03-15") "last Tuesday")
;; 5.9
(check-equal? (format-relative (get-locale "en") "2025-03-22" "2025-03-15") "next Saturday")
;; 5.10
(check-equal? (format-relative (get-locale "en") "2025-03-27" "2025-03-15") "next Thursday")
;; 5.11
(check-equal? (format-relative (get-locale "en") "2025-03-01" "2025-03-15") "March 1st")
;; 5.12
(check-equal? (format-relative (get-locale "en") "2025-04-10" "2025-03-15") "April 10th")
;; 5.13
(check-equal? (format-relative (get-locale "en") "2026-01-05" "2025-03-15") "January 5th, 2026")
;; 5.14
(check-equal? (format-relative (get-locale "en") "2024-12-25" "2025-03-15") "December 25th, 2024")

;; Section 6: format_relative -- compact skips weekday tiers
;; 6.1
(check-equal? (format-relative (get-locale "en") "2025-03-15" "2025-03-15" 'compact) "today")
;; 6.2
(check-equal? (format-relative (get-locale "en") "2025-03-16" "2025-03-15" 'compact) "tomorrow")
;; 6.3
(check-equal? (format-relative (get-locale "en") "2025-03-19" "2025-03-15" 'compact) "3/19")
;; 6.4
(check-equal? (format-relative (get-locale "en") "2026-01-05" "2025-03-15" 'compact) "1/5/26")

;; Section 7: Locale -- German
;; 7.1
(check-equal? (format-date (get-locale "de") "2025-03-15") "15. M\u00e4rz")
;; 7.2
(check-equal? (format-relative (get-locale "de") "2025-03-16" "2025-03-15") "morgen")
;; 7.3
(check-equal? (format-relative (get-locale "de") "2025-03-17" "2025-03-15") "\u00fcbermorgen")
;; 7.4
(check-equal? (format-relative (get-locale "de") "2025-03-19" "2025-03-15") "diesen Mittwoch")

;; Section 8: Locale -- French
;; 8.1
(check-equal? (format-date (get-locale "fr") "2025-03-01") "1er mars")
;; 8.2
(check-equal? (format-date (get-locale "fr") "2025-03-15") "15 mars")
;; 8.3
(check-equal? (format-relative (get-locale "fr") "2025-03-16" "2025-03-15") "demain")

;; Section 9: Locale -- Japanese
;; 9.1
(check-equal? (format-date (get-locale "ja") "2025-03-15") "3\u670815\u65e5")
;; 9.2
(check-equal? (format-relative (get-locale "ja") "2025-03-16" "2025-03-15") "\u660e\u65e5")
;; 9.3
(check-equal? (format-relative (get-locale "ja") "2025-03-19" "2025-03-15") "\u4eca\u5ea6\u306e\u6c34\u66dc\u65e5")

;; Section 10: Locale -- Russian (genitive months)
;; 10.1
(check-equal? (format-date (get-locale "ru") "2025-03-15") "15 \u043c\u0430\u0440\u0442\u0430")
;; 10.2
(check-equal? (format-relative (get-locale "ru") "2025-03-16" "2025-03-15") "\u0437\u0430\u0432\u0442\u0440\u0430")

;; Section 11: Locale -- Arabic
;; 11.1
(check-equal? (format-date (get-locale "ar") "2025-03-15") "15 \u0645\u0627\u0631\u0633")
;; 11.2
(check-equal? (format-relative (get-locale "ar") "2025-03-16" "2025-03-15") "\u063a\u062f\u0627\u064b")

;; Section 12: Locale -- Spanish
;; 12.1
(check-equal? (format-date (get-locale "es") "2025-03-15") "15 de marzo")
;; 12.2
(check-equal? (format-relative (get-locale "es") "2025-03-17" "2025-03-15") "pasado ma\u00f1ana")

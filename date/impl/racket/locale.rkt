#lang racket

(provide (struct-out date-compactness-override)
         (struct-out date-locale))

;; Optional overrides for short/compact display modes.
;; #f fields mean "use the base locale value."
(struct date-compactness-override
  (months months-in-date weekdays day-format day-format-exceptions
   date-pattern date-pattern-with-year today tomorrow yesterday)
  #:transparent)

;; All locale-specific data for date formatting.
(struct date-locale
  (code months weekdays day-format day-format-exceptions
   date-pattern date-pattern-with-year
   today tomorrow yesterday
   day-after-tomorrow day-before-yesterday
   this-weekday next-weekday last-weekday
   months-in-date
   short-override compact-override)
  #:transparent)

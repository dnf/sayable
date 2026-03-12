#lang racket

(provide (struct-out stage-label)
         (struct-out compactness-override)
         (struct-out age-locale)
         resolve-stage)

;; A stage label that may be gender-neutral or gendered.
;; If label is non-#f, it is gender-neutral.
;; If m and f are non-#f, the label is gendered.
(struct stage-label (label m f) #:transparent)

;; Optional overrides for short/compact display modes.
;; #f fields mean "use the base locale value."
(struct compactness-override (day week month year half delimiter just-born) #:transparent)

;; All locale-specific data for age formatting.
(struct age-locale (code plural units half delimiter just-born stages short-override compact-override) #:transparent)

;; Resolve a stage label given a gender string ("m", "f", or "").
(define (resolve-stage sl gender)
  (if (stage-label-m sl)
      (if (equal? gender "f")
          (stage-label-f sl)
          (stage-label-m sl))
      (stage-label-label sl)))

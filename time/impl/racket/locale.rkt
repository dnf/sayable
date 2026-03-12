#lang racket

(provide (struct-out clock-config)
         (struct-out short-clock-config)
         (struct-out time-compactness-override)
         (struct-out time-locale))

;; Natural language clock reading configuration.
(struct clock-config (hours midnight noon patterns) #:transparent)

;; Digital clock display configuration for short/compact modes.
;; am-pm is either #f or a pair (cons am pm).
(struct short-clock-config (use24h format am-pm) #:transparent)

;; Optional overrides for short/compact display modes.
(struct time-compactness-override (clock) #:transparent)

;; Locale definition for clock time formatting.
(struct time-locale (code clock short-override compact-override) #:transparent)

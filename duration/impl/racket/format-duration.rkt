#lang racket

(require "locale.rkt")

(provide format-duration
         format-since
         format-until
         version)

(define version "0.5.0")

;; ---- ISO datetime parsing ----

(define (leap-year? y)
  (or (and (= (remainder y 4) 0)
           (not (= (remainder y 100) 0)))
      (= (remainder y 400) 0)))

(define (days-in-month y m)
  (cond
    [(member m '(1 3 5 7 8 10 12)) 31]
    [(member m '(4 6 9 11)) 30]
    [(= m 2) (if (leap-year? y) 29 28)]
    [else 30]))

(define (days-since-epoch year month day)
  "Calculate days since 2000-01-01."
  (let ([days 0])
    (let ([days (if (>= year 2000)
                    (for/fold ([d 0]) ([y (in-range 2000 year)])
                      (+ d (if (leap-year? y) 366 365)))
                    (- (for/fold ([d 0]) ([y (in-range year 2000)])
                         (+ d (if (leap-year? y) 366 365)))))])
      (let ([days (for/fold ([d days]) ([m (in-range 1 month)])
                    (+ d (days-in-month year m)))])
        (+ days day -1)))))

(define (parse-iso-to-seconds iso-str)
  "Parse ISO datetime string to epoch-ish seconds for diffing. Returns #f on failure."
  (if (or (not iso-str) (not (string? iso-str)) (equal? iso-str ""))
      #f
      (with-handlers ([exn:fail? (lambda (_) #f)])
        (let* ([parts (string-split iso-str "T")]
               [date-part (car parts)]
               [time-part (if (> (length parts) 1) (cadr parts) "0:0:0")]
               [dp (string-split date-part "-")]
               [year (string->number (list-ref dp 0))]
               [month (string->number (list-ref dp 1))]
               [day (string->number (list-ref dp 2))]
               ;; Strip timezone info
               [time-str (car (string-split time-part "+"))]
               [time-str (car (string-split time-str "Z"))]
               [tp (string-split time-str ":")]
               [hour (string->number (list-ref tp 0))]
               [minute (if (> (length tp) 1) (string->number (list-ref tp 1)) 0)]
               [second (if (> (length tp) 2)
                           (string->number (car (string-split (list-ref tp 2) ".")))
                           0)]
               [days (days-since-epoch year month day)])
          (+ (* days 86400) (* hour 3600) (* minute 60) second)))))

;; ---- Pick override value ----

(define (pick ovr accessor default)
  (if ovr
      (let ([val (accessor ovr)])
        (if val val default))
      default))

;; ---- Effective values ----

(define (effective-unit locale compactness unit-key)
  (let* ([ovr (cond
                [(equal? compactness 'short) (duration-locale-short-override locale)]
                [(equal? compactness 'compact) (duration-locale-compact-override locale)]
                [else #f])]
         [ovr-unit (and ovr
                        (case unit-key
                          [("second") (duration-compactness-override-second ovr)]
                          [("minute") (duration-compactness-override-minute ovr)]
                          [("hour") (duration-compactness-override-hour ovr)]
                          [("day") (duration-compactness-override-day ovr)]
                          [("week") (duration-compactness-override-week ovr)]
                          [("month") (duration-compactness-override-month ovr)]
                          [("year") (duration-compactness-override-year ovr)]
                          [else #f]))])
    (or ovr-unit (hash-ref (duration-locale-units locale) unit-key))))

(define (effective-half locale compactness)
  (let ([ovr (cond
               [(equal? compactness 'short) (duration-locale-short-override locale)]
               [(equal? compactness 'compact) (duration-locale-compact-override locale)]
               [else #f])])
    (pick ovr duration-compactness-override-half (duration-locale-half locale))))

(define (effective-delimiter locale compactness)
  (let ([ovr (cond
               [(equal? compactness 'short) (duration-locale-short-override locale)]
               [(equal? compactness 'compact) (duration-locale-compact-override locale)]
               [else #f])])
    (pick ovr duration-compactness-override-delimiter (duration-locale-delimiter locale))))

(define (effective-ago locale compactness)
  (let ([ovr (cond
               [(equal? compactness 'short) (duration-locale-short-override locale)]
               [(equal? compactness 'compact) (duration-locale-compact-override locale)]
               [else #f])])
    (pick ovr duration-compactness-override-ago (duration-locale-ago locale))))

(define (effective-in-future locale compactness)
  (let ([ovr (cond
               [(equal? compactness 'short) (duration-locale-short-override locale)]
               [(equal? compactness 'compact) (duration-locale-compact-override locale)]
               [else #f])])
    (pick ovr duration-compactness-override-in-future (duration-locale-in-future locale))))

;; ---- Duration tier formatting ----

(define (format-duration-seconds total locale compactness)
  "Apply duration tiers to total seconds."
  (let ([sec-unit (effective-unit locale compactness "second")]
        [min-unit (effective-unit locale compactness "minute")]
        [hr-unit (effective-unit locale compactness "hour")]
        [day-unit (effective-unit locale compactness "day")]
        [wk-unit (effective-unit locale compactness "week")]
        [mo-unit (effective-unit locale compactness "month")]
        [yr-unit (effective-unit locale compactness "year")]
        [half (effective-half locale compactness)]
        [delimiter (effective-delimiter locale compactness)])

    (cond
      ;; 0 seconds
      [(= total 0) (duration-locale-just-now locale)]

      ;; 1-59 seconds
      [(< total 60)
       (resolve-unit total sec-unit locale)]

      ;; 1-4 minutes: minutes + seconds
      [(< (quotient total 60) 5)
       (let* ([total-min (quotient total 60)]
              [rem-sec (remainder total 60)]
              [result (resolve-unit total-min min-unit locale)])
         (if (> rem-sec 0)
             (string-append result delimiter (resolve-unit rem-sec sec-unit locale))
             result))]

      ;; 5-59 minutes
      [(< (quotient total 60) 60)
       (resolve-unit (quotient total 60) min-unit locale)]

      ;; 1-5 hours: hours + minutes (with half marker)
      [(<= (quotient total 3600) 5)
       (let* ([total-hours (quotient total 3600)]
              [rem-min (quotient (remainder total 3600) 60)])
         (cond
           [(= rem-min 30)
            (resolve-unit total-hours hr-unit locale half)]
           [(> rem-min 0)
            (string-append (resolve-unit total-hours hr-unit locale)
                           delimiter
                           (resolve-unit rem-min min-unit locale))]
           [else
            (resolve-unit total-hours hr-unit locale)]))]

      ;; 6-23 hours
      [(< (quotient total 3600) 24)
       (resolve-unit (quotient total 3600) hr-unit locale)]

      ;; 1-2 days: days + hours (with half marker)
      [(<= (quotient total 86400) 2)
       (let* ([total-days (quotient total 86400)]
              [rem-hours (quotient (remainder total 86400) 3600)])
         (cond
           [(= rem-hours 12)
            (resolve-unit total-days day-unit locale half)]
           [(> rem-hours 0)
            (string-append (resolve-unit total-days day-unit locale)
                           delimiter
                           (resolve-unit rem-hours hr-unit locale))]
           [else
            (resolve-unit total-days day-unit locale)]))]

      ;; 3-6 days
      [(< (quotient total 86400) 7)
       (resolve-unit (quotient total 86400) day-unit locale)]

      ;; 1-4 weeks: weeks + days (up to 29 days)
      [(< (quotient total 86400) 30)
       (let* ([total-days (quotient total 86400)]
              [total-weeks (quotient total-days 7)]
              [rem-days (remainder total-days 7)]
              [result (resolve-unit total-weeks wk-unit locale)])
         (if (> rem-days 0)
             (string-append result delimiter (resolve-unit rem-days day-unit locale))
             result))]

      ;; Months and years
      [else
       (let* ([total-days (quotient total 86400)]
              [total-months (inexact->exact (round (/ total-days 30.44)))]
              [total-months (if (= total-months 0) 1 total-months)])
         (if (< total-months 12)
             (resolve-unit total-months mo-unit locale)
             (let* ([total-years (quotient total-months 12)]
                    [rem-months (remainder total-months 12)]
                    [result (resolve-unit total-years yr-unit locale)])
               (if (> rem-months 0)
                   (string-append result delimiter (resolve-unit rem-months mo-unit locale))
                   result))))])))

;; ---- Public API ----

(define (format-duration locale start-or-seconds [end #f] #:compactness [compactness 'normal])
  "Format a duration in human-friendly terms.
   start-or-seconds: Either seconds (integer) or ISO datetime start string.
   end: ISO datetime end (required if start-or-seconds is a string).
   Returns #f if inputs are invalid."
  (cond
    [(not start-or-seconds) #f]
    [(integer? start-or-seconds)
     (if (< start-or-seconds 0)
         #f
         (format-duration-seconds start-or-seconds locale compactness))]
    [(string? start-or-seconds)
     (if (not end)
         #f
         (let ([s (parse-iso-to-seconds start-or-seconds)]
               [e (parse-iso-to-seconds end)])
           (if (or (not s) (not e))
               #f
               (format-duration-seconds (abs (- e s)) locale compactness))))]
    [else #f]))

(define (format-since locale start as-of [compactness 'normal])
  "Format elapsed time as 'X ago'. Returns #f if invalid."
  (if (or (not start) (not (string? start)) (equal? start "")
          (not as-of) (not (string? as-of)) (equal? as-of ""))
      #f
      (let ([s (parse-iso-to-seconds start)]
            [a (parse-iso-to-seconds as-of)])
        (if (or (not s) (not a))
            #f
            (let ([diff (- a s)])
              (cond
                [(< diff 0) #f]
                [(= diff 0) (duration-locale-just-now locale)]
                [else
                 (let ([dur (format-duration-seconds diff locale compactness)]
                       [ago-tmpl (effective-ago locale compactness)])
                   (string-replace ago-tmpl "{0}" dur))]))))))

(define (format-until locale target as-of [compactness 'normal])
  "Format time until a future event as 'in X'. Returns #f if invalid."
  (if (or (not target) (not (string? target)) (equal? target "")
          (not as-of) (not (string? as-of)) (equal? as-of ""))
      #f
      (let ([t (parse-iso-to-seconds target)]
            [a (parse-iso-to-seconds as-of)])
        (if (or (not t) (not a))
            #f
            (let ([diff (- t a)])
              (cond
                [(< diff 0) #f]
                [(= diff 0) (duration-locale-just-now locale)]
                [else
                 (let ([dur (format-duration-seconds diff locale compactness)]
                       [future-tmpl (effective-in-future locale compactness)])
                   (string-replace future-tmpl "{0}" dur))]))))))

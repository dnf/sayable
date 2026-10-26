#lang racket

(require "locale.rkt")

(provide format-time
         version)

(define version "0.5.0")

;; ---- Time parsing ----

;; A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
;; suffix, which is ignored), alone or after the T of an ISO datetime.
(define clock-pattern
  #px"^([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:[.][0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?$")
(define date-pattern #px"^([0-9]{4})-([0-9]{2})-([0-9]{2})$")

(define (leap-year? y)
  (or (and (zero? (remainder y 4)) (not (zero? (remainder y 100))))
      (zero? (remainder y 400))))

(define (days-in-month y m)
  (cond
    [(= m 2) (if (leap-year? y) 29 28)]
    [(memv m '(4 6 9 11)) 30]
    [else 31]))

(define (real-date? date-part)
  (match (regexp-match date-pattern date-part)
    [(list _ y m d)
     (let ([year (string->number y)] [month (string->number m)] [day (string->number d)])
       (and (<= 1 month 12) (<= 1 day (days-in-month year month))))]
    [_ #f]))

(define (clock-part input-str)
  "The clock time of input-str, or #f when an ISO date part is not a real date."
  (match (regexp-match-positions #rx"T" input-str)
    [(list (cons t-start t-end))
     (and (real-date? (substring input-str 0 t-start))
          (substring input-str t-end))]
    [_ input-str]))

(define (parse-time input-str)
  "Parse a clock time or ISO datetime to (list hour minute). Returns #f on failure."
  (define clock (and (string? input-str) (clock-part input-str)))
  (match (and clock (regexp-match clock-pattern clock))
    [(list _ h m sec)
     (let ([hour (string->number h)]
           [minute (string->number m)]
           [second (if sec (string->number sec) 0)])
       (and (<= hour 23) (<= minute 59) (<= second 59)
            (list hour minute)))]
    [_ #f]))

;; ---- Round to nearest 5 minutes ----

(define (round-to-5 minute)
  (* (quotient (+ minute 2) 5) 5))

;; ---- Natural clock formatting ----

(define (format-natural hour minute clock)
  (let* ([rounded (round-to-5 minute)]
         [h hour])
    (let-values ([(rounded h) (if (= rounded 60) (values 0 (remainder (+ h 1) 24)) (values rounded h))])
      (cond
        [(and (= rounded 0) (= h 0))
         (clock-config-midnight clock)]
        [(and (= rounded 0) (= h 12))
         (clock-config-noon clock)]
        [else
         (let* ([h12 (remainder h 12)]
                [next-h12 (remainder (+ h 1) 12)]
                [h-name (list-ref (clock-config-hours clock) h12)]
                [next-h-name (list-ref (clock-config-hours clock) next-h12)]
                [pattern (hash-ref (clock-config-patterns clock) rounded
                                   (hash-ref (clock-config-patterns clock) 0 "{h}"))])
           (string-replace (string-replace pattern "{next_h}" next-h-name) "{h}" h-name))]))))

;; ---- Digital clock formatting ----

(define (format-digital hour minute sc)
  (let* ([fmt (short-clock-config-format sc)]
         [mm (let ([s (number->string minute)])
               (if (< minute 10) (string-append "0" s) s))])
    (if (short-clock-config-use24h sc)
        (string-replace (string-replace fmt "{mm}" mm) "{h}" (number->string hour))
        (let* ([h12 (remainder hour 12)]
               [h12 (if (= h12 0) 12 h12)]
               [am-pm-pair (or (short-clock-config-am-pm sc) (cons "AM" "PM"))]
               [ampm-str (if (< hour 12) (car am-pm-pair) (cdr am-pm-pair))])
          (string-replace
           (string-replace
            (string-replace fmt "{ampm}" ampm-str)
            "{mm}" mm)
           "{h}" (number->string h12))))))

;; ---- Public API ----

(define (format-time locale input-str [compactness 'normal])
  "Format a time as natural language clock reading. Returns #f if invalid."
  (if (or (not input-str) (not (string? input-str)) (equal? input-str ""))
      #f
      (let ([parsed (parse-time input-str)])
        (if (not parsed)
            #f
            (let ([hour (list-ref parsed 0)]
                  [minute (list-ref parsed 1)])
              (if (not (equal? compactness 'normal))
                  (let ([ovr (cond
                               [(equal? compactness 'short) (time-locale-short-override locale)]
                               [(equal? compactness 'compact) (time-locale-compact-override locale)]
                               [else #f])])
                    (if (and ovr (time-compactness-override-clock ovr))
                        (format-digital hour minute (time-compactness-override-clock ovr))
                        (format-natural hour minute (time-locale-clock locale))))
                  (format-natural hour minute (time-locale-clock locale))))))))

#lang racket

(require "locale.rkt")

(provide format-date
         format-date-with-year
         format-relative
         version)

(define version "0.5.0")

;; ---- Date parsing ----

(define (ascii-digits? s)
  (for/and ([c (in-string s)]) (char<=? #\0 c #\9)))

(define (leap-year? y)
  (or (and (zero? (remainder y 4)) (not (zero? (remainder y 100))))
      (zero? (remainder y 400))))

(define (days-in-month y m)
  (cond
    [(= m 2) (if (leap-year? y) 29 28)]
    [(memv m '(4 6 9 11)) 30]
    [else 31]))

(define (date-alone-or-before-time? s)
  (or (= (string-length s) 10)
      (and (> (string-length s) 10) (char=? (string-ref s 10) #\T))))

(define (parse-date s)
  "Parse YYYY-MM-DD, optionally followed by T and a time, naming a real calendar day, to (list year month day). Returns #f on failure."
  (and (string? s)
       (date-alone-or-before-time? s)
       (char=? (string-ref s 4) #\-)
       (char=? (string-ref s 7) #\-)
       (ascii-digits? (string-append (substring s 0 4) (substring s 5 7) (substring s 8 10)))
       (let ([y (string->number (substring s 0 4))]
             [m (string->number (substring s 5 7))]
             [d (string->number (substring s 8 10))])
         (and (<= 1 m 12)
              (<= 1 d (days-in-month y m))
              (list y m d)))))

;; ---- Julian Day Number ----

(define (to-jdn year month day)
  (let* ([a (quotient (- 14 month) 12)]
         [y (+ year 4800 (- a))]
         [m (+ month (* 12 a) -3)])
    (+ day
       (quotient (+ (* 153 m) 2) 5)
       (* 365 y)
       (quotient y 4)
       (- (quotient y 100))
       (quotient y 400)
       -32045)))

(define (weekday year month day)
  "Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday."
  (remainder (+ (to-jdn year month day) 1) 7))

;; ---- Pick override value ----

(define (pick ovr accessor default)
  "Pick override value if set (not #f), else default."
  (if ovr
      (let ([val (accessor ovr)])
        (if val val default))
      default))

;; ---- Effective locale values ----

(define (make-effective locale compactness)
  "Compute effective locale values with compactness overrides applied."
  (let ([ovr (cond
               [(equal? compactness 'short) (date-locale-short-override locale)]
               [(equal? compactness 'compact) (date-locale-compact-override locale)]
               [else #f])])
    (let* ([months (pick ovr date-compactness-override-months (date-locale-months locale))]
           [months-in-date
            (pick ovr date-compactness-override-months-in-date (date-locale-months-in-date locale))]
           [weekdays (pick ovr date-compactness-override-weekdays (date-locale-weekdays locale))]
           [day-format (pick ovr date-compactness-override-day-format (date-locale-day-format locale))]
           ;; When override has day-format but no day-format-exceptions, clear exceptions
           [day-format-exceptions
            (if (and ovr
                     (date-compactness-override-day-format ovr)
                     (not (date-compactness-override-day-format-exceptions ovr)))
                (hash)
                (pick ovr date-compactness-override-day-format-exceptions
                      (date-locale-day-format-exceptions locale)))]
           [date-pattern (pick ovr date-compactness-override-date-pattern
                               (date-locale-date-pattern locale))]
           [date-pattern-with-year (pick ovr date-compactness-override-date-pattern-with-year
                                        (date-locale-date-pattern-with-year locale))]
           [today (pick ovr date-compactness-override-today (date-locale-today locale))]
           [tomorrow (pick ovr date-compactness-override-tomorrow (date-locale-tomorrow locale))]
           [yesterday (pick ovr date-compactness-override-yesterday (date-locale-yesterday locale))])
      (values months months-in-date weekdays day-format day-format-exceptions
              date-pattern date-pattern-with-year today tomorrow yesterday))))

;; ---- Absolute date formatting ----

(define (format-absolute year month day include-year
                         months months-in-date day-fmt day-fmt-exceptions
                         date-pattern date-pattern-with-year)
  "Format a date as an absolute calendar reference."
  (let* ([day-str (number->string day)]
         [fmt (hash-ref day-fmt-exceptions day-str day-fmt)]
         [formatted-day (string-replace fmt "{n}" day-str)]
         [month-names (or months-in-date months)]
         [month-name (list-ref month-names (sub1 month))]
         [pattern (if include-year date-pattern-with-year date-pattern)]
         [result (string-replace pattern "{month}" month-name)]
         [result (string-replace result "{day}" formatted-day)]
         [result (string-replace result "{d}" (number->string day))]
         [result (string-replace result "{m}" (number->string month))])
    (if include-year
        (let* ([result (string-replace result "{year}" (number->string year))]
               [yy (let ([v (remainder year 100)])
                     (if (< v 10) (string-append "0" (number->string v)) (number->string v)))]
               [result (string-replace result "{yy}" yy)])
          result)
        result)))

;; ---- Public API ----

(define (format-date locale date-str [compactness 'normal])
  "Format a calendar date in locale-appropriate form. Returns #f if invalid."
  (if (or (not date-str) (not (string? date-str)) (equal? date-str ""))
      #f
      (let ([parsed (parse-date date-str)])
        (if (not parsed)
            #f
            (let-values ([(months months-in-date weekdays day-fmt day-fmt-exceptions
                           date-pattern date-pattern-with-year today tomorrow yesterday)
                          (make-effective locale compactness)])
              (format-absolute (list-ref parsed 0) (list-ref parsed 1) (list-ref parsed 2)
                               #f months months-in-date day-fmt day-fmt-exceptions
                               date-pattern date-pattern-with-year))))))

(define (format-date-with-year locale date-str [compactness 'normal])
  "Format a calendar date with year. Returns #f if invalid."
  (if (or (not date-str) (not (string? date-str)) (equal? date-str ""))
      #f
      (let ([parsed (parse-date date-str)])
        (if (not parsed)
            #f
            (let-values ([(months months-in-date weekdays day-fmt day-fmt-exceptions
                           date-pattern date-pattern-with-year today tomorrow yesterday)
                          (make-effective locale compactness)])
              (format-absolute (list-ref parsed 0) (list-ref parsed 1) (list-ref parsed 2)
                               #t months months-in-date day-fmt day-fmt-exceptions
                               date-pattern date-pattern-with-year))))))

(define (format-relative locale date-str as-of [compactness 'normal])
  "Format a date relative to as-of, picking the most natural reference. Returns #f if invalid."
  (if (or (not date-str) (not (string? date-str)) (equal? date-str "")
          (not as-of) (not (string? as-of)) (equal? as-of ""))
      #f
      (let ([parsed-date (parse-date date-str)]
            [parsed-as-of (parse-date as-of)])
        (if (or (not parsed-date) (not parsed-as-of))
            #f
            (let-values ([(months months-in-date weekdays day-fmt day-fmt-exceptions
                           date-pattern date-pattern-with-year today tomorrow yesterday)
                          (make-effective locale compactness)])
              (let* ([dy (list-ref parsed-date 0)]
                     [dm (list-ref parsed-date 1)]
                     [dd (list-ref parsed-date 2)]
                     [ay (list-ref parsed-as-of 0)]
                     [am (list-ref parsed-as-of 1)]
                     [ad (list-ref parsed-as-of 2)]
                     [date-jdn (to-jdn dy dm dd)]
                     [asof-jdn (to-jdn ay am ad)]
                     [diff (- date-jdn asof-jdn)]
                     [is-compact (equal? compactness 'compact)])

                (cond
                  ;; Today
                  [(= diff 0) today]

                  ;; Tomorrow
                  [(= diff 1) tomorrow]

                  ;; Yesterday
                  [(= diff -1) yesterday]

                  ;; Day after tomorrow (optional, skip in compact)
                  [(and (= diff 2)
                        (date-locale-day-after-tomorrow locale)
                        (not is-compact))
                   (date-locale-day-after-tomorrow locale)]

                  ;; Day before yesterday (optional, skip in compact)
                  [(and (= diff -2)
                        (date-locale-day-before-yesterday locale)
                        (not is-compact))
                   (date-locale-day-before-yesterday locale)]

                  ;; Compact mode: skip weekday references, go straight to calendar date
                  [is-compact
                   (let ([include-year (not (= dy ay))])
                     (format-absolute dy dm dd include-year
                                      months months-in-date day-fmt day-fmt-exceptions
                                      date-pattern date-pattern-with-year))]

                  ;; This weekday (+2 to +6)
                  [(and (>= diff 2) (<= diff 6) (date-locale-this-weekday locale))
                   (let* ([dow (weekday dy dm dd)]
                          [weekday-name (list-ref weekdays dow)])
                     (string-replace (date-locale-this-weekday locale) "{weekday}" weekday-name))]

                  ;; Last weekday (-2 to -6)
                  [(and (>= diff -6) (<= diff -2) (date-locale-last-weekday locale))
                   (let* ([dow (weekday dy dm dd)]
                          [weekday-name (list-ref weekdays dow)])
                     (string-replace (date-locale-last-weekday locale) "{weekday}" weekday-name))]

                  ;; Next weekday (+7 to +13)
                  [(and (>= diff 7) (<= diff 13) (date-locale-next-weekday locale))
                   (let* ([dow (weekday dy dm dd)]
                          [weekday-name (list-ref weekdays dow)])
                     (string-replace (date-locale-next-weekday locale) "{weekday}" weekday-name))]

                  ;; Calendar fallback
                  [else
                   (let ([include-year (not (= dy ay))])
                     (format-absolute dy dm dd include-year
                                      months months-in-date day-fmt day-fmt-exceptions
                                      date-pattern date-pattern-with-year))])))))))

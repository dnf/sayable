#lang racket

(require "locale.rkt")

(provide format-age
         format-stage
         version)

(define version "0.5.0")

(define max-age-months 6000)

;; ---- Date parsing ----

(define (parse-date-parts s)
  "Parse a YYYY-MM-DD string into (values year month day). Returns (values 0 0 0) on failure."
  (if (or (not (string? s))
          (< (string-length s) 10)
          (not (char=? (string-ref s 4) #\-))
          (not (char=? (string-ref s 7) #\-)))
      (values 0 0 0)
      (let ([y (string->number (substring s 0 4))]
            [m (string->number (substring s 5 7))]
            [d (string->number (substring s 8 10))])
        (if (and y m d)
            (values y m d)
            (values 0 0 0)))))

;; ---- Leap year and days-in-month ----

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

;; ---- Days between two dates (Julian Day Number approach) ----

(define (date->jdn y m d)
  "Convert a date to Julian Day Number."
  (let* ([a (quotient (- 14 m) 12)]
         [y1 (+ y 4800 (- a))]
         [m1 (+ m (* 12 a) -3)])
    (+ d
       (quotient (+ (* 153 m1) 2) 5)
       (* 365 y1)
       (quotient y1 4)
       (- (quotient y1 100))
       (quotient y1 400)
       -32045)))

(define (days-between y1 m1 d1 y2 m2 d2)
  "Return number of days from (y1,m1,d1) to (y2,m2,d2)."
  (- (date->jdn y2 m2 d2) (date->jdn y1 m1 d1)))

;; ---- Age parsing ----

(define (parse-age dob [as-of #f])
  "Parse age from dob and as-of strings. Returns (values months diff-days) or (values #f #f)."
  (when (or (not dob) (equal? dob "") (not (string? dob)))
    (values #f #f))
  (if (or (not dob) (equal? dob "") (not (string? dob)))
      (values #f #f)
      (let-values ([(dob-y dob-m dob-d) (parse-date-parts dob)])
        (if (and (= dob-y 0) (= dob-m 0) (= dob-d 0))
            (values #f #f)
            (let-values ([(ref-y ref-m ref-d)
                          (if (and as-of (not (equal? as-of "")))
                              (parse-date-parts as-of)
                              (let ([now (current-date)])
                                (values (date-year now)
                                        (date-month now)
                                        (date-day now))))])
              (if (and (= ref-y 0) (= ref-m 0) (= ref-d 0))
                  (values #f #f)
                  (let ([diff-days (days-between dob-y dob-m dob-d ref-y ref-m ref-d)])
                    (if (< diff-days 0)
                        (values #f #f)
                        ;; Calendar months with birthday clamping
                        (let* ([last-day (days-in-month ref-y ref-m)]
                               [clamped-birthday (min dob-d last-day)]
                               [months (- (+ (* (- ref-y dob-y) 12) (- ref-m dob-m))
                                          (if (< ref-d clamped-birthday) 1 0))])
                          (if (> months max-age-months)
                              (values #f #f)
                              (values months diff-days)))))))))))

;; ---- Stage key ----

(define (stage-key months)
  (cond
    [(< months 2) "newborn"]
    [(< months 12) "infant"]
    [(< months 36) "toddler"]
    [(< months 156) "child"]
    [(< months 216) "teenager"]
    [else "adult"]))

;; ---- Unit resolution ----

(define (resolve-unit count unit-forms locale half)
  "Format a count with unit forms, applying plural rules and half markers."
  (let* ([base-n (number->string count)]
         ;; Apply {n}-style half marker to the number
         [n (if (and (not (equal? half ""))
                     (string-contains? half "{n}"))
                (string-replace half "{n}" base-n)
                base-n)]
         ;; Select template
         [template
          (let ([type (hash-ref unit-forms "type")])
            (if (equal? type "simple")
                (hash-ref unit-forms "form")
                (let* ([forms (hash-ref unit-forms "forms")]
                       [plural-fn (age-locale-plural locale)]
                       [cat (plural-fn count)]
                       [tmpl (hash-ref forms cat #f)])
                  (or tmpl (hash-ref forms "other")))))]
         ;; Substitute {n} in template
         [result (string-replace template "{n}" n)])
    ;; Apply {0}-style half marker (wraps the whole expression)
    (if (and (not (equal? half ""))
             (string-contains? half "{0}"))
        (string-replace half "{0}" result)
        result)))

;; ---- Effective locale values (with compactness) ----

(define (effective-unit locale compactness unit-key)
  "Get the effective unit forms for a key, considering compactness overrides."
  (let* ([ovr (cond
                [(equal? compactness 'short) (age-locale-short-override locale)]
                [(equal? compactness 'compact) (age-locale-compact-override locale)]
                [else #f])]
         [ovr-unit (and ovr
                       (case unit-key
                         [("day") (compactness-override-day ovr)]
                         [("week") (compactness-override-week ovr)]
                         [("month") (compactness-override-month ovr)]
                         [("year") (compactness-override-year ovr)]
                         [else #f]))])
    (or ovr-unit (hash-ref (age-locale-units locale) unit-key))))

(define (effective-half locale compactness)
  (let ([ovr (cond
               [(equal? compactness 'short) (age-locale-short-override locale)]
               [(equal? compactness 'compact) (age-locale-compact-override locale)]
               [else #f])])
    (if (and ovr (compactness-override-half ovr))
        (compactness-override-half ovr)
        (age-locale-half locale))))

(define (effective-delimiter locale compactness)
  (let ([ovr (cond
               [(equal? compactness 'short) (age-locale-short-override locale)]
               [(equal? compactness 'compact) (age-locale-compact-override locale)]
               [else #f])])
    (if (and ovr (compactness-override-delimiter ovr))
        (compactness-override-delimiter ovr)
        (age-locale-delimiter locale))))

(define (effective-just-born locale compactness)
  (let ([ovr (cond
               [(equal? compactness 'short) (age-locale-short-override locale)]
               [(equal? compactness 'compact) (age-locale-compact-override locale)]
               [else #f])])
    (if (and ovr (compactness-override-just-born ovr))
        (compactness-override-just-born ovr)
        (age-locale-just-born locale))))

;; ---- Public API ----

(define (format-age locale dob [as-of #f] #:compactness [compactness 'normal])
  "Format a human-friendly age string. Returns #f if inputs are invalid."
  (let-values ([(months diff-days) (parse-age dob as-of)])
    (if (not months)
        #f
        (let ([day-unit (effective-unit locale compactness "day")]
              [week-unit (effective-unit locale compactness "week")]
              [month-unit (effective-unit locale compactness "month")]
              [year-unit (effective-unit locale compactness "year")]
              [half (effective-half locale compactness)]
              [delimiter (effective-delimiter locale compactness)]
              [just-born (effective-just-born locale compactness)])

          (cond
            ;; Tier 1: 0 days
            [(= diff-days 0) just-born]

            ;; Tier 1b: 1-6 days
            [(< diff-days 7)
             (resolve-unit diff-days day-unit locale "")]

            ;; Tier 2: weeks + days until 3 calendar months
            [(< months 3)
             (let* ([weeks (quotient diff-days 7)]
                    [days (remainder diff-days 7)]
                    [result (resolve-unit weeks week-unit locale "")])
               (if (> days 0)
                   (string-append result delimiter (resolve-unit days day-unit locale ""))
                   result))]

            ;; Tier 3: 3-23 months
            [(< months 24)
             (resolve-unit months month-unit locale "")]

            ;; Tier 4: 24-35 months -> years + months
            [(< months 36)
             (let* ([years (quotient months 12)]
                    [rem (remainder months 12)])
               (if (= rem 0)
                   (resolve-unit years year-unit locale "")
                   (string-append (resolve-unit years year-unit locale "")
                                  delimiter
                                  (resolve-unit rem month-unit locale ""))))]

            ;; Tier 5: 3-6 years -> years with half marker
            [(< months 84)
             (let* ([years (quotient months 12)]
                    [rem (remainder months 12)])
               (if (>= rem 6)
                   (resolve-unit years year-unit locale half)
                   (resolve-unit years year-unit locale "")))]

            ;; Tier 6: 7+ years
            [else
             (let ([years (quotient months 12)])
               (resolve-unit years year-unit locale ""))])))))

(define (format-stage locale dob [as-of #f] #:gender [gender ""] #:compactness [compactness 'normal])
  "Format a developmental stage label. Returns #f if inputs are invalid."
  (let-values ([(months diff-days) (parse-age dob as-of)])
    (if (not months)
        #f
        (let* ([key (stage-key months)]
               [sl (hash-ref (age-locale-stages locale) key)])
          (resolve-stage sl gender)))))

;; ---- Current date helper (for default as-of) ----

(define (current-date)
  "Return the current date as a date struct."
  (seconds->date (current-seconds)))

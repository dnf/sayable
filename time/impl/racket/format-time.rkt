#lang racket

(require "locale.rkt")

(provide format-time
         version)

(define version "0.5.0")

;; ---- Time parsing ----

(define (parse-time input-str)
  "Parse HH:MM or ISO datetime to (values hour minute). Returns #f on failure."
  (if (or (not input-str) (not (string? input-str)) (equal? input-str ""))
      #f
      (with-handlers ([exn:fail? (lambda (_) #f)])
        (let* ([t (if (string-contains? input-str "T")
                      (cadr (string-split input-str "T"))
                      input-str)]
               [t (car (string-split t "+"))]
               [t (car (string-split t "Z"))]
               [parts (string-split t ":")]
               [_ (when (< (length parts) 2) (error "need at least H:M"))]
               [hour (string->number (list-ref parts 0))]
               [minute-str (car (string-split (list-ref parts 1) "."))]
               [minute (string->number minute-str)])
          (if (and hour minute
                   (>= hour 0) (<= hour 23)
                   (>= minute 0) (<= minute 59))
              (list hour minute)
              #f)))))

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

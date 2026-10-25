#lang racket

(require
  (only-in "../../../age/impl/racket/format-age.rkt" format-age format-stage)
  "../../../age/impl/racket/locale.rkt"
  (prefix-in age: "../../../age/impl/racket/locales/registry.rkt")
  (only-in "../../../date/impl/racket/format-date.rkt" format-date format-date-with-year format-relative)
  "../../../date/impl/racket/locale.rkt"
  (prefix-in date: "../../../date/impl/racket/locales/registry.rkt")
  (only-in "../../../duration/impl/racket/format-duration.rkt" format-duration format-since format-until)
  "../../../duration/impl/racket/locale.rkt"
  (prefix-in dur: "../../../duration/impl/racket/locales/registry.rkt")
  (only-in "../../../time/impl/racket/format-time.rkt" format-time)
  "../../../time/impl/racket/locale.rkt"
  (prefix-in time: "../../../time/impl/racket/locales/registry.rkt"))

(define cli-version "0.5.0")

(define help-text
  "Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version")

(define (cli-error msg)
  (eprintf "error: ~a\n" msg)
  (eprintf "Run 'sayable help' for usage.\n")
  (exit 2))

(define (nullify val)
  (if (equal? val "null") #f val))

(define (get-today)
  (let ([now (seconds->date (current-seconds))])
    (format "~a-~a-~a"
            (date-year now)
            (~a (date-month now) #:min-width 2 #:align 'right #:pad-string "0")
            (~a (date-day now) #:min-width 2 #:align 'right #:pad-string "0"))))

(define (parse-args argv)
  (if (null? argv)
      (values #f '() (make-hash))
      (let ([first-arg (car argv)])
        (cond
          [(member first-arg '("-h" "--help" "help"))
           (values "help" '() (make-hash))]
          [(member first-arg '("-v" "--version" "version"))
           (values "version" '() (make-hash))]
          [else
           (let ([command first-arg]
                 [positionals '()]
                 [options (make-hash `(("locale" . "en")
                                       ("as-of" . #f)
                                       ("compactness" . "normal")
                                       ("gender" . #f)
                                       ("with-year" . #f)))]
                 [rest (cdr argv)])
             (let loop ([args rest] [pos '()] [stop-opts #f])
               (if (null? args)
                   (values command (reverse pos) options)
                   (let ([arg (car args)] [remaining (cdr args)])
                     (cond
                       [(and (equal? arg "--") (not stop-opts))
                        (loop remaining pos #t)]
                       [(and (not stop-opts) (string-prefix? arg "-"))
                        (cond
                          [(member arg '("-l" "--locale"))
                           (when (null? remaining) (cli-error (format "'~a' requires a value" arg)))
                           (hash-set! options "locale" (car remaining))
                           (loop (cdr remaining) pos stop-opts)]
                          [(member arg '("-d" "--as-of"))
                           (when (null? remaining) (cli-error (format "'~a' requires a value" arg)))
                           (hash-set! options "as-of" (car remaining))
                           (loop (cdr remaining) pos stop-opts)]
                          [(member arg '("-g" "--gender"))
                           (when (null? remaining) (cli-error (format "'~a' requires a value" arg)))
                           (hash-set! options "gender" (car remaining))
                           (loop (cdr remaining) pos stop-opts)]
                          [(equal? arg "--short")
                           (hash-set! options "compactness" "short")
                           (loop remaining pos stop-opts)]
                          [(equal? arg "--compact")
                           (hash-set! options "compactness" "compact")
                           (loop remaining pos stop-opts)]
                          [(equal? arg "--with-year")
                           (hash-set! options "with-year" #t)
                           (loop remaining pos stop-opts)]
                          [(member arg '("-h" "--help"))
                           (values "help" '() (make-hash))]
                          [(member arg '("-v" "--version"))
                           (values "version" '() (make-hash))]
                          [else
                           (cli-error (format "unknown option '~a'" arg))])]
                       [else
                        (loop remaining (cons arg pos) stop-opts)])))))]))))

(define (compactness-sym s)
  (cond
    [(equal? s "short") 'short]
    [(equal? s "compact") 'compact]
    [else 'normal]))

(define (cmd-age positionals options)
  (when (null? positionals) (cli-error "age requires a date-of-birth argument"))
  (let* ([dob (nullify (car positionals))]
         [locale-code (hash-ref options "locale")]
         [locale (age:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [as-of (hash-ref options "as-of")]
         [as-of (if as-of (nullify as-of) (get-today))]
         [compactness (compactness-sym (hash-ref options "compactness"))]
         [result (format-age locale dob as-of #:compactness compactness)])
    (if result
        (displayln result)
        (exit 1))))

(define (cmd-stage positionals options)
  (when (null? positionals) (cli-error "stage requires a date-of-birth argument"))
  (let* ([dob (nullify (car positionals))]
         [locale-code (hash-ref options "locale")]
         [locale (age:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [as-of (hash-ref options "as-of")]
         [as-of (if as-of (nullify as-of) (get-today))]
         [gender (or (hash-ref options "gender") "")]
         [compactness (compactness-sym (hash-ref options "compactness"))]
         [result (format-stage locale dob as-of #:gender gender #:compactness compactness)])
    (if result
        (displayln result)
        (exit 1))))

(define (cmd-date positionals options)
  (when (null? positionals) (cli-error "date requires a date argument"))
  (let* ([date-val (nullify (car positionals))]
         [locale-code (hash-ref options "locale")]
         [locale (date:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [compactness (compactness-sym (hash-ref options "compactness"))]
         [with-year (hash-ref options "with-year")]
         [result (if with-year
                     (format-date-with-year locale date-val compactness)
                     (format-date locale date-val compactness))])
    (if result
        (displayln result)
        (exit 1))))

(define (cmd-relative positionals options)
  (when (null? positionals) (cli-error "relative requires a date argument"))
  (let* ([date-val (nullify (car positionals))]
         [as-of (hash-ref options "as-of")]
         [_ (unless as-of (cli-error "relative requires --as-of / -d option"))]
         [as-of (nullify as-of)]
         [locale-code (hash-ref options "locale")]
         [locale (date:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [compactness (compactness-sym (hash-ref options "compactness"))]
         [result (format-relative locale date-val as-of compactness)])
    (if result
        (displayln result)
        (exit 1))))

(define (cmd-time positionals options)
  (when (null? positionals) (cli-error "time requires a time argument"))
  (let* ([time-val (nullify (car positionals))]
         [locale-code (hash-ref options "locale")]
         [locale (time:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [compactness (compactness-sym (hash-ref options "compactness"))]
         [result (format-time locale time-val compactness)])
    (if result
        (displayln result)
        (exit 1))))

(define (cmd-duration positionals options)
  (when (null? positionals) (cli-error "duration requires a value argument"))
  (let* ([value (nullify (car positionals))]
         [locale-code (hash-ref options "locale")]
         [locale (dur:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [compactness (compactness-sym (hash-ref options "compactness"))])
    (let ([result
           (cond
             [(not value) (format-duration locale #f)]
             ;; Check if it's an integer (possibly negative)
             [(regexp-match? #rx"^-?[0-9]+$" value)
              (format-duration locale (string->number value) #f #:compactness compactness)]
             ;; Timestamp mode
             [else
              (when (< (length positionals) 2)
                (cli-error "duration with timestamps requires start and end arguments"))
              (let ([end (nullify (list-ref positionals 1))])
                (format-duration locale value end #:compactness compactness))])])
      (if result
          (displayln result)
          (exit 1)))))

(define (cmd-since positionals options)
  (when (null? positionals) (cli-error "since requires a start timestamp argument"))
  (let* ([start (nullify (car positionals))]
         [as-of (hash-ref options "as-of")]
         [_ (unless as-of (cli-error "since requires --as-of / -d option"))]
         [as-of (nullify as-of)]
         [locale-code (hash-ref options "locale")]
         [locale (dur:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [compactness (compactness-sym (hash-ref options "compactness"))]
         [result (format-since locale start as-of compactness)])
    (if result
        (displayln result)
        (exit 1))))

(define (cmd-until positionals options)
  (when (null? positionals) (cli-error "until requires a target timestamp argument"))
  (let* ([target (nullify (car positionals))]
         [as-of (hash-ref options "as-of")]
         [_ (unless as-of (cli-error "until requires --as-of / -d option"))]
         [as-of (nullify as-of)]
         [locale-code (hash-ref options "locale")]
         [locale (dur:get-locale locale-code)]
         [_ (unless locale (cli-error (format "unknown locale '~a'" locale-code)))]
         [compactness (compactness-sym (hash-ref options "compactness"))]
         [result (format-until locale target as-of compactness)])
    (if result
        (displayln result)
        (exit 1))))

(define (cmd-locales)
  (for ([code (in-list '("af" "ak" "am" "ar" "ay" "az" "bci" "be" "bem" "bg" "bi" "bm"
                         "bn" "br" "bs" "ca" "cak" "ceb" "cs" "cy" "da" "de" "din" "dje"
                         "dv" "dyu" "dz" "ee" "el" "en" "es" "et" "eu" "fa" "fan" "ff"
                         "fi" "fil" "fj" "fon" "fr" "ga" "gd" "gl" "gn" "gu" "gv" "ha"
                         "he" "hi" "hmn" "hr" "ht" "hu" "hy" "id" "ig" "is" "it" "ja"
                         "jv" "ka" "kbp" "kek" "ki" "kk" "kl" "km" "kn" "ko" "kpe" "kri"
                         "ktu" "ku" "kw" "ky" "lb" "lg" "ln" "lo" "lt" "luo" "lv" "mam"
                         "men" "mfe" "mg" "mi" "mk" "ml" "mn" "mnk" "mos" "mr" "ms" "mt"
                         "my" "nb" "nd" "ne" "ng" "nl" "nr" "nso" "nus" "ny" "om" "or"
                         "pa" "pis" "pl" "pov" "ps" "pt" "qu" "quc" "ro" "ru" "rw" "sar"
                         "sd" "sg" "shi" "shn" "si" "sk" "sl" "sn" "snk" "so" "sq" "sr"
                         "ss" "st" "su" "suk" "sv" "sw" "ta" "te" "tem" "tet" "tg" "th"
                         "ti" "tig" "tk" "tn" "tpi" "tr" "ts" "tum" "tzm" "uk" "umb" "ur"
                         "uz" "ve" "vi" "vmw" "wo" "xh" "yao" "yo" "yue" "zdj" "zh" "zu"))])
    (displayln code)))

(define (dispatch argv)
  (let-values ([(command positionals options) (parse-args argv)])
    (cond
      [(not command)
       (displayln help-text)
       (exit 2)]
      [(equal? command "help")
       (displayln help-text)
       (exit 0)]
      [(equal? command "version")
       (printf "sayable ~a\n" cli-version)
       (exit 0)]
      [(equal? command "locales")
       (cmd-locales)
       (exit 0)]
      [(equal? command "age") (cmd-age positionals options)]
      [(equal? command "stage") (cmd-stage positionals options)]
      [(equal? command "date") (cmd-date positionals options)]
      [(equal? command "relative") (cmd-relative positionals options)]
      [(equal? command "time") (cmd-time positionals options)]
      [(equal? command "duration") (cmd-duration positionals options)]
      [(equal? command "since") (cmd-since positionals options)]
      [(equal? command "until") (cmd-until positionals options)]
      [else (cli-error (format "unknown command '~a'" command))])))

;; Runs one command exactly as a one-shot run would, but returns its exit code
;; and stdout text instead of exiting. A crash exits 1 in a one-shot run.
(define (run-captured argv)
  (define output (open-output-string))
  (define exit-code
    (let/ec escape
      (with-handlers ([exn:fail? (λ (e)
                                   ((error-display-handler) (exn-message e) e)
                                   1)])
        (parameterize ([current-output-port output]
                       [exit-handler escape])
          (dispatch argv)
          0))))
  (values exit-code (get-output-string output)))

(define (strip-carriage-return line)
  (string-trim line "\r" #:left? #f #:repeat? #f))

;; Answers one tab-separated request per stdin line (see cli/SPEC.md).
(define (repl)
  (for ([line (in-lines (current-input-port) 'linefeed)])
    (define-values (exit-code output)
      (run-captured (regexp-split #rx"\t" (strip-carriage-return line))))
    (printf "~a\t~a\n" exit-code (string-replace (string-trim output "\n" #:left? #f) "\n" "\t"))
    (flush-output)))

(define (main argv)
  (if (equal? argv '("--repl"))
      (repl)
      (dispatch argv)))

(main (vector->list (current-command-line-arguments)))

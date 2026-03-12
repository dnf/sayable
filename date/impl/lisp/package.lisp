(defpackage :sayable-date
  (:use :cl)
  (:export #:+version+
           #:date-locale
           #:make-date-locale
           #:clock-config
           #:make-clock-config
           #:short-clock-config
           #:make-short-clock-config
           #:sayable-date-formatter
           #:make-formatter
           #:format-date
           #:format-date-with-year
           #:format-relative
           #:get-locale
           ;; Default English functions
           #:default-format-date
           #:default-format-relative))

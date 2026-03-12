(defpackage :sayable-time
  (:use :cl)
  (:export #:+version+
           #:time-locale
           #:make-time-locale
           #:clock-config
           #:make-clock-config
           #:short-clock-config
           #:make-short-clock-config
           #:sayable-time-formatter
           #:make-formatter
           #:format-time
           #:get-locale
           ;; Default English function
           #:default-format-time))

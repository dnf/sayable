(defpackage :sayable-duration
  (:use :cl)
  (:export #:+version+
           #:duration-locale
           #:make-duration-locale
           #:sayable-duration-formatter
           #:make-formatter
           #:format-duration
           #:format-since
           #:format-until
           #:get-locale
           ;; Default English functions
           #:default-format-duration
           #:default-format-since
           #:default-format-until))

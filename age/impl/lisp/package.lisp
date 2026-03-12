(defpackage :sayable-age
  (:use :cl)
  (:export #:+version+
           #:age-locale
           #:make-age-locale
           #:compactness-override
           #:make-compactness-override
           #:sayable-age-formatter
           #:make-formatter
           #:format-age
           #:format-stage
           #:get-locale
           ;; Default English functions
           #:default-format-age
           #:default-format-stage))

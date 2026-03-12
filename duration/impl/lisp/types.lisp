(in-package :sayable-duration)

(defstruct duration-locale
  "Locale definition for duration formatting."
  (code "" :type string)
  (plural (lambda (n) (declare (ignore n)) :other) :type function)
  (units nil :type list)          ; alist of (:second . forms) (:minute . forms) ...
  (half "" :type string)
  (delimiter "" :type string)
  (just-now "" :type string)
  (ago "" :type string)           ; e.g. "{0} ago"
  (in-future "" :type string)     ; e.g. "in {0}"
  ;; Short compactness overrides
  (short-units nil :type list)
  (short-half nil)
  (short-delimiter nil)
  (short-ago nil)
  (short-in-future nil)
  ;; Compact compactness overrides
  (compact-units nil :type list)
  (compact-half nil)
  (compact-delimiter nil)
  (compact-ago nil)
  (compact-in-future nil))

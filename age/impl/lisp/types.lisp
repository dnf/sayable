(in-package :sayable-age)

(defstruct age-locale
  "Locale definition for age formatting."
  (code "" :type string)
  (plural (lambda (n) (declare (ignore n)) :other) :type function)
  (units nil :type list)          ; alist of (:day . forms) (:week . forms) ...
  (half "" :type string)
  (delimiter "" :type string)
  (just-born "" :type string)
  (stages nil :type list)         ; alist of (:newborn . label) (:infant . label) ...
  ;; Short compactness overrides
  (short-units nil :type list)
  (short-half nil)
  (short-delimiter nil)
  (short-just-born nil)
  ;; Compact compactness overrides
  (compact-units nil :type list)
  (compact-half nil)
  (compact-delimiter nil)
  (compact-just-born nil))

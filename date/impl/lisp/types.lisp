(in-package :sayable-date)

(defstruct date-locale
  "Locale definition for date formatting."
  (code "" :type string)
  (months nil :type list)               ; list of 12 month name strings
  (weekdays nil :type list)             ; list of 7 weekday name strings (Sun=0)
  (day-format "" :type string)          ; e.g. "{n}th"
  (day-format-exceptions nil :type list) ; alist of day-string -> format
  (date-pattern "" :type string)        ; e.g. "{month} {day}"
  (date-pattern-with-year "" :type string) ; e.g. "{month} {day}, {year}"
  (today "" :type string)
  (tomorrow "" :type string)
  (yesterday "" :type string)
  (day-after-tomorrow nil)              ; optional string
  (day-before-yesterday nil)            ; optional string
  (this-weekday nil)                    ; optional string e.g. "this {weekday}"
  (next-weekday nil)                    ; optional string
  (last-weekday nil)                    ; optional string
  (months-in-date nil)                  ; optional list of genitive month names
  ;; Short compactness overrides
  (short-months nil)
  (short-weekdays nil)
  (short-day-format nil)
  (short-day-format-exceptions nil)
  (short-date-pattern nil)
  (short-date-pattern-with-year nil)
  ;; Compact compactness overrides
  (compact-date-pattern nil)
  (compact-date-pattern-with-year nil))

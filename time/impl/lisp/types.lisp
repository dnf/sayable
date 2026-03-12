(in-package :sayable-time)

(defstruct clock-config
  "Natural language clock reading configuration."
  (hours nil :type list)            ; list of 12 hour name strings
  (midnight "" :type string)
  (noon "" :type string)
  (patterns nil :type list))        ; alist of (integer . pattern-string)

(defstruct short-clock-config
  "Digital clock display configuration for short/compact modes."
  (use24h t :type boolean)
  (format "{h}:{mm}" :type string)
  (am-pm nil))                      ; optional cons of (am-string . pm-string)

(defstruct time-locale
  "Locale definition for clock time formatting."
  (code "" :type string)
  (clock nil :type (or null clock-config))
  (short-clock nil)                 ; optional short-clock-config
  (compact-clock nil))              ; optional short-clock-config

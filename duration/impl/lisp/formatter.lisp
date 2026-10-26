(in-package :sayable-duration)

(defvar +version+ "0.5.0")

(defconstant +max-duration-months+ 6000
  "500 years, the same ceiling as sayable-age.")

;;; --- String utilities ---

(defun string-replace-all (string old new)
  "Replace all occurrences of OLD in STRING with NEW."
  (let ((old-len (length old)))
    (when (zerop old-len)
      (return-from string-replace-all string))
    (with-output-to-string (out)
      (loop with start = 0
            for pos = (search old string :start2 start)
            while pos
            do (write-string (subseq string start pos) out)
               (write-string new out)
               (setf start (+ pos old-len))
            finally (write-string (subseq string start) out)))))

;;; --- ISO timestamp parsing ---

(defun leap-year-p (year)
  "Return T if YEAR is a leap year."
  (or (and (zerop (mod year 4))
           (not (zerop (mod year 100))))
      (zerop (mod year 400))))

(defun days-in-month (year month)
  "Return the number of days in MONTH of YEAR."
  (case month
    ((1 3 5 7 8 10 12) 31)
    ((4 6 9 11) 30)
    (2 (if (leap-year-p year) 29 28))))

(defun days-since-epoch (year month day)
  "Calculate days since a reference epoch (2000-01-01)."
  (let ((days 0))
    (if (>= year 2000)
        (loop for y from 2000 below year
              do (incf days (if (leap-year-p y) 366 365)))
        (loop for y from year below 2000
              do (decf days (if (leap-year-p y) 366 365))))
    (loop for m from 1 below month
          do (incf days (days-in-month year m)))
    (+ days day -1)))

(defun ascii-digit-p (ch)
  "Return T if CH is one of the ASCII digits 0-9."
  (char<= #\0 ch #\9))

(defun scan-digits (s pos min-count max-count)
  "Return the position after MIN-COUNT to MAX-COUNT ASCII digits of S at POS, or NIL."
  (let ((end (or (position-if-not #'ascii-digit-p s :start pos
                                  :end (min (length s) (+ pos max-count)))
                 (min (length s) (+ pos max-count)))))
    (when (>= (- end pos) min-count)
      end)))

(defun char-at-p (s pos ch)
  "Return T if S has the character CH at POS."
  (and (< pos (length s)) (char= (char s pos) ch)))

(defun scan-fraction (s pos)
  "Skip an optional . and one or more digits at POS; return the next position or NIL."
  (if (char-at-p s pos #\.)
      (scan-digits s (1+ pos) 1 (length s))
      pos))

(defun scan-zone (s pos)
  "Skip an optional Z or +HH:MM / -HH:MM zone suffix at POS; return the next position or NIL."
  (cond
    ((char-at-p s pos #\Z) (1+ pos))
    ((or (char-at-p s pos #\+) (char-at-p s pos #\-))
     (let ((hours-end (scan-digits s (1+ pos) 2 2)))
       (when (and hours-end (char-at-p s hours-end #\:))
         (scan-digits s (1+ hours-end) 2 2))))
    (t pos)))

(defun parse-clock (s start)
  "Parse H:MM or HH:MM with optional :SS, fraction and zone, filling S from START to its end.
Returns (values hour minute second), or NIL when malformed or out of range."
  (let* ((hour-end (scan-digits s start 1 2))
         (minute-end (and hour-end (char-at-p s hour-end #\:)
                          (scan-digits s (1+ hour-end) 2 2)))
         (second-end (and minute-end (char-at-p s minute-end #\:)
                          (scan-digits s (1+ minute-end) 2 2)))
         (fraction-end (if second-end (scan-fraction s second-end) minute-end))
         (zone-end (and fraction-end (scan-zone s fraction-end))))
    (when (eql zone-end (length s))
      (let ((hour (parse-integer s :start start :end hour-end))
            (minute (parse-integer s :start (1+ hour-end) :end minute-end))
            (second-val (if second-end
                            (parse-integer s :start (1+ minute-end) :end second-end)
                            0)))
        (when (and (<= hour 23) (<= minute 59) (<= second-val 59))
          (values hour minute second-val))))))

(defun parse-date-part (s)
  "Parse the YYYY-MM-DD that opens S into (values year month day), or NIL unless it names a real day."
  (when (and (>= (length s) 10)
             (scan-digits s 0 4 4)
             (char-at-p s 4 #\-)
             (eql (scan-digits s 5 2 2) 7)
             (char-at-p s 7 #\-)
             (eql (scan-digits s 8 2 2) 10))
    (let ((year (parse-integer s :start 0 :end 4))
          (month (parse-integer s :start 5 :end 7))
          (day (parse-integer s :start 8 :end 10)))
      (when (and (<= 1 month 12) (<= 1 day (days-in-month year month)))
        (values year month day)))))

(defun parse-iso-to-seconds (iso-str)
  "Parse a YYYY-MM-DDTHH:MM timestamp (optional :SS, fraction and ignored zone) to
epoch-ish seconds for diffing. Returns NIL when malformed."
  (when (and (stringp iso-str) (char-at-p iso-str 10 #\T))
    (multiple-value-bind (year month day) (parse-date-part iso-str)
      (when year
        (multiple-value-bind (hour minute second-val) (parse-clock iso-str 11)
          (when hour
            (+ (* (days-since-epoch year month day) 86400)
               (* hour 3600) (* minute 60) second-val)))))))

;;; --- Unit resolution ---

(defun get-unit (key units)
  "Look up a unit by keyword from an alist."
  (cdr (assoc key units)))

(defun resolve-unit (count unit-forms locale half)
  "Resolve a unit count to its display string using locale rules."
  (let* ((base-n (write-to-string count))
         (n (if (and half (> (length half) 0) (search "{n}" half))
                (string-replace-all half "{n}" base-n)
                base-n))
         (template (if (stringp unit-forms)
                       unit-forms
                       (let* ((category (if (and half (> (length half) 0))
                                            :other
                                            (funcall (duration-locale-plural locale) count)))
                              (entry (assoc category unit-forms)))
                         (if entry
                             (cdr entry)
                             (cdr (assoc :other unit-forms))))))
         (result (string-replace-all template "{n}" n)))
    (if (and half (> (length half) 0) (search "{0}" half))
        (string-replace-all half "{0}" result)
        result)))

;;; --- Formatter ---

(defstruct sayable-duration-formatter
  "Locale-aware duration formatter."
  (locale nil :type (or null duration-locale))
  (units nil :type list)
  (half "" :type string)
  (delimiter "" :type string)
  (just-now "" :type string)
  (ago "" :type string)
  (in-future "" :type string))

(defun pick-override (ovr-value default-value)
  "Pick the override value if non-NIL, else default."
  (if ovr-value ovr-value default-value))

(defun make-formatter (locale &optional (compactness :normal))
  "Create a formatter for the given locale and compactness level."
  (let* ((ovr-units (case compactness
                      (:short (duration-locale-short-units locale))
                      (:compact (duration-locale-compact-units locale))
                      (otherwise nil)))
         (merged-units (list
                        (cons :second (or (get-unit :second ovr-units)
                                          (get-unit :second (duration-locale-units locale))))
                        (cons :minute (or (get-unit :minute ovr-units)
                                          (get-unit :minute (duration-locale-units locale))))
                        (cons :hour (or (get-unit :hour ovr-units)
                                        (get-unit :hour (duration-locale-units locale))))
                        (cons :day (or (get-unit :day ovr-units)
                                       (get-unit :day (duration-locale-units locale))))
                        (cons :week (or (get-unit :week ovr-units)
                                        (get-unit :week (duration-locale-units locale))))
                        (cons :month (or (get-unit :month ovr-units)
                                         (get-unit :month (duration-locale-units locale))))
                        (cons :year (or (get-unit :year ovr-units)
                                        (get-unit :year (duration-locale-units locale))))))
         (ovr-half (case compactness
                     (:short (duration-locale-short-half locale))
                     (:compact (duration-locale-compact-half locale))
                     (otherwise nil)))
         (ovr-delimiter (case compactness
                          (:short (duration-locale-short-delimiter locale))
                          (:compact (duration-locale-compact-delimiter locale))
                          (otherwise nil)))
         (ovr-ago (case compactness
                    (:short (duration-locale-short-ago locale))
                    (:compact (duration-locale-compact-ago locale))
                    (otherwise nil)))
         (ovr-in-future (case compactness
                          (:short (duration-locale-short-in-future locale))
                          (:compact (duration-locale-compact-in-future locale))
                          (otherwise nil))))
    (make-sayable-duration-formatter
     :locale locale
     :units merged-units
     :half (pick-override ovr-half (duration-locale-half locale))
     :delimiter (pick-override ovr-delimiter (duration-locale-delimiter locale))
     :just-now (duration-locale-just-now locale)
     :ago (pick-override ovr-ago (duration-locale-ago locale))
     :in-future (pick-override ovr-in-future (duration-locale-in-future locale)))))

;;; --- Duration formatting ---

(defun format-duration-seconds (formatter total)
  "Apply duration tiers to total seconds. Returns NIL beyond the 500-year ceiling."
  (let* ((loc (sayable-duration-formatter-locale formatter))
         (units (sayable-duration-formatter-units formatter))
         (half (sayable-duration-formatter-half formatter))
         (delimiter (sayable-duration-formatter-delimiter formatter)))
    ;; 0 seconds
    (when (= total 0)
      (return-from format-duration-seconds (sayable-duration-formatter-just-now formatter)))
    ;; 1-59 seconds
    (when (< total 60)
      (return-from format-duration-seconds
        (resolve-unit total (get-unit :second units) loc "")))
    (let ((total-minutes (floor total 60))
          (remainder-seconds (mod total 60)))
      ;; 1-4 minutes: minutes + seconds
      (when (< total-minutes 5)
        (let ((result (resolve-unit total-minutes (get-unit :minute units) loc "")))
          (when (> remainder-seconds 0)
            (setf result (concatenate 'string result delimiter
                                      (resolve-unit remainder-seconds
                                                    (get-unit :second units) loc ""))))
          (return-from format-duration-seconds result)))
      ;; 5-59 minutes
      (when (< total-minutes 60)
        (return-from format-duration-seconds
          (resolve-unit total-minutes (get-unit :minute units) loc ""))))
    (let ((total-hours (floor total 3600))
          (remainder-minutes (floor (mod total 3600) 60)))
      ;; 1-5 hours: hours + minutes (with half marker)
      (when (<= total-hours 5)
        (when (= remainder-minutes 30)
          (return-from format-duration-seconds
            (resolve-unit total-hours (get-unit :hour units) loc half)))
        (let ((result (resolve-unit total-hours (get-unit :hour units) loc "")))
          (when (> remainder-minutes 0)
            (setf result (concatenate 'string result delimiter
                                      (resolve-unit remainder-minutes
                                                    (get-unit :minute units) loc ""))))
          (return-from format-duration-seconds result)))
      ;; 6-23 hours
      (when (< total-hours 24)
        (return-from format-duration-seconds
          (resolve-unit total-hours (get-unit :hour units) loc ""))))
    (let ((total-days (floor total 86400))
          (remainder-hours (floor (mod total 86400) 3600)))
      ;; 1-2 days: days + hours (with half marker)
      (when (<= total-days 2)
        (when (= remainder-hours 12)
          (return-from format-duration-seconds
            (resolve-unit total-days (get-unit :day units) loc half)))
        (let ((result (resolve-unit total-days (get-unit :day units) loc "")))
          (when (> remainder-hours 0)
            (setf result (concatenate 'string result delimiter
                                      (resolve-unit remainder-hours
                                                    (get-unit :hour units) loc ""))))
          (return-from format-duration-seconds result)))
      ;; 3-6 days
      (when (< total-days 7)
        (return-from format-duration-seconds
          (resolve-unit total-days (get-unit :day units) loc "")))
      (let ((total-weeks (floor total-days 7))
            (remainder-days (mod total-days 7)))
        ;; 1-4 weeks: weeks + days (up to 29 days)
        (when (< total-days 30)
          (let ((result (resolve-unit total-weeks (get-unit :week units) loc "")))
            (when (> remainder-days 0)
              (setf result (concatenate 'string result delimiter
                                        (resolve-unit remainder-days
                                                      (get-unit :day units) loc ""))))
            (return-from format-duration-seconds result)))
        ;; Approximate months (30.44 days average)
        (let ((total-months (round (/ total-days 30.44d0))))
          (when (< total-months 1) (setf total-months 1))
          (when (> total-months +max-duration-months+)
            (return-from format-duration-seconds nil))
          ;; 1-11 months
          (when (< total-months 12)
            (return-from format-duration-seconds
              (resolve-unit total-months (get-unit :month units) loc "")))
          ;; 12+ months: years + months
          (let* ((total-years (floor total-months 12))
                 (remainder-months (mod total-months 12))
                 (result (resolve-unit total-years (get-unit :year units) loc "")))
            (when (> remainder-months 0)
              (setf result (concatenate 'string result delimiter
                                        (resolve-unit remainder-months
                                                      (get-unit :month units) loc ""))))
            result))))))

;;; --- Public API ---

(defun format-duration (formatter start-or-seconds &optional end)
  "Format a duration in human-friendly terms. Returns NIL for invalid input."
  (when (null start-or-seconds)
    (return-from format-duration nil))
  (cond
    ((integerp start-or-seconds)
     (if (< start-or-seconds 0)
         nil
         (format-duration-seconds formatter start-or-seconds)))
    ((stringp start-or-seconds)
     (when (null end)
       (return-from format-duration nil))
     (let ((s (parse-iso-to-seconds start-or-seconds))
           (e (parse-iso-to-seconds end)))
       (when (or (null s) (null e))
         (return-from format-duration nil))
       (format-duration-seconds formatter (abs (- e s)))))
    (t nil)))

(defun format-since (formatter start as-of)
  "Format elapsed time as 'X ago'. Returns NIL for invalid input."
  (when (or (null start) (null as-of)
            (not (stringp start)) (not (stringp as-of))
            (zerop (length start)) (zerop (length as-of)))
    (return-from format-since nil))
  (let ((s (parse-iso-to-seconds start))
        (a (parse-iso-to-seconds as-of)))
    (when (or (null s) (null a))
      (return-from format-since nil))
    (let ((diff (- a s)))
      (when (< diff 0)
        (return-from format-since nil))
      (when (= diff 0)
        (return-from format-since (sayable-duration-formatter-just-now formatter)))
      (let ((dur (format-duration-seconds formatter diff)))
        (when dur
          (string-replace-all (sayable-duration-formatter-ago formatter) "{0}" dur))))))

(defun format-until (formatter target as-of)
  "Format time until a future event as 'in X'. Returns NIL for invalid input."
  (when (or (null target) (null as-of)
            (not (stringp target)) (not (stringp as-of))
            (zerop (length target)) (zerop (length as-of)))
    (return-from format-until nil))
  (let ((tgt (parse-iso-to-seconds target))
        (a (parse-iso-to-seconds as-of)))
    (when (or (null tgt) (null a))
      (return-from format-until nil))
    (let ((diff (- tgt a)))
      (when (< diff 0)
        (return-from format-until nil))
      (when (= diff 0)
        (return-from format-until (sayable-duration-formatter-just-now formatter)))
      (let ((dur (format-duration-seconds formatter diff)))
        (when dur
          (string-replace-all (sayable-duration-formatter-in-future formatter) "{0}" dur))))))

;;; --- Default English functions ---

(declaim (ftype function get-locale)) ; defined by the generated locale registry, loaded later

(defvar *default-formatter* nil
  "Default English formatter, initialized when locales are loaded.")

(defun ensure-default-formatter ()
  "Ensure the default formatter is initialized."
  (unless *default-formatter*
    (let ((en (get-locale "en")))
      (when en
        (setf *default-formatter* (make-formatter en))))))

(defun default-format-duration (start-or-seconds &optional end)
  "Format a duration using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-duration *default-formatter* start-or-seconds end)))

(defun default-format-since (start as-of)
  "Format elapsed time using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-since *default-formatter* start as-of)))

(defun default-format-until (target as-of)
  "Format time until event using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-until *default-formatter* target as-of)))

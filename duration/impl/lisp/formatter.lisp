(in-package :sayable-duration)

(defvar +version+ "0.5.0")

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

(defun split-string (s delimiter)
  "Split S by DELIMITER character."
  (let ((result nil)
        (start 0))
    (loop for i from 0 below (length s)
          when (char= (char s i) delimiter)
            do (push (subseq s start i) result)
               (setf start (1+ i)))
    (push (subseq s start) result)
    (nreverse result)))

(defun str-to-int (s)
  "Parse a string as a non-negative integer."
  (str-to-int-impl s 0 0))

(defun str-to-int-impl (s idx acc)
  (if (>= idx (length s))
      acc
      (let ((ch (char s idx)))
        (if (digit-char-p ch)
            (str-to-int-impl s (1+ idx) (+ (* acc 10) (digit-char-p ch)))
            acc))))

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

(defun parse-iso-to-seconds (iso-str)
  "Parse ISO datetime string to epoch-ish seconds for diffing. Returns NIL on failure."
  (when (or (null iso-str)
            (not (stringp iso-str))
            (zerop (length iso-str)))
    (return-from parse-iso-to-seconds nil))
  (let ((t-pos (position #\T iso-str)))
    (unless t-pos (return-from parse-iso-to-seconds nil))
    (let* ((date-part (subseq iso-str 0 t-pos))
           (time-part (subseq iso-str (1+ t-pos)))
           (date-parts (split-string date-part #\-)))
      (unless (= (length date-parts) 3)
        (return-from parse-iso-to-seconds nil))
      (let ((year (str-to-int (first date-parts)))
            (month (str-to-int (second date-parts)))
            (day (str-to-int (third date-parts))))
        ;; Strip timezone info
        (let ((time-str time-part))
          (let ((plus-pos (position #\+ time-str)))
            (when plus-pos
              (setf time-str (subseq time-str 0 plus-pos))))
          (let ((z-pos (position #\Z time-str)))
            (when z-pos
              (setf time-str (subseq time-str 0 z-pos))))
          (let ((tp (split-string time-str #\:)))
            (let ((hour (str-to-int (first tp)))
                  (minute (if (> (length tp) 1)
                              (str-to-int (second tp))
                              0))
                  (second-val (if (> (length tp) 2)
                                  ;; Strip fractional seconds
                                  (let ((sec-str (first (split-string (third tp) #\.))))
                                    (str-to-int sec-str))
                                  0)))
              (let ((days (days-since-epoch year month day)))
                (+ (* days 86400) (* hour 3600) (* minute 60) second-val)))))))))

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
  "Apply duration tiers to total seconds."
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
        (let ((total-months (round total-days 30.44)))
          (when (< total-months 1) (setf total-months 1))
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
        (string-replace-all (sayable-duration-formatter-ago formatter) "{0}" dur)))))

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
        (string-replace-all (sayable-duration-formatter-in-future formatter) "{0}" dur)))))

;;; --- Default English functions ---

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

(in-package :sayable-age)

(defvar +version+ "0.5.0")

(defconstant +max-age-months+ 6000)

;;; --- Date utilities ---

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

(defun julian-day-number (year month day)
  "Compute the Julian Day Number for a date."
  (let* ((a (floor (- 14 month) 12))
         (y (+ year 4800 (- a)))
         (m (+ month (* 12 a) -3)))
    (+ day
       (floor (+ (* 153 m) 2) 5)
       (* 365 y)
       (floor y 4)
       (- (floor y 100))
       (floor y 400)
       -32045)))

(defun ascii-digit-p (ch)
  "Return T if CH is one of the ASCII digits 0-9."
  (char<= #\0 ch #\9))

(defun digits-value (s start end)
  "Return the integer spelled by the ASCII digits of S from START to END, or NIL."
  (when (every #'ascii-digit-p (subseq s start end))
    (parse-integer s :start start :end end)))

(defun parse-date (date-str)
  "Parse exactly YYYY-MM-DD naming a real calendar day into (values year month day).
Returns NIL on failure."
  (when (and (stringp date-str)
             (= (length date-str) 10)
             (char= (char date-str 4) #\-)
             (char= (char date-str 7) #\-))
    (let ((year (digits-value date-str 0 4))
          (month (digits-value date-str 5 7))
          (day (digits-value date-str 8 10)))
      (when (and year month day
                 (<= 1 month 12)
                 (<= 1 day (days-in-month year month)))
        (values year month day)))))

;;; --- Default reference date ---

(defun local-today-string ()
  "Today's local date as YYYY-MM-DD."
  (multiple-value-bind (sec min hour day month year) (get-decoded-time)
    (declare (ignore sec min hour))
    (format nil "~4,'0D-~2,'0D-~2,'0D" year month day)))

(defun resolve-as-of (as-of-str)
  "AS-OF-STR, or today's local date when it is NIL or empty."
  (if (or (null as-of-str) (equal as-of-str ""))
      (local-today-string)
      as-of-str))

;;; --- Age computation ---

(defun compute-age (dob-str as-of-str)
  "Parse DOB and as-of strings, compute (values months diff-days) or NIL."
  (multiple-value-bind (dob-y dob-m dob-d) (parse-date dob-str)
    (unless dob-y (return-from compute-age nil))
    (multiple-value-bind (ref-y ref-m ref-d) (parse-date as-of-str)
      (unless ref-y (return-from compute-age nil))
      (let ((diff-days (- (julian-day-number ref-y ref-m ref-d)
                          (julian-day-number dob-y dob-m dob-d))))
        (when (< diff-days 0)
          (return-from compute-age nil))
        (let* ((last-day (days-in-month ref-y ref-m))
               (clamped-birthday (min dob-d last-day))
               (months (+ (* (- ref-y dob-y) 12)
                          (- ref-m dob-m))))
          (when (< ref-d clamped-birthday)
            (decf months))
          (when (> months +max-age-months+)
            (return-from compute-age nil))
          (values months diff-days))))))

;;; --- Stage resolution ---

(defun stage-key (months)
  "Map calendar months to a stage keyword."
  (cond
    ((< months 2) :newborn)
    ((< months 12) :infant)
    ((< months 36) :toddler)
    ((< months 156) :child)
    ((< months 216) :teenager)
    (t :adult)))

(defun resolve-stage-label (label gender)
  "Resolve a stage label, optionally selecting a gendered variant."
  (if (stringp label)
      label
      ;; label is an alist like ((:m . "...") (:f . "..."))
      (if (and gender (string= gender "f"))
          (cdr (assoc :f label))
          (cdr (assoc :m label)))))

;;; --- Unit resolution ---

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

(defun resolve-unit (count unit-forms locale half)
  "Resolve a unit count to its display string using locale rules."
  (let* ((base-n (write-to-string count))
         (n (if (and half (> (length half) 0) (search "{n}" half))
                (string-replace-all half "{n}" base-n)
                base-n))
         (template (if (stringp unit-forms)
                       unit-forms
                       (let* ((category (funcall (age-locale-plural locale) count))
                              (entry (assoc category unit-forms)))
                         (if entry
                             (cdr entry)
                             (cdr (assoc :other unit-forms))))))
         (result (string-replace-all template "{n}" n)))
    (if (and half (> (length half) 0) (search "{0}" half))
        (string-replace-all half "{0}" result)
        result)))

;;; --- Formatter ---

(defstruct sayable-age-formatter
  "Locale-aware age formatter."
  (locale nil :type (or null age-locale))
  (units nil :type list)
  (half "" :type string)
  (delimiter "" :type string)
  (just-born "" :type string))

(defun get-unit (key units)
  "Look up a unit by keyword from an alist."
  (cdr (assoc key units)))

(defun pick-override (ovr-value default-value)
  "Pick the override value if non-NIL, else default."
  (if ovr-value ovr-value default-value))

(defun make-formatter (locale &optional (compactness :normal))
  "Create a formatter for the given locale and compactness level."
  (let* ((ovr-units (case compactness
                      (:short (age-locale-short-units locale))
                      (:compact (age-locale-compact-units locale))
                      (otherwise nil)))
         (merged-units (list
                        (cons :day (or (get-unit :day ovr-units)
                                       (get-unit :day (age-locale-units locale))))
                        (cons :week (or (get-unit :week ovr-units)
                                        (get-unit :week (age-locale-units locale))))
                        (cons :month (or (get-unit :month ovr-units)
                                         (get-unit :month (age-locale-units locale))))
                        (cons :year (or (get-unit :year ovr-units)
                                        (get-unit :year (age-locale-units locale))))))
         (ovr-half (case compactness
                     (:short (age-locale-short-half locale))
                     (:compact (age-locale-compact-half locale))
                     (otherwise nil)))
         (ovr-delimiter (case compactness
                          (:short (age-locale-short-delimiter locale))
                          (:compact (age-locale-compact-delimiter locale))
                          (otherwise nil)))
         (ovr-just-born (case compactness
                          (:short (age-locale-short-just-born locale))
                          (:compact (age-locale-compact-just-born locale))
                          (otherwise nil))))
    (make-sayable-age-formatter
     :locale locale
     :units merged-units
     :half (pick-override ovr-half (age-locale-half locale))
     :delimiter (pick-override ovr-delimiter (age-locale-delimiter locale))
     :just-born (pick-override ovr-just-born (age-locale-just-born locale)))))

(defun format-age (formatter dob-str &optional as-of-str)
  "Format an age as a human-friendly string. Returns NIL for invalid input."
  (when (or (null dob-str)
            (not (stringp dob-str))
            (zerop (length dob-str))
            (string= dob-str "undefined"))
    (return-from format-age nil))
  (setf as-of-str (resolve-as-of as-of-str))
  (multiple-value-bind (months diff-days) (compute-age dob-str as-of-str)
    (unless months (return-from format-age nil))
    (let* ((loc (sayable-age-formatter-locale formatter))
           (units (sayable-age-formatter-units formatter))
           (half (sayable-age-formatter-half formatter))
           (delimiter (sayable-age-formatter-delimiter formatter)))
      ;; Tier 1: 0-6 days
      (when (zerop diff-days)
        (return-from format-age (sayable-age-formatter-just-born formatter)))
      (when (< diff-days 7)
        (return-from format-age (resolve-unit diff-days (get-unit :day units) loc "")))
      ;; Tier 2: weeks + days until 3 calendar months
      (when (< months 3)
        (let* ((weeks (floor diff-days 7))
               (days (mod diff-days 7))
               (result (resolve-unit weeks (get-unit :week units) loc "")))
          (when (> days 0)
            (setf result (concatenate 'string result delimiter
                                      (resolve-unit days (get-unit :day units) loc ""))))
          (return-from format-age result)))
      ;; Tier 3: 3-23 months
      (when (< months 24)
        (return-from format-age (resolve-unit months (get-unit :month units) loc "")))
      ;; Tier 4: 24-35 months -> years + months
      (when (< months 36)
        (let* ((years (floor months 12))
               (rem (mod months 12)))
          (if (zerop rem)
              (return-from format-age (resolve-unit years (get-unit :year units) loc ""))
              (return-from format-age
                (concatenate 'string
                             (resolve-unit years (get-unit :year units) loc "")
                             delimiter
                             (resolve-unit rem (get-unit :month units) loc ""))))))
      ;; Tier 5: 3-6 years -> half marker
      (when (< months 84)
        (let* ((years (floor months 12))
               (rem (mod months 12)))
          (if (>= rem 6)
              (return-from format-age (resolve-unit years (get-unit :year units) loc half))
              (return-from format-age (resolve-unit years (get-unit :year units) loc "")))))
      ;; Tier 6: 7+ years
      (resolve-unit (floor months 12) (get-unit :year units) loc ""))))

(defun format-stage (formatter dob-str &optional as-of-str gender)
  "Format a developmental stage label. Returns NIL for invalid input."
  (when (or (null dob-str)
            (not (stringp dob-str))
            (zerop (length dob-str))
            (string= dob-str "undefined"))
    (return-from format-stage nil))
  (setf as-of-str (resolve-as-of as-of-str))
  (multiple-value-bind (months diff-days) (compute-age dob-str as-of-str)
    (declare (ignore diff-days))
    (unless months (return-from format-stage nil))
    (let* ((loc (sayable-age-formatter-locale formatter))
           (key (stage-key months))
           (label (cdr (assoc key (age-locale-stages loc)))))
      (resolve-stage-label label gender))))

;;; --- Default English functions (set up after locales are loaded) ---

(declaim (ftype function get-locale)) ; defined by the generated locale registry, loaded later

(defvar *default-formatter* nil
  "Default English formatter, initialized when locales are loaded.")

(defun ensure-default-formatter ()
  "Ensure the default formatter is initialized."
  (unless *default-formatter*
    (let ((en (get-locale "en")))
      (when en
        (setf *default-formatter* (make-formatter en))))))

(defun default-format-age (dob-str &optional as-of-str)
  "Format an age using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-age *default-formatter* dob-str as-of-str)))

(defun default-format-stage (dob-str &optional as-of-str gender)
  "Format a stage using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-stage *default-formatter* dob-str as-of-str gender)))

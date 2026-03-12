(in-package :sayable-date)

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

;;; --- Date parsing ---

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

(defun parse-date (date-str)
  "Parse a YYYY-MM-DD or ISO datetime string into (values year month day).
Returns NIL on failure."
  (when (and date-str
             (stringp date-str)
             (> (length date-str) 0))
    ;; Strip time part if ISO datetime
    (let ((date-part (if (position #\T date-str)
                         (subseq date-str 0 (position #\T date-str))
                         date-str)))
      (let ((parts (split-string date-part #\-)))
        (when (= (length parts) 3)
          (let ((year (str-to-int (first parts)))
                (month (str-to-int (second parts)))
                (day (str-to-int (third parts))))
            (when (and (>= month 1) (<= month 12)
                       (>= day 1) (<= day 31))
              (values year month day))))))))

;;; --- Date arithmetic ---

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

(defun weekday (year month day)
  "Return day of week: 0=Sunday, 1=Monday, ..., 6=Saturday."
  (mod (1+ (julian-day-number year month day)) 7))

;;; --- Formatter ---

(defstruct sayable-date-formatter
  "Locale-aware date formatter."
  (locale nil :type (or null date-locale))
  (compactness :normal :type keyword)
  (months nil :type list)
  (months-in-date nil)
  (weekdays nil :type list)
  (day-format "" :type string)
  (day-format-exceptions nil :type list)
  (date-pattern "" :type string)
  (date-pattern-with-year "" :type string)
  (today-str "" :type string)
  (tomorrow-str "" :type string)
  (yesterday-str "" :type string))

(defun pick-override (ovr-value default-value)
  "Pick the override value if non-NIL, else default."
  (if ovr-value ovr-value default-value))

(defun make-formatter (locale &optional (compactness :normal))
  "Create a formatter for the given locale and compactness level."
  (let* ((ovr-months (case compactness
                       (:short (date-locale-short-months locale))
                       (otherwise nil)))
         (ovr-weekdays (case compactness
                         (:short (date-locale-short-weekdays locale))
                         (otherwise nil)))
         (ovr-day-format (case compactness
                           (:short (date-locale-short-day-format locale))
                           (otherwise nil)))
         ;; When short overrides dayFormat but not dayFormatExceptions,
         ;; clear the exceptions (mirroring Python behavior)
         (ovr-day-format-exceptions
           (cond
             ((eq compactness :short)
              (if (and (date-locale-short-day-format locale)
                       (null (date-locale-short-day-format-exceptions locale)))
                  ;; short overrides dayFormat but not exceptions => clear exceptions
                  :cleared
                  (date-locale-short-day-format-exceptions locale)))
             (t nil)))
         (ovr-date-pattern (case compactness
                             (:short (date-locale-short-date-pattern locale))
                             (:compact (date-locale-compact-date-pattern locale))
                             (otherwise nil)))
         (ovr-date-pattern-with-year (case compactness
                                       (:short (date-locale-short-date-pattern-with-year locale))
                                       (:compact (date-locale-compact-date-pattern-with-year locale))
                                       (otherwise nil))))
    (make-sayable-date-formatter
     :locale locale
     :compactness compactness
     :months (or ovr-months (date-locale-months locale))
     :months-in-date (date-locale-months-in-date locale)
     :weekdays (or ovr-weekdays (date-locale-weekdays locale))
     :day-format (pick-override ovr-day-format (date-locale-day-format locale))
     :day-format-exceptions (if (eq ovr-day-format-exceptions :cleared)
                                nil
                                (or ovr-day-format-exceptions
                                    (date-locale-day-format-exceptions locale)))
     :date-pattern (pick-override ovr-date-pattern (date-locale-date-pattern locale))
     :date-pattern-with-year (pick-override ovr-date-pattern-with-year
                                            (date-locale-date-pattern-with-year locale))
     :today-str (date-locale-today locale)
     :tomorrow-str (date-locale-tomorrow locale)
     :yesterday-str (date-locale-yesterday locale))))

;;; --- Absolute date formatting ---

(defun format-absolute (formatter year month day include-year)
  "Format a date as an absolute calendar reference."
  (let* ((day-str (write-to-string day))
         (exceptions (sayable-date-formatter-day-format-exceptions formatter))
         (fmt (or (cdr (assoc day-str exceptions :test #'string=))
                  (sayable-date-formatter-day-format formatter)))
         (formatted-day (string-replace-all fmt "{n}" day-str))
         ;; Pick month name (genitive form if available)
         (month-names (or (sayable-date-formatter-months-in-date formatter)
                          (sayable-date-formatter-months formatter)))
         (month-name (nth (1- month) month-names))
         (pattern (if include-year
                      (sayable-date-formatter-date-pattern-with-year formatter)
                      (sayable-date-formatter-date-pattern formatter)))
         (result (string-replace-all pattern "{month}" month-name)))
    (setf result (string-replace-all result "{day}" formatted-day))
    (setf result (string-replace-all result "{d}" (write-to-string day)))
    (setf result (string-replace-all result "{m}" (write-to-string month)))
    (when include-year
      (setf result (string-replace-all result "{year}" (write-to-string year)))
      (let ((yy (mod year 100)))
        (setf result (string-replace-all result "{yy}"
                                         (if (< yy 10)
                                             (concatenate 'string "0" (write-to-string yy))
                                             (write-to-string yy))))))
    result))

;;; --- Public API ---

(defun format-date (formatter date-str)
  "Format a calendar date in locale-appropriate form. Returns NIL for invalid input."
  (when (or (null date-str)
            (not (stringp date-str))
            (zerop (length date-str)))
    (return-from format-date nil))
  (multiple-value-bind (year month day) (parse-date date-str)
    (unless year (return-from format-date nil))
    (format-absolute formatter year month day nil)))

(defun format-date-with-year (formatter date-str)
  "Format a calendar date with year. Returns NIL for invalid input."
  (when (or (null date-str)
            (not (stringp date-str))
            (zerop (length date-str)))
    (return-from format-date-with-year nil))
  (multiple-value-bind (year month day) (parse-date date-str)
    (unless year (return-from format-date-with-year nil))
    (format-absolute formatter year month day t)))

(defun format-relative (formatter date-str as-of-str)
  "Format a date relative to as-of, picking the most natural reference.
Returns NIL for invalid input."
  (when (or (null date-str)
            (not (stringp date-str))
            (zerop (length date-str))
            (null as-of-str)
            (not (stringp as-of-str))
            (zerop (length as-of-str)))
    (return-from format-relative nil))
  (multiple-value-bind (dy dm dd) (parse-date date-str)
    (unless dy (return-from format-relative nil))
    (multiple-value-bind (ay am ad) (parse-date as-of-str)
      (unless ay (return-from format-relative nil))
      (let* ((date-jdn (julian-day-number dy dm dd))
             (asof-jdn (julian-day-number ay am ad))
             (diff (- date-jdn asof-jdn))
             (loc (sayable-date-formatter-locale formatter))
             (is-compact (eq (sayable-date-formatter-compactness formatter) :compact)))
        ;; Today
        (when (= diff 0)
          (return-from format-relative (sayable-date-formatter-today-str formatter)))
        ;; Tomorrow
        (when (= diff 1)
          (return-from format-relative (sayable-date-formatter-tomorrow-str formatter)))
        ;; Yesterday
        (when (= diff -1)
          (return-from format-relative (sayable-date-formatter-yesterday-str formatter)))
        ;; Day after tomorrow (optional)
        (when (and (= diff 2)
                   (date-locale-day-after-tomorrow loc)
                   (not is-compact))
          (return-from format-relative (date-locale-day-after-tomorrow loc)))
        ;; Day before yesterday (optional)
        (when (and (= diff -2)
                   (date-locale-day-before-yesterday loc)
                   (not is-compact))
          (return-from format-relative (date-locale-day-before-yesterday loc)))
        ;; Compact mode: skip weekday references
        (when is-compact
          (let ((include-year (/= dy ay)))
            (return-from format-relative
              (format-absolute formatter dy dm dd include-year))))
        ;; This weekday (+2 to +6)
        (when (and (<= 2 diff 6) (date-locale-this-weekday loc))
          (let* ((dow (weekday dy dm dd))
                 (weekday-name (nth dow (sayable-date-formatter-weekdays formatter))))
            (return-from format-relative
              (string-replace-all (date-locale-this-weekday loc) "{weekday}" weekday-name))))
        ;; Last weekday (-2 to -6)
        (when (and (<= -6 diff -2) (date-locale-last-weekday loc))
          (let* ((dow (weekday dy dm dd))
                 (weekday-name (nth dow (sayable-date-formatter-weekdays formatter))))
            (return-from format-relative
              (string-replace-all (date-locale-last-weekday loc) "{weekday}" weekday-name))))
        ;; Next weekday (+7 to +13)
        (when (and (<= 7 diff 13) (date-locale-next-weekday loc))
          (let* ((dow (weekday dy dm dd))
                 (weekday-name (nth dow (sayable-date-formatter-weekdays formatter))))
            (return-from format-relative
              (string-replace-all (date-locale-next-weekday loc) "{weekday}" weekday-name))))
        ;; Calendar fallback
        (let ((include-year (/= dy ay)))
          (format-absolute formatter dy dm dd include-year))))))

;;; --- Default English functions ---

(defvar *default-formatter* nil
  "Default English formatter, initialized when locales are loaded.")

(defun ensure-default-formatter ()
  "Ensure the default formatter is initialized."
  (unless *default-formatter*
    (let ((en (get-locale "en")))
      (when en
        (setf *default-formatter* (make-formatter en))))))

(defun default-format-date (date-str)
  "Format a date using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-date *default-formatter* date-str)))

(defun default-format-relative (date-str as-of-str)
  "Format a relative date using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-relative *default-formatter* date-str as-of-str)))

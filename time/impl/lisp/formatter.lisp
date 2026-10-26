(in-package :sayable-time)

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

;;; --- Time parsing ---

(defun leap-year-p (year)
  "Return T if YEAR is a Gregorian leap year."
  (or (and (zerop (mod year 4))
           (not (zerop (mod year 100))))
      (zerop (mod year 400))))

(defun days-in-month (year month)
  "Return the number of days in MONTH of YEAR."
  (case month
    ((4 6 9 11) 30)
    (2 (if (leap-year-p year) 29 28))
    (otherwise 31)))

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

(defun clock-start (input-str)
  "Return where the clock time starts in INPUT-STR: 0, or after the T of an ISO datetime
whose date part is a real YYYY-MM-DD day. Returns NIL for a malformed date part."
  (let ((t-pos (position #\T input-str)))
    (cond
      ((null t-pos) 0)
      ((and (= t-pos 10) (parse-date-part input-str)) 11)
      (t nil))))

(defun parse-time (input-str)
  "Parse a clock time or ISO datetime to (values hour minute). Returns NIL on failure."
  (when (and (stringp input-str) (plusp (length input-str)))
    (let ((start (clock-start input-str)))
      (when start
        (multiple-value-bind (hour minute) (parse-clock input-str start)
          (when hour
            (values hour minute)))))))

(defun round-to-5 (minute)
  "Round minute to nearest 5."
  (* (floor (+ minute 2) 5) 5))

;;; --- Formatter ---

(defstruct sayable-time-formatter
  "Locale-aware clock time formatter."
  (locale nil :type (or null time-locale))
  (compactness :normal :type keyword)
  (short-clock nil))

(defun make-formatter (locale &optional (compactness :normal))
  "Create a formatter for the given locale and compactness level."
  (let ((sc (case compactness
              (:short (time-locale-short-clock locale))
              (:compact (time-locale-compact-clock locale))
              (otherwise nil))))
    (make-sayable-time-formatter
     :locale locale
     :compactness compactness
     :short-clock sc)))

;;; --- Natural time formatting ---

(defun format-natural (formatter hour minute)
  "Format time as spoken natural language."
  (let* ((clock (time-locale-clock (sayable-time-formatter-locale formatter)))
         (rounded (round-to-5 minute))
         (h hour))
    ;; Handle rounding to next hour
    (when (= rounded 60)
      (setf rounded 0)
      (setf h (mod (1+ h) 24)))
    ;; Special cases for midnight and noon
    (when (= rounded 0)
      (when (= h 0)
        (return-from format-natural (clock-config-midnight clock)))
      (when (= h 12)
        (return-from format-natural (clock-config-noon clock))))
    (let* ((h12 (mod h 12))
           (next-h12 (mod (1+ h) 12))
           (h-name (nth h12 (clock-config-hours clock)))
           (next-h-name (nth next-h12 (clock-config-hours clock)))
           (pattern (or (cdr (assoc rounded (clock-config-patterns clock)))
                        (cdr (assoc 0 (clock-config-patterns clock)))
                        "{h}")))
      (string-replace-all
       (string-replace-all pattern "{h}" h-name)
       "{next_h}" next-h-name))))

;;; --- Digital time formatting ---

(defun zero-pad-2 (n)
  "Pad integer N to 2 digits with leading zero."
  (if (< n 10)
      (concatenate 'string "0" (write-to-string n))
      (write-to-string n)))

(defun format-digital (formatter hour minute)
  "Format time as digital clock display."
  (let* ((sc (sayable-time-formatter-short-clock formatter))
         (fmt (short-clock-config-format sc)))
    (if (short-clock-config-use24h sc)
        ;; 24-hour format
        (string-replace-all
         (string-replace-all fmt "{h}" (write-to-string hour))
         "{mm}" (zero-pad-2 minute))
        ;; 12-hour format
        (let* ((h12 (mod hour 12))
               (h12-display (if (= h12 0) 12 h12))
               (am-pm-pair (or (short-clock-config-am-pm sc)
                               (cons "AM" "PM")))
               (ampm-str (if (< hour 12)
                             (car am-pm-pair)
                             (cdr am-pm-pair))))
          (string-replace-all
           (string-replace-all
            (string-replace-all fmt "{h}" (write-to-string h12-display))
            "{mm}" (zero-pad-2 minute))
           "{ampm}" ampm-str)))))

;;; --- Public API ---

(defun format-time (formatter input-str)
  "Format a time as natural language clock reading. Returns NIL for invalid input."
  (when (or (null input-str)
            (not (stringp input-str))
            (zerop (length input-str)))
    (return-from format-time nil))
  (multiple-value-bind (hour minute) (parse-time input-str)
    (unless hour (return-from format-time nil))
    (if (and (not (eq (sayable-time-formatter-compactness formatter) :normal))
             (sayable-time-formatter-short-clock formatter))
        (format-digital formatter hour minute)
        (format-natural formatter hour minute))))

;;; --- Default English function ---

(declaim (ftype function get-locale)) ; defined by the generated locale registry, loaded later

(defvar *default-formatter* nil
  "Default English formatter, initialized when locales are loaded.")

(defun ensure-default-formatter ()
  "Ensure the default formatter is initialized."
  (unless *default-formatter*
    (let ((en (get-locale "en")))
      (when en
        (setf *default-formatter* (make-formatter en))))))

(defun default-format-time (input-str)
  "Format a time using the default English locale."
  (ensure-default-formatter)
  (when *default-formatter*
    (format-time *default-formatter* input-str)))

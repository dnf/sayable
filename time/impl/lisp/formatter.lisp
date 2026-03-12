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

(defun parse-time (input-str)
  "Parse HH:MM or ISO datetime to (values hour minute). Returns NIL on failure."
  (when (or (null input-str)
            (not (stringp input-str))
            (zerop (length input-str)))
    (return-from parse-time nil))
  (let ((t-str input-str))
    ;; Strip date part from ISO datetime
    (let ((t-pos (position #\T t-str)))
      (when t-pos
        (setf t-str (subseq t-str (1+ t-pos)))))
    ;; Strip timezone
    (let ((plus-pos (position #\+ t-str)))
      (when plus-pos
        (setf t-str (subseq t-str 0 plus-pos))))
    (let ((z-pos (position #\Z t-str)))
      (when z-pos
        (setf t-str (subseq t-str 0 z-pos))))
    (let ((parts (split-string t-str #\:)))
      (when (< (length parts) 2)
        (return-from parse-time nil))
      ;; Strip fractional seconds from minute part if present
      (let* ((hour-str (first parts))
             (min-str (first (split-string (second parts) #\.)))
             (hour (str-to-int hour-str))
             (minute (str-to-int min-str)))
        ;; Validate
        (when (or (< hour 0) (> hour 23)
                  (< minute 0) (> minute 59))
          (return-from parse-time nil))
        ;; Extra validation: make sure the strings were numeric
        (when (or (zerop (length hour-str))
                  (zerop (length min-str))
                  (not (digit-char-p (char hour-str 0)))
                  (not (digit-char-p (char min-str 0))))
          (return-from parse-time nil))
        (values hour minute)))))

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

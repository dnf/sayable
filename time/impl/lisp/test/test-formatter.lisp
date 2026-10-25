(defpackage :sayable-time-test
  (:use :cl :sayable-time)
  (:export #:run-tests))

(in-package :sayable-time-test)

(defvar *pass-count* 0)
(defvar *fail-count* 0)

(defun check-equal (test-id actual expected)
  "Check that ACTUAL equals EXPECTED."
  (if (equal actual expected)
      (incf *pass-count*)
      (progn
        (format t "FAIL ~a: expected ~s, got ~s~%" test-id expected actual)
        (incf *fail-count*))))

(defun check-nil (test-id actual)
  "Check that ACTUAL is NIL."
  (if (null actual)
      (incf *pass-count*)
      (progn
        (format t "FAIL ~a: expected NIL, got ~s~%" test-id actual)
        (incf *fail-count*))))

;; Section 1: Null / edge cases
(defun test-section-1 ()
  ;; 1.1
  (check-nil "1.1" (format-time (make-formatter (get-locale "en") :normal) nil))
  ;; 1.2
  (check-nil "1.2" (format-time (make-formatter (get-locale "en") :normal) ""))
  ;; 1.3
  (check-nil "1.3" (format-time (make-formatter (get-locale "en") :normal) "invalid"))
  ;; 1.4
  (check-nil "1.4" (format-time (make-formatter (get-locale "en") :normal) "25:00"))
)

;; Section 2: Clock time (normal compactness)
(defun test-section-2 ()
  ;; 2.1
  (check-equal "2.1" (format-time (make-formatter (get-locale "en") :normal) "00:00") "midnight")
  ;; 2.2
  (check-equal "2.2" (format-time (make-formatter (get-locale "en") :normal) "12:00") "noon")
  ;; 2.3
  (check-equal "2.3" (format-time (make-formatter (get-locale "en") :normal) "15:00") "three o'clock")
  ;; 2.4
  (check-equal "2.4" (format-time (make-formatter (get-locale "en") :normal) "14:15") "a quarter past two")
  ;; 2.5
  (check-equal "2.5" (format-time (make-formatter (get-locale "en") :normal) "09:30") "half past nine")
  ;; 2.6
  (check-equal "2.6" (format-time (make-formatter (get-locale "en") :normal) "10:45") "a quarter to eleven")
  ;; 2.7
  (check-equal "2.7" (format-time (make-formatter (get-locale "en") :normal) "08:05") "five past eight")
  ;; 2.8
  (check-equal "2.8" (format-time (make-formatter (get-locale "en") :normal) "16:55") "five to five")
  ;; 2.9 — rounds to 0:00 of next day
  (check-equal "2.9" (format-time (make-formatter (get-locale "en") :normal) "23:58") "midnight")
  ;; 2.10 — 22 rounds to 20
  (check-equal "2.10" (format-time (make-formatter (get-locale "en") :normal) "07:22") "twenty past seven")
  ;; 2.11 — ISO datetime input
  (check-equal "2.11" (format-time (make-formatter (get-locale "en") :normal) "2025-01-15T14:15:00") "a quarter past two")
)

;; Section 3: Clock time (short compactness)
(defun test-section-3 ()
  ;; 3.1
  (check-equal "3.1" (format-time (make-formatter (get-locale "en") :short) "14:15") "2:15 PM")
  ;; 3.2
  (check-equal "3.2" (format-time (make-formatter (get-locale "en") :short) "09:30") "9:30 AM")
  ;; 3.3
  (check-equal "3.3" (format-time (make-formatter (get-locale "en") :short) "00:00") "12:00 AM")
  ;; 3.4
  (check-equal "3.4" (format-time (make-formatter (get-locale "en") :short) "12:00") "12:00 PM")
)

;; Section 4: Clock time (compact)
(defun test-section-4 ()
  ;; 4.1
  (check-equal "4.1" (format-time (make-formatter (get-locale "en") :compact) "14:15") "2:15p")
  ;; 4.2
  (check-equal "4.2" (format-time (make-formatter (get-locale "en") :compact) "09:30") "9:30a")
)

;; Section 5: Locale — German
(defun test-section-5 ()
  ;; 5.1
  (check-equal "5.1" (format-time (make-formatter (get-locale "de") :normal) "15:30") "halb vier")
)

;; Section 6: Locale — French
(defun test-section-6 ()
  ;; 6.1
  (check-equal "6.1" (format-time (make-formatter (get-locale "fr") :normal) "15:15") "trois heures et quart")
)

;; Section 7: Locale — Japanese
(defun test-section-7 ()
  ;; 7.1
  (check-equal "7.1" (format-time (make-formatter (get-locale "ja") :normal) "15:30") "三時半")
)

;; Section 8: Locale — Finnish (dot separator, short)
(defun test-section-8 ()
  ;; 8.1 — dot separator per CLDR Finnish time format
  (check-equal "8.1" (format-time (make-formatter (get-locale "fi") :short) "14:15") "14.15")
  ;; 8.2 — midnight in 24h dot format
  (check-equal "8.2" (format-time (make-formatter (get-locale "fi") :short) "00:00") "0.00")
)

;; Section 9: Minutes in short and compact modes
(defun test-section-9 ()
  ;; 9.1
  (check-equal "9.1" (format-time (make-formatter (get-locale "en") :short) "18:01") "6:01 PM")
  ;; 9.2
  (check-equal "9.2" (format-time (make-formatter (get-locale "en") :compact) "19:05") "7:05p")
)

;; Section 10: Input validation
(defun test-section-10 ()
  ;; 10.1
  (check-equal "10.1" (format-time (make-formatter (get-locale "en") :normal) "9:30") "half past nine")
  ;; 10.2
  (check-equal "10.2" (format-time (make-formatter (get-locale "en") :normal) "09:30") "half past nine")
  ;; 10.3
  (check-nil "10.3" (format-time (make-formatter (get-locale "en") :normal) " 9:30"))
  ;; 10.4
  (check-nil "10.4" (format-time (make-formatter (get-locale "en") :normal) "9:30 "))
  ;; 10.5
  (check-nil "10.5" (format-time (make-formatter (get-locale "en") :normal) "9:5"))
  ;; 10.6
  (check-nil "10.6" (format-time (make-formatter (get-locale "en") :normal) "24:00"))
  ;; 10.7
  (check-equal "10.7" (format-time (make-formatter (get-locale "en") :normal) "14:15:30") "a quarter past two")
  ;; 10.8
  (check-equal "10.8" (format-time (make-formatter (get-locale "en") :normal) "2025-01-15T14:15:00Z") "a quarter past two")
  ;; 10.9
  (check-nil "10.9" (format-time (make-formatter (get-locale "en") :normal) "2025-02-30T14:15:00"))
)

(defun run-tests ()
  (setf *pass-count* 0)
  (setf *fail-count* 0)
  (format t "~%Running sayable-time tests...~%~%")
  (test-section-1)
  (test-section-2)
  (test-section-3)
  (test-section-4)
  (test-section-5)
  (test-section-6)
  (test-section-7)
  (test-section-8)
  (test-section-9)
  (test-section-10)

  (format t "~%Results: ~a passed, ~a failed~%" *pass-count* *fail-count*)
  (when (> *fail-count* 0)
    (sb-ext:exit :code 1)))

(defpackage :sayable-date-test
  (:use :cl :sayable-date)
  (:export #:run-tests))

(in-package :sayable-date-test)

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
  (check-nil "1.1" (format-date (make-formatter (get-locale "en") :normal) nil))
  ;; 1.2
  (check-nil "1.2" (format-date (make-formatter (get-locale "en") :normal) ""))
  ;; 1.3
  (check-nil "1.3" (format-date (make-formatter (get-locale "en") :normal) "invalid"))
  ;; 1.4
  (check-nil "1.4" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-15" nil))
  ;; 1.5
  (check-nil "1.5" (format-relative (make-formatter (get-locale "en") :normal) nil "2025-03-15"))
)

;; Section 2: format_date — normal compactness (English)
(defun test-section-2 ()
  ;; 2.1
  (check-equal "2.1" (format-date (make-formatter (get-locale "en") :normal) "2025-03-15") "March 15th")
  ;; 2.2
  (check-equal "2.2" (format-date (make-formatter (get-locale "en") :normal) "2025-01-01") "January 1st")
  ;; 2.3
  (check-equal "2.3" (format-date (make-formatter (get-locale "en") :normal) "2025-05-22") "May 22nd")
  ;; 2.4
  (check-equal "2.4" (format-date (make-formatter (get-locale "en") :normal) "2025-07-03") "July 3rd")
  ;; 2.5
  (check-equal "2.5" (format-date (make-formatter (get-locale "en") :normal) "2025-12-31") "December 31st")
  ;; 2.6
  (check-equal "2.6" (format-date (make-formatter (get-locale "en") :normal) "2025-06-11") "June 11th")
  ;; 2.7
  (check-equal "2.7" (format-date (make-formatter (get-locale "en") :normal) "2025-03-15T14:30:00") "March 15th")
)

;; Section 3: format_date — short compactness (English)
(defun test-section-3 ()
  ;; 3.1
  (check-equal "3.1" (format-date (make-formatter (get-locale "en") :short) "2025-03-15") "Mar 15")
  ;; 3.2
  (check-equal "3.2" (format-date (make-formatter (get-locale "en") :short) "2025-01-01") "Jan 1")
  ;; 3.3
  (check-equal "3.3" (format-date (make-formatter (get-locale "en") :short) "2025-12-25") "Dec 25")
)

;; Section 4: format_date — compact (English)
(defun test-section-4 ()
  ;; 4.1
  (check-equal "4.1" (format-date (make-formatter (get-locale "en") :compact) "2025-03-15") "3/15")
  ;; 4.2
  (check-equal "4.2" (format-date (make-formatter (get-locale "en") :compact) "2025-01-01") "1/1")
)

;; Section 5: format_relative — proximity tiers (English)
(defun test-section-5 ()
  ;; 5.1
  (check-equal "5.1" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-15" "2025-03-15") "today")
  ;; 5.2
  (check-equal "5.2" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-16" "2025-03-15") "tomorrow")
  ;; 5.3
  (check-equal "5.3" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-14" "2025-03-15") "yesterday")
  ;; 5.4
  (check-equal "5.4" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-17" "2025-03-15") "the day after tomorrow")
  ;; 5.5
  (check-equal "5.5" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-13" "2025-03-15") "the day before yesterday")
  ;; 5.6
  (check-equal "5.6" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-19" "2025-03-15") "this Wednesday")
  ;; 5.7
  (check-equal "5.7" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-20" "2025-03-15") "this Thursday")
  ;; 5.8
  (check-equal "5.8" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-11" "2025-03-15") "last Tuesday")
  ;; 5.9
  (check-equal "5.9" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-22" "2025-03-15") "next Saturday")
  ;; 5.10
  (check-equal "5.10" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-27" "2025-03-15") "next Thursday")
  ;; 5.11
  (check-equal "5.11" (format-relative (make-formatter (get-locale "en") :normal) "2025-03-01" "2025-03-15") "March 1st")
  ;; 5.12
  (check-equal "5.12" (format-relative (make-formatter (get-locale "en") :normal) "2025-04-10" "2025-03-15") "April 10th")
  ;; 5.13
  (check-equal "5.13" (format-relative (make-formatter (get-locale "en") :normal) "2026-01-05" "2025-03-15") "January 5th, 2026")
  ;; 5.14
  (check-equal "5.14" (format-relative (make-formatter (get-locale "en") :normal) "2024-12-25" "2025-03-15") "December 25th, 2024")
)

;; Section 6: format_relative — compact skips weekday tiers
(defun test-section-6 ()
  ;; 6.1
  (check-equal "6.1" (format-relative (make-formatter (get-locale "en") :compact) "2025-03-15" "2025-03-15") "today")
  ;; 6.2
  (check-equal "6.2" (format-relative (make-formatter (get-locale "en") :compact) "2025-03-16" "2025-03-15") "tomorrow")
  ;; 6.3
  (check-equal "6.3" (format-relative (make-formatter (get-locale "en") :compact) "2025-03-19" "2025-03-15") "3/19")
  ;; 6.4
  (check-equal "6.4" (format-relative (make-formatter (get-locale "en") :compact) "2026-01-05" "2025-03-15") "1/5/26")
)

;; Section 7: Locale — German
(defun test-section-7 ()
  ;; 7.1
  (check-equal "7.1" (format-date (make-formatter (get-locale "de") :normal) "2025-03-15") "15. März")
  ;; 7.2
  (check-equal "7.2" (format-relative (make-formatter (get-locale "de") :normal) "2025-03-16" "2025-03-15") "morgen")
  ;; 7.3
  (check-equal "7.3" (format-relative (make-formatter (get-locale "de") :normal) "2025-03-17" "2025-03-15") "übermorgen")
  ;; 7.4
  (check-equal "7.4" (format-relative (make-formatter (get-locale "de") :normal) "2025-03-19" "2025-03-15") "diesen Mittwoch")
)

;; Section 8: Locale — French
(defun test-section-8 ()
  ;; 8.1
  (check-equal "8.1" (format-date (make-formatter (get-locale "fr") :normal) "2025-03-01") "1er mars")
  ;; 8.2
  (check-equal "8.2" (format-date (make-formatter (get-locale "fr") :normal) "2025-03-15") "15 mars")
  ;; 8.3
  (check-equal "8.3" (format-relative (make-formatter (get-locale "fr") :normal) "2025-03-16" "2025-03-15") "demain")
)

;; Section 9: Locale — Japanese
(defun test-section-9 ()
  ;; 9.1
  (check-equal "9.1" (format-date (make-formatter (get-locale "ja") :normal) "2025-03-15") "3月15日")
  ;; 9.2
  (check-equal "9.2" (format-relative (make-formatter (get-locale "ja") :normal) "2025-03-16" "2025-03-15") "明日")
  ;; 9.3
  (check-equal "9.3" (format-relative (make-formatter (get-locale "ja") :normal) "2025-03-19" "2025-03-15") "今度の水曜日")
)

;; Section 10: Locale — Russian (genitive months)
(defun test-section-10 ()
  ;; 10.1
  (check-equal "10.1" (format-date (make-formatter (get-locale "ru") :normal) "2025-03-15") "15 марта")
  ;; 10.2
  (check-equal "10.2" (format-relative (make-formatter (get-locale "ru") :normal) "2025-03-16" "2025-03-15") "завтра")
)

;; Section 11: Locale — Arabic
(defun test-section-11 ()
  ;; 11.1
  (check-equal "11.1" (format-date (make-formatter (get-locale "ar") :normal) "2025-03-15") "15 مارس")
  ;; 11.2
  (check-equal "11.2" (format-relative (make-formatter (get-locale "ar") :normal) "2025-03-16" "2025-03-15") "غداً")
)

;; Section 12: Locale — Spanish
(defun test-section-12 ()
  ;; 12.1
  (check-equal "12.1" (format-date (make-formatter (get-locale "es") :normal) "2025-03-15") "15 de marzo")
  ;; 12.2
  (check-equal "12.2" (format-relative (make-formatter (get-locale "es") :normal) "2025-03-17" "2025-03-15") "pasado mañana")
)

(defun run-tests ()
  (setf *pass-count* 0)
  (setf *fail-count* 0)
  (format t "~%Running sayable-date tests...~%~%")
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
  (test-section-11)
  (test-section-12)

  (format t "~%Results: ~a passed, ~a failed~%" *pass-count* *fail-count*)
  (when (> *fail-count* 0)
    (sb-ext:exit :code 1)))

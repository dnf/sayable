(defpackage :sayable-age-test
  (:use :cl :sayable-age)
  (:export #:run-tests))

(in-package :sayable-age-test)

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

(defun check-contains (test-id actual substring)
  "Check that ACTUAL contains SUBSTRING."
  (if (and actual (search substring actual))
      (incf *pass-count*)
      (progn
        (format t "FAIL ~a: expected to contain ~s, got ~s~%" test-id substring actual)
        (incf *fail-count*))))

(defun check-locale-code (test-id locale expected-code)
  "Check that LOCALE has the expected code."
  (if locale
      (if (string= (sayable-age::age-locale-code locale) expected-code)
          (incf *pass-count*)
          (progn
            (format t "FAIL ~a: expected code ~s, got ~s~%" test-id expected-code (sayable-age::age-locale-code locale))
            (incf *fail-count*)))
      (progn
        (format t "FAIL ~a: expected locale with code ~s, got NIL~%" test-id expected-code)
        (incf *fail-count*))))

;; Section 1: Null / edge cases
(defun test-section-1 ()
  ;; 1.1
  (check-nil "1.1" (format-age (make-formatter (get-locale "en") :normal) nil nil))
  ;; 1.2
  (check-nil "1.2" (format-age (make-formatter (get-locale "en") :normal) "undefined" nil))
  ;; 1.3
  (check-nil "1.3" (format-age (make-formatter (get-locale "en") :normal) "" nil))
  ;; 1.4
  (check-nil "1.4" (format-age (make-formatter (get-locale "en") :normal) "2025-07-01" "2025-06-15"))
  ;; 1.5
  (check-equal "1.5" (format-age (make-formatter (get-locale "en") :normal) "1525-06-15" "2025-06-15") "500 years")
  ;; 1.6
  (check-nil "1.6" (format-age (make-formatter (get-locale "en") :normal) "1524-06-15" "2025-06-15"))
  ;; 1.7
  (check-nil "1.7" (format-age (make-formatter (get-locale "en") :normal) "1025-06-15" "2025-06-15"))
)

;; Section 2: Days tier (0–6 days)
(defun test-section-2 ()
  ;; 2.1
  (check-equal "2.1" (format-age (make-formatter (get-locale "en") :normal) "2025-06-15" "2025-06-15") "Newborn")
  ;; 2.2
  (check-equal "2.2" (format-age (make-formatter (get-locale "en") :normal) "2025-06-14" "2025-06-15") "1 day")
  ;; 2.3
  (check-equal "2.3" (format-age (make-formatter (get-locale "en") :normal) "2025-06-12" "2025-06-15") "3 days")
  ;; 2.4
  (check-equal "2.4" (format-age (make-formatter (get-locale "en") :normal) "2025-06-09" "2025-06-15") "6 days")
  ;; 2.5
  (check-equal "2.5" (format-age (make-formatter (get-locale "en") :normal) "2025-06-08" "2025-06-15") "1 week")
)

;; Section 3: Weeks+days tier (7 days to <3 calendar months)
(defun test-section-3 ()
  ;; 3.1
  (check-equal "3.1" (format-age (make-formatter (get-locale "en") :normal) "2025-06-08" "2025-06-15") "1 week")
  ;; 3.2
  (check-equal "3.2" (format-age (make-formatter (get-locale "en") :normal) "2025-06-07" "2025-06-15") "1 week, 1 day")
  ;; 3.3
  (check-equal "3.3" (format-age (make-formatter (get-locale "en") :normal) "2025-06-06" "2025-06-15") "1 week, 2 days")
  ;; 3.4
  (check-equal "3.4" (format-age (make-formatter (get-locale "en") :normal) "2025-06-02" "2025-06-15") "1 week, 6 days")
  ;; 3.5
  (check-equal "3.5" (format-age (make-formatter (get-locale "en") :normal) "2025-06-01" "2025-06-15") "2 weeks")
  ;; 3.6
  (check-equal "3.6" (format-age (make-formatter (get-locale "en") :normal) "2025-05-31" "2025-06-15") "2 weeks, 1 day")
  ;; 3.7
  (check-equal "3.7" (format-age (make-formatter (get-locale "en") :normal) "2025-05-26" "2025-06-15") "2 weeks, 6 days")
  ;; 3.8
  (check-equal "3.8" (format-age (make-formatter (get-locale "en") :normal) "2025-05-25" "2025-06-15") "3 weeks")
  ;; 3.9
  (check-equal "3.9" (format-age (make-formatter (get-locale "en") :normal) "2025-05-15" "2025-06-15") "4 weeks, 3 days")
  ;; 3.10
  (check-equal "3.10" (format-age (make-formatter (get-locale "en") :normal) "2025-04-15" "2025-06-15") "8 weeks, 5 days")
  ;; 3.11
  (check-equal "3.11" (format-age (make-formatter (get-locale "en") :normal) "2025-03-15" "2025-06-14") "13 weeks")
  ;; 3.12
  (check-equal "3.12" (format-age (make-formatter (get-locale "en") :normal) "2025-03-15" "2025-06-15") "3 months")
)

;; Section 4: Month boundaries — standard months
(defun test-section-4 ()
  ;; 4.1
  (check-equal "4.1" (format-age (make-formatter (get-locale "en") :normal) "2025-01-01" "2025-04-01") "3 months")
  ;; 4.2
  (check-contains "4.2" (format-age (make-formatter (get-locale "en") :normal) "2025-01-01" "2025-03-31") "weeks")
  ;; 4.3
  (check-equal "4.3" (format-age (make-formatter (get-locale "en") :normal) "2025-06-15" "2025-09-15") "3 months")
  ;; 4.4
  (check-contains "4.4" (format-age (make-formatter (get-locale "en") :normal) "2025-06-15" "2025-09-14") "weeks")
  ;; 4.5
  (check-equal "4.5" (format-age (make-formatter (get-locale "en") :normal) "2025-06-15" "2025-12-15") "6 months")
)

;; Section 5: Month boundaries — February non-leap year
(defun test-section-5 ()
  ;; 5.1
  (check-equal "5.1" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-02-28") "4 weeks")
  ;; 5.2
  (check-equal "5.2" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-04-30") "3 months")
  ;; 5.3
  (check-contains "5.3" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-04-29") "weeks")
  ;; 5.4
  (check-equal "5.4" (format-age (make-formatter (get-locale "en") :normal) "2025-02-01" "2025-05-01") "3 months")
  ;; 5.5
  (check-contains "5.5" (format-age (make-formatter (get-locale "en") :normal) "2025-02-01" "2025-04-30") "weeks")
)

;; Section 6: Month boundaries — February leap year
(defun test-section-6 ()
  ;; 6.1
  (check-equal "6.1" (format-age (make-formatter (get-locale "en") :normal) "2024-01-31" "2024-02-29") "4 weeks, 1 day")
  ;; 6.2
  (check-equal "6.2" (format-age (make-formatter (get-locale "en") :normal) "2024-01-31" "2024-02-28") "4 weeks")
  ;; 6.3
  (check-equal "6.3" (format-age (make-formatter (get-locale "en") :normal) "2024-01-31" "2024-04-30") "3 months")
  ;; 6.4
  (check-contains "6.4" (format-age (make-formatter (get-locale "en") :normal) "2024-01-30" "2024-02-29") "weeks")
  ;; 6.5
  (check-contains "6.5" (format-age (make-formatter (get-locale "en") :normal) "2024-01-30" "2024-02-28") "weeks")
)

;; Section 7: Month boundaries — 30-day months
(defun test-section-7 ()
  ;; 7.1
  (check-equal "7.1" (format-age (make-formatter (get-locale "en") :normal) "2025-03-31" "2025-06-30") "3 months")
  ;; 7.2
  (check-contains "7.2" (format-age (make-formatter (get-locale "en") :normal) "2025-03-31" "2025-06-29") "weeks")
  ;; 7.3
  (check-equal "7.3" (format-age (make-formatter (get-locale "en") :normal) "2025-08-31" "2025-11-30") "3 months")
  ;; 7.4
  (check-contains "7.4" (format-age (make-formatter (get-locale "en") :normal) "2025-08-31" "2025-11-29") "weeks")
)

;; Section 8: Month boundaries — leap year baby (born Feb 29)
(defun test-section-8 ()
  ;; 8.1
  (check-equal "8.1" (format-age (make-formatter (get-locale "en") :normal) "2024-02-29" "2024-05-29") "3 months")
  ;; 8.2
  (check-contains "8.2" (format-age (make-formatter (get-locale "en") :normal) "2024-02-29" "2024-05-28") "weeks")
  ;; 8.3
  (check-equal "8.3" (format-age (make-formatter (get-locale "en") :normal) "2024-02-29" "2025-02-28") "12 months")
  ;; 8.4
  (check-equal "8.4" (format-age (make-formatter (get-locale "en") :normal) "2024-02-29" "2025-03-01") "12 months")
)

;; Section 9: Months tier (3–23 months)
(defun test-section-9 ()
  ;; 9.1
  (check-equal "9.1" (format-age (make-formatter (get-locale "en") :normal) "2025-01-15" "2025-04-15") "3 months")
  ;; 9.2
  (check-equal "9.2" (format-age (make-formatter (get-locale "en") :normal) "2025-01-15" "2025-07-15") "6 months")
  ;; 9.3
  (check-equal "9.3" (format-age (make-formatter (get-locale "en") :normal) "2024-06-15" "2025-06-15") "12 months")
  ;; 9.4
  (check-equal "9.4" (format-age (make-formatter (get-locale "en") :normal) "2024-01-15" "2025-12-15") "23 months")
  ;; 9.5
  (check-equal "9.5" (format-age (make-formatter (get-locale "en") :normal) "2025-01-15" "2025-07-14") "5 months")
  ;; 9.6
  (check-equal "9.6" (format-age (make-formatter (get-locale "en") :normal) "2024-11-10" "2025-04-10") "5 months")
)

;; Section 10: Years+months tier (24–35 months)
(defun test-section-10 ()
  ;; 10.1
  (check-equal "10.1" (format-age (make-formatter (get-locale "en") :normal) "2023-06-15" "2025-06-15") "2 years")
  ;; 10.2
  (check-equal "10.2" (format-age (make-formatter (get-locale "en") :normal) "2023-06-15" "2025-07-15") "2 years, 1 month")
  ;; 10.3
  (check-equal "10.3" (format-age (make-formatter (get-locale "en") :normal) "2023-06-15" "2025-12-15") "2 years, 6 months")
  ;; 10.4
  (check-equal "10.4" (format-age (make-formatter (get-locale "en") :normal) "2023-06-15" "2026-05-15") "2 years, 11 months")
  ;; 10.5
  (check-equal "10.5" (format-age (make-formatter (get-locale "en") :normal) "2023-06-15" "2025-06-14") "23 months")
)

;; Section 11: Half-year tier (3–6 years)
(defun test-section-11 ()
  ;; 11.1
  (check-equal "11.1" (format-age (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-06-15") "3 years")
  ;; 11.2
  (check-equal "11.2" (format-age (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-11-15") "3 years")
  ;; 11.3
  (check-equal "11.3" (format-age (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-12-15") "3½ years")
  ;; 11.4
  (check-equal "11.4" (format-age (make-formatter (get-locale "en") :normal) "2022-06-15" "2026-05-15") "3½ years")
  ;; 11.5
  (check-equal "11.5" (format-age (make-formatter (get-locale "en") :normal) "2021-06-15" "2025-06-15") "4 years")
  ;; 11.6
  (check-equal "11.6" (format-age (make-formatter (get-locale "en") :normal) "2021-06-15" "2025-12-15") "4½ years")
  ;; 11.7
  (check-equal "11.7" (format-age (make-formatter (get-locale "en") :normal) "2020-06-15" "2025-06-15") "5 years")
  ;; 11.8
  (check-equal "11.8" (format-age (make-formatter (get-locale "en") :normal) "2020-06-15" "2026-02-15") "5½ years")
  ;; 11.9
  (check-equal "11.9" (format-age (make-formatter (get-locale "en") :normal) "2019-06-15" "2025-06-15") "6 years")
  ;; 11.10
  (check-equal "11.10" (format-age (make-formatter (get-locale "en") :normal) "2019-06-15" "2025-12-15") "6½ years")
  ;; 11.11
  (check-equal "11.11" (format-age (make-formatter (get-locale "en") :normal) "2019-06-15" "2026-05-15") "6½ years")
  ;; 11.12
  (check-equal "11.12" (format-age (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-06-14") "2 years, 11 months")
)

;; Section 12: Integer tier (7+ years)
(defun test-section-12 ()
  ;; 12.1
  (check-equal "12.1" (format-age (make-formatter (get-locale "en") :normal) "2018-06-15" "2025-06-15") "7 years")
  ;; 12.2
  (check-equal "12.2" (format-age (make-formatter (get-locale "en") :normal) "2018-03-20" "2025-06-15") "7 years")
  ;; 12.3
  (check-equal "12.3" (format-age (make-formatter (get-locale "en") :normal) "1980-01-01" "2025-06-15") "45 years")
)

;; Section 13: Cross-year transitions with February
(defun test-section-13 ()
  ;; 13.1
  (check-equal "13.1" (format-age (make-formatter (get-locale "en") :normal) "2024-12-31" "2025-03-31") "3 months")
  ;; 13.2
  (check-contains "13.2" (format-age (make-formatter (get-locale "en") :normal) "2024-12-31" "2025-03-30") "weeks")
  ;; 13.3
  (check-equal "13.3" (format-age (make-formatter (get-locale "en") :normal) "2024-11-30" "2025-02-28") "3 months")
  ;; 13.4
  (check-contains "13.4" (format-age (make-formatter (get-locale "en") :normal) "2024-11-30" "2025-02-27") "weeks")
)

;; Section 14: Born-on-31st progression
(defun test-section-14 ()
  ;; 14.1
  (check-equal "14.1" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-04-30") "3 months")
  ;; 14.2
  (check-equal "14.2" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-05-31") "4 months")
  ;; 14.3
  (check-equal "14.3" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-06-30") "5 months")
  ;; 14.4
  (check-equal "14.4" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-07-01") "5 months")
  ;; 14.5
  (check-equal "14.5" (format-age (make-formatter (get-locale "en") :normal) "2025-01-31" "2025-07-31") "6 months")
)

;; Section 15: Default asOf (current date) -- SKIPPED (requires system date mocking)

;; Section 16: formatStage — null / edge cases
(defun test-section-16 ()
  ;; 16.1
  (check-nil "16.1" (format-stage (make-formatter (get-locale "en") :normal) nil nil))
  ;; 16.2
  (check-nil "16.2" (format-stage (make-formatter (get-locale "en") :normal) "undefined" nil))
  ;; 16.3
  (check-nil "16.3" (format-stage (make-formatter (get-locale "en") :normal) "" nil))
  ;; 16.4
  (check-nil "16.4" (format-stage (make-formatter (get-locale "en") :normal) "2025-07-01" "2025-06-15"))
  ;; 16.5
  (check-equal "16.5" (format-stage (make-formatter (get-locale "en") :normal) "1525-06-15" "2025-06-15") "Adult")
  ;; 16.6
  (check-nil "16.6" (format-stage (make-formatter (get-locale "en") :normal) "1524-06-15" "2025-06-15"))
)

;; Section 17: formatStage — Newborn (0–1 months, <2 calendar months)
(defun test-section-17 ()
  ;; 17.1
  (check-equal "17.1" (format-stage (make-formatter (get-locale "en") :normal) "2025-06-15" "2025-06-15") "Newborn")
  ;; 17.2
  (check-equal "17.2" (format-stage (make-formatter (get-locale "en") :normal) "2025-06-14" "2025-06-15") "Newborn")
  ;; 17.3
  (check-equal "17.3" (format-stage (make-formatter (get-locale "en") :normal) "2025-05-25" "2025-06-15") "Newborn")
  ;; 17.4
  (check-equal "17.4" (format-stage (make-formatter (get-locale "en") :normal) "2025-05-15" "2025-06-15") "Newborn")
  ;; 17.5
  (check-equal "17.5" (format-stage (make-formatter (get-locale "en") :normal) "2025-04-16" "2025-06-15") "Newborn")
  ;; 17.6
  (check-equal "17.6" (format-stage (make-formatter (get-locale "en") :normal) "2025-04-15" "2025-06-15") "Infant")
)

;; Section 18: formatStage — Infant (2–11 months)
(defun test-section-18 ()
  ;; 18.1
  (check-equal "18.1" (format-stage (make-formatter (get-locale "en") :normal) "2025-04-15" "2025-06-15") "Infant")
  ;; 18.2
  (check-equal "18.2" (format-stage (make-formatter (get-locale "en") :normal) "2024-12-15" "2025-06-15") "Infant")
  ;; 18.3
  (check-equal "18.3" (format-stage (make-formatter (get-locale "en") :normal) "2024-07-15" "2025-06-15") "Infant")
  ;; 18.4
  (check-equal "18.4" (format-stage (make-formatter (get-locale "en") :normal) "2024-06-15" "2025-06-15") "Toddler")
)

;; Section 19: formatStage — Toddler (12–35 months)
(defun test-section-19 ()
  ;; 19.1
  (check-equal "19.1" (format-stage (make-formatter (get-locale "en") :normal) "2024-06-15" "2025-06-15") "Toddler")
  ;; 19.2
  (check-equal "19.2" (format-stage (make-formatter (get-locale "en") :normal) "2024-01-15" "2025-07-15") "Toddler")
  ;; 19.3
  (check-equal "19.3" (format-stage (make-formatter (get-locale "en") :normal) "2023-06-15" "2025-06-15") "Toddler")
  ;; 19.4
  (check-equal "19.4" (format-stage (make-formatter (get-locale "en") :normal) "2023-06-15" "2026-05-15") "Toddler")
  ;; 19.5
  (check-equal "19.5" (format-stage (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-06-15") "Child")
)

;; Section 20: formatStage — Child (36–155 months, 3–12 years)
(defun test-section-20 ()
  ;; 20.1
  (check-equal "20.1" (format-stage (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-06-15") "Child")
  ;; 20.2
  (check-equal "20.2" (format-stage (make-formatter (get-locale "en") :normal) "2021-06-15" "2025-06-15") "Child")
  ;; 20.3
  (check-equal "20.3" (format-stage (make-formatter (get-locale "en") :normal) "2019-06-15" "2025-06-15") "Child")
  ;; 20.4
  (check-equal "20.4" (format-stage (make-formatter (get-locale "en") :normal) "2016-06-15" "2025-06-15") "Child")
  ;; 20.5
  (check-equal "20.5" (format-stage (make-formatter (get-locale "en") :normal) "2013-06-15" "2026-05-15") "Child")
  ;; 20.6
  (check-equal "20.6" (format-stage (make-formatter (get-locale "en") :normal) "2012-06-15" "2025-06-15") "Teenager")
)

;; Section 21: formatStage — Teenager (156–215 months, 13–17 years)
(defun test-section-21 ()
  ;; 21.1
  (check-equal "21.1" (format-stage (make-formatter (get-locale "en") :normal) "2012-06-15" "2025-06-15") "Teenager")
  ;; 21.2
  (check-equal "21.2" (format-stage (make-formatter (get-locale "en") :normal) "2010-06-15" "2025-06-15") "Teenager")
  ;; 21.3
  (check-equal "21.3" (format-stage (make-formatter (get-locale "en") :normal) "2008-06-15" "2026-05-15") "Teenager")
  ;; 21.4
  (check-equal "21.4" (format-stage (make-formatter (get-locale "en") :normal) "2007-06-15" "2025-06-15") "Adult")
)

;; Section 22: formatStage — Adult (216+ months, 18+ years)
(defun test-section-22 ()
  ;; 22.1
  (check-equal "22.1" (format-stage (make-formatter (get-locale "en") :normal) "2007-06-15" "2025-06-15") "Adult")
  ;; 22.2
  (check-equal "22.2" (format-stage (make-formatter (get-locale "en") :normal) "2000-06-15" "2025-06-15") "Adult")
  ;; 22.3
  (check-equal "22.3" (format-stage (make-formatter (get-locale "en") :normal) "1980-01-01" "2025-06-15") "Adult")
)

;; Section 23: formatStage — default asOf -- SKIPPED (requires system date mocking)

;; Section 24: SayableAge class — English locale delegation
(defun test-section-24 ()
  ;; 24.1
  (check-equal "24.1" (format-age (make-formatter (get-locale "en") :normal) "2025-06-15" "2025-06-15") "Newborn")
  ;; 24.2
  (check-equal "24.2" (format-age (make-formatter (get-locale "en") :normal) "2025-06-12" "2025-06-15") "3 days")
  ;; 24.3
  (check-equal "24.3" (format-age (make-formatter (get-locale "en") :normal) "2025-06-07" "2025-06-15") "1 week, 1 day")
  ;; 24.4
  (check-equal "24.4" (format-age (make-formatter (get-locale "en") :normal) "2025-01-15" "2025-07-15") "6 months")
  ;; 24.5
  (check-equal "24.5" (format-age (make-formatter (get-locale "en") :normal) "2023-06-15" "2025-07-15") "2 years, 1 month")
  ;; 24.6
  (check-equal "24.6" (format-age (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-12-15") "3½ years")
  ;; 24.7
  (check-equal "24.7" (format-age (make-formatter (get-locale "en") :normal) "2018-06-15" "2025-06-15") "7 years")
  ;; 24.8
  (check-equal "24.8" (format-stage (make-formatter (get-locale "en") :normal) "2025-06-15" "2025-06-15") "Newborn")
  ;; 24.9
  (check-equal "24.9" (format-stage (make-formatter (get-locale "en") :normal) "2025-01-15" "2025-06-15") "Infant")
  ;; 24.10
  (check-equal "24.10" (format-stage (make-formatter (get-locale "en") :normal) "2024-06-15" "2025-06-15") "Toddler")
  ;; 24.11
  (check-equal "24.11" (format-stage (make-formatter (get-locale "en") :normal) "2022-06-15" "2025-06-15") "Child")
  ;; 24.12
  (check-equal "24.12" (format-stage (make-formatter (get-locale "en") :normal) "2012-06-15" "2025-06-15") "Teenager")
  ;; 24.13
  (check-equal "24.13" (format-stage (make-formatter (get-locale "en") :normal) "2007-06-15" "2025-06-15") "Adult")
  ;; 24.14
  (check-nil "24.14" (format-age (make-formatter (get-locale "en") :normal) nil "2025-06-15"))
  ;; 24.15
  (check-nil "24.15" (format-stage (make-formatter (get-locale "en") :normal) nil "2025-06-15"))
)

;; Section 25: i18n — locale with all plural features
(defun test-section-25 ()
  ;; 25.1
  (check-equal "25.1" (format-age (make-formatter (get-locale "es") :normal) "2025-06-15" "2025-06-15") "Recién nacido")
  ;; 25.2
  (check-equal "25.2" (format-age (make-formatter (get-locale "es") :normal) "2025-06-14" "2025-06-15") "1 día")
  ;; 25.3
  (check-equal "25.3" (format-age (make-formatter (get-locale "es") :normal) "2025-06-12" "2025-06-15") "3 días")
  ;; 25.4
  (check-equal "25.4" (format-age (make-formatter (get-locale "es") :normal) "2025-06-08" "2025-06-15") "1 semana")
  ;; 25.5
  (check-equal "25.5" (format-age (make-formatter (get-locale "es") :normal) "2025-06-07" "2025-06-15") "1 semana, 1 día")
  ;; 25.6
  (check-equal "25.6" (format-age (make-formatter (get-locale "es") :normal) "2025-05-26" "2025-06-15") "2 semanas, 6 días")
  ;; 25.7
  (check-equal "25.7" (format-age (make-formatter (get-locale "es") :normal) "2025-01-15" "2025-07-15") "6 meses")
  ;; 25.8
  (check-equal "25.8" (format-age (make-formatter (get-locale "es") :normal) "2023-06-15" "2025-07-15") "2 años, 1 mes")
  ;; 25.9
  (check-equal "25.9" (format-age (make-formatter (get-locale "es") :normal) "2023-06-15" "2025-12-15") "2 años, 6 meses")
  ;; 25.10
  (check-equal "25.10" (format-age (make-formatter (get-locale "es") :normal) "2022-06-15" "2025-12-15") "3 y medio años")
  ;; 25.11
  (check-equal "25.11" (format-age (make-formatter (get-locale "es") :normal) "2022-06-15" "2025-06-15") "3 años")
  ;; 25.12
  (check-equal "25.12" (format-age (make-formatter (get-locale "es") :normal) "2018-06-15" "2025-06-15") "7 años")
  ;; 25.13
  (check-equal "25.13" (format-stage (make-formatter (get-locale "es") :normal) "2025-06-15" "2025-06-15") "Recién nacido")
  ;; 25.14
  (check-equal "25.14" (format-stage (make-formatter (get-locale "es") :normal) "2025-01-15" "2025-06-15") "Bebé")
  ;; 25.15
  (check-equal "25.15" (format-stage (make-formatter (get-locale "es") :normal) "2024-06-15" "2025-06-15") "Niño pequeño")
  ;; 25.16
  (check-equal "25.16" (format-stage (make-formatter (get-locale "es") :normal) "2022-06-15" "2025-06-15") "Niño")
  ;; 25.17
  (check-equal "25.17" (format-stage (make-formatter (get-locale "es") :normal) "2012-06-15" "2025-06-15") "Adolescente")
  ;; 25.18
  (check-equal "25.18" (format-stage (make-formatter (get-locale "es") :normal) "2007-06-15" "2025-06-15") "Adulto")
  ;; 25.19
  (check-nil "25.19" (format-age (make-formatter (get-locale "es") :normal) nil "2025-06-15"))
  ;; 25.20
  (check-nil "25.20" (format-stage (make-formatter (get-locale "es") :normal) nil "2025-06-15"))
)

;; Section 26: Compactness — short
(defun test-section-26 ()
  ;; 26.1
  (check-equal "26.1" (format-age (make-formatter (get-locale "en") :short) "2025-06-12" "2025-06-15") "3 d")
  ;; 26.2
  (check-equal "26.2" (format-age (make-formatter (get-locale "en") :short) "2025-06-08" "2025-06-15") "1 wk")
  ;; 26.3
  (check-equal "26.3" (format-age (make-formatter (get-locale "en") :short) "2025-06-07" "2025-06-15") "1 wk, 1 d")
  ;; 26.4
  (check-equal "26.4" (format-age (make-formatter (get-locale "en") :short) "2025-01-15" "2025-07-15") "6 mo")
  ;; 26.5
  (check-equal "26.5" (format-age (make-formatter (get-locale "en") :short) "2023-06-15" "2025-07-15") "2 yr, 1 mo")
  ;; 26.6
  (check-equal "26.6" (format-age (make-formatter (get-locale "en") :short) "2022-06-15" "2025-12-15") "3½ yr")
  ;; 26.7
  (check-equal "26.7" (format-age (make-formatter (get-locale "en") :short) "2018-06-15" "2025-06-15") "7 yr")
  ;; 26.8
  (check-equal "26.8" (format-age (make-formatter (get-locale "en") :short) "2025-06-15" "2025-06-15") "Newborn")
  ;; 26.9
  (check-equal "26.9" (format-stage (make-formatter (get-locale "en") :short) "2025-01-15" "2025-06-15") "Infant")
)

;; Section 27: Compactness — compact
(defun test-section-27 ()
  ;; 27.1
  (check-equal "27.1" (format-age (make-formatter (get-locale "en") :compact) "2025-06-12" "2025-06-15") "3d")
  ;; 27.2
  (check-equal "27.2" (format-age (make-formatter (get-locale "en") :compact) "2025-06-08" "2025-06-15") "1w")
  ;; 27.3
  (check-equal "27.3" (format-age (make-formatter (get-locale "en") :compact) "2025-06-07" "2025-06-15") "1w1d")
  ;; 27.4
  (check-equal "27.4" (format-age (make-formatter (get-locale "en") :compact) "2025-01-15" "2025-07-15") "6m")
  ;; 27.5
  (check-equal "27.5" (format-age (make-formatter (get-locale "en") :compact) "2023-06-15" "2025-07-15") "2y1m")
  ;; 27.6
  (check-equal "27.6" (format-age (make-formatter (get-locale "en") :compact) "2022-06-15" "2025-12-15") "3½y")
  ;; 27.7
  (check-equal "27.7" (format-age (make-formatter (get-locale "en") :compact) "2018-06-15" "2025-06-15") "7y")
  ;; 27.8
  (check-equal "27.8" (format-age (make-formatter (get-locale "en") :compact) "2025-06-15" "2025-06-15") "Newborn")
)

;; Section 29: Locale-specific edge cases — plural rules
(defun test-section-29 ()
  ;; 29.1
  (check-equal "29.1" (format-age (make-formatter (get-locale "he") :normal) "2025-06-15" "2025-06-15") "רק נולד")
  ;; 29.2
  (check-equal "29.2" (format-age (make-formatter (get-locale "he") :normal) "2025-06-14" "2025-06-15") "יום 1")
  ;; 29.3
  (check-equal "29.3" (format-age (make-formatter (get-locale "he") :normal) "2025-06-12" "2025-06-15") "3 ימים")
  ;; 29.4
  (check-equal "29.4" (format-age (make-formatter (get-locale "he") :normal) "2025-06-01" "2025-06-15") "שבועיים")
  ;; 29.5
  (check-equal "29.5" (format-age (make-formatter (get-locale "he") :normal) "2025-05-25" "2025-06-15") "3 שבועות")
  ;; 29.6
  (check-equal "29.6" (format-age (make-formatter (get-locale "he") :normal) "2025-01-15" "2025-07-15") "6 חודשים")
  ;; 29.7
  (check-equal "29.7" (format-age (make-formatter (get-locale "he") :normal) "2025-03-15" "2025-06-15") "3 חודשים")
  ;; 29.8
  (check-equal "29.8" (format-age (make-formatter (get-locale "he") :normal) "2023-06-15" "2025-07-15") "שנתיים, חודש 1")
  ;; 29.9
  (check-equal "29.9" (format-age (make-formatter (get-locale "he") :normal) "2022-06-15" "2025-12-15") "3 שנים וחצי")
  ;; 29.10
  (check-equal "29.10" (format-age (make-formatter (get-locale "he") :normal) "2018-06-15" "2025-06-15") "7 שנים")
  ;; 29.11
  (check-equal "29.11" (format-stage (make-formatter (get-locale "he") :normal) "2025-06-15" "2025-06-15" "m") "רק נולד")
  ;; 29.12
  (check-equal "29.12" (format-stage (make-formatter (get-locale "he") :normal) "2025-06-15" "2025-06-15" "f") "רק נולדה")
  ;; 29.13
  (check-equal "29.13" (format-stage (make-formatter (get-locale "he") :normal) "2007-06-15" "2025-06-15" "m") "מבוגר")
  ;; 29.14
  (check-equal "29.14" (format-stage (make-formatter (get-locale "he") :normal) "2007-06-15" "2025-06-15" "f") "מבוגרת")
  ;; 29.15
  (check-equal "29.15" (format-age (make-formatter (get-locale "mk") :normal) "2025-06-15" "2025-06-15") "Новороденче")
  ;; 29.16
  (check-equal "29.16" (format-age (make-formatter (get-locale "mk") :normal) "2025-06-14" "2025-06-15") "1 ден")
  ;; 29.17
  (check-equal "29.17" (format-age (make-formatter (get-locale "mk") :normal) "2025-06-12" "2025-06-15") "3 дена")
  ;; 29.18
  (check-equal "29.18" (format-age (make-formatter (get-locale "mk") :normal) "2025-01-15" "2025-07-15") "6 месеци")
  ;; 29.19
  (check-equal "29.19" (format-age (make-formatter (get-locale "mk") :normal) "2023-06-15" "2025-07-15") "2 години, 1 месец")
  ;; 29.20
  (check-equal "29.20" (format-age (make-formatter (get-locale "mk") :normal) "2022-06-15" "2025-12-15") "3 години и пол")
  ;; 29.21
  (check-equal "29.21" (format-age (make-formatter (get-locale "mk") :normal) "2018-06-15" "2025-06-15") "7 години")
  ;; 29.22
  (check-equal "29.22" (format-age (make-formatter (get-locale "sw") :normal) "2025-06-15" "2025-06-15") "Mzaliwa mpya")
  ;; 29.23
  (check-equal "29.23" (format-age (make-formatter (get-locale "sw") :normal) "2025-06-14" "2025-06-15") "siku 1")
  ;; 29.24
  (check-equal "29.24" (format-age (make-formatter (get-locale "sw") :normal) "2025-06-12" "2025-06-15") "siku 3")
  ;; 29.25
  (check-equal "29.25" (format-age (make-formatter (get-locale "sw") :normal) "2025-01-15" "2025-07-15") "miezi 6")
  ;; 29.26
  (check-equal "29.26" (format-age (make-formatter (get-locale "sw") :normal) "2023-06-15" "2025-07-15") "miaka 2, mwezi 1")
  ;; 29.27
  (check-equal "29.27" (format-age (make-formatter (get-locale "sw") :normal) "2022-06-15" "2025-12-15") "miaka 3 na nusu")
  ;; 29.28
  (check-equal "29.28" (format-age (make-formatter (get-locale "id") :normal) "2025-06-15" "2025-06-15") "Baru lahir")
  ;; 29.29
  (check-equal "29.29" (format-age (make-formatter (get-locale "id") :normal) "2025-06-14" "2025-06-15") "1 hari")
  ;; 29.30
  (check-equal "29.30" (format-age (make-formatter (get-locale "id") :normal) "2025-06-12" "2025-06-15") "3 hari")
  ;; 29.31
  (check-equal "29.31" (format-age (make-formatter (get-locale "id") :normal) "2025-01-15" "2025-07-15") "6 bulan")
  ;; 29.32
  (check-equal "29.32" (format-age (make-formatter (get-locale "id") :normal) "2022-06-15" "2025-12-15") "3 tahun setengah")
  ;; 29.33
  (check-equal "29.33" (format-age (make-formatter (get-locale "id") :normal) "2018-06-15" "2025-06-15") "7 tahun")
  ;; 29.34
  (check-equal "29.34" (format-age (make-formatter (get-locale "am") :normal) "2025-06-15" "2025-06-15") "አዲስ የተወለደ")
  ;; 29.35
  (check-equal "29.35" (format-age (make-formatter (get-locale "am") :normal) "2025-06-14" "2025-06-15") "1 ቀን")
  ;; 29.36
  (check-equal "29.36" (format-age (make-formatter (get-locale "am") :normal) "2025-06-12" "2025-06-15") "3 ቀናት")
  ;; 29.37
  (check-equal "29.37" (format-age (make-formatter (get-locale "am") :normal) "2025-06-07" "2025-06-15") "1 ሳምንት፣ 1 ቀን")
  ;; 29.38
  (check-equal "29.38" (format-age (make-formatter (get-locale "am") :normal) "2025-01-15" "2025-07-15") "6 ወራት")
  ;; 29.39
  (check-equal "29.39" (format-age (make-formatter (get-locale "am") :normal) "2022-06-15" "2025-12-15") "3 ዓመታት ተኩል")
)

;; Section 30: Locale lookup by code string
(defun test-section-30 ()
  ;; 30.1
  (check-locale-code "30.1" (get-locale "en") "en")
  ;; 30.2
  (check-locale-code "30.2" (get-locale "fr") "fr")
  ;; 30.3
  (check-nil "30.3" (get-locale "xx"))
  ;; 30.4
  (check-nil "30.4" (get-locale ""))
  ;; 30.5
  (check-nil "30.5" (get-locale "EN"))
)

;; Section 31: Weeks and days across month ends
(defun test-section-31 ()
  ;; 31.1
  (check-equal "31.1" (format-age (make-formatter (get-locale "en") :normal) "2016-12-31" "2017-03-29") "12 weeks, 4 days")
  ;; 31.2
  (check-equal "31.2" (format-age (make-formatter (get-locale "en") :normal) "1991-11-27" "1992-02-25") "12 weeks, 6 days")
  ;; 31.3
  (check-equal "31.3" (format-age (make-formatter (get-locale "en") :normal) "2020-11-30" "2021-01-02") "4 weeks, 5 days")
  ;; 31.4
  (check-equal "31.4" (format-age (make-formatter (get-locale "en") :compact) "2016-12-31" "2017-03-29") "12w4d")
)

;; Section 32: Half years take their plural form from whole years
(defun test-section-32 ()
  ;; 32.1
  (check-equal "32.1" (format-age (make-formatter (get-locale "pl") :normal) "2021-06-15" "2025-01-15") "3 i pół lata")
  ;; 32.2
  (check-equal "32.2" (format-age (make-formatter (get-locale "pl") :short) "2020-06-15" "2025-12-15") "5 i pół lat")
  ;; 32.3
  (check-equal "32.3" (format-age (make-formatter (get-locale "shi") :normal) "2005-06-08" "2012-06-07") "6 iseggasen d uzgen")
)

;; Section 33: Input validation
(defun test-section-33 ()
  ;; 33.1
  (check-nil "33.1" (format-age (make-formatter (get-locale "en") :normal) "2025-02-30" "2032-06-25"))
  ;; 33.2
  (check-nil "33.2" (format-age (make-formatter (get-locale "en") :normal) "2025-13-01" "2027-01-31"))
  ;; 33.3
  (check-nil "33.3" (format-age (make-formatter (get-locale "en") :normal) "2023-02-29" "2025-03-01"))
  ;; 33.4
  (check-nil "33.4" (format-age (make-formatter (get-locale "en") :normal) "2025-06-00" "2027-02-25"))
  ;; 33.5
  (check-nil "33.5" (format-age (make-formatter (get-locale "en") :normal) "2025-6-1" "2027-02-25"))
  ;; 33.6
  (check-nil "33.6" (format-age (make-formatter (get-locale "en") :normal) " 2025-06-01" "2027-02-25"))
  ;; 33.7
  (check-nil "33.7" (format-age (make-formatter (get-locale "en") :normal) "2025-06-15T10:00:00" "2027-02-25"))
  ;; 33.8
  (check-nil "33.8" (format-age (make-formatter (get-locale "en") :normal) "2020-01-01" "2025-04-31"))
  ;; 33.9
  (check-nil "33.9" (format-stage (make-formatter (get-locale "en") :normal) "2025-02-30" "2027-09-05"))
  ;; 33.10
  (check-equal "33.10" (format-age (make-formatter (get-locale "en") :normal) "2024-02-29" "2026-03-01") "2 years")
)

(defun run-tests ()
  (setf *pass-count* 0)
  (setf *fail-count* 0)
  (format t "~%Running sayable-age tests...~%~%")
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
  (test-section-13)
  (test-section-14)
  ;; Section 15 skipped (system date mocking)
  (test-section-16)
  (test-section-17)
  (test-section-18)
  (test-section-19)
  (test-section-20)
  (test-section-21)
  (test-section-22)
  ;; Section 23 skipped (system date mocking)
  (test-section-24)
  (test-section-25)
  (test-section-26)
  (test-section-27)
  (test-section-29)
  (test-section-30)
  (test-section-31)
  (test-section-32)
  (test-section-33)

  (format t "~%Results: ~a passed, ~a failed~%" *pass-count* *fail-count*)
  (when (> *fail-count* 0)
    (sb-ext:exit :code 1)))

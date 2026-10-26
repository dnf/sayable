(defpackage :sayable-duration-test
  (:use :cl :sayable-duration)
  (:export #:run-tests))

(in-package :sayable-duration-test)

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
  (check-nil "1.1" (format-duration (make-formatter (get-locale "en") :normal) nil))
  ;; 1.2
  (check-nil "1.2" (format-duration (make-formatter (get-locale "en") :normal) -1))
  ;; 1.3
  (check-nil "1.3" (format-since (make-formatter (get-locale "en") :normal) nil "2025-01-15T10:00:00"))
  ;; 1.4
  (check-nil "1.4" (format-until (make-formatter (get-locale "en") :normal) nil "2025-01-15T10:00:00"))
  ;; 1.5 — asOf before start
  (check-nil "1.5" (format-since (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T09:00:00"))
  ;; 1.6 — target in the past
  (check-nil "1.6" (format-until (make-formatter (get-locale "en") :normal) "2025-01-15T09:00:00" "2025-01-15T10:00:00"))
)

;; Section 2: Duration — seconds tier (0-59s)
(defun test-section-2 ()
  ;; 2.1
  (check-equal "2.1" (format-duration (make-formatter (get-locale "en") :normal) 0) "just now")
  ;; 2.2
  (check-equal "2.2" (format-duration (make-formatter (get-locale "en") :normal) 1) "1 second")
  ;; 2.3
  (check-equal "2.3" (format-duration (make-formatter (get-locale "en") :normal) 45) "45 seconds")
  ;; 2.4
  (check-equal "2.4" (format-duration (make-formatter (get-locale "en") :normal) 59) "59 seconds")
)

;; Section 3: Duration — minutes + seconds tier (1-4 min)
(defun test-section-3 ()
  ;; 3.1
  (check-equal "3.1" (format-duration (make-formatter (get-locale "en") :normal) 60) "1 minute")
  ;; 3.2
  (check-equal "3.2" (format-duration (make-formatter (get-locale "en") :normal) 90) "1 minute, 30 seconds")
  ;; 3.3
  (check-equal "3.3" (format-duration (make-formatter (get-locale "en") :normal) 240) "4 minutes")
  ;; 3.4
  (check-equal "3.4" (format-duration (make-formatter (get-locale "en") :normal) 270) "4 minutes, 30 seconds")
)

;; Section 4: Duration — minutes tier (5-59 min)
(defun test-section-4 ()
  ;; 4.1
  (check-equal "4.1" (format-duration (make-formatter (get-locale "en") :normal) 300) "5 minutes")
  ;; 4.2
  (check-equal "4.2" (format-duration (make-formatter (get-locale "en") :normal) 1500) "25 minutes")
  ;; 4.3
  (check-equal "4.3" (format-duration (make-formatter (get-locale "en") :normal) 3540) "59 minutes")
)

;; Section 5: Duration — hours + minutes tier (1-5 hr)
(defun test-section-5 ()
  ;; 5.1
  (check-equal "5.1" (format-duration (make-formatter (get-locale "en") :normal) 3600) "1 hour")
  ;; 5.2 — half marker
  (check-equal "5.2" (format-duration (make-formatter (get-locale "en") :normal) 5400) "1½ hours")
  ;; 5.3
  (check-equal "5.3" (format-duration (make-formatter (get-locale "en") :normal) 8100) "2 hours, 15 minutes")
  ;; 5.4
  (check-equal "5.4" (format-duration (make-formatter (get-locale "en") :normal) 18000) "5 hours")
)

;; Section 6: Duration — hours tier (6-23 hr)
(defun test-section-6 ()
  ;; 6.1
  (check-equal "6.1" (format-duration (make-formatter (get-locale "en") :normal) 28800) "8 hours")
  ;; 6.2
  (check-equal "6.2" (format-duration (make-formatter (get-locale "en") :normal) 82800) "23 hours")
)

;; Section 7: Duration — days tier
(defun test-section-7 ()
  ;; 7.1
  (check-equal "7.1" (format-duration (make-formatter (get-locale "en") :normal) 86400) "1 day")
  ;; 7.2
  (check-equal "7.2" (format-duration (make-formatter (get-locale "en") :normal) 97200) "1 day, 3 hours")
  ;; 7.3 — half marker
  (check-equal "7.3" (format-duration (make-formatter (get-locale "en") :normal) 129600) "1½ days")
  ;; 7.4
  (check-equal "7.4" (format-duration (make-formatter (get-locale "en") :normal) 432000) "5 days")
  ;; 7.5
  (check-equal "7.5" (format-duration (make-formatter (get-locale "en") :normal) 172800) "2 days")
)

;; Section 8: Duration — weeks tier
(defun test-section-8 ()
  ;; 8.1
  (check-equal "8.1" (format-duration (make-formatter (get-locale "en") :normal) 604800) "1 week")
  ;; 8.2
  (check-equal "8.2" (format-duration (make-formatter (get-locale "en") :normal) 1296000) "2 weeks, 1 day")
  ;; 8.3
  (check-equal "8.3" (format-duration (make-formatter (get-locale "en") :normal) 2419200) "4 weeks")
)

;; Section 9: Duration — months and years tier
(defun test-section-9 ()
  ;; 9.1 — ~31 days
  (check-equal "9.1" (format-duration (make-formatter (get-locale "en") :normal) 2678400) "1 month")
  ;; 9.2 — ~91 days
  (check-equal "9.2" (format-duration (make-formatter (get-locale "en") :normal) 7884000) "3 months")
  ;; 9.3 — 365 days
  (check-equal "9.3" (format-duration (make-formatter (get-locale "en") :normal) 31536000) "1 year")
  ;; 9.4 — ~456 days
  (check-equal "9.4" (format-duration (make-formatter (get-locale "en") :normal) 39420000) "1 year, 3 months")
)

;; Section 10: Duration from ISO timestamps
(defun test-section-10 ()
  ;; 10.1
  (check-equal "10.1" (format-duration (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T11:30:00") "1½ hours")
  ;; 10.2
  (check-equal "10.2" (format-duration (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T10:45:00") "45 minutes")
)

;; Section 11: Relative time — since
(defun test-section-11 ()
  ;; 11.1
  (check-equal "11.1" (format-since (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T10:00:00") "just now")
  ;; 11.2
  (check-equal "11.2" (format-since (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T10:00:30") "30 seconds ago")
  ;; 11.3
  (check-equal "11.3" (format-since (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T10:45:00") "45 minutes ago")
  ;; 11.4
  (check-equal "11.4" (format-since (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T13:00:00") "3 hours ago")
)

;; Section 12: Relative time — until
(defun test-section-12 ()
  ;; 12.1
  (check-equal "12.1" (format-until (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T10:00:00") "just now")
  ;; 12.2
  (check-equal "12.2" (format-until (make-formatter (get-locale "en") :normal) "2025-01-15T10:20:00" "2025-01-15T10:00:00") "in 20 minutes")
  ;; 12.3
  (check-equal "12.3" (format-until (make-formatter (get-locale "en") :normal) "2025-01-15T13:00:00" "2025-01-15T10:00:00") "in 3 hours")
)

;; Section 13: Locale — German
(defun test-section-13 ()
  ;; 13.1
  (check-equal "13.1" (format-duration (make-formatter (get-locale "de") :normal) 3600) "1 Stunde")
  ;; 13.2
  (check-equal "13.2" (format-since (make-formatter (get-locale "de") :normal) "2025-01-15T10:00:00" "2025-01-15T10:05:00") "vor 5 Minuten")
)

;; Section 14: Locale — French
(defun test-section-14 ()
  ;; 14.1
  (check-equal "14.1" (format-duration (make-formatter (get-locale "fr") :normal) 7200) "2 heures")
)

;; Section 15: Locale — Japanese
(defun test-section-15 ()
  ;; 15.1
  (check-equal "15.1" (format-duration (make-formatter (get-locale "ja") :normal) 120) "2分")
  ;; 15.2
  (check-equal "15.2" (format-since (make-formatter (get-locale "ja") :normal) "2025-01-15T10:00:00" "2025-01-15T11:00:00") "1時間前")
)

;; Section 16: Short compactness — duration
(defun test-section-16 ()
  ;; 16.1
  (check-equal "16.1" (format-duration (make-formatter (get-locale "en") :short) 3600) "1h")
  ;; 16.2
  (check-equal "16.2" (format-duration (make-formatter (get-locale "en") :short) 90) "1m, 30s")
)

;; Section 17: Compact compactness — duration
(defun test-section-17 ()
  ;; 17.1
  (check-equal "17.1" (format-duration (make-formatter (get-locale "en") :compact) 3600) "1h")
  ;; 17.2
  (check-equal "17.2" (format-duration (make-formatter (get-locale "en") :compact) 90) "1m30s")
)

;; Section 18: Short compactness — relative time
(defun test-section-18 ()
  ;; 18.1
  (check-equal "18.1" (format-since (make-formatter (get-locale "men") :normal) "2025-01-20T01:32:11" "2025-01-22T15:39:16") "lɔhɔnga 2, awa 14 taa gbɔyɔ")
)

;; Section 19: Range (500-year ceiling)
(defun test-section-19 ()
  ;; 19.1
  (check-equal "19.1" (format-duration (make-formatter (get-locale "en") :normal) 15778800000) "500 years")
  ;; 19.2
  (check-nil "19.2" (format-duration (make-formatter (get-locale "en") :normal) 15800000000))
  ;; 19.3
  (check-nil "19.3" (format-duration (make-formatter (get-locale "en") :normal) 99999999999))
  ;; 19.4
  (check-nil "19.4" (format-since (make-formatter (get-locale "en") :normal) "1500-01-01T00:00:00" "2025-01-01T00:00:00"))
  ;; 19.5
  (check-nil "19.5" (format-until (make-formatter (get-locale "en") :normal) "2600-01-01T00:00:00" "2025-01-01T00:00:00"))
)

;; Section 20: Timestamp validation
(defun test-section-20 ()
  ;; 20.1
  (check-equal "20.1" (format-duration (make-formatter (get-locale "en") :normal) "2025-01-15T10:00" "2025-01-15T11:30:00") "1½ hours")
  ;; 20.2
  (check-nil "20.2" (format-duration (make-formatter (get-locale "en") :normal) "2025-01-15T10" "2025-01-15T11:30:00"))
  ;; 20.3
  (check-nil "20.3" (format-duration (make-formatter (get-locale "en") :normal) "2025-1-5T10:00:00" "2025-01-15T11:30:00"))
  ;; 20.4
  (check-nil "20.4" (format-duration (make-formatter (get-locale "en") :normal) "2025-02-30T10:00:00" "2025-03-15T11:30:00"))
  ;; 20.5
  (check-nil "20.5" (format-since (make-formatter (get-locale "en") :normal) "2025-01-15T10:00:00" "2025-01-15T25:00:00"))
)

(defun run-tests ()
  (setf *pass-count* 0)
  (setf *fail-count* 0)
  (format t "~%Running sayable-duration tests...~%~%")
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
  (test-section-15)
  (test-section-16)
  (test-section-17)
  (test-section-18)
  (test-section-19)
  (test-section-20)

  (format t "~%Results: ~a passed, ~a failed~%" *pass-count* *fail-count*)
  (when (> *fail-count* 0)
    (sb-ext:exit :code 1)))

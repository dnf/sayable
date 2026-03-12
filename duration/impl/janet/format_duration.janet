# Human-friendly duration and relative time formatting.

(def version "0.5.0")

(defn- string-replace-all [s pattern replacement]
  (var result s)
  (var idx (string/find pattern result))
  (while idx
    (set result (string (string/slice result 0 idx) replacement
                        (string/slice result (+ idx (length pattern)))))
    (set idx (string/find pattern result)))
  result)

(defn- resolve-unit [count unit-forms loc &opt half]
  (default half "")
  (def base-n (string count))
  (def n
    (if (and (not= half "") (string/find "{n}" half))
      (string-replace-all half "{n}" base-n)
      base-n))
  (def template
    (if (string? unit-forms)
      unit-forms
      (let [category (if (not= half "")
                       :other
                       ((loc :plural) count))]
        (or (get unit-forms category)
            (get unit-forms :other)))))
  (var result (string-replace-all template "{n}" n))
  (if (and (not= half "") (string/find "{0}" half))
    (string-replace-all half "{0}" result)
    result))

(defn- is-leap-year [y]
  (or (and (= (% y 4) 0) (not= (% y 100) 0))
      (= (% y 400) 0)))

(defn- days-in-month [y m]
  (case m
    2 (if (is-leap-year y) 29 28)
    4 30  6 30  9 30  11 30
    31))

(defn- days-since-epoch [y m d]
  (var days 0)
  (if (>= y 2000)
    (for i 2000 y
      (+= days (if (is-leap-year i) 366 365)))
    (for i y 2000
      (-= days (if (is-leap-year i) 366 365))))
  (for i 1 m
    (+= days (days-in-month y i)))
  (+ days d -1))

(defn- parse-iso-to-seconds [s]
  (when (and s (not= s ""))
    (def parts (string/split "T" s))
    (when (= (length parts) 2)
      (def dp (string/split "-" (in parts 0)))
      (when (= (length dp) 3)
        (def year (scan-number (in dp 0)))
        (def month (scan-number (in dp 1)))
        (def day (scan-number (in dp 2)))
        (var time-str (in parts 1))
        (when (string/find "+" time-str)
          (set time-str (first (string/split "+" time-str))))
        (when (string/find "Z" time-str)
          (set time-str (first (string/split "Z" time-str))))
        (def tp (string/split ":" time-str))
        (def hour (scan-number (in tp 0)))
        (def minute (if (>= (length tp) 2) (scan-number (in tp 1)) 0))
        (def sec-str (if (>= (length tp) 3)
                       (first (string/split "." (in tp 2)))
                       "0"))
        (def second (scan-number sec-str))
        (when (and year month day hour minute second)
          (def days (days-since-epoch year month day))
          (+ (* days 86400) (* hour 3600) (* minute 60) second))))))

(defn- pick [override attr default]
  (if override
    (let [val (get override attr)]
      (if (not= val nil) val default))
    default))

(defn- format-duration-seconds [total units half delimiter just-now loc]
  # 0 seconds
  (when (= total 0)
    (break just-now))

  # 1-59 seconds
  (when (< total 60)
    (break (resolve-unit total (units :second) loc)))

  (def total-minutes (math/floor (/ total 60)))
  (def remainder-seconds (% total 60))

  # 1-4 minutes: minutes + seconds
  (when (< total-minutes 5)
    (var result (resolve-unit total-minutes (units :minute) loc))
    (when (> remainder-seconds 0)
      (set result (string result delimiter
                          (resolve-unit remainder-seconds (units :second) loc))))
    (break result))

  # 5-59 minutes
  (when (< total-minutes 60)
    (break (resolve-unit total-minutes (units :minute) loc)))

  (def total-hours (math/floor (/ total 3600)))
  (def remainder-minutes (math/floor (/ (% total 3600) 60)))

  # 1-5 hours: hours + minutes (with half marker)
  (when (<= total-hours 5)
    (if (= remainder-minutes 30)
      (break (resolve-unit total-hours (units :hour) loc half))
      (do
        (var result (resolve-unit total-hours (units :hour) loc))
        (when (> remainder-minutes 0)
          (set result (string result delimiter
                              (resolve-unit remainder-minutes (units :minute) loc))))
        (break result))))

  # 6-23 hours
  (when (< total-hours 24)
    (break (resolve-unit total-hours (units :hour) loc)))

  (def total-days (math/floor (/ total 86400)))
  (def remainder-hours (math/floor (/ (% total 86400) 3600)))

  # 1-2 days: days + hours (with half marker)
  (when (<= total-days 2)
    (if (= remainder-hours 12)
      (break (resolve-unit total-days (units :day) loc half))
      (do
        (var result (resolve-unit total-days (units :day) loc))
        (when (> remainder-hours 0)
          (set result (string result delimiter
                              (resolve-unit remainder-hours (units :hour) loc))))
        (break result))))

  # 3-6 days
  (when (< total-days 7)
    (break (resolve-unit total-days (units :day) loc)))

  (def total-weeks (math/floor (/ total-days 7)))
  (def remainder-days (% total-days 7))

  # 1-4 weeks (up to 29 days)
  (when (< total-days 30)
    (var result (resolve-unit total-weeks (units :week) loc))
    (when (> remainder-days 0)
      (set result (string result delimiter
                          (resolve-unit remainder-days (units :day) loc))))
    (break result))

  # Approximate months
  (var total-months (math/round (/ total-days 30.44)))

  # 1-11 months
  (when (< total-months 12)
    (when (= total-months 0)
      (set total-months 1))
    (break (resolve-unit total-months (units :month) loc)))

  # 12+ months: years + months
  (def total-years (math/floor (/ total-months 12)))
  (def remainder-months (% total-months 12))
  (var result (resolve-unit total-years (units :year) loc))
  (when (> remainder-months 0)
    (set result (string result delimiter
                        (resolve-unit remainder-months (units :month) loc))))
  result)

(defn make-formatter [loc &opt compactness]
  (default compactness "normal")
  (def ovr
    (case compactness
      "short" (get loc :short)
      "compact" (get loc :compact)
      nil))
  (def ovr-units (if ovr (get ovr :units)))
  (def units @{})
  (each k [:second :minute :hour :day :week :month :year]
    (put units k
         (if (and ovr-units (get ovr-units k))
           (get ovr-units k)
           (get (loc :units) k))))
  (def half (pick ovr :half (loc :half)))
  (def delimiter (pick ovr :delimiter (loc :delimiter)))
  (def just-now (loc :just-now))
  (def ago (pick ovr :ago (loc :ago)))
  (def in-future (pick ovr :in-future (loc :in-future)))

  {:format-duration
   (fn [start-or-seconds &opt end]
     (when (nil? start-or-seconds) (break nil))
     (var total-seconds nil)
     (if (number? start-or-seconds)
       (do
         (when (< start-or-seconds 0) (break nil))
         (set total-seconds start-or-seconds))
       (if (string? start-or-seconds)
         (do
           (when (nil? end) (break nil))
           (def s (parse-iso-to-seconds start-or-seconds))
           (def e (parse-iso-to-seconds end))
           (when (or (nil? s) (nil? e)) (break nil))
           (set total-seconds (math/abs (- e s))))
         (break nil)))
     (format-duration-seconds total-seconds units half delimiter just-now loc))

   :format-since
   (fn [start as-of]
     (when (or (nil? start) (= start "") (nil? as-of) (= as-of ""))
       (break nil))
     (def s (parse-iso-to-seconds start))
     (def a (parse-iso-to-seconds as-of))
     (when (or (nil? s) (nil? a)) (break nil))
     (def diff (- a s))
     (when (< diff 0) (break nil))
     (when (= diff 0) (break just-now))
     (def dur (format-duration-seconds diff units half delimiter just-now loc))
     (string-replace-all ago "{0}" dur))

   :format-until
   (fn [target as-of]
     (when (or (nil? target) (= target "") (nil? as-of) (= as-of ""))
       (break nil))
     (def t (parse-iso-to-seconds target))
     (def a (parse-iso-to-seconds as-of))
     (when (or (nil? t) (nil? a)) (break nil))
     (def diff (- t a))
     (when (< diff 0) (break nil))
     (when (= diff 0) (break just-now))
     (def dur (format-duration-seconds diff units half delimiter just-now loc))
     (string-replace-all in-future "{0}" dur))})

# Default English locale
(import ./locales/en :prefix "en-")
(def- default-en en-locale)
(def- default-formatter (make-formatter default-en))

(defn format-duration [start-or-seconds &opt end]
  ((default-formatter :format-duration) start-or-seconds end))

(defn format-since [start as-of]
  ((default-formatter :format-since) start as-of))

(defn format-until [target as-of]
  ((default-formatter :format-until) target as-of))

(import ./locales/registry :as reg)

(defn get-locale [code]
  (reg/get-locale code))

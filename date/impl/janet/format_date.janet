# Human-friendly date formatting.

(def version "0.5.0")

(defn- leap-year? [y]
  (or (and (= (% y 4) 0) (not= (% y 100) 0))
      (= (% y 400) 0)))

(defn- days-in-month [y m]
  (cond
    (= m 2) (if (leap-year? y) 29 28)
    (index-of m [4 6 9 11]) 30
    31))

(defn- real-date? [y m d]
  (and (<= 1 m 12) (<= 1 d (days-in-month y m))))

# YYYY-MM-DD, alone or followed by T and the rest of an ISO datetime.
(def- date-grammar
  (peg/compile
    '(* (capture (4 :d)) "-" (capture (2 :d)) "-" (capture (2 :d))
        (+ -1 "T"))))

(defn- parse-date [s]
  (when-let [parts (and (string? s) (peg/match date-grammar s))
             ymd (map scan-number parts)]
    (when (real-date? ;ymd) ymd)))

(defn- to-jdn [y m d]
  (def a (math/floor (/ (- 14 m) 12)))
  (def yy (+ y 4800 (- a)))
  (def mm (+ m (* 12 a) -3))
  (+ d
     (math/floor (/ (+ (* 153 mm) 2) 5))
     (* 365 yy)
     (math/floor (/ yy 4))
     (- (math/floor (/ yy 100)))
     (math/floor (/ yy 400))
     -32045))

(defn- weekday [y m d]
  (% (+ (to-jdn y m d) 1) 7))

(defn- string-replace [s pattern replacement]
  (def idx (string/find pattern s))
  (if idx
    (string (string/slice s 0 idx) replacement
            (string/slice s (+ idx (length pattern))))
    s))

(defn- string-replace-all [s pattern replacement]
  (var result s)
  (var idx (string/find pattern result))
  (while idx
    (set result (string (string/slice result 0 idx) replacement
                        (string/slice result (+ idx (length pattern)))))
    (set idx (string/find pattern result)))
  result)

(defn- pick [override attr fallback]
  (if override
    (let [val (get override attr)]
      (if (not= val nil) val fallback))
    fallback))

(defn- format-absolute [year month day include-year loc months weekdays
                        day-format day-format-exceptions date-pattern
                        date-pattern-with-year months-in-date]
  (def day-str (string day))
  (def fmt
    (if (and day-format-exceptions (get day-format-exceptions day-str))
      (get day-format-exceptions day-str)
      day-format))
  (def formatted-day (string-replace-all fmt "{n}" day-str))
  (def month-names (if months-in-date months-in-date months))
  (def month-name (in month-names (- month 1)))
  (def pattern (if include-year date-pattern-with-year date-pattern))
  (var result (string-replace-all pattern "{month}" month-name))
  (set result (string-replace-all result "{day}" formatted-day))
  (set result (string-replace-all result "{d}" (string day)))
  (set result (string-replace-all result "{m}" (string month)))
  (when include-year
    (set result (string-replace-all result "{year}" (string year)))
    (def yy (% year 100))
    (def yy-str (if (< yy 10) (string "0" yy) (string yy)))
    (set result (string-replace-all result "{yy}" yy-str)))
  result)

(defn make-formatter [loc &opt compactness]
  (default compactness "normal")
  (def ovr
    (case compactness
      "short" (get loc :short)
      "compact" (get loc :compact)
      nil))
  (def months (pick ovr :months (loc :months)))
  (def months-in-date (pick ovr :months-in-date (get loc :months-in-date)))
  (def weekdays (pick ovr :weekdays (loc :weekdays)))
  (def day-format (pick ovr :day-format (loc :day-format)))
  # When short overrides day-format but not exceptions, clear exceptions
  (def day-format-exceptions
    (if (and ovr (get ovr :day-format) (nil? (get ovr :day-format-exceptions)))
      {}
      (pick ovr :day-format-exceptions (loc :day-format-exceptions))))
  (def date-pattern (pick ovr :date-pattern (loc :date-pattern)))
  (def date-pattern-with-year (pick ovr :date-pattern-with-year (loc :date-pattern-with-year)))
  (def today (pick ovr :today (loc :today)))
  (def tomorrow (pick ovr :tomorrow (loc :tomorrow)))
  (def yesterday (pick ovr :yesterday (loc :yesterday)))

  {:format-date
   (fn [date]
     (when (or (nil? date) (= date ""))
       (break nil))
     (def parsed (parse-date date))
     (unless parsed (break nil))
     (def [y m d] parsed)
     (format-absolute y m d false loc months weekdays
                      day-format day-format-exceptions date-pattern
                      date-pattern-with-year months-in-date))

   :format-date-with-year
   (fn [date]
     (when (or (nil? date) (= date ""))
       (break nil))
     (def parsed (parse-date date))
     (unless parsed (break nil))
     (def [y m d] parsed)
     (format-absolute y m d true loc months weekdays
                      day-format day-format-exceptions date-pattern
                      date-pattern-with-year months-in-date))

   :format-relative
   (fn [date as-of]
     (when (or (nil? date) (= date "") (nil? as-of) (= as-of ""))
       (break nil))
     (def parsed-date (parse-date date))
     (def parsed-as-of (parse-date as-of))
     (unless (and parsed-date parsed-as-of) (break nil))
     (def [dy dm dd] parsed-date)
     (def [ay am ad] parsed-as-of)
     (def date-jdn (to-jdn dy dm dd))
     (def asof-jdn (to-jdn ay am ad))
     (def diff (- date-jdn asof-jdn))

     # Today
     (when (= diff 0) (break today))

     # Tomorrow
     (when (= diff 1) (break tomorrow))

     # Yesterday
     (when (= diff -1) (break yesterday))

     (def is-compact (= compactness "compact"))

     # Day after tomorrow
     (when (and (= diff 2) (get loc :day-after-tomorrow) (not is-compact))
       (break (get loc :day-after-tomorrow)))

     # Day before yesterday
     (when (and (= diff -2) (get loc :day-before-yesterday) (not is-compact))
       (break (get loc :day-before-yesterday)))

     # Compact: skip weekday references
     (when is-compact
       (def include-year (not= dy ay))
       (break (format-absolute dy dm dd include-year loc months weekdays
                               day-format day-format-exceptions date-pattern
                               date-pattern-with-year months-in-date)))

     # This weekday (+2 to +6)
     (when (and (>= diff 2) (<= diff 6) (get loc :this-weekday))
       (def dow (weekday dy dm dd))
       (def weekday-name (in weekdays dow))
       (break (string-replace-all (get loc :this-weekday) "{weekday}" weekday-name)))

     # Last weekday (-2 to -6)
     (when (and (>= diff -6) (<= diff -2) (get loc :last-weekday))
       (def dow (weekday dy dm dd))
       (def weekday-name (in weekdays dow))
       (break (string-replace-all (get loc :last-weekday) "{weekday}" weekday-name)))

     # Next weekday (+7 to +13)
     (when (and (>= diff 7) (<= diff 13) (get loc :next-weekday))
       (def dow (weekday dy dm dd))
       (def weekday-name (in weekdays dow))
       (break (string-replace-all (get loc :next-weekday) "{weekday}" weekday-name)))

     # Calendar fallback
     (def include-year (not= dy ay))
     (format-absolute dy dm dd include-year loc months weekdays
                      day-format day-format-exceptions date-pattern
                      date-pattern-with-year months-in-date))})

# Default English locale
(import ./locales/en :prefix "en-")
(def- default-en en-locale)
(def- default-formatter (make-formatter default-en))

(defn format-date [date]
  ((default-formatter :format-date) date))

(defn format-date-with-year [date]
  ((default-formatter :format-date-with-year) date))

(defn format-relative [date as-of]
  ((default-formatter :format-relative) date as-of))

(import ./locales/registry :as reg)

(defn get-locale [code]
  (reg/get-locale code))

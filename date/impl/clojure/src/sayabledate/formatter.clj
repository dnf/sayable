(ns sayabledate.formatter
  (:require [clojure.string :as str]))

(def version "0.1.0")

(defn- all-digits? [^String s]
  (every? #(Character/isDigit ^char %) s))

(defn- safe-atoi [^String s]
  (when (and (seq s) (all-digits? s))
    (Integer/parseInt s)))

(defn- parse-date [^String s]
  (when (seq s)
    (let [date-part (if (str/includes? s "T") (first (str/split s #"T")) s)
          parts (str/split date-part #"-")]
      (when (== (count parts) 3)
        (when-let [year (safe-atoi (nth parts 0))]
          (when-let [month (safe-atoi (nth parts 1))]
            (when-let [day (safe-atoi (nth parts 2))]
              (when (and (>= month 1) (<= month 12) (>= day 1) (<= day 31))
                [year month day]))))))))

(defn- to-jdn [year month day]
  (let [a (quot (- 14 month) 12)
        y (+ year 4800 (- a))
        m (+ month (* 12 a) -3)]
    (+ day (quot (+ (* 153 m) 2) 5) (* 365 y) (quot y 4)
       (- (quot y 100)) (quot y 400) -32045)))

(defn- weekday [year month day]
  (mod (+ (to-jdn year month day) 1) 7))

(defn- ovr-or [ovr-val default]
  (if (some? ovr-val) ovr-val default))

(defn- resolve-locale [locale compactness]
  (let [ovr (case compactness
              :normal nil
              :short (:short locale)
              :compact (:compact locale))]
    (if (nil? ovr)
      {:months (:months locale)
       :months-in-date (:months-in-date locale)
       :weekdays (:weekdays locale)
       :day-format (:day-format locale)
       :day-format-exceptions (:day-format-exceptions locale)
       :date-pattern (:date-pattern locale)
       :date-pattern-with-year (:date-pattern-with-year locale)
       :today (:today locale)
       :tomorrow (:tomorrow locale)
       :yesterday (:yesterday locale)}
      ;; When override provides dayFormat but not dayFormatExceptions, clear exceptions
      (let [clear-exceptions? (and (:day-format ovr) (nil? (:day-format-exceptions ovr)))]
        {:months (ovr-or (:months ovr) (:months locale))
         :months-in-date (ovr-or (:months-in-date ovr) (:months-in-date locale))
         :weekdays (ovr-or (:weekdays ovr) (:weekdays locale))
         :day-format (ovr-or (:day-format ovr) (:day-format locale))
         :day-format-exceptions (if clear-exceptions?
                                  {}
                                  (ovr-or (:day-format-exceptions ovr) (:day-format-exceptions locale)))
         :date-pattern (ovr-or (:date-pattern ovr) (:date-pattern locale))
         :date-pattern-with-year (ovr-or (:date-pattern-with-year ovr) (:date-pattern-with-year locale))
         :today (ovr-or (:today ovr) (:today locale))
         :tomorrow (ovr-or (:tomorrow ovr) (:tomorrow locale))
         :yesterday (ovr-or (:yesterday ovr) (:yesterday locale))}))))

(defn- format-absolute [resolved year month day include-year?]
  (let [{:keys [months months-in-date day-format day-format-exceptions date-pattern date-pattern-with-year]} resolved
        day-str (str day)
        fmt (or (get day-format-exceptions day-str) day-format)
        formatted-day (str/replace fmt "{n}" day-str)
        month-name (nth (or months-in-date months) (dec month))
        pattern (if include-year? date-pattern-with-year date-pattern)]
    (cond-> (-> pattern
                (str/replace "{month}" month-name)
                (str/replace "{day}" formatted-day)
                (str/replace "{d}" (str day))
                (str/replace "{m}" (str month)))
      include-year? (-> (str/replace "{year}" (str year))
                        (str/replace "{yy}" (format "%02d" (mod year 100)))))))

(defn format-date [locale compactness date]
  (when (seq date)
    (when-let [[y m d] (parse-date date)]
      (let [resolved (resolve-locale locale compactness)]
        (format-absolute resolved y m d false)))))

(defn format-date-with-year [locale compactness date]
  (when (seq date)
    (when-let [[y m d] (parse-date date)]
      (let [resolved (resolve-locale locale compactness)]
        (format-absolute resolved y m d true)))))

(defn format-relative [locale compactness date as-of]
  (when (and (seq date) (seq as-of))
    (when-let [[dy dm dd] (parse-date date)]
      (when-let [[ay am ad] (parse-date as-of)]
        (let [resolved (resolve-locale locale compactness)
              date-jdn (to-jdn dy dm dd)
              asof-jdn (to-jdn ay am ad)
              diff (- date-jdn asof-jdn)]
          (cond
            (== diff 0) (:today resolved)
            (== diff 1) (:tomorrow resolved)
            (== diff -1) (:yesterday resolved)

            ;; Day after tomorrow (optional, skipped in compact mode)
            (and (== diff 2) (:day-after-tomorrow locale) (not= compactness :compact))
            (:day-after-tomorrow locale)

            ;; Day before yesterday (optional, skipped in compact mode)
            (and (== diff -2) (:day-before-yesterday locale) (not= compactness :compact))
            (:day-before-yesterday locale)

            ;; Compact mode: skip weekday references, go straight to calendar date
            (= compactness :compact)
            (format-absolute resolved dy dm dd (not= dy ay))

            ;; This weekday (+2 to +6)
            (and (<= 2 diff 6) (:this-weekday locale))
            (let [dow (weekday dy dm dd)
                  wd-name (nth (:weekdays resolved) dow)]
              (str/replace (:this-weekday locale) "{weekday}" wd-name))

            ;; Last weekday (-6 to -2)
            (and (<= -6 diff -2) (:last-weekday locale))
            (let [dow (weekday dy dm dd)
                  wd-name (nth (:weekdays resolved) dow)]
              (str/replace (:last-weekday locale) "{weekday}" wd-name))

            ;; Next weekday (+7 to +13)
            (and (<= 7 diff 13) (:next-weekday locale))
            (let [dow (weekday dy dm dd)
                  wd-name (nth (:weekdays resolved) dow)]
              (str/replace (:next-weekday locale) "{weekday}" wd-name))

            ;; Calendar fallback
            :else
            (format-absolute resolved dy dm dd (not= dy ay))))))))

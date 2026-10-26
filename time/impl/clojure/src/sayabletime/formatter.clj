(ns sayabletime.formatter
  (:require [clojure.string :as str]))

(def version "0.5.0")

(defn- round-to-5 [minute]
  (* (quot (+ minute 2) 5) 5))

(def ^:private clock-pattern
  "H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored)."
  #"([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?")

(def ^:private date-pattern #"([0-9]{4})-([0-9]{2})-([0-9]{2})")

(defn- days-in-month [y m]
  (case (int m)
    2 (if (or (and (zero? (mod y 4)) (not (zero? (mod y 100)))) (zero? (mod y 400))) 29 28)
    (4 6 9 11) 30
    31))

(defn- real-date? [s]
  (if-let [[_ y m d] (re-matches date-pattern s)]
    (let [year (Integer/parseInt y)
          month (Integer/parseInt m)
          day (Integer/parseInt d)]
      (and (<= 1 month 12) (<= 1 day (days-in-month year month))))
    false))

(defn- parse-time
  "Parses a clock time, alone or after the T of an ISO datetime, into [hour minute]."
  [input]
  (when (string? input)
    (let [t-idx (.indexOf ^String input (int \T))
          clock (if (>= t-idx 0) (subs input (inc t-idx)) input)]
      (when (or (neg? t-idx) (real-date? (subs input 0 t-idx)))
        (when-let [[_ h m sec] (re-matches clock-pattern clock)]
          (let [hour (Integer/parseInt h)
                minute (Integer/parseInt m)
                second (if sec (Integer/parseInt sec) 0)]
            (when (and (<= hour 23) (<= minute 59) (<= second 59))
              [hour minute])))))))

(defn- resolve-locale [locale compactness]
  (let [ovr (case compactness
              :normal nil
              :short (:short locale)
              :compact (:compact locale))]
    (when ovr (:clock ovr))))

(defn- format-natural [hour minute locale]
  (let [clock (:clock locale)
        rounded (round-to-5 minute)
        [rounded h] (if (== rounded 60) [0 (mod (inc hour) 24)] [rounded hour])]
    (if (== rounded 0)
      (cond
        (== h 0) (:midnight clock)
        (== h 12) (:noon clock)
        :else (let [h12 (mod h 12)
                    h-name (nth (:hours clock) h12)
                    pattern (or (get (:patterns clock) 0) "{h}")]
                (str/replace pattern "{h}" h-name)))
      (let [h12 (mod h 12)
            next-h12 (mod (inc h) 12)
            h-name (nth (:hours clock) h12)
            next-h-name (nth (:hours clock) next-h12)
            pattern (or (get (:patterns clock) rounded)
                        (get (:patterns clock) 0)
                        "{h}")]
        (-> pattern
            (str/replace "{h}" h-name)
            (str/replace "{next_h}" next-h-name))))))

(defn- format-digital [hour minute short-clock]
  (let [fmt (:format short-clock)]
    (if (:use-24h short-clock)
      (-> fmt
          (str/replace "{h}" (str hour))
          (str/replace "{mm}" (format "%02d" minute)))
      (let [h12 (let [h (mod hour 12)] (if (== h 0) 12 h))
            am-pm (:am-pm short-clock)
            [am pm] (if am-pm [(nth am-pm 0) (nth am-pm 1)] ["AM" "PM"])
            ampm-str (if (< hour 12) am pm)]
        (-> fmt
            (str/replace "{h}" (str h12))
            (str/replace "{mm}" (format "%02d" minute))
            (str/replace "{ampm}" ampm-str))))))

(defn format-time [locale compactness input]
  (when (seq input)
    (when-let [[hour minute] (parse-time input)]
      (let [short-clock (resolve-locale locale compactness)]
        (if short-clock
          (format-digital hour minute short-clock)
          (format-natural hour minute locale))))))

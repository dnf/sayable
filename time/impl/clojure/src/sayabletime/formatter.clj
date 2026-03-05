(ns sayabletime.formatter
  (:require [clojure.string :as str]))

(def version "0.1.0")

(defn- round-to-5 [minute]
  (* (quot (+ minute 2) 5) 5))

(defn- parse-time [^String input]
  (when (seq input)
    (let [;; Strip date part if ISO datetime
          t (let [t-idx (.indexOf input (int \T))]
              (if (>= t-idx 0) (subs input (inc t-idx)) input))
          ;; Strip timezone
          t (let [plus-idx (.indexOf ^String t (int \+))]
              (if (>= plus-idx 0) (subs t 0 plus-idx) t))
          t (let [z-idx (.indexOf ^String t (int \Z))]
              (if (>= z-idx 0) (subs t 0 z-idx) t))
          parts (str/split t #":")]
      (when (>= (count parts) 2)
        (try
          (let [hour (Integer/parseInt (nth parts 0))
                minute (Integer/parseInt (nth parts 1))]
            (when (and (>= hour 0) (<= hour 23) (>= minute 0) (<= minute 59))
              [hour minute]))
          (catch NumberFormatException _ nil))))))

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

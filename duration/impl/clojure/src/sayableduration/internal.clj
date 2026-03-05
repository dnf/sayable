(ns sayableduration.internal
  (:require [clojure.string :as str]))

(defn- all-digits? [^String s]
  (every? #(Character/isDigit ^char %) s))

(defn- safe-atoi [^String s]
  (when (and (seq s) (all-digits? s))
    (Integer/parseInt s)))

(defn- leap-year? [y]
  (or (and (== (mod y 4) 0) (not= (mod y 100) 0))
      (== (mod y 400) 0)))

(defn- days-in-month [y m]
  (case (int m)
    (1 3 5 7 8 10 12) 31
    (4 6 9 11) 30
    2 (if (leap-year? y) 29 28)
    30))

(defn- days-since-epoch [year month day]
  (let [days (atom 0)]
    (if (>= year 2000)
      (doseq [y (range 2000 year)]
        (swap! days + (if (leap-year? y) 366 365)))
      (doseq [y (range year 2000)]
        (swap! days - (if (leap-year? y) 366 365))))
    (doseq [m (range 1 month)]
      (swap! days + (days-in-month year m)))
    (+ @days day -1)))

(defn parse-iso-to-seconds [^String iso]
  (when (and (string? iso) (seq iso))
    (let [t-idx (.indexOf iso (int \T))]
      (when (>= t-idx 0)
        (let [date-part (subs iso 0 t-idx)
              time-part (subs iso (inc t-idx))
              dp (str/split date-part #"-")]
          (when (>= (count dp) 3)
            (when-let [year (safe-atoi (nth dp 0))]
              (when-let [month (safe-atoi (nth dp 1))]
                (when-let [day (safe-atoi (nth dp 2))]
                  (let [;; Strip timezone
                        tp (-> time-part
                                (str/split #"\+" 2)
                                first
                                (str/split #"Z" 2)
                                first)
                        parts (str/split tp #":")]
                    (when-let [hour (safe-atoi (first parts))]
                      (let [minute (if (> (count parts) 1) (safe-atoi (nth parts 1)) 0)
                            second (if (> (count parts) 2)
                                     (safe-atoi (first (str/split (nth parts 2) #"\.")))
                                     0)]
                        (when (and minute second)
                          (let [days (days-since-epoch year month day)]
                            (+ (* days 86400) (* hour 3600) (* minute 60) second)))))))))))))))

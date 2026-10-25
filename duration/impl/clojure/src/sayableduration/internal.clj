(ns sayableduration.internal)

(def ^:private timestamp-pattern
  "YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored)."
  #"([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?")

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

(defn parse-iso-to-seconds
  "Parses an ISO timestamp to epoch-relative seconds for diffing, else nil."
  [iso]
  (when-let [[_ & fields] (and (string? iso) (re-matches timestamp-pattern iso))]
    (let [[year month day hour minute second] (map #(if % (Long/parseLong %) 0) fields)]
      (when (and (<= 1 month 12) (<= 1 day (days-in-month year month))
                 (<= hour 23) (<= minute 59) (<= second 59))
        (+ (* (days-since-epoch year month day) 86400) (* hour 3600) (* minute 60) second)))))

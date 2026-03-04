(ns sayableage.internal)

(defn- all-digits? [^String s]
  (every? #(Character/isDigit ^char %) s))

(defn parse-date [^String s]
  (when (and (string? s)
             (>= (count s) 10)
             (= \- (.charAt s 4))
             (= \- (.charAt s 7)))
    (let [y-str (subs s 0 4)
          m-str (subs s 5 7)
          d-str (subs s 8 10)]
      (when (and (all-digits? y-str) (all-digits? m-str) (all-digits? d-str))
        (let [y (Integer/parseInt y-str)
              m (Integer/parseInt m-str)
              d (Integer/parseInt d-str)]
          (when-not (and (== y 0) (== m 0) (== d 0))
            [y m d]))))))

(defn leap-year? [y]
  (or (and (== (mod y 4) 0) (not= (mod y 100) 0))
      (== (mod y 400) 0)))

(defn days-in-month [y m]
  (case (int m)
    (1 3 5 7 8 10 12) 31
    (4 6 9 11) 30
    2 (if (leap-year? y) 29 28)
    30))

(defn- to-jdn [y m d]
  (let [a (quot (- 14 m) 12)
        yy (+ y 4800 (- a))
        mm (+ m (* 12 a) -3)]
    (+ d (quot (+ (* 153 mm) 2) 5) (* 365 yy) (quot yy 4)
       (- (quot yy 100)) (quot yy 400) -32045)))

(defn days-between [[y1 m1 d1] [y2 m2 d2]]
  (- (to-jdn y2 m2 d2) (to-jdn y1 m1 d1)))

(defn compute-age [dob as-of]
  (when-let [[dy dm dd] (parse-date dob)]
    (when-let [[ry rm rd] (parse-date as-of)]
      (let [diff-days (days-between [dy dm dd] [ry rm rd])]
        (when (>= diff-days 0)
          (let [last-day (days-in-month ry rm)
                clamped-birthday (min dd last-day)
                months0 (+ (* (- ry dy) 12) (- rm dm))
                months (if (< rd clamped-birthday) (dec months0) months0)]
            (when (<= months 6000)
              {:months months :diff-days diff-days})))))))

(defn today []
  (let [ld (java.time.LocalDate/now)]
    [(.getYear ld) (.getMonthValue ld) (.getDayOfMonth ld)]))

(defn format-date [[y m d]]
  (format "%04d-%02d-%02d" y m d))

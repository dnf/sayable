# Human-friendly clock time formatting.

(def version "0.5.0")

(defn- leap-year? [y]
  (or (and (= (% y 4) 0) (not= (% y 100) 0))
      (= (% y 400) 0)))

(defn- days-in-month [y m]
  (cond
    (= m 2) (if (leap-year? y) 29 28)
    (index-of m [4 6 9 11]) 30
    31))

(defn- real-date? [[y m d]]
  (and (<= 1 m 12) (<= 1 d (days-in-month y m))))

# A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
# suffix, which is ignored), alone or after the T of an ISO datetime.
(def- time-grammar
  (peg/compile
    ~{:date (group (* (number (4 :d)) "-" (number (2 :d)) "-" (number (2 :d))))
      :clock (group (* (number (between 1 2 :d)) ":" (number (2 :d))
                       (? (* ":" (number (2 :d)) (? (* "." (some :d)))))
                       (? (+ "Z" (* (set "+-") (2 :d) ":" (2 :d))))))
      :main (* (+ (* :date "T") (constant nil)) :clock -1)}))

(defn- parse-time [s]
  (when-let [parts (and (string? s) (peg/match time-grammar s))
             [date-part [hour minute second]] parts]
    (when (and (or (nil? date-part) (real-date? date-part))
               (<= hour 23) (<= minute 59) (<= (or second 0) 59))
      [hour minute])))

(defn- round-to-5 [minute]
  (* (math/floor (/ (+ minute 2) 5)) 5))

(defn- string-replace-all [s pattern replacement]
  (var result s)
  (var idx (string/find pattern result))
  (while idx
    (set result (string (string/slice result 0 idx) replacement
                        (string/slice result (+ idx (length pattern)))))
    (set idx (string/find pattern result)))
  result)

(defn make-formatter [loc &opt compactness]
  (default compactness "normal")
  (def ovr
    (case compactness
      "short" (get loc :short)
      "compact" (get loc :compact)
      nil))
  (def short-clock (if ovr (get ovr :clock)))

  {:format-time
   (fn [input]
     (when (or (nil? input) (= input ""))
       (break nil))
     (def parsed (parse-time input))
     (unless parsed (break nil))
     (def [hour minute] parsed)

     (if (and (not= compactness "normal") short-clock)
       # Digital format
       (do
         (def fmt (short-clock :format))
         (def use24h (short-clock :use24h))
         (if use24h
           (string-replace-all
             (string-replace-all fmt "{h}" (string hour))
             "{mm}" (if (< minute 10) (string "0" minute) (string minute)))
           (do
             (var h12 (% hour 12))
             (when (= h12 0) (set h12 12))
             (def am-pm (or (short-clock :am-pm) ["AM" "PM"]))
             (def ampm-str (if (< hour 12) (in am-pm 0) (in am-pm 1)))
             (string-replace-all
               (string-replace-all
                 (string-replace-all fmt "{h}" (string h12))
                 "{mm}" (if (< minute 10) (string "0" minute) (string minute)))
               "{ampm}" ampm-str))))

       # Natural language format
       (do
         (def clock (loc :clock))
         (var rounded (round-to-5 minute))
         (var h hour)
         (when (= rounded 60)
           (set rounded 0)
           (set h (% (+ h 1) 24)))
         (when (= rounded 0)
           (when (= h 0) (break (clock :midnight)))
           (when (= h 12) (break (clock :noon))))
         (def h12 (% h 12))
         (def next-h12 (% (+ h 1) 12))
         (def h-name (in (clock :hours) h12))
         (def next-h-name (in (clock :hours) next-h12))
         (def pattern (or (get (clock :patterns) rounded)
                          (get (clock :patterns) 0)
                          "{h}"))
         (string-replace-all
           (string-replace-all pattern "{h}" h-name)
           "{next_h}" next-h-name))))})

# Default English locale
(import ./locales/en :prefix "en-")
(def- default-en en-locale)
(def- default-formatter (make-formatter default-en))

(defn format-time [input]
  ((default-formatter :format-time) input))

(import ./locales/registry :as reg)

(defn get-locale [code]
  (reg/get-locale code))

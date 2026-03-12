# Human-friendly clock time formatting.

(def version "0.5.0")

(defn- parse-time [s]
  (when (and s (not= s ""))
    (var t s)
    (when (string/find "T" t)
      (set t (last (string/split "T" t))))
    (when (string/find "+" t)
      (set t (first (string/split "+" t))))
    (when (string/find "Z" t)
      (set t (first (string/split "Z" t))))
    (def parts (string/split ":" t))
    (when (< (length parts) 2) (break nil))
    (def hour (scan-number (in parts 0)))
    (def min-str (first (string/split "." (in parts 1))))
    (def minute (scan-number min-str))
    (when (or (nil? hour) (nil? minute)) (break nil))
    (when (or (< hour 0) (> hour 23) (< minute 0) (> minute 59))
      (break nil))
    [hour minute]))

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

# Human-friendly age formatting for young children.

(def version "0.5.0")

(def- max-age-months 6000)

(defn- leap-year? [y]
  (or (and (= (% y 4) 0) (not= (% y 100) 0))
      (= (% y 400) 0)))

(defn- days-in-month [y m]
  (def lengths [31 28 31 30 31 30 31 31 30 31 30 31])
  (if (and (= m 2) (leap-year? y))
    29
    (in lengths (- m 1))))

(defn- to-jdn [y m d]
  (var yy y)
  (var mm m)
  (when (<= mm 2)
    (-- yy)
    (+= mm 12))
  (def a (math/floor (/ yy 100)))
  (def b (+ 2 (- a) (math/floor (/ a 4))))
  (+ (math/floor (* 365.25 (+ yy 4716)))
     (math/floor (* 30.6001 (+ mm 1)))
     d b -1524))

(defn- days-between [y1 m1 d1 y2 m2 d2]
  (- (to-jdn y2 m2 d2) (to-jdn y1 m1 d1)))

(def- date-grammar
  (peg/compile
    '(* (capture (4 :d)) "-" (capture (2 :d)) "-" (capture (2 :d)) -1)))

(defn- real-date? [y m d]
  (and (<= 1 m 12) (<= 1 d (days-in-month y m))))

(defn- parse-date [s]
  (when-let [parts (and (string? s) (peg/match date-grammar s))
             ymd (map scan-number parts)]
    (when (real-date? ;ymd) ymd)))

(defn- parse-age [date-of-birth as-of]
  (when (and date-of-birth (not= date-of-birth ""))
    (def dob (parse-date date-of-birth))
    (unless dob (break nil))
    (def [dob-y dob-m dob-d] dob)
    (def ref
      (if (and as-of (not= as-of ""))
        (parse-date as-of)
        (let [t (os/date (os/time) true)]
          [(+ (t :year) 1900) (+ (t :month) 1) (+ (t :month-day) 1)])))
    (unless ref (break nil))
    (def [ref-y ref-m ref-d] ref)
    (def diff-days (days-between dob-y dob-m dob-d ref-y ref-m ref-d))
    (when (< diff-days 0) (break nil))
    (def last-day (days-in-month ref-y ref-m))
    (def clamped-birthday (min dob-d last-day))
    (var months (+ (* (- ref-y dob-y) 12) (- ref-m dob-m)))
    (when (< ref-d clamped-birthday)
      (-- months))
    (when (> months max-age-months) (break nil))
    [months diff-days]))

(defn- stage-key [months]
  (cond
    (< months 2) :newborn
    (< months 12) :infant
    (< months 36) :toddler
    (< months 156) :child
    (< months 216) :teenager
    :adult))

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
      (let [category ((loc :plural) count)]
        (or (get unit-forms category)
            (get unit-forms :other)))))
  (var result (string-replace-all template "{n}" n))
  (if (and (not= half "") (string/find "{0}" half))
    (string-replace-all half "{0}" result)
    result))

(defn- resolve-stage [stage-label gender]
  (if (string? stage-label)
    stage-label
    (if (= gender "f")
      (get stage-label :f)
      (get stage-label :m))))

(defn- pick [override attr fallback]
  (if override
    (let [val (get override attr)]
      (if (not= val nil) val fallback))
    fallback))

(defn make-formatter [loc &opt compactness]
  (default compactness "normal")
  (def ovr
    (case compactness
      "short" (get loc :short)
      "compact" (get loc :compact)
      nil))
  (def ovr-units (if ovr (get ovr :units)))
  (def units @{})
  (each k [:day :week :month :year]
    (put units k
         (if (and ovr-units (get ovr-units k))
           (get ovr-units k)
           (get (loc :units) k))))
  (def half (pick ovr :half (loc :half)))
  (def delimiter (pick ovr :delimiter (loc :delimiter)))
  (def just-born (pick ovr :just-born (loc :just-born)))

  {:format-age
   (fn [date-of-birth &opt as-of]
     (def parsed (parse-age date-of-birth as-of))
     (unless parsed (break nil))
     (def [months diff-days] parsed)

     # Tier 1: 0-6 days
     (when (= diff-days 0) (break just-born))
     (when (< diff-days 7)
       (break (resolve-unit diff-days (units :day) loc)))

     # Tier 2: weeks + days until 3 calendar months
     (when (< months 3)
       (def weeks (math/floor (/ diff-days 7)))
       (def days (% diff-days 7))
       (var result (resolve-unit weeks (units :week) loc))
       (when (> days 0)
         (set result (string result delimiter
                             (resolve-unit days (units :day) loc))))
       (break result))

     # Tier 3: 3-23 months
     (when (< months 24)
       (break (resolve-unit months (units :month) loc)))

     # Tier 4: 24-35 months -> years + months
     (when (< months 36)
       (def years (math/floor (/ months 12)))
       (def rem (% months 12))
       (when (= rem 0)
         (break (resolve-unit years (units :year) loc)))
       (break (string (resolve-unit years (units :year) loc)
                      delimiter
                      (resolve-unit rem (units :month) loc))))

     # Tier 5: 3-6 years -> years with half marker
     (when (< months 84)
       (def years (math/floor (/ months 12)))
       (def rem (% months 12))
       (if (>= rem 6)
         (break (resolve-unit years (units :year) loc half))
         (break (resolve-unit years (units :year) loc))))

     # Tier 6: 7+ years
     (resolve-unit (math/floor (/ months 12)) (units :year) loc))

   :format-stage
   (fn [date-of-birth &opt as-of gender]
     (def parsed (parse-age date-of-birth as-of))
     (unless parsed (break nil))
     (def [months _] parsed)
     (resolve-stage (get (loc :stages) (stage-key months)) gender))})

# Default English locale
(import ./locales/en :prefix "en-")
(def- default-en en-locale)
(def- default-formatter (make-formatter default-en))

(defn format-age [date-of-birth &opt as-of]
  ((default-formatter :format-age) date-of-birth as-of))

(defn format-stage [date-of-birth &opt as-of gender]
  ((default-formatter :format-stage) date-of-birth as-of gender))

(import ./locales/registry :as reg)

(defn get-locale [code]
  (reg/get-locale code))

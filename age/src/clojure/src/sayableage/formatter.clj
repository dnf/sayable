(ns sayableage.formatter
  (:require [clojure.string :as str]
            [sayableage.internal :as internal]))

(def version "0.5.0")

(defn- lookup-unit-form [cat forms]
  (or (get forms cat) (get forms :other) ""))

(defn- resolve-unit [count' unit-forms locale half]
  (let [base-n (str count')
        n (if (and (seq half) (str/includes? half "{n}"))
            (str/replace half "{n}" base-n)
            base-n)
        plural-fn (:plural locale)
        template (case (:type unit-forms)
                   :simple (:form unit-forms)
                   :pluralized (lookup-unit-form (plural-fn count') (:forms unit-forms)))
        result (str/replace template "{n}" n)]
    (if (and (seq half) (str/includes? half "{0}"))
      (str/replace half "{0}" result)
      result)))

(defn- ovr-or [ovr-val default]
  (if (some? ovr-val) ovr-val default))

(defn- resolve-locale [locale compactness]
  (let [m-ovr (case compactness
                :normal nil
                :short (:short locale)
                :compact (:compact locale))]
    (if (nil? m-ovr)
      {:day (:day locale) :week (:week locale) :month (:month locale) :year (:year locale)
       :half (:half locale) :delimiter (:delimiter locale) :just-born (:just-born locale)}
      {:day (ovr-or (:day m-ovr) (:day locale))
       :week (ovr-or (:week m-ovr) (:week locale))
       :month (ovr-or (:month m-ovr) (:month locale))
       :year (ovr-or (:year m-ovr) (:year locale))
       :half (ovr-or (:half m-ovr) (:half locale))
       :delimiter (ovr-or (:delimiter m-ovr) (:delimiter locale))
       :just-born (ovr-or (:just-born m-ovr) (:just-born locale))})))

(defn- format-tier [locale day week month year half delim just-born months diff-days]
  (cond
    (== diff-days 0)
    just-born

    (< diff-days 7)
    (resolve-unit diff-days day locale "")

    (< months 3)
    (let [weeks (quot diff-days 7)
          days (mod diff-days 7)
          w-str (resolve-unit weeks week locale "")]
      (if (> days 0)
        (str w-str delim (resolve-unit days day locale ""))
        w-str))

    (< months 24)
    (resolve-unit months month locale "")

    (< months 36)
    (let [years (quot months 12)
          rem' (mod months 12)
          y-str (resolve-unit years year locale "")]
      (if (== rem' 0)
        y-str
        (str y-str delim (resolve-unit rem' month locale ""))))

    (< months 84)
    (let [years (quot months 12)
          rem' (mod months 12)]
      (if (>= rem' 6)
        (resolve-unit years year locale half)
        (resolve-unit years year locale "")))

    :else
    (let [years (quot months 12)]
      (resolve-unit years year locale ""))))

(defn format-age-pure [locale compactness dob as-of]
  (when (seq dob)
    (when-let [{:keys [months diff-days]} (internal/compute-age dob as-of)]
      (when (<= months 6000)
        (let [{:keys [day week month year half delimiter just-born]} (resolve-locale locale compactness)]
          (format-tier locale day week month year half delimiter just-born months diff-days))))))

(defn- stage-label [months stages]
  (cond
    (< months 2) (:newborn stages)
    (< months 12) (:infant stages)
    (< months 36) (:toddler stages)
    (< months 156) (:child stages)
    (< months 216) (:teenager stages)
    :else (:adult stages)))

(defn- resolve-stage-label [label gender]
  (case (:type label)
    :neutral (:label label)
    :gendered (if (= gender :female) (:f label) (:m label))))

(defn format-stage-pure [locale dob as-of gender]
  (when (seq dob)
    (when-let [{:keys [months]} (internal/compute-age dob as-of)]
      (let [stages (:stages locale)
            label (stage-label months stages)]
        (resolve-stage-label label gender)))))

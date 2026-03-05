(ns sayableduration.formatter
  (:require [clojure.string :as str]
            [sayableduration.internal :as internal]))

(def version "0.1.0")

(defn- lookup-unit-form [cat forms]
  (or (get forms cat) (get forms :other) ""))

(defn- resolve-unit [count' unit-forms locale half]
  (let [base-n (str count')
        n (if (and (seq half) (str/includes? half "{n}"))
            (str/replace half "{n}" base-n)
            base-n)
        plural-fn (:plural locale)
        ;; Force :other plural when half is non-empty
        template (case (:type unit-forms)
                   :simple (:form unit-forms)
                   :pluralized (lookup-unit-form
                                 (if (seq half) :other (plural-fn count'))
                                 (:forms unit-forms)))
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
      {:second (:second locale) :minute (:minute locale) :hour (:hour locale)
       :day (:day locale) :week (:week locale) :month (:month locale) :year (:year locale)
       :half (:half locale) :delimiter (:delimiter locale) :just-now (:just-now locale)
       :ago (:ago locale) :in-future (:in-future locale)}
      {:second (ovr-or (:second m-ovr) (:second locale))
       :minute (ovr-or (:minute m-ovr) (:minute locale))
       :hour (ovr-or (:hour m-ovr) (:hour locale))
       :day (ovr-or (:day m-ovr) (:day locale))
       :week (ovr-or (:week m-ovr) (:week locale))
       :month (ovr-or (:month m-ovr) (:month locale))
       :year (ovr-or (:year m-ovr) (:year locale))
       :half (ovr-or (:half m-ovr) (:half locale))
       :delimiter (ovr-or (:delimiter m-ovr) (:delimiter locale))
       :just-now (:just-now locale)
       :ago (ovr-or (:ago m-ovr) (:ago locale))
       :in-future (ovr-or (:in-future m-ovr) (:in-future locale))})))

(defn- format-duration-internal [locale resolved total]
  (let [{:keys [second minute hour day week month year half delimiter just-now]} resolved]
    (cond
      ;; 0 seconds
      (== total 0)
      just-now

      ;; 1-59 seconds
      (< total 60)
      (resolve-unit total second locale "")

      :else
      (let [total-minutes (quot total 60)
            remainder-seconds (mod total 60)]
        (cond
          ;; 1-4 minutes: minutes + seconds
          (< total-minutes 5)
          (let [result (resolve-unit total-minutes minute locale "")]
            (if (> remainder-seconds 0)
              (str result delimiter (resolve-unit remainder-seconds second locale ""))
              result))

          ;; 5-59 minutes
          (< total-minutes 60)
          (resolve-unit total-minutes minute locale "")

          :else
          (let [total-hours (quot total 3600)
                remainder-minutes (quot (mod total 3600) 60)]
            (cond
              ;; 1-5 hours: hours + minutes (with half marker)
              (<= total-hours 5)
              (if (== remainder-minutes 30)
                (resolve-unit total-hours hour locale half)
                (let [result (resolve-unit total-hours hour locale "")]
                  (if (> remainder-minutes 0)
                    (str result delimiter (resolve-unit remainder-minutes minute locale ""))
                    result)))

              ;; 6-23 hours
              (< total-hours 24)
              (resolve-unit total-hours hour locale "")

              :else
              (let [total-days (quot total 86400)
                    remainder-hours (quot (mod total 86400) 3600)]
                (cond
                  ;; 1-2 days: days + hours (with half marker)
                  (<= total-days 2)
                  (if (== remainder-hours 12)
                    (resolve-unit total-days day locale half)
                    (let [result (resolve-unit total-days day locale "")]
                      (if (> remainder-hours 0)
                        (str result delimiter (resolve-unit remainder-hours hour locale ""))
                        result)))

                  ;; 3-6 days
                  (< total-days 7)
                  (resolve-unit total-days day locale "")

                  :else
                  (let [total-weeks (quot total-days 7)
                        remainder-days (mod total-days 7)]
                    (cond
                      ;; 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
                      (< total-days 30)
                      (let [result (resolve-unit total-weeks week locale "")]
                        (if (> remainder-days 0)
                          (str result delimiter (resolve-unit remainder-days day locale ""))
                          result))

                      :else
                      (let [total-months (Math/round (/ (double total-days) 30.44))
                            total-months (if (and (< total-months 12) (== total-months 0)) 1 total-months)]
                        (if (< total-months 12)
                          ;; 1-11 months
                          (resolve-unit total-months month locale "")
                          ;; 12+ months: years + months
                          (let [total-years (quot total-months 12)
                                remainder-months (mod total-months 12)
                                result (resolve-unit total-years year locale "")]
                            (if (> remainder-months 0)
                              (str result delimiter (resolve-unit remainder-months month locale ""))
                              result)))))))))))))))

(defn format-duration-seconds [locale compactness seconds]
  (when (>= seconds 0)
    (let [resolved (resolve-locale locale compactness)]
      (format-duration-internal locale resolved seconds))))

(defn format-duration-iso [locale compactness start end]
  (when (and (seq start) (seq end))
    (when-let [s (internal/parse-iso-to-seconds start)]
      (when-let [e (internal/parse-iso-to-seconds end)]
        (let [total (Math/abs (- e s))
              resolved (resolve-locale locale compactness)]
          (format-duration-internal locale resolved total))))))

(defn format-since [locale compactness start as-of]
  (when (and (seq start) (seq as-of))
    (when-let [s (internal/parse-iso-to-seconds start)]
      (when-let [a (internal/parse-iso-to-seconds as-of)]
        (let [diff (- a s)]
          (when (>= diff 0)
            (if (== diff 0)
              (:just-now locale)
              (let [resolved (resolve-locale locale compactness)
                    dur (format-duration-internal locale resolved diff)]
                (str/replace (:ago resolved) "{0}" dur)))))))))

(defn format-until [locale compactness target as-of]
  (when (and (seq target) (seq as-of))
    (when-let [t (internal/parse-iso-to-seconds target)]
      (when-let [a (internal/parse-iso-to-seconds as-of)]
        (let [diff (- t a)]
          (when (>= diff 0)
            (if (== diff 0)
              (:just-now locale)
              (let [resolved (resolve-locale locale compactness)
                    dur (format-duration-internal locale resolved diff)]
                (str/replace (:in-future resolved) "{0}" dur)))))))))

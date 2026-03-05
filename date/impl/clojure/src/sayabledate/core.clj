(ns sayabledate.core
  (:require [sayabledate.formatter :as fmt]
            [sayabledate.locales :as locales]))

(defn format-date
  ([date] (fmt/format-date (locales/get-locale "en") :normal date))
  ([locale compactness date] (fmt/format-date locale compactness date)))

(defn format-date-with-year
  ([date] (fmt/format-date-with-year (locales/get-locale "en") :normal date))
  ([locale compactness date] (fmt/format-date-with-year locale compactness date)))

(defn format-relative
  ([date as-of] (fmt/format-relative (locales/get-locale "en") :normal date as-of))
  ([locale compactness date as-of] (fmt/format-relative locale compactness date as-of)))

(defn get-locale [code]
  (locales/get-locale code))

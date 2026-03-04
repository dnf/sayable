(ns sayableage.core
  (:require [sayableage.formatter :as fmt]
            [sayableage.locales :as locales]
            [sayableage.internal :as internal]))

(defn format-age-pure [locale compactness dob as-of]
  (fmt/format-age-pure locale compactness dob as-of))

(defn format-age [locale compactness dob as-of]
  (let [effective-as-of (or as-of (internal/format-date (internal/today)))]
    (fmt/format-age-pure locale compactness dob effective-as-of)))

(defn format-stage-pure [locale dob as-of gender]
  (fmt/format-stage-pure locale dob as-of gender))

(defn format-stage [locale dob as-of gender]
  (let [effective-as-of (or as-of (internal/format-date (internal/today)))]
    (fmt/format-stage-pure locale dob effective-as-of gender)))

(defn get-locale [code]
  (locales/get-locale code))

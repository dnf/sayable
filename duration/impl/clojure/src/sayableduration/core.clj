(ns sayableduration.core
  (:require [sayableduration.formatter :as fmt]
            [sayableduration.locales :as locales]))

(defn format-duration-seconds
  ([seconds] (fmt/format-duration-seconds (locales/get-locale "en") :normal seconds))
  ([locale compactness seconds] (fmt/format-duration-seconds locale compactness seconds)))

(defn format-duration-iso
  ([start end] (fmt/format-duration-iso (locales/get-locale "en") :normal start end))
  ([locale compactness start end] (fmt/format-duration-iso locale compactness start end)))

(defn format-since
  ([start as-of] (fmt/format-since (locales/get-locale "en") :normal start as-of))
  ([locale compactness start as-of] (fmt/format-since locale compactness start as-of)))

(defn format-until
  ([target as-of] (fmt/format-until (locales/get-locale "en") :normal target as-of))
  ([locale compactness target as-of] (fmt/format-until locale compactness target as-of)))

(defn get-locale [code]
  (locales/get-locale code))

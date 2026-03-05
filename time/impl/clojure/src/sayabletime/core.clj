(ns sayabletime.core
  (:require [sayabletime.formatter :as fmt]
            [sayabletime.locales :as locales]))

(defn format-time
  ([input] (fmt/format-time (locales/get-locale "en") :normal input))
  ([locale compactness input] (fmt/format-time locale compactness input)))

(defn get-locale [code]
  (locales/get-locale code))

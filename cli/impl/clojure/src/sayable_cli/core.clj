(ns sayable-cli.core
  "Sayable CLI -- unified command-line interface to all four Sayable components.

  See cli/SPEC.md for the full specification."
  (:require [clojure.string :as str]
            [sayableage.core :as age]
            [sayableage.locales :as age-locales]
            [sayabledate.core :as date]
            [sayabledate.locales :as date-locales]
            [sayabletime.core :as time-core]
            [sayabletime.locales :as time-locales]
            [sayableduration.core :as duration]
            [sayableduration.locales :as duration-locales])
  (:gen-class))

(def version "0.5.0")

(def help-text
  "Usage: sayable <command> [arguments] [options]

Commands:
  age <dob>              Format an age
  stage <dob>            Get developmental stage
  date <date>            Format a calendar date
  relative <date>        Format a relative date
  time <time>            Format a clock time
  duration <value> [end] Format a duration
  since <start>          Format elapsed time
  until <target>         Format remaining time
  locales                List available locale codes
  version                Show version
  help                   Show this help

Options:
  -l, --locale <code>    Locale code (default: en)
  -d, --as-of <value>    Reference date/timestamp
      --short            Short compactness
      --compact          Compact compactness
  -g, --gender <m|f>     Gender for stage labels
      --with-year        Include year (date only)
  -h, --help             Show this help
  -v, --version          Show version")

(defn- cli-error
  "Abort the current request with a usage error (exit code 2)."
  [msg]
  (throw (ex-info msg {::usage-error true})))

(defn- usage-error? [e]
  (::usage-error (ex-data e)))

(defn- nullify
  "Convert the CLI 'null' sentinel to nil."
  [value]
  (if (= value "null") nil value))

(defn- get-today
  "Get today's date as YYYY-MM-DD."
  []
  (let [ld (java.time.LocalDate/now)]
    (format "%04d-%02d-%02d"
            (.getYear ld)
            (.getMonthValue ld)
            (.getDayOfMonth ld))))

(defn- parse-compactness
  "Convert compactness string to keyword."
  [s]
  (case s
    "normal" :normal
    "short" :short
    "compact" :compact
    :normal))

(defn- parse-gender
  "Convert gender string to keyword."
  [s]
  (case s
    "m" :male
    "f" :female
    nil))

(defn- parse-args
  "Parse CLI arguments into [command positionals options]."
  [argv]
  (if (empty? argv)
    [nil [] {}]
    (let [first-arg (first argv)]
      (if (contains? #{"-h" "--help" "help"} first-arg)
        ["help" [] {}]
        (if (contains? #{"-v" "--version" "version"} first-arg)
          ["version" [] {}]
          (let [command first-arg]
            (loop [i 1
                   positionals []
                   options {:locale "en"
                            :as-of nil
                            :compactness "normal"
                            :gender nil
                            :with-year false}
                   stop-opts false]
              (if (>= i (count argv))
                [command positionals options]
                (let [arg (nth argv i)]
                  (cond
                    (and (= arg "--") (not stop-opts))
                    (recur (inc i) positionals options true)

                    (and (not stop-opts) (.startsWith ^String arg "-"))
                    (cond
                      (or (= arg "-l") (= arg "--locale"))
                      (if (>= (inc i) (count argv))
                        (cli-error (str "'" arg "' requires a value"))
                        (recur (+ i 2) positionals
                               (assoc options :locale (nth argv (inc i)))
                               stop-opts))

                      (or (= arg "-d") (= arg "--as-of"))
                      (if (>= (inc i) (count argv))
                        (cli-error (str "'" arg "' requires a value"))
                        (recur (+ i 2) positionals
                               (assoc options :as-of (nth argv (inc i)))
                               stop-opts))

                      (or (= arg "-g") (= arg "--gender"))
                      (if (>= (inc i) (count argv))
                        (cli-error (str "'" arg "' requires a value"))
                        (recur (+ i 2) positionals
                               (assoc options :gender (nth argv (inc i)))
                               stop-opts))

                      (= arg "--short")
                      (recur (inc i) positionals
                             (assoc options :compactness "short")
                             stop-opts)

                      (= arg "--compact")
                      (recur (inc i) positionals
                             (assoc options :compactness "compact")
                             stop-opts)

                      (= arg "--with-year")
                      (recur (inc i) positionals
                             (assoc options :with-year true)
                             stop-opts)

                      (or (= arg "-h") (= arg "--help"))
                      ["help" [] {}]

                      (or (= arg "-v") (= arg "--version"))
                      ["version" [] {}]

                      :else
                      (cli-error (str "unknown option '" arg "'")))

                    :else
                    (recur (inc i) (conj positionals arg) options stop-opts)))))))))))

(defn- cmd-age [positionals options]
  (when (empty? positionals)
    (cli-error "age requires a date-of-birth argument"))
  (let [dob (nullify (first positionals))
        locale-code (:locale options)
        locale (age-locales/get-locale locale-code)]
    (when (nil? locale)
      (cli-error (str "unknown locale '" locale-code "'")))
    (let [as-of (if (some? (:as-of options))
                  (nullify (:as-of options))
                  (get-today))
          compactness (parse-compactness (:compactness options))
          result (age/format-age locale compactness dob as-of)]
      result)))

(defn- cmd-stage [positionals options]
  (when (empty? positionals)
    (cli-error "stage requires a date-of-birth argument"))
  (let [dob (nullify (first positionals))
        locale-code (:locale options)
        locale (age-locales/get-locale locale-code)]
    (when (nil? locale)
      (cli-error (str "unknown locale '" locale-code "'")))
    (let [as-of (if (some? (:as-of options))
                  (nullify (:as-of options))
                  (get-today))
          gender (parse-gender (:gender options))
          result (age/format-stage locale dob as-of gender)]
      result)))

(defn- cmd-date [positionals options]
  (when (empty? positionals)
    (cli-error "date requires a date argument"))
  (let [date-val (nullify (first positionals))
        locale-code (:locale options)
        locale (date-locales/get-locale locale-code)]
    (when (nil? locale)
      (cli-error (str "unknown locale '" locale-code "'")))
    (let [compactness (parse-compactness (:compactness options))
          result (if (:with-year options)
                   (date/format-date-with-year locale compactness date-val)
                   (date/format-date locale compactness date-val))]
      result)))

(defn- cmd-relative [positionals options]
  (when (empty? positionals)
    (cli-error "relative requires a date argument"))
  (let [date-val (nullify (first positionals))
        as-of-raw (:as-of options)]
    (when (nil? as-of-raw)
      (cli-error "relative requires --as-of / -d option"))
    (let [as-of (nullify as-of-raw)
          locale-code (:locale options)
          locale (date-locales/get-locale locale-code)]
      (when (nil? locale)
        (cli-error (str "unknown locale '" locale-code "'")))
      (let [compactness (parse-compactness (:compactness options))
            result (date/format-relative locale compactness date-val as-of)]
        result))))

(defn- cmd-time [positionals options]
  (when (empty? positionals)
    (cli-error "time requires a time argument"))
  (let [time-val (nullify (first positionals))
        locale-code (:locale options)
        locale (time-locales/get-locale locale-code)]
    (when (nil? locale)
      (cli-error (str "unknown locale '" locale-code "'")))
    (let [compactness (parse-compactness (:compactness options))
          result (time-core/format-time locale compactness time-val)]
      result)))

(defn- all-digits?
  "Check if string (with optional leading minus removed) is all digits."
  [^String s]
  (every? #(Character/isDigit ^char %) s))

(defn- integer-string?
  "Check if string represents an integer (possibly negative)."
  [^String s]
  (and (seq s)
       (let [stripped (if (.startsWith s "-") (subs s 1) s)]
         (and (seq stripped) (all-digits? stripped)))))

(defn- cmd-duration [positionals options]
  (when (empty? positionals)
    (cli-error "duration requires a value argument"))
  (let [value (nullify (first positionals))
        locale-code (:locale options)
        locale (duration-locales/get-locale locale-code)]
    (when (nil? locale)
      (cli-error (str "unknown locale '" locale-code "'")))
    (let [compactness (parse-compactness (:compactness options))
          result (cond
                   (nil? value)
                   nil

                   (integer-string? value)
                   (let [n (Long/parseLong value)]
                     (duration/format-duration-seconds locale compactness n))

                   :else
                   (do
                     (when (< (count positionals) 2)
                       (cli-error "duration with timestamps requires start and end arguments"))
                     (let [end-val (nullify (nth positionals 1))]
                       (duration/format-duration-iso locale compactness value end-val))))]
      result)))

(defn- cmd-since [positionals options]
  (when (empty? positionals)
    (cli-error "since requires a start timestamp argument"))
  (let [start (nullify (first positionals))
        as-of-raw (:as-of options)]
    (when (nil? as-of-raw)
      (cli-error "since requires --as-of / -d option"))
    (let [as-of (nullify as-of-raw)
          locale-code (:locale options)
          locale (duration-locales/get-locale locale-code)]
      (when (nil? locale)
        (cli-error (str "unknown locale '" locale-code "'")))
      (let [compactness (parse-compactness (:compactness options))
            result (duration/format-since locale compactness start as-of)]
        result))))

(defn- cmd-until [positionals options]
  (when (empty? positionals)
    (cli-error "until requires a target timestamp argument"))
  (let [target (nullify (first positionals))
        as-of-raw (:as-of options)]
    (when (nil? as-of-raw)
      (cli-error "until requires --as-of / -d option"))
    (let [as-of (nullify as-of-raw)
          locale-code (:locale options)
          locale (duration-locales/get-locale locale-code)]
      (when (nil? locale)
        (cli-error (str "unknown locale '" locale-code "'")))
      (let [compactness (parse-compactness (:compactness options))
            result (duration/format-until locale compactness target as-of)]
        result))))

(defn- cmd-locales []
  (let [codes (into (sorted-set)
                    (keep (fn [code]
                            (when (age-locales/get-locale code) code))
                          ;; Extract locale codes from the age locales registry
                          ;; by trying all known codes. We use the file listing
                          ;; approach: every locale file defines a code.
                          (map :code
                               (keep (fn [ns-sym]
                                       (try
                                         (require ns-sym)
                                         (let [ns-obj (find-ns ns-sym)]
                                           (when-let [v (ns-resolve ns-obj 'locale)]
                                             (deref v)))
                                         (catch Exception _ nil)))
                                     ;; Generate namespace symbols for all possible locale namespaces
                                     (for [code ["af" "ak" "am" "ar" "az" "bci" "be" "bem" "bg" "bm"
                                                 "bn" "br" "bs" "ca" "ceb" "cs" "cy" "da" "de" "din"
                                                 "dje" "dyu" "ee" "el" "en" "es" "et" "eu" "fa" "fan"
                                                 "ff" "fi" "fil" "fon" "fr" "ga" "gd" "gl" "gn" "gu"
                                                 "gv" "ha" "he" "hi" "hr" "ht" "hu" "hy" "id" "ig"
                                                 "is" "it" "ja" "jv" "ka" "kbp" "kk" "km" "kn" "ko"
                                                 "kpe" "ktu" "ku" "kw" "ky" "lg" "ln" "lo" "lt" "lv"
                                                 "men" "mfe" "mg" "mi" "mk" "ml" "mn" "mnk" "mos" "mr"
                                                 "ms" "mt" "my" "nb" "nd" "ne" "ng" "nl" "nso" "nus"
                                                 "ny" "om" "or" "pa" "pl" "pov" "ps" "pt" "qu" "ro"
                                                 "ru" "rw" "sar" "sd" "sg" "shi" "si" "sk" "sl" "sn"
                                                 "snk" "so" "sq" "sr" "ss" "st" "su" "suk" "sv" "sw"
                                                 "ta" "te" "tem" "tg" "th" "ti" "tig" "tk" "tn" "tr"
                                                 "ts" "tzm" "uk" "umb" "ur" "uz" "vi" "vmw" "wo" "xh"
                                                 "yo" "yue" "zdj" "zh" "zu"]]
                                       (symbol (str "sayableage.locales." code)))))))]
    (str/join "\n" codes)))

(def ^:private commands
  {"age" cmd-age
   "stage" cmd-stage
   "date" cmd-date
   "relative" cmd-relative
   "time" cmd-time
   "duration" cmd-duration
   "since" cmd-since
   "until" cmd-until})

(defn- run
  "Run one command, returning [exit-code output]; output is nil when nothing
  is printed."
  [argv]
  (try
    (let [[command positionals options] (parse-args argv)]
      (cond
        (nil? command) [2 help-text]
        (= command "help") [0 help-text]
        (= command "version") [0 (str "sayable " version)]
        (= command "locales") [0 (cmd-locales)]

        (contains? commands command)
        (if-some [result ((get commands command) positionals options)]
          [0 result]
          [1 nil])

        :else
        (cli-error (str "unknown command '" command "'"))))
    (catch clojure.lang.ExceptionInfo e
      (if (usage-error? e)
        (binding [*out* *err*]
          (println (str "error: " (ex-message e)))
          (println "Run 'sayable help' for usage.")
          [2 nil])
        (throw e)))))

(defn- run-catching-crashes
  "A crashed one-shot run exits 1, so a crashed request answers 1 and the
  REPL keeps serving."
  [argv]
  (try
    (run argv)
    (catch Exception e
      (.printStackTrace e)
      [1 nil])))

(defn- repl
  "Answer one tab-separated request per stdin line (see cli/SPEC.md,
  \"REPL Mode\")."
  []
  (doseq [line (line-seq (java.io.BufferedReader. *in*))]
    (let [[code output] (run-catching-crashes (str/split line #"\t" -1))]
      (println (str code "\t" (some-> output (str/replace "\n" "\t"))))
      (flush))))

(defn -main [& args]
  (if (= args ["--repl"])
    (repl)
    (let [[code output] (run (vec args))]
      (when (some? output)
        (println output))
      (flush)
      (System/exit code))))

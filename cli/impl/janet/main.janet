# Sayable CLI — unified command-line interface to all four Sayable components.
# See cli/SPEC.md for the full specification.

(def cli-version "0.5.0")

# The wrapper script cds to the project root before invoking janet.
# Add a CWD-relative module path so require resolves from the project root.
(array/insert module/paths 0
  [(string (os/cwd) "/:all:.janet") :source])

# Component base paths (relative to project root)
(def- age-base "age/impl/janet")
(def- date-base "date/impl/janet")
(def- duration-base "duration/impl/janet")
(def- time-base "time/impl/janet")

# Import formatter modules
(def- age-mod (require (string age-base "/sayableage")))
(def- date-mod (require (string date-base "/format_date")))
(def- dur-mod (require (string duration-base "/format_duration")))
(def- time-mod (require (string time-base "/format_time")))

# Extract make-formatter from each module
(def age/make-formatter ((age-mod 'make-formatter) :value))
(def date/make-formatter ((date-mod 'make-formatter) :value))
(def dur/make-formatter ((dur-mod 'make-formatter) :value))
(def time/make-formatter ((time-mod 'make-formatter) :value))

# Locale loading — bypasses the registries (which use cwd-relative paths)
(def- age-locale-cache @{})
(def- date-locale-cache @{})
(def- dur-locale-cache @{})
(def- time-locale-cache @{})

(defn- load-locale [cache base-path code]
  (if-let [cached (in cache code)]
    cached
    (do
      (def path (string base-path "/locales/" code))
      (def env (try (require path) ([_] nil)))
      (when env
        (def loc ((env 'locale) :value))
        (put cache code loc)
        loc))))

(defn- get-age-locale [code]
  (load-locale age-locale-cache age-base code))

(defn- get-date-locale [code]
  (load-locale date-locale-cache date-base code))

(defn- get-dur-locale [code]
  (load-locale dur-locale-cache duration-base code))

(defn- get-time-locale [code]
  (load-locale time-locale-cache time-base code))

(def help-text `Usage: sayable <command> [arguments] [options]

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
  -v, --version          Show version`)

(defn- cli-error [msg]
  (eprintf "error: %s" msg)
  (eprint "Run 'sayable help' for usage.")
  (os/exit 2))

(defn- nullify [val]
  (if (= val "null") nil val))

(defn- get-today []
  (def t (os/date (os/time) true))
  (string/format "%04d-%02d-%02d"
                 (+ (t :year) 1900)
                 (+ (t :month) 1)
                 (+ (t :month-day) 1)))

(defn- parse-args [argv]
  (when (= (length argv) 0)
    (break [nil [] @{}]))
  (def first-arg (in argv 0))
  (when (or (= first-arg "-h") (= first-arg "--help") (= first-arg "help"))
    (break ["help" [] @{}]))
  (when (or (= first-arg "-v") (= first-arg "--version") (= first-arg "version"))
    (break ["version" [] @{}]))

  (def command first-arg)
  (def positionals @[])
  (def options @{:locale "en" :as-of nil :compactness "normal" :gender nil :with-year false})

  (var i 1)
  (var stop-opts false)
  (while (< i (length argv))
    (def arg (in argv i))
    (if (and (= arg "--") (not stop-opts))
      (do (set stop-opts true) (++ i))
      (if (and (not stop-opts) (string/has-prefix? "-" arg))
        (cond
          (or (= arg "-l") (= arg "--locale"))
          (do
            (when (>= (+ i 1) (length argv)) (cli-error (string "'" arg "' requires a value")))
            (++ i)
            (put options :locale (in argv i)))

          (or (= arg "-d") (= arg "--as-of"))
          (do
            (when (>= (+ i 1) (length argv)) (cli-error (string "'" arg "' requires a value")))
            (++ i)
            (put options :as-of (in argv i)))

          (or (= arg "-g") (= arg "--gender"))
          (do
            (when (>= (+ i 1) (length argv)) (cli-error (string "'" arg "' requires a value")))
            (++ i)
            (put options :gender (in argv i)))

          (= arg "--short")
          (put options :compactness "short")

          (= arg "--compact")
          (put options :compactness "compact")

          (= arg "--with-year")
          (put options :with-year true)

          (or (= arg "-h") (= arg "--help"))
          (break ["help" [] @{}])

          (or (= arg "-v") (= arg "--version"))
          (break ["version" [] @{}])

          (cli-error (string "unknown option '" arg "'")))
        (array/push positionals arg)))
    (++ i))
  [command positionals options])

(defn- cmd-age [positionals options]
  (when (= (length positionals) 0)
    (cli-error "age requires a date-of-birth argument"))
  (def dob (nullify (in positionals 0)))
  (def locale-code (options :locale))
  (def loc (get-age-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def as-of (if (options :as-of) (nullify (options :as-of)) (get-today)))
  (def pt (age/make-formatter loc (options :compactness)))
  (def result ((pt :format-age) dob as-of))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-stage [positionals options]
  (when (= (length positionals) 0)
    (cli-error "stage requires a date-of-birth argument"))
  (def dob (nullify (in positionals 0)))
  (def locale-code (options :locale))
  (def loc (get-age-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def as-of (if (options :as-of) (nullify (options :as-of)) (get-today)))
  (def gender (options :gender))
  (def pt (age/make-formatter loc (options :compactness)))
  (def result ((pt :format-stage) dob as-of gender))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-date [positionals options]
  (when (= (length positionals) 0)
    (cli-error "date requires a date argument"))
  (def date-val (nullify (in positionals 0)))
  (def locale-code (options :locale))
  (def loc (get-date-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def pt (date/make-formatter loc (options :compactness)))
  (def result
    (if (options :with-year)
      ((pt :format-date-with-year) date-val)
      ((pt :format-date) date-val)))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-relative [positionals options]
  (when (= (length positionals) 0)
    (cli-error "relative requires a date argument"))
  (def date-val (nullify (in positionals 0)))
  (def as-of (options :as-of))
  (when (nil? as-of) (cli-error "relative requires --as-of / -d option"))
  (def as-of-val (nullify as-of))
  (def locale-code (options :locale))
  (def loc (get-date-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def pt (date/make-formatter loc (options :compactness)))
  (def result ((pt :format-relative) date-val as-of-val))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-time [positionals options]
  (when (= (length positionals) 0)
    (cli-error "time requires a time argument"))
  (def time-val (nullify (in positionals 0)))
  (def locale-code (options :locale))
  (def loc (get-time-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def pt (time/make-formatter loc (options :compactness)))
  (def result ((pt :format-time) time-val))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-duration [positionals options]
  (when (= (length positionals) 0)
    (cli-error "duration requires a value argument"))
  (def value (nullify (in positionals 0)))
  (def locale-code (options :locale))
  (def loc (get-dur-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def pt (dur/make-formatter loc (options :compactness)))
  (var result nil)
  (if (nil? value)
    (set result ((pt :format-duration) nil))
    (do
      # Check if it looks like an integer (possibly negative)
      (def stripped (if (string/has-prefix? "-" value) (string/slice value 1) value))
      (if (and (> (length stripped) 0) (all |(and (>= $ 48) (<= $ 57)) stripped))
        (set result ((pt :format-duration) (scan-number value)))
        # Timestamp mode
        (do
          (when (< (length positionals) 2)
            (cli-error "duration with timestamps requires start and end arguments"))
          (def end-val (nullify (in positionals 1)))
          (set result ((pt :format-duration) value end-val))))))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-since [positionals options]
  (when (= (length positionals) 0)
    (cli-error "since requires a start timestamp argument"))
  (def start (nullify (in positionals 0)))
  (def as-of (options :as-of))
  (when (nil? as-of) (cli-error "since requires --as-of / -d option"))
  (def as-of-val (nullify as-of))
  (def locale-code (options :locale))
  (def loc (get-dur-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def pt (dur/make-formatter loc (options :compactness)))
  (def result ((pt :format-since) start as-of-val))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-until [positionals options]
  (when (= (length positionals) 0)
    (cli-error "until requires a target timestamp argument"))
  (def target (nullify (in positionals 0)))
  (def as-of (options :as-of))
  (when (nil? as-of) (cli-error "until requires --as-of / -d option"))
  (def as-of-val (nullify as-of))
  (def locale-code (options :locale))
  (def loc (get-dur-locale locale-code))
  (when (nil? loc) (cli-error (string "unknown locale '" locale-code "'")))
  (def pt (dur/make-formatter loc (options :compactness)))
  (def result ((pt :format-until) target as-of-val))
  (if (nil? result) (os/exit 1) (print result)))

(defn- cmd-locales []
  (def codes @[])
  (def known-codes
    ["af" "ak" "am" "ar" "ay" "az" "bci" "be" "bem" "bg" "bi" "bm" "bn" "br"
     "bs" "ca" "cak" "ceb" "cs" "cy" "da" "de" "din" "dje" "dv" "dyu" "dz" "ee"
     "el" "en" "es" "et" "eu" "fa" "fan" "ff" "fi" "fil" "fj" "fon" "fr" "ga"
     "gd" "gl" "gn" "gu" "gv" "ha" "he" "hi" "hmn" "hr" "ht" "hu" "hy" "id"
     "ig" "is" "it" "ja" "jv" "ka" "kbp" "kek" "ki" "kk" "kl" "km" "kn" "ko"
     "kpe" "kri" "ktu" "ku" "kw" "ky" "lb" "lg" "ln" "lo" "lt" "luo" "lv" "mam"
     "men" "mfe" "mg" "mi" "mk" "ml" "mn" "mnk" "mos" "mr" "ms" "mt" "my" "nb"
     "nd" "ne" "ng" "nl" "nr" "nso" "nus" "ny" "om" "or" "pa" "pis" "pl" "pov"
     "ps" "pt" "qu" "quc" "ro" "ru" "rw" "sar" "sd" "sg" "shi" "shn" "si" "sk"
     "sl" "sn" "snk" "so" "sq" "sr" "ss" "st" "su" "suk" "sv" "sw" "ta" "te"
     "tem" "tet" "tg" "th" "ti" "tig" "tk" "tn" "tpi" "tr" "ts" "tum" "tzm" "uk"
     "umb" "ur" "uz" "ve" "vi" "vmw" "wo" "xh" "yao" "yo" "yue" "zdj" "zh" "zu"])
  (each code known-codes
    (when (get-age-locale code)
      (array/push codes code)))
  (sort codes)
  (each code codes
    (print code)))

(defn main [&]
  (def argv (dyn :args))
  (def args (array/slice argv 1))
  (def [command positionals options] (parse-args args))

  (when (nil? command)
    (print help-text)
    (os/exit 2))

  (case command
    "help" (do (print help-text) (os/exit 0))
    "version" (do (printf "sayable %s" cli-version) (os/exit 0))
    "locales" (do (cmd-locales) (os/exit 0))
    "age" (cmd-age positionals options)
    "stage" (cmd-stage positionals options)
    "date" (cmd-date positionals options)
    "relative" (cmd-relative positionals options)
    "time" (cmd-time positionals options)
    "duration" (cmd-duration positionals options)
    "since" (cmd-since positionals options)
    "until" (cmd-until positionals options)
    (cli-error (string "unknown command '" command "'"))))

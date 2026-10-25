;;; Sayable CLI — unified command-line interface to all four Sayable components.
;;; See cli/SPEC.md for the full specification.

(defvar *cli-version* "0.5.0")

(defvar *help-text*
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

;;; --- Argument parsing ---

(defun cli-exit (code)
  "End the current command with exit CODE; the caller of DISPATCH decides what exiting means."
  (throw 'cli-exit code))

(defun cli-error (msg)
  "Print error to stderr and exit with code 2."
  (format *error-output* "error: ~a~%" msg)
  (format *error-output* "Run 'sayable help' for usage.~%")
  (cli-exit 2))

(defun nullify (value)
  "Convert the CLI 'null' sentinel to NIL."
  (if (string= value "null") nil value))

(defun get-today ()
  "Get today's date as YYYY-MM-DD."
  (multiple-value-bind (sec min hour day month year)
      (get-decoded-time)
    (declare (ignore sec min hour))
    (format nil "~4,'0d-~2,'0d-~2,'0d" year month day)))

(defun digits-p (s)
  "Return T if S consists entirely of digits."
  (and (> (length s) 0)
       (every #'digit-char-p s)))

(defun parse-args (argv)
  "Parse CLI arguments into (values command positionals options)."
  (when (null argv)
    (return-from parse-args (values nil nil nil)))
  (let ((first (first argv)))
    ;; Global flags
    (when (or (string= first "-h") (string= first "--help") (string= first "help"))
      (return-from parse-args (values "help" nil nil)))
    (when (or (string= first "-v") (string= first "--version") (string= first "version"))
      (return-from parse-args (values "version" nil nil)))
    (let ((command first)
          (positionals nil)
          (locale "en")
          (as-of nil)
          (compactness :normal)
          (gender nil)
          (with-year nil)
          (stop-opts nil)
          (i 1))
      (loop while (< i (length argv))
            do (let ((arg (nth i argv)))
                 (cond
                   ((and (string= arg "--") (not stop-opts))
                    (setf stop-opts t))
                   ((and (not stop-opts) (or (string= arg "-l") (string= arg "--locale")))
                    (incf i)
                    (when (>= i (length argv))
                      (cli-error (format nil "'~a' requires a value" arg)))
                    (setf locale (nth i argv)))
                   ((and (not stop-opts) (or (string= arg "-d") (string= arg "--as-of")))
                    (incf i)
                    (when (>= i (length argv))
                      (cli-error (format nil "'~a' requires a value" arg)))
                    (setf as-of (nth i argv)))
                   ((and (not stop-opts) (or (string= arg "-g") (string= arg "--gender")))
                    (incf i)
                    (when (>= i (length argv))
                      (cli-error (format nil "'~a' requires a value" arg)))
                    (setf gender (nth i argv)))
                   ((and (not stop-opts) (string= arg "--short"))
                    (setf compactness :short))
                   ((and (not stop-opts) (string= arg "--compact"))
                    (setf compactness :compact))
                   ((and (not stop-opts) (string= arg "--with-year"))
                    (setf with-year t))
                   ((and (not stop-opts) (or (string= arg "-h") (string= arg "--help")))
                    (return-from parse-args (values "help" nil nil)))
                   ((and (not stop-opts) (or (string= arg "-v") (string= arg "--version")))
                    (return-from parse-args (values "version" nil nil)))
                   ((and (not stop-opts) (> (length arg) 0) (char= (char arg 0) #\-)
                         ;; Allow negative numbers through as positionals
                         (not (and (> (length arg) 1) (digit-char-p (char arg 1)))))
                    (cli-error (format nil "unknown option '~a'" arg)))
                   (t
                    (push arg positionals))))
               (incf i))
      (values command (nreverse positionals)
              (list :locale locale :as-of as-of :compactness compactness
                    :gender gender :with-year with-year)))))

(defun opt (options key)
  "Get an option value from the options plist."
  (getf options key))

;;; --- Command handlers ---

(defun cmd-age (positionals options)
  (when (null positionals)
    (cli-error "age requires a date-of-birth argument"))
  (let* ((dob (nullify (first positionals)))
         (locale-code (opt options :locale))
         (locale (sayable-age:get-locale locale-code)))
    (unless locale
      (cli-error (format nil "unknown locale '~a'" locale-code)))
    (let* ((as-of (let ((v (opt options :as-of)))
                    (if v (nullify v) (get-today))))
           (formatter (sayable-age:make-formatter locale (opt options :compactness)))
           (result (sayable-age:format-age formatter dob as-of)))
      (if result
          (progn (format t "~a~%" result) (cli-exit 0))
          (cli-exit 1)))))

(defun cmd-stage (positionals options)
  (when (null positionals)
    (cli-error "stage requires a date-of-birth argument"))
  (let* ((dob (nullify (first positionals)))
         (locale-code (opt options :locale))
         (locale (sayable-age:get-locale locale-code)))
    (unless locale
      (cli-error (format nil "unknown locale '~a'" locale-code)))
    (let* ((as-of (let ((v (opt options :as-of)))
                    (if v (nullify v) (get-today))))
           (gender (opt options :gender))
           (formatter (sayable-age:make-formatter locale (opt options :compactness)))
           (result (sayable-age:format-stage formatter dob as-of gender)))
      (if result
          (progn (format t "~a~%" result) (cli-exit 0))
          (cli-exit 1)))))

(defun cmd-date (positionals options)
  (when (null positionals)
    (cli-error "date requires a date argument"))
  (let* ((date-val (nullify (first positionals)))
         (locale-code (opt options :locale))
         (locale (sayable-date:get-locale locale-code)))
    (unless locale
      (cli-error (format nil "unknown locale '~a'" locale-code)))
    (let* ((formatter (sayable-date:make-formatter locale (opt options :compactness)))
           (result (if (opt options :with-year)
                       (sayable-date:format-date-with-year formatter date-val)
                       (sayable-date:format-date formatter date-val))))
      (if result
          (progn (format t "~a~%" result) (cli-exit 0))
          (cli-exit 1)))))

(defun cmd-relative (positionals options)
  (when (null positionals)
    (cli-error "relative requires a date argument"))
  (let ((as-of (opt options :as-of)))
    (unless as-of
      (cli-error "relative requires --as-of / -d option"))
    (let* ((date-val (nullify (first positionals)))
           (as-of-val (nullify as-of))
           (locale-code (opt options :locale))
           (locale (sayable-date:get-locale locale-code)))
      (unless locale
        (cli-error (format nil "unknown locale '~a'" locale-code)))
      (let* ((formatter (sayable-date:make-formatter locale (opt options :compactness)))
             (result (sayable-date:format-relative formatter date-val as-of-val)))
        (if result
            (progn (format t "~a~%" result) (cli-exit 0))
            (cli-exit 1))))))

(defun cmd-time (positionals options)
  (when (null positionals)
    (cli-error "time requires a time argument"))
  (let* ((time-val (nullify (first positionals)))
         (locale-code (opt options :locale))
         (locale (sayable-time:get-locale locale-code)))
    (unless locale
      (cli-error (format nil "unknown locale '~a'" locale-code)))
    (let* ((formatter (sayable-time:make-formatter locale (opt options :compactness)))
           (result (sayable-time:format-time formatter time-val)))
      (if result
          (progn (format t "~a~%" result) (cli-exit 0))
          (cli-exit 1)))))

(defun cmd-duration (positionals options)
  (when (null positionals)
    (cli-error "duration requires a value argument"))
  (let* ((value (nullify (first positionals)))
         (locale-code (opt options :locale))
         (locale (sayable-duration:get-locale locale-code)))
    (unless locale
      (cli-error (format nil "unknown locale '~a'" locale-code)))
    (let* ((formatter (sayable-duration:make-formatter locale (opt options :compactness)))
           (result
             (cond
               ((null value)
                (sayable-duration:format-duration formatter nil))
               ;; Check for non-negative integer (all digits)
               ((digits-p value)
                (sayable-duration:format-duration formatter (parse-integer value)))
               ;; Check for negative integer
               ((and (> (length value) 1)
                     (char= (char value 0) #\-)
                     (digits-p (subseq value 1)))
                (sayable-duration:format-duration formatter (- (parse-integer (subseq value 1)))))
               ;; Timestamp mode
               (t
                (when (< (length positionals) 2)
                  (cli-error "duration with timestamps requires start and end arguments"))
                (let ((end (nullify (second positionals))))
                  (sayable-duration:format-duration formatter value end))))))
      (if result
          (progn (format t "~a~%" result) (cli-exit 0))
          (cli-exit 1)))))

(defun cmd-since (positionals options)
  (when (null positionals)
    (cli-error "since requires a start timestamp argument"))
  (let ((as-of (opt options :as-of)))
    (unless as-of
      (cli-error "since requires --as-of / -d option"))
    (let* ((start (nullify (first positionals)))
           (as-of-val (nullify as-of))
           (locale-code (opt options :locale))
           (locale (sayable-duration:get-locale locale-code)))
      (unless locale
        (cli-error (format nil "unknown locale '~a'" locale-code)))
      (let* ((formatter (sayable-duration:make-formatter locale (opt options :compactness)))
             (result (sayable-duration:format-since formatter start as-of-val)))
        (if result
            (progn (format t "~a~%" result) (cli-exit 0))
            (cli-exit 1))))))

(defun cmd-until (positionals options)
  (when (null positionals)
    (cli-error "until requires a target timestamp argument"))
  (let ((as-of (opt options :as-of)))
    (unless as-of
      (cli-error "until requires --as-of / -d option"))
    (let* ((target (nullify (first positionals)))
           (as-of-val (nullify as-of))
           (locale-code (opt options :locale))
           (locale (sayable-duration:get-locale locale-code)))
      (unless locale
        (cli-error (format nil "unknown locale '~a'" locale-code)))
      (let* ((formatter (sayable-duration:make-formatter locale (opt options :compactness)))
             (result (sayable-duration:format-until formatter target as-of-val)))
        (if result
            (progn (format t "~a~%" result) (cli-exit 0))
            (cli-exit 1))))))

(defun cmd-locales ()
  "List all supported locale codes."
  (let ((codes nil))
    ;; Use age locales as the canonical list
    (dolist (pair sayable-age::*all-locales*)
      (push (car pair) codes))
    (dolist (code (sort codes #'string<))
      (format t "~a~%" code)))
  (cli-exit 0))

;;; --- Main entry point ---

(defun dispatch (argv)
  "Run one command, ending it with CLI-EXIT."
  (multiple-value-bind (command positionals options) (parse-args argv)
    (cond
      ((null command)
       (format t "~a~%" *help-text*)
       (cli-exit 2))
      ((string= command "help")
       (format t "~a~%" *help-text*)
       (cli-exit 0))
      ((string= command "version")
       (format t "sayable ~a~%" *cli-version*)
       (cli-exit 0))
      ((string= command "locales")
       (cmd-locales))
      ((string= command "age") (cmd-age positionals options))
      ((string= command "stage") (cmd-stage positionals options))
      ((string= command "date") (cmd-date positionals options))
      ((string= command "relative") (cmd-relative positionals options))
      ((string= command "time") (cmd-time positionals options))
      ((string= command "duration") (cmd-duration positionals options))
      ((string= command "since") (cmd-since positionals options))
      ((string= command "until") (cmd-until positionals options))
      (t
       (cli-error (format nil "unknown command '~a'" command))))))

(defun exit-code-of (argv)
  "Run one command and return the exit code it ends with."
  (catch 'cli-exit
    (dispatch argv)
    0))

(defun run-isolated (argv)
  "Run one command, returning (values exit-code stdout-text).
A crashed one-shot run exits 1, so a crash answers 1 and leaves the REPL serving."
  (let* ((code 1)
         (output (with-output-to-string (*standard-output*)
                   (handler-case (setf code (exit-code-of argv))
                     (error (e)
                       (format *error-output* "error: ~a~%" e))))))
    (values code output)))

(defun split-fields (line)
  "Split LINE on tabs, keeping empty fields."
  (loop for start = 0 then (1+ tab)
        for tab = (position #\Tab line :start start)
        collect (subseq line start tab)
        while tab))

(defun strip-carriage-return (line)
  (let ((end (length line)))
    (if (and (> end 0) (char= (char line (1- end)) #\Return))
        (subseq line 0 (1- end))
        line)))

(defun response-text (output)
  "OUTPUT without its trailing newline, inner newlines turned into tabs."
  (substitute #\Tab #\Newline (string-right-trim '(#\Newline) output)))

(defun repl ()
  "Answer one tab-separated request per stdin line (see cli/SPEC.md)."
  (loop for line = (read-line *standard-input* nil)
        while line
        do (multiple-value-bind (code output)
               (run-isolated (split-fields (strip-carriage-return line)))
             (format t "~d~c~a~%" code #\Tab (response-text output))
             (finish-output))))

(defun main ()
  (let ((argv (rest sb-ext:*posix-argv*)))
    (if (equal argv '("--repl"))
        (progn (repl) (sb-ext:exit :code 0))
        (sb-ext:exit :code (exit-code-of argv)))))

(main)

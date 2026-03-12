(in-package :sayable-duration)

;;; Load all generated locale files and the registry.

(eval-when (:load-toplevel :execute)
  (let* ((this-file (or *compile-file-pathname* *load-pathname*))
         (locales-dir (merge-pathnames "locales/" (directory-namestring this-file)))
         (all-files (sort (directory (merge-pathnames "*.lisp" locales-dir))
                          #'string< :key #'namestring)))
    ;; Load individual locale files first (skip registry.lisp)
    (dolist (file all-files)
      (unless (string= (pathname-name file) "registry")
        (load file)))
    ;; Load registry last so all locale variables are defined
    (let ((registry (merge-pathnames "registry.lisp" locales-dir)))
      (when (probe-file registry)
        (load registry)))))

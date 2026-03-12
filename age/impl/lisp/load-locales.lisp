(in-package :sayable-age)

;;; Load all generated locale files and the registry.
;;; When compiled via ASDF, the .fasl lives in a cache directory, so
;;; *load-pathname* at load time points away from the source tree.
;;; We resolve the locales directory relative to the source file using
;;; ASDF when available, falling back to *compile-file-pathname* or
;;; *load-pathname*.

(defun find-locales-dir ()
  "Locate the locales/ directory relative to this source file."
  (let ((base-dir (or (and (find-package :asdf)
                           (let ((system (funcall (intern "FIND-SYSTEM" :asdf)
                                                  "sayable-age" nil)))
                             (when system
                               (funcall (intern "SYSTEM-SOURCE-DIRECTORY" :asdf)
                                        system))))
                      (when *compile-file-pathname*
                        (directory-namestring *compile-file-pathname*))
                      (when *load-pathname*
                        (directory-namestring *load-pathname*)))))
    (when base-dir
      (merge-pathnames "locales/" base-dir))))

(eval-when (:load-toplevel :execute)
  (let* ((locales-dir (find-locales-dir))
         (all-files (when locales-dir
                      (sort (directory (merge-pathnames "*.lisp" locales-dir))
                            #'string< :key #'namestring))))
    ;; Load individual locale files first (skip registry.lisp)
    (dolist (file all-files)
      (unless (string= (pathname-name file) "registry")
        (load file)))
    ;; Load registry last so all locale variables are defined
    (when locales-dir
      (let ((registry (merge-pathnames "registry.lisp" locales-dir)))
        (when (probe-file registry)
          (load registry))))))

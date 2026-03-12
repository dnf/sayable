(defsystem "sayable-age"
  :version "0.5.0"
  :author "Don Neufeld"
  :license "MIT"
  :description "Human-friendly age formatting — how parents actually talk about little ones"
  :serial t
  :components
  ((:file "package")
   (:file "types")
   (:file "formatter")
   (:file "load-locales")))

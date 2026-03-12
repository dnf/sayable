#lang racket

(provide (struct-out duration-compactness-override)
         (struct-out duration-locale)
         resolve-unit)

;; Optional overrides for short/compact display modes.
;; #f fields mean "use the base locale value."
;; Fields: second minute hour day week month year half delimiter ago in-future
(struct duration-compactness-override
  (second minute hour day week month year half delimiter ago in-future)
  #:transparent)

;; All locale-specific data for duration formatting.
(struct duration-locale
  (code plural units half delimiter just-now ago in-future
   short-override compact-override)
  #:transparent)

;; Resolve a unit count to its display string using locale rules.
;; The half template supports two placeholders:
;;   {n} -- replaces the formatted number before unit substitution
;;   {0} -- wraps the fully resolved expression after unit substitution
;; When a half marker is applied, the plural category is forced to "other".
(define (resolve-unit count unit-forms locale [half ""])
  (let* ([base-n (number->string count)]
         ;; Apply {n}-style half marker to the number
         [n (if (and (not (equal? half ""))
                     (string-contains? half "{n}"))
                (string-replace half "{n}" base-n)
                base-n)]
         ;; Select template
         [template
          (let ([type (hash-ref unit-forms "type")])
            (if (equal? type "simple")
                (hash-ref unit-forms "form")
                (let* ([forms (hash-ref unit-forms "forms")]
                       [plural-fn (duration-locale-plural locale)]
                       ;; Half-marked values use "other" plural
                       [cat (if (equal? half "") (plural-fn count) "other")]
                       [tmpl (hash-ref forms cat #f)])
                  (or tmpl (hash-ref forms "other")))))]
         ;; Substitute {n} in template
         [result (string-replace template "{n}" n)])
    ;; Apply {0}-style half marker (wraps the whole expression)
    (if (and (not (equal? half ""))
             (string-contains? half "{0}"))
        (string-replace half "{0}" result)
        result)))

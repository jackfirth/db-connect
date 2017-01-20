#lang racket/base

(provide (for-label (all-from-out db
                                  db/connect
                                  racket/base
                                  racket/contract
                                  racket/tcp))
         db-connect-examples
         document-accessors
         source-code-link)

(require (for-label db
                    db/connect
                    racket/base
                    racket/contract
                    racket/tcp)
         scribble/example
         scribble/manual
         scribble/text
         syntax/parse/define)


(define (make-db-connect-eval)
  (make-base-eval #:lang 'racket/base
                  '(require db/connect
                            racket/class)
                  '(define connection% (class object% (super-new)))))

(define-simple-macro (db-connect-examples example:expr ...)
  (examples #:eval (make-db-connect-eval) example ...))

(define (source-code-link url-str)
  (begin/text "Source code for this library is avaible at " (url url-str)))

(define-simple-macro
  (document-accessors (config:id config?:expr [accessor:id contract:expr] ...+)
                      pre-flow ...+)
  (deftogether ((defproc (accessor [config config?]) contract) ...)
    pre-flow ...))

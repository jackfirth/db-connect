#lang info
(define collection "db")
(define deps '("base"))
(define scribblings '(("scribblings/main.scrbl" () (library) "db-connect")))
(define build-deps '("retry"
                     "db-doc"
                     "mock-rackunit"
                     "racket-doc"
                     "rackunit-lib"
                     "scribble-lib"
                     "scribble-text-lib"))

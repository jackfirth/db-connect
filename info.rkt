#lang info
(define collection "db")
(define scribblings '(("scribblings/main.scrbl" () (library) "db-connect")))
(define deps '("db-lib"
               "mock"
               "base"))
(define build-deps '("retry"
                     "db-doc"
                     "mock-rackunit"
                     "racket-doc"
                     "rackunit-lib"
                     "scribble-lib"
                     "scribble-text-lib"))

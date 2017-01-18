#lang racket/base

(require db)

(module+ test
  (require rackunit))


(struct postgresql-config
  (user database server port password)
  #:transparent
  #:omit-define-syntaxes
  #:constructor-name make-postgresql-config)

(define (postgresql-config #:user [user "postgres"]
                           #:database [database "public"]
                           #:server [server "localhost"]
                           #:port [port 5432]
                           #:password [password #f])
  (make-postgresql-config user database server port password))

(module+ test
  (check-equal? (postgresql-config)
                (make-postgresql-config
                 "postgres" "public" "localhost" 5432 #f)))

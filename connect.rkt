#lang racket/base

(require racket/contract)

(provide
 (contract-out
  [postgresql-config
   (->* ()
        (#:user string?
         #:database string?
         #:server string?
         #:port port-number?
         #:password (or/c string? #f))
        postgresql-config?)]
  [postgresql-config? predicate/c]
  [postgresql-config-user (-> postgresql-config? string?)]
  [postgresql-config-database (-> postgresql-config? string?)]
  [postgresql-config-server (-> postgresql-config? string?)]
  [postgresql-config-port (-> postgresql-config? port-number?)]
  [postgresql-config-password (-> postgresql-config? (or/c string? #f))]
  [postgresql-connect/config (-> postgresql-config? connection?)]))

(require db
         mock
         racket/tcp)

(module+ test
  (require mock/rackunit
           rackunit))


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

(define/mock (postgresql-connect/config config)
  #:opaque test-connection
  #:mock postgresql-connect #:with-behavior (const/kw test-connection)
  (postgresql-connect #:user (postgresql-config-user config)
                      #:database (postgresql-config-database config)
                      #:server (postgresql-config-server config)
                      #:port (postgresql-config-port config)
                      #:password (postgresql-config-password config)))

(module+ test
  (with-mocks postgresql-connect/config
    (define test-config
      (postgresql-config #:user "test-user"
                         #:database "test-database"
                         #:server "test.dns.address"
                         #:port 1234
                         #:password "testing password"))
    (check-equal? (postgresql-connect/config test-config) test-connection)
    (check-mock-calls postgresql-connect
                      (list (arguments #:user "test-user"
                                       #:database "test-database"
                                       #:server "test.dns.address"
                                       #:port 1234
                                       #:password "testing password")))))

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

(require (for-syntax racket/base)
         db
         mock
         racket/tcp
         syntax/parse/define)

(module+ test
  (require mock/rackunit
           rackunit))


(begin-for-syntax
  (define (identifier->keyword id-stx)
    (string->keyword (symbol->string (identifier-binding-symbol id-stx))))
  (define-syntax-class kw-field
    #:attributes ([kwarg-formals 1] id)
    (pattern id:id
             #:with id-kw (identifier->keyword #'id)
             #:attr [kwarg-formals 1] (list #'id-kw #'id))
    (pattern [id:id default:expr]
             #:with id-kw (identifier->keyword #'id)
             #:attr [kwarg-formals 1] (list #'id-kw #'[id default]))))

(define-simple-macro (struct/kw name:id (field:kw-field ...))
  (begin
    (struct name (field.id ...)
      #:transparent #:omit-define-syntaxes #:constructor-name make)
    (define (name field.kwarg-formals ... ...)
      (make field.id ...))))

(struct/kw postgresql-config
  ([user "postgres"]
   [database "public"]
   [server "localhost"]
   [port 5432]
   [password #f]))

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
    (check-equal? (postgresql-connect/config (postgresql-config))
                  test-connection)
    (check-mock-calls postgresql-connect
                      (list (arguments #:user "postgres"
                                       #:database "public"
                                       #:server "localhost"
                                       #:port 5432
                                       #:password #f)))))

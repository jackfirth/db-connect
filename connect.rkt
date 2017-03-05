#lang racket/base

(require racket/contract)

(provide
 (contract-out
  [mysql-config
   (->* ()
        (#:user string?
         #:database (or/c string? #f)
         #:server string?
         #:port port-number?
         #:password (or/c string? #f))
        mysql-config?)]
  [mysql-config? predicate/c]
  [mysql-config-user (-> mysql-config? string?)]
  [mysql-config-database (-> mysql-config? (or/c string? #f))]
  [mysql-config-server (-> mysql-config? string?)]
  [mysql-config-port (-> mysql-config? port-number?)]
  [mysql-config-password (-> mysql-config? (or/c string? #f))]
  [mysql-connect/config (-> mysql-config? connection?)]
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
  [postgresql-connect/config (-> postgresql-config? connection?)]
  [sqlite3-config
   (->* ()
        (#:database (or/c path-string? 'memory 'temporary)
         #:mode (or/c 'read-only 'read/write 'create)
         #:use-place? boolean?)
        sqlite3-config?)]
  [sqlite3-config? predicate/c]
  [sqlite3-config-database
   (-> sqlite3-config? (or/c path-string? 'memory 'temporary))]
  [sqlite3-config-mode
   (-> sqlite3-config? (or/c 'read-only 'read/write 'create))]
  [sqlite3-config-use-place? (-> sqlite3-config? boolean?)]
  [sqlite3-connect/config (-> sqlite3-config? connection?)]))

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

(struct/kw mysql-config
  ([user "mysql"] [database #f] [server "localhost"] [port 3306] [password #f]))

(define/mock (mysql-connect/config config)
  #:opaque test-connection
  #:mock mysql-connect #:with-behavior (const/kw test-connection)
  (mysql-connect #:user (mysql-config-user config)
                 #:database (mysql-config-database config)
                 #:server (mysql-config-server config)
                 #:port (mysql-config-port config)
                 #:password (mysql-config-password config)))

(module+ test
  (with-mocks mysql-connect/config
    (check-equal? (mysql-connect/config (mysql-config)) test-connection)
    (check-mock-calls mysql-connect
                      (list (arguments #:user "mysql"
                                       #:database #f
                                       #:server "localhost"
                                       #:port 3306
                                       #:password #f)))))

(struct/kw sqlite3-config
  ([database 'temporary] [mode 'read/write] [use-place? #f]))

(define/mock (sqlite3-connect/config config)
  #:opaque test-connection
  #:mock sqlite3-connect #:with-behavior (const/kw test-connection)
  (sqlite3-connect #:database (sqlite3-config-database config)
                   #:mode (sqlite3-config-mode config)
                   #:use-place (sqlite3-config-use-place? config)))

(module+ test
  (with-mocks sqlite3-connect/config
    (check-equal? (sqlite3-connect/config (sqlite3-config)) test-connection)
    (check-mock-calls sqlite3-connect
                      (list (arguments #:database 'temporary
                                       #:mode 'read/write
                                       #:use-place #f)))))

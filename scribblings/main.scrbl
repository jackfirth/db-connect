#lang scribble/manual
@(require "base.rkt")

@title{Preconfigured Database-Agnostic Connections}
@defmodule[db/connect #:packages ("db-connect")]
@author[@author+email["Jack Firth" "jackhfirth@gmail.com"]]

This library provides utilites for establishing database connections with the
@racketmodname[db] library. Connections can be constructed in terms of
configuration structs or database URLs instead of individual keyword parameters.
Retryers from the @racketmodname[retry] library are included for establishing
connections to databases that automatically handle temporary failure gracefully.
Additionally, connections and connection pools can be constructed automatically
from specific "well-known" environment variables.

@source-code-link{https://github.com/jackfirth/db-connect}

@section{API Reference}

@defproc[(postgresql-config [#:user user string? "postgres"]
                            [#:database database string? "public"]
                            [#:server server string? "localhost"]
                            [#:port port port-number? 5432]
                            [#:password password (or/c string? #f) #f])
         postgresql-config?]{
 Constructs a configuration value that can be used to connect to a PostgreSQL
 database using @racket[postgresql-connect/config]. Currently, connecting with
 TLS is not supported.
 @(db-connect-examples
   (postgresql-config #:server "db.server.com" #:port 1234))}

@defproc[(postgresql-config? [v any/c]) boolean?]{
 Returns true when @racket[v] is a PostgreSQL connection configuration value
 constructed by @racket[postgresql-config].
 @(db-connect-examples
   (postgresql-config? (postgresql-config))
   (postgresql-config? "angry lizard"))}

@document-accessors[
 (config postgresql-config?
         [postgresql-config-user string?]
         [postgresql-config-database string?]
         [postgresql-config-server string?]
         [postgresql-config-port port-number?]
         [postgresql-config-password (or/c string? #f)])]{
 Accessors for each of the fields of PostgreSQL connection configuration values.
 See @racket[postgresql-config] and @racket[postgresql-connect/config] for
 details on how these fields are used.
 @(db-connect-examples
   (postgresql-config-database (postgresql-config #:database "my-database")))}

@(define (local-sockets-secref)
   (secref "connecting-to-server" #:doc '(lib "db/scribblings/db.scrbl")))

@defproc[(postgresql-connect/config [config postgresql-config?]) connection?]{
 Like @racket[postgresql-connect] from @racketmodname[db], but a connection is
 established using the fields of the given @racket[config] object. Not all
 features of @racket[postgresql-connect] are supported; TLS connections cannot
 be established, notification handlers cannot be registered, and connections
 cannot be made over local sockets (see @local-sockets-secref[]).
 @(db-connect-examples
   (eval:alts (postgresql-connect (postgresql-config #:user "zoeytheadmin"
                                                     #:database "superdb"
                                                     #:server "db.zoey.com"
                                                     #:port 8257
                                                     #:password "hanshotfirst"))
              (new connection%)))}

@defproc[(mysql-config [#:user user string? "mysql"]
                       [#:database database (or/c string? #f) #f]
                       [#:server server string? "localhost"]
                       [#:port port port-number? 3306]
                       [#:password password (or/c string? #f) #f])
         mysql-config?]{
 Constructs a configuration value that can be used to connect to a MySQL
 database using @racket[mysql-connect/config]. Currently, connecting with
 TLS is not supported. Unlike @racket[mysql-connect], @racket[user] defaults to
 @racket["mysql"].
 @(db-connect-examples
   (mysql-config #:server "db.server.com" #:port 1234))}

@defproc[(mysql-config? [v any/c]) boolean?]{
 Returns true when @racket[v] is a MySQL connection configuration value
 constructed by @racket[mysql-config].
 @(db-connect-examples
   (mysql-config? (mysql-config))
   (mysql-config? "lethargic unicorn"))}

@document-accessors[
 (config mysql-config?
         [mysql-config-user string?]
         [mysql-config-database (or/c string? #f)]
         [mysql-config-server string?]
         [mysql-config-port port-number?]
         [mysql-config-password (or/c string? #f)])]{
 Accessors for each of the fields of MySQL connection configuration values. See
 @racket[mysql-config] and @racket[mysql-connect/config] for details on how
 these fields are used.
 @(db-connect-examples
   (mysql-config-port (mysql-config #:port 624)))}

@defproc[(mysql-connect/config [config mysql-config?]) connection?]{
 Like @racket[mysql-connect] from @racketmodname[db], but a connection is
 established using the fields of the given @racket[config] object. Not all
 features of @racket[mysql-connect] are supported; TLS connections cannot
 be established, notification handlers cannot be registered, and connections
 cannot be made over local sockets (see @local-sockets-secref[]).
 @(db-connect-examples
   (eval:alts (mysql-connect (mysql-config #:user "zoeytheadmin"
                                           #:database "superdb"
                                           #:server "db.zoey.com"
                                           #:port 8257
                                           #:password "hanshotfirst"))
              (new connection%)))}

@defproc[(sqlite3-config [#:database database
                          (or/c path-string? 'memory 'temporary) 'memory]
                         [#:mode mode (or/c 'read-only 'read/write 'create)
                          'read/write]
                         [#:use-place? use-place? boolean? #f])
         sqlite3-config?]{
 Constructs a configuration value that can be used to connect to a SQLite
 database using @racket[sqlite3-connect/config]. Unlike
 @racket[sqlite3-connect], @racket[database] defaults to @racket['memory].
 @(db-connect-examples
   (sqlite3-config #:database "/path/to/db.sqlite" #:mode 'read-only))}

@defproc[(sqlite3-config? [v any/c]) boolean?]{
 Returns true when @racket[v] is a SQLite connection configuration value
 constructed by @racket[sqlite3-config].
 @(db-connect-examples
   (sqlite3-config? (sqlite3-config))
   (sqlite3-config? "lethargic unicorn"))}

@document-accessors[
 (config sqlite3-config?
         [sqlite3-config-database (or/c path-string? 'memory 'temporary)]
         [sqlite3-config-mode (or/c 'read-only 'read/write 'create)]
         [sqlite3-config-use-place? boolean?])]{
 Accessors for each of the fields of sqlite connection configuration values. See
 @racket[sqlite3-config] and @racket[sqlite3-connect/config] for details on how
 these fields are used.
 @(db-connect-examples
   (sqlite3-config-mode (sqlite3-config #:mode 'create)))}

@defproc[(sqlite3-connect/config [config sqlite3-config?]) connection?]{
 Like @racket[sql3-connect] from @racketmodname[db], but a connection is
 established using the fields of the given @racket[config] object. Unlike
 @racket[sqlite3-connect], this procedure does not handle retries in the event
 of a busy connection. All connections are single-attempt only, leading to a
 high failure rate in the event of concurrent access.
 @(db-connect-examples
   (eval:alts (sqlite3-connect (sqlite3-config #:database "/data/mydb.sqlite"
                                               #:mode 'read
                                               #:use-place? #t))
              (new connection%)))}

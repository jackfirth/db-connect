#lang scribble/manual
@(require "base.rkt")

@title{Preconfigured Database-Agnostic Connections}
@defmodule[db/connect #:packages ("db-connect")]
@author[@author+email["Jack Firth" "jackhfirth@gmail.com"]]

This library provides utilites for establishing database connections with the
@racketmodname[db] library. Connections can be constructed in terms of option
structs or database URLs instead of individual keyword parameters. Retryers from
the @racketmodname[retry] library are included for establishing connections to
databases that automatically handle temporary failure gracefully. Additionally,
connections and connection pools can be constructed automatically from common
"well-known" environment variables.

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
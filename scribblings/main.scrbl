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

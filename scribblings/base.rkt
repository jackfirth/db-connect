#lang racket/base

(provide source-code-link)

(require scribble/manual
         scribble/text)


(define (source-code-link url-str)
  (begin/text "Source code for this library is avaible at " (url url-str)))

#lang racket

(require "dsl-parser.rkt" "dsl-translate.rkt" racket/sandbox)

(define dsl-file-loc (vector-ref (current-command-line-arguments) 0))
;;; (pretty-display dsl-file-loc)
(define dsl-source (open-input-string (file->string dsl-file-loc)))
;;; (pretty-display dsl-source)

(translate (dsl-parser (lex-this dsl-lexer dsl-source)))
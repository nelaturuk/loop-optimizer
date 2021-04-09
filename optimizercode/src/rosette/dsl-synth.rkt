#lang s-exp rosette
(require rosette/lib/match rosette/lib/angelic)

(define x (choose* 1 2 3))

;;; (pretty-display x)
(define sol (solve (assert (> x 0))))
(define val (evaluate x sol))
(printf "e1=~a \n" val)

(define ht (make-hash))

(struct SHIFTLEFT (arg0 arg1 arg2) #:transparent)
(struct UPDATERANGE (arg0 arg1 arg2) #:transparent)

(define (get-sym-var)
    (define-symbolic* var integer?)
    var)

(define (get-aux-cst var candidates)
    ;;; (define var (get-sym-var))
    (foldl (lambda (a result)
        (or result (= a var))) false candidates))

(define (??expr)
    (define ARRAY (apply choose* (list 4 5 6)))
    (define INT (apply choose* (list 7 8)))
    (define stmt (choose* (SHIFTLEFT ARRAY INT INT)
             (UPDATERANGE ARRAY ARRAY INT)))
    (define stmt_id (choose* (list 1 2)))
    (printf "stmt=~a, type=~a \n" stmt (boolean? stmt))
)

(define prog (??expr))
(pretty-display prog)

(define x2 (get-sym-var))
(define x1 (choose* 1 2))
(pretty-display x1)
(define soll (solve (assert (and (or (= x1 1) (= x1 2)) (= x2 x1)))))
(pretty-display soll)

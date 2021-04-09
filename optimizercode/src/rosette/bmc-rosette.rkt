#lang s-exp rosette

(require json rosette/query/debug racket/sandbox "solidity-parser.rkt" "inst.rkt")

;;; n is the length of the symbolic vector
(define (get-sym-vec name n)
  (list->vector
    (for/list ([i (range n)])
      (constant
        (format "~a@~a" name i) integer?))))
        ; (string->symbol (format "~a@~a" name i)) integer?))))

;;; Racket uninterpreted function to model transfer operation
(define-symbolic sym-transfer (~> integer? integer? integer?))

;;; Racket function to model array read
(define (sym-array-read base offset)
    ;;; (notice) first tell if the variables are symbolic or not before assertion
    (if (not (or (constant? offset) (term? offset) (expression? offset)))
        (if (or (< offset 0) (>= offset (vector-length base)))
            (begin
                (printf "invalid offset range: sat? = #t\n") ; programs not equal 
                (printf "got: ~a\n" offset)
                (exit 0)
            )
            (printf "")
        )
        (printf "")
    )
    ;;; if you pass the above without exitting, 
    ;;; then it's ok to issue the rosette assertions
    (assert (>= offset 0)) 
    (assert (< offset (vector-length base)))
    (vector-ref base offset) )

;;; Racket function to model array write
;;; return base[offset] (TMP: won't be used)
(define (sym-array-write base offset source)
    ;;; (notice) first tell if the variables are symbolic or not before assertion
    (if (not (or (constant? offset) (term? offset) (expression? offset)))
        (if (or (< offset 0) (>= offset (vector-length base)))
            (begin
                (printf "invalid offset range: sat? = #t\n") ; programs not equal 
                (printf "got: ~a\n" offset)
                (exit 0)
            )
            (printf "")
        )
        (printf "")
    )
    ;;; if you pass the above without exitting, 
    ;;; then it's ok to issue the rosette assertions
    (assert (>= offset 0)) 
    (assert (< offset (vector-length base)))
    ;;; no return value will be used
    (vector-set! base offset source)
)

(define parser (new solidity-parser%))

;;; Map names to symbolic variables
(define regs-out-1 (make-hash))
(define regs-out-2 (make-hash))

(define (gen-var-by-name name regs-out)
    (define var (constant name integer?))
    (if (hash-has-key? regs-out name)
        (hash-ref regs-out name)
        (begin
            (hash-set! regs-out name var)
            var))
)

;;; special method for flag variable
(define (gen-bool-by-name name regs-out)
    (define var (constant name boolean?))
    (if (hash-has-key? regs-out name)
        (hash-ref regs-out name)
        (begin
            (hash-set! regs-out name var)
            var))
)

;;; FIXME: change to larger constant later
(define fixed-vector-length 10)
(define (gen-vec-by-name name regs-out)
    (define var (get-sym-vec name fixed-vector-length))
    (if (hash-has-key? regs-out name)
        (hash-ref regs-out name)
        (begin
            (hash-set! regs-out name var)
            var)))

(define (check-equivalent input-json) 
    ;;; there could be multiple variables to check/verify
    ;;; (notice) assume the Python side has done necessary pre-checking
    ;;; e.g., at least 1 variable for checking
    ;;; e.g., all variables for checking should match
    ;;; e.g., they are in order
    ;;; ------ (important) -------
    ;;; Python side should preprocess to add program aware prefix
    ;;; e.g., CKPT_0 --> PROG1_CKPT_0
    ;;;       CKPT_0 --> PROG2_CKPT_0
    ;;; because rosette's `define-symbolic` is whatever global and can be defined twice
    ;;; e.g., (define-symbolic a integer?) refers to the same "a" symbolic variable
    ;;;       no matter where you define it, and you can do that multiple times without
    ;;;       triggering any exception
    (define outs-reg1 (hash-ref input-json `write1))
    (define outs-reg2 (hash-ref input-json `write2))
    (printf "--> outs-reg1: ~a \n" outs-reg1)
    (printf "--> outs-reg2: ~a \n" outs-reg2)

    (define insts-1 (hash-ref input-json `insts1))
    (define insts-2 (hash-ref input-json `insts2))

    (for ([cur-inst insts-1])
        (pretty-display cur-inst)
        (define inst-code (vector-ref (parse-code cur-inst) 0))
        (interpret-inst inst-code regs-out-1))

    ;;; (debug) print out all expressions
    (for ([i (in-range (length outs-reg1))])
        (define key-1 (list-ref outs-reg1 i))
        (printf "--> file1, ~a: \n" key-1)
        (printf "~a" (hash-ref regs-out-1 key-1))
        (printf "\n"))

    (for ([cur-inst insts-2])
        (pretty-display cur-inst)
        (define inst-code (vector-ref (parse-code cur-inst) 0))
        (interpret-inst inst-code regs-out-2))

    ;;; (debug) print out all expressions
    (for ([i (in-range (length outs-reg2))])
        (define key-2 (list-ref outs-reg2 i))
        (printf "--> file2, ~a: \n" key-2)
        (printf "~a" (hash-ref regs-out-2 key-2))
        (printf "\n"))

    ;;; (debug)
    (printf "--> regs1: \n~a \n" regs-out-1)
    (printf "--> regs2: \n~a \n" regs-out-2)
    (printf "--> asserts <---\n")
    (printf "~a \n" (asserts))


    ;;; start verification
    ;;; first construct the ultimate predicate
    (define upred
        (for/list ([i (in-range (length outs-reg1))])
            (equal? 
                (hash-ref regs-out-1 (list-ref outs-reg1 i)) 
                (hash-ref regs-out-2 (list-ref outs-reg2 i)) 
            )
        )
    )

    (printf "upred: ~a \n" upred)
    ;;; super solve with conjunction of all variables being equal
    (define ok (sat? (solve (assert (not (apply && upred))))))
    ; (define ok (sat? (solve (assert (not (equal? output1 output2))))))
    (printf "sat? = ~a \n" ok)
    (if ok "NEQ" "EQ")
)

(define (interpret-inst inst env)
    (define op-name (inst-op inst))
    (define args (inst-args inst))
    (printf "working=~a args=~a \n" op-name args)

    (define (assign)
        (define d (vector-ref args 1))
        (define a (vector-ref args 2))
        (define val (gen-var-by-name a env))
        (hash-set! env d val))
        ; (ref-hash-set! env d val))

    (define (assign#)
        (define d (vector-ref args 1))
        (define a (vector-ref args 2))
        (define val (string->number a))
        (hash-set! env d val))
        ; (ref-hash-set! env d val))

    (define (array-read)
        (define d (vector-ref args 1))
        (define base (vector-ref args 2))
        (define offset (vector-ref args 3))
        (define base-val (gen-vec-by-name base env))
        (define offset-val (gen-var-by-name offset env))
        (define val (sym-array-read base-val offset-val))
        (hash-set! env d val)
    )

    (define (array-write)
        (define d (vector-ref args 1))
        (define base (vector-ref args 2))
        (define offset (vector-ref args 3))
        (define source (vector-ref args 4))
        (define base-val (gen-vec-by-name base env))
        (define offset-val (gen-var-by-name offset env))
        (define source-val (gen-var-by-name source env))
        ;;; d won't be used, so no need to set it
        (sym-array-write base-val offset-val source-val)
    )

    (define (array-write#)
        (define d (vector-ref args 1))
        (define base (vector-ref args 2))
        (define offset (vector-ref args 3))
        (define source (vector-ref args 4))
        (define base-val (gen-vec-by-name base env))
        (define offset-val (gen-var-by-name offset env))
        (define source-val (string->number source))
        ;;; d won't be used, so no need to set it
        (sym-array-write base-val offset-val source-val)
    )

    (define (binary-op#rr op)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define a1-val (gen-var-by-name a1 env))
        (define a2-val (gen-var-by-name a2 env))
        (define val (op a1-val a2-val))
        (hash-set! env d val))

    (define (binary-op#rn op)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define a1-val (gen-var-by-name a1 env))
        (define val (op a1-val (string->number a2)))
        (hash-set! env d val))

    (define (binary-op#nr op)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define a2-val (gen-var-by-name a2 env))
        (define val (op (string->number a1) a2-val))
        (hash-set! env d val))

    (define (binary-op#nn op)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define val (op (string->number a1) (string->number a2)))
        (hash-set! env d val))

    (define (unary-op op)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a1-val (gen-var-by-name a1 env))
        (define val (op a1-val))
        (hash-set! env d val))

    (define (unary-op# op)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define val (op (string->number a1)))
        (hash-set! env d val))

    ;;; require
    (define (rq)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a1-val (gen-var-by-name a1 env))
        ;;; special trick for assert verification
        ;;; define separate d-val for different programs
        ;;; (important) don't use gen-var, use the special gen-bool
        ;;; flags must be bool so that they can be correctly process by rosette
        ;;; (notice) the names of d are made different in the Python side already
        (define d-val (gen-bool-by-name d env))
        (if (integer? a1-val)
            (begin
                (if (not (or (constant? a1-val) (term? a1-val) (expression? a1-val)))
                    (if (not (or (equal? a1-val 0) (equal? a1-val 1)))
                        (begin
                            (printf "incompatible integer for require: sat? = #t\n") ; programs not equal 
                            (printf "got: ~a\n" a1-val)
                            (exit 0)
                        )
                        (printf "")
                    )
                    (printf "")
                )
                (if (equal? a1-val 1)
                    ; either one will be captured by rosette assertion store
                    (assert d-val)
                    (assert (not d-val))
                )
            )
            ;;; else, it's boolean
            (begin
                (if a1-val
                    ; either one will be captured by rosette assertion store
                    (assert d-val)
                    (assert (not d-val))
                )
            )
        )
        (hash-set! env d d-val)
    )

    ;;; logical not
    (define (logical-not x)
        (if (not (or (constant? x) (term? x) (expression? x)))
            (if (not (or (equal? x 0) (equal? x 1)))
                (begin
                    (printf "incompatible integer for logical-not: sat? = #t\n") ; programs not equal 
                    (printf "got: ~a\n" x)
                    (exit 0)
                )
                (printf "")
            )
            (printf "")
        )
        (assert (or (equal? x 0) (equal? x 1)))
        (list-ref (list 1 0) x)
    )

    ;;; transfer series
    ;;; the names of d should be kept the same and put into
    (define (transfer#rr)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define a1-val (gen-var-by-name a1 env))
        (define a2-val (gen-var-by-name a2 env))
        (define val (sym-transfer a1-val a2-val))
        (hash-set! env d val)
    )

    (define (transfer#rn)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define a1-val (gen-var-by-name a1 env))
        (define val (sym-transfer a1-val (string->number a2)))
        (hash-set! env d val)
    )

    (define (transfer#nr)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define a2-val (gen-var-by-name a2 env))
        (define val (sym-transfer (string->number a1) a2-val))
        (hash-set! env d val)
    )

    (define (transfer#nn)
        (define d (vector-ref args 1))
        (define a1 (vector-ref args 2))
        (define a2 (vector-ref args 3))
        (define val (sym-transfer (string->number a1) (string->number a2)))
        (hash-set! env d val)
    )

    (cond
         ; [(equal? op-name "nop")   (void)]

         [(equal? op-name "add#rr")   (binary-op#rr +)]
         [(equal? op-name "add#rn")   (binary-op#rn +)]
         [(equal? op-name "add#nr")   (binary-op#nr +)]
         [(equal? op-name "add#nn")   (binary-op#nn +)]

         [(equal? op-name "sub#rr")   (binary-op#rr -)]
         [(equal? op-name "sub#rn")   (binary-op#rn -)]
         [(equal? op-name "sub#nr")   (binary-op#nr -)]
         [(equal? op-name "sub#nn")   (binary-op#nn -)]

         [(equal? op-name "mul#rr")   (binary-op#rr *)]
         [(equal? op-name "mul#rn")   (binary-op#rn *)]
         [(equal? op-name "mul#nr")   (binary-op#nr *)]
         [(equal? op-name "mul#nn")   (binary-op#nn *)]

         [(equal? op-name "div#rr")   (binary-op#rr /)]
         [(equal? op-name "div#rn")   (binary-op#rn /)]
         [(equal? op-name "div#nr")   (binary-op#nr /)]
         [(equal? op-name "div#nn")   (binary-op#nn /)]

         [(equal? op-name "assign#") (assign#)]
         [(equal? op-name "assign") (assign)]

         [(equal? op-name "lt#rr") (binary-op#rr <)]
         [(equal? op-name "lt#rn") (binary-op#rn <)]
         [(equal? op-name "lt#nr") (binary-op#nr <)]
         [(equal? op-name "lt#nn") (binary-op#nn <)]

         [(equal? op-name "lte#rr") (binary-op#rr <=)]
         [(equal? op-name "lte#rn") (binary-op#rn <=)]
         [(equal? op-name "lte#nr") (binary-op#nr <=)]
         [(equal? op-name "lte#nn") (binary-op#nn <=)]

         [(equal? op-name "gt#rr") (binary-op#rr >)]
         [(equal? op-name "gt#rn") (binary-op#rn >)]
         [(equal? op-name "gt#nr") (binary-op#nr >)]
         [(equal? op-name "gt#nn") (binary-op#nn >)]

         [(equal? op-name "gte#rr") (binary-op#rr >=)]
         [(equal? op-name "gte#rn") (binary-op#rn >=)]
         [(equal? op-name "gte#nr") (binary-op#nr >=)]
         [(equal? op-name "gte#nn") (binary-op#nn >=)]

         [(equal? op-name "eq#rr") (binary-op#rr equal?)]
         [(equal? op-name "eq#rn") (binary-op#rn equal?)]
         [(equal? op-name "eq#nr") (binary-op#nr equal?)]
         [(equal? op-name "eq#nn") (binary-op#nn equal?)]

         [(equal? op-name "neq#rr") (binary-op#rr (lambda (x y) (not (equal? x y))))]
         [(equal? op-name "neq#rn") (binary-op#rn (lambda (x y) (not (equal? x y))))]
         [(equal? op-name "neq#nr") (binary-op#nr (lambda (x y) (not (equal? x y))))]
         [(equal? op-name "neq#nn") (binary-op#nn (lambda (x y) (not (equal? x y))))]

         [(equal? op-name "array-read") (array-read)]
         [(equal? op-name "array-write") (array-write)]
         [(equal? op-name "array-write#") (array-write#)]

         [(equal? op-name "require") (rq)] ; use rq to avoid keyword require
         ;;; (special note) 
         ;;; since we are using integer to model boolean
         ;;; only 1 and 0 are valid, the `logical-not` method is implemented as a special method
         ;;; to deal with boolean-like integer operation
         [(equal? op-name "not") (unary-op logical-not)]
         [(equal? op-name "not#") (unary-op# logical-not)]

         [(equal? op-name "transfer#rr") (transfer#rr)]
         [(equal? op-name "transfer#rn") (transfer#rn)]
         [(equal? op-name "transfer#nr") (transfer#nr)]
         [(equal? op-name "transfer#nn") (transfer#nn)]

         [else (assert #f (format "simulator: undefine instruction ~a" op-name))])
)

(define (parse-code inst-str)
    (define code
        (with-handlers ([(lambda (v) #t) (lambda (v) 'parser-error)])
            (send parser ir-from-string inst-str)))
            code)

;;; Uncomment this if you want to test bmc separately.
;;; (define json-obj (call-with-input-file "eq.json" read-json))

;;; Default integration point with python.
(define cmd (current-command-line-arguments))
(define json-obj (string->jsexpr (vector-ref cmd 0)))


;;; (pretty-display "debugging interface...........")
;;; (pretty-display cmd)
;;; (pretty-display json-obj)
(check-equivalent json-obj)
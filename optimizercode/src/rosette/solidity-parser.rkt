#lang racket

(require parser-tools/lex
         (prefix-in re- parser-tools/lex-sre)
         parser-tools/yacc
	 "parser.rkt" "inst.rkt")

(provide solidity-parser%)

;; This is a Racket Lex Yacc parser.
;; Refer to the follow resources to complete this file.
;; - Lexer:   http://docs.racket-lang.org/parser-tools/Lexers.html
;; - Parser:  http://docs.racket-lang.org/parser-tools/LALR_1__Parsers.html
;; - Example: https://gist.github.com/danking/1068185
(define solidity-parser%
  (class parser%
    (super-new)
    (inherit-field asm-parser asm-lexer)
    (init-field [compress? #f])
    
    (define-tokens a (VAR WORD NUM REG)) ;; add more tokens
    ; (define-empty-tokens b (EOF EQ HOLE BLOCKHASH EQCMP COMMA CREATE THROW THROWI NOP LOG BALANCE ISZERO SGT GT SLT LT SHA3 DELEGATECALL CALLCODE CALL NOT OR
    ;                         SELFDESTRUCT MSIZE NUMBER CALLDATACOPY CODECOPY SUB TIMESTAMP EXP DIV RETURNDATACOPY MUL AND ADD REVERT RETURNDATASIZE
    ;                         CODESIZE EXTCODECOPY MOD XOR DIFFICULTY BYTE ARRAY-READ ARRAY-WRITE
    ;                         RETURN COLON ORIGIN CALLVALUE JUMP EXTCODESIZE JUMPI SLP LC RC LP RP ADDRESS CALLDATASIZE CALLDATALOAD)) ;; add more tokens
    (define-empty-tokens b (EOF ASSIGN LT LTE GT GTE EQ NEQ SUB ADD MUL DIV ARRAY-READ ARRAY-WRITE COLON REQUIRE TRANSFER NOT
                            )) ;; add more tokens

    (define-lex-abbrevs
      (digit10 (char-range "0" "9"))
      (number10 (number digit10))
      (snumber10 (re-or number10 (re-seq "-" number16)))
      (number16 (re-or (char-range "0" "9") (char-range "a" "f")))

      (snumber16 (re-+ "0x" number16))



      ;;; FIXME: added "." to model `id.id` as a separate identifier
      (identifier-characters (re-or (char-range "A" "Z") (char-range "a" "z") "_" ".")) 
      ;;; (identifier-characters-ext (re-* (re-or digit10 identifier-characters "_")))
      ;;; (identifier (re-+ identifier-characters))
      ;;; (identifier (re-+ identifier-characters))

      (identifier (re-seq identifier-characters 
                          (re-* (re-or identifier-characters digit10))))
      ;;; (var (re-: "%" (re-+ (re-or identifier-characters digit10))))
      ;;; (var (re-+ (re-or identifier-characters digit10)))

      ;;; (reg (re-seq (re-or "V" "S") number10))

      )

    ;; Complete lexer
    (set! asm-lexer
      (lexer-src-pos
       ; ? ;; add more tokens
       (":"         (token-COLON))

       ("ADD"       (token-ADD))
       ("SUB"       (token-SUB))
       ("MUL"       (token-MUL))
       ("DIV"       (token-DIV))

       ("ARRAY-READ" (token-ARRAY-READ))
       ("ARRAY-WRITE" (token-ARRAY-WRITE))

       ("="         (token-ASSIGN))
       ("LT"         (token-LT))
       ("LTE"         (token-LTE))
       ("GT"          (token-GT))
       ("GTE"          (token-GTE))
       ("EQ"            (token-EQ))
       ("NEQ"           (token-NEQ))

       ("REQUIRE"   (token-REQUIRE))
       ("TRANSFER"   (token-TRANSFER))
       ("NOT"   (token-NOT))

       (identifier   (token-REG lexeme))
       (snumber10   (token-NUM lexeme))
       (snumber16   (token-NUM lexeme))
       (identifier  (token-WORD lexeme))
       (identifier   (token-VAR lexeme))
       (whitespace   (position-token-token (asm-lexer input-port)))
       ((eof) (token-EOF))))

    ;; Complete parser
    (set! asm-parser
      (parser
       (start program)
       (end EOF)
       (error
        (lambda (tok-ok? tok-name tok-value start-pos end-pos)
          (raise-syntax-error 'parser
                              (format "syntax error at '~a' in src l:~a c:~a"
                                      tok-name
                                      (position-line start-pos)
                                      (position-col start-pos)))))
       (tokens a b)
       (src-pos)
       (grammar

        ; ? ;; add more grammar rules
        ;;; (arg  ((REG) $1)
        ;;;       ((NUM) $1))

        ;;; (args ((arg) (list $1))
        ;;;       ((arg args) (cons $1 $2))
        ;;;       ((arg COMMA args) (cons $1 $3)))
        (instruction
          ;;; ((NUM COLON WORD args)    (inst $3 (list->vector $4)))
          ;;; when parsing ?, return (inst #f #f) as an unknown instruction
          ;;; (a place holder for synthesis)
          ;;; ((HOLE)         (inst #f #f))


          ((NUM COLON REG ASSIGN SUB REG REG) (inst "sub#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN SUB REG NUM) (inst "sub#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN SUB NUM REG) (inst "sub#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN SUB NUM NUM) (inst "sub#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN ADD REG REG) (inst "add#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN ADD REG NUM) (inst "add#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN ADD NUM REG) (inst "add#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN ADD NUM NUM) (inst "add#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN MUL REG REG) (inst "mul#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN MUL REG NUM) (inst "mul#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN MUL NUM REG) (inst "mul#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN MUL NUM NUM) (inst "mul#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN DIV REG REG) (inst "div#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN DIV REG NUM) (inst "div#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN DIV NUM REG) (inst "div#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN DIV NUM NUM) (inst "div#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN NUM) (inst "assign#" (vector $1 $3 $5)))
          ((NUM COLON REG ASSIGN REG) (inst "assign" (vector $1 $3 $5)))

          ((NUM COLON REG ASSIGN LT REG REG) (inst "lt#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN LT REG NUM) (inst "lt#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN LT NUM REG) (inst "lt#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN LT NUM NUM) (inst "lt#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN LTE REG REG) (inst "lte#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN LTE REG NUM) (inst "lte#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN LTE NUM REG) (inst "lte#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN LTE NUM NUM) (inst "lte#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN GT REG REG) (inst "gt#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN GT REG NUM) (inst "gt#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN GT NUM REG) (inst "gt#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN GT NUM NUM) (inst "gt#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN GTE REG REG) (inst "gte#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN GTE REG NUM) (inst "gte#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN GTE NUM REG) (inst "gte#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN GTE NUM NUM) (inst "gte#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN EQ REG REG) (inst "eq#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN EQ REG NUM) (inst "eq#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN EQ NUM REG) (inst "eq#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN EQ NUM NUM) (inst "eq#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN NEQ REG REG) (inst "neq#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN NEQ REG NUM) (inst "neq#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN NEQ NUM REG) (inst "neq#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN NEQ NUM NUM) (inst "neq#nn" (vector $1 $3 $6 $7)))

          ((NUM COLON REG ASSIGN ARRAY-READ REG REG) (inst "array-read" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN ARRAY-WRITE REG REG REG) (inst "array-write" (vector $1 $3 $6 $7 $8)))
          ((NUM COLON REG ASSIGN ARRAY-WRITE REG REG NUM) (inst "array-write#" (vector $1 $3 $6 $7 $8)))

          ((NUM COLON REG ASSIGN REQUIRE REG) (inst "require" (vector $1 $3 $6)))
          ((NUM COLON REG ASSIGN NOT REG) (inst "not" (vector $1 $3 $6)))
          ((NUM COLON REG ASSIGN NOT NUM) (inst "not#" (vector $1 $3 $6)))

          ;;; (notice) both arguments of transfer can be either var or const
          ((NUM COLON REG ASSIGN TRANSFER REG REG) (inst "transfer#rr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN TRANSFER REG NUM) (inst "transfer#rn" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN TRANSFER NUM REG) (inst "transfer#nr" (vector $1 $3 $6 $7)))
          ((NUM COLON REG ASSIGN TRANSFER NUM NUM) (inst "transfer#nn" (vector $1 $3 $6 $7)))

         ) 
        
        (code   
         (() (list))
         ((instruction code) (cons $1 $2)))

        (program
         ((code) (list->vector $1)))
       )))


    ;;;;;;;;;;;;;;;;;;;;;;;;; For cooperative search ;;;;;;;;;;;;;;;;;;;;;;;
    #|
    ;; Required method if using cooperative search driver.
    ;; Read from file and convert file content into the format we want.
    ;; Info usually includes live-out information.
    ;; It can also contain extra information such as precondition of the inputs.
    (define/override (info-from-file file)
      ? ;; modify this function

      ;; Example
      ;; read from file
      (define lines (file->lines file))
      (define live-out (string-split (first lines) ","))
      live-out)
    |#

    ))


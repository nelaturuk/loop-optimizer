#lang racket
(require parser-tools/lex
         (prefix-in re- parser-tools/lex-sre)
         parser-tools/yacc
         "inst.rkt")

(provide (all-defined-out))

(define-tokens a (NUM VAR))
(define-empty-tokens b (+ - * EOF UPDATERANGE SHIFTLEFT SUM MUL SUB MAP COPYRANGE RB LB COLON LAMBDA COMMA))
(define-lex-trans number
  (syntax-rules ()
    ((_ digit)
     (re-: (re-? (re-or "-" "-")) (uinteger digit)
           (re-? (re-: "." (re-? (uinteger digit))))))))
(define-lex-trans uinteger
  (syntax-rules ()
    ((_ digit) (re-+ digit))))

(define-lex-abbrevs
  (digit10 (char-range "0" "9"))
  (number10 (number digit10))
  (identifier-characters (re-or (char-range "A" "z") (char-range "0" "9")
                                "?" "!" "$" "%" "^" "&" "." "-"))
  (identifier (re-+ identifier-characters)))

(define dsl-lexer
           (lexer
            ((re-+ number10) (token-NUM (string->number lexeme)))
            ("-" (token--))
            ("+" (token-+))
            ("*" (token-*))
            ("(" (token-LB))
            (")" (token-RB))
            ("," (token-COMMA))
            (":" (token-COLON))
            ("λ" (token-LAMBDA))
            ("lambda" (token-LAMBDA))
            ("UPDATERANGE" (token-UPDATERANGE))
            ("SHIFTLEFT" (token-SHIFTLEFT))
            ("SUM" (token-SUM))
            ("MUL" (token-MUL))
            ("SUB" (token-SUB))
            ("COPYRANGE" (token-COPYRANGE))
            ("MAP" (token-MAP))
            (identifier  (token-VAR lexeme))
            ;; recursively calls the lexer which effectively skips whitespace
            (whitespace (dsl-lexer input-port))
            ((eof) (token-EOF))))

(define dsl-parser
           (parser
            (start code)
            (end EOF)
            (error void)
            (tokens a b)
            (precs (left - +))
            (grammar
            ;;;  idx is a bad name
             (idx ((NUM) $1)
                  ((VAR) $1)
                  ((idx + idx) (string-append $1 "+" (~v $3)))
                  ((idx - idx) (string-append $1 "-" (~v $3)))
                  ((idx * idx) (string-append $1 "*" (~v $3)))
                  )
             (exp ((NUM) $1)
                  ;;; updateRange(target, container, val)
                  ((UPDATERANGE LB VAR COMMA VAR COMMA VAR RB) (inst "UPDATERANGE" (vector $3 $5 $7)))
                  ;;; shiftLeft(org, startIdx, endIdx)
                  ((SHIFTLEFT LB VAR COMMA VAR COMMA idx RB) (inst "SHIFTLEFT" (vector $3 $5 $7)))

                  ;;; sum(cumulate, target, startIdx, endIdx)
                  ((SUM LB VAR COMMA VAR COMMA idx COMMA idx RB) (inst "SUM" (vector $3 $5 $7 $9)))

                  ((MUL LB VAR COMMA VAR COMMA idx COMMA idx RB) (inst "MUL" (vector $3 $5 $7 $9)))
                  
                  ((SUB LB VAR COMMA VAR COMMA idx COMMA idx RB) (inst "SUB" (vector $3 $5 $7 $9)))

                  ((SUM LB VAR COMMA VAR COMMA idx COMMA idx COMMA LAMBDA VAR COLON idx RB) (inst "SUM-λ" (vector $3 $5 $7 $9 $12 $14)))

                  ;;; CopyRange(Src, srcStart, srcEnd, trgt, tgtStart, tgtEnd)
                  ((COPYRANGE LB VAR COMMA idx COMMA idx COMMA VAR COMMA idx COMMA idx RB) (inst "COPYRANGE" (vector $3 $5 $7 $9 $11 $13)))
                  ;;; COPYRANGE(index2groupName, 1, _groupsCount+1, _groups, 0, _groupsCount)

                  ;;; FIXME: only support one argument for now
                  ;;; COPYRANGE(lockTime[_address], i0, lockNum[_address], tempLockTime, i0, lockNum[address], λ arg: arg+later-earlier)
                  ((COPYRANGE LB VAR COMMA idx COMMA idx COMMA VAR COMMA idx COMMA idx COMMA LAMBDA VAR COLON idx RB) 
                                                  (inst "COPYRANGE-λ" (vector $3 $5 $7 $9 $11 $13 $16 $18)))

                  ;;; map(tgt, startIdx, endIdx, val)
                  ((MAP LB VAR COMMA idx COMMA idx COMMA idx RB) (inst "MAP" (vector $3 $5 $7 $9)))


                  ;;; incRange(a,range1,b, range2): b[j] += a[i] for i in range1 and j in range2 
                  ;;; INCREMENTRANGE(playerValue, 0, 12, Bettors[0].betsVAlue, 0, 12)

                  ;;; UPDATERANGEWithfunction(minerAddress, minerTokens, minerRewardToeksn, \lamdba (v, i). v + minerRewardTokens[i])

                  ((exp + exp) (+ $1 $3))
                  ((exp - exp) (- $1 $3))
              )

            ;;; Each code contains multiple expressions.
            (code   
                  (() (list))
                  ((exp code) (cons $1 $2)))
            )))

(define (lex-this lexer input) (lambda () (lexer input)))
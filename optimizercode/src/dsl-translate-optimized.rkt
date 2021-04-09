#lang racket
(require "inst.rkt")

(provide (all-defined-out))

;;; pragma solidity ^0.5.10;

;;; contract C {
    
;;;     mapping (address => uint256[]) private lockTime;
;;;     mapping (address => uint256[]) private tempLockTime;
;;;     mapping (address => uint256) private lockNum;
;;;     uint later = 1;
;;;     uint earlier = 2;

;;;     function foo(address _address) public {

;;;         //uint256[] memory tempLockTime = new uint256[](lockNum[_address]);
;;; 	for (uint i = 0; i < lockNum[_address]; ++i) {
;;; 	      tempLockTime[_address][i] = lockTime[_address][i] + later-earlier;
;;; 	}

;;;     }
;;; }

(define contract-template "
pragma solidity ^0.5.10;

contract C {
    
    mapping (address => uint256[]) private _storage1;
    mapping (address => uint256[]) private _storage2;
    mapping (address => uint256) private _storage3;
    uint256 cumulate;

    _body
}
")

;;; (pretty-display contract-template)

(define (generate-updaterange args)
  ;;; target
  (define arg0 (vector-ref args 0))
  ;;; container
  (define arg1 (vector-ref args 1))
  ;;; value
  (define arg2 (vector-ref args 2))

  (define template "
  function foo() public {
    bool rvariable = val; 
    uint loopcondition = addresses.length;
    foo_for(rvariable, loopcondition);
  }

  function foo_for(bool rvariable, uint loopcondition) internal {
  for (uint i = 0; i < loopcondition; i++) {
    container[addresses[i]] = rvariable;
   }
  }
  ")
  (define loop-body (string-replace 
    (string-replace 
      (string-replace template "addresses" arg0) 
                               "container" arg1) 
                               "val" arg2))
  (pretty-display (string-replace (string-replace (string-replace contract-template "_body" loop-body) "_storage1" arg1) "_args" arg0))
)


(define (generate-shiftleft args)
  ;;; org
  (define arg0 (vector-ref args 0))
  ;;; startIdx
  (define arg1 (vector-ref args 1))
  ;;; endIdx
  (define arg2 (vector-ref args 2))

  (define template "
    for(uint i=startIdx; i < endIdx;i++){
      addresses[i] = addresses[i+1];
    }
  ")
  (pretty-display (string-replace 
    (string-replace 
      (string-replace template "addresses" arg0) 
                               "startIdx" arg1) 
                               "endIdx" arg2)))

(define (generate-sum args)
  ;;; cum
  (define arg0 (vector-ref args 0))
  ;;; org
  (define arg1 (vector-ref args 1))
  ;;; startIdx
  (define arg2 (vector-ref args 2))
  ;;; endIdx
  (define arg3 (vector-ref args 3))

  (define template "
    function foo() public {
    uint initial = startIdx;
    uint initialSum = cumulate; 
    uint loopcondition = endIdx;
    cumulate = foo_for(initial, initialSum, loopcondition);
  }

  function foo_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total + addresses[i];
    }
    return temp_total;
  }  
    
  ")

  (define loop-body (string-replace 
    (string-replace 
    (string-replace 
      (string-replace template "cumulate" arg0)
                               "addresses" arg1) 
                               "startIdx" (if (number? arg2) (number->string arg2) arg2)) 
                               "endIdx" arg3))

  (pretty-display (string-replace (string-replace (string-replace contract-template "_body" loop-body) "cumulate" arg0) "_args" arg0))
  )

(define (generate-mul args)
  ;;; cum
  (define arg0 (vector-ref args 0))
  ;;; org
  (define arg1 (vector-ref args 1))
  ;;; startIdx
  (define arg2 (vector-ref args 2))
  ;;; endIdx
  (define arg3 (vector-ref args 3))

  (define template "
    function foo() public {
    uint initial = startIdx;
    uint initialSum = cumulate; 
    uint loopcondition = endIdx;
    cumulate = foo_for(initial, initialSum, loopcondition);
  }

  function foo_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total * addresses[i];
    }
    return temp_total;
  }  
    
  ")

  (define loop-body (string-replace 
    (string-replace 
    (string-replace 
      (string-replace template "cumulate" arg0)
                               "addresses" arg1) 
                               "startIdx" (if (number? arg2) (number->string arg2) arg2)) 
                               "endIdx" arg3))

  (pretty-display (string-replace (string-replace (string-replace contract-template "_body" loop-body) "cumulate" arg0) "_args" arg0))
  )

(define (generate-sub args)
  ;;; cum
  (define arg0 (vector-ref args 0))
  ;;; org
  (define arg1 (vector-ref args 1))
  ;;; startIdx
  (define arg2 (vector-ref args 2))
  ;;; endIdx
  (define arg3 (vector-ref args 3))

  (define template "
    function foo() public {
    uint initial = startIdx;
    uint initialSum = cumulate; 
    uint loopcondition = endIdx;
    cumulate = foo_for(initial, initialSum, loopcondition);
  }

  function foo_for(uint initial, uint initialSum, uint loopcondition) internal returns (uint) {
    uint temp_total = initialSum;
    for(uint i=initial; i < loopcondition;i++){
      temp_total = temp_total - addresses[i];
    }
    return temp_total;
  }  
    
  ")

  (define loop-body (string-replace 
    (string-replace 
    (string-replace 
      (string-replace template "cumulate" arg0)
                               "addresses" arg1) 
                               "startIdx" (if (number? arg2) (number->string arg2) arg2)) 
                               "endIdx" arg3))

  (pretty-display (string-replace (string-replace (string-replace contract-template "_body" loop-body) "cumulate" arg0) "_args" arg0))
  )


(define (generate-sum-λ args)
  ;;; cum
  (define arg0 (vector-ref args 0))
  ;;; org
  (define arg1 (vector-ref args 1))
  ;;; startIdx
  (define arg2 (vector-ref args 2))
  ;;; endIdx
  (define arg3 (vector-ref args 3))
  ;;; argument
  (define arg4 (vector-ref args 4))
    ;;; body
  (define arg5 (vector-ref args 5))

  (set! arg5 (string-replace arg5 "\"" ""))

  (define rhs-expr (string-replace arg5 arg4 "addresses[i]"))

  (define template "
    uint cumulate = 0;
    for(uint i=startIdx; i < endIdx;i++){
      cumulate = cumulate.add(addresses[i]);
    }
  ")
  (pretty-display (string-replace 
    (string-replace 
    (string-replace 
    (string-replace 
      (string-replace template "cumulate" arg0)
                               "addresses[i]" rhs-expr)
                               "addresses" arg1) 
                               "startIdx" (if (number? arg2) (number->string arg2) arg2)) 
                               "endIdx" arg3)))

(define (generate-map args)
  ;;; org
  (define arg0 (vector-ref args 0))
  ;;; startIdx
  (define arg1 (vector-ref args 1))
  ;;; endIdx
  (define arg2 (vector-ref args 2))
  ;;; value 
  (define arg3 (vector-ref args 3))

  (define template "
    function foo() public {
    bool rvariable = val; 
    uint initial = startIdx;
    uint loopcondition = endIdx;
    foo_for(rvariable, initial, loopcondition);
  }

  function foo_for(bool rvariable, uint initial, uint loopcondition) internal {
  for (uint i = initial; i < loopcondition; i++) {
    addresses[i] = rvariable;
   }
  }
    
  ")

  (define loop-body (string-replace 
    (string-replace 
    (string-replace 
      (string-replace template "addresses" arg0)
                               "endIdx" arg2) 
                               "startIdx" (if (number? arg1) (number->string arg1) arg1)) 
                               "val" (if (number? arg3) (number->string arg3) arg3)))

  (pretty-display (string-replace (string-replace (string-replace contract-template "_body" loop-body) "_storage1" arg0) "_args" arg0))
  )
  
      

(define (generate-copyrange args)
  ;;; CopyRange(Src, srcStart, srcEnd, tgt, tgtStart, tgtEnd)
  ;;; src
  (define arg0 (vector-ref args 0))
  ;;; srcStart
  (define arg1 (vector-ref args 1))
  ;;; srcEnd
  (define arg2 (vector-ref args 2))
  ;;; tgt
  (define arg3 (vector-ref args 3))
  ;;; tgtStart
  (define arg4 (vector-ref args 4))
  ;;; tgtEnd
  (define arg5 (vector-ref args 5))

  (define template "
    function foo() public {
    uint initial = tgtStart;
    uint mapstart = srcStart;
    uint mapend = srcEnd;
    uint loopcondition = tgtEnd;
    foo_for(initial, loopcondition, mapstart, mapend);
  }

  function foo_for(uint initial, uint loopcondition, uint _mapstart, uint _mapend) internal {
  for (uint i = initial; i < loopcondition; ++i) {
          tgtObj[i + _mapstart] = srcObj[i + _mapend];
    }
  }
    
  ")

  (define loop-body (string-replace 
    (string-replace 
    (string-replace 
    (string-replace 
    (string-replace 
      (string-replace template "srcObj" arg0) 
                               "srcStart" (if (number? arg1) (number->string arg1) arg1)) 
                               "srcEnd" arg2) 
                               "tgtObj" arg3) 
                               "tgtStart" (if (number? arg4) (number->string arg4) arg4)) 
                               "tgtEnd" arg5))
  (pretty-display (string-replace (string-replace (string-replace contract-template "_body" loop-body) "_storage1" arg0) "_args" arg0))
  )

(define (generate-copyrange-λ args)
  ;;; CopyRange(Src, srcStart, srcEnd, tgt, tgtStart, tgtEnd)
  ;;; src
  (define arg0 (vector-ref args 0))
  ;;; srcStart
  (define arg1 (vector-ref args 1))
  ;;; srcEnd
  (define arg2 (vector-ref args 2))
  ;;; tgt
  (define arg3 (vector-ref args 3))
  ;;; tgtStart
  (define arg4 (vector-ref args 4))
  ;;; tgtEnd
  (define arg5 (vector-ref args 5))
  ;;; λ-arg
  (define arg6 (vector-ref args 6))
  ;;; λ-body
  (define arg7 (vector-ref args 7))
  ;;; FIXME
  (set! arg7 (string-replace arg7 "\"" ""))

  (define rhs-expr (string-replace arg7 arg6 "srcObj[i]"))

  (define template "
    for (uint i = tgtStart; i < tgtEnd; ++i) {
          tgtObj[i] = srcObj[i];
    }
  ")
  (pretty-display (string-replace 
    (string-replace 
    (string-replace 
    (string-replace 
    (string-replace 
    (string-replace 
      (string-replace template 
                               "srcObj[i]" rhs-expr)
                               "srcObj" arg0) 
                               "srcStart" (if (number? arg1) (number->string arg1) arg1)) 
                               "srcEnd" (if (number? arg2) (number->string arg2) arg2)) 
                               "tgtObj" arg3) 
                               "tgtStart" (if (number? arg4) (number->string arg4) arg4)) 
                               "tgtEnd" (if (number? arg5) (number->string arg5) arg5))
                               ))

(define (translate code) 
    (for ([expr code])
      (match (inst-op expr)
        ["UPDATERANGE" (generate-updaterange (inst-args expr))]
        ["SHIFTLEFT" (generate-shiftleft (inst-args expr))]
        ["SUM" (generate-sum (inst-args expr))]
        ["MUL" (generate-mul (inst-args expr))]
        ["SUB" (generate-sub (inst-args expr))]
        ["SUM-λ" (generate-sum-λ (inst-args expr))]
        ["MAP" (generate-map (inst-args expr))]
        ["COPYRANGE" (generate-copyrange (inst-args expr))]
        ["COPYRANGE-λ" (generate-copyrange-λ (inst-args expr))]
        [_           (println "I dont know about this!!!")])

      ))
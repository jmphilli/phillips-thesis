#lang frtime

(require "box-requires.rkt")

#|
TODO : 
Make it so that the musics can come into this queue and pop back out (they're gonna need discrete time stamps essentially)
Write a function that decides which of the musics is more musical at any given time.
|#

#|****************************************************************************************************************************************************************************************************|#
#|things I need passed to me|#
(define clock (- seconds (value-now seconds)))
(define my-sig (new-cell))
(define my-func (lambda (x) x)) ;the function needs to take any number of arguments
(define base-value 0)
#|****************************************************************************************************************************************************************************************************|#

#|****************************************************************************************************************************************************************************************************|#
#|things I own|#
(define q (box '()));tuples of (time value) in q
#|****************************************************************************************************************************************************************************************************|#

#|****************************************************************************************************************************************************************************************************|#
#|Interface|#
(define (init-sig clk sig-ref func b-v)
  (begin
    (set! clock clk)
    (set! my-sig sig-ref)
    (set! my-func func)
    (set! base-value b-v)
    (go)))

(define (add-to-signal time new-value)
  (set-box! q (add-to-signal-queue_ time new-value (unbox q))))
#|****************************************************************************************************************************************************************************************************|#


#|****************************************************************************************************************************************************************************************************|#
#|Behind the scene stuff|#
(define (add-to-signal-queue_ time new-value queue)
  (if (empty? queue)
      (cons (cons time new-value) queue)
      (if (< (car (first queue)) time)
          (cons (first queue) (add-to-signal-queue_ time new-value (rest queue)))
          (cons (cons time new-value) queue))))

(define (go)
  (map-e (lambda (x)
           (let ([current-vals (find-all-values-at-time x (unbox q))])
             (if (empty? current-vals)
                 (set-cell! my-sig base-value)
                 (set-cell! my-sig (my-func current-vals)))
             (clean-out-queue))
             #;(set-cell! my-sig (foldr my-func base-value (find-all-values-at-time x (unbox q))))) (changes clock)))

(define (clean-out-queue)
  (set-box! q (clean-out-queue_ (unbox q))))

(define (clean-out-queue_ queue)
  (if (empty? queue)
      '()
      (if (< (car (first queue)) (value-now clock))
          (clean-out-queue_ (rest queue))
          queue)))

(define (find-all-values-at-time time queue)
  (if (or (empty? queue) #;(< time (car (first queue))))
      '()
      (if (<= (car (first queue)) time)
          (cons (cdr (first queue)) (find-all-values-at-time time (rest queue)))
          (find-all-values-at-time time (rest queue)))))
#|****************************************************************************************************************************************************************************************************|#


#|****************************************************************************************************************************************************************************************************|#
#|Tests
(add-to-signal-queue 10 2)
(add-to-signal-queue 10 3)
(add-to-signal-queue 10 55)

(add-to-signal-queue 20 3)
(add-to-signal-queue 20 2)

(add-to-signal-queue 10 1)
(add-to-signal-queue 1 2)
(add-to-signal-queue 0 3)
(add-to-signal-queue 4 4)
(add-to-signal-queue 7 5)
(init-sig my-sig max 0)
;32451|#
#|****************************************************************************************************************************************************************************************************|#
(provide init-sig add-to-signal)
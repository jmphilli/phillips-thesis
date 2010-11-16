#lang frtime
(require "signal-interface.rkt")

(define my-sig (new-cell))

(define b-v -1)

(define (func . tl)
  (first (first tl)))

(init-sig (- seconds (value-now seconds)) my-sig func b-v)

(add-to-signal 1 10)
(add-to-signal 1 44)
(add-to-signal 1 2)
(add-to-signal 2 11)
(add-to-signal 3 12)
